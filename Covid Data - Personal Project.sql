use [Portfolio Project]


-----Select data I'll be using-----
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
order by 1,2

--Total Cases vs Total Deaths--
-- Reflects likelihood of dying if you get covid--
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE location like '%states%'
order by 1,2

--Total Cases vs Population--
--Reflects the % of the population that got infected--
SELECT Location, date, population, total_cases , (total_deaths/population)*100 as DeathPercentage
FROM CovidDeaths$
WHERE location like '%states%'
order by 1,2

--Countries with highest infection Rate compared to population--
SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count , MAX((total_deaths/population)*100) as Percentage_Population_Infected
FROM CovidDeaths$
--WHERE location like '%states%'--
GROUP BY Location, Population
order by Percentage_Population_Infected desc


--Countries with Highest Death Count per population--
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths$
WHERE Continent is not null
GROUP BY Location
order by TotalDeathCount desc

--Deaths by Continent--
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc

--Global Numbers--
SELECT  date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentaje--, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
order by 1,2

-- Total Cases--
SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentaje--, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
order by 1,2

--Join Covid Deaths and Covid Vaccinations--
SELECT *
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
     ON dea.location = vac.location
	 and dea.date = vac.date

--Total Population / Vaccinations
set ansi_warnings off

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated,
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--Use CTE to perform Calculation on Partition By in previous query--
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Using Temp Table to perform Calculation on Partition By in previous query

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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


