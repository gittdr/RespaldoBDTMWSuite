SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'SafetyAccidentCount' ,1
CREATE Proc [dbo].[WatchDog_SafetyAccidentCount] 
(
	@MinThreshold float = 200,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalSafetyAccidentCount',
	@WatchName varchar(255)='WatchSafetyAccidentCount',
	@ThresholdFieldName varchar(255) = 'Accident Count',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar(50) = 'Selected'
)
						
As

	Set NoCount On


	/*
	Procedure Name:    WatchDog_SafetyAccidentCount
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	   Returns all empty legs above a specific threshold
	Revision History:
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Select distinct srp_driver1
	into   #DriversWithAccidents
	From   safetyreport da (NOLOCK)
	Where  srp_eventdate >= DateAdd(mi,@MinsBack,GetDate())
		And srp_classification = 'ACC'

	Select mpp_id as DriverID,
		mpp_lastname as [Driver Name],
		mpp_hiredate as [Hire Date],
		[LastAccidentReportNumber] = (select max(srp_number) from safetyreport da (NOLOCK) where manpowerprofile.mpp_id = da.srp_driver1 and srp_classification='ACC' and srp_eventdate = (select max(srp_eventdate) from safetyreport da (NOLOCK) where manpowerprofile.mpp_id = da.srp_driver1 and srp_classification='ACC')),
		[Total # Accidents] = (select count(srp_number) from safetyreport da (NOLOCK) where manpowerprofile.mpp_id = da.srp_driver1 and srp_classification='ACC')
	Into   #DriverList
	From   Manpowerprofile (NOLOCK),#DriversWithAccidents
	Where  mpp_id = srp_driver1

	Select  #DriverList.*,
		[Last Accident Date] = (select srp_eventdate from safetyreport da (NOLOCK) where da.srp_number=LastAccidentReportNumber),
		[Last Accident Description] = (select srp_description from safetyreport da (NOLOCK) where da.srp_number=LastAccidentReportNumber),	
		[Last Accident Chargeable] = (select srp_description from safetyreport da (NOLOCK) where da.srp_number=LastAccidentReportNumber)
	into    #TempResults
	From    #DriverList
	Where   [Total # Accidents] >= @MinThreshold

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
GRANT EXECUTE ON  [dbo].[WatchDog_SafetyAccidentCount] TO [public]
GO
