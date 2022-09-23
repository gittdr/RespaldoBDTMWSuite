SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- WatchDogProcessing 'drivermileageplanner',1
CREATE Proc [dbo].[WatchDog_DriverMileagePlanner] 
(
	--Standard Parameters
	@MinThreshold float = 2500,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalDriverMileagePlanner',
	@WatchName varchar(255)='WatchDriverMileagePlanner',
	@ThresholdFieldName varchar(255) = 'Miles',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar(50) = 'Selected',
	--Additional/Optional Parameters
	@ThresholdDirection varchar(10) = 'Below',
	@DrvType1 varchar(255)='',
	@DrvType2 varchar(255)='',
	@DrvType3 varchar(255)='',
	@DrvType4 varchar(255)='',
	@TeamLeader varchar(255)='',
	@DrvFleet varchar(255)='',
	@DrvDivision varchar(255)='',
	@DrvDomicile varchar(255)='',
	@DrvCompany varchar(255)='',
	@DrvTerminal varchar(255)='',
	@RevType1 varchar(255)='',
	@RevType2 varchar(255)='',
	@RevType3 varchar(255)='',
	@RevType4 varchar(255)='',
	@DispatchStatus varchar(140)='DSP,PLN,STD,CMP',
	@LoadedStatus varchar(140)='ALL',
	@PriorityStatus varchar(255) = '9',
	@DailyMilesMinimum int = 500,
	@AddMileageForExpirationsYN char(1)= 'Y',
	@ExcludeDrvDomicile varchar(255)= '',
	@FirstDayOfWeek int = '7', -- 7=Sunday 1=Monday
	@UseRunningDaysBackYN char(1) = 'N', --Set to N to run current week Monday-Sunday, Set Y to run X Days Back
	@DaysBack int = '7',
	@ExcludeDriverStatus varchar(255)=''
)
						

