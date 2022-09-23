SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_DriverHomeTime]	
	(
		--Standard Parameters
		@Result DECIMAL(20, 5) OUTPUT, 
		@ThisCount DECIMAL(20, 5) OUTPUT,
		@ThisTotal DECIMAL(20, 5) OUTPUT, 
		@DateStart DATETIME, 
		@DateEnd DATETIME,
		@UseMetricParms INT, 
		@ShowDetail INT,
		--Additional/Optional Parameters
		@Only_mpp_id varchar(128) = '', --Driver ID
		@Only_mpp_teamleader	varchar(128) ='',
		@Only_mpp_fleet		varchar(128) ='',
		@Only_mpp_division	varchar(128) ='',
		@Only_mpp_domicile	varchar(128) ='',
		@Only_mpp_company	varchar(128) ='',
		@Only_mpp_terminal	varchar(128) ='',
		@Only_mpp_type1		varchar(128) ='',
		@Only_mpp_type2		varchar(128) ='',
		@Only_mpp_type3		varchar(128) ='',
		@Only_mpp_type4		varchar(128) ='',
		@Mode varchar(50) = 'Hours', -- 'Nights'
		@DayRange INT = 7,
		@MatchCriteria varchar(1) = 'C' -- 'D' or 'T'

	)

AS

SET NOCOUNT ON

	--Standard Metric Initialization
	/* 	<METRIC-INSERT-SQL>
	
		EXEC MetricInitializeItem
			@sMetricCode = 'DriverHomeTime',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 107, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDECIMAL = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 0,
			@sCaption = 'Driver home time',
			@sCaptionFull = 'Amount of time driver remains at home per week.',
			@sProcedureName = 'Metric_DriverHomeTime',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'
	
		</METRIC-INSERT-SQL>
*/
/*


		declare @Result DECIMAL(20, 5)
		declare @ThisCount DECIMAL(20, 5)
		declare @ThisTotal DECIMAL(20, 5)

		declare @DateStart DATETIME 
		set @DateStart = '07/13/05'
		declare @DateEnd DATETIME 
		set @DateEnd = '07/14/05'
		declare @UseMetricParms INT 
		set @UseMetricParms =0
		declare @ShowDetail INT
		set @ShowDetail =1
		--Additional/Optional Parameters
		drop table #TempHome


DECLARE	@Only_mpp_id varchar(128) , --Driver ID
		@Only_mpp_teamleader	varchar(128) ,
		@Only_mpp_fleet		varchar(128) ,
		@Only_mpp_division	varchar(128) ,
		@Only_mpp_domicile	varchar(128) ,
		@Only_mpp_company	varchar(128) ,
		@Only_mpp_terminal	varchar(128) ,
		@Only_mpp_type1		varchar(128) ,
		@Only_mpp_type2		varchar(128) ,
		@Only_mpp_type3		varchar(128) ,
		@Only_mpp_type4		varchar(128) ,
		@Mode varchar(50) , -- 'Nights'
		@DayRange INT,
		@MatchCriteria varchar(1) 

SET		@Only_mpp_id = '' --Driver ID HOWWIL1
SET		@Only_mpp_teamleader	=''
SET		@Only_mpp_fleet		=''
SET		@Only_mpp_division	=''
SET		@Only_mpp_domicile	=''
SET		@Only_mpp_company	=''
SET		@Only_mpp_terminal	='WITA'
SET		@Only_mpp_type1		=''
SET		@Only_mpp_type2		=''
SET		@Only_mpp_type3		=''
SET		@Only_mpp_type4		=''
SET		@Mode = 'Hours' -- 'Nights'
SET		@DayRange = 7
SET		@MatchCriteria = 'D'
*/


	--Standard Parameter Initialization	
	Set @Only_mpp_id =',' + ISNULL(@Only_mpp_id,'') + ','
	Set @Only_mpp_teamleader= ',' + ISNULL(@Only_mpp_teamleader,'') + ','
	Set @Only_mpp_fleet= ',' + ISNULL(@Only_mpp_fleet,'') + ','
	Set @Only_mpp_division= ',' + ISNULL(@Only_mpp_division,'') + ','
	Set @Only_mpp_domicile= ',' + ISNULL(@Only_mpp_domicile,'') + ','
	Set @Only_mpp_company= ',' + ISNULL(@Only_mpp_company,'') + ','
	Set @Only_mpp_terminal= ',' + ISNULL(@Only_mpp_terminal,'') + ','

	Set @Only_mpp_type1= ',' + ISNULL(@Only_mpp_type1,'') + ','
	Set @Only_mpp_type2= ',' + ISNULL(@Only_mpp_type2,'') + ','
	Set @Only_mpp_type3= ',' + ISNULL(@Only_mpp_type3,'') + ','
	Set @Only_mpp_type4= ',' + ISNULL(@Only_mpp_type4,'') + ','

