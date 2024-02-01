Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..Covidvaccinations
--order by 3,4


--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at the total cases vs total deaths
-- Shows likelihood dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'India' and  continent is not null
order by 1,2

--Looking at the Total cases vs Population
-- Shows what percentage of population got covid
Select Location, Date, Total_cases, Population,(Total_cases/Population)*100 as percentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location = 'United States' and continent is not null
Order by 1,2

-- Looking at the countries with Highest Infection Rate comapred to population

Select Location, Population, Max(Total_cases) as HighestInfectionCount, Max((total_cases/Population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location, population
Order by 4 desc

--Showing countries having the highest DeathCount Per Population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null 
group by location, continent
Order by TotalDeathCount desc

-- Lets Check with Continent 

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is  null
group by location
Order by TotalDeathCount desc

--Global Numbers
Select  sum(new_cases) as Totalcases, sum(cast(new_deaths as int)) as Totaldeath, SUM(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as Total_People_Vaccinated_As_On_That_Date
From PortfolioProject..CovidDeaths dea
 join PortfolioProject..Covidvaccinations vac
 on dea.location = vac.location
 Where dea.continent is not null
 and dea.date = vac.date
 order by 2,3


 --Using CTE

 With PopvsVac (Continent, Location, Date, Population, 
 New_Vaccinations, Total_People_Vaccinated_As_On_That_Date)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as Total_People_Vaccinated_As_On_That_Date
From PortfolioProject..CovidDeaths dea
 join PortfolioProject..Covidvaccinations vac
 on dea.location = vac.location
 Where dea.continent is not null
 and dea.date = vac.date
 --order by 2,3
 )
 Select *, (Total_People_Vaccinated_As_On_That_Date/Population)*100
 From PopvsVac

 --Using Temp Table 
 Drop Table if exists #Temp_PercentPopulationVaccinated
 Create Table #Temp_PercentPopulationVaccinated
 (Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 Total_People_Vaccinated_As_On_That_Date numeric
 )

 Insert into #Temp_PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as Total_People_Vaccinated_As_On_That_Date
From PortfolioProject..CovidDeaths dea
 join PortfolioProject..Covidvaccinations vac
 on dea.location = vac.location
 --Where dea.continent is not null
 and dea.date = vac.date
 --order by 2,3
 
 Select *, (Total_People_Vaccinated_As_On_That_Date/Population)*100
 From #Temp_PercentPopulationVaccinated 

 -- Creating View to store data for Later Visulasation

 Create view PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as Total_People_Vaccinated_As_On_That_Date
From PortfolioProject..CovidDeaths dea
 join PortfolioProject..Covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
  Where dea.continent is not null
 --order by 2,3

 Select * from PercentPopulationVaccinated