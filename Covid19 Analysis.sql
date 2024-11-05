SELECT *
FROM portfolio..CovidDeaths

SELECT *
FROM portfolio..CovidVaccinations






SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,	 
	vacc.total_vaccinations, 
	vacc.new_vaccinations, 
	SUM(CAST(vacc.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccinated
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vacc
	ON  dea.location = vacc.location 
	AND dea.date = vacc.date
WHERE dea.continent is not null
ORDER BY 2, 3



--USING A CTE

WITH PopvsVacc (
	Continent, 
	Location, 
	Date, 
	Population, 
	Total_Vaccinations, 
	New_Vaccinations, 
	RollingPeopleVaccinated
)
AS 
(
	SELECT 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population,	 
		vacc.total_vaccinations, 
		vacc.new_vaccinations, 
		SUM(CAST(vacc.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
		dea.date) AS RollingPeopleVaccinated
	FROM portfolio..CovidDeaths dea
	JOIN portfolio..CovidVaccinations vacc
		ON  dea.location = vacc.location 
		AND dea.date = vacc.date
	WHERE dea.continent is not null 
	--ORDER BY 2, 3
)


SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM PopvsVacc





-- Check if the temp table exists and drop it if it does
IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
   DROP TABLE #PercentPopulationVaccinated;

DROP TABLE IF EXISTS #PercentPopulationVaccinated
-- Create the temporary table
CREATE TABLE #PercentPopulationVaccinated
(
   Continent nvarchar(255),
   Location nvarchar(255),
   Date datetime,
   Population numeric,
   Total_Vaccinations numeric,
   New_vaccinations numeric, 
   RollingPeopleVaccinated numeric
);

-- Insert data into the temporary table
INSERT INTO #PercentPopulationVaccinated
SELECT 
   dea.continent, 
   dea.location, 
   dea.date, 
   dea.population,	
   vacc.total_vaccinations, 
   vacc.new_vaccinations, 
   SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vacc
   ON dea.location = vacc.location 
   AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL;

-- Select data with the calculated percentage
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;



--Global Number
SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, 
SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage 
FROM portfolio..CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2





--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE View PercPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,	
    vacc.total_vaccinations, 
    vacc.new_vaccinations, 
    SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio..CovidDeaths dea
JOIN portfolio..CovidVaccinations vacc
    ON dea.location = vacc.location 
    AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL;
