SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'SafeMilesLevel1' ,1
CREATE   Proc [dbo].[WatchDog_SafetySafeMiles] 
(
	@MinThreshold float = 200,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalSafeMiles',
	@WatchName varchar(255)='WatchSafeMiles',
	@ThresholdFieldName varchar(255) = 'Empty Miles',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar(50) = 'Selected',
	@OnlyDrvType4 VARCHAR(255)='',
	@ExcludeDrvType4 VARCHAR(255)=''
	--@BonusLevel varchar(255)='', -- Removed to make generic
	--@ExcludeBonusLevel varchar(255)='' -- Removed to make generic
)
						
As

	Set NoCount On


	/*
	Procedure Name:    WatchDog_SafetySafeMiles
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	   Returns drivers that have went over X amount of miles without an accident
	Revision History:
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Set @OnlyDrvType4= ',' + RTrim(ISNULL(@OnlyDrvType4,'')) + ','
	Set @ExcludeDrvType4= ',' + RTrim(ISNULL(@ExcludeDrvType4,'')) + ','

	Select mpp_id as [Driver ID],
		[LastAccidentReportNumber] = IsNull((select max(srp_number) from safetyreport da (NOLOCK) where manpowerprofile.mpp_id = da.srp_driver1 and srp_safetytype1 = 'ASMILE' and srp_eventdate = (select max(srp_eventdate) from safetyreport da (NOLOCK) where manpowerprofile.mpp_id = da.srp_driver1 and srp_safetytype1 = 'ASMILE')),''),
		IsNull(mpp_type4,'') as DriverBonusLevel
	Into   #DriverList
	From   Manpowerprofile (NOLOCK)
	Where (@OnlyDrvType4 =',,' or CHARINDEX(',' + mpp_type4+ ',', @OnlyDrvType4) >0)
		And (@ExcludeDrvType4 = ',,' OR Not (CHARINDEX(',' + mpp_type4 + ',', @ExcludeDrvType4) > 0)) 
		And mpp_terminationdt > GetDate() or mpp_terminationdt Is Null
	
	Select #DriverList.*,
		[Last Accident Date] = (select srp_eventdate from safetyreport da (NOLOCK) where da.srp_number=LastAccidentReportNumber),
		[Last Accident Order #] = IsNull((select ord_number from safetyreport da (NOLOCK) where da.srp_number=LastAccidentReportNumber),''),
		[Last Accident Tractor] = IsNull((select srp_tractor from safetyreport da (NOLOCK) where da.srp_number=LastAccidentReportNumber),'')
	into #DriverLastAccidents
	From #DriverList

	Select  #DriverLastAccidents.*,
		[Miles Since Last Accident] =  Case When [Last Accident Date] Is Not Null Then
						(select sum(stp_lgh_mileage) from stops (NOLOCK),legheader (NOLOCK) where legheader.lgh_number = stops.lgh_number and stp_arrivaldate > [Last Accident Date] and legheader.lgh_driver1 = [Driver ID] and stp_status = 'DNE') 
							Else
						(select sum(stp_lgh_mileage) from stops (NOLOCK),legheader (NOLOCK) where legheader.lgh_number = stops.lgh_number and legheader.lgh_driver1 = [Driver ID] and stp_status = 'DNE') 
							End
	into   #TempDriversAndMiles
	From   #DriverLastAccidents

	Select [Driver ID],
		[LastAccidentReportNumber],
		DriverBonusLevel,
		[Last Accident Order #],
		[Last Accident Tractor],
		[Miles Since Last Accident],
		Replace(Cast([Last Accident Date] as varchar(100)),NULL,'') as [Last Accident Date]
	into   #TempResults
	From   #TempDriversAndMiles
	Where  [Miles Since Last Accident] >= @MinThreshold
	Order By [Driver ID]

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
GRANT EXECUTE ON  [dbo].[WatchDog_SafetySafeMiles] TO [public]
GO
