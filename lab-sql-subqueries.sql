USE sakila;

/* Challenge
Write SQL queries to perform the following tasks using the Sakila database:
1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
2. List all films whose length is longer than the average length of all the films in the Sakila database.
3. Use a subquery to display all actors who appear in the film "Alone Trip".
*/
-- 1. 
SELECT f.title, COUNT(i.film_id) AS num_of_copies
FROM film as f
JOIN inventory as i
ON f.film_id = i.film_id
WHERE title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY f.title;

-- 2. 
SELECT * FROM film
WHERE length > 
	(SELECT ROUND(AVG(length)) AS avg_length
	FROM film)
ORDER BY length;

-- 3.
SELECT actor_id, CONCAT(first_name,' ',last_name) AS actor_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id 
    FROM film_actor 
	WHERE film_id IN (
		SELECT film_id
		FROM film
		WHERE title = 'ALONE TRIP') 
);

/* Bonus:
4. Sales have been lagging among young families, and you want to target family movies for a promotion.
Identify all movies categorized as family films.
5. Retrieve the name and email of customers from Canada using both subqueries and joins. 
To use joins, you will need to identify the relevant tables and their primary and foreign keys.
6. Determine which films were starred by the most prolific actor in the Sakila database. 
A prolific actor is defined as the actor who has acted in the most number of films. 
First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
7. Find the films rented by the most profitable customer in the Sakila database. 
You can use the customer and payment tables to find the most profitable customer,
i.e., the customer who has made the largest sum of payments.
8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent
by each client. You can use subqueries to accomplish this.
*/

-- 4. 
SELECT f.title AS family_movies
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id 
JOIN category c
ON fc.category_id = c.category_id 
WHERE name = 'Family'
ORDER BY f.title;

SELECT title
FROM film 
WHERE film_id IN (
	SELECT film_id 
	FROM film_category
	WHERE category_id IN (
		SELECT category_id
		FROM category 
		WHERE name = 'Family')
ORDER BY title
);

-- 5.
SELECT cu.first_name, cu.last_name, cu.email
FROM customer cu
WHERE cu.address_id IN (
	SELECT a.address_id 
    FROM address a
    JOIN city c
    ON a.city_id = c.city_id
	JOIN country co
	ON c.country_id = co.country_id 
	WHERE country = 'Canada');
    
-- 6. 
SELECT title
FROM film
WHERE film_id IN (
    SELECT film_id
    FROM film_actor
    WHERE actor_id = (
        SELECT actor_id
        FROM film_actor
        GROUP BY actor_id
        ORDER BY COUNT(*) DESC
        LIMIT 1)
);

-- 7. 
SELECT title
FROM film
WHERE film_id IN (
    SELECT film_id
	FROM inventory
    WHERE inventory_id IN ( 
		SELECT inventory_id 
        FROM rental 
        WHERE customer_id IN (
			SELECT customer_id 
			FROM inventory 
			WHERE customer_id = (
				SELECT customer_id 
				FROM payment
				GROUP BY customer_id
				ORDER BY SUM(amount) DESC
				LIMIT 1))));

SELECT f.title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id
JOIN (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
) AS top_customer ON c.customer_id = top_customer.customer_id;

-- 8.
SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id 
HAVING total_amount_spent > (
	SELECT AVG(total_amount) 
	FROM (
		SELECT customer_id, SUM(amount) AS total_amount
		FROM payment
		GROUP BY customer_id) AS sub1)
ORDER BY total_amount_spent;