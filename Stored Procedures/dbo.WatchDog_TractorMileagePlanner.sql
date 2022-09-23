SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- WatchDogProcessing 'drivermileageplanner',1
CREATE Proc [dbo].[WatchDog_TractorMileagePlanner] 
(	
	@MinThreshold float = 2500,
	@MinsBack int=-20,
	@DaysBackToCheck int=7,
	@DaysFutureToCheck int=0,
	@TempTableName varchar(255) = '##WatchDogGlobalTractorMileagePlanner',
	@WatchName varchar(255)='WatchTractorMileagePlanner',
	@ThresholdFieldName varchar(255) = 'Miles',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar(50) = 'Selected',
	@TrcType1 varchar(255)='',
	@TrcType2 varchar(255)='',
	@TrcType3 varchar(255)='',
	@TrcType4 varchar(255)='',
	@TeamLeader varchar(255)='',
	@TrcFleet varchar(255)='',
	@TrcDivision varchar(255)='',
	@TrcCompany varchar(255)='',
	@TrcTerminal varchar(255)='',
	@RevType1 varchar(255)='',
	@RevType2 varchar(255)='',
	@RevType3 varchar(255)='',
	@RevType4 varchar(255)='',
	@DispatchStatus varchar(140)='DSP,PLN,STD,CMP',
	@ExpirationCode varchar(255) = 'OUT',
	@DailyMilesMinimum int = 0,
	@AddMileageForExpirationsYN char(1)= 'Y',
	@ExcludeTrcFleet varchar(255)=''

)
						
As

SET NOCOUNT On

