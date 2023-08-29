SELECT *
FROM SQLPortfolioProject1.dbo.CovidDeaths
ORDER BY 3,4

SELECT *
FROM SQLPortfolioProject1.dbo.CovidVaccinations

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM SQLPortfolioProject1.dbo.CovidDeaths
ORDER BY 1,2

--TOTAL CASE VS TOTAL DEATH
--DETERMINE THE DEATH PERCENTAGE
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
FROM SQLPortfolioProject1.dbo.CovidDeaths
WHERE location like '%india'
ORDER BY 1,2

--TOTAL CASE VS POPULATION
--DETERMINR PERCENTAGE OF POPULATION GOT COVID
SELECT location,date,population,total_cases,(total_cases/population)*100 as CovidAffectedpercentage
FROM SQLPortfolioProject1.dbo.CovidDeaths
--WHERE location like '%india%'
ORDER BY 1,2

--CHECKING WHICH COUNTRY HAS HIGHEST COUNT OF COVID PER POPULATION
SELECT location,population,MAX(total_cases) as HighestCount,MAX((total_cases/population))*100 as HighestCountpercentage
FROM SQLPortfolioProject1.dbo.CovidDeaths
--where location like '%india'
GROUP BY location,population
ORDER BY HighestCountpercentage desc

--DETERMINING THE COUNTRY WHICH HIGHEST DEATHCOUNT PER POPULATION
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPortfolioProject1.dbo.CovidDeaths
--where location like '%india'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--DETERMINE THE CONTITENT WITH HIGHEST DEATH COUNT
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPortfolioProject1.dbo.CovidDeaths
--where location like '%india'
WHERE continent is null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GOBAL COUNTS
SELECT date,SUM(new_cases) as TotalNewCases,SUM(CAST(new_deaths AS INT)) as TotalNewDeathCase,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM SQLPortfolioProject1.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as TotalNewCases,SUM(CAST(new_deaths AS INT)) as TotalNewDeathCase,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM SQLPortfolioProject1.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--JOIN THE TWO TABLES(COVID DEATH ND VACCINATION)
SELECT *
FROM SQLPortfolioProject1.dbo.CovidDeaths cd JOIN
SQLPortfolioProject1.dbo.CovidVaccinations cv 
on cd.location=cv.location
and cd.date=cv.date
--LOOKING TOT.POPULATION VS VACCINATION
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
FROM SQLPortfolioProject1.dbo.CovidDeaths cd JOIN
SQLPortfolioProject1.dbo.CovidVaccinations cv 
on cd.location=cv.location
and cd.date=cv.date
WHERE CD.continent is not null
ORDER BY 2,3

SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location Order by cd.location,
cd.date) as Totalvaccination
FROM SQLPortfolioProject1.dbo.CovidDeaths cd JOIN
SQLPortfolioProject1.dbo.CovidVaccinations cv 
on cd.location=cv.location
and cd.date=cv.date
WHERE CD.continent is not null
ORDER BY 2,3


--USING CTE because of the error occured while determinig the % of people vaccinated
WITH pervac(Contitnent,Location,Date,Population,New_vaccinated,Total_vaccination)
as
(
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location Order by cd.location,
cd.date) as Totalvaccination
FROM SQLPortfolioProject1.dbo.CovidDeaths cd JOIN
SQLPortfolioProject1.dbo.CovidVaccinations cv 
on cd.location=cv.location
and cd.date=cv.date
WHERE CD.continent is not null
--ORDER BY 2,3 don't use order by in cte
)
SELECT *,(Total_vaccination/Population)*100 as PercentageOfVaccinated
FROM pervac

--SAME ABOVE QUERY BUT USING TEMP TABLE
DROP TABLE IF EXISTS Percentofpeoplevaccinated
CREATE TABLE Percentofpeoplevaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric,
Total_vaccination numeric
)

INSERT INTO Percentofpeoplevaccinated
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location Order by cd.location,
cd.date) as Totalvaccination
FROM SQLPortfolioProject1.dbo.CovidDeaths cd JOIN
SQLPortfolioProject1.dbo.CovidVaccinations cv 
on cd.location=cv.location
and cd.date=cv.date
--WHERE CD.continent is not null
--ORDER BY 2,3

SELECT *,(Total_vaccination/Population)*100 as PercentageOfVaccinated
FROM Percentofpeoplevaccinated

--CREATE VIEW FOR LATER VISUALIZAION
create view Totalvaccination as
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location Order by cd.location,
cd.date) as Totalvaccination
FROM SQLPortfolioProject1.dbo.CovidDeaths cd JOIN
SQLPortfolioProject1.dbo.CovidVaccinations cv 
on cd.location=cv.location
and cd.date=cv.date

SELECT *
FROM Totalvaccination



