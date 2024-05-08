--SELECT *
--FROM PortfolioProject1..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject1..CovidVaccinations
--ORDER BY 3,4

--Select the data that we are going to be using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

--Total cases vs total deaths in India
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location ='India'
ORDER BY 1,2

--Total cases VS Population

SELECT location,date, population,total_cases,(total_cases/Population)*100 AS PercentageOfCases
FROM PortfolioProject1..CovidDeaths
WHERE location ='India'
ORDER BY 1,2

--Which country has highest infection rates compared to population
SELECT location,population,MAX(total_cases) AS HighestInfetionCount,MAX((total_cases/Population))*100 AS PercentageOfCases
FROM PortfolioProject1..CovidDeaths
--WHERE location = 'India'
GROUP BY location,population
ORDER BY PercentageOfCases DESC

--Countries with higest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject1..CovidDeaths
-- WHERE location = 'India'
WHERE continent is  NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--STUDYING DATA BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject1..CovidDeaths
-- WHERE location = 'India'
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY HighestDeathCount DESC

--Continent with the highest death counts per population


-- GLOBAL NUMBER
--Total death percentage in the world
SELECT SUM(new_cases), SUM(cast(new_deaths as int)),
SUM(cast(new_deaths as int))/ SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location ='India'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2

--Total death percentage in the world grouped by date
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)),
SUM(cast(new_deaths as int))/ SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location ='India'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2
-- total poulation vs vaccination
SELECT*
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
