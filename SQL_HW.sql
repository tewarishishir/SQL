use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name 'First Name', last_name 'Last Name'  from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(concat(first_name, ' ',  last_name)) 'Actor Name'  from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id ID, first_name 'First Name', last_name 'Last Name'  from actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id ID, first_name 'First Name', last_name 'Last Name'  from actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id ID, first_name 'First Name', last_name 'Last Name'  from actor where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor add column description blob ;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name 'Last Name', count(*) 'Actor Count' from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name 'Last Name', count(*) 'Actor Count' from actor
group by last_name
having count(*) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
-- select actor_id ID, first_name 'First Name', last_name 'Last Name'  from actor where first_name = 'GROUCHO' and last_name =  'WILLIAMS';
update actor set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name =  'WILLIAMS';
-- select actor_id ID, first_name 'First Name', last_name 'Last Name'  from actor where first_name = 'HARPO' and last_name =  'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
-- select actor_id ID, first_name 'First Name', last_name 'Last Name'  from actor where first_name = 'HARPO' ;
update actor set first_name = 'GROUCHO' where first_name = 'HARPO' ;
-- select actor_id ID, first_name 'First Name', last_name 'Last Name'  from actor where first_name = 'GROUCHO' ;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name 'First Name', last_name 'Last Name' , address 'Address' from 
staff s inner join address a
on s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select  s.staff_id 'Staff ID', first_name 'First Name', last_name 'Last Name' ,  sum(amount ) 'Total Amount'
from staff s inner join payment p
on s.staff_id = p.staff_id
where monthname(payment_date) = 'August' and year(payment_date)  = 2005
group by s.staff_id , first_name , last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.film_id, title, count(actor_id) 'Actor Count' 
from film_actor fa join film f
on fa.film_id = f.film_id
group by film_id, title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(*) 'Film Hunchback Impossible Count' 
from inventory i join film f
on i.film_id = f.film_id
where title = 'Hunchback Impossible';


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select  first_name 'First Name', last_name 'Last Name'  ,  sum(amount ) 'Total Amount Paid'
from customer c inner join payment p
on c.customer_id = p.customer_id
group by c.customer_id , first_name , last_name
order by last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- select f.title
-- from film f join language l
-- on f.language_id = l.language_id
-- where (f.title like 'K%' or f.title like 'Q%') and l.name = 'English'

select f.title
from film f 
where (f.title like 'K%' or f.title like 'Q%') and f.language_id  in (select language_id from language where name = 'English');


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select concat(a.first_name, ' ', a.last_name) 'Actor Name'
from actor a where a.actor_id in (select fa.actor_id from film_actor fa where fa.film_id in (select film_id from film f where f.title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select cust.first_name 'First Name', cust.last_name 'Last Name', cust.email 'Email'
from country coun join city ci
on ci.country_id = coun.country_id
join address ad 
on ad.city_id = ci.city_id
join customer cust
on cust.address_id = ad.address_id
where coun.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select f.title, f.description, f.release_year, f.special_features
from category cat join film_category fc
on cat.category_id = fc.category_id
join film f 
on f.film_id = fc.film_id
where cat.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select f.film_id 'ID', title, count(*) 'Film Count'
from film f join inventory i
on f.film_id = i.film_id
join rental r
on r.inventory_id = i.inventory_id
group by f.film_id, title
order by 3 desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(amount) 'Store Revenue'
from store s join customer c 
on s.store_id = c.store_id
join payment p
on p.customer_id = c.customer_id
group by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id 'Store ID', c.city 'City', coun.country 'Country'
from store s join address a 
on s.address_id = a.address_id
join city c 
on c.city_id = a.city_id
join country coun 
on coun.country_id = c.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select cat.name, sum(p.amount) 'Gross Revenue'
from category cat join film_category fc
on cat.category_id = fc.category_id
join film f 
on f.film_id = fc.film_id
join inventory i
on f.film_id = i.film_id
join rental r
on r.inventory_id = i.inventory_id
join payment p
on p.rental_id = r.rental_id
group by cat.name
order by 2 desc
limit 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres
as
select cat.name, sum(p.amount) 'Gross Revenue'
from category cat join film_category fc
on cat.category_id = fc.category_id
join film f 
on f.film_id = fc.film_id
join inventory i
on f.film_id = i.film_id
join rental r
on r.inventory_id = i.inventory_id
join payment p
on p.rental_id = r.rental_id
group by cat.name
order by 2 desc
limit 5;


-- 8b. How would you display the view that you created in 8a?
#definition
Show create view top_five_genres;
#data
select * from top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view if exists top_five_genres;

