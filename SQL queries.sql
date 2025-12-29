--The objective of this analysis is to identify key sales performance drivers across 
--products, customers, suppliers, stores, and time periods, using SQL to uncover insights 
--that support revenue optimization and operational decision-making.

--1. Which products are the best performers based on sales volume and total revenue?
 WITH product_sales AS (
		SELECT 
 		i.item_name,
		SUM(f.quantity) AS total_quantity,
		SUM(f.total_price) AS total_revenue
 FROM item_dim i
 JOIN fact_table f
 ON i.item_key = f.item_key
 GROUP BY i.item_key, i.item_name
 )
 SELECT 
 	item_name, 
	total_quantity,
	total_revenue,
	RANK() OVER(ORDER BY total_quantity DESC) AS quantity_rank,
	RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank	
 FROM product_sales
 ORDER BY revenue_rank -- By adding DESC to the last line of the query, 
 --we can know underperforming products by revenue, by ordering by qntity rank, we can see product performance by quantitysold.
 ;

         
--Which store locations generate the highest revenue and number of transactions?
SELECT 
		s.store_key, 
		s.division, 
		s.district,
		SUM(f.quantity) AS total_transactions,
		SUM(f.total_price) AS total_revenue
FROM store_dim s
JOIN fact_table f
ON s.store_key = f.store_key
GROUP BY s.store_key, division, district
ORDER BY total_revenue DESC;


--SALES TREND ANALYIS
-- Create view of data between 2014 and 2020 becuase they have complete data while 2021 only have for january

CREATE VIEW complete_data AS
SELECT 
	t.date,
	t.hour,
	t.day,
	t.week,
	t.month,
	t.quarter,
	t.year,
	f.total_price
FROM time_dim t
JOIN fact_table f
	ON t.time_key = f.time_key
WHERE DATE_PART('year', date) BETWEEN 2014 AND 2020;


--3. What is the year-over-year (YoY) sales performance, and how much did sales grow or decline annually?
WITH yearly_sales AS (
	SELECT
		DATE_PART('Year', date) AS year,
		SUM(total_price) as yearly_revenue
	FROM complete_data
	GROUP BY DATE_PART('Year', date)
)
SELECT 
	year,
	yearly_revenue,
	yearly_revenue - LAG(yearly_revenue, 1) OVER(ORDER BY year),
	ROUND(((yearly_revenue - LAG(yearly_revenue, 1) OVER(ORDER BY year)) /
	LAG(yearly_revenue, 1) OVER(ORDER BY year) * 100), 2) 
FROM yearly_sales;
	

 

--4. What are the weekly and monthly sales trends, and which time periods show the strongest performance?
--Weekly Sales Trend
SELECT 
	week,
	SUM(total_price) AS total_sales
FROM complete_data
GROUP BY week
ORDER BY 2 DESC;


--Monthly Sales Trend
SELECT 
	DATE_PART('month',date) AS month,
	SUM(total_price) AS total_sales
FROM complete_data
GROUP BY DATE_PART('month',date)
ORDER BY 2 DESC;


 
--5. Which customers are the highest spenders, and how much do they contribute to total revenue?
SELECT 
	c.name,
	SUM(f.total_price) AS total_amount_spent
FROM customers c
JOIN fact_table f
	ON f.customer_key = c.customer_key
WHERE c.name IS NOT NULL
GROUP BY c.name
ORDER BY 2 DESC;



--6. How do product selling prices relate to their sales volume and total revenue, and which products rank highest in performance?
WITH product_performance AS (
	SELECT 	
		i.item_name,
		ROUND(AVG(f.unit_price),2) AS avg_unit_price,
		SUM(quantity) AS total_quantity_sold,
		SUM(total_price) AS total_revenue
	FROM item_dim i
	JOIN fact_table f
		ON i.item_key = f.item_key
	GROUP BY item_name	 
)
SELECT
	item_name,
	avg_unit_price,
	total_quantity_sold,
	total_revenue,
	RANK() OVER(ORDER BY total_quantity_sold DESC) AS quantity_rank,
	RANK() OVER(ORDER BY total_revenue DESC) AS sales_rank
FROM product_performance
ORDER BY 2 DESC;
	


--7. Which suppliers contribute the highest revenue to the business?
SELECT 
	supplier,
	SUM(quantity) AS total_quantity,
	SUM(total_price) AS total_revenue,
	RANK()OVER (ORDER BY SUM(quantity) DESC) AS quantity_rank
FROM item_dim i
JOIN fact_table f
	ON i.item_key = f.item_key
GROUP by supplier
ORDER BY 2 DESC;



--8. Which products show declining sales over time, based on year-over-year performance?
WITH yearly_product_performance AS (
	SELECT 
		item_name,
		DATE_PART('Year', date) AS year,
		SUM(total_price) AS total_revenue
	FROM item_dim i
	JOIN fact_table f ON i.item_key = f.item_key
	JOIN time_dim t ON t.time_key = f.time_key
	WHERE DATE_PART('Year', date) != '2021'
	GROUP BY item_name, DATE_PART('Year', date)
	ORDER BY item_name
),
trend AS (
	SELECT 
		item_name,
		year,
		total_revenue,
		LAG(total_revenue,1)OVER(PARTITION BY item_name ORDER BY YEAR) AS prev_year_sale
	FROM yearly_product_performance
)
SELECT
	item_name,
	year,
	total_revenue,
	prev_year_sale
FROM trend
WHERE prev_year_sale IS NOT NULL AND prev_year_sale > total_revenue
;




--9. What percentage of customers are repeat buyers, and how many customers purchase more than once?
WITH purchase_days AS (
	SELECT 
		customer_key,
		COUNT(DISTINCT date) AS purchase_days
	FROM fact_table f
	JOIN time_dim t
		ON t.time_key = f.time_key
	GROUP BY customer_key
)
SELECT  
	ROUND((COUNT(*) FILTER (WHERE purchase_days > 1) *100.0) / COUNT(*), 2)
FROM purchase_days
 ;
 
 
  
--10. Which store locations are experiencing the highest year-over-year growth or decline in revenue?
WITH store_performance AS (
	SELECT  
		division,
		year,
		SUM(total_price) AS revenue
	FROM store_dim s
	JOIN fact_table f
		ON s.store_key =f.store_key
	JOIN time_dim t
		ON t.time_key = f.time_key
	GROUP BY division, year
) 
SELECT 
	division,
	year,
	revenue,
	ROUND(
	(revenue - LAG(revenue, 1) OVER(PARTITION BY division ORDER BY year))
	/LAG(revenue, 1) OVER(PARTITION BY division ORDER BY year)
	* 100.0,
	2)
FROM store_performance
WHERE year != '2024';
	
	
 
     

 