SELECT *
FROM [Portfolio Project]..coviddeaths$
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project]..covidvacinations$
--ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT Location, Date, total_cases, new_cases,total_deaths,population
FROM [Portfolio Project].. coviddeaths$
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood if you contract covid in your country

SELECT Location, Date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project].. coviddeaths$
WHERE location like '%states%'
AND continent is not NULL
ORDER BY 1,2

--Looking at the Total cases vs Total Population
-- Shows what percentage of population got Covid
SELECT Location, Date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project].. coviddeaths$
WHERE location like '%states%'
AND continent is not NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, max(total_cases) AS HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project].. coviddeaths$
WHERE Continent is not NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM[Portfolio Project]..coviddeaths$
WHERE Continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount desc 

--Lets break things down by continents 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM[Portfolio Project]..coviddeaths$
WHERE Continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc 


-- Showing the Continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM[Portfolio Project]..coviddeaths$
WHERE Continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc 

--GLOBAL NUMBERS 
 SELECT SUM(new_cases) AS totalcases_perday, sum(cast(new_deaths as int)) AS totaldeath_perday, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 FROM [Portfolio Project]..coviddeaths$
 WHERE continent is not null
 ORDER BY 1,2

 
-- Global numbers of total cases and deaths per day

 SELECT date,SUM(new_cases) AS totalcases_perday, sum(cast(new_deaths as int)) AS totaldeath_perday, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 FROM [Portfolio Project]..coviddeaths$
 WHERE continent is not null
 GROUP by date
 ORDER BY 1,2

 -- Looking at Total Population vs Vaccinations 
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].. coviddeaths$ dea
Join [Portfolio Project].. covidvacinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--AND vac.new_vaccinations is not null
ORDER BY 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
As 
(
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].. coviddeaths$ dea
Join [Portfolio Project].. covidvacinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--AND vac.new_vaccinations is not null
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].. coviddeaths$ dea
Join [Portfolio Project].. covidvacinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--CREATING View to store data for later visualizations
Create View PercentPopulationVaccinated as

SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].. coviddeaths$ dea
Join [Portfolio Project].. covidvacinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated