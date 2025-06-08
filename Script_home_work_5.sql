--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате платежа
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате платежа
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по размеру платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по размеру платежа от наибольшего к
--меньшему так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

--задание решил двумя способами
--сначала так:
select customer_id, payment_id, payment_date, column_1, column_2, column_3, column_4
from (
select customer_id, payment_id, payment_date,
dense_rank() over(partition by customer_id order by amount desc) as column_4,
sum(amount) over(partition by customer_id order by payment_date, amount) as column_3,
row_number() over(partition by customer_id order by payment_date) as column_2,
row_number() over(order by payment_date) as column_1
from payment)

--потом так:
select customer_id, payment_id, payment_date,
    row_number() over(order by payment_date) as column_1,
    row_number() over(partition by customer_id order by payment_date) as column_2,
    sum(amount) over(partition by customer_id order by payment_date, amount) as column_3,
    dense_rank() over(partition by customer_id order by amount desc) as column_4
  from payment
  order by customer_id, column_4

--на первый взгляд оба рабочие и верные


--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате платежа.
select customer_id, payment_id, payment_date, amount,
lag(amount, 1, 0.) over(partition by customer_id order by payment_date) as last_amount
from payment


--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
select customer_id, payment_id, payment_date, amount,
(amount-lead(amount, 1, 0.) over(partition by customer_id order by payment_date)) as difference
from payment


--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
select customer_id, payment_id, payment_date, amount
from(
select*,
last_value(payment_date) over(partition by customer_id)
from(
select*
from payment
order by customer_id, payment_date))
where payment_date=last_value


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.
select staff_id, payment_date::date, sum(amount) as sum_amount,
sum(sum(amount)) over(partition by staff_id order by payment_date::date) as sum
from payment
where payment_date::date between '01.08.2005' and '31.08.2005'
group by staff_id, payment_date::date


--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку
select customer_id, payment_date, row_number
from(
	select *, row_number() over (order by payment_date)
	from payment 
	where payment_date::date = '20.08.2005') 
where mod(row_number, 100)=0


--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм
with cte1 as (
	select p.customer_id, count, sum, max
	from (
		select customer_id, sum(amount)
		from payment
		group by customer_id) p
	join (
		select customer_id, count(*), max(r.rental_date)
		from rental r
		join inventory i on r.inventory_id = i.inventory_id
		group by customer_id) r on r.customer_id = p.customer_id),
cte2 as (
	select c2.country_id, concat(c.first_name, ' ', c.last_name), count, sum, max,
		case when count = max(count) over (partition by c2.country_id) then concat(c.first_name, ' ', c.last_name) end cc,
		case when sum = max(sum) over (partition by c2.country_id) then concat(c.first_name, ' ', c.last_name) end cs,
		case when max = max(max) over (partition by c2.country_id) then concat(c.first_name, ' ', c.last_name) end cm
	from customer c
	join address a on c.address_id = a.address_id
	join city c2 on c2.city_id = a.city_id
	join cte1 on c.customer_id = cte1.customer_id)
select c.country, string_agg(cc, ', '), string_agg(cs, ', '), string_agg(cm, ', ')
from country c
left join cte2 on c.country_id = cte2.country_id
group by c.country_id
order by 1

