-- ============================================================
-- LMSI COMPONENTS — Development & Testing File
-- Australian Labour Market Stress Index
-- NOTE: This file contains individual component queries for
-- development and testing purposes only.
-- Final LMSI score is defined as analytics.lmsi_scores in 01_setup.sql
-- ============================================================

-- ============================================================
-- COMPONENT 1: VACANCY INTENSITY (NORMALIZED)
-- vacancies / employed_thousands, scaled 0-100
-- ============================================================

WITH cte1 AS (
    SELECT
        date,
        state,
        industry,
        vacancies_thousands / employed_thousands AS vacancy_intensity
    FROM analytics.lmsi_base
),
cte2 AS (
    SELECT
        date,
        state,
        industry,
        vacancy_intensity,
        (vacancy_intensity - MIN(vacancy_intensity) OVER ()) /
        NULLIF(MAX(vacancy_intensity) OVER () - MIN(vacancy_intensity) OVER (), 0) * 100 AS vi_norm
    FROM cte1
)
SELECT *
FROM cte2
ORDER BY date, state, industry;

-- ============================================================
-- COMPONENT 2: WAGE GROWTH PRESSURE (NORMALIZED)
-- WPI year-on-year growth, scaled 0-100
-- ============================================================

WITH cte1 AS (
    SELECT
        date,
        state,
        industry,
        wpi_growth 
    FROM analytics.lmsi_base
),
cte2 AS (
    SELECT
        date,
        state,
        industry,
        wpi_growth,
        (
            wpi_growth - MIN(wpi_growth) OVER ()) /
        NULLIF(MAX(wpi_growth) OVER () - MIN(wpi_growth) OVER (), 0) * 100 AS wpi_norm
    FROM cte1
)
SELECT *
FROM cte2
ORDER BY date, state, industry;

-- ============================================================
-- COMPONENT 3: LABOUR TIGHTNESS PROXY (NORMALIZED)
-- vacancy_intensity × wpi_growth
-- High vacancies + high wage growth = genuine labour shortage signal
-- Triangulation logic: isolates simultaneous demand and compensation pressure
-- NOTE: This is the legacy interaction proxy (v1 methodology).
-- Current methodology uses textbook tightness: vacancies / unemployed_by_industry
-- See analytics.lmsi_scores in 01_setup.sql for final implementation.
-- ============================================================

WITH cte1 AS (
    SELECT
        date,
        state,
        industry,
        (vacancies_thousands / employed_thousands) * wpi_growth AS tightness_proxy
    FROM analytics.lmsi_base
),
cte2 AS (
    SELECT
        date,
        state,
        industry,
        tightness_proxy,
        (tightness_proxy - MIN(tightness_proxy) OVER ()) /
        NULLIF(MAX(tightness_proxy) OVER () - MIN(tightness_proxy) OVER (), 0) * 100 AS tightness_norm
    FROM cte1
)
SELECT *
FROM cte2
ORDER BY date, state, industry;

-- ============================================================
-- FINAL LMSI SCORE — Legacy Test Query (v1 interaction proxy)
-- NOTE: This uses the old tightness methodology for comparison purposes.
-- Current final LMSI is defined in analytics.lmsi_scores (01_setup.sql)
-- which uses UQ2B unemployment-based tightness.
-- ============================================================

-- ============================================================
-- FINAL LMSI SCORE — Test Query
-- Same logic as analytics.lmsi_scores view in 01_setup.sql
-- Run this to verify view output manually
-- ============================================================

