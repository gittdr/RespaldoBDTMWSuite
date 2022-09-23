SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 
CREATE Proc [dbo].[Metric_LoadBalance]

(
	--Standard Parameters
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--Additional/Optional Parameters
	@MinTrvlMilesToInclude	int=0,
	@ExcludedLegheaderInStatusList Varchar(128)='HST,PLN,UNP', --'PLN,DSP',
	@ExcludedLegheaderOutStatusList Varchar(128)='PLN,CMP,DSP,STD,CAN',--PLN,CMP,DSP,STD
	@OnlyOrderStatusList Varchar(128) ='',
	@ExcludeTractorExpirationYN char(1) = 'Y',
	@ExcludeTractorExpirationCodeList Varchar(128)='',
	@ExcludeTractorExpirationPriority varchar(3)='',
	@MinutesNearTractorExpiration int = 1440,
	@ExcludeDriverExpirationYN char(1) = 'Y',
	@ExcludeDriverExpirationCodeList Varchar(128)='',
	@ExcludeDriverExpirationPriority varchar(3)='',
	@MinutesNearDriverExpiration int = 1440,
	@DaysToLookBack int = 7, 
	@DaysToLookForward int = 4,
	@OnlyRevClass1List varchar(128) ='',
	@OnlyRevClass2List varchar(128) ='',
	@OnlyRevClass3List varchar(128) ='',
	@OnlyRevClass4List varchar(128) ='',
	@OnlyIncludeStateList varchar(128) ='',
	@MetricCode varchar(200) = '',
	@StateOrRegionMode varchar(10)='State', --Region1 
	@OnlyIncludeRegion1List varchar(255)='',
	@InBoundTractorsOrOrdersMode varchar(10)='Tractors', -- Orders
	@AvlForAssnDaysBack INT = 5,
    @OnlyMppType3List varchar(128) =''
	)

AS
	SET NOCOUNT ON  -- PTS46367

/*

	--DECLARE @TestEndDate datetime
	--SELECT  @TestEndDate = '09/01/2004'
declare
	@Result decimal(20, 5) , 
	@ThisCount decimal(20, 5) , 
	@ThisTotal decimal(20, 5) , 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int

set @ShowDetail =0
set @DateStart = '07/18/05'
set @DateEnd = '07/19/05'
drop table #IBList
drop table #OBList

Declare
	@MinTrvlMilesToInclude	int,
	@ExcludedLegheaderInStatusList Varchar(128), --'PLN,DSP',
	@ExcludedLegheaderOutStatusList Varchar(128),--PLN,CMP,DSP,STD
	@OnlyOrderStatusList Varchar(128) ,
	@ExcludeTractorExpirationYN char(1) ,
	@ExcludeTractorExpirationCodeList Varchar(128),
	@ExcludeTractorExpirationPriority varchar(3),
	@MinutesNearTractorExpiration int ,
	@ExcludeDriverExpirationYN char(1) ,
	@ExcludeDriverExpirationCodeList Varchar(128),
	@ExcludeDriverExpirationPriority varchar(3),
	@MinutesNearDriverExpiration int ,
	@DaysToLookBack int  ,
	@DaysToLookForward int ,
	@OnlyRevClass1List varchar(128) ,
	@OnlyRevClass2List varchar(128) ,
	@OnlyRevClass3List varchar(128) ,
	@OnlyRevClass4List varchar(128) ,
	@OnlyIncludeStateList varchar(128) ,
	@MetricCode varchar(200) ,
	@StateOrRegionMode varchar(10), --Region1 
	@OnlyIncludeRegion1List varchar(255),
	@InBoundTractorsOrOrdersMode varchar(10),
	@AvlForAssnDaysBack INT

SET @MinTrvlMilesToInclude	=0
SET	@ExcludedLegheaderInStatusList ='CAN' --'PLN,DSP',
SET	@ExcludedLegheaderOutStatusList ='CAN'--PLN,CMP,DSP,STD
SET	@OnlyOrderStatusList  =''
SET	@ExcludeTractorExpirationYN = ''
SET	@ExcludeTractorExpirationCodeList =''
SET	@ExcludeTractorExpirationPriority =''
SET	@MinutesNearTractorExpiration = 1440
SET	@ExcludeDriverExpirationYN = ''
SET	@ExcludeDriverExpirationCodeList =''
SET	@ExcludeDriverExpirationPriority =''
SET	@MinutesNearDriverExpiration = 1440
SET	@DaysToLookBack = 180
SET	@DaysToLookForward = 4
SET	@OnlyRevClass1List =''
SET	@OnlyRevClass2List =''
SET	@OnlyRevClass3List =''
SET	@OnlyRevClass4List =''
SET	@OnlyIncludeStateList =''
SET	@MetricCode = 'LoadBalance'
SET	@StateOrRegionMode ='State' --Region1 
SET	@OnlyIncludeRegion1List =''
SET	@InBoundTractorsOrOrdersMode = 'Tractors'
SET @AvlForAssnDaysBack = 180

*/


	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'LoadBalance', 
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 701, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Load Balance',
		@sCaptionFull = 'Load Balance',
		@sProcedureName = 'Metric_LoadBalance',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'Y', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/

	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	Set @ExcludedLegheaderInStatusList= ',' + ISNULL(@ExcludedLegheaderInStatusList,'') + ','
	Set @ExcludedLegheaderOutStatusList= ',' + ISNULL(@ExcludedLegheaderOutStatusList,'') + ','

	Set @ExcludeTractorExpirationCodeList = ',' + ISNULL(@ExcludeTractorExpirationCodeList ,'') + ','
	Set @ExcludeDriverExpirationCodeList = ',' + ISNULL(@ExcludeDriverExpirationCodeList ,'') + ','

	Set @onlyOrderStatusList= ',' + ISNULL(@onlyOrderStatusList,'') + ','
	Set @OnlyIncludeStateList = ',' + ISNULL(@OnlyIncludeStateList ,'') + ','
	Set @OnlyIncludeRegion1List = ',' + ISNULL(@OnlyIncludeRegion1List ,'') + ','

    Set @OnlyMppType3List= ',' + ISNULL(@OnlyMppType3List,'') + ','
	
