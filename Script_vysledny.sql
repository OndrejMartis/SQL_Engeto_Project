-- příprava: vytvoření tabulek s daty a pohledy se kterými budu nadále pracovat

create or replace table t_ondrej_martis_project_sql_primary_final as
select
 cp.payroll_year as measured_year, cpib.name, cp.value, 'payrolls' as measured_type
from czechia_payroll cp
join czechia_payroll_industry_branch cpib on cp.industry_branch_code = cpib.code
union 
select year(cp2.date_from), cpc.name, cp2.value, 'foods' as measured_type
from czechia_price cp2
join czechia_price_category cpc on cpc.code = cp2.category_code
union
select `year`, country, GDP, 'GDP' as measured_type
from economies e 
where country = 'Czech Republic';
; -- příkaz, kterým vytvořím výslednou tabulku s potřebnými daty

CREATE OR REPLACE TABLE t_ondrej_martis_project_SQL_secondary_final as
SELECT e.country, e.`year`, e.GDP, e.gini, e.population 
FROM economies e 
JOIN countries c ON c.country = e.country 
WHERE c.continent IN ('Europe') AND (`year` BETWEEN 2006 AND 2020) AND e.GDP IS NOT NULL AND e.gini IS NOT NULL
ORDER BY country, `year` asc ; -- příkaz pro vytvoření druhé výsledné tabulky

create or replace view food_prices_comparsion as
select 
	name, 
	measured_year, 
	round(avg(value), 1) as average_price,
	lead(round(avg(value), 1)) over(partition by name order by measured_year) as average_price_next_year
from t_ondrej_martis_project_sql_primary_final tompspf 
where measured_type like 'foods'
group by name, measured_year; -- pohled pro průměrné ceny + porovnání cen s následujícím rokem


create or replace view payroll_comparsion as
select 
	name, 
	measured_year, 
	round(avg(value), 0) as average_payroll,
	lead(round(avg(value), 0)) over(partition by name order by measured_year) as average_payroll_next_year
from t_ondrej_martis_project_sql_primary_final tompspf 
where measured_type like 'payrolls'
group by name, measured_year; -- pohled pro průměrné mzdy + porovnání mezd s následujícím rokem

create or replace view GDP_czechia as
select 
	name, 
	measured_year, 
	value,
	lead(value) over(partition by name order by measured_year) as gdp_next_year
from t_ondrej_martis_project_sql_primary_final tompspf 
where measured_type like 'GDP'; -- pohled pro GDP + porovnání GDP s následujícím rokem

create or replace view first_year_food_prices as
select name, measured_year, average_price 
from food_prices_comparsion fpc
where measured_year in (select min(measured_year) from food_prices_comparsion fpc2); -- pohled s daty za první rok

create or replace view last_year_food_prices as
select name, measured_year, average_price 
from food_prices_comparsion fpc
where measured_year in (select max(measured_year) from food_prices_comparsion fpc2); -- pohled s cenami potravin za posledni rok

create or replace view first_year_payrolls as
select name, measured_year, average_payroll 
from payroll_comparsion pc 
where measured_year in (select min(measured_year) from payroll_comparsion pc2); -- pohled s průměrnými mzdami za první rok

create or replace view last_year_payrolls as
select name, measured_year, average_payroll 
from payroll_comparsion pc 
where measured_year in (select max(measured_year) from payroll_comparsion pc2); -- pohled s průměrnými mzdami za posledni rok

-- odpověď 1:

select *, 
case 
when average_payroll < average_payroll_next_year then 'ano'
when average_payroll > average_payroll_next_year then 'ne'
else 'nelze vypočítat'
end as narust,
round(((average_payroll_next_year - average_payroll)/average_payroll)*100, 1) as percentualni_rozdil
from payroll_comparsion pc
order by name, measured_year; -- dotaz, který vypíše zda-li v daném roce rostly mzdy v daném odvětví s s meziročním rozdílem vyjádřeným v procentech

select
	pc.name,
	round(((power((lyp.average_payroll/fyp.average_payroll), 1/count(pc.measured_year))*100)-100), 2) as percentualni_mezirocni_narust
from payroll_comparsion pc 
join first_year_payrolls fyp on fyp.name = pc.name
join last_year_payrolls lyp on lyp.name = pc.name
group by name
order by round(((power((lyp.average_payroll/fyp.average_payroll), 1/count(pc.measured_year))*100)-100), 2); /* zde za pomoci geometrického průměru vidím
jaký byl průměrný meziroční nárůst mezd dle odvětví */

