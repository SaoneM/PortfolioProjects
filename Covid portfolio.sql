select *
from CovidDeaths
where continent is not null
order by 3,4;

-- Select the data we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2;

-- looking at the total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentageInfected
from CovidDeaths
where location like '%Africa%'
order by 1,2;


-- looking at the total cases vs the population
-- shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentOfPopulationI
from CovidDeaths
where location like '%Botswana%'
order by 1,2;

-- countries with highest infection rate compared to population
select location, max(total_cases) as highest_infection_count
, population, (max(total_cases)/population)*100 percent_population_infected
from CovidDeaths
group by population, location
order by percent_population_infected desc;

-- showing countries with highest death count per population
select location, max(total_deaths) as total_death_count
from CovidDeaths
where continent is not null
group by location
order by total_death_count desc;

-- lets break things down by continent
-- showing the continents with the highest death count
select continent, max(total_deaths) as total_death_count
from CovidDeaths
where continent is not null
group by continent
order by total_death_count desc;

-- global numbers
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100
from CovidDeaths
where continent is not null
-- group by date 
order by 1,2,;


-- looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location 
order by dea.location, dea.date) as rolling_people_vaccinated 
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- use cte
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location 
order by dea.location, dea.date) as rolling_people_vaccinated 
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
select *, (rolling_people_vaccinated/population)*100
from PopvsVac;



-- temp table

create table percentage_population_vaccinated (          
	continent varchar(255),
	location varchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
);

insert into percentage_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location 
order by dea.location, dea.date) as rolling_people_vaccinated 
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null;

select *
from percentage_population_vaccinated;

-- creating view to store data for later visualisations

create view percentage_population_vaccinated_view as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location 
order by dea.location, dea.date) as rolling_people_vaccinated 
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null;


select *
from percentage_population_vaccinated_view;
