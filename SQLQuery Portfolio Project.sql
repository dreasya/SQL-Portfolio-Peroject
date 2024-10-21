--select *
--from CovidDeaths

--select *
--from CovidVacc

--Select location, date, total_cases, new_cases, total_deaths, population
--from CovidDeaths
--order by 1, 2 --this tells sql to order the data by total_cases and new_cases

-- looking at total deaths by total cases in Morocco  

--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
--from CovidDeaths
--where location like '%Morocco%'
--order by 1

--Total cases by population

--Select location, date, total_cases, population, (total_cases/population)*100 as cases_Percentage
--from CovidDeaths
--where location like '%Morocco%'
--order by 1

--Looking at countrie with highest infection rate

--Select location, max(total_cases) as MaxCases, population, Max((total_cases/population))*100 as infectionRate
--from CovidDeaths
----where location like '%Morocco%'
--group by location, population
--order by infectionRate desc


--- Countries with highest deaths count/population

--Select location, max(cast(total_deaths as int)) as MaxDeaths, population, Max((total_deaths/population))*100 as DeathRate
--from CovidDeaths --- we used the cast(... as int) function to convert the data type of the column from numeric to int for accuracy reasons. 
----where location like '%Morocco%'
--where continent is not null -- we added this because in the table we had data for continent locations named ASIA, Europe Union, World... and we don't want that.
--group by location, population
--order by DeathRate desc

-- let see highest deaths count by continent

--Select location, max(total_cases) as MaxCases
--from CovidDeaths
----where location like '%Morocco%'
--where continent is null --in the data table we have, when continent is null location is filled and vice versa.
--group by location
--order by MaxCases desc

--Global Numbers

--SELECT date, sum(new_cases) as sum_new_cases, 
--       sum(cast(new_deaths as int)) as sum_new_deaths, 
--       CASE 
--           WHEN sum(new_cases) = 0 THEN NULL  -- or any value you prefer, such as 0
--           ELSE sum(cast(new_deaths as int)) / sum(new_cases)*100
--       END as deathsPercentage
--FROM CovidDeaths
--where continent is not null --for accuracy and consistancy with data
--Group by date
--order by deathsPercentage desc

----Total Global number
--SELECT sum(new_cases) as sum_new_cases, 
--       sum(cast(new_deaths as int)) as sum_new_deaths, 
--       CASE 
--           WHEN sum(new_cases) = 0 THEN NULL  -- or any value you prefer, such as 0
--           ELSE sum(cast(new_deaths as int)) / sum(new_cases)*100
--       END as deathsPercentage
--FROM CovidDeaths
--where continent is not null
--order by deathsPercentage desc

-- Looking vaccinated people from the entire population

--Select * 
--from CovidVacc vc
--join CovidDeaths dea
--	on vc.date = dea.date
--	and vc.location = dea.location
--order by vc.location

--Select dea.continent, dea.location, dea.date, dea.population, vc.new_vaccinations
--from CovidVacc vc
--join CovidDeaths dea
--	on vc.date = dea.date
--	and vc.location = dea.location
--where dea.continent is not null
--order by dea.continent, dea.location, dea.date

--Select dea.continent, dea.location, dea.date, dea.population, vc.new_vaccinations
--, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.date) as vacc_add_up

--from CovidVacc vc
--join CovidDeaths dea
--	on dea.date = vc.date
--	and dea.location = vc.location 

--where dea.continent is not null
--   --and dea.location like '%Albania%'
--   AND dea.population IS NOT NULL -- we added this because the population column had dublicate missing (NULL) values.

--order by dea.continent, dea.location, dea.date



-- Number of people vaccinated over population (country by country)
----USE CTE

--with popVac (continent, location, date, population, new_vaccinations, vacc_add_up)
--as 
--(
--Select dea.continent, dea.location, dea.date, dea.population, vc.new_vaccinations
--, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.date) as vacc_add_up
--from CovidVacc vc
--join CovidDeaths dea
--	on dea.date = vc.date
--	and dea.location = vc.location 
--where dea.continent is not null
--   --and dea.location like '%Albania%'
--   AND dea.population IS NOT NULL -- we added this because the population column had dublicate missing (NULL) values.
--)
--select continent, population, location, Max((vacc_add_up/population)*100) as per_vaccinated
--from popvac
--group by continent, location, population


-----
-----
----- TEMP Table
-----
-----

--drop table if exists #Percent_vacc
--create table #Percent_vacc
--(
--continent varchar(255),
--location varchar(255),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--vacc_add_up numeric
--)

--insert into #Percent_vacc
--Select dea.continent, dea.location, dea.date, dea.population, vc.new_vaccinations
--, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.date) as vacc_add_up
--from CovidVacc vc
--join CovidDeaths dea
--	on dea.date = vc.date
--	and dea.location = vc.location 
--where dea.continent is not null
--   --and dea.location like '%Albania%'
--   AND dea.population IS NOT NULL -- we added this because the population column had dublicate missing (NULL) values.

--select continent, population, location, Max((vacc_add_up/population)*100) as per_vaccinated
--from #Percent_vacc
--group by continent, location, population

---
---
---
--- Creating view to store data for later visualizations
--
--
create view Percent_vacc as
Select dea.continent, dea.location, dea.date, dea.population, vc.new_vaccinations
, sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.date) as vacc_add_up
from CovidVacc vc
join CovidDeaths dea
	on dea.date = vc.date
	and dea.location = vc.location 
where dea.continent is not null
   AND dea.population IS NOT NULL -- we added this because the population column had dublicate missing (NULL) values.


---View2
create view Total_cases as

--Total cases by population

Select location, date, total_cases, population, (total_cases/population)*100 as cases_Percentage
from CovidDeaths
where location like '%Morocco%'
--order by 1

---View3
-- let see highest deaths count by continent
Create view highest_deaths as
Select location, max(total_cases) as MaxCases
from CovidDeaths
--where location like '%Morocco%'
where continent is null --in the data table we have, when continent is null location is filled and vice versa.
group by location

---View4

----Total Global number
create view Total_Global_number as
SELECT sum(new_cases) as sum_new_cases, 
       sum(cast(new_deaths as int)) as sum_new_deaths, 
       CASE 
           WHEN sum(new_cases) = 0 THEN NULL  -- or any value you prefer, such as 0
           ELSE sum(cast(new_deaths as int)) / sum(new_cases)*100
       END as deathsPercentage
FROM CovidDeaths
where continent is not null

----View5
create view vaccinated_people as 
Select dea.continent, dea.location, dea.date, dea.population, vc.new_vaccinations
from CovidVacc vc
join CovidDeaths dea
	on vc.date = dea.date
	and vc.location = dea.location
where dea.continent is not null
