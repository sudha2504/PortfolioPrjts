select * from dbo.[Covid_Deaths] order by  continent,location,total_cases asc

select * from dbo.[Covid_Deaths] order by  3,4

select * from dbo.Covid_Vaccinations order by  3,4

Select  [location], [date], total_cases, new_cases, total_deaths, population
from dbo.[Covid_Deaths] 
order by 1, 2

-- Looking at Total Cases vs Total Deaths
Select  [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.[Covid_Deaths] 
where location like 'India'
order by 1, 2

--Looking at the total cases vs Population
Select  [location], [date], total_cases, population, (total_cases/population)*100 as PercentPopulation
From dbo.[Covid_Deaths] 
Where location like 'India'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
Select  [location], MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From dbo.[Covid_Deaths] 
group by LOCATION
order by 3 desc

Select  [location], population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From dbo.[Covid_Deaths] 
group by [location], population
order by 4 desc

--Showing countries with Highest Death Count Per Population
select location, MAX(Total_deaths) as TotalDeathCount
From dbo.[Covid_Deaths] 
where continent is not Null
group by [location]
order by 2 desc


-- Look at data based on Continent
select location, MAX(Total_deaths) as TotalDeathCount
From dbo.[Covid_Deaths] 
where continent is  Null
group by location
order by 2 desc

update dbo.[Covid_Deaths]
set continent = LOCATION
where continent is Null

-- Showing Continent with the highest death rate
select continent, MAX(Total_deaths) as TotalDeathCount
From dbo.[Covid_Deaths] 
group by continent
order by 2 desc

--- Global Numbers

-- Death Percentage Globally based on date
Select [date], SUM(total_cases) AS TC, SUM(total_deaths) AS TD, (SUM(total_deaths)/SUM(total_cases))*100 as DeathPercentage
from dbo.[Covid_Deaths] 
Group by date
-- where location like 'India'
order by 1, 2

-- New cases by date
Select [date], SUM(new_cases) AS New_Cases
from dbo.[Covid_Deaths] 
Group by date
-- where location like 'India'
order by 1

-- New Death Cases
Select [date], SUM(new_cases) , SUM(new_deaths)
from dbo.[Covid_Deaths] 
Group by date
-- where location like 'India'
order by 1

-- New Death Percentage
select * 
from dbo.Covid_Deaths dea



Select [date], SUM(new_cases) as new_cases , SUM(new_deaths) as new_deaths,
 SUM(new_deaths)/SUM(new_cases) as NewDeathPercent
from dbo.[Covid_Deaths] 
Group by date
HAVING SUM(new_deaths) <> 0
order by 1, 2

--   Covid Vaccination
select *
from dbo.Covid_Deaths dea
join dbo.Covid_Vaccinations vac
on dea.[location] = vac.[location]
and dea.date = vac.[date]



--Looking at Total Population vs Vaccinations
select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
from dbo.Covid_Deaths dea
join dbo.Covid_Vaccinations vac
on dea.[location] = vac.[location]
and dea.date = vac.[date]
order by 1,2,3


--Rolling Sum of vaccination based on Location
select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.[location] order by dea.location, dea.date) as RollingSum
from dbo.Covid_Deaths dea
join dbo.Covid_Vaccinations vac
on dea.[location] = vac.[location]
and dea.date = vac.[date]
order by 1,2,3

-- USE CTE
With PopVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
  ( select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.[location] order by dea.location, dea.date) as RollingSum
from dbo.Covid_Deaths dea
join dbo.Covid_Vaccinations vac
on dea.[location] = vac.[location]
and dea.date = vac.[date]
-- order by 1,2,3
  )
  select * , (RollingPeopleVaccinated/Population)*100
  from PopVac

  ## Creating VIEW
Create View PercentPopulationVaccina as
select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.[location] order by dea.location, dea.date) as RollingSum
from dbo.Covid_Deaths dea
join dbo.Covid_Vaccinations vac
on dea.[location] = vac.[location]
and dea.date = vac.[date]
