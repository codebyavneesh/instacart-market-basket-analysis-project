# Instacart Market Basket Analysis — End-to-End Data Pipeline & Power BI Dashboard

An end-to-end data analytics project on the Instacart dataset (~32M rows), covering the full pipeline from raw CSV ingestion to an interactive Power BI dashboard — built using MySQL, Python, and advanced SQL analytics.

---

## 📌 Overview

This project analyzes Instacart's grocery ordering data to uncover patterns in customer purchase behavior, product reordering trends, department/aisle performance, and product co-purchase relationships (market basket analysis).

The pipeline follows a real-world analytics workflow:

**Raw CSV → MySQL (validated load) → SQL Analytics → Python (EDA) → Power BI Dashboard**

---

## 🧰 Tech Stack

| Layer | Tools |
|---|---|
| Database | MySQL |
| Data Validation & Loading | Python |
| Analysis | Python (Pandas, NumPy, Matplotlib, Seaborn) |
| Advanced Querying | SQL (CTEs, self-joins, window functions) |
| Visualization | Power BI |
| Environment | Jupyter Notebook |

---

## 🗂️ Project Structure

```
instacart-market-basket-analysis/
│
├── data_validation/       # Data quality checks — nulls, duplicates, referential integrity — before DB load
├── load/                  # Scripts to load validated CSVs into MySQL (instacart_db)
├── sql/                   # Advanced SQL analytics: 20 queries using CTEs, self-joins, cross-department analysis
├── python_analysis/       # Jupyter notebooks — EDA, Python-MySQL connectivity, visualizations
├── screenshots/           # Dashboard page screenshots (dashboard1.png – dashboard4.png)
└── README.md
```

> Raw CSVs are **not included** in this repo (~32M rows, too large for Git) — see the [Dataset](#-dataset) section below for the download link.
>
> **TODO:** Add `data/` to a `.gitignore` file so it's actually excluded — this note alone won't stop it from being committed if it's still tracked locally.

> **TODO:** Update the tree above once inside each folder — add exact filenames/notebook names so a visitor can navigate straight to the right file.

---

## 📊 Dataset

- **Source:** [Instacart Market Basket Analysis — Kaggle](https://www.kaggle.com/c/instacart-market-basket-analysis/data) (orders, products, aisles, departments, order_products__prior, order_products__train)
- **Scale:** ~32 million rows loaded into MySQL
- **Storage:** MySQL database `instacart_db`
- **Note:** Raw CSVs are not committed to this repo due to size — download them from the Kaggle link above and place them locally before running the pipeline.

> **TODO:** Confirm this is the exact Kaggle page/version you downloaded from — there are a few re-uploaded mirrors of this dataset on Kaggle, so double-check before publishing.

---

## 🔄 Pipeline Stages

1. **Dataset download** — Raw CSVs sourced from Kaggle (see [Dataset](#-dataset)), not stored in this repo
2. **`data_validation/`** — Pre-load checks (nulls, duplicates, foreign key integrity)
3. **`load/`** — Bulk load into MySQL (`instacart_db`)
4. **`sql/`** — 20 advanced SQL queries: self-joins, CTEs, window functions, cross-department analysis
5. **`python_analysis/`** — Python-MySQL connectivity, EDA, and visual analysis in Jupyter
6. **Power BI** — Final 4-page interactive dashboard

---

## 📈 Power BI Dashboard

A dark-themed, 4-page interactive dashboard:

**1. Overview** — High-level KPIs (customers, products, orders, reorder rate) and order trends
![Overview Dashboard](https://github.com/codebyavneesh/instacart-market-basket-analysis-project/blob/main/intercast_marker_basket_analysis_project/screenshots/dashboard1.png)

**2. Order Patterns** — Order timing, frequency, and reorder behavior by hour/day
![Order Patterns Dashboard](https://github.com/codebyavneesh/instacart-market-basket-analysis-project/blob/main/intercast_marker_basket_analysis_project/screenshots/dashboard2.png)

**3. Product & Department Analysis** — Department/aisle-level performance and reorder rates
![Product & Department Analysis Dashboard](https://github.com/codebyavneesh/instacart-market-basket-analysis-project/blob/main/intercast_marker_basket_analysis_project/screenshots/dashboard3.png)

**4. Market Basket / Co-purchase Insights** — Product association and co-purchase pairs
![Market Basket Dashboard](https://github.com/codebyavneesh/instacart-market-basket-analysis-project/blob/main/intercast_marker_basket_analysis_project/screenshots/dashboard4.png)

> ⚠️ **Rendering note:** `/blob/` GitHub URLs point to the file preview page, not the raw image — they can show as broken images depending on where the README is viewed. If the screenshots don't render on your repo page, switch each link's domain to `raw.githubusercontent.com` (same path, no `/blob/`), or simpler: use the relative path `screenshots/dashboard1.png` since the images already live in this repo — relative paths always resolve correctly and need no editing if you rename the repo later.

**Planned enhancement:** A 5th page on **Customer Behavior** (segmentation, cohort/retention analysis) is deferred to a future update.

---

## 🔍 SQL Analytics Highlights

20 advanced SQL queries covering:
- Self-joins for reorder/repeat-purchase patterns
- CTEs for multi-step aggregations
- Window functions for ranking and running metrics
- Cross-department and cross-aisle comparative analysis

> **TODO:** List the actual 20 questions here (or link to `sql/README.md` if you document them separately).

---

## 💡 Key Insights

> **TODO:** Add 3–5 concrete findings once finalized, e.g. reorder rate %, peak ordering hours, top co-purchased product pairs. Concrete numbers here are what recruiters actually read — don't skip this section.

---

## ⚙️ Technical Challenges

- Loading and managing a ~32M-row dataset in MySQL, including diagnosing and resolving a table lock/rollback issue during bulk import.
- Designing a validation layer to catch data quality issues *before* they reached the database, rather than cleaning after the fact.

---

## 🚧 Future Enhancements

- Customer Behavior dashboard page (segmentation, retention)
- Forecasting/predictive analytics page (planned post scikit-learn training)

---

## 🚀 How to Run

```bash
# 1. Clone the repo
git clone https://github.com/codebyavneesh/<repo-name>.git
cd <repo-name>

# 2. Download the dataset from Kaggle (see Dataset section) and place the CSVs
#    in a local `data/` folder — this folder is gitignored, not part of the repo
mkdir data && cd data
# download & unzip Instacart CSVs here

# 3. Set up MySQL and create the database
mysql -u root -p < sql/schema.sql   # update path to your actual schema file

# 4. Run data validation
python data_validation/<script_name>.py   # update filename

# 5. Load data into MySQL
python load/<script_name>.py   # update filename

# 6. Run SQL analytics
# Execute queries in sql/ against instacart_db

# 7. Explore Python analysis
jupyter notebook python_analysis/

# 8. Open the Power BI dashboard
# Open the .pbix file in Power BI Desktop
```

> **TODO:** Replace placeholder filenames/paths above with your actual script names.

---

## 👤 Author

**Avneesh**
GitHub: [@codebyavneesh](https://github.com/codebyavneesh)
LinkedIn: [codebyavneesh](https://linkedin.com/in/codebyavneesh)
