--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
select upper(concat(c.first_name,' ', c.last_name)) as "customer name", a.address, ct.city, cn.country
from customer c
right join address a on c.address_id=a.address_id
right join city ct on a.city_id=ct.city_id
right join country cn on ct.country_id=cn.country_id


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select s.store_id, count(c.customer_id) as "количество покупателей"
from store s
left join customer c on s.store_id=c.store_id
group by s.store_id 


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select s.store_id, count(c.customer_id) as "количество покупателей"
from store s
left join customer c on s.store_id=c.store_id
group by s.store_id
having count(c.customer_id)>300


-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select s.store_id, count(c.customer_id) as "количество покупателей", ct.city as "город", concat(sf.last_name,' ', sf.first_name) as "фамилия и имя сотрудника"
from store s
left join customer c on s.store_id=c.store_id
right join address a on s.address_id=a.address_id
right join city ct on a.city_id=ct.city_id
right join staff sf on s.store_id=sf.store_id
group by s.store_id, ct.city_id, sf.staff_id
having count(c.customer_id)>300


--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select concat(c.first_name,' ', c.last_name) as "имя и фамилия", count(r.customer_id)
from customer c
left join rental r on c.customer_id=r.customer_id
group by c.customer_id
order by count(r.customer_id) desc
limit 5

--можно еще лимит задать так:
select concat(c.first_name,' ', c.last_name)as "имя и фамилия", count(r.customer_id)
from customer c
left join rental r on c.customer_id=r.customer_id
group by c.customer_id
order by count(r.customer_id) desc
fetch first 5 rows with ties --можно еще лимит задать так:


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select concat(c.first_name,' ', c.last_name) as "имя и фамилия",
	count(r.rental_id) as "количество арендованных фильмов",
	round(sum(p.amount), 0) as "общая стоимость",
	min(p.amount)as "минимальная стоимость",
	max(p.amount)as "максимальная стоимость"
	from customer c	
left join payment p on c.customer_id=p.customer_id
left join rental r on r.rental_id=p.rental_id
group by c.customer_id


--ЗАДАНИЕ №5
--Используя данные из таблицы городов, составьте все возможные пары городов так, чтобы 
--в результате не было пар с одинаковыми названиями городов. Решение должно быть через Декартово произведение.
 select distinct c1.city as "город 1", c2.city as "город 2"
 from city c1, city c2
 where c1.city > c2.city


--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и 
--дате возврата (поле return_date), вычислите для каждого покупателя среднее количество 
--дней, за которые он возвращает фильмы. В результате должны быть дробные значения, а не интервал.
 select distinct customer_id as "ID покупателя", round(avg(return_date::date-rental_date::date), 2) as"среднее число дней на возврат"
 from rental
 group by customer_id
 order by customer_id
 

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select f.title as "название фильма",
       f.rating as "рейтинг",
       fc.string_agg as "жанр",
       f.release_year as "год выпуска",
       l."name" as "язык",
       i.count as "количество аренд",
       i.sum as "общая стоимость аренды"
from film f
left join (
	select i.film_id, count(r.rental_id), sum(p.amount)
	from inventory i
	left join rental r on r.inventory_id=i.inventory_id
	left join payment p on p.rental_id=r.rental_id
	group by i.film_id) i on f.film_id=i.film_id
left join "language" l on l.language_id=f.language_id
left join (
	select fc.film_id, string_agg(c.name, ', ')
	from film_category fc
	left join category c on c.category_id=fc.category_id
	group by fc.film_id) fc on f.film_id=fc.film_id


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd дисках.
select f.title as "название фильма",
       f.rating as "рейтинг",
       fc.string_agg as "жанр",
       f.release_year as "год выпуска",
       l."name" as "язык",
       f.count as "количество аренд",
       f.sum as "общая стоимость аренды"
from (
	select f.film_id, f.title, f.release_year, f.language_id, f.rating, count(r.rental_id), sum(p.amount)
	from film f
	left join inventory i on f.film_id=i.film_id
	left join rental r on r.inventory_id=i.inventory_id
	left join payment p on p.rental_id=r.rental_id
	where i.film_id is null
	group by f.film_id) f
left join "language" l on l.language_id=f.language_id
left join (
	select fc.film_id, string_agg(c.name, ', ')
	from film_category fc
	left join category c on c.category_id=fc.category_id
	group by fc.film_id) fc on f.film_id=fc.film_id


--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
select s.staff_id, count(p.payment_id),
	case
		when count(p.payment_id) > 7300 then 'да'
		else 'нет'
	end "Премия"
from payment p
right join staff s on s.staff_id=p.staff_id 
group by s.staff_id