/*
Procedure Name:    WatchDog_DriverMileagePlanner
Author/CreateDate: Brent Keeton / 6-15-2004
Purpose: 	   Returns all empty legs above a specific threshold
Revision History:
*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

Declare @DateStart datetime
Declare @DateEnd datetime
Declare @currdate datetime
Declare @DayCount int

SET @currdate = cast(CONVERT(VARCHAR,getdate(),101) as datetime)

--Resolve the beginning of the week
SET @DateStart = DateAdd(d,-@DaysBackToCheck,@currdate)

SET @DateEnd = DateAdd(d,@DaysFutureToCheck,@currdate)

SET @DayCount = (Datediff(day,@DateStart,@DateEnd))

SET @TrcType1= ',' + ISNULL(@TrcType1,'') + ','
SET @TrcType2= ',' + ISNULL(@TrcType2,'') + ','
SET @TrcType3= ',' + ISNULL(@TrcType3,'') + ','
SET @TrcType4= ',' + ISNULL(@TrcType4,'') + ','
SET @TeamLeader= ',' + ISNULL(@TeamLeader,'') + ','
SET @TrcFleet= ',' + ISNULL(@TrcFleet,'') + ','
SET @TrcDivision= ',' + ISNULL(@TrcDivision,'') + ','
SET @TrcCompany= ',' + ISNULL(@TrcCompany,'') + ','
SET @TrcTerminal= ',' + ISNULL(@TrcTerminal,'') + ','
SET @RevType1= ',' + ISNULL(@RevType1,'') + ','
SET @RevType2= ',' + ISNULL(@RevType2,'') + ','
SET @RevType3= ',' + ISNULL(@RevType3,'') + ','
SET @RevType4= ',' + ISNULL(@RevType4,'') + ','
SET @DispatchStatus= ',' + ISNULL(@DispatchStatus,'') + ','
SET @ExpirationCode= ',' + ISNULL(@ExpirationCode,'') + ','
SET @ExcludeTrcFleet= ',' + ISNULL(@ExcludeTrcFleet,'') + ','


SELECT 	trc_number as [Tractor ID],
        --'Driver' = IsNull(mpp_lastfirst,lgh_driver1),
		Miles = IsNull((SELECT sum(IsNull(stp_lgh_mileage,0)) FROM stops (NOLOCK) where stops.lgh_number = legheader.lgh_number),0)
INTO   #TractorList
FROM  	tractorprofile (NOLOCK)
		LEFT JOIN legheader (NOLOCK) On tractorprofile.trc_number = legheader.lgh_tractor	
Where (@TrcType1 =',,' OR CHARINDEX(',' + tractorprofile.trc_type1 + ',', @TrcType1) >0)
	AND (@TrcType2 =',,' OR CHARINDEX(',' + tractorprofile.trc_type2 + ',', @TrcType2) >0)
	AND (@TrcType3 =',,' OR CHARINDEX(',' + tractorprofile.trc_type3 + ',', @TrcType3) >0)
	AND (@TrcType4 =',,' OR CHARINDEX(',' + tractorprofile.trc_type4 + ',', @TrcType4) >0)
	--AND (@TeamLeader =',,' OR CHARINDEX(',' + manpowerprofile.mpp_TeamLeader + ',', @TeamLeader) >0)
	AND (@TrcFleet =',,' OR CHARINDEX(',' + tractorprofile.trc_Fleet + ',', @TrcFleet) >0)
	AND (@TrcDivision =',,' OR CHARINDEX(',' + tractorprofile.trc_Division + ',', @TrcDivision) >0)
	AND (@TrcCompany =',,' OR CHARINDEX(',' + tractorprofile.trc_Company + ',', @TrcCompany) >0)
	AND (@TrcTerminal =',,' OR CHARINDEX(',' + tractorprofile.trc_Terminal + ',', @TrcTerminal) >0)
	AND (@RevType1 =',,' OR CHARINDEX(',' + lgh_class1 + ',', @RevType1) >0)
	AND (@RevType2 =',,' OR CHARINDEX(',' + lgh_class2 + ',', @RevType2) >0)
	AND (@RevType3 =',,' OR CHARINDEX(',' + lgh_class3 + ',', @RevType3) >0)
	AND (@RevType4 =',,' OR CHARINDEX(',' + lgh_class4 + ',', @RevType4) >0)
	AND ((trc_retiredate is null or trc_retiredate >= @DateStart) AND trc_startdate < @DateStart)
	AND (
			(lgh_number Is Null)
				OR 
			(lgh_enddate >= @DateStart AND lgh_enddate < @DateEnd AND (@DispatchStatus =',,' OR CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatus) >0))
	 	)
	AND (@ExcludeTrcFleet =',,' OR CHARINDEX(',' + tractorprofile.trc_Fleet + ',', @ExcludeTrcFleet) =0)

--Add Mileage For Expirations During the Week (Based on Minimum)
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx
If @AddMileageForExpirationsYN = 'Y' 
Begin
	UPDATE #TractorList SET Miles = Miles + IsNull((@DailyMilesMinimum * dbo.fnc_TMWRN_TotalTractorExpirations(@DateStart,@DateEnd,[Tractor ID],@ExpirationCode)),0)
End

SELECT [Tractor ID] , Sum(ISNULL(Miles,0)) Miles
INTO #TractorListDistinct
FROM #TractorList
Group by [Tractor ID]

--Leave only the drivers that have not met week minimum
DELETE FROM #TractorListDistinct 
Where Miles > @MinThreshold

--  Leave only the drivers that have not met the total of day's minumum * the number of workdays that have past so far in the week
IF @DailyMilesMinimum > 0
	DELETE FROM #TractorListDistinct
	WHERE Miles > @DayCount * @DailyMilesMinimum

SELECT * 
INTO #TempResults
FROM #TractorListDistinct
ORDER BY miles

--Commits the results to be used in the wrapper
If @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
Begin
	SET @SQL = 'SELECT * FROM #TempResults'
End
Else
Begin
	SET @COLSQL = ''
	Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	SET @SQL = 'SELECT identity(int,1,1) as RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
End

Exec (@SQL)

GO