-- ALTER TABLE ResNowLoadBalanceIn ADD MetricCode varchar(12) NULL
-- ALTER TABLE ResNowLoadBalanceOut ADD MetricCode varchar(12) NULL
-- ALTER TABLE ResNowLoadBalanceSummary ADD MetricCode varchar(12) NULL


If @ShowDetail = 1
	BEGIN
		select * from metricitem WHERE 1=2
	END
	Else If @ShowDetail = 2
	BEGIN

		SELECT DISTINCT Area, Sum(InCount) as [IN], Sum(OutCount) as [OUT], LastUpdate
		FROM ResNowLoadBalanceSummary (NOLOCK) 
		WHERE metriccode = @MetricCode
		GROUP BY Area, LastUpdate	
		
	END

	

	--------INBOUND--------------

	Create table #IBList	-- Inbound List
		( Tractor varchar (20),
          CompCarga  varchar(500),
          EstadoCarga  varchar(6),
          HoraCarga datetime,
          Orden varchar(20))
	

		Insert into #IBList

		select 
			Tractor= isnull((select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number),'NA'), 
			CompCarga = cmp_name,
			EstadoCarga = stp_state,
			HoraCarga = stp_arrivaldate,
			Orden = ord_hdrnumber

			from stops  
			where month(stp_schdtlatest) =month(@dateStart)
			and year(stp_schdtlatest) =year(@dateStart)
			and day(stp_schdtlatest) = day(@dateStart)
			and stp_type ='PUP'
			and (select ord_status from orderheader where stops.ord_hdrnumber = orderheader.ord_hdrnumber) in ('AVL') 


        ---INSERT A LA TABLA 
 
        delete resnowloadbalanceIn
		 
         INSERT INTO ResNowLoadBalanceIN
	     Select Tractor,CompCarga,EstadoCarga,HoraCarga,Orden  FROM #IBList
		
-------------OUTBOUND-----------------

	Create table #OBList	-- Outbound List
		( Tractor varchar (20),
          CompCarga  varchar(500),
          EstadoCarga  varchar(6),
          HoraCarga datetime,
          HoraDisponible datetime,
          Orden varchar(20))
	

		Insert into #OBList

		select 
			Tractor = isnull((select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number),'NA'), 
			CompDescarga = cmp_name,
			EstadoDesCarga = stp_state,
			HoraDescarga = stp_arrivaldate,
			HoraDisponible = (select trc_avl_date from tractorprofile where trc_number = ( isnull((select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number),'NA'))),
			Orden = ord_hdrnumber

	        from stops  
			where month(stp_schdtlatest) =month(@dateStart)
			and year(stp_schdtlatest) =year(@dateStart)
			and day(stp_schdtlatest) = day(@dateStart)
			and stp_type ='DRP'
			and (select ord_status from orderheader where stops.ord_hdrnumber = orderheader.ord_hdrnumber) in ('AVL') 



        ---INSERT A LA TABLA 
 
        delete resnowloadbalanceOut
		 
         INSERT INTO ResNowLoadBalanceOut
	     Select Tractor,CompCarga,EstadoCarga,HoraCarga,HoraDisponible,Orden  FROM #OBList


	-----------SUMMARY------------------
		DELETE ResNowLoadBalanceSummary WHERE MetricCode = @MetricCode


			INSERT INTO ResNowLoadBalanceSummary (Area,InCount,OutCount,LastUpdate,MetricCode)
			select distinct cty_state as Area,  0 as InCount, 0 as OutCount, GETDATE() as Lastupdate, @MetricCode
			from city (NOLOCK) 
			order by Area

			UPDATE ResNowLoadBalanceSummary 
			SET InCount = IsNull((SELECT count(*) from REsNowLoadBalanceIN where Area = EstadoCarga),0),
				OutCount = IsNull((SELECT count(*) from REsNowLoadBalanceOUT  where Area = EstadoDescarga),0)
			WHERE MetricCode = @MetricCode



 DELETE Resnowloadbalancesummary where area not in ('AG','BJ','BS','CP','CH','CI','CU','CL','DF','DG','EM','GJ','GR','HG','JA','MH','MR','NA','NX','OA','PU','QA','QR','SL','SI','SO','TA','TM','TL','VZ','YC','ZT','MX')




	Set @ThisCount = 1
	Set @ThisTotal = 1

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END	



GO
GRANT EXECUTE ON  [dbo].[Metric_LoadBalance] TO [public]
GO
