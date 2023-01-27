--COVID 19 SQL EXPLORATION

SELECT *

FROM [dbo].[CovidDeaths]
ORDER BY 3,4

--DATA THAT TO USE IN COVID 19 CASES
SELECT
[location],
[date],
[total_cases],
[new_cases],
[total_deaths],
[population]
FROM [dbo].[CovidDeaths]
ORDER BY 1,2


--TOTAL CASES VS TOTAL DEATH SHOWING LIKELIHOOD OF DYING IF CONTRACTED COVID 19 IN AFRICA
SELECT
[location],
[date],
[total_cases],
[total_deaths],
[total_deaths]/[total_cases]*100 AS DEATHPERCENTAGE
FROM [dbo].[CovidDeaths]
WHERE [location] LIKE '%africa%' AND [continent] IS NOT NULL
ORDER BY 1,2


--TOTAL CASES VS POPULATION SHOWING PERCENTAGE OF POPULATION CONTRACTED COVID 19 
SELECT
[location],
[date],
[total_cases],
[population],
[total_cases]/[population]*100 AS PopulationInfectedPercentage
FROM [dbo].[CovidDeaths]
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE VS POPULATION
SELECT
[location],
[population],
MAX([total_cases]) AS HighestInfectionCases,
MAX([total_cases]/[population])*100 AS PopulationInfectedPercentage
FROM [dbo].[CovidDeaths]
GROUP BY [location],[population]
ORDER BY  PopulationInfectedPercentage DESC

--CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION 
SELECT
[continent],
MAX(CAST([total_deaths] AS INT)) AS TotalDeathCount
FROM [dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
GROUP BY [continent]
ORDER BY  TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT 
SUM([new_cases]) AS TotalCases,
SUM(CAST([new_deaths] AS INT)) AS TotalDeaths,
SUM(CAST([new_deaths] AS INT))/SUM([new_cases])*100 AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
ORDER BY 1,2

--TOTAL POPULATION VS VACCINATIONS 
SELECT 
CD.continent,
CD.location,
CD.date,
CD.population,
CV.new_vaccinations,
SUM(CONVERT(int,CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date)
AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] CD
JOIN [dbo].[CovidVaccinations] CV
ON CV.location = CD.location 
AND CV.date = CD.date
WHERE CD.[continent] IS NOT NULL
ORDER BY 2,3

--USE CTE
--TOTAL POPULATION VS VACCINATIONS SHOWING PERCENTAGE OF POPULATION VACCINATED
WITH PopvsVac(continent,location,date,population,New_vaccinations,RollingPeopleVaccinated) AS 
(
SELECT 
CD.continent,
CD.location,
CD.date,
CD.population,
CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS int)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] CD
JOIN [dbo].[CovidVaccinations] CV
ON CV.location = CD.location 
AND CV.date = CD.date
WHERE CD.[continent] IS NOT NULL
)
SELECT *,
(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
CD.continent,
CD.location,
CD.date,
CD.population,
CV.new_vaccinations,
SUM(CONVERT(INT,CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] CD
JOIN [dbo].[CovidVaccinations] CV
ON CV.location = CD.location 
AND CV.date = CD.date
WHERE CD.[continent] IS NOT NULL

SELECT *,
(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--TEMP TABLE (USING DROP TABLE IF EXISTS IF THERE IS CHANGES)
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
CD.continent,
CD.location,
CD.date,
CD.population,
CV.new_vaccinations,
SUM(CONVERT(INT,CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] CD
JOIN [dbo].[CovidVaccinations] CV
ON CV.location = CD.location 
AND CV.date = CD.date
--WHERE CD.[continent] IS NOT NULL

SELECT *,
(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR VISUALIZATION
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
CD.continent,
CD.location,
CD.date,
CD.population,
CV.new_vaccinations,
SUM(CONVERT(INT,CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] CD
JOIN [dbo].[CovidVaccinations] CV
ON CV.location = CD.location 
AND CV.date = CD.date
WHERE CD.[continent] IS NOT NULL

