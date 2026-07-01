-- ============================================================
-- LMSI PROJECT — SQL SETUP
-- Australian Labour Market Stress Index
-- ============================================================

-- ============================================================
-- SCHEMA
-- ============================================================

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS analytics;

-- ============================================================
-- RAW TABLES
-- ============================================================

-- Employment: state x industry x quarter (ABS EQ06)
CREATE TABLE IF NOT EXISTS raw.lf_employment (
    date VARCHAR(10),
    state VARCHAR(50),
    industry VARCHAR(100),
    employed_thousands NUMERIC(10,2)
);

-- Job Vacancies: industry x quarter, national (ABS Table 4)
CREATE TABLE IF NOT EXISTS raw.jv_vacancies (
    date VARCHAR(10),
    industry VARCHAR(100),
    vacancies_thousands NUMERIC(10,2)
);

-- Wage Price Index: industry x quarter, national (ABS Table 5b)
CREATE TABLE IF NOT EXISTS raw.wpi_industry (
    date VARCHAR(10),
    industry VARCHAR(100),
    wpi_growth NUMERIC(8,4)
);

-- Unemployment: state x industry x quarter (ABS UQ2b)
-- Source: 6291.0.55.001 — unemployed persons by industry of last job
-- NOTE: "industry of last job" is not equivalent to current sector job seekers
-- This is a proxy for industry-level unemployment — interpreted accordingly
CREATE TABLE IF NOT EXISTS raw.uq2b_unemployment (
    date VARCHAR(10),
    state VARCHAR(50),
    industry VARCHAR(100),
    unemployed_thousands NUMERIC(10,4)
);

-- ============================================================
-- BASE VIEW — JOIN all sources
-- ============================================================

-- Common date range: 2009Q4 onwards (driven by Job Vacancies availability)
-- Job Vacancies and WPI are national-level, applied uniformly across states
-- METHODOLOGY NOTE:
-- jv_vacancies and wpi_industry are national industry-level datasets.
-- State-level differences in lmsi_score reflect employment-adjusted allocation
-- of national industry pressure, not state-specific vacancy or wage counts.
-- Interpretation: "where national industry-level labour pressure is most intense
-- relative to each state's sector workforce size."

CREATE OR REPLACE VIEW analytics.lmsi_base AS
SELECT
    e.date,
    e.state,
    e.industry,
    e.employed_thousands,
    j.vacancies_thousands,
    w.wpi_growth,
    u.unemployed_thousands
FROM raw.lf_employment e
LEFT JOIN raw.jv_vacancies j
    ON e.date = j.date
    AND e.industry = j.industry
LEFT JOIN raw.wpi_industry w
    ON e.date = w.date
    AND e.industry = w.industry
LEFT JOIN raw.uq2b_unemployment u
    ON e.date = u.date
    AND e.state = u.state
    AND e.industry = u.industry
WHERE e.date >= '2009Q4';

-- ============================================================
-- ANALYTICS VIEW — LMSI SCORES
-- Core LMSI = 40% Vacancy Intensity + 30% Wage Pressure + 30% Labour Tightness
-- Component 3 uses textbook tightness: vacancies / unemployed_by_industry
-- Eliminates overlap between Component 1 and Component 3
-- NOTE: analytics.lmsi_base is referenced twice across CTEs — intentional
-- for component independence and readability.
-- OUTLIER FILTER: unemployed_thousands > 0.5 applied to remove 1 extreme
-- observation (QLD Prof.Sci. 0.1828 — produces astronomical tightness ratio)
-- Score bands: 0-25 Low | 25-45 Moderate | 45-60 High | 60+ Critical
-- Bands revised to reflect compressed score distribution under UQ2B tightness metric.
-- Peak observed score: 65.02 (QLD Professional Services, 2023Q1)
-- FUTURE ENHANCEMENT:
-- UQ2B "industry of last job" limitation acknowledged. A more precise
-- unemployment measure at industry level is not available from ABS.
-- Recommended for robustness check when better data becomes available.
-- ============================================================

CREATE OR REPLACE VIEW analytics.lmsi_scores AS
-- Components are normalized across the full historical sample
-- to preserve intertemporal comparability of LMSI scores.
-- Labour tightness is operationalised as vacancies relative to
-- available unemployed workers, approximating sector-specific labour scarcity.
-- Outlier filter: unemployed_thousands > 0.5 excludes extremely small
-- unemployment denominators that generate unstable tightness ratios.
-- Score bands: 0-25 Low | 25-45 Moderate | 45-60 High | 60+ Critical
WITH tightness AS (
    SELECT date, state, industry,
        vacancies_thousands / NULLIF(unemployed_thousands, 0) AS tightness_raw
    FROM analytics.lmsi_base
    WHERE unemployed_thousands > 0.5
),
tightness_norm AS (
    SELECT date, state, industry,
        (tightness_raw - MIN(tightness_raw) OVER()) /
        NULLIF(MAX(tightness_raw) OVER() - MIN(tightness_raw) OVER(), 0) * 100 AS tightness_norm
    FROM tightness
),
vi AS (
    SELECT date, state, industry,
        (vacancies_thousands / employed_thousands - MIN(vacancies_thousands / employed_thousands) OVER()) /
        NULLIF(MAX(vacancies_thousands / employed_thousands) OVER() - MIN(vacancies_thousands / employed_thousands) OVER(), 0) * 100 AS vi_norm
    FROM analytics.lmsi_base
),
wpi AS (
    SELECT date, state, industry,
        (wpi_growth - MIN(wpi_growth) OVER()) /
        NULLIF(MAX(wpi_growth) OVER() - MIN(wpi_growth) OVER(), 0) * 100 AS wpi_norm
    FROM analytics.lmsi_base
)
SELECT
    v.date, v.state, v.industry,
    ROUND(v.vi_norm::numeric, 2) AS vi_norm,
    ROUND(w.wpi_norm::numeric, 2) AS wpi_norm,
    ROUND(t.tightness_norm::numeric, 2) AS tightness_norm,
    ROUND((v.vi_norm * 0.40 + w.wpi_norm * 0.30 + t.tightness_norm * 0.30)::numeric, 2) AS lmsi_score,
    ROUND((v.vi_norm * 0.40)::numeric, 2) AS vi_contribution,
    ROUND((w.wpi_norm * 0.30)::numeric, 2) AS wpi_contribution,
    ROUND((t.tightness_norm * 0.30)::numeric, 2) AS lt_contribution
FROM vi v
JOIN wpi w ON v.date = w.date AND v.state = w.state AND v.industry = w.industry
JOIN tightness_norm t ON v.date = t.date AND v.state = t.state AND v.industry = t.industry;

