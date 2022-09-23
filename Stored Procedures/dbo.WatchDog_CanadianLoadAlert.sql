SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_CanadianLoadAlert] 
(
	@MinThreshold float = 0,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalCanadianLoadAlert',
	@WatchName varchar(255) = 'CanadianLoadAlert',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@OnlyRevType1 varchar(50)='',
	@OnlyRevType2 varchar(50)='',
	@OnlyRevType3 varchar(50)='',
	@OnlyRevType4 varchar(50)='',
	@StatesDesignatedAsCanada varchar(255)='AB,BC,MB,NS,ON,PQ,QC'
)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_CanadianLoadAlert
	Author/CreateDate: Lori Brickley / 5-31-2005
	Purpose: 	    Returns orders which have at least stop event in Canada.  
					Notice is sent when the Tractor arrives at the Shipper.
	Revision History:
	*/

	/*
	if not exists (select WatchName from WatchDogItem where WatchName = 'CanadianLoadAlert')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	 VALUES ('CanadianLoadAlert','12/30/1899','12/30/1899','WatchDog_CanadianLoadAlert','','',0,0,'','','','','',1,0,'','','')
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
	SET @OnlyRevType1= ',' + ISNULL(@OnlyRevType1,'') + ','
	SET @OnlyRevType2= ',' + ISNULL(@OnlyRevType2,'') + ','
	SET @OnlyRevType3= ',' + ISNULL(@OnlyRevType3,'') + ','
	SET @OnlyRevType4= ',' + ISNULL(@OnlyRevType4,'') + ','
	SET @StatesDesignatedAsCanada= ',' + ISNULL(@StatesDesignatedAsCanada,'') + ','

	/*************************************************************************
		Find all orders which arrived at the shipper within the last x minutes
	*************************************************************************/

	SELECT orderheader.ord_hdrnumber, ord_shipper, ord_consignee
	INTO #TempOrders
	FROM orderheader (NOLOCK) JOIN stops (NOLOCK) on stops.ord_hdrnumber = orderheader.ord_hdrnumber
	WHERE ord_shipper = cmp_id
		AND stp_status = 'DNE'		
		AND stp_arrivaldate >= DATEADD(mi,-@MinsBack,GETDATE())
		AND (@OnlyRevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @OnlyRevType1) >0)
		AND (@OnlyRevType2 =',,' or CHARINDEX(',' + ord_revtype2 + ',', @OnlyRevType2) >0)
		AND	(@OnlyRevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @OnlyRevType3) >0)
		AND	(@OnlyRevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @OnlyRevType4) >0)

	/*****************************************************
		Delete all orders which do not have Canadian stops
	*****************************************************/
	DELETE FROM #TempOrders 
	WHERE ord_hdrnumber not in (
									SELECT DISTINCT ord_hdrnumber 
									FROM stops (NOLOCK)
									WHERE (@StatesDesignatedAsCanada =',,' or CHARINDEX(',' + stp_state + ',', @StatesDesignatedAsCanada) >0)
										AND ord_hdrnumber IN (SELECT ord_hdrnumber FROM #TempOrders)
								)
	

	SELECT ord_hdrnumber as [Order Number],
			ord_shipper as [Shipper],
			ord_consignee as [Consignee]
	INTO #TempResults
	FROM #Temporders
				
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
