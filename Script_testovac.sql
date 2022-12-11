
SELECT o.product_id, o.customer_id, o.status, c.firstName, c.lastName 
FROM orders AS o
INNER JOIN customers AS c ON o.customer_id = c.id;

SELECT o.product_id, o.customer_id, o.status, c.firstName, c.lastName
FROM orders AS o
LEFT JOIN customers AS c ON o.customer_id = c.id;

SELECT o.product_id, o.customer_id, o.status, c.firstName, c.lastName
FROM orders AS o
RIGHT JOIN customers AS c ON o.customer_id = c.id;

select Name, Population 
from country c 
order by Population desc
limit 5;

select GovernmentForm, count(GovernmentForm) as Počet,
avg(LifeExpectancy) as "Průměrná délka života" 
from country c 
where LifeExpectancy > 78
group by GovernmentForm ;

select c.Name as Stát , c2.District as Kraj  
from country as c
join city as c2 on c.Code = c2.CountryCode 
where c2.Name = 'Serravalle';

create or replace view last_year_food_prices as
select name, average_price 
from food_prices_comparsion fpc
where comparsion_year in (select max(comparsion_year) from food_prices_comparsion fpc2);

create or replace view first_year_food_prices as
select name, average_price 
from food_prices_comparsion fpc
where comparsion_year in (select min(comparsion_year) from food_prices_comparsion fpc2);


select fyfp.name, 
	round(((power
	((lyfp.average_price/fyfp.average_price), 1/count(fpc.comparsion_year)  
	)-1)*100),2) as percentualni_narust_final 
from food_prices_comparsion fpc 
join first_year_food_prices fyfp on fyfp.name = fpc.name 
join last_year_food_prices lyfp on lyfp.name = fpc.name
group by name
order by round(((power
	((lyfp.average_price/fyfp.average_price), 1/count(fpc.comparsion_year)  
	)-1)*100),2) asc ;
	


create table ondramartis_test_table as;

create view economies_czech_republic as
select * 
from economies e
where country = 'Czech Republic'; 

create table ondramartis_test_table as;
select * 
from czechia_payroll cp 
cross join czechia_price cp2
cross join economies_czech_republic ecr 
join czechia_payroll_industry_branch cpib on cp.industry_branch_code = cpib.code
join czechia_price_category cpc on cpc.code = cp2.category_code 
;