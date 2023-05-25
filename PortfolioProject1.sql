SELECT*
FROM SQL_Portfolio_Project.dbo.CovidDeaths
ORDER BY 3,4


SELECT*
FROM SQL_Portfolio_Project.dbo.CovidVaccinations
ORDER BY 3,4

--Selecting the data we are going to be using.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQL_Portfolio_project..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, CONCAT(CONVERT(INT,(CONVERT(FLOAT, total_deaths)/CONVERT(FLOAT, total_cases))*100), '%') AS DeathPercentage
FROM SQL_Portfolio_project..CovidDeaths
WHERE location LIKE '%dominican republic%'
ORDER BY CONVERT(INT, total_deaths) Desc

--Looking at total cases vs population
--Shows what percentage of the population got Covid
SELECT location, date, population, total_cases, CONCAT(CONVERT(INT,(CONVERT(FLOAT, total_cases)/CONVERT(FLOAT, population))*100), '%') AS ContractionPercentage
FROM SQL_Portfolio_project..CovidDeaths
WHERE location LIKE '%dominican republic%'
ORDER BY ContractionPercentage Desc

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS TotalCases, CONCAT(CONVERT(INT,(CONVERT(FLOAT, MAX(total_cases))/CONVERT(FLOAT, population))*100), '%') AS ContractionPercentage
FROM SQL_Portfolio_project..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY CONVERT(FLOAT, MAX(total_cases))/CONVERT(FLOAT, population)*100 Desc

--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as INT)) as totaldeathcount
FROM SQL_Portfolio_project..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent != ''
GROUP BY location
ORDER BY totaldeathcount desc


--Let's break things down by continents

SELECT location, MAX(cast(total_deaths as INT)) as totaldeathcount
FROM SQL_Portfolio_project..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent = ''
GROUP BY location

--Showing the continets with the highest death count per population

SELECT continent, MAX(cast(total_deaths as INT)) as totaldeathcount
FROM SQL_Portfolio_project..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent != ''
GROUP BY continent
ORDER BY totaldeathcount desc

--Global numbers

SELECT date, SUM(new_cases), SUM(cast(new_deaths as INT)), SUM(cast(new_deaths as INT))/SUM
  (new_cases)*100 AS DeathPercentage
FROM SQL_Portfolio_project..CovidDeaths
--WHERE location LIKE '%dominican republic%'
WHERE continent is not null
GROUP By date
ORDER BY 1,2


-- JOIN

-- Looking at total populations vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM SQL_Portfolio_project..CovidDeaths dea
JOIN
SQL_Portfolio_project..CovidVaccinations vac
    on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2,3

--Looking at total vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date ) AS rolling_people_vaccinated
FROM SQL_Portfolio_project..CovidDeaths dea
JOIN
SQL_Portfolio_project..CovidVaccinations vac
    on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2,3


--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date ) AS rolling_people_vaccinated
FROM SQL_Portfolio_project..CovidDeaths dea
JOIN
SQL_Portfolio_project..CovidVaccinations vac
    on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != '' 
--ORDER BY 2,3
)

SELECT*, (rolling_people_vaccinated/population)*100 AS percentage_of_population_vaccinated
FROM PopvsVac


--Temp table


CREATE TABLE #Percent_Population_Vaccinated4
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population INT,
new_vaccinations FLOAT,
rolling_people_vaccinated FLOAT
)

INSERT INTO #Percent_Population_Vaccinated4
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date ) AS rolling_people_vaccinated
FROM SQL_Portfolio_project..CovidDeaths dea
JOIN
SQL_Portfolio_project..CovidVaccinations vac
    on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2,3



SELECT*, (rolling_people_vaccinated/population)*100
FROM #Percent_Population_Vaccinated4




--Creating View to store data for later visualizations


CREATE VIEW PercetagePopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date ) AS rolling_people_vaccinated
FROM SQL_Portfolio_project..CovidDeaths dea
JOIN
SQL_Portfolio_project..CovidVaccinations vac
    on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
--ORDER BY 2,3


SELECT*
FROM PercetagePopulationvaccinated

