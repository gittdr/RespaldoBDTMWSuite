SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_SafetyModule_AccidentCost] 
(
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	@MetricCode varchar(255)= 'SafetyModuleAccidentCost',
	@Terminal varchar(255) = '',
	@OnlyDrvType1List varchar(255)='',
	@OnlyDrvType2List varchar(255)='',
	@OnlyDrvType3List varchar(255)='',
	@OnlyDrvType4List varchar(255)='',
	@OnlyDrvTeamleaderList varchar(255)='',
	@OnlyDrvFleetList varchar(255)='',
	@OnlyDrvDivision varchar(255)='',
	@OnlyDrvDomicile varchar(255)='',
	@OnlyDrvTerminal varchar(255)='',
	@OnlyCostType1 varchar(255) = '',
	@OnlyCostType2 varchar(255)='',
	@OnlyRevType1List varchar(255)='',
	@OnlyRevType2List varchar(255)='',
	@OnlyRevType3List varchar(255)='',
	@OnlyRevType4List varchar(255)='',
	@Mode varchar(255)='TOTAL' -- INSURANCE, COMPANY

)
AS
	SET NOCOUNT ON  -- PTS46367


	SELECT @Terminal = ',' + LTRIM(RTRIM(ISNULL(@Terminal, ''))) + ','
	SELECT @OnlyDrvType1List = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType1List, ''))) + ','
	SELECT @OnlyDrvType2List = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType2List, ''))) + ','
	SELECT @OnlyDrvType3List = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType3List, ''))) + ','
	SELECT @OnlyDrvType4List = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType4List, ''))) + ','
	SELECT @OnlyDrvTeamleaderList = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvTeamleaderList, ''))) + ','
	SELECT @OnlyDrvFleetList = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvFleetList, ''))) + ','
	SELECT @OnlyDrvDivision = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvDivision, ''))) + ','
	SELECT @OnlyDrvDomicile = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvDomicile, ''))) + ','
	SELECT @OnlyDrvTerminal = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvTerminal, ''))) + ','
	SELECT @OnlyCostType1 = ',' + LTRIM(RTRIM(ISNULL(@OnlyCostType1, ''))) + ','
	SELECT @OnlyCostType2 = ',' + LTRIM(RTRIM(ISNULL(@OnlyCostType2, ''))) + ','
	SELECT @OnlyRevType1List = ',' + LTRIM(RTRIM(ISNULL(@OnlyRevType1List, ''))) + ','
	SELECT @OnlyRevType2List = ',' + LTRIM(RTRIM(ISNULL(@OnlyRevType2List, ''))) + ','
	SELECT @OnlyRevType3List = ',' + LTRIM(RTRIM(ISNULL(@OnlyRevType3List, ''))) + ','
	SELECT @OnlyRevType4List = ',' + LTRIM(RTRIM(ISNULL(@OnlyRevType4List, ''))) + ','
	
	
	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
		<METRIC-INSERT-SQL>
	
		EXEC MetricInitializeItem
			@sMetricCode = 'SafetyModuleAccidentCost',
			@nActive = 1,	-- 1=active, 0=inactive.
			@nSort = 106, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = 'CURR',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDecimal = 0,
			@nPlusDeltaIsGood = 1,
			@nCumulative = 0,
			@sCaption = 'Accident Cost',
			@sCaptionFull = 'Accident Cost',
			@sProcedureName = 'Metric_SafetyModule_AccidentCost',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = 'Dispatch'
	
		</METRIC-INSERT-SQL>
	*/
	 
	Select  acd_Driver1 as [Driver1 ID] ,
			IsNull(mpp_division,'')  as drvdivision,
			orderheader.ord_revtype1,
			srp_eventdate,
			safetyreport.lgh_number,
			srp_EventDate as [Event Date],
			acd_tractor as [Tractor],
			safetyreport.srp_terminal as [Terminal],
			acd_AccidentType1 as [Accident Type1],
			cast(srp_description as char(255)) as [Description],
			acd_DOTRecordable as [DOT Recordable],
			acd_AccdntPreventability as [Accident Preventable],
			IsNull(sc_PaidByCmp,0) as [Total Paid By Cmp],
			IsNull(sc_PaidByIns,0)    as [Total Paid By Ins],
			sc_DescOfService as [Service Desc],
			IsNull(sc_RecoveredCost,0) as [Total Recovered],
			sc_CostType1 as [Cost Type 1]
 	into    #TempAccidents
	From    Accident (NOLOCK)
		JOIN SafetyReport (NOLOCK) on Accident.srp_id = safetyreport.srp_id
		LEFT JOIN  orderheader (NOLOCK) on Safetyreport.ord_number = orderheader.ord_number
		LEFT --JOIN  legheader (NOLOCK) on orderheader.ord_hdrnumber = legheader.ord_hdrnumber and legheader.lgh_number = (select min(lgh_number) from legheader (nolock) where orderheader.ord_hdrnumber = legheader.ord_hdrnumber )
		JOIN  legheader (NOLOCK) on Safetyreport.lgh_number = legheader.lgh_number
		JOIN SafetyCost (NOLOCK) On  Accident.srp_id = safetycost.srp_id 
	Where   srp_eventdate >= @DateStart and srp_eventdate < @DateEnd
		And (@OnlyDrvType1List = ',,' OR CHARINDEX(',' + RTRIM( IsNull(mpp_type1,'') ) + ',', @OnlyDrvType1List) > 0)
		And (@OnlyDrvType2List = ',,' OR CHARINDEX(',' + RTRIM( IsNull(mpp_type2,'') ) + ',', @OnlyDrvType2List) > 0)
		And (@OnlyDrvType3List = ',,' OR CHARINDEX(',' + RTRIM( IsNull(mpp_type3,'') ) + ',', @OnlyDrvType3List) > 0)
		And (@OnlyDrvType4List = ',,' OR CHARINDEX(',' + RTRIM( IsNull(mpp_type4,'') ) + ',', @OnlyDrvType4List) > 0)
		And (@OnlyDrvTeamleaderList = ',,' OR CHARINDEX(',' + RTRIM( IsNull(mpp_teamleader,'') ) + ',', @OnlyDrvTeamleaderList) > 0)
		And (@OnlyDrvFleetList = ',,' OR CHARINDEX(',' + RTRIM( IsNull(mpp_fleet,'') ) + ',', @OnlyDrvFleetList) > 0)
		And (@OnlyDrvDivision = ',,' OR CHARINDEX(',' + RTRIM( IsNull(mpp_division,'') ) + ',', @OnlyDrvDivision) > 0)
		And (@OnlyDrvDomicile = ',,' OR CHARINDEX(',' + RTRIM( IsNull(mpp_domicile,'') ) + ',', @OnlyDrvDomicile) > 0)
		And (@OnlyDrvTerminal = ',,' OR CHARINDEX(',' + RTRIM( IsNull(mpp_terminal,'') ) + ',', @OnlyDrvTerminal) > 0)
		And (@OnlyCostType1 = ',,' OR CHARINDEX(',' + RTRIM( IsNull(sc_CostType1,'UNK') ) + ',', @OnlyCostType1) > 0)
		And (@OnlyCostType2 = ',,' OR CHARINDEX(',' + RTRIM( IsNull(sc_CostType2,'UNK') ) + ',', @OnlyCostType2) > 0)
		And (@OnlyRevType1List = ',,' OR CHARINDEX(',' + RTRIM( IsNull(ord_Revtype1,'') ) + ',', @OnlyRevType1List) > 0)
		And (@OnlyRevType2List = ',,' OR CHARINDEX(',' + RTRIM( IsNull(ord_Revtype2,'') ) + ',', @OnlyrevType2List) > 0)
		And (@OnlyRevType3List = ',,' OR CHARINDEX(',' + RTRIM( IsNull(ord_Revtype3,'') ) + ',', @OnlyRevType3List) > 0)
		And (@OnlyRevType4List = ',,' OR CHARINDEX(',' + RTRIM( IsNull(ord_Revtype4,'') ) + ',', @OnlyRevType4List) > 0)

IF @MODE = 'TOTAL' 
	Select @ThisCount = sum(isnull([Total Paid By Cmp],0)) + sum(isnull([Total Paid By Ins],0)) - sum(isnull([Total Recovered],0))
	From   #TempAccidents

IF @MODE = 'COMPANY' 
	Select @ThisCount = sum(isnull([Total Paid By Cmp],0)) - sum(isnull([Total Recovered],0))
	From   #TempAccidents

IF @MODE = 'INSURANCE' 
	Select @ThisCount = sum(isnull([Total Paid By Ins],0)) 
	From   #TempAccidents
	
	SELECT @ThisTotal = DATEDIFF(day, @DateStart, @DateEnd)
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
 

	IF (@ShowDetail=1)
	BEGIN
		Select *
		From   #TempAccidents 							

		
		
	End
	
	

GO
GRANT EXECUTE ON  [dbo].[Metric_SafetyModule_AccidentCost] TO [public]
GO
