/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY
  3,4


-- Select Data that we are going to be starting with

SELECT
  Location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY
  1, 2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT
  Location,
  date,
  total_cases,
  total_deaths,
  (
    CAST(total_deaths AS INT) / CAST(total_cases AS INT)
  ) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE
  location LIKE '%states%'
  AND continent IS NOT NULL
ORDER BY
  1,
  2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT
  Location,
  date,
  Population,
  total_cases,
  (total_cases / population) * 100 AS PercentPopulationInfected
FROM
  PortfolioProject..CovidDeaths --Where location like '%states%'
ORDER BY
  1,
  2


-- Countries with Highest Infection Rate compared to Population

SELECT
  Location,
  Population,
  MAX(total_cases) AS HighestInfectionCount,
  Max((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
  PortfolioProject..CovidDeaths --Where location like '%states%'
GROUP BY
  Location,
  Population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT
  Location,
  MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM
  PortfolioProject..CovidDeaths --Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT
  continent,
  MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM
  PortfolioProject..CovidDeaths --Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT
  SUM(new_cases) AS total_cases,
  SUM(CAST(new_deaths AS INT)) AS total_deaths,
  SUM(CAST(new_deaths AS INT)) / SUM(New_Cases) * 100 AS DeathPercentage
FROM
  PortfolioProject..CovidDeaths --Where location like '%states%'
WHERE continent IS NOT NULL --Group By date
ORDER BY
  1,
  2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (
    PARTITION BY dea.Location
    ORDER BY
      dea.location,
      dea.Date
  ) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
  JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY
  2,
  3


-- Using CTE to perform Calculation on Partition By in previous query
-- Showing the percentage of population that is already vaccinated
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(INT, vac.new_vaccinations)) OVER (
    PARTITION BY dea.Location
    ORDER BY
      dea.location,
      dea.Date
  ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
  JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
