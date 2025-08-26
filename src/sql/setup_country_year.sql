-- =====================================================
-- 1) Recreate STAGING table fresh + load CSV
-- =====================================================

DROP TABLE IF EXISTS staging.master_country_year;

CREATE TABLE staging.master_country_year (
    iso3 text,
    year int,
    country text,
    gdp_per_capita_usd numeric,
    school_enroll_tertiary_pct numeric,
    emp_agriculture_pct numeric,
    gdp_per_worker_ppp_const numeric,
    emp_industry_pct numeric,
    emp_services_pct numeric,
    lfpr_total_pct numeric,
    unemp_total_pct numeric,
    labor_force_thousands numeric,
    unemployed_thousands numeric,
    is_group boolean
);

COPY staging.master_country_year (
    iso3, year, country,
    gdp_per_capita_usd, school_enroll_tertiary_pct,
    emp_agriculture_pct, gdp_per_worker_ppp_const,
    emp_industry_pct, emp_services_pct,
    lfpr_total_pct, unemp_total_pct,
    labor_force_thousands, unemployed_thousands,
    is_group
)
FROM '/Users/saulerub/Documents/global-labor-compliance-dashboard/data/processed/master_country_year_clean.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');


-- =====================================================
-- 2) Ensure FINAL table exists (idempotent)
-- =====================================================

CREATE SCHEMA IF NOT EXISTS ilo;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'ilo'
          AND c.relname = 'master_country_year'
          AND c.relkind = 'r'
    ) THEN
        EXECUTE $ddl$
            CREATE TABLE ilo.master_country_year (
                LIKE staging.master_country_year
            );
        $ddl$;

        EXECUTE 'ALTER TABLE ilo.master_country_year
                 ADD CONSTRAINT pk_master_country_year PRIMARY KEY (iso3, year)';

        EXECUTE 'CREATE INDEX IF NOT EXISTS ix_master_country_year__year
                 ON ilo.master_country_year(year)';

        EXECUTE 'CREATE INDEX IF NOT EXISTS ix_master_country_year__iso3
                 ON ilo.master_country_year(iso3)';
    END IF;
END $$;


-- =====================================================
-- 3) Refresh FINAL table with new data
-- =====================================================

TRUNCATE TABLE ilo.master_country_year;

INSERT INTO ilo.master_country_year
SELECT * FROM staging.master_country_year;


-- =====================================================
-- 4) Recreate dependent VIEWS
-- =====================================================

-- Latest year per country (includes is_group)
CREATE OR REPLACE VIEW ilo.v_country_latest AS
SELECT m.*
FROM ilo.master_country_year m
JOIN (
    SELECT iso3, MAX(year) AS year
    FROM ilo.master_country_year
    GROUP BY iso3
) x USING (iso3, year);

-- Sector share tidy
CREATE OR REPLACE VIEW ilo.v_sector_shares_tidy AS
SELECT iso3, country, year, 'agriculture' AS sector, emp_agriculture_pct AS pct
FROM ilo.master_country_year
UNION ALL
SELECT iso3, country, year, 'industry' AS sector, emp_industry_pct
FROM ilo.master_country_year
UNION ALL
SELECT iso3, country, year, 'services' AS sector, emp_services_pct
FROM ilo.master_country_year;

-- Missingness summary
CREATE OR REPLACE VIEW ilo.v_missing_summary AS
WITH cols AS (
    SELECT unnest(ARRAY[
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
)
SELECT c.col,
       COUNT(*) FILTER (
           WHERE
             CASE c.col
               WHEN 'gdp_per_capita_usd' THEN m.gdp_per_capita_usd
               WHEN 'gdp_per_worker_ppp_const' THEN m.gdp_per_worker_ppp_const
               WHEN 'school_enroll_tertiary_pct' THEN m.school_enroll_tertiary_pct
               WHEN 'emp_agriculture_pct' THEN m.emp_agriculture_pct
               WHEN 'emp_industry_pct' THEN m.emp_industry_pct
               WHEN 'emp_services_pct' THEN m.emp_services_pct
               WHEN 'lfpr_total_pct' THEN m.lfpr_total_pct
               WHEN 'unemp_total_pct' THEN m.unemp_total_pct
               WHEN 'labor_force_thousands' THEN m.labor_force_thousands
               WHEN 'unemployed_thousands' THEN m.unemployed_thousands
             END IS NULL
       ) AS n_missing
FROM cols c CROSS JOIN ilo.master_country_year m
GROUP BY c.col
ORDER BY c.col;


-- =====================================================
-- 5) Quick sanity checks
-- =====================================================

-- Counts by group/country
SELECT is_group, COUNT(*)
FROM ilo.master_country_year
GROUP BY is_group
ORDER BY is_group;

-- Counts by group in latest view
SELECT is_group, COUNT(*)
FROM ilo.v_country_latest
GROUP BY is_group
ORDER BY is_group;

-- Peek a few region rows
SELECT iso3, country, year
FROM ilo.v_country_latest
WHERE is_group = true
ORDER BY iso3
LIMIT 20;