SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_rpt_tractor_hist3] @StartDate datetime,
					 @EndDate datetime,
					 @Truck varchar(15),
					 @SysTZHrs int,
					 @SysTZMin int,
					 @SysDSTCode int,
					 @UsrTZHrs int,
					 @UsrTZMin int,
					 @UsrDSTCode int,
					 @sUseKM varchar(1)

AS

/***********************************************************
** THIS PROC SHOULD NOT BE SHARED WITH SQL 7.0 SOURCE!!!  **
***********************************************************/

/*****************************************************************
** 07/21/00 MZ: TotalMail based Single Tractor history Report. 
** 08/27/01 DAG: Change state lengths to 6 for International.
** 10/22/01 MZ: Translated report headers
** 11/26/01 MZ: Added TZ conversion calls in new version (2)
**03/23/05 jgf: Added @sUseKM to change heading for Mexicans, Canadians, & Europeans. {19380}
*****************************************************************/

SET NOCOUNT ON 

DECLARE @LargeDirection varchar(3),
	@LargeMiles float,
	@LargeCityName varchar(16),
	@LargeState varchar(6),
	@WorkComment varchar (254),
	@SN int,
	@sT_1 varchar(200), --Used TO Translate strings
	@sT_2 varchar(200),
	@sT_3 varchar(200), 
	@sT_dir varchar(10),
	@TitleDateTime varchar (10),
	@TitleTruck varchar (7),
	@TitleMiles varchar (10),
	@TitleDir varchar (5),
	@TitleIgnition varchar (5),
	@TitleCity varchar (5),
	@TitleState varchar (5),
	@TitleNearestLarge varchar (20)

-- Get all records in date range for this tractor
SELECT  dbo.tblLatLongs.SN,
	TruckName,
	DateAndTime,
	Miles,
	Direction,
	VehicleIgnition,
	CityName,
	State,
	NearestLargeCityName,
	NearestLargeCityState,
	NearestLargeCityDirection,
	NearestLargeCityMiles,
	CONVERT(varchar(254),'') LargeComment
INTO dbo.#tmp1
FROM dbo.tblLatLongs (NOLOCK), dbo.tblTrucks (NOLOCK)
WHERE dbo.tblTrucks.TruckName = @Truck
	AND dbo.tblLatLongs.Unit = dbo.tblTrucks.DefaultCabUnit
	AND DateAndTime BETWEEN @StartDate AND DATEADD(mi, 1439 ,@EndDate)  
ORDER BY DateAndTime

-- Need to construct the nearest large city string
-- Get the first record
SELECT @SN = ISNULL(MIN(SN),0)
FROM dbo.#tmp1

WHILE @SN > 0
  BEGIN
	-- Get the info for this record
	SELECT  @LargeMiles = ISNULL(NearestLargeCityMiles,0),
		@LargeDirection = ISNULL(NearestLargeCityDirection,'Z'),
		@LargeState = ISNULL(NearestLargeCityState,''),
		@LargeCityName = ISNULL(NearestLargeCityName,'')
	FROM dbo.#tmp1
	WHERE SN = @SN	

	-- Construct the Nearest Large City string
	IF @LargeCityName = ''
		SELECT @WorkComment = ''
	ELSE
		IF @LargeMiles = 0
			SELECT @WorkComment = '@ ' + @LargeCityName + ', ' + @LargeState
		ELSE
		  BEGIN
			SELECT @sT_1 = '~1 miles ~2 of ~3, ~4'	-- Translate this string as is
			EXEC dbo.tm_t_sp @sT_1 out, 1, ''

			SELECT @sT_dir = @LargeDirection	-- Translate the direction
			EXEC dbo.tm_t_sp @sT_dir out, 1, ''

			SELECT @sT_2 = CONVERT(varchar(8), @LargeMiles)	-- Convert the miles to a string

			EXEC dbo.tm_sprint @sT_1 out, @sT_2, @sT_dir, @LargeCityName, @LargeState, '', '', '', '', '', ''
			SELECT @WorkComment = @sT_1				
		  END

	IF @WorkComment <> ''
		-- Put the nearest large city string back into the temp table
		UPDATE dbo.#tmp1
		SET LargeComment = @WorkComment
		WHERE SN = @SN

	-- Get the next record
	SELECT @SN = ISNULL(MIN(SN),0)
	FROM dbo.#tmp1
	WHERE SN > @SN 
  END  -- While

-- Translate report headers/title 
SET @TitleDateTime = 'Date/Time'
EXEC dbo.tm_t_sp @TitleDateTime out, 1, ''
SET @TitleTruck = 'Truck'
EXEC dbo.tm_t_sp @TitleTruck out, 1, ''
BEGIN
  IF @sUseKM <> '0'
    SET @TitleMiles = 'KM'
  ELSE
    SET @TitleMiles = 'Miles'
END
EXEC dbo.tm_t_sp @TitleMiles out, 1, ''
SET @TitleDir = 'Dir'
EXEC dbo.tm_t_sp @TitleDir out, 1, ''
SET @TitleIgnition = 'Ign'
EXEC dbo.tm_t_sp @TitleIgnition out, 1, ''
SET @TitleCity = 'City'
EXEC dbo.tm_t_sp @TitleCity out, 1, ''
SET @TitleState = 'St'
EXEC dbo.tm_t_sp @TitleState out, 1, ''
SET @TitleNearestLarge = 'Nearest Large City'
EXEC dbo.tm_t_sp @TitleNearestLarge out, 1, ''
SET @sT_1 = 'POSITION OF VEHICLE ~1 BETWEEN ~2 AND ~3'
EXEC dbo.tm_t_sp @sT_1 out, 1, ''

SET @sT_2 = RTRIM(CONVERT(char, @StartDate, 107))
SET @sT_3 = RTRIM(CONVERT(char, @EndDate, 107))
EXEC dbo.tm_sprint @sT_1 out, @Truck, @sT_2, @sT_3 ,'','','','','','',''

-- Return all the records now
SELECT  TruckName,
	CONVERT(VARCHAR(26), dbo.ChangeTZ(DateAndTime, @SysTZHrs, @SysDSTCode, @SysTZMin, @UsrTZHrs, @UsrDSTCode, @UsrTZMin)) as ckc_date,
	Miles,	
	Direction,	
	VehicleIgnition,
	CityName,
	State,
	LargeComment,
	@sT_1 AS Title,
	@TitleDateTime AS TitleDate,
	@TitleTruck AS TitleTruck, 
	@TitleIgnition AS TitleIgnition, 
	@TitleMiles AS TitleMiles, 
	@TitleDir AS TitleDir,
	@TitleCity as TitleCity, 
	@TitleState as TitleState, 
	@TitleNearestLarge as TitleLarge,
	DateAndTime
FROM dbo.#tmp1
ORDER BY DateAndTime

GO
GRANT EXECUTE ON  [dbo].[tm_rpt_tractor_hist3] TO [public]
GO
