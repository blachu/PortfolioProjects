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
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Poland'
-- WHERE continent IS NOT NULL
ORDER BY 1,2

-- TOTAL CASES VERSUS POPULATION: percentage of population infected with covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- HIGHEST INFECTION RATE compared to population by country
SELECT location, population
	, MAX(total_cases) AS HighestInfectionCount
	, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- HIGHEST DEATH COUNT per population by country
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- HIGHEST DEATH COUNT per population by continent
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
	AND location NOT IN ('High income', 'Upper middle income', 'Low income', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL PERSPECTIVE ON DATASET
-- GLOBAL DEATH PERCENTAGE by date
SELECT date
	, SUM(new_cases) AS total_cases
	, SUM(new_deaths) AS total_deaths
	, SUM(new_deaths) / NULLIF( SUM(new_cases), 0) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
	  AND new_cases IS NOT NULL
	  AND new_deaths IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- GLOBAL DEATH PERCENTAGE
SELECT SUM(new_cases) AS total_cases
	, SUM(new_deaths) AS total_deaths
	, SUM(new_deaths) / NULLIF( SUM(new_cases), 0) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
	  AND new_cases IS NOT NULL
	  AND new_deaths IS NOT NULL
ORDER BY 1, 2

-- TOTAL POPULATION VERSUS TOTAL VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   , SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPplVacc
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
	   , SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPplVacc
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPplVacc / population) * 100 AS popVSvac
FROM popVSvac

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
	   , SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPplVacc
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPplVacc / population) * 100 AS popVSvac
FROM #PercentPopVacc

-- VIEW for visualizations
CREATE VIEW PercentPopVacc AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	   , SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPplVacc
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
