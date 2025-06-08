--итоговая работа по модулю "SQL и получение данных"
--Каторгин Иван Павлович, DSU-PROD-74
--Data Scientist: расширенный курс. Тариф Продвинутый

--Задания:
--1. Выведите название самолетов, которые имеют менее 50 посадочных мест?
--вариант 1
select a.model as "название самолета", s.aircraft_code as "код самолета", count(*) as "количество посадочных мест"
from seats s
left join aircrafts a on s.aircraft_code=a.aircraft_code 
group by a.model, s.aircraft_code
having count(*) < 50

--вариант 2
select s.aircraft_code as "код самолета", count(*) as "количество посадочных мест"
from seats s 
group by aircraft_code
having count(*) < 50


--2. Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.
--вариант 1
with recursive r as (
--стартовая часть
select min(date_trunc('month', book_date)) x
from bookings
union
--рекурсивная часть
select x + interval '1 month' as x
from r
where x < (select max(date_trunc('month', book_date)) x from bookings))
select x::date as "дата", coalesce (b.sum, 0.) as "сумма бронирования",
round(((coalesce (b.sum, 0.)/lag(coalesce (b.sum, 0.), 1, null) over (order by x::date))*100-100), 2) as "изменение, %"
from r
left join (
select date_trunc('month', book_date), sum(total_amount)
from bookings
group by 1) b on b.date_trunc=r.x
order by 1

--вариант 2 (через generate_series):
select x::date as "дата", coalesce (b.sum, 0.) as "сумма бронирования",
round(((coalesce (b.sum, 0.)/lag(coalesce (b.sum, 0.), 1, null) over (order by x::date))*100-100), 2) as "изменение, %"
from generate_series (
(select min(date_trunc('month', book_date)) from bookings),
(select max(date_trunc('month', book_date)) x from bookings),
interval '1 month') x
left join (
select date_trunc('month', book_date), sum(total_amount)
from bookings
group by 1) b on b.date_trunc=x
order by 1


--3. Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg.
select a.aircraft_code as "код самолета", a.model as "модель самолета", s.array_agg as "класс"
from(
	select aircraft_code, array_agg(distinct fare_conditions)
		from seats
		group by aircraft_code) as s
join aircrafts a on s.aircraft_code=a.aircraft_code 
where array_position(s.array_agg, 'Business') is null


--4. Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день,
--учитывая только те самолеты, которые летали пустыми и только те дни,
--где из одного аэропорта таких самолетов вылетало более одного.
--В результате должны быть код аэропорта, дата, количество пустых мест в самолете и накопительный итог.
select f.departure_airport as "код аэропорта", f.scheduled_departure::date as "дата вылета",
count(s.seat_no) as "пустые места",
sum(count(s.seat_no)) over(partition by f.scheduled_departure::date order by f.departure_airport) as "накопленные пустые места"
from flights f
left join boarding_passes bp on f.flight_id = bp.flight_id
left join seats s on f.aircraft_code = s.aircraft_code
where bp.flight_id is null
group by f.departure_airport, f.scheduled_departure::date
having count(f.scheduled_departure::date) > 1
order by f.scheduled_departure::date, f.departure_airport


--5. Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов.
--Выведите в результат названия аэропортов и процентное отношение.
--Решение должно быть через оконную функцию.
--вариант 1
select distinct f.flight_no as "рейс",
a1.airport_name as "аэропорт вылета",
a2.airport_name as "аэропорт прилета",
concat(f.departure_airport, '-', f.arrival_airport) as "маршрут",
count(f.flight_no)*100. / sum(count(f.flight_no)) over () as "процент вылетов"
from flights f
join airports a1 on f.departure_airport=a1.airport_code
join airports a2 on f.arrival_airport=a2.airport_code
group by f.flight_no, f.departure_airport, f.arrival_airport, a1.airport_name, a2.airport_name
order by f.flight_no

--вариант 2
select distinct concat(f.departure_airport, '-', f.arrival_airport) as "маршрут",
a1.airport_name as "аэропорт вылета",
a2.airport_name as "аэропорт прилета",
count(f.flight_no)*100. / sum(count(f.flight_no)) over () as "процент вылетов"
from flights f
join airports a1 on f.departure_airport=a1.airport_code
join airports a2 on f.arrival_airport=a2.airport_code
group by f.flight_no, f.departure_airport, f.arrival_airport, a1.airport_name, a2.airport_name
order by a1.airport_name


