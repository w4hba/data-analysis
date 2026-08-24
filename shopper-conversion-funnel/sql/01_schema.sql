-- Online Shoppers Purchasing Intention — schema.
-- MySQL 8.0 syntax (verified on 9.7.1). Two tables:
--   sessions_stg  raw rows as the CSV presents them (booleans and Month as text)
--   sessions      the clean, typed analysis base, built by 02_load_and_clean.sql
--
-- Each row is one browsing session (not one user, and not an event stream), so the
-- funnel in 03 is engineered from session-level page counts, not traced per user.

DROP TABLE IF EXISTS sessions_stg;
CREATE TABLE sessions_stg (
  administrative           INT,
  administrative_duration  DOUBLE,
  informational            INT,
  informational_duration   DOUBLE,
  product_related          INT,
  product_related_duration DOUBLE,
  bounce_rate              DOUBLE,
  exit_rate                DOUBLE,
  page_values              DOUBLE,
  special_day              DOUBLE,
  month_txt                VARCHAR(10),   -- 3-letter codes plus one "June"
  operating_system         INT,
  browser                  INT,
  region                   INT,
  traffic_type             INT,
  visitor_type             VARCHAR(20),
  weekend_txt              VARCHAR(5),    -- 'TRUE' / 'FALSE'
  revenue_txt              VARCHAR(5)     -- 'TRUE' / 'FALSE'  (target)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS sessions;
CREATE TABLE sessions (
  id                       BIGINT AUTO_INCREMENT PRIMARY KEY,
  administrative           INT,
  administrative_duration  DOUBLE,
  informational            INT,
  informational_duration   DOUBLE,
  product_related          INT,
  product_related_duration DOUBLE,
  bounce_rate              DOUBLE,
  exit_rate                DOUBLE,
  page_values              DOUBLE,
  special_day              DOUBLE,
  month_txt                VARCHAR(10),
  month_num                TINYINT,       -- normalized from month_txt in 02
  operating_system         INT,
  browser                  INT,
  region                   INT,
  traffic_type             INT,
  visitor_type             VARCHAR(20),
  weekend                  TINYINT,       -- 0/1
  revenue                  TINYINT,       -- 0/1 (converted)
  KEY idx_revenue (revenue),
  KEY idx_visitor (visitor_type),
  KEY idx_traffic (traffic_type),
  KEY idx_pagevalues (page_values)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
