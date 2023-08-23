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
