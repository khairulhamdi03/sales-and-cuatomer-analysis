#best-selling products by number of sales
SELECT
  DISTINCT product_id,
  SUM(quantity) AS total_number_of_sales
FROM
  `project-431507.revou_project.transaction`
GROUP BY product_id
ORDER BY total_number_of_sales DESC
LIMIT 5;

#best-selling products by total_revenue
SELECT
  DISTINCT product_id,
  SUM(product_price*quantity) AS total_revenue
FROM
  `project-431507.revou_project.transaction`
GROUP BY product_id
ORDER BY total_revenue
LIMIT 5;

#number of sales per month
SELECT 
  DISTINCT (FORMAT_TIMESTAMP('%B', TIMESTAMP(created_at))) AS month,
  SUM(quantity) AS total_number_of_sales
FROM 
  `project-431507.revou_project.transaction` 
GROUP BY month
ORDER BY
  CASE month
      WHEN 'May' THEN 1
      WHEN 'June' THEN 2
      WHEN 'July' THEN 3
      WHEN 'August' THEN 4
      WHEN 'September' THEN 5
      WHEN 'October' THEN 6
      WHEN 'November' THEN 7
      WHEN 'December' THEN 8
  END;

#total revenue per month
  SELECT 
  DISTINCT (FORMAT_TIMESTAMP('%B', TIMESTAMP(created_at))) AS month,
  SUM(product_price*quantity) AS total_revenue
FROM 
  `project-431507.revou_project.transaction` 
GROUP BY month
ORDER BY
  CASE month
      WHEN 'May' THEN 1
      WHEN 'June' THEN 2
      WHEN 'July' THEN 3
      WHEN 'August' THEN 4
      WHEN 'September' THEN 5
      WHEN 'October' THEN 6
      WHEN 'November' THEN 7
      WHEN 'December' THEN 8
  END;

#customer distribution by gender
WITH gender AS (SELECT
  DISTINCT customer_gender,
  COUNT(
    CASE 
      WHEN customer_gender = 'Male'THEN customer_gender
      WHEN customer_gender = 'Female'THEN customer_gender END)AS total
FROM
  (SELECT
      DISTINCT customer_id,
      customer_gender
  FROM
  `project-431507.revou_project.transaction`)
GROUP BY customer_gender)

SELECT
  customer_gender,
  total,
  ROUND((total/16096)*100,2)AS gender_percentage
FROM
  gender
GROUP BY 1,2;

#customer distribution by city
WITH city AS (
  SELECT
    DISTINCT customer_id,
    customer_city,
  FROM
    `project-431507.revou_project.transaction`)

SELECT
  customer_city,
  COUNT(customer_city) AS total
FROM
  city
GROUP BY 1
ORDER By 2 DESC;

#sales comparison of online stores vs offline stores
WITH data1  AS (SELECT
  store,
  COUNT(transaction_id) AS total_transaction
FROM
  `project-431507.revou_project.transaction`
GROUP BY 1)

SELECT 
  store,
  total_transaction,
  ROUND((total_transaction/48573)*100,2) AS percentage 
FROM 
  data1 
GROUP BY 1,2;

#customer analysis uses RFM analysis
WITH customer_data AS(
SELECT
  DISTINCT customer_id,
  MAX(created_at) AS last_transaction,
  COUNT(transaction_id) AS total_transaction,
  SUM(total) AS total
FROM
  `project-431507.revou_project.transaction`
GROUP BY 1),

rfm_analysis AS(
SELECT
  customer_id,
  last_transaction,
  total_transaction,
  total,
  NTILE(3)OVER(ORDER BY last_transaction DESC) AS recency_score,
  NTILE(3)OVER(ORDER BY total_transaction DESC) AS frequency_score,
  NTILE(3)OVER(ORDER BY total DESC) AS monetary_score
FROM
  customer_data
)

SELECT
  customer_id,
  recency_score,
  frequency_score,
  monetary_score,
  CONCAT(recency_score,frequency_score,monetary_score) AS rfm_score,
  CASE
    WHEN recency_score = 3 AND frequency_score = 3 AND monetary_score = 3 THEN "Champion"
    WHEN recency_score = 3 AND frequency_score = 3 AND monetary_score = 2 THEN "Loyal Csutomer"
    WHEN recency_score = 3 AND frequency_score = 3 AND monetary_score = 1 THEN "Recent Customer"
    WHEN recency_score = 3 AND frequency_score = 2 AND monetary_score = 3 THEN "Potential Loyalist"
    WHEN recency_score = 3 AND frequency_score = 2 AND monetary_score = 2 THEN "Recent Customer"
    WHEN recency_score = 3 AND frequency_score = 2 AND monetary_score = 1 THEN "Recent Customer"
    WHEN recency_score = 3 AND frequency_score = 1 AND monetary_score = 3 THEN "Recent Customer"
    WHEN recency_score = 3 AND frequency_score = 1 AND monetary_score = 2 THEN "Recent Customer"
    WHEN recency_score = 3 AND frequency_score = 1 AND monetary_score = 1 THEN "Recent Customer"
    WHEN recency_score = 2 AND frequency_score = 3 AND monetary_score = 3 THEN "Promising"
    WHEN recency_score = 2 AND frequency_score = 3 AND monetary_score = 2 THEN "Customers Needing Attention"
    WHEN recency_score = 2 AND frequency_score = 3 AND monetary_score = 1 THEN "Customers Needing Attention"
    WHEN recency_score = 2 AND frequency_score = 2 AND monetary_score = 3 THEN "Customers Needing Attention"
    WHEN recency_score = 2 AND frequency_score = 2 AND monetary_score = 2 THEN "About to Sleep"
    WHEN recency_score = 2 AND frequency_score = 2 AND monetary_score = 1 THEN "At Risk"
    WHEN recency_score = 2 AND frequency_score = 1 AND monetary_score = 3 THEN "At Risk"
    WHEN recency_score = 2 AND frequency_score = 1 AND monetary_score = 2 THEN "Can't Lose Them"
    WHEN recency_score = 2 AND frequency_score = 1 AND monetary_score = 1 THEN "Can't Lose Them"
    WHEN recency_score = 1 AND frequency_score = 3 AND monetary_score = 3 THEN "Promising"
    WHEN recency_score = 1 AND frequency_score = 3 AND monetary_score = 2 THEN "Hibernating"
    WHEN recency_score = 1 AND frequency_score = 3 AND monetary_score = 1 THEN "Hibernating"
    WHEN recency_score = 1 AND frequency_score = 2 AND monetary_score = 3 THEN "Hibernating"
    WHEN recency_score = 1 AND frequency_score = 2 AND monetary_score = 2 THEN "Hibernating"
    WHEN recency_score = 1 AND frequency_score = 2 AND monetary_score = 1 THEN "Hibernating"
    WHEN recency_score = 1 AND frequency_score = 1 AND monetary_score = 3 THEN "Hibernating"
    WHEN recency_score = 1 AND frequency_score = 1 AND monetary_score = 2 THEN "Hibernating"
    WHEN recency_score = 1 AND frequency_score = 1 AND monetary_score = 1 THEN "Lost"
    END AS customer_segmentation
FROM
  rfm_analysis;


