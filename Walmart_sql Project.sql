SELECT * FROM walmart;
-------------
SELECT 
	 payment_method,
	 COUNT(*)
FROM walmart
GROUP BY payment_method
------------------
SELECT 
	COUNT(DISTINCT branch) 
FROM walmart;
----------------
--------------------------Business Problems--------------------------------
-------Q.1 Find different payment method and number of transactions, number of qty sold


SELECT 
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

--------Q.2:Identify the highest-rated category in each branch, displaying the branch, category AVG RATING

SELECT * 
FROM
(	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1
-----Q.3: Identify the most profitable day of the week.
SELECT 
  TO_CHAR(date, 'Day') AS day_of_week, 
  SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY day_of_week
ORDER BY total_profit DESC;

----Q.4 Identify the busiest day for each branch based on the number of transactions

select* from(
select branch,
      TO_CHAR(date,'DD') as day_name, 
	  count(*) as no_transctions,
	  rank() over(partition by branch order by count(*) desc) as rank
	  from walmart
	  group by 1,2)
where rank=1

------Q.5: Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
SELECT 
      payment_method,
	 SUM(quantity) as Total_qty
FROM walmart
GROUP BY payment_method

---------Q.6:Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.
select
     city,
	 category,
	 MIN(rating) as min_rating,
	 MAX(rating) as MAX_rating,
	 AVG(rating) as AVG_rating
from  walmart
group by 1,2

---------Q.7: Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

select
    category,
	sum(unit_price*quantity) as Total_revenue,
	sum(unit_price * profit_margin * quantity)
from walmart
group by 1

----------- Q.8: Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.


with cte
as
(select 
    branch,
	payment_method,
	count(*) as Total_trans,
	rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1,2
)

select * from cte
where rank=1

-----Q.9: Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

select 
branch,
case 
  when extract(hour from(time::time)) < 12 then 'Morning'
  when extract(hour from(time::time)) between 12 and 17 then 'Afternoon'
  else 'Evening'
 end dat_time, 
 count(*)
from walmart
group by 1,2
order by 1,3 desc

----------Q.10: Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(unit_price * quantity) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5

----Q.11:Identify the best-performing product category by profit margin.
SELECT category, AVG(profit_margin) AS avg_profit_margin
FROM walmart
GROUP BY category
ORDER BY avg_profit_margin DESC
LIMIT 5;

-------Q.12: Find the most popular product category in each city.
WITH city_category_sales AS (
    SELECT City, category, SUM(unit_price * quantity) AS total_sales,
           RANK() OVER (PARTITION BY City ORDER BY SUM(unit_price * quantity) DESC) AS rank
    FROM walmart
    GROUP BY City, category
)
SELECT City, category, total_sales
FROM city_category_sales
WHERE rank = 1;
