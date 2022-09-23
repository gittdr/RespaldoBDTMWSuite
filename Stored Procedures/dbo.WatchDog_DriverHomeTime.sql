SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_DriverHomeTime] 
(
	@MinThreshold float = 0,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalDriverHomeTime',
	@WatchName varchar(255) = 'DriverHomeTime',
	@ThresholdFieldName varchar(255) = 'Hours',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
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
	@MatchCriteria varchar(1) = 'C', -- 'D' or 'T'
	@ParameterToUseForDynamicEmail varchar(50) = '' 

)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_DriverHomeTime
	Author/CreateDate: David Wilks/ 7-14-2005
	Purpose: 	    Returns Drivers who are due for some time at home
	Revision History:
	*/

	/*
	if not exists (select WatchName from WatchDogItem where WatchName = 'DriverHomeTime')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	 VALUES ('DriverHomeTime','12/30/1899','12/30/1899','WatchDog_DriverHomeTime','','',0,0,'','','','','',1,0,'','','')
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
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

Declare @AssetAssignements Table
(
	rownum int IDENTITY (1, 1) Primary key NOT NULL , 
	asgn_id varchar(13),
	mpp_firstname  varchar(40),
	mpp_middlename varchar(1),
	mpp_lastname varchar(40),
	domicile_name varchar(50),
	terminal_name varchar(50),
	mpp_city int,
	end_city int,
	start_city int,
	asgn_date datetime,
	mpp_company varchar(6),
	mpp_division varchar(6), 
	mpp_domicile varchar(6),
	mpp_type1 varchar(6), 
	mpp_type2 varchar(6), 
	mpp_type3 varchar(6), 
	mpp_type4 varchar(6), 
	mpp_teamleader varchar(6),
	mpp_terminal varchar(6)
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
	terminal_name varchar(50),
	mpp_city INT,
	assignment_city int,
	asgn_enddate datetime,
	asgn_begindate datetime,
	home_hours int,
	home_nights int,
	mpp_company varchar(6),
	mpp_division varchar(6), 
	mpp_domicile varchar(6),
	mpp_type1 varchar(6), 
	mpp_type2 varchar(6), 
	mpp_type3 varchar(6), 
	mpp_type4 varchar(6), 
	mpp_teamleader varchar(6),
	mpp_terminal varchar(6)
) 

	DECLARE	@asgn_id varchar(13),
			@mpp_firstname  varchar(40),
			@mpp_middlename varchar(1),
			@mpp_lastname varchar(40),
			@domicile_name varchar(50),
			@terminal_name varchar(50),
			@mpp_city int,
			@end_city int,
			@start_city int,
			@asgn_date datetime,
			@mpp_company varchar(6),
			@mpp_division varchar(6), 
			@mpp_domicile varchar(6),
			@mpp_type1 varchar(6), 
			@mpp_type2 varchar(6), 
			@mpp_type3 varchar(6), 
			@mpp_type4 varchar(6), 
			@mpp_teamleader varchar(6),
			@mpp_terminal varchar(6)


	DECLARE	@Save_asgn_id varchar(13),
			@Save_end_city Int,
			@Save_asgn_date datetime,
			@home_hours int,
			@home_nights int,
			@DayRangeDateStart datetime,
			@IsMatch INT,
			@cityname VARCHAR(50),
			@HasComma INT,
			@DateStart datetime,
			@DateEnd datetime
			
	Set @DateEnd = GetDate()
	Set @DateStart = GetDate()
	Set @DayRangeDateStart = DateAdd(day, -@DayRange, @DateStart)

	insert into @AssetAssignements 
	select asgn_id, 
		mpp_firstname, 
		IsNull(mpp_middlename,''),
		mpp_lastname,
		IsNull(lf.[name], 'UNKNOWN'), 
		IsNull(Lf2.[name], 'UNKNOWN'),
		mpp_city,
		End_City = (select cmp_city FROM company c (NOLOCK) WHERE c.cmp_id = estops.cmp_id),
		Start_City = (select cmp_city FROM company c (NOLOCK) WHERE c.cmp_id = sstops.cmp_id),
		asgn_date,
		mpp_company,
		mpp_division, 
		mpp_domicile,
		mpp_type1, 
		mpp_type2, 
		mpp_type3, 
		mpp_type4, 
		mpp_teamleader,
		mpp_terminal
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
		AND (@Only_mpp_id =',,' or CHARINDEX(',' + asgn_ID + ',', @Only_mpp_id) >0)
		AND (@Only_mpp_teamleader =',,' or CHARINDEX(',' + mpp_teamleader + ',', @Only_mpp_teamleader) >0)
		AND (@Only_mpp_fleet =',,' or CHARINDEX(',' + mpp_fleet + ',', @Only_mpp_fleet) >0)
		AND (@Only_mpp_division =',,' or CHARINDEX(',' + mpp_division + ',', @Only_mpp_division) >0)
		AND (@Only_mpp_domicile =',,' or CHARINDEX(',' + mpp_domicile + ',', @Only_mpp_domicile) >0)
		AND (@Only_mpp_company =',,' or CHARINDEX(',' + mpp_company + ',', @Only_mpp_company) >0)
		AND (@Only_mpp_terminal =',,' or CHARINDEX(',' + mpp_teamleader + ',', @Only_mpp_terminal) >0)
		AND (@Only_mpp_type1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @Only_mpp_type1) >0)
		AND (@Only_mpp_type2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @Only_mpp_type2) >0)
		AND (@Only_mpp_type3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @Only_mpp_type3) >0)
		AND (@Only_mpp_type4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @Only_mpp_type4) >0)
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
	@mpp_terminal=mpp_terminal,
	@mpp_company=mpp_company, 
	@mpp_division=mpp_division, 
	@mpp_domicile=mpp_domicile, 
	@mpp_type1=mpp_type1, 
	@mpp_type2=mpp_type2, 
	@mpp_type3=mpp_type3, 
	@mpp_type4=mpp_type4, 
	@mpp_teamleader=mpp_teamleader, 
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
					@terminal_name, 
					@mpp_city,
					@end_city, 
					@Save_asgn_date, 
					@asgn_date, 
					@home_hours, 
					@home_nights,
					@mpp_company, 
					@mpp_division, 
					@mpp_domicile, 
					@mpp_type1, 
					@mpp_type2, 
					@mpp_type3, 
					@mpp_type4, 
					@mpp_teamleader, 
					@mpp_terminal
				)
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
	@mpp_terminal=mpp_terminal, 
	@mpp_company=mpp_company, 
	@mpp_division=mpp_division, 
	@mpp_domicile=mpp_domicile, 
	@mpp_type1=mpp_type1, 
	@mpp_type2=mpp_type2, 
	@mpp_type3=mpp_type3, 
	@mpp_type4=mpp_type4, 
	@mpp_teamleader=mpp_teamleader, 
	@mpp_terminal=mpp_terminal
from @AssetAssignements
where rownum = @RowCnt 

Select @RowCnt = @RowCnt + 1 
	END

		SELECT 	mpp_id AS [Driver ID], 
				mpp_firstname AS [First], 
				mpp_middlename AS [MI], 
				mpp_lastname AS [Last], 
				domicile_name AS [MPP Domicile], 
				terminal_name AS [MPP Terminal], 
				(SELECT cty_nmstct FROM city c (NOLOCK) WHERE cty_code = mpp_city) AS [MPP City], 
				(SELECT cty_nmstct FROM city c (NOLOCK) WHERE cty_code = assignment_city) AS [Dispatched City], 
				sum(home_hours) as [Hours home], 
				sum(home_nights) as [Nights home],
				ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, mpp_company,mpp_division, mpp_domicile,default, mpp_type1, mpp_type2, mpp_type3, mpp_type4,default,default ,default ,default ,default , mpp_teamleader, mpp_terminal,default, default , default ,default ,default , default,default,default,default,default,default),'') AS EmailSend 
		INTO #TempResults
				from #TempHome 
				group by mpp_id, mpp_firstname, mpp_middlename, mpp_lastname, domicile_name, terminal_name, mpp_city, assignment_city, mpp_company, mpp_division, mpp_domicile, mpp_type1, mpp_type2, mpp_type3, mpp_type4, mpp_teamleader, mpp_terminal 
				HAVING @Mode = 'Hours' AND sum(home_hours) < @MinThreshold
				OR    @Mode = 'Nights' AND sum(home_nights) < @MinThreshold


	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	
	Begin
		Set @SQL = 'Select * from #TempResults Order by [Hours home]'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
	End
	
	Exec (@SQL)
	
	Set NoCount Off
GO
GRANT EXECUTE ON  [dbo].[WatchDog_DriverHomeTime] TO [public]
GO
