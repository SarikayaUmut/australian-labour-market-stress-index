# 🇦🇺 Australian Labour Market Stress Index (LMSI)

> **An end-to-end labour market analytics project that develops a composite Labour Market Stress Index (LMSI) using Australian Bureau of Statistics (ABS) data.**

![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-ETL-3776AB?logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-336791?logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Analysis-blue)
![Excel](https://img.shields.io/badge/Excel-Validation-217346?logo=microsoftexcel&logoColor=white)

---

# 📖 Table of Contents

- Project Overview
- Dashboard Preview
- Research Objectives
- Dashboard Structure
- Analytical Workflow
- Methodology
- Repository Structure
- Key Findings
- Technology Stack
- Data Sources
- Validation
- Limitations
- Future Improvements

---

# 📊 Dashboard Preview

![](dashboard/screenshots/page01.png)

---

# 🌏 Project Overview

The **Australian Labour Market Stress Index (LMSI)** is a composite indicator designed to measure labour market stress across Australian industries and states between **2009Q4 and 2026Q1**.

Instead of relying on a single labour market metric, the LMSI integrates multiple indicators into a single framework that captures labour demand, wage pressure and labour tightness.

The project demonstrates a complete analytics workflow—from raw Australian Bureau of Statistics (ABS) datasets through data engineering, SQL modelling, dashboard development and executive reporting.

---

# 🎯 Research Objectives

The project aims to:

- Build a composite Labour Market Stress Index (LMSI)
- Compare labour market stress across industries and states
- Identify the drivers of labour market pressure
- Translate quantitative findings into policy-relevant insights
- Demonstrate an end-to-end analytics workflow suitable for consulting and economic analysis

---

# 📈 Dashboard Structure

| Page   | Question Answered                               |
| ------ | ----------------------------------------------- |
| **01** | What is the LMSI and why does it matter?        |
| **02** | Where is labour market stress highest?          |
| **03** | What is driving labour market stress?           |
| **04** | How has labour market stress evolved over time? |
| **05** | What are the policy implications?               |
| **06** | How was the index constructed?                  |

---

# ⚙️ Analytical Workflow

```
Australian Bureau of Statistics (ABS)
                │
                ▼
Python Data Transformation
                │
                ▼
PostgreSQL Data Modelling
                │
                ▼
Composite LMSI Construction
                │
                ▼
Excel Validation
                │
                ▼
Power BI Dashboard
                │
                ▼
Analytical Memo
```

---

# 🧮 Methodology

The Labour Market Stress Index combines three labour market dimensions into a weighted composite framework.

| Component         | Weight  | Purpose                  |
| ----------------- | ------- | ------------------------ |
| Vacancy Intensity | **40%** | Measures labour demand   |
| Wage Pressure     | **30%** | Measures wage growth     |
| Labour Tightness  | **30%** | Measures labour scarcity |

The weighting framework reflects analytical judgement informed by labour economics while maintaining transparency and interpretability.

---

# 📂 Repository Structure

```
australian-labour-market-stress-index/

├── dashboard/
│   ├── LMSI_Dashboard.pbix
│   ├── LMSI_Dashboard.pdf
│   └── screenshots/
│
├── data/
│   ├── raw/
│   └── processed/
│
├── python/
│
├── sql/
│
├── excel/
│
├── memo/
│
├── docs/
│
├── LICENSE
└── README.md
```

---

# 📌 Key Findings

- Labour market stress has eased from its 2023 peak but remains structurally elevated: the average LMSI is down 30.6% from its 2023Q3 peak, yet still 47.4% above the 2019 pre-pandemic level.
- Wage pressure is the dominant driver in 85% of observations.
- Accommodation & Food Services is the highest-stress sector across all three states analysed (QLD 44.1, 2026Q1).
- Health Care continues to experience persistent labour shortages.
- Education & Training currently records the lowest labour market stress.

---

# 🛠 Technology Stack

| Category        | Technology                                                                                |
| --------------- | ----------------------------------------------------------------------------------------- |
| Data Source     | Australian Bureau of Statistics (ABS)                                                     |
| Data Processing | Python (AI-assisted ETL scripts)
| Database        | PostgreSQL                                                                                |
| Query Language  | SQL                                                                                       |
| Validation      | Microsoft Excel                                                                           |
| Dashboard       | Power BI                                                                                  |
| Reporting       | Analytical Memo                                                                           |

---

# 📑 Data Sources

The project draws on **10 raw ABS data files** from three statistical collections. **Four core tables** feed the final index; the remaining files were used for exploration and cross-checking.

| Collection | Raw files | Used in LMSI |
| --- | --- | --- |
| **Job Vacancies** | Table 1 (vacancies by state), Table 4 (vacancies by industry) | ✅ Table 4 → Vacancy Intensity, Labour Tightness |
| **Labour Force** | EQ06 (employment by industry × state), Table 5 (state × industry, .xlsx and .csv), UQ2b (unemployment by industry × state) | ✅ EQ06 → employment denominator · ✅ UQ2b → Labour Tightness |
| **Wage Price Index** | Table 1 (wages by state), Table 2 (wages by industry), Table 3b (industry, quarterly), Table 5b (industry, quarterly) | ✅ Table 5b → Wage Pressure |

All data is publicly available from the Australian Bureau of Statistics.

---

# ✅ Validation

The analytical workflow includes:

- 1,187 validated observations
- 66 quarterly periods (2009Q4–2026Q1)
- 6 industries
- 3 Australian states
- Zero missing values
- Zero duplicate records
- Standardised indicators before aggregation
- Cross-validation in Excel
- Component correlation (Vacancy Intensity vs Labour Tightness) reduced from 0.85 to 0.52 after redesigning the tightness metric (v1.0 → v1.1)
- Top-3 ranking stable across five weighting scenarios

---

# ⚠️ Limitations

- Measures labour market stress rather than labour market performance.
- Some indicators rely on proxy measures.
- Weights reflect analytical judgement rather than statistical optimisation.
- One documented outlier was excluded due to an unstable denominator.
- Results support—not replace—policy judgement.

---

# 🚀 Future Improvements

Potential future enhancements include:

- Expand coverage to all Australian states and territories.
- Introduce additional labour market indicators.
- Automate the ETL workflow.
- Deploy the dashboard using Power BI Service.
- Explore alternative weighting methodologies.

---

# 👨‍💻 Author

**Umut Sarikaya**

Master of International Economics and Finance

The University of Queensland

---

## 📄 License

Released under the **MIT License**.
