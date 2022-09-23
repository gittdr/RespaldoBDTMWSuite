SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchDog_MissingDriverMessage]
(
	@MinThreshold float = 3,
	@MinsBack int=-20,
	@TempTableName VARCHAR(255) = '##WatchDogGlobalMissingDriverMessage',
	@WatchName VARCHAR(255)='MissingDriverMessage',
	@ThresholdFieldName VARCHAR(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode VARCHAR(50) = 'Selected',
	@TMServer VARCHAR(40) = NULL, -- DEFAULT TO this SERVER.
	@TMDatabase VARCHAR(40) = NULL, -- DEFAULT TO THIS DATABASE.
	@FormIdList VARCHAR(255) = NULL,  -- This is the TotalMail FormID or Macro Number.
	@DispSysTruckIdList VARCHAR(255) = NULL,
	@DispSysDriverIDList VARCHAR(255) = NULL,
	@OnlyDrvType1List VARCHAR(255)='',
	@OnlyDrvType2List VARCHAR(255)='',
	@OnlyDrvType3List VARCHAR(255)='',
	@OnlyDrvType4List VARCHAR(255)='',
	@OnlyDrvTeamleaderList VARCHAR(255)='',
	@OnlyDrvFleetList VARCHAR(255)='',
	@OnlyDrvDivisionList VARCHAR(255)='',
	@OnlyDrvDomicileList VARCHAR(255)='',
	@OnlyDrvCompanyList VARCHAR(255)='',
	@OnlyDrvTerminalList VARCHAR(255)='',
	@OnlyDrvStatusList VARCHAR(255)='',
	@ExcludeDrvStatusList VARCHAR(255)='',
	@ExcludeDrvAtTerminalYN VARCHAR(255)='N'
)

AS

	SET NOCOUNT ON
	
	/*
	Procedure Name:    WatchDog_MissingDriverMessage
	Author/CreateDate: Lori Brickley / 8-26-2005
	Purpose: 	   Returns drivers who have not sent in a TM message within x mins back
	Revision History:  
	*/
	
	--Reserved/Mandatory WatchDog Variables
	DECLARE @SQL VARCHAR(8000)
	DECLARE @COLSQL VARCHAR(4000)
	--Reserved/Mandatory WatchDog Variables
	
	
	/*

	if not exists (select WatchName from WatchDogItem where WatchName = 'MissingDriverMessage')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	VALUES ('MissingDriverMessage','12/30/1899','12/30/1899','WatchDog_MissingDriverMessage','','',0,0,'','','','','',1,0,'','','')

	*/

	SET @OnlyDrvType1List= ',' + ISNULL(@OnlyDrvType1List,'') + ','
	SET @OnlyDrvType2List= ',' + ISNULL(@OnlyDrvType2List,'') + ','
	SET @OnlyDrvType3List= ',' + ISNULL(@OnlyDrvType3List,'') + ','
	SET @OnlyDrvType4List= ',' + ISNULL(@OnlyDrvType4List,'') + ','
	SET @OnlyDrvTeamleaderList= ',' + ISNULL(@OnlyDrvTeamleaderList,'') + ','
	SET @OnlyDrvFleetList= ',' + ISNULL(@OnlyDrvFleetList,'') + ','
	SET @OnlyDrvDivisionList= ',' + ISNULL(@OnlyDrvDivisionList,'') + ','
	SET @OnlyDrvDomicileList= ',' + ISNULL(@OnlyDrvDomicileList,'') + ','
	SET @OnlyDrvCompanyList= ',' + ISNULL(@OnlyDrvCompanyList,'') + ','
	SET @OnlyDrvTerminalList= ',' + ISNULL(@OnlyDrvTerminalList,'') + ','
	SET @OnlyDrvStatusList= ',' + ISNULL(@OnlyDrvStatusList,'') + ','
	SET @ExcludeDrvStatusList= ',' + ISNULL(@ExcludeDrvStatusList,'') + ','
	 

	-- NOTE 1: This might be inaccurate to run as backfill because history may be purged, and driver/truck assignments change.
	-- NOTE 2: Make a shell procedure on TMWSuite server/database that calls equivalent procedure on TotalMail server/database.
	DECLARE @TMPrefix VARCHAR(255)

	SET NOCOUNT ON

	CREATE TABLE #T2 (sn int, DTSent datetime, FormId int, DispSysTruckId VARCHAR(15), DispSysDriverID VARCHAR(15) ) -- , Driver, Tractor, DispatchGroup, MobileCommGroup

	IF (ISNULL(@TMServer, '') = '') SELECT @TMPrefix = '' ELSE SELECT @TMPrefix = @TMServer + '.'
	IF (ISNULL(@TMDatabase, '') = '') SELECT @TMPrefix = '' ELSE SELECT @TMPrefix = @TMPrefix + @TMDatabase + '..'

	SELECT @SQL = 'EXEC ' + @TMPrefix + 'Watchdog_MissingDriverMessage_TM ''' + cast(@MinThreshold as varchar(12)) + ''', ''' + cast(@MinsBack as varchar(12)) 
										+  ISNULL(@FormIdList, '') + ''', ''' + ISNULL(@DispSysTruckIdList, '') + ''', ''' + ISNULL(@DispSysDriverIDList, '') + ''''
	INSERT INTO #T2 
	EXEC (@SQL)

	SELECT mpp_id, mpp_lastfirst, mpp_type1, mpp_type2, mpp_type3, mpp_type4, 
			mpp_teamleader, mpp_fleet, mpp_division, mpp_domicile, mpp_company, 
			mpp_terminal, mpp_status, mpp_gps_latitude,mpp_gps_longitude,
			(	select cmp_latseconds 
				from company (nolock)
				where mpp_terminal = cmp_id) as cmp_latseconds,
			(	select cmp_latseconds 
				from company (nolock)
				where mpp_terminal = cmp_id) as cmp_longseconds
	INTO #TempResults1
	FROM manpowerprofile (nolock) left join #T2 on manpowerprofile.mpp_id = #t2.DispSysDriverID
	WHERE dtsent is null
		and mpp_terminationdt >= getdate()
		AND (@OnlyDrvType1List =',,' OR CHARINDEX(',' + mpp_type1 + ',', @OnlyDrvType1List) >0)
		AND (@OnlyDrvType2List =',,' OR CHARINDEX(',' + mpp_type2 + ',', @OnlyDrvType2List) >0)
		AND (@OnlyDrvType3List =',,' OR CHARINDEX(',' + mpp_type3 + ',', @OnlyDrvType3List) >0)
		AND (@OnlyDrvType4List =',,' OR CHARINDEX(',' + mpp_type4 + ',', @OnlyDrvType4List) >0)
		AND (@OnlyDrvTeamleaderList =',,' OR CHARINDEX(',' + mpp_teamleader + ',', @OnlyDrvTeamleaderList) >0)
		AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + mpp_fleet + ',', @OnlyDrvFleetList) >0)
		AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + mpp_division + ',', @OnlyDrvDivisionList) >0)
		AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + mpp_domicile + ',', @OnlyDrvDomicileList) >0)
		AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + mpp_company + ',', @OnlyDrvCompanyList) >0)
		AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + mpp_terminal + ',', @OnlyDrvTerminalList) >0)
		AND (@OnlyDrvStatusList =',,' OR CHARINDEX(',' + mpp_status + ',', @OnlyDrvStatusList) >0)
		AND (@ExcludeDrvStatusList =',,' OR CHARINDEX(',' + mpp_status + ',', @ExcludeDrvStatusList) =0)
	order by mpp_id

	Select * , dbo.fnc_AirMilesBetweenLatLongSeconds (mpp_gps_latitude, cmp_latseconds, mpp_gps_longitude, cmp_longseconds) as DistanceFromTerminal
	INTO #TempResults2
	FROM #TempResults1

	--DELETE from #TempResults3 where DistanceFromTerminal <= 5

	Select * 
	into #TempResults
	from #TempResults2
	
	--dbo.fnc_AirMilesBetweenLatLongSeconds (@LatSeconds1 int,@LatSeconds2 int,@LongSeconds1 int,@LongSeconds2 int )


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
GRANT EXECUTE ON  [dbo].[WatchDog_MissingDriverMessage] TO [public]
GO
