SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[WatchDog_OverWeight2]
(
	@MinThreshold float = 78000,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalOverWeight2',
	@WatchName varchar(255) = 'OverWeight2',
	@ThresholdFieldName varchar(255) = 'Pounds',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',

	-- optional parameters
	@Mode varchar(5) = 'ByVol'	-- ByVol,ByWgt
)

As

	set nocount on
	
	/*
	Procedure Name:    WatchDog_OverWeight
	Author/CreateDate: David Wilks / 05/04/05
	Purpose: 	   Warn if tractor + trailer + shipment > threshold
	Revision History:
	*/

	--Standard Initialization of the Alert
	--The following section of commented out code will insert the alert into the "All" list and allow
	--availability for edits within The Dawg application	
	/*
		if not exists (select WatchName from WatchDogItem where WatchName = 'OverWeight2')
		INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress,
		 					BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName,
		 					NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, 
		 					DEFAULTCurrency, CurrencyDateType, Description,CheckedOut,ScheduleID,ScheduledRun)
		VALUES ('OverWeight2', '12/30/1899', '12/30/1899', 'WatchDog_OverWeight2', 
						'', '', 0, 0, '', '', '', '', '', 1, 0, '', '', '',0,1,'01/01/1900')
	*/
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Exec WatchDogPopulateSessionIDParamaters 'OverWeight',@WatchName 

	/*********************************************************************************************
		Step 1:
		
		Select Active_LegHeader where update time is within the minutes back 
			and join values from other tables needed in the calculation.
	*********************************************************************************************/
	SELECT  Legheader_Active.ord_hdrnumber,
			'ord_totalweight' = CONVERT(decimal(14,2), IsNull((dbo.fnc_TMWRN_UnitConversion(ord_totalweightunits,'LBS',Legheader_Active.ord_totalweight)),0)),
			'ord_totalvolume' = CONVERT(decimal(14,2), ISNULL(Legheader_Active.ord_totalvolume,0)),
			Legheader_Active.cmd_code,
			'cmd_specificgravity' = CONVERT(decimal(14,2), ISNULL((SELECT cmd_specificgravity FROM commodity (NOLOCK) WHERE commodity.cmd_code = Legheader_Active.cmd_code),'')),
			lgh_tractor,
			'trc_tareweight' = ISNULL((SELECT trc_tareweight FROM tractorprofile (NOLOCK) WHERE trc_number = lgh_tractor),0),
			lgh_primary_trailer,
			'trl_mtwgt' = ISNULL((SELECT trl_mtwgt FROM trailerprofile (NOLOCK) WHERE trl_number = lgh_primary_trailer),''),
       		Legheader_Active.mov_number,
			npup_ctyname,
			ndrp_ctyname
	INTO   #TempLegs
	FROM   Legheader_Active (NOLOCK) join OrderHeader (NOLOCK) on Legheader_Active.ord_hdrnumber = OrderHeader.ord_hdrnumber
	WHERE  Legheader_Active.lgh_updatedon >= DATEADD(mi,@MinsBack,GETDATE())

	/*********************************************************************************************
		Step 2:
		
		Select Orders where the weight is above threshold.
	*********************************************************************************************/

	SELECT 	ord_hdrnumber AS [Order Number],
			ord_totalvolume AS [Total Volume],
			cmd_code AS [Comm Code],
  			cmd_specificgravity AS [Specific Gravity],
			[Total Weight] =
				Case When @Mode = 'ByVol' Then
  					CONVERT(decimal(14,2), ISNULL((CASE WHEN ord_totalvolume > 8000 THEN ord_totalvolume ELSE ord_totalvolume * cmd_specificgravity END + trc_tareweight + trl_mtwgt),0))
				Else
					CONVERT(decimal(14,2), ISNULL(ord_totalweight + trc_tareweight + trl_mtwgt,0))
				End,
			lgh_tractor AS [Tractor ID],
			CONVERT(decimal(14,2), trc_tareweight) AS [Tractor Weight],
			lgh_primary_trailer AS [Trailer ID],
			CONVERT(decimal(14,2), trl_mtwgt) AS [Trailer Weight],
       		mov_number AS [Move #],
			npup_ctyname [Pickup City],
			ndrp_ctyname [Drop City]
	INTO   	#TempResults
	FROM   	#TempLegs
	WHERE  	
		(@Mode = 'ByVol' AND (cmd_specificgravity * ord_totalvolume + trc_tareweight + trl_mtwgt > @MinThreshold))
			OR
		(@Mode = 'ByWgt' AND (ord_totalweight + trc_tareweight + trl_mtwgt > @MinThreshold))
	ORDER BY [Total Weight] DESC


	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1, @SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
	End
	
	Exec (@SQL)
	
	set nocount off
GO
GRANT EXECUTE ON  [dbo].[WatchDog_OverWeight2] TO [public]
GO
