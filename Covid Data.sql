SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccination
--ORDER BY 3,4

--Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total cases vs Total Deaths
--Show likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
--WHERE continent is not null
ORDER BY 1,2

--Looking at Total cases vs population
--Show what percentage of population got covid

SELECT Location, date, population, total_cases,(total_cases/population) * 100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
--WHERE continent is not null
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compated to Population

SELECT Location, population, MAX(cast(total_cases as int)) AS HighestInfectionCount ,MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(NULLIF(CONVERT(float, new_cases), 0))*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP by date
ORDER BY 1,2
--Showing continents with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null AND location not like '% income'
GROUP BY location
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(NULLIF(CONVERT(float, new_cases), 0))*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP by date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
 ON dea.location= vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 2,3


 --USE CTE

 WITH PopvsVac (Continent,Location, Date, Population ,new_vaccinations, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
 ON dea.location= vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
 --ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

 -- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated;

 Create table #PercentPopulationVaccinated 
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
 ON dea.location= vac.location
 and dea.date = vac.date
--WHERE dea.continent is not null
 --ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM  #PercentPopulationVaccinated 


--Create View to store data for later visualizations

Drop view PercentPopulationVaccinated 

Create View PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
 ON dea.location= vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3



