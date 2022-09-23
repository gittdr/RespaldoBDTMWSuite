SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_rpt_tractor_hist4]	@StartDate datetime,
					@EndDate datetime,
					@Truck varchar (8),
					@sUseKM varchar(1)

AS

/* 05/12/99 MZ: Single Tractor history Report. 
 * 10/22/01 MZ: Translated report headers  
* 03/23/05 jgf: Added @sUseKM to change heading for Mexicans, Canadians, & Europeans. {19380}*/

SET NOCOUNT ON 

DECLARE @sT_1 VARCHAR(200), 
		@sT_2 VARCHAR(200), 
		@sT_3 VARCHAR(200), --Used TO Translate strings
	    @TitleDateTime varchar (10),
	    @TitleTruck varchar (7),
	    @TitleMiles varchar (10),
	    @TitleDir varchar (5),
	    @TitleIgnition varchar (5),
	    @TitleCity varchar (5),
	    @TitleState varchar (5),
	    @TitleNearestLarge varchar (20)

SET @TitleDateTime = 'Date/Time'
--EXEC dbo.tm_t_sp @TitleDateTime out, 1, ''
SET @TitleTruck = 'Truck'
--EXEC dbo.tm_t_sp @TitleTruck out, 1, ''
BEGIN
  IF @sUseKM <> '0'
    SET @TitleMiles = 'KM'
  ELSE
    SET @TitleMiles = 'Miles'
END
--EXEC dbo.tm_t_sp @TitleMiles out, 1, ''
SET @TitleDir = 'Dir'
--EXEC dbo.tm_t_sp @TitleDir out, 1, ''
SET @TitleIgnition = 'Ign'
--EXEC dbo.tm_t_sp @TitleIgnition out, 1, ''
SET @TitleCity = 'City'
--EXEC dbo.tm_t_sp @TitleCity out, 1, ''
SET @TitleState = 'St'
--EXEC dbo.tm_t_sp @TitleState out, 1, ''
SET @TitleNearestLarge = 'Nearest Large City'
--EXEC dbo.tm_t_sp @TitleNearestLarge out, 1, ''
SET @sT_1 = 'POSITION OF VEHICLE ~1 BETWEEN ~2 AND ~3'
-- EXEC dbo.tm_t_sp @sT_1 out, 1, ''

SELECT @sT_2 = RTRIM(CONVERT(char, @StartDate, 107))
SELECT @sT_3 = RTRIM(CONVERT(char, @EndDate, 107))
EXEC dbo.tmail_sprint @sT_1 out, @Truck, @sT_2, @sT_3 ,'','','','','','',''

SELECT  ckc_Tractor,
	CONVERT(VARCHAR(26), ckc_date),
	ckc_milesfrom,
	ckc_directionfrom,
	ckc_vehicleignition,
	ckc_cityname,
	ckc_state,
	ckc_commentlarge,
	@sT_1 AS Title,
	@TitleDateTime AS TitleDate,
	@TitleTruck AS TitleTruck, 
    @TitleIgnition AS TitleIgnition, 
	@TitleMiles AS TitleMiles, 
	@TitleDir AS TitleDir,
	@TitleCity as TitleCity, 
	@TitleState as TitleState, 
	@TitleNearestLarge as TitleLarge
FROM checkcall (NOLOCK)
WHERE ckc_tractor = @Truck
	AND ckc_date BETWEEN @StartDate AND DATEADD(mi, 1439 ,@EndDate)  
ORDER BY ckc_date 

GO
GRANT EXECUTE ON  [dbo].[tmail_rpt_tractor_hist4] TO [public]
GO
