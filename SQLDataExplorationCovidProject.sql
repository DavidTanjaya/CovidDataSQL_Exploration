-- Looking for all data has imported
SELECT TOP 100 *
FROM CovidProject..CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM CovidProject..CovidVaccinations
--ORDER BY 3,4;


-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY 1,2;

--Looking at Total cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases) * 100 , 2) AS DeathPercentage
FROM CovidProject..CovidDeaths
ORDER BY 1,2;

-- Now i want to get to know in Indonesia where i live in
SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases) * 100 , 2) AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location = 'Indonesia'
ORDER BY 1,2;

-- Comparison between total cases vs population
SELECT location, MAX(total_cases) AS Infected, population, ROUND((MAX(total_cases)/population) *100 , 2) AS InfectedPercentage
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC;
-- from this query i get the highest infected by covid over population is 72% in Cyprus 
-- it means 7 from 10 person get infected by covid in Cyprus


--Showing Countires with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL --this for world and continent not included
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Show the global number, how many people on earth have infected each day
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death,
ROUND((SUM(CAST(new_deaths as int))/SUM(New_cases) * 100),2) as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

-- show total a cross the world
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death,
ROUND((SUM(CAST(new_deaths as int))/SUM(New_cases) * 100),2) as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1;


-- Looking at Total Population vs Vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER (PARTITION BY d.location
ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS PeopleVaccinatedEachDay
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

-- now i want to calculate the how many percentage people vaccinated each day per population
-- it become easier with CTE to calculate it from previous query

WITH PeopleVac (continent, location, date, population, new_vaccinations, CountPeopleVaccinatedEachDay)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER (PARTITION BY d.location
ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS CountPeopleVaccinatedEachDay
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, ROUND((CountPeopleVaccinatedEachDay / population) * 100 , 2)
FROM PeopleVac


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CountPeopleVaccinatedEachDay numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER (PARTITION BY d.location
ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS CountPeopleVaccinatedEachDay
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
--WHERE d.continent IS NOT NULL

Select *, (CountPeopleVaccinatedEachDay/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data 

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER (PARTITION BY d.location
ORDER BY d.location, d.date ROWS UNBOUNDED PRECEDING) AS CountPeopleVaccinatedEachDay
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT TOP (1000)*
FROM CovidProject.dbo.PercentPopulationVaccinated









