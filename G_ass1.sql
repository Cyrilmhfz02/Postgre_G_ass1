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