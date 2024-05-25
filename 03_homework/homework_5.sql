-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */
SELECT product_name, 

CASE
when instr(product_name,'-')=0 
	THEN NULL
when instr(product_name,'-')!=0 
	THEN 
		RTRIM(LTRIM(substr(product_name, instr(product_name,'-')+2)))
END as description

from product


/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */
select product_size from product
where product_size REGEXP '[0-9]'


-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */
SELECT market_date, daily_sales from

(select market_date
,quantity*cost_to_customer_per_qty as sales 
,sum(quantity*cost_to_customer_per_qty) as daily_sales
,rank()over (order by sum(quantity*cost_to_customer_per_qty)) as sales_rank

FROM customer_purchases
group by market_date)
where sales_rank = 1 

UNION

SELECT market_date, daily_sales from

(select market_date
,quantity*cost_to_customer_per_qty as sales 
,sum(quantity*cost_to_customer_per_qty) as daily_sales
,rank()over (order by sum(quantity*cost_to_customer_per_qty) DESC) as sales_rank

FROM customer_purchases
group by market_date)
where sales_rank = 1


-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

--why use CROSS JOIN for this practice? CROSS JOIN is great for creating permutations but not calculations....... (y) can easily be queried by count distinct........
DROP TABLE IF EXISTS number_of_customerssss;

CREATE TEMPORARY TABLE number_of_customerssss AS
SELECT COUNT(DISTINCT customer_first_name || customer_last_name) AS number_of_customers
FROM customer;

DROP TABLE IF EXISTS all_products;

CREATE TEMPORARY TABLE all_products AS
SELECT vendor_id, product_id, SUM(sales) AS total_sales
FROM (
    SELECT DISTINCT vendor_id, product_id, original_price, original_price * 5 AS sales
    FROM vendor_inventory
) 
GROUP BY vendor_id, product_id;

SELECT v.vendor_name, p.product_name, ap.total_sales * nc.number_of_customers AS total_5sales_per_product
FROM all_products ap
JOIN number_of_customerssss nc
JOIN vendor v ON v.vendor_id = ap.vendor_id
JOIN product p ON p.product_id = ap.product_id;

-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */
CREATE TABLE product_units as
SELECT * from product where product_qty_type = 'unit';

ALTER TABLE product_units add snapshot_timestamp;



/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

insert into product_units 
VALUES (24,'Big Mac','1/4lb',3,'unit',CURRENT_TIMESTAMP);


-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

DELETE FROM product_units WHERE snapshot_timestamp is NOT NULL;


-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */



WITH last_inventory AS (
    SELECT 
        market_date, product_id, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY market_date DESC) AS recency, quantity
    FROM 
        vendor_inventory
),

filtered_last_inventory AS (
    SELECT 
        market_date, product_id, quantity
    FROM 
        last_inventory
    WHERE 
        recency = 1
),

product_quantity AS (
    SELECT
        fli.market_date, fli.product_id, p.product_name, fli.quantity
    FROM
        filtered_last_inventory fli
    LEFT JOIN
        product p ON fli.product_id = p.product_id

    UNION ALL

    SELECT
        NULL AS market_date, p.product_id, p.product_name,
        NULL AS quantity
    FROM
        product p
    LEFT JOIN
        filtered_last_inventory fli ON p.product_id = fli.product_id
    WHERE
        fli.product_id IS NULL
)


UPDATE product_units
SET current_quantity = (
    SELECT pq.quantity
    FROM product_quantity pq
    WHERE pq.product_id = product_units.product_id
);

--OMGGGGG this one was so hard, and especially working with DB browser SQLite!!!!!!! no FULL OUTER JOIN!?!?!?!?!