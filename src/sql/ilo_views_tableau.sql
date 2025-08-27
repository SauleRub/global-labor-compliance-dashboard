-- src/sql/ilo_views.sql
-- Purpose: Tableau-ready views from ilo.master_country_year
-- Inputs: ilo.master_country_year (columns in snake_case, includes boolean is_group)
-- Safe to re-run: uses CREATE OR REPLACE VIEW

-- 1) Full history (tidy)
CREATE OR REPLACE VIEW ilo.v_tableau_country_year AS
SELECT
  iso3,
  country,
  is_group,                 -- TRUE = region/aggregate, FALSE = country
  year,
  gdp_per_capita_usd,
  gdp_per_worker_ppp_const,
  school_enroll_tertiary_pct,
  emp_agriculture_pct,
  emp_industry_pct,
  emp_services_pct,
  lfpr_total_pct,
  unemp_total_pct,
  labor_force_thousands,
  unemployed_thousands
FROM ilo.master_country_year;

-- 2) Latest year per entity (country or region)
CREATE OR REPLACE VIEW ilo.v_tableau_latest AS
SELECT m.*
FROM ilo.master_country_year m
JOIN (
  SELECT iso3, MAX(year) AS latest_year
  FROM ilo.master_country_year
  GROUP BY iso3
) y
  ON m.iso3 = y.iso3 AND m.year = y.latest_year;

-- Optional splits (handy in Tableau)
CREATE OR REPLACE VIEW ilo.v_tableau_latest_countries AS
SELECT * FROM ilo.v_tableau_latest WHERE is_group = FALSE;

CREATE OR REPLACE VIEW ilo.v_tableau_latest_regions AS
SELECT * FROM ilo.v_tableau_latest WHERE is_group = TRUE;

-- 3) Sector shares in tidy form (for stacked bars)
CREATE OR REPLACE VIEW ilo.v_tableau_sector_shares AS
SELECT iso3, country, is_group, year, 'agriculture'::text AS sector, emp_agriculture_pct AS pct
FROM ilo.master_country_year
UNION ALL
SELECT iso3, country, is_group, year, 'industry'::text,  emp_industry_pct
FROM ilo.master_country_year
UNION ALL
SELECT iso3, country, is_group, year, 'services'::text,  emp_services_pct
FROM ilo.master_country_year;

-- 4) Missingness summary (QC)
CREATE OR REPLACE VIEW ilo.v_tableau_missing_summary AS
WITH cols AS (
  SELECT UNNEST(ARRAY[
    'gdp_per_capita_usd',
    'gdp_per_worker_ppp_const',
    'school_enroll_tertiary_pct',
    'emp_agriculture_pct',
    'emp_industry_pct',
    'emp_services_pct',
    'lfpr_total_pct',
    'unemp_total_pct',
    'labor_force_thousands',
    'unemployed_thousands'
  ]) AS col
),
m AS (
  SELECT
    SUM( (gdp_per_capita_usd          IS NULL)::int ) AS gdp_per_capita_usd,
    SUM( (gdp_per_worker_ppp_const    IS NULL)::int ) AS gdp_per_worker_ppp_const,
    SUM( (school_enroll_tertiary_pct  IS NULL)::int ) AS school_enroll_tertiary_pct,
    SUM( (emp_agriculture_pct         IS NULL)::int ) AS emp_agriculture_pct,
    SUM( (emp_industry_pct            IS NULL)::int ) AS emp_industry_pct,
    SUM( (emp_services_pct            IS NULL)::int ) AS emp_services_pct,
    SUM( (lfpr_total_pct              IS NULL)::int ) AS lfpr_total_pct,
    SUM( (unemp_total_pct             IS NULL)::int ) AS unemp_total_pct,
    SUM( (labor_force_thousands       IS NULL)::int ) AS labor_force_thousands,
    SUM( (unemployed_thousands        IS NULL)::int ) AS unemployed_thousands
  FROM ilo.master_country_year
)
SELECT
  c.col,
  CASE c.col
    WHEN 'gdp_per_capita_usd'         THEN m.gdp_per_capita_usd
    WHEN 'gdp_per_worker_ppp_const'   THEN m.gdp_per_worker_ppp_const
    WHEN 'school_enroll_tertiary_pct' THEN m.school_enroll_tertiary_pct
    WHEN 'emp_agriculture_pct'        THEN m.emp_agriculture_pct
    WHEN 'emp_industry_pct'           THEN m.emp_industry_pct
    WHEN 'emp_services_pct'           THEN m.emp_services_pct
    WHEN 'lfpr_total_pct'             THEN m.lfpr_total_pct
    WHEN 'unemp_total_pct'            THEN m.unemp_total_pct
    WHEN 'labor_force_thousands'      THEN m.labor_force_thousands
    WHEN 'unemployed_thousands'       THEN m.unemployed_thousands
  END AS n_missing
FROM cols c CROSS JOIN m
ORDER BY c.col;

-- Quick checks (run ad-hoc in pgAdmin if you want)
-- SELECT COUNT(*) FROM ilo.v_tableau_country_year;
-- SELECT is_group, COUNT(*) FROM ilo.v_tableau_latest GROUP BY is_group ORDER BY is_group;