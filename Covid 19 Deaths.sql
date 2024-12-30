SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY country, date


SELECT country, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY country, date


-- Looking at Total Cases vs Total Deaths
SELECT country, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_cases <> 0 AND total_deaths <> 0
ORDER BY country, date


-- Shows the likelihood of dying if you contract Covid in Canada.
SELECT country, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_cases <> 0 AND total_deaths <> 0 AND country = 'Canada'
ORDER BY country, date


-- Lookig at Total Cases vs Population
SELECT country, date, total_cases, population, (total_cases/population) * 100 AS PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY country, date


-- Shows what percentage of population contracted covid in Canada
SELECT country, date, total_cases, population, (total_cases/population) * 100 AS PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE country = 'Canada'
ORDER BY country, date


--Looking at Countries with Highest Infection Rate compared to the Population
SELECT country, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY country, population
ORDER BY PercentofPopulationInfected Desc


-- Showing Countries with Highest Death Rate Percentage
SELECT country, population, MAX(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100 AS PercentofPopulationDied
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY country, population
ORDER BY PercentofPopulationDied Desc


-- Showing Countries with Highest Death Rate per Population
SELECT country, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY country
ORDER BY TotalDeathCount Desc


-- Showing Continents with the Highest Death Count per Population
SELECT continent, MAX(total_deaths) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC


-- Breaking Stats by Continents
SELECT country, MAX(total_deaths) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND total_deaths IS NOT NULL
GROUP BY country 
ORDER BY TotalDeaths DESC


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) <> 0 AND SUM(new_deaths) <> 0
ORDER BY date 


-- Looking at Total Population vs Vaccination
SELECT DEA.continent, DEA.country, DEA.date, DEA.population, VAC.new_vaccinations
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.country = VAC.country
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY country, date



--USE CTE
WITH PopvVac (continent, country, date, population, new_vaccinations, RollingCount)
as
(
SELECT DEA.continent, DEA.country, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS FLOAT)) OVER (PARTITION BY DEA.country ORDER BY DEA.country, DEA.date) AS RollingCount
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.country = VAC.country
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
GROUP BY DEA.continent, DEA.country, DEA.date, DEA.population, VAC.new_vaccinations
)
SELECT *, (RollingCount/population)*100 AS PopulationVaccinated
FROM PopvVac
ORDER BY country, date


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Country nvarchar(255),
Date datetime,
Population numeric,
NewVaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.country, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS FLOAT)) OVER (PARTITION BY DEA.country ORDER BY DEA.country, DEA.date) AS RollingCount
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.country = VAC.country
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
GROUP BY DEA.continent, DEA.country, DEA.date, DEA.population, VAC.new_vaccinations
ORDER BY country, date

SELECT *, (RollingPeopleVaccinated/population)*100 AS PopulationVaccinated
FROM #PercentPopulationVaccinated



-- Creating View to store data later for Visualization
USE PortfolioProject;
GO

CREATE VIEW PercentPopulationVaccinated AS 
SELECT DEA.continent, DEA.country, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS FLOAT)) OVER (PARTITION BY DEA.country ORDER BY DEA.country, DEA.date) AS RollingCount
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.country = VAC.country
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
GO

--Query the View
SELECT continent, country, date, population, new_vaccinations, RollingCount
FROM PercentPopulationVaccinated
ORDER BY country, date