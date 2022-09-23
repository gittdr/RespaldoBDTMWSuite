SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'ServiceExceptions' ,1
CREATE Proc [dbo].[WatchDog_DriverServiceExceptions]
(
	@MinThreshold float = 200,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalDriverServiceExceptions',
	@WatchName varchar(255)='WatchDriverServiceExceptions',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar(50) = 'Selected',
	@AffectsPay char(1) = ''
)
						

As

	Set NoCount On


	/*
	Procedure Name:    WatchDog_DriverServiceExceptions
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	   Returns drivers that have over X amount of service exceptions
	Revision History:
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	--All Drivers with at least 1 exception in the last x mins
	Select  distinct sxn_asgn_id as [Driver ID]
	into    #TempDriversWithServiceExceptions
	From    serviceexception (NOLOCK)
	Where   sxn_asgn_type = 'DRV'
		And sxn_createddate >= DateAdd(mi,@MinsBack,GetDate())
		And (
				@AffectsPay=''
				OR
				@AffectsPay='Y' and sxn_affectspay = 'Y'
				OR
				@AffectsPay = 'N' and sxn_affectspay = 'N'
			)

	--Total service exceptions for each driver
	Select [Driver ID],
		mpp_lastfirst as [Driver Name],
		[Total # Service Exceptions] =	(	select count(*) 
												from serviceexception (NOLOCK) 
												where manpowerprofile.mpp_id = sxn_asgn_id 
													and sxn_asgn_type = 'DRV'
													And (
	 														@AffectsPay=''
	 														OR
	 														@AffectsPay='Y' and sxn_affectspay = 'Y'
	 														OR
	 														@AffectsPay = 'N' and sxn_affectspay = 'N'
        												)
											)
	into   #DriverList
	From   manpowerprofile (NOLOCK),#TempDriversWithServiceExceptions
	Where  mpp_id = [Driver ID]
	          
	Select #DriverList.*
	into   #FinalDriverList
	From   #DriverList

	--Drivers with Total service exceptions exceeding the threshold
	Select  #FinalDriverList.*,
		sxn_createddate as [Service Exception Date],
		sxn_description as [Service Exception Description]
	into    #TempResults
	From    #FinalDriverList,serviceexception (NOLOCK)
	Where   [Driver ID]= sxn_asgn_id and sxn_asgn_type = 'DRV'
		And [Total # Service Exceptions] >= @MinThreshold
		And (
				@AffectsPay=''
				OR
				@AffectsPay='Y' and sxn_affectspay = 'Y'
				OR
				@AffectsPay = 'N' and sxn_affectspay = 'N'
			)

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
GRANT EXECUTE ON  [dbo].[WatchDog_DriverServiceExceptions] TO [public]
GO
