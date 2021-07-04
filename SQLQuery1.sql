

--Select *
--      From [SQl Tutorial] ..['Covid Deaths$']
--	  order by 3,4;

	  
--Select *
--      From [SQl Tutorial] ..['Covid Vaccinations$']
--	  order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population
From [SQl Tutorial]..['Covid Deaths$']
order by 1,2;

-- Looking at Total Cases Vs Total Deaths
-- Shows Likleyhood of dying if you get covid in the states
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [SQl Tutorial]..['Covid Deaths$']
where location like '%states%'
order by 1,2;


-- Looking at the the Total Cases Vs Population
-- Shows percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [SQl Tutorial]..['Covid Deaths$']
where location like '%states%'
order by 1,2;


-- Looking At countries with highest infection Rates

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [SQl Tutorial]..['Covid Deaths$']
--where location like '%states%'--
Group by Location, population
order by PercentPopulationInfected desc

-- SHowing Countries with HIghest Death Count per Population

Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From [SQl Tutorial]..['Covid Deaths$']
--where location like '%states%'--
Where continent is not null
Group by Location
order by TotalDeathCount desc;

-- Now Lets look into location

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From [SQl Tutorial]..['Covid Deaths$']
--where location like '%states%'--
Where continent is  null
Group by location
order by TotalDeathCount desc;



--- Showing Continent with highest death COunt

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From [SQl Tutorial]..['Covid Deaths$']
--where location like '%states%'--
Where continent is not null
Group by Location
order by TotalDeathCount desc;

-- Global Numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [SQl Tutorial]..['Covid Deaths$']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine



Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated,
 --(RollingPeopleVaccinated/population)*100
From [SQl Tutorial]..['Covid Deaths$'] dea
Join [SQl Tutorial]..['Covid Vaccinations$'] vac
    On dea.location = vac.location  
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--USe CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 

as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/population)*100
From [SQl Tutorial]..['Covid Deaths$'] dea
Join [SQl Tutorial]..['Covid Vaccinations$'] vac
    On dea.location = vac.location  
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	Select *
	From PopvsVac

	-- Using Temp Table to perform Calculation on Partition By in previous query

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
 , SUM (CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQl Tutorial]..['Covid Deaths$'] dea
Join [SQl Tutorial]..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to Store Data For Later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM (CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQl Tutorial]..['Covid Deaths$'] dea
Join [SQl Tutorial]..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select *
From PercentPopulationVaccinated