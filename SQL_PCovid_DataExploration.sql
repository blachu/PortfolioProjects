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
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select Data
SELECT location, date, total_cases, new_cases,  total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2
