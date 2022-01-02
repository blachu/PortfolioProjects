/* 

TABLEAU PROJECT - Queries

*/

-- 1
SELECT SUM(new_cases) AS Total_Cases, 
	   SUM(new_deaths) AS Total_Deaths, 
	   SUM(new_deaths) / SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null 
ORDER BY 1,2

-- 2
SELECT location, SUM(new_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- 3
SELECT location, population, 
	   MAX(total_cases) AS HighestInfectionCount,  
	   Max((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- 4
SELECT location, population, date, 
	   MAX(total_cases) AS HighestInfectionCount,  
	   Max((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC


/* 

Additional visualizations

*/
