🌍 Global Workforce & Economic Trends (2000–2023)

📌 Project Overview

This project explores the intersection of economic development and labor markets across more than 180 countries from 2000–2023, using data from the International Labour Organization (ILO) and World Bank.

The analysis focuses on:
	•	GDP per capita disparities across countries and regions
	•	Labor Force Participation Rate (LFPR)
	•	Employment structure by sector (Agriculture, Industry, Services)
	•	Unemployment rates and global/regional benchmarks
	•	Trends over time and cross-regional comparisons

The results are presented in a series of interactive Tableau dashboards designed to support companies, policymakers, and researchers in understanding labor force dynamics and economic inequalities.

⸻

🔧 Tech Stack

📊 Data Collection & Processing
	•	Python (Pandas, NumPy) → cleaning, reshaping, filtering datasets
	•	Regex & String handling → standardizing country names (snake_case, removing regions from country lists)
	•	Custom Python scripts → tagging countries vs regions, creating calculated fields (LFPR corrected, unemployment %)

🗄️ Database & Queries
	•	PostgreSQL + pgAdmin4 → staging + final schema design
	•	SQL (DDL & DML) →
	•	staging/final tables (staging.master_country_year, ilo.master_country_year)
	•	transformations (snake_case, dropping duplicates)
	•	views for Tableau (ilo_views_tableau.sql)

📉 Visualization
	•	Tableau → building interactive dashboards
	•	maps, bar charts, stacked bars, scatterplots, trendlines
	•	reference lines (world median, averages)
	•	tooltips customization

📂 Project Management
	•	Git & GitHub → version control, organizing SQL/Python/Tableau work
	•	CSV / Excel → raw + cleaned datasets, mapping files

⸻

📊 Dashboards

1️⃣ World GDP per Capita (2023 Snapshot)

👉 View Dashboard
	•	Choropleth world map: GDP per capita by country
	•	Top 10 richest vs poorest countries
	•	Median GDP per capita reference line

⸻

2️⃣ Global Workforce Overview (2023)

👉 View Dashboard
	•	LFPR by region (labor force participation rates)
	•	Employment by sector (Agriculture, Industry, Services)
	•	Unemployment by region with world average benchmark

⸻

3️⃣ Global Workforce Trends (2000–2023)

👉 View Dashboard
	•	Trends for GDP per capita, LFPR, Unemployment over 2000–2023
	•	Interactive time slider (Pages) for exploring yearly data
	•	Bubble scatterplot → relationship between GDP per capita & labor participation
	•	Regional and country-level comparisons

⸻

📂 Repository Structure

📁 data/              → raw & cleaned datasets (CSV)
📁 sql/               → SQL scripts (staging, final, Tableau views)
📁 notebooks/         → Python preprocessing scripts (cleaning, tagging, transformations)
📁 dashboards/        → Tableau links (README.md) + packaged workbooks (optional)
README.md             → Project overview (this file)

✅ Key Insights

- 🌍 **Income inequality** is stark: GDP per capita varies by factors of 50–100x between the richest and poorest countries.  
- 👥 **Labor force participation differs strongly by region**: Sub-Saharan Africa shows some of the highest rates, while the Middle East & North Africa remain lower.  
- 🏭 **Employment structure** is shifting: the services sector dominates globally, but agriculture is still a key employer in low-income regions.  
- 📉 **Unemployment rates** cluster below 10% in most regions, though fragile/conflict economies and specific years (e.g., financial crisis, COVID-19) show clear spikes.  
- 📊 **Trends (2000–2023)** reveal steady GDP growth overall, but uneven labor market improvements across regions.  

 🚀 How to Use
	1.	Clone this repo:
 git clone https://github.com/SauleRub/global-labor-compliance-dashboard.git
  2.	Explore SQL scripts inside /sql to see how staging & final tables were built.
	3.	Open Tableau dashboards (links above) for interactive exploration.

 ✨ This project demonstrates end-to-end workflow:
raw data → Python cleaning → SQL modeling → Tableau dashboards → GitHub documentation.

⸻

📌 Next Steps (Future Improvements):
	•	Add population data for richer bubble scaling
	•	Automate updates with Tableau Public extracts
	•	Explore predictive models (Python ML) for LFPR & unemployment
