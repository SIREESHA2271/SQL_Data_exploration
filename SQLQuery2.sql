select *
from data_exploration..CovidDeaths

select *
from data_exploration..CovidVaccinations

--Percentage of cases

select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from data_exploration..CovidDeaths
where location = 'United states'
and continent is not NULL
order by 1,2

--total number of people died based on location
Select Location, population, 
SUM(total_deaths) as TotalDeath
From data_exploration..CovidDeaths
where continent is not null 
group by location, population
order by 1,2

--countries with highest death count
select location, population, max(total_deaths) as MaxDeath
from data_exploration..CovidDeaths
where continent is not null
group by location, population
order by MaxDeath desc

--continent with highest death count
select continent, max(total_deaths) as DeathCount
from data_exploration..CovidDeaths
where continent is not null
group by continent
order by DeathCount desc

--percentage of population that recieved vaccination
select cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location, cd.date) as peoplevaccinated
from data_exploration..CovidDeaths as cd
join data_exploration..CovidVaccinations as cv
     on cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not NULL
order by 1,2

--using CTE to perform calculations on peoplevaccinated
With cte_vacc as 
(select cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location, cd.date) as peoplevaccinated
from data_exploration..CovidDeaths as cd
join data_exploration..CovidVaccinations as cv
     on cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not NULL
)
select *, (peoplevaccinated/population)*100
from cte_vacc

--using temp tables

create table #temp_vacc(
continent nvarchar(50),
location nvarchar(50),
date datetime,
population bigint,
new_vaccinations int,
peoplevaccinated int
)
insert into #temp_vacc 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location, cd.date) as peoplevaccinated
from data_exploration..CovidDeaths as cd
join data_exploration..CovidVaccinations as cv
     on cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not NULL

select *, (peoplevaccinated/population)*100
from #temp_vacc


