-- =========================================================
-- ILO unemployment convenience views
-- Schema: ilo
-- Creates:
--   - ilo.age_band_dim         (helper lookup for sort order)
--   - ilo.v_unemployment_headline   (country-year, Total 15+)
--   - ilo.v_unemployment_age10      (country-year, Total, 10-year bands)
--   - ilo.v_unemployment_age10_rollup (sum of bands per country-year)
--   - ilo.v_unemployment_summary    (headline + bands in one table)
-- =========================================================

-- 0) Helper: age-band ordering (idempotent)
CREATE TABLE IF NOT EXISTS ilo.age_band_dim (
  age_band text PRIMARY KEY,
  sort_key int NOT NULL
);

-- Upsert the expected bands (won’t duplicate if they already exist)
INSERT INTO ilo.age_band_dim (age_band, sort_key) VALUES
  ('15-24', 1), ('25-34', 2), ('35-44', 3),
  ('45-54', 4), ('55-64', 5), ('65+',  6),
  ('15+',   0)  -- so totals sort before bands when you want
ON CONFLICT (age_band) DO NOTHING;

-- 1) Headline: country-year, Total population 15+
DROP VIEW IF EXISTS ilo.v_unemployment_headline CASCADE;
CREATE VIEW ilo.v_unemployment_headline AS
SELECT
  country,
  year,
  labour_force_thousands,
  unemployed_thousands,
  unemployment_rate
FROM ilo.unemployment_clean
WHERE sex = 'Total' AND age_group = '15+';

-- 2) Age bands: country-year, Total, standard 10-year groups
DROP VIEW IF EXISTS ilo.v_unemployment_age10 CASCADE;
CREATE VIEW ilo.v_unemployment_age10 AS
SELECT
  c.country,
  c.year,
  c.age_group,
  d.sort_key,
  c.labour_force_thousands,
  c.unemployed_thousands,
  c.unemployment_rate
FROM ilo.unemployment_clean c
JOIN ilo.age_band_dim d
  ON d.age_band = c.age_group
WHERE c.sex = 'Total'
  AND c.age_group IN ('15-24','25-34','35-44','45-54','55-64','65+');

-- 3) Roll-up of age bands (useful for coverage checks)
DROP VIEW IF EXISTS ilo.v_unemployment_age10_rollup CASCADE;
CREATE VIEW ilo.v_unemployment_age10_rollup AS
SELECT
  country,
  year,
  SUM(unemployed_thousands)      AS sum_age_unemployed,
  SUM(labour_force_thousands)    AS sum_age_labour_force,
  COUNT(*)                       AS bands_present
FROM ilo.v_unemployment_age10
GROUP BY country, year;

-- 4) Summary = headline + bands in one tidy structure
DROP VIEW IF EXISTS ilo.v_unemployment_summary CASCADE;
CREATE VIEW ilo.v_unemployment_summary AS
-- headline (band = '15+')
SELECT
  h.country,
  h.year,
  '15+'::text                  AS band,
  (SELECT sort_key FROM ilo.age_band_dim WHERE age_band='15+') AS sort_key,
  h.labour_force_thousands,
  h.unemployed_thousands,
  h.unemployment_rate
FROM ilo.v_unemployment_headline h
UNION ALL
-- age bands
SELECT
  a.country,
  a.year,
  a.age_group                 AS band,
  a.sort_key,
  a.labour_force_thousands,
  a.unemployed_thousands,
  a.unemployment_rate
FROM ilo.v_unemployment_age10 a;