


SELECT *
FROM pproject..['COVID Deaths$']
ORDER BY 3,4

SELECT *
FROM pproject..['COVID Vaccinations$']
ORDER BY 3,4

SELECT Location, 
	Date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM pproject..['COVID Deaths$']
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country

SELECT Location, 
	Date, 
	total_cases, 
	total_deaths, 
	(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM pproject..['COVID Deaths$']
WHERE location like 'United States' 
	AND total_cases IS NOT NULL 
	AND continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population  got COVID

SELECT Location, 
	Date, 
	population, 
	total_cases, 
	(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS CovidAffectedPercentage
FROM pproject..['COVID Deaths$']
WHERE location like 'United States' 
	AND total_cases IS NOT NULL 
	AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, 
	population, 
	MAX(total_cases) as HighestInfectionCount, 
	(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0)) * 100 AS CovidAffectedPercentage
FROM pproject..['COVID Deaths$']
GROUP BY location, population
ORDER BY CovidAffectedPercentage DESC


--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM pproject..['COVID Deaths$']
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing Countries with Highest Death Count

SELECT Location, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM pproject..['COVID Deaths$']
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing Countries with Highest Death Count to Population

SELECT Location, 
       MAX(CAST(total_deaths AS INT)) / NULLIF(CONVERT(FLOAT, MAX(population)), 0)*100 AS DeathCounttoPopRatio
FROM pproject..['COVID Deaths$']
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY DeathCounttoPopRatio DESC;




-- GLOBAL NUMBERS

SELECT Date, 
	SUM(new_cases) AS TotalCases, 
	SUM(cast(new_deaths as int)) as TotalDeaths, 
	SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM pproject..['COVID Deaths$']
WHERE total_Cases is not null AND continent is not null
GROUP BY date
ORDER BY 1,2

SELECT  SUM(new_cases) AS TotalCases, 
	SUM(cast(new_deaths as int)) as TotalDeaths, 
	SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM pproject..['COVID Deaths$']
WHERE total_Cases is not null AND continent is not null
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM pproject..['COVID Deaths$'] dea
JOIN pproject..['COVID Vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM pproject..['COVID Deaths$'] dea
    JOIN pproject..['COVID Vaccinations$'] vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population) as PercentageofPopVaccinated
FROM PopvsVac
ORDER BY Location, Date;


--USE TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM pproject..['COVID Deaths$'] dea
    JOIN pproject..['COVID Vaccinations$'] vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL

	SELECT *, (RollingPeopleVaccinated/Population) as PercentageofPopVaccinated
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
    SELECT dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM pproject..['COVID Deaths$'] dea
    JOIN pproject..['COVID Vaccinations$'] vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL


