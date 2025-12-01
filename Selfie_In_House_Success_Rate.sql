WITH months_list AS (
  SELECT FORMAT_DATE('%Y-%m', d) AS month
  FROM UNNEST(
    GENERATE_DATE_ARRAY(DATE_SUB(CURRENT_DATE(), INTERVAL 4 MONTH), CURRENT_DATE(), INTERVAL 1 MONTH)
  ) AS d
),
categories AS (
  SELECT 'IN_House_Success' AS category
  UNION ALL
  SELECT 'IN_House_Not_Success' AS category
),
month_category AS (
  SELECT m.month, c.category
  FROM months_list m
  CROSS JOIN categories c
),
in_house_success AS (
  SELECT
    FORMAT_DATE('%Y-%m', DATE(date_created)) AS month,
    'IN_House_Success' AS category,
    COUNT(DISTINCT loan_app_id_ref) AS cnt
  FROM `mv-dw-wi.lending.inhouse_face_match`
  WHERE DATE(date_created) >= DATE_SUB(CURRENT_DATE(), INTERVAL 4 MONTH)
    AND is_match = 'yes'
  GROUP BY month
),
in_house_not_success AS (
  SELECT
    FORMAT_DATE('%Y-%m', DATE(date_created)) AS month,
    'IN_House_Not_Success' AS category,
    COUNT(DISTINCT loan_app_id_ref) AS cnt
  FROM `mv-dw-wi.lending.inhouse_face_match`
  WHERE DATE(date_created) >= DATE_SUB(CURRENT_DATE(), INTERVAL 4 MONTH)
    AND is_match='no'
  GROUP BY month
),
all_data AS (
  SELECT * FROM in_house_success
  UNION ALL
  SELECT * FROM in_house_not_success
),
full_data AS (
  SELECT 
    mc.month,
    mc.category,
    IFNULL(a.cnt, 0) AS cnt
  FROM month_category mc
  LEFT JOIN all_data a
    ON mc.month = a.month AND mc.category = a.category
),
total_per_month AS (
  SELECT month, SUM(cnt) AS total_cnt
  FROM full_data
  GROUP BY month
)
SELECT
  f.month,
  f.category,
  f.cnt,
  SAFE_DIVIDE(f.cnt, t.total_cnt) * 100 AS distribution_percentage
FROM full_data f
JOIN total_per_month t
  ON f.month = t.month
ORDER BY f.month, f.category;
