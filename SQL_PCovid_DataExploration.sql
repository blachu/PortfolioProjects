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

-- Total Cases vs Total Deaths: Likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Poland'
-- WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population: Percentage of Population infected with covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Countires with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Highest Death Count per Population by Continent
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
