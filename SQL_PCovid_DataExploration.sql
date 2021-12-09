/*
Project scope: COVID-19 data exploration with SQL
Dataset: https://ourworldindata.org/covid-deaths

#1 Getting out dataset:
- move column "population" right behind "date"
- select everything from "new_tests" to the right end of dataset and delete - save as CovidDeaths
- restore that data (ctrl+z). Delete everything between columns "population" and "weekly_hosp_admissions_per_million" - save as CovidVaccinations

#2 Import datasets into SQL
- I had an issue with datasets. Whenever column starts as a blank cell and any values appears after more than just few line (20+), then after data import to SQL it showed that these columns contains only NULL values
- So thing I did (after looking on many-many solutions) was just to add 0 (zeroes) to each blank cells that were at the beggining of columns.  I mean, if on row number 1500 was a blank cell then I did not add any 0 there.
- Another issue - I could not import .xlsx file so to solve it I used SQL Server 20xx Import and Export Data (64-bit)

#3 EXPLORE
*/

-- Looking through, to be sure that everything is fine
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select Data
SELECT location, date, total_cases, new_cases,  total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- TOTAL CASES VERSUS TOTAL DEATHS: likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Poland'
-- WHERE continent IS NOT NULL
ORDER BY 1,2

-- TOTAL CASES VERSUS POPULATION: percentage of population infected with covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- HIGHEST INFECTION RATE compared to population by country
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- HIGHEST DEATH COUNT per population by country
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- HIGHEST DEATH COUNT per population by continent
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT LIKE 'High income' 
AND location NOT LIKE 'Upper middle income'
AND location NOT LIKE 'Lower middle income'
AND location NOT LIKE 'Low income'
AND location NOT LIKE 'International'
GROUP BY location
ORDER BY TotalDeathCount desc


-- GLOBAL PERSPECTIVE ON DATASET
-- GLOBAL DEATH PERCENTAGE by date
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths
		   , SUM(new_deaths) / NULLIF( SUM(new_cases), 0) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
	  AND new_cases IS NOT NULL
	  AND new_deaths IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- GLOBAL DEATH PERCENTAGE
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths
		   , SUM(new_deaths) / NULLIF( SUM(new_cases), 0) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
	  AND new_cases IS NOT NULL
	  AND new_deaths IS NOT NULL
ORDER BY 1, 2

-- TOTAL POPULATION VERSUS TOTAL VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   , SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPplVacc
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Had to chunk column cause of error in previous query to execute that query
ALTER TABLE dbo.CovidDeaths
ALTER COLUMN location nvarchar(180)

-- CTE - to calculate on PARTITON BY in previous query
WITH popVSvac (continent, location, date, population, new_vaccinations, RollingPplVacc) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   , SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPplVacc
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
Select *, (RollingPplVacc / population) * 100 AS popVSvac
From popVSvac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopVacc
CREATE TABLE #PercentPopVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPplVacc numeric
)

INSERT INTO #PercentPopVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   , SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPplVacc
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPplVacc / population) * 100 AS popVSvac
FROM #PercentPopVacc

-- VIEW for visualizations
CREATE VIEW PercentPopVacc AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   , SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPplVacc
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
