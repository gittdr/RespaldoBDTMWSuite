SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_MissingLogHours] 
(
	@MinThreshold float = 1,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalMissingLogHours',
	@WatchName varchar(255)='WatchMissingLogHours',
	@ThresholdFieldName varchar(255) = 'Log Hours',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@DrvType1 varchar(140)='',
	@DrvType2 varchar(140)='',
	@DrvType3 varchar(140)='',
	@DrvType4 varchar(140)='',
	@DrvFleet varchar(140)='',
	@DrvDivision varchar(140)='',
	@DrvCompany varchar(140)='',
	@DrvTerminal varchar(140)='',
	@ExcludeDriverStatusList varchar(255)='',
	@DateToCheck datetime = Null,
	@DaysBack int = 1,
  	@CheckSpecificDateYN char(1) = 'N',
	@IncludeTodaysMissingLogsYN char(1) = 'Y',
	@OnlyTeamLeaderList varchar(140)='',
	@ExcludeTeamLeaderList varchar(140)='',
	@ExcludeStationaryTruckHours float = 0
)
As

	Set NoCount On
	
	
	/*
	Procedure Name:    WatchDog_MissingLogHours
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	   Returns all missing log hours x days back or by date
	Revision History:
			1. Added @CheckSpecificDateYN optional parameter
			   Really just added to just check for missing logs
			   x days back and just for that specific date (x days back) -> LBK
	*/
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
	
	
	Declare @LogDate datetime	
	Declare @CurrentDate datetime
	Declare @Offset int
	
	
	Set @DrvType1= ',' + ISNULL(@DrvType1,'') + ','
	Set @DrvType2= ',' + ISNULL(@DrvType2,'') + ','
	Set @DrvType3= ',' + ISNULL(@DrvType3,'') + ','
	Set @DrvType4= ',' + ISNULL(@DrvType4,'') + ','
	Set @ExcludeDriverStatusList = ',' + ISNULL(@ExcludeDriverStatusList,'') + ','
	Set @OnlyTeamLeaderList = ',' + ISNULL(@OnlyTeamLeaderList,'') + ','
	Set @ExcludeTeamLeaderList = ',' + ISNULL(@ExcludeTeamLeaderList,'') + ','
	Set @DrvFleet = ',' + ISNULL(@DrvFleet,'') + ','
	Set @DrvDivision = ',' + ISNULL(@DrvDivision,'') + ','
	Set @DrvCompany = ',' + ISNULL(@DrvCompany,'') + ','
	Set @DrvTerminal = ',' + ISNULL(@DrvTerminal,'') + ','
	
	Set @CurrentDate = cast(floor(cast(getdate() as float)) as datetime)
	
	If @DateToCheck Is Null
	   Begin
		Set @DateToCheck = cast(floor(cast(getdate() as float)) as datetime) - @DaysBack       
	   End
	   Else
	   Begin
		Set @CheckSpecificDateYN = 'Y'
	   End
	  
	If @IncludeTodaysMissingLogsYN = 'Y'
	   Begin
		Set @Offset = 1
	   End
	Else
	   Begin
		Set @Offset = 0
	   End
	
	Create Table #LogDate (LogDate datetime)
	
	Set @LogDate = @DateToCheck
	
	--Create LogDateTempTable 
	While @LogDate <> (@CurrentDate + @Offset)
		  Begin
			insert into #LogDate (LogDate) Values (@LogDate)
			Set @LogDate = @LogDate + 1 		
		  End
	
	
	--Create SQL and return results into #TempResults
	Select mpp.mpp_id as [Driver ID],
	       mpp.mpp_lastfirst as [Driver Name],
	       LogDate,
	       DATENAME(weekday, LogDate) as DayofWeek,
			mpp_teamleader as [Team Leader],
			usr_userid as [TLUserID],
			'MaxAsgnNumber'= (
								SELECT MAX(asgn_number) 
								FROM assetassignment a (NOLOCK)
								WHERE mpp.mpp_id=asgn_id
									AND asgn_type = 'DRV'
									AND asgn_enddate = (
															SELECT MAX(b.asgn_enddate) 
															FROM assetassignment b (NOLOCK) 
															WHERE (b.asgn_type = 'DRV'
																	AND a.asgn_id = b.asgn_id)
														)
							),
			mpp.mpp_id + ' logs for ' + DATENAME(weekday, LogDate) As ShortDescription,
			mpp.mpp_lastfirst + ' driver logs missing for ' + DATENAME(weekday, LogDate) + ' ' + convert(varchar(12), LogDate) As FullDescription,
			(select MIN(IsNull(ckc_latseconds,0))  from checkcall (nolock) where ckc_asgntype = 'DRV' and ckc_asgnid = mpp.mpp_id and ckc_date between dateadd(hh, -@ExcludeStationaryTruckHours, Getdate()) AND GetDate() ) AS MinLatSeconds,
			(select MAX(IsNull(ckc_latseconds,0))  from checkcall (nolock) where ckc_asgntype = 'DRV' and ckc_asgnid = mpp.mpp_id and ckc_date between dateadd(hh, -@ExcludeStationaryTruckHours, Getdate()) AND GetDate() ) AS MaxLatSeconds,
			(select MIN(IsNull(ckc_longseconds,0))  from checkcall (nolock) where ckc_asgntype = 'DRV' and ckc_asgnid = mpp.mpp_id and ckc_date between dateadd(hh, -@ExcludeStationaryTruckHours, Getdate()) AND GetDate() ) AS MinLongSeconds,
			(select MAX(IsNull(ckc_longseconds,0))  from checkcall (nolock) where ckc_asgntype = 'DRV' and ckc_asgnid = mpp.mpp_id and ckc_date between dateadd(hh, -@ExcludeStationaryTruckHours, Getdate()) AND GetDate() ) AS MaxLongSeconds
	into   #TempDriverEachDay
	From   #LogDate  ,manpowerprofile mpp (NOLOCK)
			left join labelfile lf (nolock) on lf.labeldefinition = 'TeamLeader' and mpp.mpp_teamleader =  lf.abbr 
			left join ttsusers tu (nolock) on lf.teamleader_email = tu.usr_mail_address
	Where (@DrvType1 =',,' or CHARINDEX(',' + mpp.mpp_type1 + ',', @DrvType1) >0)
		AND (@DrvType2 =',,' or CHARINDEX(',' + mpp.mpp_type2 + ',', @DrvType2) >0)
		AND (@DrvType3 =',,' or CHARINDEX(',' + mpp.mpp_type3 + ',', @DrvType3) >0)
		AND (@DrvType4 =',,' or CHARINDEX(',' + mpp.mpp_type4 + ',', @DrvType4) >0)
		AND (@DrvFleet =',,' or CHARINDEX(',' + mpp.mpp_fleet + ',', @DrvFleet) >0)
		AND (@DrvDivision =',,' or CHARINDEX(',' + mpp_division + ',', @DrvDivision) >0)
		AND (@DrvCompany =',,' or CHARINDEX(',' + mpp_company + ',', @DrvCompany) >0)
		AND (@DrvTerminal =',,' or CHARINDEX(',' + mpp_terminal + ',', @DrvTerminal) >0)		
		And mpp_terminationdt > GetDate()    
		And (@ExcludeDriverStatusList = ',,' OR Not (CHARINDEX(',' + mpp_status + ',', @ExcludeDriverStatusList) > 0))
		And (@OnlyTeamLeaderList = ',,' OR (CHARINDEX(',' + mpp.mpp_teamleader + ',', @OnlyTeamLeaderList) > 0))
		And (@ExcludeTeamLeaderList  = ',,' OR Not (CHARINDEX(',' + mpp_teamleader + ',', @ExcludeTeamLeaderList) > 0))

	Delete from #TempDriverEachDay 
	Where dbo.fnc_AirMilesBetweenLatLongSeconds(MinLatSeconds,MaxLatSeconds,MinLongSeconds,MaxLongSeconds) < 1
	And MinLatSeconds <> 0 And MaxLatSeconds <> 0 And MinLongSeconds <> 0 And MaxLongSeconds <> 0
	

	Select #TempDriverEachDay.*, lgh_Tractor AS TractorID
	into   #TempResults
	From   #TempDriverEachDay  Left Join log_driverlogs (NOLOCK) On #TempDriverEachDay.logdate = log_driverlogs.log_date And #TempDriverEachDay.[Driver Id] = log_driverlogs.mpp_id
		LEFT JOIN Assetassignment (NOLOCK) ON #TempDriverEachDay.MaxAsgnNumber =Assetassignment.Asgn_number
    	LEFT JOIN LegHeader (NOLOCK) ON Assetassignment.lgh_number = LegHeader.lgh_number 	 
	Where log_driverlogs.log_date Is Null  
		And	(
				(@CheckSpecificDateYN = 'N' and #TempDriverEachDay.LogDate >= @DateToCheck)
		  		Or
				(@CheckSpecificDateYN = 'Y' and #TempDriverEachDay.LogDate = @DateToCheck)          
	       	)
	order by #TempDriverEachDay.[Driver ID],#TempDriverEachDay.LogDate
	
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
	
	
	Set NoCount Off
	
	
	
	
	





































































GO
