-- 1
-- Create a view called "sales_revenue_by_category_qtr" that shows the film category and total sales revenue for 
-- the current quarter.
create or replace view sales_revenue_by_category_qtr as
select c.name as category, sum(p.amount) as total_revenue
from payment p
join rental r on p.rental_id = r.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film_category fc on i.film_id = fc.film_id
join category c on fc.category_id = c.category_id
where date_trunc('quarter', current_date) = date_trunc('quarter', p.payment_date)
group by c.name
having sum(p.amount) > 0;

-- 2
-- Create a query language function called "get_sales_revenue_by_category_qtr" that accepts one parameter representing 
-- the current quarter and returns the same result as the "sales_revenue_by_category_qtr" view.
create or replace function get_sales_revenue_by_category_qtr(date) 
returns table (category text, total_revenue numeric) as 
$$
begin
    return query 
    select c.name as category, sum(p.amount) as total_revenue 
    from payment p 
    join rental r on p.rental_id = r.rental_id 
    join inventory i on r.inventory_id = i.inventory_id 
    join film_category fc on i.film_id = fc.film_id 
    join category c on fc.category_id = c.category_id 
    where date_trunc('quarter', p.payment_date) = date_trunc('quarter', $1) 
    group by c.name 
    having sum(p.amount) > 0;
end; 
$$ 
language plpgsql;

-- 3
-- Create a procedure language function called "new_movie" that takes a movie title as a parameter 
-- and inserts a new movie with the given title in the film table
create or replace function new_movie(movie_title text) 
returns void as 
$$
declare klingon_id int;
begin
    select language_id into klingon_id from language where name = 'Klingon';
    if klingon_id is null then 
		raise exception 'Language "Klingon" does not exist in the "language" table.';
    end if;
    insert into film (title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    values (movie_title, 4.99, 3, 19.99, extract(year from current_date), klingon_id);
end; 
$$ 
language plpgsql;

