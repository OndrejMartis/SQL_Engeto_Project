-- příprava: vytvoření tabulek s daty a pohledy se kterými budu nadále pracovat

CREATE OR REPLACE TABLE t_ondrej_martis_project_sql_primary_final AS
SELECT 
	cp.payroll_year AS measured_year,
	cpib.name, 
	cp.value, 
	'payrolls' AS measured_type
    FROM 
        czechia_payroll cp
    	JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code
    UNION 
    	SELECT 
        	year(cp2.date_from), 
        	cpc.name, 
        	cp2.value, 
        	'foods' AS measured_type
    	FROM 
        	czechia_price cp2
    		JOIN czechia_price_category cpc ON cpc.code = cp2.category_code
    UNION
    	SELECT
        	`year`, 
        	country, 
        	GDP, 
        	'GDP' as measured_type
    	FROM 
        	economies e 
    	WHERE 
        	country = 'Czech Republic'
;
 -- příkaz, kterým vytvořím výslednou tabulku s potřebnými daty

CREATE OR REPLACE TABLE t_ondrej_martis_project_SQL_secondary_final AS 
SELECT 
  e.country, 
  e.`year`, 
  e.GDP, 
  e.gini, 
  e.population 
FROM 
  economies e 
  JOIN countries c ON c.country = e.country 
WHERE 
  c.continent IN ('Europe') 
  AND (`year` BETWEEN 2006 AND 2020) 
  AND e.GDP IS NOT NULL 
  AND e.gini IS NOT NULL
ORDER BY 
  country, 
  `year` ASC; 
  -- příkaz pro vytvoření druhé výsledné tabulky

CREATE OR REPLACE VIEW food_prices_comparsion AS
SELECT 
  name, 
  measured_year, 
  ROUND(AVG(value), 1) AS average_price,
  LEAD(ROUND(AVG(value), 1)) OVER (PARTITION BY name ORDER BY measured_year) AS average_price_next_year
FROM 
  t_ondrej_martis_project_sql_primary_final tompspf 
WHERE 
  measured_type LIKE 'foods'
GROUP BY 
  name, 
  measured_year;
 -- pohled pro průměrné ceny + porovnání cen s následujícím rokem


CREATE OR REPLACE VIEW payroll_comparsion AS
SELECT
    name,
    measured_year,
    ROUND(AVG(value), 0) AS average_payroll,
    LEAD(ROUND(AVG(value), 0)) OVER(PARTITION BY name ORDER BY measured_year) AS average_payroll_next_year
FROM
    t_ondrej_martis_project_sql_primary_final tompspf
WHERE
    measured_type LIKE 'payrolls'
GROUP BY
    name, measured_year; 
-- pohled pro průměrné mzdy + porovnání mezd s následujícím rokem

CREATE OR REPLACE VIEW GDP_czechia AS
SELECT
    name,
    measured_year,
    value,
    LEAD(value) OVER(PARTITION BY name ORDER BY measured_year) AS gdp_next_year
FROM
    t_ondrej_martis_project_sql_primary_final tompspf
WHERE
    measured_type LIKE 'GDP';
-- pohled pro GDP + porovnání GDP s následujícím rokem

CREATE OR REPLACE VIEW first_year_food_prices AS
SELECT
    name,
    measured_year,
    average_price
FROM
    food_prices_comparsion fpc
WHERE
    measured_year IN (SELECT MIN(measured_year) FROM food_prices_comparsion fpc2);
 -- pohled s daty za první rok

CREATE OR REPLACE VIEW last_year_food_prices AS
SELECT
    name,
    measured_year,
    average_price
FROM
    food_prices_comparsion fpc
WHERE
    measured_year IN (SELECT MAX(measured_year) FROM food_prices_comparsion fpc2);
 -- pohled s cenami potravin za posledni rok

CREATE OR REPLACE VIEW first_year_payrolls AS
SELECT
    name,
    measured_year,
    average_payroll
FROM
    payroll_comparsion pc
WHERE
    measured_year IN (SELECT MIN(measured_year) FROM payroll_comparsion pc2); 
-- pohled s průměrnými mzdami za první rok

CREATE OR REPLACE VIEW last_year_payrolls AS
SELECT
    name,
    measured_year,
    average_payroll
FROM
    payroll_comparsion pc
WHERE
    measured_year IN (SELECT MAX(measured_year) FROM payroll_comparsion pc2); 
-- pohled s průměrnými mzdami za posledni rok

-- odpověď 1:

SELECT 
    *,
    CASE
        WHEN average_payroll < average_payroll_next_year THEN 'ano'
        WHEN average_payroll > average_payroll_next_year THEN 'ne'
        ELSE 'nelze vypočítat'
    END AS narust,
    ROUND(((average_payroll_next_year - average_payroll) / average_payroll) * 100, 1) AS percentualni_rozdil
FROM 
    payroll_comparsion pc
ORDER BY 
    name, measured_year;
 -- dotaz, který vypíše zda-li v daném roce rostly mzdy v daném odvětví s s meziročním rozdílem vyjádřeným v procentech

SELECT 
    pc.name,
    ROUND(((POWER((lyp.average_payroll / fyp.average_payroll), 1 / COUNT(pc.measured_year)) * 100) - 100), 2) AS percentualni_mezirocni_narust -- průměr z průměrů by vytvořil nepřesný výsledek, proto počítám geometrický průměr, k němu používám funkci POWER, jejíž mocninu určím 1/počet měřených let, čímž vytvořím odmocninu  
