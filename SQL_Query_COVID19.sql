-- Alter data types & Replace NULL values with 0
ALTER TABLE Portfolio_Prjoect_COVID19..COVID
ALTER COLUMN total_deaths BIGINT;
ALTER TABLE Portfolio_Prjoect_COVID19..COVID
ALTER COLUMN new_deaths BIGINT;
ALTER TABLE Portfolio_Prjoect_COVID19..COVID
ALTER COLUMN people_fully_vaccinated FLOAT;
ALTER TABLE Portfolio_Prjoect_COVID19..COVID
ALTER COLUMN new_vaccinations BIGINT;
ALTER TABLE Portfolio_Prjoect_COVID19..COVID
ALTER COLUMN female_smokers FLOAT;
ALTER TABLE Portfolio_Prjoect_COVID19..COVID
ALTER COLUMN male_smokers FLOAT;
UPDATE Portfolio_Prjoect_COVID19..COVID
SET total_cases = 0
WHERE total_cases IS NULL
UPDATE Portfolio_Prjoect_COVID19..COVID
SET new_cases = 0
WHERE new_cases IS NULL	
UPDATE Portfolio_Prjoect_COVID19..COVID
SET total_deaths = 0
WHERE total_deaths IS NULL	
UPDATE Portfolio_Prjoect_COVID19..COVID
SET new_deaths = 0
WHERE new_deaths IS NULL	
UPDATE Portfolio_Prjoect_COVID19..COVID
SET total_vaccinations = 0
WHERE total_vaccinations IS NULL
UPDATE Portfolio_Prjoect_COVID19..COVID
SET people_fully_vaccinated = 0
WHERE people_fully_vaccinated IS NULL
UPDATE Portfolio_Prjoect_COVID19..COVID
SET new_vaccinations = 0
WHERE new_vaccinations IS NULL
UPDATE Portfolio_Prjoect_COVID19..COVID
SET stringency_index = 0
WHERE stringency_index IS NULL
UPDATE Portfolio_Prjoect_COVID19..COVID
SET population_density = 0
WHERE population_density IS NULL





-- 1. Acquire basic information of the 5 countries
SELECT 
	location, 
	date,
	new_cases,
	new_deaths,
	total_deaths,
	total_cases, 
	population,
	(total_cases/population*100) AS infection_rate_percentage,
	(total_deaths/NULLIF(total_cases, 0)*100) AS death_rate_percentage,
	people_fully_vaccinated
FROM Portfolio_Prjoect_COVID19..COVID
WHERE location IN ('United States', 'United Kingdom', 'Singapore', 'Japan', 'South Korea')
ORDER BY 1,2





-- 2. Find more info of the 5 countries
SELECT
	location, 
	date,
	stringency_index,
	population_density,
	gdp_per_capita,
	cardiovasc_death_rate,
	diabetes_prevalence,
	(female_smokers+male_smokers) AS poulation_smoking_percentage, 
	population*(female_smokers+male_smokers)/100 AS population_smoking,
	aged_65_older AS aged_65_older_percentage,
	(population*aged_65_older/100) AS population_age_65_older
FROM Portfolio_Prjoect_COVID19..COVID
WHERE location IN ('United States', 'United Kingdom', 'Singapore', 'Japan', 'South Korea')
ORDER BY 1,2





-- 3. Aquire info from all continents
WITH table2 AS 
(
SELECT 
	continent,
	location, 
	date, 
	population,
	new_cases,
	SUM(new_cases) OVER (PARTITION BY location ORDER BY location, date ROWS UNBOUNDED PRECEDING) AS running_total_cases,
	new_deaths,
	SUM(new_deaths) OVER (PARTITION BY location ORDER BY location, date ROWS UNBOUNDED PRECEDING) AS running_total_deaths,
	people_fully_vaccinated
FROM Portfolio_Prjoect_COVID19..COVID
GROUP BY continent, location, date, new_cases, new_deaths, population, people_fully_vaccinated
HAVING continent IS NULL 
AND 
location IN ('Asia', 'North America', 'Africa', 'Oceania','Europe', 'South America')
)
SELECT
	location AS continent, 
	date, 
	new_cases,
	running_total_cases,
	new_deaths,
	running_total_deaths,
	(running_total_cases/population)*100 AS infection_rate_percentage,
	(running_total_deaths/NULLIF(running_total_cases,0))*100 AS death_rate_percentage,
	people_fully_vaccinated
FROM table2
ORDER BY 1,2






-- 4. Extract more info
select 
	location, 
	date, 
	people_fully_vaccinated
FROM Portfolio_Prjoect_COVID19..COVID
WHERE continent IS NULL 
AND 
location IN ('Asia', 'North America', 'Africa', 'Oceania','Europe', 'South America')
order by 1,2




-- 5. Global Numbers
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	population,
	(total_cases/population)*100 AS infection_rate,
	(total_deaths/total_cases)*100 AS death_rate
FROM Portfolio_Prjoect_COVID19..COVID
WHERE continent IS NULL AND location = 'World'
ORDER BY 1,2