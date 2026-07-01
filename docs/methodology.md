# Methodology

## Overview

The Australian Labour Market Stress Index (LMSI) was developed to provide a composite measure of labour market stress across Australian states and industries.

Rather than relying on a single labour market indicator, the LMSI integrates multiple dimensions of labour market conditions into a transparent and interpretable composite framework.

The index is designed to identify where labour market pressure is concentrated, how it evolves over time, and which factors contribute most to observed stress.

---

# Data Sources

The LMSI was constructed using publicly available datasets from the Australian Bureau of Statistics (ABS).

Three statistical collections were integrated:

- Job Vacancies
- Labour Force
- Wage Price Index

Across these collections, ten ABS datasets were used throughout the project.

The analytical period covers:

**2009Q4 – 2026Q1**

---

# Composite Framework

The final LMSI combines three labour market dimensions.

| Dimension | Weight |
|-----------|-------:|
| Vacancy Intensity | 40% |
| Wage Pressure | 30% |
| Labour Tightness | 30% |

Each component represents a different aspect of labour market conditions.

### Vacancy Intensity

Measures hiring demand relative to employment.

### Wage Pressure

Captures labour market pressure reflected in wage growth.

### Labour Tightness

Measures labour scarcity using vacancy and unemployment information.

---

# Weighting Approach

The weighting framework was selected using analytical judgement informed by labour economics.

Rather than relying solely on statistical optimisation, the model prioritises economic interpretability and practical policy relevance.

Vacancy Intensity receives the highest weight because it provides the most direct signal of employer demand, while Wage Pressure and Labour Tightness capture complementary dimensions of labour market conditions.

---

# Data Processing Workflow

The project follows an end-to-end analytical workflow.

```text
Australian Bureau of Statistics (ABS)
        │
        ▼
Python
(Data transformation)
        │
        ▼
PostgreSQL
(Data modelling)
        │
        ▼
Excel
(Validation & robustness testing)
        │
        ▼
Power BI
(Interactive dashboard)
        │
        ▼
Analytical Memo
```

---

# Model Development

The LMSI evolved through multiple iterations during development.

An earlier version used a proxy measure for Labour Tightness which exhibited a high correlation with Vacancy Intensity (≈0.85).

To improve conceptual independence, the Labour Tightness component was redesigned using a vacancy-to-unemployment framework, reducing component correlation to approximately 0.52.

This revision improved the interpretability of the composite index while preserving its analytical consistency.

---

# Validation

Several quality assurance procedures were performed throughout development.

- 1,187 observations validated
- Zero duplicate joins
- Zero missing values after processing*
- Standardised indicators prior to aggregation
- Cross-validation in Microsoft Excel
- Robustness testing across alternative weighting schemes
- Version comparison between LMSI v1 and v1.1

\*One documented outlier was intentionally excluded due to an unstable denominator in the Labour Tightness calculation.

---

# Limitations

Several methodological considerations should be recognised.

- The LMSI measures labour market stress rather than labour market performance.
- Some indicators represent analytical proxy measures.
- Component weights reflect analytical judgement rather than statistical optimisation.
- Results are intended to support—not replace—policy judgement.

---

# Reproducibility

The repository contains all analytical assets required to reproduce the project, including:

- Raw ABS datasets
- Python transformation scripts
- SQL database scripts
- Processed datasets
- Excel validation workbook
- Power BI dashboard
- Analytical memo

The workflow has been designed to maximise transparency and reproducibility while maintaining a clear separation between data preparation, modelling, validation and reporting.
