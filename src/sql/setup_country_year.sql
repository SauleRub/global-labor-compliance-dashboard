-- setup_country_year.sql
-- Rebuilds staging + final tables, loads CSV, adds constraints/indexes, and creates views.

-- 0) Safety: keep everything atomic
BEGIN;

-- 1) Schemas
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS ilo;

-- 2) Staging table (drop & recreate)
DROP TABLE IF EXISTS staging.master_country_year;
CREATE TABLE staging.master_country_year (
  iso3 text,
  country text,
  year int,
  gdp_per_capita_usd numeric,
  gdp_per_worker_ppp_const numeric,
  lfpr_total_pct numeric,
  unemp_total_pct numeric,
  emp_agriculture_pct numeric,
  emp_industry_pct numeric,
  emp_services_pct numeric,
  labor_force_thousands numeric,
  unemployed_thousands numeric
);

-- 3) Load from CSV (edit the path!)
COPY staging.master_country_year
FROM '/Users/saulerub/Documents/global-labor-compliance-dashboard/data/processed/master_country_year_clean.csv'
WITH (FORMAT csv, HEADER true, NULL '', DELIMITER ',', QUOTE '"');

-- 4) Final table (idempotent)
DROP TABLE IF EXISTS ilo.master_country_year;
CREATE TABLE ilo.master_country_year (LIKE staging.master_country_year);

-- Primary key + helpful indexes
ALTER TABLE ilo.master_country_year
  ADD CONSTRAINT pk_master_country_year PRIMARY KEY (iso3, year);
CREATE INDEX IF NOT EXISTS ix_master_country_year__year ON ilo.master_country_year (year);
CREATE INDEX IF NOT EXISTS ix_master_country_year__iso3 ON ilo.master_country_year (iso3);

-- Percent-range checks (keeps future loads clean)
DO $$
DECLARE c text;
BEGIN
  FOREACH c IN ARRAY ARRAY[
    'lfpr_total_pct','unemp_total_pct','emp_agriculture_pct','emp_industry_pct','emp_services_pct'
  ]
  LOOP
    EXECUTE format(
      'ALTER TABLE ilo.master_country_year
         ADD CONSTRAINT chk_%I_range
         CHECK (%I IS NULL OR (%I >= -0.1 AND %I <= 100.1))',
      c, c, c, c
    );
  END LOOP;
END$$;

-- 5) Publish from staging
INSERT INTO ilo.master_country_year
SELECT * FROM staging.master_country_year;

-- 6) Convenience view: latest year per country
CREATE OR REPLACE VIEW ilo.v_country_latest AS
SELECT m.*
FROM ilo.master_country_year m
JOIN (
  SELECT iso3, MAX(year) AS latest_year
  FROM ilo.master_country_year
  GROUP BY iso3
) last USING (iso3, year);

-- 7) Planner stats
ANALYZE ilo.master_country_year;

COMMIT;

-- ---- Optional quick checks (run as needed)
-- SELECT COUNT(*) rows, MIN(year) min_year, MAX(year) max_year, COUNT(DISTINCT iso3) countries
-- FROM ilo.master_country_year;
-- SELECT iso3, year, COUNT(*) n FROM ilo.master_country_year GROUP BY 1,2 HAVING COUNT(*)>1;