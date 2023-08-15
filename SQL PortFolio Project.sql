Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total cases vs Total deaths in India


select Location, date, total_cases, total_deaths,
CONVERT(DECIMAL(18, 8), (CONVERT(DECIMAL(18, 8), total_deaths) / CONVERT(DECIMAL(18, 8), total_cases)))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where continent is not null
Where location like '%India%'
order by 1,2

--Looking at Percentage of Population infected in world

select Location, date, total_cases, population,
CONVERT(DECIMAL(18, 8), (CONVERT(DECIMAL(18, 8), total_cases) / CONVERT(DECIMAL(18, 8), population)))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population


select Location, population, Max(0 + total_cases) as HighestInfectionCount,
Max((total_cases)/(population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Group by location, population
order by PercentPopulationInfected desc


--Showing countries with Highest Death Count per Population


select Location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break things down by continent
--Showing continents with th3e highest death numbers

select location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is null
Group by location
order by TotalDeathCount desc

--Global Numbers
--Sum of New cases and deaths
--

select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/sum(NULLIF(new_cases, 0))*100 as DeathPercentage

FROM PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%India%'
Group by date
order by 1,2

--Looking at Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.Date) 
  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.Date) 
  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
From PopVsVac


-- Temp Table

Drop table if exists #PercentPopulationVaccinated
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
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.Date) 
  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.Date) 
  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 


--This is the above executed Table


Select *
From PercentPopulationVaccinated

