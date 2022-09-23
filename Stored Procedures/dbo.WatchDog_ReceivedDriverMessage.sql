SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchDog_ReceivedDriverMessage]
(
	@MinThreshold float = 3,
	@MinsBack int=-1440,
	@TempTableName VARCHAR(255) = '##WatchDogGlobalReceivedDriverMessage',
	@WatchName VARCHAR(255)='ReceivedDriverMessage',
	@ThresholdFieldName VARCHAR(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode VARCHAR(50) = 'Selected',
	@TMServer VARCHAR(40) = NULL, -- DEFAULT TO this SERVER.
	@TMDatabase VARCHAR(40) = NULL, -- DEFAULT TO THIS DATABASE.
	@FormIdList VARCHAR(255) = NULL,  -- This is the TotalMail FormID or Macro Number.
	@CacheResultsWithNoRepetitionYN varchar(1)='Y',
	@DaysToMaintainCache int = 1

)

AS

	SET NOCOUNT ON
	
	/*
	Procedure Name:    WatchDog_ReceivedDriverMessage
	Author/CreateDate: Lori Brickley / 5-02-2006
	Purpose: Returns macros of drivers who have sent in a TM message indicated in the @FormIdList
			 and forwards as watchdog email message.
	Revision History:  
	*/
	
	--Reserved/Mandatory WatchDog Variables
	DECLARE @SQL VARCHAR(8000)
	DECLARE @COLSQL VARCHAR(4000)
	--Reserved/Mandatory WatchDog Variables
	
	
	/*

	if not exists (select WatchName from WatchDogItem where WatchName = 'ReceivedDriverMessage')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	VALUES ('ReceivedDriverMessage','12/30/1899','12/30/1899','WatchDog_ReceivedDriverMessage','','',0,0,'','','','','',1,0,'','','')

	*/

	DECLARE @TMPrefix VARCHAR(255)

	SET NOCOUNT ON

	CREATE TABLE #T2 (sn int, DTSent datetime, FormId int, DispSysTruckId VARCHAR(15), DispSysDriverID VARCHAR(15), msgImage text) 

	IF (ISNULL(@TMServer, '') = '') SELECT @TMPrefix = '' ELSE SELECT @TMPrefix = @TMServer + '.'
	IF (ISNULL(@TMDatabase, '') = '') SELECT @TMPrefix = '' ELSE SELECT @TMPrefix = @TMPrefix + @TMDatabase + '..'

	SELECT @SQL = 'EXEC ' + @TMPrefix + 'Watchdog_ReceivedDriverMessage_TM ''' + cast(@MinsBack as varchar(12)) + ''', ''' 
										+  ISNULL(@FormIdList, '')  + ''''


	INSERT INTO #T2 
	EXEC (@SQL)

	Update #T2 
	Set DispSysDriverID = trc_driver
	FROM #T2 inner join tractorprofile (nolock) on #T2.DispSysTruckID = trc_number
	WHERE IsNull(#T2.DispSysDriverID,'') = ''
	

	SELECT dtsent, FormId, DispSysTruckId, trc_terminal, DispSysDriverID, mpp_firstname, mpp_lastname, trc_gps_desc, msgImage
    INTO   #TempResultsPreCache   
	FROM #T2 JOIN tractorprofile on tractorprofile.trc_number = #t2.DispSysTruckID
			 JOIN manpowerprofile on manpowerprofile.mpp_id = #t2.DispSysDriverID


            IF @CacheResultsWithNoRepetitionYN = 'Y'
            BEGIN
                DELETE FROM WatchDogCache
                WHERE CacheDate < DateAdd(day,-@DaysToMaintainCache,GETDATE())

                DELETE FROM #TempResultsPreCache
                WHERE EXISTS (
                                SELECT * 
                                from WatchDogCache
                                where convert(varchar(20),#TempResultsPreCache.dtsent,109)+#TempResultsPreCache.DispSysTruckId= WatchDogCache.[Identifier]
                                and WatchName = @WatchName 
                            )

                Insert Into WatchDogCache
                SELECT            @WatchName,
                                convert(varchar(20),dtsent,109)+DispSysTruckId,
                                GETDATE() as CacheDate
                FROM #TempResultsPreCache
                where Isnull(dtsent,'') > ''
            END


            SELECT * into #TempResults from #TempResultsPreCache         




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

GRANT EXECUTE ON dbo.WatchDog_ReceivedDriverMessage TO public
GO
