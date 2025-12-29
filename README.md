# Sales-Performance-Analysis-with-SQL
## Project Overview
The objective of this analysis is to identify key sales performance drivers across products, customers, suppliers, stores, and time periods. Using SQL, the project uncovers insights that support revenue optimization and operational decision-making.
The analysis is conducted on a star-schema–style dataset consisting of fact and dimension tables (transactions, customers, item, store, and time).

**The Entity Relationship Diagram**
![test](Images/fdh.PNG)

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