As

	Set NoCount On
	
	
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
	

	IF @UseRunningDaysBackYN <> 'N'
	BEGIN
		Set @currdate = CAST(CONVERT(VARCHAR,GETDATE(),101) AS DATETIME)
		Set @DateStart = DATEADD(dd, -@DaysBack, @currdate)
		Set @DateEnd = GETDATE()
	END
	ELSE
	BEGIN
		Set DateFirst @FirstDayOfWeek

		Set @currdate = cast(CONVERT(VARCHAR,getdate(),101) as datetime)
	
		--Resolve the beginning of the week
		Set @DateStart = cast(CONVERT(VARCHAR, CASE DATEPART(dw, getdate())
	                               WHEN 1 THEN getdate()
	                               WHEN 2 THEN DATEADD(dd, -1, getdate())
	                               WHEN 3 THEN DATEADD(dd, -2, getdate())
	                               WHEN 4 THEN DATEADD(dd, -3, getdate())
	                               WHEN 5 THEN DATEADD(dd, -4, getdate())
	                               WHEN 6 THEN DATEADD(dd, -5, getdate())
	                               WHEN 7 THEN DATEADD(dd, -6, getdate())
	                             END ,101) as datetime)
	
		Set @DateEnd = cast(CONVERT(VARCHAR, CASE DATEPART(dw, getdate() )
	                               WHEN 1 THEN DATEADD(dd, 6, getdate())
	                               WHEN 2 THEN DATEADD(dd, 5, getdate())
	                               WHEN 3 THEN DATEADD(dd, 4, getdate())
	                               WHEN 4 THEN DATEADD(dd, 3, getdate())
	                               WHEN 5 THEN DATEADD(dd, 2, getdate())
	                               WHEN 6 THEN DATEADD(dd, 1, getdate())
	                               WHEN 7 THEN getdate()
	                             END ,101) as datetime)
	END

	Set @DayCount = (Datediff(day,@DateStart,getdate()))

	Set @DrvType1= ',' + ISNULL(@DrvType1,'') + ','
	Set @DrvType2= ',' + ISNULL(@DrvType2,'') + ','
	Set @DrvType3= ',' + ISNULL(@DrvType3,'') + ','
	Set @DrvType4= ',' + ISNULL(@DrvType4,'') + ','
	Set @TeamLeader= ',' + ISNULL(@TeamLeader,'') + ','
	Set @DrvFleet= ',' + ISNULL(@DrvFleet,'') + ','
	Set @DrvDivision= ',' + ISNULL(@DrvDivision,'') + ','
	Set @DrvDomicile= ',' + ISNULL(@DrvDomicile,'') + ','
	Set @DrvCompany= ',' + ISNULL(@DrvCompany,'') + ','
	Set @DrvTerminal= ',' + ISNULL(@DrvTerminal,'') + ','
	Set @RevType1= ',' + ISNULL(@RevType1,'') + ','
	Set @RevType2= ',' + ISNULL(@RevType2,'') + ','
	Set @RevType3= ',' + ISNULL(@RevType3,'') + ','
	Set @RevType4= ',' + ISNULL(@RevType4,'') + ','
	Set @DispatchStatus= ',' + ISNULL(@DispatchStatus,'') + ','
	Set @ExcludeDrvDomicile= ',' + ISNULL(@ExcludeDrvDomicile,'') + ','
	Set @ExcludeDriverStatus= ',' + ISNULL(@ExcludeDriverStatus,'') + ','
	
	Select 
	         mpp_id as [Driver ID],
	        'Driver' = IsNull(mpp_lastfirst,lgh_driver1),
			/*Miles = IsNull((	select sum(IsNull(stp_lgh_mileage,0)) 
								from stops (NOLOCK) 
								where stops.lgh_number = legheader.lgh_number
							),0),*/
			Miles = dbo.fnc_tmwrn_miles(default,default,default,default,default,legheader.lgh_number,default,@LoadedStatus,default,default,default),
			lgh_driver2 as [Driver2],
			manpowerprofile.mpp_teamleader as [TeamLeader],
			mpp_tractornumber as [Tractor],
			manpowerprofile.mpp_Type1 as [DrvType1],
			manpowerprofile.mpp_Type2 as [DrvType2],
			manpowerprofile.mpp_Type3 as [DrvType3],
			manpowerprofile.mpp_Type4 as [DrvType4],
			'N' as Expirations,
			0 as Last30DayMileage
	into   #DriverList
	From  	manpowerprofile (NOLOCK) Left Join legheader (NOLOCK) On manpowerprofile.mpp_id = legheader.lgh_driver1	
	Where	(@DrvType1 =',,' or CHARINDEX(',' + manpowerprofile.mpp_type1 + ',', @DrvType1) >0)
		AND (@DrvType2 =',,' or CHARINDEX(',' + manpowerprofile.mpp_type2 + ',', @DrvType2) >0)
		AND (@DrvType3 =',,' or CHARINDEX(',' + manpowerprofile.mpp_type3 + ',', @DrvType3) >0)
		AND (@DrvType4 =',,' or CHARINDEX(',' + manpowerprofile.mpp_type4 + ',', @DrvType4) >0)
		And (@TeamLeader =',,' or CHARINDEX(',' + manpowerprofile.mpp_TeamLeader + ',', @TeamLeader) >0)
		And (@DrvFleet =',,' or CHARINDEX(',' + manpowerprofile.mpp_Fleet + ',', @DrvFleet) >0)
		And (@DrvDivision =',,' or CHARINDEX(',' + manpowerprofile.mpp_Division + ',', @DrvDivision) >0)
		And (@DrvDomicile =',,' or CHARINDEX(',' + manpowerprofile.mpp_Domicile + ',', @DrvDomicile) >0)
		And (@DrvCompany =',,' or CHARINDEX(',' + manpowerprofile.mpp_Company + ',', @DrvCompany) >0)
		And (@DrvTerminal =',,' or CHARINDEX(',' + manpowerprofile.mpp_Terminal + ',', @DrvTerminal) >0)
		And (@RevType1 =',,' or CHARINDEX(',' + lgh_class1 + ',', @RevType1) >0)
		AND (@RevType2 =',,' or CHARINDEX(',' + lgh_class2 + ',', @RevType2) >0)
		AND (@RevType3 =',,' or CHARINDEX(',' + lgh_class3 + ',', @RevType3) >0)
		AND (@RevType4 =',,' or CHARINDEX(',' + lgh_class4 + ',', @RevType4) >0)
		And (mpp_terminationdt >= @DateStart AND mpp_hiredate < @DateStart)
		And (@ExcludeDriverStatus =',,' or CHARINDEX(',' + manpowerprofile.mpp_status + ',', @ExcludeDriverStatus) =0)
		And (@ExcludeDrvDomicile =',,' or CHARINDEX(',' + manpowerprofile.mpp_Domicile + ',', @ExcludeDrvDomicile) =0)
		And (
				(lgh_number Is Null)
				    OR 
				(lgh_enddate >= @DateStart and lgh_enddate < @DateEnd And (@DispatchStatus =',,' or CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatus) >0))
			)
	
	
	--Deletes 2nd driver of team based on if they are any trips that they have been on with driver 1
	Delete from #DriverList
	-- For Drivers on at least on leg- Maybe for the future?
	--  Where [Driver ID] In (select [Driver2] from #DriverList)
	WHERE [Driver ID] in (Select trc_driver2 from tractorprofile (NOLOCK))
	
	Select
		[Driver ID],
		[Driver],
		sum(IsNull(miles,0)) as Miles,
		[TeamLeader],
		[Tractor],
		[DrvType1],
		[DrvType2],
		[DrvType3],
		[DrvType4],
		Expirations,
		Last30DayMileage
	into    #NewDriverList
	From    #DriverList
	Group By [Driver ID],[Driver],[TeamLeader],[Tractor],[DrvType1],[DrvType2],[DrvType3],[DrvType4], Expirations,Last30DayMileage
	
	
	--Add Mileage For Expirations During the Week (Based on Minimum)
	
	If @AddMileageForExpirationsYN = 'Y' 
	Begin
		Update #NewDriverList Set Miles = Miles + IsNull((@DailyMilesMinimum * dbo.fnc_TMWRN_TotalDriverExpirations(@DateStart,@DateEnd,[Driver ID],@PriorityStatus)),0)
		
		Update #NewDriverList 
		Set Expirations = 'Y'
		Where isnull((dbo.fnc_TMWRN_TotalDriverExpirations(@DateStart,@DateEnd,[Driver ID],@PriorityStatus)),0)>0
	
	End
	

	--Leave only the drivers that have not met week minimum
	If @ThresholdDirection = 'Below'
	BEGIN
		Delete from #NewDriverList 
		Where Miles > @MinThreshold
	END
	Else
	BEGIN
		Delete from #NewDriverList 
		Where Miles < @MinThreshold
	END
	
	--  Leave only the drivers that have not met the total of day's minumum * the number of workdays that have past so far in the week
	If @ThresholdDirection = 'Below'
		Delete from #NewDriverList
		Where Miles > @DayCount * @DailyMilesMinimum
	
	Update #NewDriverList
	Set Last30DayMileage = Isnull((	select Miles = SUM(IsNull(dbo.fnc_TMWRN_StopMiles(stops.stp_number,0,@LoadedStatus,default),0))
								From  	stops (nolock) Left Join legheader (NOLOCK) On stops.lgh_number = legheader.lgh_number 
								where legheader.lgh_driver1 = #NewDriverList.[Driver ID]
									And (
											(legheader.lgh_number Is Null)
											OR 
											(lgh_enddate >= dateadd(d,-30,@DateEnd) and lgh_enddate < @DateEnd And (@DispatchStatus =',,' or CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatus) >0))
										)
							),0)
	
	
	Select * 
	into #TempResults
	from #NewDriverList
	Order by miles
	
	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
	End
	
	Exec (@SQL)

	
GO
