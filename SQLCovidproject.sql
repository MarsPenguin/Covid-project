SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

-- look up death rate in each country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_rate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- looking at total cases / the population
SELECT location, date, total_cases, population, (total_cases/population)*100 as covidrate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--country with highest infection rate
SELECT location, population, MAX(total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as covidrate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY covidrate desc

--show countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as deathcount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY deathcount desc
--showing the contintents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as deathcount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY deathcount desc

SELECT location, MAX(cast(total_deaths as int)) as deathcount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY deathcount desc

SELECT location, MAX(cast(total_deaths as int)) as deathcount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY deathcount desc

--showing the contintents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as deathcount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY deathcount desc


--Global numbers
SELECT  SUM(new_cases)as total_Case,SUM(cast(new_deaths as int)) as deathCOUNT,
SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as deathpercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 
--48:37
--looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, Cast(vac.new_vaccinations as int) as new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location) as RollingPeopleVaccinated,

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date=vac.date
WHERE dea.continent is not null
ORDER by 2,3
--use cte
With PopvsVac (Continent, Location, Date, Population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date=vac.date
WHERE dea.continent is not null
--ORDER by 2,3
)
Select*,(RollingPeopleVaccinated/Population)*100
From PopvsVac 

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Contintent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date=vac.date
--WHERE dea.continent is not null

Select*,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--creating view to store data for later visulizations
Create View deathcountby_continent as
SELECT continent, MAX(cast(total_deaths as int)) as deathcount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
--ORDER BY deathcount desc