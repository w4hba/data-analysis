-- Online Shoppers — load the CSV and clean into the typed `sessions` table.
-- Run from the repo root with:  mysql --defaults-extra-file=db.local.cnf --local-infile=1 < ...
--
-- Cleaning done here: cast the TRUE/FALSE text columns to 0/1, and normalize Month
-- (the file mixes 3-letter codes with a spelled-out "June", and has no Jan or Apr)
-- into a numeric month for ordering. The 125 exact-duplicate rows are KEPT on
-- purpose: rows are anonymized session feature-vectors, so identical rows are
-- plausibly distinct bounce sessions, and dropping them would undercount bounces.

TRUNCATE TABLE sessions_stg;

LOAD DATA LOCAL INFILE 'shopper-conversion-funnel/data/raw/online_shoppers_intention.csv'
INTO TABLE sessions_stg
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES
(administrative, administrative_duration, informational, informational_duration,
 product_related, product_related_duration, bounce_rate, exit_rate, page_values,
 special_day, month_txt, operating_system, browser, region, traffic_type,
 visitor_type, weekend_txt, @revenue)
SET revenue_txt = TRIM(TRAILING '\r' FROM @revenue);

TRUNCATE TABLE sessions;

INSERT INTO sessions
  (administrative, administrative_duration, informational, informational_duration,
   product_related, product_related_duration, bounce_rate, exit_rate, page_values,
   special_day, month_txt, month_num, operating_system, browser, region,
   traffic_type, visitor_type, weekend, revenue)
SELECT
  administrative, administrative_duration, informational, informational_duration,
  product_related, product_related_duration, bounce_rate, exit_rate, page_values,
  special_day,
  month_txt,
  CASE month_txt                       -- normalize incl. the spelled-out "June"
    WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3  WHEN 'May' THEN 5  WHEN 'June' THEN 6
    WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9  WHEN 'Oct' THEN 10
    WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12 END,
  operating_system, browser, region, traffic_type, visitor_type,
  (weekend_txt = 'TRUE'),
  (revenue_txt = 'TRUE')
FROM sessions_stg;

-- Summary: class balance and the headline PageValues split.
SELECT 'sessions loaded'          AS metric, COUNT(*) AS value FROM sessions
UNION ALL SELECT 'converted (revenue=1)',        SUM(revenue) FROM sessions
UNION ALL SELECT 'conversion rate %',            ROUND(100*AVG(revenue),2) FROM sessions
UNION ALL SELECT 'exact-duplicate rows (kept)',  COUNT(*)-COUNT(DISTINCT administrative,administrative_duration,informational,informational_duration,product_related,product_related_duration,bounce_rate,exit_rate,page_values,special_day,month_txt,operating_system,browser,region,traffic_type,visitor_type,weekend,revenue) FROM sessions
UNION ALL SELECT 'sessions with PageValues=0',   SUM(page_values=0) FROM sessions
UNION ALL SELECT 'unmapped month_num (should be 0)', SUM(month_num IS NULL) FROM sessions;
