Select *
From COVIDPortfolioProject..CovidDeaths
Order By 3,4

--Select *
--From COVIDPortfolioProject..CovidVaccinations
--Order By 3,4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From COVIDPortfolioProject..CovidDeaths
Order By 1,2

--total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From COVIDPortfolioProject..CovidDeaths
Where location like '%states%'
Order By 1,2

--Total cases vs Population
--Shows what percentage got covid

Select location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From COVIDPortfolioProject..CovidDeaths
--Where location like '%states%'
Order By 1,2

--Looking at countries with highest infection rate compared to population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
From COVIDPortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

--Showing countries with highest death count per population

Select location, MAX(cast(total_cases as int)) as TotalDeathCount
From COVIDPortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location
Order by TotalDeathCount desc

--Let's break things down by continent

Select continent, MAX(cast(total_cases as int)) as TotalDeathCount
From COVIDPortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Showing continents with the highest death count per population

Select continent, MAX(cast(total_cases as int)) as TotalDeathCount
From COVIDPortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From COVIDPortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order By 1,2

-- Looking at Total population vs. vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortfolioProject..CovidDeaths dea
Join COVIDPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order By 2,3

-- USE CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortfolioProject..CovidDeaths dea
Join COVIDPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortfolioProject..CovidDeaths dea
Join COVIDPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated

--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortfolioProject..CovidDeaths dea
Join COVIDPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order By 2,3

Select *
From PercentPopulationVaccinated