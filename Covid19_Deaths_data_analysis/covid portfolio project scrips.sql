select *
from Portfolio..covidDeaths
order by 3,4

--select *
--from Portfolio..covidVacination
--order by 3,4
--select the data that we are going to use
select location,date,total_cases,new_cases,total_deaths,population
from Portfolio..covidDeaths
order by 1,2

--looking at total cases vs total deaths
--show likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(cast(total_deaths as float )/total_cases)*100 as DeathPercentage
from Portfolio..covidDeaths
where location like '%india%'
order by 1,2

--looking at total_cases vs Population
--shows what percentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as CasePercentage
from Portfolio..covidDeaths
--where location like '%state%'
where total_cases is NOT NULL
order by 1,2




--looking at countries with highest infection rate cpmpared to population
select location, population,max(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as PercentPOpulationInfected
from Portfolio..covidDeaths
--where location like '%state%'
--where total_cases is NOT NULL
group by location,population
order by PercentPOpulationInfected desc

-- showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as DeathCount
from Portfolio..covidDeaths
--where location like '%state%'
where continent is NOT NULL
group by location
order by DeathCount desc






--Let's break things down by continent

select location,max(cast(total_deaths as int)) as DeathCount
from Portfolio..covidDeaths
--where location like '%state%'
where continent is NULL
group by location
order by DeathCount desc




--showing the continent with highest death counnt per Population


select continent,max(cast(total_deaths as int)) as DeathCount
from Portfolio..covidDeaths
--where location like '%state%'
where continent is not NULL
group by continent
order by DeathCount desc




--Global Numbers

select date,sum(new_cases)
from Portfolio..covidDeaths
--where location like '%state%'
where continent is not NULL
group by date
order by 1,2

--------------------------------

select date,sum(new_cases),sum(cast(new_deaths as int)),sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage 
from Portfolio..covidDeaths
--where location like '%state%'
where continent is not NULL 
group by date
order by DeathPercentage
-----------------------------------------------

select sum(new_cases) as total_deaths,sum(cast(new_deaths as int)) as Total_deaths,sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage 
from Portfolio..covidDeaths
--where location like '%state%'
where continent is not NULL 
--group by date
order by DeathPercentage






-------------------------------------------------------------------------------

select *
from Portfolio..covidVacination

--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from Portfolio..covidDeaths dea
join Portfolio..covidVacination vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

---------------------------------------
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from Portfolio..covidDeaths dea
join Portfolio..covidVacination vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3







--------------------------------------------------------------
--Use CTE
with PopvsVac( continent,location,date,populaiton,new_vaccination,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from Portfolio..covidDeaths dea
join Portfolio..covidVacination vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/populaiton)*100 as VaccinatedPercentage
from PopvsVac



----------------------------------------------------------------------------------------
--create temp table
drop table if exists #PercentPopulationVacinated
create table #PercentPopulationVacinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVacinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from Portfolio..covidDeaths dea
join Portfolio..covidVacination vac
on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select * ,(RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
from #PercentPopulationVacinated


-----------------------------------------------------------------
--creating view to store data for later visualizations
drop view if exists PercentPopulationVacinated
create view PercentPopulationVacinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from Portfolio..covidDeaths dea
join Portfolio..covidVacination vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVacinated