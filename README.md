# SQL_Engeto_Project
Ahoj, toto je můj první SQL projekt, zde k němu mám pár slov: <br/>
**Ke správné funkci popsaných příkazů nezbytná původní databáze ENGETO**
- V první části "příprava" jsou příkazy pro vytvoření výsledných tabulek a pohledů, které budu následně využívat k zodpovězení stanovených otázek. 
- U každého příkazu je komentář vysvětlující co daný příkaz vykonává. 
- Dále se již budu věnovat konkrétním otázkám. <br/>

## Otázka 1 - Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? 

V sekci **odpověď 1** jsou dva dotazy, jeden pro podrobnější zobrazení výsledků, kde vidíme roční nárůst mezd v jednotlivých oborech v jednotlivých letech.
- Z prvního dotazu můžeme vyvodit odpověď že v průběhu let mzdy rostou i klesají napříč odvětvími.
- Druhý dotaz počítá s celkovým průměrným nárůstem/poklesem mezd v jednotlivých odvětvích, zde na výsledcích vidíme, že mzdy ve všech odvětvích rostly.

## Otázka 2 - Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

V sekci **odpověď 2** nalezneme dotaz, ve kterém vyberu požadované potraviny a požadované období, vydělím průměrnou mzdu průměrnou cenou a získám tak odpověď.
- V roce 2006 bylo možné si pořídit za průměrnou mzdu 1218kg chleba a 1345l mléka, v roce 2018 to bylo 1259kg chleba a 1537l mléka.

## Otázka 3 - Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

V sekci **odpoveď 3** nalezneme dva dotazy - první zobrazí všechny druhy potravin a meziroční nárůst/pokles ceny v procentech, **zde vidíme, že Cukr krystalový a Rajská jablka červená kulatá dokonce v průběhu let zlevnili**, ale pro doslovné odpovězení jsem z dotazu vytvořil pohled, který využiju v druhém dotazu, kde už pouze vyfiltruji jednu potravinu, která měla nejnižší nárůst ceny v průběhu let.
- Nejpomaleji zdražující potravinou byly banány žluté.

## Otázka 4 - Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

V sekci **odpoveď 4** nalezneme dva dotazy, jeden zobrazující rozdíly nárůstu u mezd a cen potravin v celém měřeném období dle let, pro zjednodušení jsem z něj vytvořil pohled,
který využiju v druhém dotazu, kterým si zobrazím všechny roky, ve kterých byl meziroční rozdíl nárůstu cen potravin vyšší než 10%.
- Je-li otázka brána doslovně, tak nebyl žádný rok, ve kterém ceny potravin vzrostly o více než 10% oproti nárůstu mezd, avšak v letech 2008 a 2016 byl propad cen potravin vyrazně nižší než propad mezd.

## Otázka 5 - Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

V sekci **odpověď 5** nalezneme dotaz, který zobrazí rok, HDP, průměrnou mzdu a průměrnou cenu potravin v daném roce. Dále také zobrazí procentuální změny HDP, platů a cen následující rok.
Ve výsledcích tedy vidíme změnu HDP a jakým způsobem na to reagovaly platy a mzdy.
- Z výsledků lze vidět, že zde není zcela jednoznačná odpověď: například v letech 2014 a 2016 HDP narostlo o více než 5% a platy následující rok zaznamenaly nárůst přes 30%, ale podíváme-li se na rok 2013, vidíme, že přestože HDP zaznamenalo nárůst (2,26%), tak průměrné mzdy následující rok klesly, stejné případy jsou i v letech 2015 nebo 2009.
- Ohledně dopadu HDP na ceny potravin lze vyvodit, že změny HDP na ně nemají přímý vliv. V roce 2006 HDP vzrostlo o 5,57%, ceny ve stejném roce o 17,77%, ale například v roce 2016 se ceny propadly a propadaly i následující rok, přestože HDP zanamenalo nárůst přes 5%.

## Tabulka pro data o dalších evropských státech

V sekci **příprava** je také příkaz pro vytvoření druhé požadované tabulky s HDP, GINI koeficientem a populací dalších evropských států. <br/>
Bohužel v dodatečných tabulkách "countries" a "economies" ze kterých jsem sekundární tabulku vytvářel nebyla data k zodpovězení výše vytyčených výzkumných otázek.