WITH emp AS (
    SELECT date, state, industry,
        vacancies_thousands / employed_thousands AS vi
    FROM analytics.lmsi_base
),
vi AS (
    SELECT date, state, industry,
        (vi - MIN(vi) OVER ()) /
        NULLIF(MAX(vi) OVER () - MIN(vi) OVER (), 0) * 100 AS vi_norm
    FROM emp
),
wpi AS (
    SELECT date, state, industry,
        (wpi_growth - MIN(wpi_growth) OVER ()) /
        NULLIF(MAX(wpi_growth) OVER () - MIN(wpi_growth) OVER (), 0) * 100 AS wpi_norm
    FROM analytics.lmsi_base
),
tight AS (
    SELECT date, state, industry,
        (vacancies_thousands / employed_thousands) * wpi_growth AS tp
    FROM analytics.lmsi_base
),
tight_norm AS (
    SELECT date, state, industry,
        (tp - MIN(tp) OVER ()) /
        NULLIF(MAX(tp) OVER () - MIN(tp) OVER (), 0) * 100 AS tightness_norm
    FROM tight
)
SELECT 
    v.date, v.state, v.industry,
    ROUND(v.vi_norm::numeric, 2) AS vi_norm,
    ROUND(w.wpi_norm::numeric, 2) AS wpi_norm,
    ROUND(t.tightness_norm::numeric, 2) AS tightness_norm,
    ROUND((v.vi_norm * 0.40 + w.wpi_norm * 0.30 + t.tightness_norm * 0.30)::numeric, 2) AS lmsi_score
FROM vi v
JOIN wpi w ON v.date = w.date AND v.state = w.state AND v.industry = w.industry
JOIN tight_norm t ON v.date = t.date AND v.state = t.state AND v.industry = t.industry
ORDER BY lmsi_score DESC;

-- ============================================================
-- PEAK VS CURRENT DECOMPOSITION
-- 2023Q1 (peak) vs 2026Q1 (current) — component breakdown
-- Which component drove the peak? Which has since moderated?
-- ============================================================

SELECT
    s.state,
    s.industry,
    s.date,
    s.lmsi_score,
    s.vi_contribution,
    s.wpi_contribution,
    s.lt_contribution
FROM analytics.lmsi_scores s
WHERE s.date IN ('2023Q1', '2026Q1')
ORDER BY s.industry, s.state, s.date;

-- ============================================================
-- MODEL COMPARISON — Interaction Tightness vs Unemployment Tightness
-- Compares v1 (interaction proxy) with v2 (vacancies / unemployed)
-- Shows which sectors changed rank and by how much
-- ============================================================

WITH old_tightness AS (
    SELECT date, state, industry,
        (vacancies_thousands / employed_thousands) * wpi_growth AS tp
    FROM analytics.lmsi_base
),
old_tight_norm AS (
    SELECT date, state, industry,
        (tp - MIN(tp) OVER()) /
        NULLIF(MAX(tp) OVER() - MIN(tp) OVER(), 0) * 100 AS tightness_norm
    FROM old_tightness
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
),
lmsi_v1 AS (
    SELECT v.date, v.state, v.industry,
        ROUND((v.vi_norm * 0.40 + w.wpi_norm * 0.30 + t.tightness_norm * 0.30)::numeric, 2) AS lmsi_v1
    FROM vi v
    JOIN wpi w ON v.date = w.date AND v.state = w.state AND v.industry = w.industry
    JOIN old_tight_norm t ON v.date = t.date AND v.state = t.state AND v.industry = t.industry
)
SELECT
    n.date, n.state, n.industry,
    o.lmsi_v1,
    n.lmsi_score AS lmsi_v2,
    ROUND((n.lmsi_score - o.lmsi_v1)::numeric, 2) AS score_change
FROM analytics.lmsi_scores n
JOIN lmsi_v1 o ON n.date = o.date AND n.state = o.state AND n.industry = o.industry
WHERE n.date = '2026Q1'
ORDER BY o.lmsi_v1 DESC
LIMIT 10;

-- ============================================================
-- CORRELATION DIAGNOSTICS
-- Tests whether overlap between Component 1 and Component 3
-- has been resolved by the UQ2B unemployment-based tightness metric.
-- Expected: new corr(vi_norm, tightness_norm) significantly lower
-- than old interaction proxy correlation.
-- ============================================================

SELECT
    ROUND(CORR(vi_norm, tightness_norm)::numeric, 4) AS corr_vi_tightness,
    ROUND(CORR(vi_norm, wpi_norm)::numeric, 4) AS corr_vi_wpi,
    ROUND(CORR(wpi_norm, tightness_norm)::numeric, 4) AS corr_wpi_tightness
FROM analytics.lmsi_scores;