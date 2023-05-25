--1. Identify the top 10 customers and their email so we can reward them
WITH t1 AS (SELECT *, first_name || ' ' || last_name AS full_name 
			FROM customer)
SELECT full_name, email, address, phone, city, country, SUM(amount) AS total_purchase_in_currency
FROM t1
JOIN address
USING (address_id)
JOIN city
USING (city_id)
JOIN country
USING (country_id)
JOIN payment
USING(customer_id)
GROUP BY 1,2,3,4,5,6
ORDER BY 7 DESC
LIMIT 10;

SELECT first_name, email
FROM customer
ORDER BY customer_id ASC
LIMIT 10

--2. Identify the bottom 10 customers and their emails
WITH t1 AS (SELECT *, first_name || ' ' || last_name AS full_name 
			FROM customer)
SELECT full_name, email, address, phone, city, country, SUM(amount) AS total_purchase_in_currency
FROM t1
JOIN address
USING (address_id)
JOIN city
USING (city_id)
JOIN country
USING (country_id)
JOIN payment
USING(customer_id)
GROUP BY 1,2,3,4,5,6
ORDER BY 7 ASC
LIMIT 10;

SELECT first_name, email
FROM customer
ORDER BY customer_id DESC
LIMIT 10

--3. What are the most profitable movie genres (ratings)? 
SELECT name AS genre, COUNT(*) AS total_transaction, SUM(amount) AS total_payment
FROM rental
JOIN payment
ON payment.rental_id = rental.rental_id
JOIN inventory
ON inventory.inventory_id = rental.inventory_id
--JOIN film
--ON inventory.film_id = film.film_id
JOIN film_category
ON film_category.film_id = inventory.film_id
JOIN category
ON category.category_id = film_category.category_id
GROUP BY name 
ORDER BY total_transaction DESC;

SELECT category.name AS genre, COUNT(customer.customer_id) AS highest_movie_rate,
SUM(payment.amount) AS total_sales_movie FROM category
inner join film_category
using (category_id)
inner join film
using (film_id)
inner join inventory
using (film_id)
inner join rental
using (inventory_id)
inner join customer
using (customer_id)
inner join payment
using (rental_id)
GROUP BY 1;


--4. How many rented movies were returned late, early, and on time?
WITH t1 AS (Select *, DATE_PART('day', return_date - rental_date)
			AS date_difference
			FROM rental),
t2 AS (SELECT rental_duration, date_difference,
	   CASE
	   	WHEN rental_duration > date_difference THEN 'Returned early'
	   	WHEN rental_duration = date_difference THEN 'Returned on Time' 
	   	ELSE 'Returned late'
	   END AS Return_status
	   FROM film f
	   JOIN inventory i
	   USING(film_id)
	   JOIN t1
	   USING (inventory_id))
SELECT Return_status, count(*) As total_no_of_films
FROM t2
GROUP BY 1
ORDER BY 2 DESC;


--5. What is the customer base in the countries where we have a presence?
SELECT country, COUNT(DISTINCT customer_id) AS total_freq, SUM(amount) AS total_sales 
FROM country
JOIN city
USING(country_id)
JOIN address
USING(city_id)
JOIN customer
USING(address_id)
JOIN payment
USING (customer_id)
GROUP BY country
HAVING COUNT(DISTINCT customer_id) >= 30
ORDER BY total_freq DESC;


--6. Which country is the most profitable for the business?
SELECT country, COUNT(*) AS total_transaction, SUM(amount) AS total_payment
FROM customer
JOIN address
ON address.address_id = customer.address_id
JOIN city
ON city.city_id = address.city_id
JOIN country
ON country.country_id = city.country_id
JOIN payment
ON customer.customer_id = payment.customer_id
GROUP BY country 
ORDER BY total_transaction DESC;


--7. What is the average rental rate per movie genre (rating)?
SELECT name AS movie_genre, ROUND(AVG(rental_rate),2) AS average_rental_rate
FROM film
JOIN film_category
ON film_category.film_id = film.film_id
JOIN category
ON category.category_id = film_category.category_id
GROUP BY movie_genre
ORDER BY average_rental_rate DESC;


