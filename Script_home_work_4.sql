--=============== МОДУЛЬ 4. УГЛУБЛЕНИЕ В SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаёте новую схему с префиксом в --виде фамилии, название должно быть на латинице в нижнем регистре и таблицы создаете --в этой новой схеме, если подключение к локальному серверу, то создаёте новую схему и --в ней создаёте таблицы.
create database Homework_4

create schema Hm_w_4

set search_path to Hm_w_4


--Спроектируйте базу данных, содержащую три справочника:
--· язык (английский, французский и т. п.);
--· народность (славяне, англосаксы и т. п.);
--· страны (Россия, Германия и т. п.).
--Две таблицы со связями: язык-народность и народность-страна, отношения многие ко многим. Пример таблицы со связями — film_actor.
--Требования к таблицам-справочникам:
--· наличие ограничений первичных ключей.
--· идентификатору сущности должен присваиваться автоинкрементом;
--· наименования сущностей не должны содержать null-значения, не должны допускаться --дубликаты в названиях сущностей.
--Требования к таблицам со связями:
--· наличие ограничений первичных и внешних ключей.

--В качестве ответа на задание пришлите запросы создания таблиц и запросы по --добавлению в каждую таблицу по 5 строк с данными.
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
create table language (
	language_id serial primary key,
	language_name varchar(50) not null unique)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
select * from "language"
	
insert into "language" (language_name)
values ('Английский'), ('Французский'), ('Русский'), ('Японский'), ('Немецкий')

insert into "language" (language_name)
values ('Немецкий')


--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ
create table nation (
	nation_id serial primary key,
	nation_name varchar(50) not null unique)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ
select * from "nation"
	
insert into "nation" (nation_name)
values ('Славяне'), ('Англосаксы'), ('Азиаты'), ('Немцы')

insert into "nation" (nation_name)
values ('Французы')


--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
create table country (
	country_id serial primary key,
	country_name varchar(50) not null unique)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ
select * from "country"

insert into "country" (country_name)
values ('Россия'), ('Великобритания'), ('Франция'), ('Япония')

insert into "country" (country_name)
values ('Германия')


--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table language_nation (
	language_id int references language(language_id),
	nation_id int references nation(nation_id),
	primary key (language_id, nation_id))
	
alter table "language" add constraint language_nation_fkey foreign key (nation_id) references nation(nation_id)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
select *
from language_nation

insert into language_nation (language_id, nation_id)
values(
1,	1)

insert into language_nation (language_id, nation_id)
values(
1,	2)

insert into language_nation (language_id, nation_id)
values(
1,	3)

insert into language_nation (language_id, nation_id)
values(
1,	4)

insert into language_nation (language_id, nation_id)
values(
1,	5)

insert into language_nation (language_id, nation_id)
values(
2,	1)

insert into language_nation (language_id, nation_id)
values(
2,	2)

insert into language_nation (language_id, nation_id)
values(
2,	3)

insert into language_nation (language_id, nation_id)
values(
2,	4)

insert into language_nation (language_id, nation_id)
values(
2,	5)

insert into language_nation (language_id, nation_id)
values(
3,	1)

insert into language_nation (language_id, nation_id)
values(
3,	2)

insert into language_nation (language_id, nation_id)
values(
3,	3)

insert into language_nation (language_id, nation_id)
values(
3,	4)

insert into language_nation (language_id, nation_id)
values(
3,	5)

insert into language_nation (language_id, nation_id)
values(
4,	1)

insert into language_nation (language_id, nation_id)
values(
4,	2)

insert into language_nation (language_id, nation_id)
values(
4,	3)

insert into language_nation (language_id, nation_id)
values(
4,	4)

insert into language_nation (language_id, nation_id)
values(
4,	5)

insert into language_nation (language_id, nation_id)
values(
8,	1)

insert into language_nation (language_id, nation_id)
values(
8,	2)

insert into language_nation (language_id, nation_id)
values(
8,	3)

insert into language_nation (language_id, nation_id)
values(
8,	4)

insert into language_nation (language_id, nation_id)
values(
8,	5)


--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table nation_country (
	nation_id int references nation(nation_id),
	country_id int references country(country_id),
	primary key (nation_id, country_id))
	
alter table nation add constraint nation_country_fkey foreign key (country_id) references country(country_id)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
select *
from nation_country


insert into nation_country (nation_id, country_id)
values(
1,	1)

insert into nation_country (nation_id, country_id)
values(
1,	2)

insert into nation_country (nation_id, country_id)
values(
1,	3)

insert into nation_country (nation_id, country_id)
values(
1,	4)

insert into nation_country (nation_id, country_id)
values(
1,	5)

insert into nation_country (nation_id, country_id)
values(
2,	1)

insert into nation_country (nation_id, country_id)
values(
2,	2)

insert into nation_country (nation_id, country_id)
values(
2,	3)

insert into nation_country (nation_id, country_id)
values(
2,	4)

insert into nation_country (nation_id, country_id)
values(
2,	5)

insert into nation_country (nation_id, country_id)
values(
3,	1)

insert into nation_country (nation_id, country_id)
values(
3,	2)

insert into nation_country (nation_id, country_id)
values(
3,	3)

insert into nation_country (nation_id, country_id)
values(
3,	4)

insert into nation_country (nation_id, country_id)
values(
3,	5)

insert into nation_country (nation_id, country_id)
values(
4,	1)

insert into nation_country (nation_id, country_id)
values(
4,	2)

insert into nation_country (nation_id, country_id)
values(
4,	3)

insert into nation_country (nation_id, country_id)
values(
4,	4)

insert into nation_country (nation_id, country_id)
values(
4,	5)

insert into nation_country (nation_id, country_id)
values(
5,	1)

insert into nation_country (nation_id, country_id)
values(
5,	2)

insert into nation_country (nation_id, country_id)
values(
5,	3)

insert into nation_country (nation_id, country_id)
values(
5,	4)

insert into nation_country (nation_id, country_id)
values(
5,	5)

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============


--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.
create table film_new (
	film_id serial primary key,
	film_name varchar(255) not null,
	film_year integer check(film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration integer not null check(film_duration > 0))


--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]
insert into film_new(film_name, film_year, film_rental_rate, film_duration)
select *
from unnest(
	array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List'],
	array[1994, 1999, 1985, 1994, 1993],
	array[2.99, 0.99, 1.99, 2.99, 3.99],
	array[142, 189, 116, 142, 195])
	
select * from film_new


--ЗАДАНИЕ №3
--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41
update film_new
set film_rental_rate = film_rental_rate + 1.41


--ЗАДАНИЕ №4
--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new
delete from film_new
where film_id = 3


--ЗАДАНИЕ №5
--Добавьте в таблицу film_new запись о любом другом новом фильме
insert into film_new(film_name, film_year, film_rental_rate, film_duration)
values ('Dune', 2021, 6.2, 156)


--ЗАДАНИЕ №6
--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых
select *, round(film_duration / 60., 1) as "длительность фильма в часах"
from film_new


--ЗАДАНИЕ №7 
--Удалите таблицу film_new
drop table film_new