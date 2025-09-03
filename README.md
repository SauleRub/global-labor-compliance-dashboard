# 🌍 Global Workforce & Economic Trends (2000–2023)

## 📌 Project Overview  
This project explores the intersection of economic development and labor markets across more than 180 countries (2000–2023), using data from the **International Labour Organization (ILO)** and **World Bank**.  

The analysis focuses on:  
- **GDP per capita disparities** across countries and regions  
- **Labor Force Participation Rate (LFPR)**  
- **Employment structure** by sector (Agriculture, Industry, Services)  
- **Unemployment rates** and global/regional benchmarks  
- **Trends over time** and cross-regional comparisons  

The results are presented through a series of **interactive Tableau dashboards**, designed to support companies, policymakers, and researchers in understanding labor force dynamics and global inequalities.  

---

## 🛠 Tech Stack

### 📊 Data Collection & Processing
- **Python** (Pandas, NumPy) → cleaning, reshaping, filtering datasets  
- Regex & String handling → standardizing country names  
- Custom Python scripts → tagging countries vs regions, creating calculated fields (LFPR corrected, unemployment %)  

### 🗄 Database & Queries
- **PostgreSQL + pgAdmin4**  
- SQL (DDL & DML) → staging + final schema design  
- Built Tableau-ready views (staging + final tables → `ilo.master_country_year`, `ilo_views_tableau.sql`)  

### 📈 Visualization
- **Tableau** → interactive dashboards  
- Choropleth maps, bar charts, stacked bars, scatterplots, trendlines  
- Interactive features: filters, tooltips, time sliders  

### 🚀 Project Management
- **Git & GitHub** → version control, project organization  
- CSV / Excel → raw & cleaned datasets  
- Documentation (this README + dashboards folder)  

---

## 📊 Dashboards  

### 1️⃣ World GDP per Capita (2023 Snapshot)  
🔗 [View Dashboard](https://public.tableau.com/views/WorldGDPperCapita2023Snapshot/WorldGDPperCapita2023Snapshot?:language=en-GB&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)  
- Choropleth world map: GDP per capita by country  
- Top 10 richest vs poorest countries  
- Median GDP per capita reference line  

---

### 2️⃣ Global Workforce Overview (2023)  
🔗 [View Dashboard](https://public.tableau.com/views/GlobalWorkforceOverview2023/GlobalWorkforceOverview2023?:language=en-GB&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)  
- LFPR by region (labor force participation)  
- Employment by sector (Agriculture, Industry, Services)  
- Unemployment by region with world average benchmark  

---

### 3️⃣ Global Workforce Trends (2000–2023)  
🔗 [View Dashboard](https://public.tableau.com/views/GlobalWorkforceTrendsGDPLaborParticipationUnemployment20002023/GlobalWorkforceTrendsGDPLaborParticipationUnemployment20002023?:language=en-GB&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)  
- Trends for GDP per capita, LFPR, Unemployment (2000–2023)  
- Interactive time slider for exploring yearly data  
- Bubble scatterplot → GDP vs LFPR with unemployment as bubble size  

---

## 📂 Repository Structure

📁 data/              → cleaned datasets (CSV)
📁 sql/               → SQL scripts (staging, final, Tableau views)
📁 notebooks/         → Python preprocessing scripts (cleaning, tagging, transformations)
📁 dashboards/        → Tableau links (README.md) + packaged workbooks (optional)
README.md             → Project overview (this file)

---

✅ Key Insights

- 🌍 **Income inequality** is stark: GDP per capita varies by factors of 50–100x between the richest and poorest countries.  
- 👥 **Labor force participation differs strongly by region**: Sub-Saharan Africa shows some of the highest rates, while the Middle East & North Africa remain lower.  
- 🏭 **Employment structure** is shifting: the services sector dominates globally, but agriculture is still a key employer in low-income regions.  
- 📉 **Unemployment rates** cluster below 10% in most regions, though fragile/conflict economies and specific years (e.g., financial crisis, COVID-19) show clear spikes.  
- 📊 **Trends (2000–2023)** reveal steady GDP growth overall, but uneven labor market improvements across regions.  

## 📌 How to Use
1. Clone this repo:  
   ```bash
   git clone https://github.com/SauleRub/global-labor-compliance-dashboard.git

2.	Explore SQL scripts
	•	Inside /sql/ you’ll find staging and final schema scripts (ilo.master_country_year, ilo_views_tableau.sql).
	•	These define how raw data was cleaned, merged, and prepared for Tableau.

3.	Run Python preprocessing (optional)
	•	Inside /notebooks/ you’ll find Jupyter notebooks for cleaning, tagging, and transforming datasets before SQL staging.

4.	Open Tableau Dashboards
Dashboards are in /dashboards/ and published on Tableau Public:
    •	🌍 World GDP per Capita (2023 Snapshot)
  	•	👥 Global Workforce Overview (2023)
  	•	📈 Global Workforce Trends (2000–2023)

⸻

🔮 Next Steps (Future Improvements)
	•	⚡ Automate updates → set up Tableau Public extracts to refresh data regularly.
 
	•	🤖 Predictive modeling → use Python ML to forecast future LFPR & unemployment trends.
 
	•	🗺 Regional deep dives → build additional dashboards focusing on specific continents.
 
	•	📈 Comparative policy analysis → integrate governance or education indicators for broader insights.
