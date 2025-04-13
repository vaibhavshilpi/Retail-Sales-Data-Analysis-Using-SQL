-- Use Database
USE p1_retail_db;

-- Create Table
CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,    
    sale_time TIME,
    customer_id INT,    
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,    
    cogs FLOAT,
    total_sale FLOAT
);



-- Customer Behavior & Demographics

-- Percentage of total revenue from each age group
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '55+' 
    END AS age_group,
    ROUND(SUM(total_sale) * 100.0 / (SELECT SUM(total_sale) FROM retail_sales), 2) AS revenue_percentage
FROM retail_sales
GROUP BY age_group
ORDER BY revenue_percentage DESC;

-- Age group with highest average transaction value
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '55+' 
    END AS age_group,
    ROUND(AVG(total_sale), 2) AS avg_transaction_value
FROM retail_sales
GROUP BY age_group
ORDER BY avg_transaction_value DESC;

-- Seasonal & Time-Based Trends

-- Average total sale per day of the week
SELECT 
    TO_CHAR(sale_date, 'Day') AS weekday,
    ROUND(AVG(total_sale), 2) AS avg_sale_amount
FROM retail_sales
GROUP BY weekday
ORDER BY avg_sale_amount DESC;

-- Trend of weekend vs. weekday sales
SELECT 
    CASE 
        WHEN EXTRACT(DOW FROM sale_date) IN (0,6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(total_sale) AS total_revenue,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY day_type
ORDER BY total_revenue DESC;

-- Product Performance

-- Total revenue and profit by product category
SELECT 
    category, 
    SUM(total_sale) AS total_revenue, 
    SUM(total_sale - cogs) AS total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;

-- Product categories with highest return on investment (ROI)
SELECT 
    category, 
    ROUND(SUM(total_sale - cogs) / SUM(cogs) * 100, 2) AS roi_percentage
FROM retail_sales
GROUP BY category
ORDER BY roi_percentage DESC;

-- Customer Loyalty & Retention

-- Percentage of customers who made only a single purchase
SELECT 
    ROUND(COUNT(customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM retail_sales), 2) AS single_purchase_percentage
FROM (
    SELECT customer_id
    FROM retail_sales
    GROUP BY customer_id
    HAVING COUNT(*) = 1
) single_purchases;

-- Identifying churned customers (customers who made only one purchase)
SELECT customer_id, COUNT(*) AS total_purchases
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(*) = 1
ORDER BY total_purchases DESC;

-- Revenue Optimization

-- Correlation between discounts and sales volume
SELECT 
    category,
    ROUND(AVG(price_per_unit - total_sale / quantity), 2) AS avg_discount,
    COUNT(*) AS total_sales
FROM retail_sales
WHERE price_per_unit > (total_sale / quantity)
GROUP BY category
ORDER BY avg_discount DESC;

-- Percentage of revenue from top 10% of customers
SELECT 
    ROUND(SUM(total_sale) * 100.0 / (SELECT SUM(total_sale) FROM retail_sales), 2) AS top_10_percent_revenue
FROM (
    SELECT customer_id, SUM(total_sale) AS total_sales
    FROM retail_sales
    GROUP BY customer_id
    ORDER BY total_sales DESC
    LIMIT (SELECT COUNT(DISTINCT customer_id) * 0.1 FROM retail_sales)
) top_customers;
S