-- odpověď 2:

select 
	fpc.name, 
	fpc.measured_year, 
	avg(fpc.average_price) AS average_price, 
	round(avg(pc.average_payroll), 0) AS average_payroll,
	round((avg(pc.average_payroll)/avg(fpc.average_price)), 0) as can_buy_for_payroll
from food_prices_comparsion fpc 
join payroll_comparsion pc on pc.measured_year = fpc.measured_year
where (fpc.name like '%mléko%' or fpc.name like '%chleb%') and fpc.measured_year in (2006, 2018)
group by fpc.name, fpc.measured_year
order by measured_year;/* dotaz kterým vyberu požadované potraviny, první a poslední možný rok měření a spočítám kolik jednotek dané potraviny
je možné koupit za průměrnou mzdu v daném roce */

-- odpověď 3:

create or replace view average_prices_yearly_growth AS
select fyfp.name, 
	round(((power
	((lyfp.average_price/fyfp.average_price), 1/count(fpc.measured_year)  
	)*100)-100),2) as percentualni_mezirocni_narust
from food_prices_comparsion fpc 
join first_year_food_prices fyfp on fyfp.name = fpc.name 
join last_year_food_prices lyfp on lyfp.name = fpc.name
group by name
order by round(((power
	((lyfp.average_price/fyfp.average_price), 1/count(fpc.measured_year)  
	)*100)-100),2) asc; /* dotaz používající data z pohledů za první a poslední rok, ve kterém spočítám geometrický průměr - poslední měřená hodnota
	dělena počáteční hodnotou, odmocněná počtem měřených let, vyjádřená v procentech, pro doslovnou odpověď si z dotazu vytvořím pohled */
	
select *
from average_prices_yearly_growth apyg 
where percentualni_mezirocni_narust > 0
order by percentualni_mezirocni_narust asc
limit 1; -- zde si už jednoduše zobrazím která z potravin zdražovala v průběhu let nejpomaleji


-- odpověď 4:

CREATE OR REPLACE VIEW payrolls_prices_yearly_growth AS
SELECT 
	fpc.measured_year, 
	round(((pc.average_payroll_next_year - pc.average_payroll)/pc.average_payroll)*100, 1) AS percentualni_rozdil_payrolls,
	round(((fpc.average_price_next_year - fpc.average_price)/fpc.average_price)*100, 1) AS percentualni_rozdil_food_prices
FROM food_prices_comparsion fpc 
JOIN payroll_comparsion pc ON pc.measured_year = fpc.measured_year
GROUP BY fpc.measured_year; -- pohled zobrazující percentuální rozdíly cen potravin a mezd podle let

select *, (percentualni_rozdil_food_prices - percentualni_rozdil_payrolls) as rozdil  
from payrolls_prices_yearly_growth ppyg 
where (percentualni_rozdil_food_prices - percentualni_rozdil_payrolls) > 10; /* dotaz kterým získám odpověď 
je-li otázka brána doslovně, tak nebyl žádný rok, kdy by ceny rostly o 10% více než mzdy, avšak v letech 2008 a 2016 se propadly výrazně méně než mzdy*/


-- odpověď 5:

select 
	fpc.measured_year,
	round(gc.value, 0) as GDP,
	round(avg(pc.average_payroll), 1) as payroll,
	round(avg(fpc.average_price), 1) as food_price,
	round((((gc.gdp_next_year - gc.value)/gc.value)*100), 2) as '%_zmena_gdp_nasledujici_rok',
	round((((pc.average_payroll_next_year - pc.average_payroll)/pc.average_payroll)*100), 2) as '%_zmena_platu_nasledujici_rok',
	round((((fpc.average_price_next_year - fpc.average_price)/fpc.average_price)*100), 2) as '%_zmena_cen_nasledujici_rok'
from food_prices_comparsion fpc 
join payroll_comparsion pc on pc.measured_year = fpc.measured_year 
join gdp_czechia gc on gc.measured_year = fpc.measured_year 
group by fpc.measured_year 
order by fpc.measured_year asc; /* dotaz, který mi vypíše procentuální změnu HDP, procentuální změnu průměrných platů a procentuální změnu cen potravin */




















