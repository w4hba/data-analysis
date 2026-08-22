-- Online Retail II — clean staging into the analysis base.
-- Run after data/load_to_mysql.py has populated stg_retail.
--
-- If your server has local_infile enabled, the CSV can be loaded directly instead
-- of via Python:
--   SET GLOBAL local_infile = 1;   -- needs admin privilege
--   LOAD DATA LOCAL INFILE 'data/raw/online_retail_II.csv' INTO TABLE stg_retail
--     FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
--     LINES TERMINATED BY '\n' IGNORE 1 LINES
--     (invoice, stock_code, description, quantity, invoice_date, price, @cid, country)
--     SET customer_id = NULLIF(@cid, '\\N');

TRUNCATE TABLE retail_clean;

-- ROW_NUMBER (not SELECT DISTINCT) so the dedupe key is explicit and the first
-- occurrence is the one kept; DISTINCT would silently collapse on all columns.
INSERT INTO retail_clean
  (invoice, stock_code, description, quantity, unit_price, invoice_ts, customer_id, country)
WITH deduped AS (
  SELECT
    invoice,
    stock_code,
    description,
    quantity,
    price        AS unit_price,
    invoice_date AS invoice_ts,
    customer_id,
    country,
    ROW_NUMBER() OVER (
      PARTITION BY invoice, stock_code, quantity, price, customer_id
      ORDER BY invoice_date
    ) AS rn
  FROM stg_retail
  WHERE invoice NOT LIKE 'C%'        -- cancellations: counted as returns, not sales
    AND quantity > 0                 -- drop returns/adjustments
    AND price    > 0                 -- drop zero/negative-priced lines
    AND stock_code REGEXP '^[0-9]'   -- keep real products; service codes (POST, DOT, M,
)                                    -- BANK CHARGES, AMAZONFEE, ADJUST, ...) start with a letter
SELECT invoice, stock_code, description, quantity, unit_price, invoice_ts, customer_id, country
FROM deduped
WHERE rn = 1;

-- Cleaning summary: how many rows each rule removed, and what remains.
SELECT 'raw staging rows'            AS step, COUNT(*) AS rows_ FROM stg_retail
UNION ALL SELECT 'cancellations',          COUNT(*) FROM stg_retail WHERE invoice LIKE 'C%'
UNION ALL SELECT 'non-positive quantity',  COUNT(*) FROM stg_retail WHERE invoice NOT LIKE 'C%' AND quantity <= 0
UNION ALL SELECT 'non-positive price',     COUNT(*) FROM stg_retail WHERE invoice NOT LIKE 'C%' AND quantity > 0 AND price <= 0
UNION ALL SELECT 'non-product stockcode',  COUNT(*) FROM stg_retail WHERE invoice NOT LIKE 'C%' AND quantity > 0 AND price > 0 AND stock_code NOT REGEXP '^[0-9]'
UNION ALL SELECT 'clean rows kept',        COUNT(*) FROM retail_clean
UNION ALL SELECT '  of which null customer', COUNT(*) FROM retail_clean WHERE customer_id IS NULL;
