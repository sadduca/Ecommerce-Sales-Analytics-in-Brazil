# 📊 End-to-End Business Intelligence Project | Brazil E-commerce Analytics

End-to-end data analytics project based on a Brazilian e-commerce dataset.  
Data modeling and transformation were performed in SQL Server, and interactive business intelligence dashboards were developed in Power BI.

---

## 🛠 Tech Stack

- SQL Server
- Power BI
- Data Modeling
- DAX
- Data Cleaning & Transformation

---

## 🧱 Data Modeling Process

The project involved building an analytical dataset optimized for business intelligence.

Main steps:

1. Exploration of raw transactional tables.
2. Monetary value normalization (price and freight adjustments).
3. Creation of intermediate analytical table `fact_sales`.
4. Filtering for delivered orders only.
5. Product category translation to English.
6. Missing value handling using `COALESCE`.
7. Final analytical table `fact_sales_final` prepared for Power BI consumption.

The complete SQL transformation script is available in the `/sql` directory.

---

## 📈 Power BI Dashboard

The report includes two main pages:

### 1️⃣ Performance Overview

- Total revenue KPIs
- Revenue breakdown (sales & freight)
- Total products sold
- Average ticket value
- Average freight value
- Revenue time evolution
- Monthly growth percentage
- Dynamic month slicer

![Performance Overview](images/resumen_desempeno.png)

---

### 2️⃣ Segment Performance

- Revenue by state
- Revenue distribution by product category
- Payment type analysis
- Dynamic Top 10 states
- Monthly filtering interaction

![Segment Performance](images/desempeno_por_segmento.png)

---

## 🎯 Project Objective

To design a structured analytical dataset and develop an interactive dashboard that enables:

- Business performance monitoring
- Revenue distribution analysis
- Time-series evaluation
- Multi-dimensional segmentation

---

## 📌 Repository Structure

```
ecommerce-analytics-brazil/
│
├── README.md
├── sql/
│   └── sales_etl_for_power_bi.sql
├── powerbi/
│   └── ecommerce_dashboard.pbix
└── images/
    ├── performance_overview.png
    └── segment_performance.png
```

---

## 👤 Author

Santino Adduca  
Data Analyst | Data Scientist  
Buenos Aires, Argentina
