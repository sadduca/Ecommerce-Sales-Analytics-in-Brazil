# 📊 End-to-End Business Intelligence Project | Brazil E-commerce Analytics

This project simulates a corporate Business Intelligence environment using a real-world Brazilian e-commerce dataset provided by Olist.

The objective was to replicate a real analytical workflow: loading raw CSV files into a local SQL Server database, transforming transactional data using SQL, and developing interactive dashboards in Power BI for business performance analysis.

---

## 🗄 Data Source

Dataset: Brazilian E-Commerce Public Dataset by Olist    
Reference: https://doi.org/10.34740/kaggle/dsv/195341 

To simulate a real corporate environment:

- Raw CSV files were imported into a local Microsoft SQL Server database.
- A structured relational database was created.
- SQL queries were used to transform transactional data into an analytical dataset optimized for reporting.

This approach mirrors how data teams operate in enterprise environments where databases are queried rather than flat files.

---

## 🚀 Project Highlights

- End-to-end ETL process using SQL Server.
- Creation of an analytical dataset from normalized transactional tables.
- Business metric design (revenue, AOV, shipping contribution).
- Interactive and dynamic dashboard development in Power BI.
- Simulation of a real-world BI workflow from database to executive reporting.

---

## 🛠 Tech Stack

- Microsoft SQL Server
- Power BI
- DAX
- SQL
- ETL
- Data Cleaning & Transformation

---

## 📈 Power BI Dashboard

The report is structured into two main analytical pages.

### 🔹 Shared KPIs (Available in Both Pages)

The following core metrics are displayed consistently across both dashboards:

- Total Revenue
- Revenue (Sales)
- Revenue (Shipping)

These KPIs provide a unified performance reference across different analytical perspectives.

---

### 1️⃣ Performance Overview

Focus: Executive-level performance monitoring.

Includes:

- Total products sold
- Average Order Value (AOV)
- Average product revenue per order
- Average shipping revenue per order
- Revenues and products sold time-series evolution
- Monthly Growth (MoM %)
- Total Revenue and Average Product Revenue per Order Over the Year
- Dynamic month slicer

![Performance Overview](images/performance_overview.png)

---

### 2️⃣ Segment Performance

Focus: Regional and product segmentation analysis.

Includes:

- Top 10 Brazilian states by revenue
- Top 10 Brazilian states by products sold
- Top 10 most profitable product categories
- Payment type distribution
- Monthly filtering interaction

![Segment Performance](images/segment_performance.png)

---

## 🎯 Business Objective

This project aims to demonstrate how raw transactional data can be transformed into actionable business insights by:

- Monitoring revenue performance
- Understanding logistics contribution (shipping vs sales)
- Evaluating time-series growth
- Analyzing regional and product-level segmentation
- Supporting strategic decision-making

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

If you would like to discuss this project or explore potential collaboration opportunities, feel free to reach out via email or connect with me on LinkedIn.
