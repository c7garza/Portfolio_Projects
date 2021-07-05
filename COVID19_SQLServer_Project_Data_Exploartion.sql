-- Overview of Both Tables; ordered by location,date
SELECT *
FROM Portfolio_Project..Covid_Deaths$
WHERE continent IS NOT NULL ---Removes locations that are continents(Asia,Europe,Africa..etc) or World
ORDER BY 3,4

SELECT*
FROM Portfolio_Project..Covid_Vaccinations$
WHERE continent IS NOT NULL
ORDER BY 3,4

--Total Cases VS Total Deaths
--Based on the location,we want to see the likelihood of dying if Covid-19 is contracted.

SELECT location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_percentage
FROM Portfolio_Project..Covid_Deaths$
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2;

--Total Cases VS Population
--We want to see what percentage of the population got Covid-19

SELECT location,date,population, total_cases,(total_cases/population)*100 as Percent_Population_Infected
FROM Portfolio_Project..Covid_Deaths$
--WHERE location LIKE ''
ORDER BY 1,2;

-- Countries with the Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
FROM Portfolio_Project..Covid_Deaths$
--WHERE location LIKE ''
GROUP BY location, population
ORDER BY  Percent_Population_Infected DESC;

--Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..Covid_Deaths$
--WHERE location LIKE ''
WHERE continent  IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;

---BREAKING THINGS DOWN BY CONTINENT---

SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..Covid_Deaths$
--WHERE location LIKE ''
WHERE continent  IS NOT NULL -- IS NULL to filter out only the continents
GROUP BY continent
ORDER BY Total_Death_Count DESC;

--Continent with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..Covid_Deaths$
WHERE continent  IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;


---Global Numbers
-- We want to see the numbers of Covid19 globally per day

SELECT date, SUM(new_cases)as Total_cases, SUM(cast(new_deaths as INT)) as Total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as Death_percentage
FROM Portfolio_Project..Covid_Deaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

---Total Population VS Vaccinations; with a rolling count column of new vaccinations

SELECT deaths.continent, deaths.location,deaths.date, deaths.population,vacs.new_vaccinations, 
SUM(cast (vacs.new_vaccinations as INT)) 
OVER(Partition by deaths.location ORDER BY deaths.location, deaths.date) as Cumulative_Vac_Count
FROM Portfolio_Project..Covid_Deaths$ as deaths 
JOIN Portfolio_Project..Covid_Vaccinations$ as vacs
ON deaths.location=vacs.location AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3;

---USE CTE to create a column that displays the percentage of population vaccinated using Cumulative_Vac_Count 

WITH Pop_vs_Vac (Continent, Location, Date, Population, New_vaccinations, Cumulative_Vac_Count)
as
(
SELECT deaths.continent, deaths.location,deaths.date, deaths.population,vacs.new_vaccinations, 
SUM(cast (vacs.new_vaccinations as INT)) 
OVER(Partition by deaths.location ORDER BY deaths.location, deaths.date) as Cumulative_Vac_Count
FROM Portfolio_Project..Covid_Deaths$ as deaths 
JOIN Portfolio_Project..Covid_Vaccinations$ as vacs
ON deaths.location=vacs.location AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL
)
SELECT *, (Cumulative_Vac_Count/ Population)* 100 as Percent_Total_Vaccinations
FROM Pop_vs_Vac;


---CREATING VIEWS---
--Creating views to use for later visualizations

--POP VS VAC VIEW
CREATE VIEW Pop_vs_vac as
SELECT deaths.continent, deaths.location,deaths.date, deaths.population,vacs.new_vaccinations, 
SUM(cast (vacs.new_vaccinations as INT)) 
OVER(Partition by deaths.location ORDER BY deaths.location, deaths.date) as Cumulative_Vac_Count
FROM Portfolio_Project..Covid_Deaths$ as deaths 
JOIN Portfolio_Project..Covid_Vaccinations$ as vacs
ON deaths.location=vacs.location AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL;

-- GLOBAL NUMBERS VIEW
CREATE VIEW Global_numbers as 
SELECT date, SUM(new_cases)as Total_cases, SUM(cast(new_deaths as INT)) as Total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as Death_percentage
FROM Portfolio_Project..Covid_Deaths$
WHERE continent IS NOT NULL
GROUP BY date;

-- HIGHEST INFECTED COUNTRIES VIEW
CREATE VIEW Highest_Infected_Countries_Pop as
SELECT location,population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
FROM Portfolio_Project..Covid_Deaths$
GROUP BY location, population;