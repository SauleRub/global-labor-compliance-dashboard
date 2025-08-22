-- =========================================================
-- ILO unemployment – sanity checks
-- Targets the canonical table: ilo.unemployment_clean
-- and the convenience views created in ilo_views.sql
-- =========================================================

-- 1) No NULLs in keys
SELECT COUNT(*) AS null_keys
FROM ilo.unemployment_clean
WHERE country IS NULL OR year IS NULL OR sex IS NULL OR age_group IS NULL;

-- 2) Numeric sanity: no negatives
SELECT
  COUNT(*) FILTER (WHERE labour_force_thousands < 0) AS neg_lf,
  COUNT(*) FILTER (WHERE unemployed_thousands   < 0) AS neg_unemp,
  COUNT(*) FILTER (WHERE unemployment_rate      < 0) AS neg_rate
FROM ilo.unemployment_clean;

-- 3) Re-compute unemployment rate and compare to stored (tolerance in pct points)
WITH params AS (
  SELECT 0.01::numeric AS tol_pct   -- 0.01 percentage points
),
calc AS (
  SELECT
    country, year, sex, age_group,
    labour_force_thousands, unemployed_thousands,
    unemployment_rate AS rate_stored,
    CASE WHEN labour_force_thousands = 0 THEN NULL
         ELSE (unemployed_thousands / labour_force_thousands) * 100
    END AS rate_calc
  FROM ilo.unemployment_clean
),
diffs AS (
  SELECT
    c.*,
    (c.rate_calc - c.rate_stored) AS diff_pp,
    ABS(c.rate_calc - c.rate_stored) AS abs_diff_pp
  FROM calc c
)
SELECT
  COUNT(*)                          AS rows_checked,
  COUNT(*) FILTER (WHERE rate_calc IS NULL) AS rows_null_calc,
  COUNT(*) FILTER (WHERE abs_diff_pp > (SELECT tol_pct FROM params)) AS rows_over_tolerance,
  MIN(abs_diff_pp)                  AS min_abs_diff_pp,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY abs_diff_pp) AS p50_abs_diff_pp,
  MAX(abs_diff_pp)                  AS max_abs_diff_pp
FROM diffs;

-- Which rows had LF = 0 (so rate_calc is NULL)?
SELECT country, year, sex, age_group, labour_force_thousands, unemployed_thousands
FROM ilo.unemployment_clean
WHERE labour_force_thousands = 0
ORDER BY country, year, sex, age_group;

-- Any accidental NaNs in the stored rate?
SELECT
  COUNT(*) FILTER (WHERE unemployment_rate IS NULL)  AS null_rate,
  COUNT(*) FILTER (WHERE unemployment_rate = 'NaN'::text::numeric) AS nan_rate
FROM ilo.unemployment_clean;

-- 4) Internal consistency: band sums ≈ headline (show diffs)
--    A) unrestricted (all coverage)
WITH bands AS (
  SELECT
    s.country,
    s.year,
    SUM(CASE WHEN band <> '15+' THEN unemployed_thousands   ELSE 0 END) AS band_unemp,
    SUM(CASE WHEN band <> '15+' THEN labour_force_thousands ELSE 0 END) AS band_lf
  FROM ilo.v_unemployment_summary s
  GROUP BY s.country, s.year
),
heads AS (
  SELECT country, year,
         unemployed_thousands   AS head_unemp,
         labour_force_thousands AS head_lf
  FROM ilo.v_unemployment_headline
),
cmp AS (
  SELECT
    b.country, b.year,
    (b.band_unemp - h.head_unemp) AS diff_unemp,
    (b.band_lf    - h.head_lf)    AS diff_lf
  FROM bands b
  JOIN heads h
    ON h.country = b.country AND h.year = b.year
)
SELECT *
FROM cmp
WHERE ABS(diff_unemp) > 0.5 OR ABS(diff_lf) > 0.5  -- tolerance in “thousands”
ORDER BY country, year;

--    B) stricter: only country-years with full 6-band coverage
WITH r AS (
  SELECT country, year, bands_present
  FROM ilo.v_unemployment_age10_rollup
),
h AS (
  SELECT * FROM ilo.v_unemployment_headline
),
b AS (
  SELECT
    s.country, s.year,
    SUM(CASE WHEN band <> '15+' THEN unemployed_thousands   ELSE 0 END) AS sum_age_unemployed,
    SUM(CASE WHEN band <> '15+' THEN labour_force_thousands ELSE 0 END) AS sum_age_labour_force
  FROM ilo.v_unemployment_summary s
  GROUP BY s.country, s.year
),
cmp AS (
  SELECT
    h.country, h.year,
    b.sum_age_unemployed - h.unemployed_thousands   AS diff_unemp,
    b.sum_age_labour_force - h.labour_force_thousands AS diff_lf
  FROM h
  JOIN b ON b.country = h.country AND b.year = h.year
  JOIN r ON r.country = h.country AND r.year = h.year
  WHERE r.bands_present = 6
)
SELECT country, year,
       ROUND(diff_unemp, 3) AS diff_unemp,
       ROUND(diff_lf, 3)    AS diff_lf
FROM cmp
WHERE ABS(diff_unemp) > 0.5 OR ABS(diff_lf) > 0.5
ORDER BY country, year;

-- 5) Summary view uniqueness (no duplicate country–year–band)
SELECT country, year, band, COUNT(*) AS cnt
FROM ilo.v_unemployment_summary
GROUP BY 1,2,3
HAVING COUNT(*) > 1;