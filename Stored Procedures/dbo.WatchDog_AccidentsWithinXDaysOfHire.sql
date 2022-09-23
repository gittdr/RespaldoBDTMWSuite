SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_AccidentsWithinXDaysOfHire] 
(
	@MinThreshold float = 1,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalAccidentsWithinXDaysOfHire',
	@WatchName varchar(255)='WatchAccidentsWithinXDaysOfHire',
	@ThresholdFieldName varchar(255) = 'Days',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@DrvType1 varchar(140)='',
	@DrvType2 varchar(140)='',
	@DrvType3 varchar(140)='',
	@DrvType4 varchar(140)=''
)
						
As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_AccidentsWithinXDaysOfHire
	Author/CreateDate: Lori Brickley / 5-6-2005
	Purpose: 	    Returns accidents which were entered in the last
					x minutes which involved a driver hired within
					last y days
	Revision History:
	*/
	
	
	/*
	if not exists (select WatchName from WatchDogItem where WatchName = 'AccidentsWithinXDaysOfHire')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	 VALUES ('AccidentsWithinXDaysOfHire','12/30/1899','12/30/1899','WatchDog_AccidentsWithinXDaysOfHire','','',0,0,'','','','','',1,0,'','','')
	
	*/
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
	Set @DrvType1= ',' + ISNULL(@DrvType1,'') + ','
	Set @DrvType2= ',' + ISNULL(@DrvType2,'') + ','
	Set @DrvType3= ',' + ISNULL(@DrvType3,'') + ','
	Set @DrvType4= ',' + ISNULL(@DrvType4,'') + ','	
	
	SELECT manpowerprofile.mpp_id as [Driver ID],
			dra_accidentdate as [Date of Accident],
			dra_description as [Description],
			dra_preventable as [Preventable],
			trc_number as [Tractor ID],
			trl_number as [Trailer ID]
			
	INTO #tempresults		
	FROM driveraccident (NOLOCK), manpowerprofile (NOLOCK)
	WHERE dra_accidentdate >= DateAdd(mi,@MinsBack,GetDate())
		AND dra_accidentdate >= mpp_hiredate 
		AND dra_accidentdate <= dateadd(day, @MinThreshold, mpp_hiredate)
		AND driveraccident.mpp_id = manpowerprofile.mpp_id
		AND (@DrvType1= ',,'  or CHARINDEX(',' + manpowerprofile.mpp_type1 + ',', @DrvType1) >0)
		AND (@DrvType1= ',,'  or CHARINDEX(',' + manpowerprofile.mpp_type2 + ',', @DrvType2) >0)
		AND (@DrvType1= ',,'  or CHARINDEX(',' + manpowerprofile.mpp_type3 + ',', @DrvType3) >0)
		AND (@DrvType1= ',,'  or CHARINDEX(',' + manpowerprofile.mpp_type4 + ',', @DrvType4) >0)
			      				
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