FROM 
    payroll_comparsion pc
    JOIN first_year_payrolls fyp ON fyp.name = pc.name
    JOIN last_year_payrolls lyp ON lyp.name = pc.name
GROUP BY 
    name
ORDER BY 
    ROUND(((POWER((lyp.average_payroll / fyp.average_payroll), 1 / COUNT(pc.measured_year)) * 100) - 100), 2);
-- zde za pomoci geometrického průměru vidím jaký byl průměrný meziroční nárůst mezd dle odvětví

-- odpověď 2:

SELECT 
    fpc.name, 
    fpc.measured_year, 
    AVG(fpc.average_price) AS average_price, 
    ROUND(AVG(pc.average_payroll), 0) AS average_payroll,
    ROUND((AVG(pc.average_payroll) / AVG(fpc.average_price)), 0) AS can_buy_for_payroll
FROM 
    food_prices_comparsion fpc 
    JOIN payroll_comparsion pc ON pc.measured_year = fpc.measured_year
WHERE 
    (fpc.name LIKE '%mléko%' OR fpc.name LIKE '%chleb%') AND fpc.measured_year IN (2006, 2018)
GROUP BY 
    fpc.name, fpc.measured_year
ORDER BY 
    measured_year;
/* dotaz kterým vyberu požadované potraviny, první a poslední možný rok měření a spočítám kolik jednotek dané potraviny
je možné koupit za průměrnou mzdu v daném roce */

-- odpověď 3:

CREATE OR REPLACE VIEW average_prices_yearly_growth AS
SELECT 
	fyfp.name, 
	ROUND(((POWER((lyfp.average_price/fyfp.average_price), 1/COUNT(fpc.measured_year))*100)-100), 2) AS percentualni_mezirocni_narust
FROM 
	food_prices_comparsion fpc 
	JOIN first_year_food_prices fyfp ON fyfp.name = fpc.name 
	JOIN last_year_food_prices lyfp ON lyfp.name = fpc.name
GROUP BY 
	name
ORDER BY 
	ROUND(((POWER((lyfp.average_price/fyfp.average_price), 1/COUNT(fpc.measured_year))*100)-100),2) ASC;
/* dotaz používající data z pohledů za první a poslední rok, ve kterém spočítám geometrický průměr - poslední měřená hodnota
dělena počáteční hodnotou, odmocněná počtem měřených let, vyjádřená v procentech, pro doslovnou odpověď si z dotazu vytvořím pohled */
	
SELECT *
FROM 
	average_prices_yearly_growth apyg 
WHERE 
	percentualni_mezirocni_narust > 0
ORDER BY 
	percentualni_mezirocni_narust ASC
LIMIT 1;
 -- zde si už jednoduše zobrazím která z potravin zdražovala v průběhu let nejpomaleji


-- odpověď 4:

CREATE OR REPLACE VIEW payrolls_prices_yearly_growth AS
SELECT 
    fpc.measured_year, 
    round(((pc.average_payroll_next_year - pc.average_payroll)/pc.average_payroll)*100, 1) AS percentualni_rozdil_payrolls,
    round(((fpc.average_price_next_year - fpc.average_price)/fpc.average_price)*100, 1) AS percentualni_rozdil_food_prices
FROM 
	food_prices_comparsion fpc 
	JOIN payroll_comparsion pc ON pc.measured_year = fpc.measured_year
GROUP BY 
	fpc.measured_year;
 -- pohled zobrazující percentuální rozdíly cen potravin a mezd podle let

SELECT 
    *, 
    (percentualni_rozdil_food_prices - percentualni_rozdil_payrolls) AS rozdil
FROM 
	payrolls_prices_yearly_growth ppyg 
WHERE 
	(percentualni_rozdil_food_prices - percentualni_rozdil_payrolls) > 10;
 -- dotaz kterým získám odpověď je-li otázka brána doslovně, tak nebyl žádný rok, kdy by ceny rostly o 10% více než mzdy, avšak v letech 2008 a 2016 se propadly výrazně méně než mzdy


-- odpověď 5:

SELECT 
	fpc.measured_year,
	ROUND(gc.value, 0) AS GDP,
	ROUND(AVG(pc.average_payroll), 1) AS payroll,
	ROUND(AVG(fpc.average_price), 1) AS food_price,
	ROUND((((gc.gdp_next_year - gc.value)/gc.value)*100), 2) AS '%_zmena_gdp_nasledujici_rok',
	ROUND((((pc.average_payroll_next_year - pc.average_payroll)/pc.average_payroll)*100), 2) AS '%_zmena_platu_nasledujici_rok',
	ROUND((((fpc.average_price_next_year - fpc.average_price)/fpc.average_price)*100), 2) AS '%_zmena_cen_nasledujici_rok'
FROM food_prices_comparsion fpc 
	JOIN payroll_comparsion pc ON pc.measured_year = fpc.measured_year 
	JOIN gdp_czechia gc ON gc.measured_year = fpc.measured_year 
GROUP BY 
	fpc.measured_year 
ORDER BY 
	fpc.measured_year ASC;
 
/* dotaz, který mi vypíše procentuální změnu HDP, procentuální změnu průměrných platů a procentuální změnu cen potravin */
