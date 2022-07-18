Select *
  FROM [PortfolioProjec].[dbo].[CovidVaccinations]
order BY 3,4
Select *
  FROM [PortfolioProjec].[dbo].[CovidDeaths]
order BY 3,4
--select the data we are going to be using
select location,date ,total_cases ,new_cases,total_deaths, population
from [PortfolioProjec].[dbo].[CovidDeaths]
order by 1,2

--Looking at Total Cases VS Total Deaths
--Show likelihood of dying if you contract covid in your country
select location,date ,total_cases ,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [PortfolioProjec].[dbo].[CovidDeaths]
where location like '%Algeria%'
order by 1,2

--Looking at Total Cases VS Population
--Shows what percentage of Population got Covid
select location,date ,Population,total_cases , (total_cases/Population)*100 as PercentPopulationInfected
from [PortfolioProjec].[dbo].[CovidDeaths]
--where location like '%Algeria%'
order by 1,2

--Looking at Countries With Highest Infection Rate compared to Population
select location ,Population,Max(total_cases)as HighestInfectionCount ,
Max((total_cases/Population))*100 as PercentPopulationInfected
from [PortfolioProjec].[dbo].[CovidDeaths]
--where location like '%Algeria%'
Group By location,population
order by PercentPopulationInfected desc
-- Showing contintents with the highest death count per population
select location ,Max(cast(total_deaths as int))as  TotalDeathsCount
from [PortfolioProjec].[dbo].[CovidDeaths]
--where location like '%Algeria%'
where continent is not Null
Group By location
order by TotalDeathsCount desc 
--Let's Break Things Down By continent
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProjec].[dbo].[CovidDeaths]
--Where location like '%Algeria%'
Where continent is null
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProjec].[dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [PortfolioProjec].[dbo].[CovidDeaths]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProjec].[dbo].[CovidDeaths] dea
Join [PortfolioProjec].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProjec].[dbo].[CovidDeaths] dea
Join [PortfolioProjec].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
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
, SUM(CONVERT(BIGint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProjec].[dbo].[CovidDeaths] dea
Join [PortfolioProjec].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated_V4 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProjec].[dbo].[CovidDeaths] dea
Join [PortfolioProjec].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

