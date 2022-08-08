SELECT * FROM PortfolioProject.coviddeaths
WHERE continent
ORDER BY 3,4;

-- Select relevant data
SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject.coviddeaths
WHERE continent != ""
ORDER BY 1,2;

-- Calculting Total Cases vs Total Deaths
-- Shows likelihoodnofdying if you contracted covid
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeaths
WHERE location like '%states%'
AND continent != ""
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows % of population that contracted covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.coviddeaths
WHERE location like '%states%'
and continent != ""
ORDER BY 1,2;

-- Looking at countries with highest infection rate as compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 
AS PercentPopulationInfected
FROM PortfolioProject.coviddeaths
WHERE location like '%states%'
and continent != ""
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- Showing the countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths as unsigned)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
-- WHERE location like '%states%'
WHERE continent != ""
GROUP BY location
ORDER BY TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- SELECT location, MAX(CAST(total_deaths as unsigned)) as TotalDeathCount
-- FROM PortfolioProject.coviddeaths
-- WHERE location like '%states%'
-- WHERE continent = ""
-- GROUP BY location
-- ORDER BY TotalDeathCount desc;"

SELECT continent, MAX(CAST(total_deaths as unsigned)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
-- WHERE location like '%states%'
WHERE continent != ""
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- SHOWING CONTINENTS WITH HIGHEST DEATH COUNT
SELECT continent, MAX(CAST(total_deaths as unsigned)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
-- WHERE location like '%states%'
WHERE continent != ""
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as unsigned)) as total_deaths, SUM(CAST(new_deaths as unsigned))/SUM(new_cases)*100 
AS DeathPercentage
FROM PortfolioProject.coviddeaths
-- WHERE location like '%states%'
WHERE continent != ""
GROUP BY date
ORDER BY 1,2;

-- Looking at TOTAL POPULATION vs VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as unsigned)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
	as RollingCountofPeopleVaccinated
-- , (RollingCountofPeopleVaccinated/population)*100
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ""
ORDER BY 2,3;

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCountofPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as unsigned)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
	as RollingCountofPeopleVaccinated
-- , (RollingCountofPeopleVaccinated/population)*100
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != "")

SELECT * , (RollingCountofPeopleVaccinated/population) * 100 FROM PopvsVac;

-- Temp Table

DROP TABLE IF exists PercentPopulationVaccinated;
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountofPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as unsigned)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
	as RollingCountofPeopleVaccinated
-- , (RollingCountofPeopleVaccinated/population)*100
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ""
-- ORDER BY 2,3;

SELECT * , (RollingCountofPeopleVaccinated/population) * 100 
FROM PopvsVac;

-- Creating view to store data for later visualizations
CREATE VIEW jkbnm AS
    SELECT 
        location,
        date,
        total_cases,
        new_cases,
        total_deaths,
        (total_deaths / total_cases) * 100 AS DeathPercentage
    FROM
        PortfolioProject.coviddeaths
    WHERE
        location LIKE '%states%'
            AND continent != ''
    ORDER BY 1 , 2;