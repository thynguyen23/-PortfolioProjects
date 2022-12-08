

-- total cases and total deaths--
-- percentage death rate in your contry
select location, date,total_cases , total_deaths, round((total_deaths/total_cases)*100.0,2) as Death_percentage
from PortfofolProject..CovidDeaths
where location = 'VietNam' 
order by 1,2
--total cases and population 
-- show what percentage of population infected with covid
select location, date,total_cases, population, round((total_cases/population)*100.0,4) as Percentage_population_Infected
from PortfofolProject..CovidDeaths
order by 1,2
-- countries with highest infection compared to population


select location,max(total_cases ) as Highest_Infection_Count, population, round(max((total_cases/population))*100.0,4) as Percentage_population_Infected
from PortfofolProject..CovidDeaths
group by location,population
order by Percentage_population_Infected desc 



-- countries with highest death count per population 


select location,max(cast(total_deaths as int)) as Total_death_count -- why i used 'cast' ? bc total_deaths is nvarchar, so i will convert it into integer
from PortfofolProject..CovidDeaths
where continent is not null
group by location
order by Total_death_count desc 

-- show	continents with the highest death count per population 

select continent,max(cast(total_deaths as int)) as Total_death_count 
where continent is not null
group by location
order by Total_death_count desc
--Global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
round((sum(cast(new_deaths as int))/sum(new_cases))*100,2) as Death_Percentage
from PortfofolProject..CovidDeaths
where continent is not null
order by 1,2

-- total population vs vaccinations 
--show percentage of population that has received at least one covid vaccine 
select   de.continent,de.location,de.date,de.population,va.new_vaccinations,
sum(convert(bigint,de.new_vaccinations)) over (partition by de.location order by de.date, de.location) as Rolling_People_Vaccinated
from PortfofolProject..CovidVaccinations va
join PortfofolProject..CovidDeaths de 
	on de.location = va.location and de.date =va.date 
where de.continent is not null 
order by 2,3 
--using CTE to perform calculation on partition by
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfofolProject..CovidDeaths dea
Join PortfofolProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select distinct *, (RollingPeopleVaccinated/Population)*100 as percentage_rolling_People_Vanccinated 
From PopvsVac
--using temp table to perfom caculation on partition by in vervious query
create table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
 RollingPeopleVaccinated numeric


)
insert into #Percent_Population_Vaccinated
	Select dea.Continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfofolProject..CovidDeaths dea
Join PortfofolProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Select distinct *, ( RollingPeopleVaccinated/Population)*100 as percentage_rolling_People_Vanccinated 
From  #Percent_Population_Vaccinated

--create view to store data 
create view Percent_Population_Vaccinated as 
Select dea.Continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfofolProject..CovidDeaths dea
Join PortfofolProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date	
	where dea.continent is not null