--6. Выведите количество пассажиров по каждому коду сотового оператора, если учесть,
--что код оператора - это три символа после +7
--вариант 1
select distinct substring(contact_data ->> 'phone', 3, 3) as "код оператора",
count(distinct passenger_id) as "количество пассажиров"
from tickets t
group by 1
order by 1


--7. Классифицируйте финансовые обороты (сумма стоимости перелетов) по маршрутам:
--До 50 млн - low
--От 50 млн включительно до 150 млн - middle
--От 150 млн включительно - high
--Выведите в результат количество маршрутов в каждом полученном классе
select "классификация" as "уровень оборота", count(*) as "количество маршрутов"
from(
	select sum(tf.amount),
		case
			when sum(tf.amount) < 50000000 then 'low'
			when sum(tf.amount) >= 150000000 then 'high'
			else 'middle'
		end "классификация"
	from ticket_flights tf
	join flights f on tf.flight_id=f.flight_id
	group by f.flight_no)
group by "классификация"


--8. Вычислите медиану стоимости перелетов, медиану размера бронирования и отношение медианы бронирования к медиане стоимости перелетов, округленной до сотых
with cte1 as (
select
percentile_disc(0.5) within group (order by total_amount) as "медиана бронирования"
from bookings),
cte2 as (
select
percentile_disc(0.5) within group (order by amount) as "медиана стоимости перелетов"
from ticket_flights)
select *, round("медиана бронирования" / "медиана стоимости перелетов", 2) as "отношение"
from cte1, cte2


--9. Найдите значение минимальной стоимости полета 1 км для пассажиров. То есть нужно найти расстояние между аэропортами и с учетом стоимости перелетов получить искомый результат
create extension cube

create extension earthdistance

--вариант 1. Стоимость посчитал просто как tf.amount
select min("стоимость 1 км")
from(
select distinct a1.airport_code as departure_airport,
a2.airport_code as arrival_airport,
a1.longitude as longitude_departure_airport, a1.latitude as latitude_departure_airport,
a2.longitude as longitude_arrival_airport, a2.latitude as latitude_arrival_airport,
concat(f.departure_airport, '-', f.arrival_airport) as "маршрут", tf.amount,
earth_distance(ll_to_earth(a1.latitude, a1.longitude), ll_to_earth(a2.latitude, a2.longitude))/1000 as distance,
tf.amount / (earth_distance(ll_to_earth(a1.latitude, a1.longitude), ll_to_earth(a2.latitude, a2.longitude))/1000) as "стоимость 1 км"
from flights f
join airports a1 on f.departure_airport=a1.airport_code
join airports a2 on f.arrival_airport=a2.airport_code
join ticket_flights tf on f.flight_id =tf.flight_id
order by 1
)

--вариант 2. Стоимость посчитал с использованием оконной функции (sum(tf.amount) over (partition by tf.flight_id order by tf.flight_id))
select min("стоимость 1 км")
from(
select distinct a1.airport_code as departure_airport,
a2.airport_code as arrival_airport,
a1.longitude as longitude_departure_airport, a1.latitude as latitude_departure_airport,
a2.longitude as longitude_arrival_airport, a2.latitude as latitude_arrival_airport,
concat(f.departure_airport, '-', f.arrival_airport) as "маршрут", sum(tf.amount) over (partition by tf.flight_id order by tf.flight_id),
earth_distance(ll_to_earth(a1.latitude, a1.longitude), ll_to_earth(a2.latitude, a2.longitude))/1000 as distance,
tf.amount / (earth_distance(ll_to_earth(a1.latitude, a1.longitude), ll_to_earth(a2.latitude, a2.longitude))/1000) as "стоимость 1 км"
from flights f
join airports a1 on f.departure_airport=a1.airport_code
join airports a2 on f.arrival_airport=a2.airport_code
join ticket_flights tf on f.flight_id =tf.flight_id
order by 1
)
