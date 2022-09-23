SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Metric_SettledTripsPerUser]
	(	
		--Standard Parameters
		@Result DECIMAL(20, 5) OUTPUT,
		@ThisCount DECIMAL(20, 5) OUTPUT, 
		@ThisTotal DECIMAL(20, 5) OUTPUT, 
		@DateStart DATETIME, 
		@DateEnd DATETIME, 
		@UseMetricParms int, 
		@ShowDetail int,
  
		--Additional/Optional Parameters
		@OnlyRevClass1List VARCHAR(128) ='',
		@OnlyRevClass2List VARCHAR(128) ='',
		@OnlyRevClass3List VARCHAR(128) ='',
		@OnlyRevClass4List VARCHAR(128) ='',
		@MetricCode VARCHAR(255)='SettledTripsPerUser',
		@OnlyAsgnTypeList varchar(255)='CAR,DRV,TRC,TRL',
		@OnlyDrvTerminalList varchar(128)=''    
 	)  

AS  
	SET NOCOUNT ON  -- PTS46367

	--Populate default currency and currency date types
 	EXEC PopulateSessionIDParamatersInProc 'Revenue',@MetricCode  
 
	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.  
	 <METRIC-INSERT-SQL>  
	  
		EXEC MetricInitializeItem
			@sMetricCode = 'SettledTripsPerUser',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 205, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',
			@nNumDigitsAfterDecimal = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 0,
			@sCaption = 'Settled trips/user',
			@sCaptionFull = 'Settled trips per user',
			@sProcedureName = 'Metric_SettledTripsPerUser',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'
	
	 </METRIC-INSERT-SQL>  
	*/  
  
	--Metric Specific Variables
	DECLARE @CountOfLegHeadersSettled Int   
	DECLARE @CountOfDistinctSettlers Int   
   
	--Standard Parameter Initialization
	SET @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	SET @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	SET @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	SET @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','
	SET @OnlyDrvTerminalList= ',' + ISNULL(@OnlyDrvTerminalList,'') + ','
	SET @OnlyAsgnTypeList= ',' + ISNULL(@OnlyAsgnTypeList,'') + ','
	
	

 	/**********************************************************
		Step 1:	Load matching paydetail records into temp table
	**********************************************************/ 

	SELECT 	DISTINCT	pyd_updatedby AS [Updated By],
						lgh_number,
						asgn_type,
						asgn_id,
						pyd_description AS [Pay Description],
						pyd_quantity AS Quantity,
						pyd_rate 	AS Rate,
						IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00) as 'Amount', 
						pyd_transdate AS [Transaction Date],
						pyh_payperiod AS [Pay Period],
						ord_revtype1 AS [Order Rev Class1],
						ord_revtype2 AS [Order Rev Class2],
						ord_revtype3 AS [Order Rev Class3],
						ord_revtype4 AS [Order Rev Class4]
						
	INTO #PayTemp
 								FROM PayDetail pd (NOLOCK) JOIN OrderHeader oh (NOLOCK)
 														ON pd.ord_hdrnumber = oh.ord_hdrnumber 
 								WHERE pyd_transdate between @DateStart and @DateEnd
			    AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
	            AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
			    AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
			    AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
			    AND (@OnlyAsgnTypeList =',,' OR CHARINDEX(',' + RTRIM( asgn_type ) + ',', @OnlyAsgnTypeList) >0)
				AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( (select top 1 mpp_terminal from manpowerprofile (nolock) where  (@OnlyAsgnTypeList =',,' OR CHARINDEX(',' + 'DRV' + ',', @OnlyAsgnTypeList) >0) and asgn_id = mpp_id)  ) + ',', @OnlyDrvTerminalList) >0) 
		
	
	ORDER BY  pyd_updatedby, lgh_number
 	/************************************************
		Step 2:	Select the Count of Distinct LegHeaders
	************************************************/ 
 	SET @CountOfLegHeadersSettled =	(SELECT COUNT(DISTINCT lgh_number) FROM #PayTemp (NOLOCK))  

 	/************************************************
		Step 2: Select Count of Distinct users
	************************************************/   
 	SET @CountOfDistinctSettlers =	(SELECT count(distinct [Updated By]) FROM #PayTemp (NOLOCK))
 
  	/************************************************
		Step 3: calculate metric values
	************************************************/  
   
  	SET  @ThisTotal = @CountOfDistinctSettlers
 	SET  @ThisCount = @CountOfLegHeadersSettled
  	
  	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END   
   
 	IF (@ShowDetail=1)  SELECT * FROM #PayTemp
GO
GRANT EXECUTE ON  [dbo].[Metric_SettledTripsPerUser] TO [public]
GO
