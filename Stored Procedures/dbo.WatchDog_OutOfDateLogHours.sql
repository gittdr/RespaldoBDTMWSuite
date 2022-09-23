SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OutOfDateLogHours] 
(
	--Standard Parameters
	@MinThreshold float = 1,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalMissingLogHours',
	@WatchName varchar(255)='WatchMissingLogHours',
	@ThresholdFieldName varchar(255) = 'Log Hours',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	--Additional/Optional Parameters
	@DrvType1 varchar(140)='',
	@DrvType2 varchar(140)='',
	@DrvType3 varchar(140)='',
  	@DrvType4 varchar(140)='',
  	@ExcludeDriverStatusList varchar(255)='',
	@IgnoreTodaysLogHoursYN char(1)='N',
	@ExcludeDriverID varchar(255)=''
)
As

	Set NoCount On
	
	/*
	Procedure Name:    WatchDog_OutOfDateLogHours
	Author/CreateDate: Brent Keeton / 10-11-2004
	Purpose: 	   Returns Drivers over/equal @MinThreshold # days since their last log
	
	*/
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
	Set @DrvType1= ',' + ISNULL(@DrvType1,'') + ','
	Set @DrvType2= ',' + ISNULL(@DrvType2,'') + ','
	Set @DrvType3= ',' + ISNULL(@DrvType3,'') + ','
	Set @DrvType4= ',' + ISNULL(@DrvType4,'') + ','
	Set @ExcludeDriverStatusList = ',' + ISNULL(@ExcludeDriverStatusList,'') + ','
	Set @ExcludeDriverID = ',' + ISNULL(@ExcludeDriverID,'') + ','
	
	
	--Create SQL and return results into #TempResults
	Select manpowerprofile.mpp_id as [Driver ID],
	       manpowerprofile.mpp_lastfirst as [Driver Name],
	       [Last Log Date] = 	(
									select max(log_date) 
									from log_driverlogs (NOLOCK) 
									where log_driverlogs.mpp_id = manpowerprofile.mpp_id
								),
			manpowerprofile.mpp_type1 as [Driver Type 1],
			manpowerprofile.mpp_type2 as [Driver Type 2],
			manpowerprofile.mpp_type3 as [Driver Type 3],
			manpowerprofile.mpp_type4 as [Driver Type 4]
	into   #TempDriverLastLog
	From   manpowerprofile (NOLOCK)
	Where (@DrvType1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @DrvType1) >0)
		AND (@DrvType2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @DrvType2) >0)
		AND (@DrvType3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
		AND (@DrvType4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @DrvType4) >0)
		And (mpp_terminationdt > GetDate() or mpp_terminationdt Is Null)   
		And (@ExcludeDriverStatusList = ',,' OR Not (CHARINDEX(',' + mpp_status + ',', @ExcludeDriverStatusList) > 0))    
		And (@ExcludeDriverID = ',,' OR Not (CHARINDEX(',' + mpp_status + ',', @ExcludeDriverID) > 0))    
	       
	Select #TempDriverLastLog.*
	into   #TempResults
	From   #TempDriverLastLog
	Where ( 
			(@IgnoreTodaysLogHoursYN <> 'Y' and DateDiff(day,[Last Log Date],GetDate()) >= @MinThreshold)
				OR
			(@IgnoreTodaysLogHoursYN = 'Y' and DateDiff(day,[Last Log Date],DateAdd(d,-1,GetDate())) >= @MinThreshold)
		  )
	order by #TempDriverLastLog.[Last Log Date]
	
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
