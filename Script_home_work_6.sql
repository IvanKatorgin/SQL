--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
explain analyze
select film_id, title, special_features 
from film
where special_features && array['Behind the Scenes']


--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
explain analyze
select film_id, title, special_features
from film
where array_position(special_features,'Behind the Scenes') is not null


explain analyze
select film_id, title, special_features
from film
where 'Behind the Scenes' =any (special_features)


--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.
explain analyze
with cte as(
select film_id, title, special_features 
from film
where special_features && array['Behind the Scenes'])
select c.customer_id, count(r.rental_id)
from customer c
join rental r on c.customer_id=r.customer_id
join inventory i on i.inventory_id=r.inventory_id
join cte on cte.film_id=i.film_id
group by c.customer_id
order by c.customer_id


--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.
explain analyze
select c.customer_id, count(r.rental_id)
from customer c
join rental r on c.customer_id=r.customer_id
join inventory i on i.inventory_id=r.inventory_id
join (select film_id, title, special_features 
from film
where special_features && array['Behind the Scenes']) as t1 on t1.film_id=i.film_id
group by c.customer_id
order by c.customer_id


--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления
create materialized view tasc_1 as
select c.customer_id, count(r.rental_id)
from customer c
join rental r on c.customer_id=r.customer_id
join inventory i on i.inventory_id=r.inventory_id
join (select film_id, title, special_features 
from film
where special_features && array['Behind the Scenes']) as t1 on t1.film_id=i.film_id
group by c.customer_id
order by c.customer_id

refresh materialized view tasc_1


--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ стоимости выполнения запросов из предыдущих заданий и ответьте на вопросы:
--1. с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания: 
--поиск значения в массиве затрачивает меньше ресурсов системы;
--2. какой вариант вычислений затрачивает меньше ресурсов системы: 
--с использованием CTE или с использованием подзапроса.
 
--explain analyze запросов:
--1. Seq Scan on film  (cost=0.00..67.50 rows=538 width=78) (actual time=0.023..0.358 rows=538 loops=1)
--2. Seq Scan on film  (cost=0.00..67.50 rows=995 width=78) (actual time=0.037..0.444 rows=538 loops=1)
--3. Seq Scan on film  (cost=0.00..77.50 rows=538 width=78) (actual time=0.014..0.312 rows=538 loops=1)
--4. Sort  (cost=719.27..720.76 rows=599 width=12) (actual time=11.597..11.616 rows=599 loops=1)
--5. Sort  (cost=719.27..720.76 rows=599 width=12) (actual time=10.917..10.936 rows=599 loops=1)

выводы:
1. с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания
поиск значения в массиве затрачивает меньше ресурсов системы:
в данном случае со всеми примерно одинаково, но && чуть эффективнее

2. какой вариант вычислений затрачивает меньше ресурсов системы: с использованием CTE или с использованием подзапроса
в данном случае примерно одинаково, но с подзапросом время выполнения чуть быстрее


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии
--Сделайте explain analyze этого запроса:
explain analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc

--оптимизированный запрос:
explain analyze
select  c.first_name  || ' ' || c.last_name as name, count(*)
from rental r
right join inventory i on r.inventory_id = i.inventory_id
	and i.film_id in (
		select film_id
		from film 
		where special_features && array['Behind the Scenes']) 
join customer c on c.customer_id = r.customer_id
group by c.customer_id
order by 2 desc


--Основываясь на описании запроса, найдите узкие места и опишите их
В первоначальном запросе содержится много ошибок и неточностей.
В нем узкие места связаны с hash join
его выполнение увеличивает количество строк до 8608 что приводит к увеличению стоимости

--Сравните с вашим запросом из основной части (если ваш запрос изначально укладывается в 15мс — отлично!).
в целом мои запросы укладываются в диапазон 15мс

--Сделайте построчное описание explain analyze на русском языке оптимизированного запроса.
Тут пока тяжко. Не могу прям построчно их читать. Буду постепенно вникать

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
select p.staff_id, f.film_id, f.title, p.amount, p.payment_date, c.last_name as customer_last_name, c.first_name as customer_first_name 
from(
select *, row_number() over (partition by staff_id order by payment_date)
from payment) p
join customer c on p.customer_id=c.customer_id
join rental r on p.rental_id=r.rental_id
join inventory i on r.inventory_id=i.inventory_id
join film f on i.film_id=f.film_id
where row_number=1


--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

Задание не имеет решения, учитывая текущие данные.
Возможно девять вариантов неточного решения:

аренда			продажа
диск			диск
сотрудник		сотрудник
пользователь	пользователь
диск			сотрудник
диск			пользователь
сотрудник		диск
сотрудник		пользователь
пользователь	диск
пользователь	сотрудник

select *
from (
	select i.store_id, r.rental_date::date, count(i.film_id),
		row_number() over (partition by i.store_id order by count(i.film_id) desc)
	from rental r
	join inventory i on r.inventory_id = i.inventory_id
	group by 1, 2) t1
join (
	select s.store_id, p.payment_date::date, sum(p.amount),
		row_number() over (partition by s.store_id order by sum(p.amount))
	from payment p
	join staff s on s.staff_id = p.staff_id
	group by 1, 2) t2 on t1.store_id = t2.store_id
where t1.row_number = 1 and t2.row_number = 1

