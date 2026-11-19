-- creating covid death tables 
DROP TABLE IF EXISTS coviddeaths;

CREATE TABLE coviddeaths (
    iso_code                            VARCHAR(10),
    continent                           VARCHAR(50),
    location                            VARCHAR(100),
    date                                DATE,
    population                          NUMERIC,
	total_cases							NUMERIC,
    new_cases                           NUMERIC,
    new_cases_smoothed                  NUMERIC,
    total_deaths                        NUMERIC,
    new_deaths                          NUMERIC,
    new_deaths_smoothed                 NUMERIC,
    total_cases_per_million             NUMERIC,
    new_cases_per_million               NUMERIC,
    new_cases_smoothed_per_million      NUMERIC,
    total_deaths_per_million            NUMERIC,
    new_deaths_per_million              NUMERIC,
    new_deaths_smoothed_per_million     NUMERIC,
    reproduction_rate                   NUMERIC,
    icu_patients                        NUMERIC,
    icu_patients_per_million            NUMERIC,
    hosp_patients                       NUMERIC,
    hosp_patients_per_million           NUMERIC,
    weekly_icu_admissions               NUMERIC,
    weekly_icu_admissions_per_million   NUMERIC,
    weekly_hosp_admissions              NUMERIC,
    weekly_hosp_admissions_per_million  NUMERIC,
    new_tests                           NUMERIC,
    population_density                  NUMERIC,
    median_age                          NUMERIC,
    aged_65_older                       NUMERIC,
    aged_70_older                       NUMERIC,
    gdp_per_capita                      NUMERIC,
    extreme_poverty                     NUMERIC,
    cardiovasc_death_rate               NUMERIC,
    diabetes_prevalence                 NUMERIC,
    female_smokers                      NUMERIC,
    male_smokers                        NUMERIC,
    handwashing_facilities              NUMERIC,
    hospital_beds_per_thousand          NUMERIC,
    life_expectancy                     NUMERIC,
    human_development_index             NUMERIC
);
-- creating covid vaccination tables
DROP TABLE IF EXISTS covidvaccinations;

CREATE TABLE covidvaccinations (
    iso_code                                VARCHAR(10),
    continent                               VARCHAR(50),
    location                                VARCHAR(100),
    date                                    DATE,
    total_tests                             NUMERIC,
    total_tests_per_thousand                NUMERIC,
    new_tests_per_thousand                  NUMERIC,
    new_tests_smoothed                      NUMERIC,
    new_tests_smoothed_per_thousand         NUMERIC,
    positive_rate                           NUMERIC,
    tests_per_case                          NUMERIC,
    tests_units                             VARCHAR(50),
    total_vaccinations                      NUMERIC,
    people_vaccinated                       NUMERIC,
    people_fully_vaccinated                 NUMERIC,
    new_vaccinations                        NUMERIC,
    new_vaccinations_smoothed               NUMERIC,
    total_vaccinations_per_hundred          NUMERIC,
    people_vaccinated_per_hundred           NUMERIC,
    people_fully_vaccinated_per_hundred     NUMERIC,
    new_vaccinations_smoothed_per_million   NUMERIC,
    stringency_index                        NUMERIC,
    population_density                      NUMERIC,
    median_age                              NUMERIC,
    aged_65_older                           NUMERIC,
    aged_70_older                           NUMERIC,
    gdp_per_capita                          NUMERIC,
    extreme_poverty                         NUMERIC,
    cardiovasc_death_rate                   NUMERIC,
    diabetes_prevalence                     NUMERIC,
    female_smokers                          NUMERIC,
    male_smokers                            NUMERIC,
    handwashing_facilities                  NUMERIC,
    hospital_beds_per_thousand              NUMERIC,
    life_expectancy                         NUMERIC,
    human_development_index                NUMERIC
);
-- exploring data
Select * 
From coviddeaths
order by 1,2;
-- Select data that we are going to be using
Select Location, date, total_cases, total_deaths, population
From coviddeaths
order by 1,2

-- looking at total casves vs total deaths
-- likelihood of dying if you have covid in the united states
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From coviddeaths
where location = 'United States'
order by 1,2

--looking at total cases vs population
-- shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From coviddeaths
where location = 'United States'
order by 1,2

--looking at countries with highest infection rate compared to population 
select location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentage
From coviddeaths
group by location, population
order by covidpercentage desc

-- showing countries with highest death count per population 
select location, MAX(total_deaths) as TotalDeathCount
From coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc

--continent stats
select continent, max(total_deaths) as TotalDeathCount
from coviddeaths
where continent is not null 
group by continent
order by totaldeathcount desc

--global stats
select date, sum(new_cases) as total_cases, sum(new_Deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null
group by date
order by 1,2

-- looking at total population vs vaccinations
select dea.continent, dea.location, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccination,
(RollingVaccination/population) * 100
from coviddeaths DEA
join covidvaccinations VAC
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Drop Table if exists PercentPopulationVaccinated;
CREATE Table PercentPopulationVaccinated
(
Continent varchar(50),
Location varchar(100),
Date Date,
Population numeric,
New_vaccinations numeric,
RollingVaccination numeric
);
Insert into PercentPopulationVaccinated
(Continent, Location, Date, Population, New_vaccinations, RollingVaccination)
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccination

from coviddeaths DEA
join covidvaccinations VAC
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

select * , (RollingVaccination/Population)*100
From PercentPopulationVaccinated

-- creating for visualizations
create view PercentVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccination

from coviddeaths DEA
join covidvaccinations VAC
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null 