/*********************************************************************************************
	Step 1:
	
*********************************************************************************************/


--DriverId,Startof hometime, end of home time, domicile, #Hours or # of Nights
--Subtotals

Declare @AssetAssignements Table
(
	rownum int IDENTITY (1, 1) Primary key NOT NULL , 
	asgn_id varchar(13),
	mpp_firstname  varchar(40),
	mpp_middlename varchar(1),
	mpp_lastname varchar(40),
	domicile_name varchar(50),
	mpp_city int,
	end_city int,
	start_city int,
	asgn_date datetime,
	mpp_terminal varchar(50)
)
declare @RowCnt int 
declare @MaxRows int 



CREATE TABLE #TempHome
(   
	mpp_id varchar(8),
	mpp_firstname  varchar(40),
	mpp_middlename varchar(1),
	mpp_lastname varchar(40),
	domicile_name varchar(50),
	mpp_terminal varchar(50),
	mpp_city INT,
	assignment_city int,
	asgn_enddate datetime,
	asgn_begindate datetime,
	home_hours int,
	home_nights int
) 

	DECLARE	@asgn_id varchar(13),
			@mpp_firstname  varchar(40),
			@mpp_middlename varchar(1),
			@mpp_lastname varchar(40),
			@domicile_name varchar(50),
			@mpp_city int,
			@end_city int,
			@start_city int,
			@asgn_date datetime,
			@mpp_terminal varchar(50)



	DECLARE	@Save_asgn_id varchar(13),
			@Save_end_city Int,
			@Save_asgn_date datetime,
			@home_hours int,
			@home_nights int,
			@DayRangeDateStart datetime,
			@IsMatch INT,
			@cityname VARCHAR(50),
			@HasComma INT
			

	Set @DayRangeDateStart = DateAdd(day, -@DayRange, @DateStart)

	insert into @AssetAssignements 
	select asgn_id, 
		mpp_firstname, 
		IsNull(mpp_middlename,''),
		mpp_lastname,
		IsNull(lf.[name], 'UNKNOWN'), 
		mpp_city,
		End_City = (select cmp_city FROM company c (NOLOCK) WHERE c.cmp_id = estops.cmp_id),
		Start_City = (select cmp_city FROM company c (NOLOCK) WHERE c.cmp_id = sstops.cmp_id),
		asgn_date,
		IsNull(Lf2.[name], 'UNKNOWN')
	FROM assetassignment (NOLOCK), event sevent (NOLOCK), stops sstops (NOLOCK), 
		event eevent (NOLOCK), stops estops (NOLOCK), manpowerprofile (NOLOCK)
		left join labelfile Lf (NOLOCK) on mpp_domicile = Lf.abbr and Lf.labeldefinition = 'domicile'
		left join labelfile Lf2 (NOLOCK) on mpp_terminal = Lf2.abbr and Lf2.labeldefinition = 'terminal'
 	WHERE asgn_date BETWEEN @DayRangeDateStart AND @DateEnd
		AND asgn_type = 'DRV'
		AND asgn_ID = mpp_id
		AND assetassignment.evt_number = sevent.evt_number
		AND sevent.stp_number = sstops.stp_number
		AND assetassignment.last_evt_number = eevent.evt_number
		AND eevent.stp_number = estops.stp_number
		AND (@Only_mpp_id =',,' or CHARINDEX(',' + RTRIM( RTRIM( RTRIM( asgn_ID ) ) ) + ',', @Only_mpp_id) >0)
		AND (@Only_mpp_teamleader =',,' or CHARINDEX(',' + RTRIM( RTRIM( mpp_teamleader ) ) + ',', @Only_mpp_teamleader) >0)
		AND (@Only_mpp_fleet =',,' or CHARINDEX(',' + RTRIM( RTRIM( mpp_fleet ) ) + ',', @Only_mpp_fleet) >0)
		AND (@Only_mpp_division =',,' or CHARINDEX(',' + RTRIM( RTRIM( mpp_division ) ) + ',', @Only_mpp_division) >0)
		AND (@Only_mpp_domicile =',,' or CHARINDEX(',' + RTRIM( RTRIM( mpp_domicile ) ) + ',', @Only_mpp_domicile) >0)
		AND (@Only_mpp_company =',,' or CHARINDEX(',' + RTRIM( RTRIM( mpp_company ) ) + ',', @Only_mpp_company) >0)
		AND (@Only_mpp_terminal =',,' or CHARINDEX(',' + RTRIM( RTRIM( mpp_terminal ) ) + ',', @Only_mpp_terminal) >0)
		AND (@Only_mpp_type1 =',,' or CHARINDEX(',' + RTRIM( RTRIM( mpp_type1 ) ) + ',', @Only_mpp_type1) >0)
		AND (@Only_mpp_type2 =',,' or CHARINDEX(',' + RTRIM( RTRIM( mpp_type2 ) ) + ',', @Only_mpp_type2) >0)
		AND (@Only_mpp_type3 =',,' or CHARINDEX(',' + RTRIM( RTRIM( mpp_type3 ) ) + ',', @Only_mpp_type3) >0)
		AND (@Only_mpp_type4 =',,' or CHARINDEX(',' + RTRIM( RTRIM( mpp_type4 ) ) + ',', @Only_mpp_type4) >0)
	order by asgn_id, asgn_date




