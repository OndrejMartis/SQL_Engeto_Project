
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
	


create view economies_czech_republic as
select * 
from economies e
where country = 'Czech Republic'
; -- pohled pro vyselektování České republiky pro použití informací o GDP do výsledné tabulky 


create or replace table t_ondrej_martis_project_sql_primary_final as
select 
	cp.payroll_year as measured_year,
	cpib.name as branch_name,
	cp.value as average_payroll ,
	cpc.name as food_category, 
	cp2.value as food_price,
	ecr.GDP as GDP
from czechia_payroll cp 
inner join czechia_price cp2 on cp.payroll_year = year(cp2.date_from)
inner join economies_czech_republic ecr on cp.payroll_year = ecr.`year` 
join czechia_payroll_industry_branch cpib on cp.industry_branch_code = cpib.code
join czechia_price_category cpc on cpc.code = cp2.category_code 
; -- výsledná tabulka obsahující požadované informace 





