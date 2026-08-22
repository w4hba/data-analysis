-- Online Retail II — schema
-- MySQL 8.0 syntax (verified on 9.7.1). Two tables:
--   stg_retail    raw line items loaded verbatim from the CSV (see data/load_to_mysql.py)
--   retail_clean  the analysis base, built from staging by 02_load_and_clean.sql
-- Loading is done in Python because this server has local_infile OFF and the
-- analyst user lacks the global privilege to enable it. All cleaning stays in SQL.

-- Staging mirrors the CSV exactly: no keys, no constraints, duplicates and junk intact.
DROP TABLE IF EXISTS stg_retail;
CREATE TABLE stg_retail (
  invoice       VARCHAR(12),
  stock_code    VARCHAR(20),
  description   VARCHAR(255),
  quantity      INT,
  invoice_date  DATETIME,
  price         DECIMAL(10,2),
  customer_id   INT,
  country       VARCHAR(60)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Analysis base. line_revenue and invoice_month are generated so every query
-- shares one definition of "revenue" and "cohort month" rather than re-deriving them.
DROP TABLE IF EXISTS retail_clean;
CREATE TABLE retail_clean (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  invoice       VARCHAR(12)   NOT NULL,
  stock_code    VARCHAR(20)   NOT NULL,
  description   VARCHAR(255),
  quantity      INT           NOT NULL,
  unit_price    DECIMAL(10,2) NOT NULL,
  invoice_ts    DATETIME      NOT NULL,
  customer_id   INT           NULL,          -- null = guest/unlinked sale; kept for revenue, dropped for cohorts
  country       VARCHAR(60)   NOT NULL,
  line_revenue  DECIMAL(12,2) AS (quantity * unit_price) STORED,
  invoice_month DATE          AS (invoice_ts - INTERVAL (DAYOFMONTH(invoice_ts) - 1) DAY) STORED,
  KEY idx_customer (customer_id),
  KEY idx_ts (invoice_ts),
  KEY idx_invoice (invoice),
  KEY idx_month (invoice_month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
