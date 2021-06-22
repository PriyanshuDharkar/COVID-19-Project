USE Project
SELECT *
FROM Project..CovidDeaths
WHERE continent IS NOT Null
ORDER BY 3,4

SELECT *
FROM Project..CovidDeaths
WHERE continent IS NOT Null
ORDER BY 3,4

--Data we need

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project..CovidDeaths
WHERE continent IS NOT Null
ORDER BY 1,2

-- Looking at Total cases vs Total deaths in your country

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Project..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

--Total case vs Total population
-- percentage of population getting covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS infected_percentage
FROM Project..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population 

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS infected_percentage
FROM Project..CovidDeaths
WHERE continent IS NOT Null
GROUP BY location, population
ORDER BY 4 DESC

-- Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count
FROM Project..CovidDeaths
WHERE continent IS NOT Null
GROUP BY location
ORDER BY 2 DESC

-- Breaking down by continent

SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count
FROM Project..CovidDeaths
WHERE continent IS Null
GROUP BY location
ORDER BY 2 DESC

-- Global death percentage by dates

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM Project..CovidDeaths
WHERE Continent IS NOT Null
GROUP BY date
ORDER BY 1,2

--Global death percentage

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM Project..CovidDeaths
WHERE Continent IS NOT Null
ORDER BY 1,2

-- Total population vs total vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int))OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT Null
ORDER BY 2,3

--Using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int))OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT Null
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 AS vaccinated_percentage
FROM PopvsVac

--Using new table

CREATE TABLE percent_population_vaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
INSERT INTO percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int))OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT Null
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100 AS vaccinated_percentage
FROM percent_population_vaccinated

