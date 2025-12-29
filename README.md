# Sales-Performance-Analysis-with-SQL
## Project Overview
The objective of this analysis is to identify key sales performance drivers across products, customers, suppliers, stores, and time periods. Using SQL, the project uncovers insights that support revenue optimization and operational decision-making.
The analysis is conducted on a star-schema–style dataset consisting of fact and dimension tables (transactions, customers, item, store, and time).

**The Entity Relationship Diagram**


![test](images/ERD.PNG)

## Business Questions & Analysis
### 1. Best-Performing Products by Sales Volume and Revenue
Business Question: Which products generate the highest sales volume and total revenue?


```sql
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
 ORDER BY revenue_rank;
```

**Approach:**
I used SQL aggregations to calculate total quantity sold and total revenue per product. Window functions were then applied to rank products by both sales volume and revenue, allowing for identification of top- and bottom-performing products.

**Key Findings:**
•	The Top 10 products ranked by total revenue show that Red Bull 12oz is the highest-revenue-generating product.
•	Red Bull 12oz is also ranked 5th in sales volume out of over 200 products, indicating strong performance in both revenue and quantity sold.
•	Changing the final query order to ORDER BY quantity_rank allows identification of the top products based on sales volume instead of revenue.
Focusing on these top-performing products can help improve inventory planning and marketing effectiveness.
