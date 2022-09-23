SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_NewDriverDispatchToCanada] 
(
	@MinThreshold float = 0,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalNewDriverDispatchToCanada',
	@WatchName varchar(255) = 'NewDriverDispatchToCanada',
	@ThresholdFieldName varchar(255) = 'Days',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@OnlyDrvType1 varchar(50)='',
	@OnlyDrvType2 varchar(50)='',
	@OnlyDrvType3 varchar(50)='',
	@OnlyDrvType4 varchar(50)='',
	@StatesDesignatedAsCanada varchar(255)='AB,BC,MB,NS,ON,PQ,QC,RI'
)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_OnTimePct
	Author/CreateDate: Lori Brickley / 5-17-2005
	Purpose: 	    Returns Drivers who are dispatched to Canada within x days of hire
	Revision History:
	*/

	/*
	if not exists (select WatchName from WatchDogItem where WatchName = 'NewDriverDispatchToCanada')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	 VALUES ('NewDriverDispatchToCanada','12/30/1899','12/30/1899','WatchDog_NewDriverDispatchToCanada','','',0,0,'','','','','',1,0,'','','')
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
	SET @OnlyDrvType1= ',' + ISNULL(@OnlyDrvType1,'') + ','
	SET @OnlyDrvType2= ',' + ISNULL(@OnlyDrvType2,'') + ','
	SET @OnlyDrvType3= ',' + ISNULL(@OnlyDrvType3,'') + ','
	SET @OnlyDrvType4= ',' + ISNULL(@OnlyDrvType4,'') + ','
	SET @StatesDesignatedAsCanada= ',' + ISNULL(@StatesDesignatedAsCanada,'') + ','

	Select 	lgh_driver1 as [Driver ID],
			ord_hdrnumber as [Order Number],
			lgh_number as [Leg Number],
			lgh_endstate as [Destination],
			0 as EmploymentDays
	Into #TempResults
	From legheader (NOLOCK)
	WHERE lgh_updatedon >= DateAdd(mi,-@MinsBack,GetDate())
		AND (@StatesDesignatedAsCanada =',,' or CHARINDEX(',' + lgh_endstate + ',', @StatesDesignatedAsCanada) >0)
		AND (@OnlyDrvType1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @OnlyDrvType1) >0)
		AND (@OnlyDrvType2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @OnlyDrvType2) >0)
		AND	(@OnlyDrvType3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @OnlyDrvType3) >0)
		AND	(@OnlyDrvType4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @OnlyDrvType4) >0)
	order by lgh_driver1
	--Filter Results Based on Additional/Optional Parameters
	IF (@MinThreshold>0)		
	BEGIN
		Delete #TempResults
		Where [Driver ID] not in 	(	select mpp_id 
										from manpowerprofile (NOLOCK)
										where mpp_hiredate >= dateadd(d,-@MinThreshold,getdate())
											and mpp_hiredate <= getdate()
									)
	END

	update #TempResults
	set EmploymentDays = (	Select DateDiff(d,mpp_hiredate,getdate()) 
							from manpowerprofile (NOLOCK)
							where [Driver ID] = mpp_id
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
GRANT EXECUTE ON  [dbo].[WatchDog_NewDriverDispatchToCanada] TO [public]
GO