select @MaxRows=count(*) from @AssetAssignements 

select @RowCnt = 1 

select 	@asgn_id=asgn_id, 
	@mpp_firstname=mpp_firstname,
	@mpp_middlename=mpp_middlename,
	@mpp_lastname=mpp_lastname, 
	@domicile_name=domicile_name, 
	@mpp_city=mpp_city,
	@end_city=end_city, 
	@start_city=start_city,
	@asgn_date=asgn_date,
	@mpp_terminal=mpp_terminal 
from @AssetAssignements
where rownum = @RowCnt 

Select @RowCnt = @RowCnt + 1 

	SET @Save_asgn_id = @asgn_id 
	SET @Save_end_city = @end_city
	SET @Save_asgn_date = @asgn_date 

while @RowCnt <= @MaxRows 
begin 

		IF @Save_asgn_id <> @asgn_id 
			BEGIN
			SET @Save_asgn_id = @asgn_id 
			SET @Save_end_city = @end_city 
			SET @Save_asgn_date = @asgn_date 
			END
		ELSE IF  @start_city = @Save_end_city 
			BEGIN
			SET @IsMatch = 0
			IF @MatchCriteria = 'D'
				BEGIN
				SET @cityname = (select cty_name from city (NOLOCK) where cty_code = @end_city)
				SET @HasComma = IsNULL(CHARINDEX(',', @domicile_name),0)
				IF @HasComma = 0 
					IF IsNull(CHARINDEX(@domicile_name, @cityname),0) > 0
						SET @IsMatch = 1

				IF @HasComma > 1
					IF IsNull(CHARINDEX(LEFT(@domicile_name, (@HasComma - 1)), @cityname),0) > 1
						SET @IsMatch = 1
				END
			ELSE IF @MatchCriteria = 'T'
				BEGIN
				SET @cityname = (select cty_name from city (NOLOCK) where cty_code = @end_city)
				SET @HasComma = IsNULL(CHARINDEX(',', @mpp_terminal),0)
				IF @HasComma = 0 
					IF IsNull(CHARINDEX(@mpp_terminal, @cityname),0) > 0
						SET @IsMatch = 1
	
				IF @HasComma > 1
					IF IsNull(CHARINDEX(LEFT(@mpp_terminal, (@HasComma - 1)), @cityname),0) > 1
						SET @IsMatch = 1
				END
			ELSE IF @mpp_city = @end_city 
					SET @IsMatch = 1

			IF @IsMatch = 1
				BEGIN
				SET @home_hours = round(Convert(Float, DateDiff(mi, @Save_asgn_date, @asgn_date)) / 60 ,0)
				SET @home_nights = convert(int, cast(floor(cast(@asgn_date as float)) as datetime) - cast(floor(cast(@Save_asgn_date as float)) as datetime))
			
				INSERT INTO #TempHome
				VALUES(@asgn_id, 
					@mpp_firstname, 
					@mpp_middlename, 
					@mpp_lastname, 
					@domicile_name, 
					@mpp_terminal,
					@mpp_city,
					@end_city, 
					@Save_asgn_date, 
					@asgn_date, 
					@home_hours, 
					@home_nights)
				END
			END
		SET @Save_asgn_id = @asgn_id 
		SET @Save_end_city = @end_city 
		SET @Save_asgn_date = @asgn_date 

	select 	@asgn_id=asgn_id, 
		@mpp_firstname=mpp_firstname,
		@mpp_middlename=mpp_middlename,
		@mpp_lastname=mpp_lastname, 
		@domicile_name=domicile_name, 
		@mpp_city=mpp_city,
		@end_city=end_city, 
		@start_city=start_city,
		@asgn_date=asgn_date,
		@mpp_terminal=mpp_terminal 
	from @AssetAssignements
	where rownum = @RowCnt 

	Select @RowCnt = @RowCnt + 1 

	END

	
	IF @Mode = 'Hours'
		SET @ThisCount = (SELECT sum(ISNULL(home_hours, 0)) from #TempHome) 
	ELSE
		SET @ThisCount = (SELECT sum(ISNULL(home_nights, 0)) from #TempHome) 

	SET @ThisTotal = (Select count(distinct mpp_id) from #TempHome)

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	If @ShowDetail = 1
		SELECT 'Y' as [Subtotal], 
					mpp_id AS [Driver ID], 
					mpp_firstname AS [First], 
					mpp_middlename AS [MI], 
					mpp_lastname AS [Last], 
					domicile_name AS [MPP Domicile], 
					mpp_terminal AS [MPP Terminal], 
					(SELECT cty_nmstct FROM city c (NOLOCK) WHERE cty_code = mpp_city) AS [MPP City], 
					(SELECT cty_nmstct FROM city c (NOLOCK) WHERE cty_code = assignment_city) AS [Dispatched City], 
					'Total for (' + mpp_id + ') ->' AS [Arrive Date], 
					LEFT(left(mpp_firstname,1) + ' ' + mpp_middlename + ' ' +  left(mpp_lastname,16), 18) AS [Depart Date], 
					sum(home_hours) as [Hours home], 
					sum(home_nights) as [Nights home]
					from #TempHome group by mpp_id, mpp_firstname, mpp_middlename, mpp_lastname, domicile_name, mpp_terminal, mpp_city, assignment_city 
		UNION
		SELECT 'N' as [Subtotal], 
					mpp_id AS [Driver ID], 
					mpp_firstname AS [First], 
					mpp_middlename AS [MI], 
					mpp_lastname AS [Last], 
					domicile_name AS [MPP Domicile], 
					mpp_terminal AS [MPP Terminal], 
					(SELECT cty_nmstct FROM city c (NOLOCK) WHERE cty_code = mpp_city) AS [MPP City], 
					(SELECT cty_nmstct FROM city c (NOLOCK) WHERE cty_code = assignment_city) AS [Dispatched City], 
					CONVERT(VARCHAR(18), asgn_enddate) AS [Arrive Date], 
					CONVERT(VARCHAR(18), asgn_begindate) AS [Depart Date], 
					home_hours as [Hours home], 
					home_nights as [Nights home]  
					from #TempHome 
		Order by  mpp_id, subtotal 

GO
GRANT EXECUTE ON  [dbo].[Metric_DriverHomeTime] TO [public]
GO
