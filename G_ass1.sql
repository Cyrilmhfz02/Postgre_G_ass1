--Using a CTE, find out the total number of films rented for each rating (like 'PG', 'G', etc.) in the year 2005.
--List the ratings that had more than 50 rentals.
With CTE_rental AS(
	SELECT
		
		f.rating,
		Count(f.film_id) as numb_film
	FROM public.film as f
	INNER JOIN public.inventory AS inv
	ON f.film_id=inv.film_id
	INNER JOIN public.rental AS rent
	ON rent.inventory_id=inv.inventory_id
	WHERE  EXTRACT( YEAR from rent.rental_date) = 2005
	GROUP BY f.rating
	
)
SELECT
	*
from CTE_rental
WHERE numb_film >50

--: Identify the categories of films that have an average rental duration greater than 5 days. 
--Only consider films rated 'PG' or 'G'.
	SELECT 
		cat.name as category,
		AVG(f.rental_duration) as avrg_rent_dur
	FROM film as f
	INNER JOIN public.film_category AS f_cat
	ON f_cat.film_id=f.film_id
	INNER JOIN public.category as cat
	ON cat.category_id=f_cat.category_id
	WHERE f.rating='PG' OR f.rating='G' 
	GROUP BY category
	HAVING AVG(f.rental_duration) >5


--: Determine the total rental amount collected from each customer. 
--List only those customers who have spent more than $100 in total.

SELECT
	CONCAT(cust.first_name,' ',cust.last_name) AS full_name,
	SUM(pay.amount) as sum_amount
FROM public.payment as pay
INNER JOIN customer as cust
ON pay.customer_id=cust.customer_id
GROUP BY CONCAT(cust.first_name,' ',cust.last_name)
HAVING SUM(pay.amount) >100


--: Create a temporary table containing the names and email addresses of customers who have rented more than 10 films.

CREATE TEMP TABLE cust_rent_more_than_10 AS(
	SELECT 
		CONCAT(cust.first_name,' ',cust.last_name) AS full_name,
		COUNT(rent.rental_id) AS number_of_rental,
		cust.email
	FROM customer as cust
	INNER JOIN rental as rent
	ON rent.customer_id=cust.customer_id
	GROUP BY CONCAT(cust.first_name,' ',cust.last_name), cust.email
	HAVING COUNT(rent.rental_id)>10
)


--: From the temporary table created in Task 3.1, identify customers who have a Gmail email address (i.e., their email ends with '@gmail.com').

CREATE TEMP TABLE cust_rent_more_than_10 AS
	SELECT 
		CONCAT(cust.first_name,' ',cust.last_name) AS full_name,
		COUNT(rent.rental_id) AS number_of_rental,
		cust.email as email
	FROM customer as cust
	INNER JOIN rental as rent
	ON rent.customer_id=cust.customer_id
	GROUP BY CONCAT(cust.first_name,' ',cust.last_name), cust.email
	HAVING COUNT(rent.rental_id)>10;


SELECT *
FROM cust_rent_more_than_10 
WHERE email LIKE '%@gmail.com'

--BIG TASK INCOMING:
-- STEP 1: Create a CTE that finds the total number of films rented for each category.
-- STEP 2: Create a temporary table from this CTE.

CREATE TEMPORARY TABLE temp_cte AS
	WITH CTE_total_nb_films_rented_per_cat AS (
		SELECT
			COUNT(rent.rental_id) AS total_rent,
			cat.name AS category
		FROM public.film AS f
		INNER JOIN public.inventory AS inv 
		ON f.film_id = inv.film_id
		INNER JOIN public.rental AS rent 
		ON inv.inventory_id = rent.inventory_id
		INNER JOIN public.film_category AS f_cat 
		ON f.film_id = f_cat.film_id
		INNER JOIN public.category AS cat 
		ON cat.category_id = f_cat.category_id
		GROUP BY 
			category
	)
SELECT
	category,
	total_rent
FROM CTE_total_nb_films_rented_per_cat;


SELECT *
FROM temp_cte

--STEP 3: Using the temporary table, list the top 5 categories with the highest number of rentals. Ensure the results are in descending order.
SELECT 
	category,
	total_rent
FROM temp_cte
ORDER BY 
	total_rent DESC
LIMIT 5


--: Identify films that have never been rented out. Use a combination of CTE and LEFT JOIN for this task.

WITH CTE_film_rented AS (
	SELECT
		DISTINCT inv.film_id AS r_f_id
	FROM public.rental AS rent
	INNER JOIN public.inventory AS inv
	ON rent.inventory_id = inv.inventory_id
),

CTE_unrented_film AS (
	SELECT 
		f.film_id AS u_f_id, 
		f.title AS u_f_t
	FROM public.film AS f
	LEFT OUTER JOIN CTE_film_rented
	ON CTE_film_rented.r_f_id = f.film_id
	WHERE 
		CTE_film_rented.r_f_id IS NULL
)

SELECT 
	u_f_id,
	u_f_t
FROM CTE_unrented_film;

--(INNER JOIN): Find the names of customers who rented films with a replacement cost greater than $20 and 
--which belong to the 'Action' or 'Comedy' categories.

SELECT
	f.title,
	f.replacement_cost AS rep_cost,
	cat.name
FROM public.customer AS cust
INNER JOIN public.rental AS rent
ON rent.customer_id=cust.customer_id
INNER JOIN public.inventory AS inv
ON rent.inventory_id=inv.inventory_id
INNER JOIN public.film AS f
ON f.film_id=inv.film_id
INNER JOIN public.film_category as f_cat
ON f.film_id=f_cat.film_id
INNER JOIN public.category as cat
ON f_cat.category_id=cat.category_id
WHERE f.replacement_cost >20 AND (cat.name LIKE 'Action' OR cat.name LIKE 'Comedy')