SELECT *
FROM PortfolioProject..CovidDeaths dea


-- Select Data that we are going to be starting with

SELECT continent, location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths dea
WHERE continent IS NOT NULL
ORDER BY 2,3


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


SELECT continent, location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths dea
WHERE location LIKE '%egypt%'
	AND continent IS NOT NULL
ORDER BY 2,3,7


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, (total_cases/population)*100 AS TotalCasesPer
FROM PortfolioProject..CovidDeaths dea
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfection, (MAX(total_cases)/population)*100 AS HighestInfectionRate
FROM PortfolioProject..CovidDeaths dea
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY  HighestInfectionRate DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeath
FROM PortfolioProject..CovidDeaths dea
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY  HighestDeath DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeath
FROM PortfolioProject..CovidDeaths dea
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  HighestDeath DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalNewCases, SUM(CONVERT(INT, new_deaths)) AS TotalNewDeaths, (SUM(CONVERT(INT, new_deaths))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths dea
WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY  HighestDeath DESC


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
				SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location, dea.date)  AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopulationVaccenated AS (
	
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
				SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location, dea.date)  AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (TotalVaccinations/population)*100 AS VacsPercentage
FROM PopulationVaccenated


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE IF EXISTS #PopVacs
CREATE TABLE #PopVacs (
Continent varchar(255),
Location varchar(255),
Date datetime,
Population INT,
New_vaccinationS INT,
TotalVaccinations INT
)

INSERT INTO #PopVacs 

	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
				SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location, dea.date)  AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date =vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (TotalVaccinations/Population)*100 AS VacsPercentage
FROM #PopVacs




-- Creating View to store data for later visualizations

CREATE VIEW PopVacs AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
				SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location, dea.date)  AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date =vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PopVacs















