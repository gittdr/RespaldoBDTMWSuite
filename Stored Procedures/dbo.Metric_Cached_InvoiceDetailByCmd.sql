SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--drop table MetricCacheInvoiceDetail
CREATE PROCEDURE [dbo].[Metric_Cached_InvoiceDetailByCmd]
	(
		--Standard Parameters
		@Result DECIMAL(20, 5) OUTPUT, 
		@ThisCount DECIMAL(20, 5) OUTPUT, 
		@ThisTotal DECIMAL(20, 5) OUTPUT, 
		@DateStart DATETIME, 
		@DateEnd DATETIME, 
		@UseMetricParms INT, 
		@ShowDetail INT,
		@MetricCode VARCHAR(255)='InvoiceDetailByCmd',

		--Additional/Optional Parameters
		@Mode CHAR(50)='Count', --Count, Revenue 
		@DateType VARCHAR(100) = 'Bill', --Bill, Transfer, Delivery, GLPost
		@OnlyInvoiceStatusList VARCHAR(128) ='XFR',
		@OnlyRevClass1List VARCHAR(128) ='',
		@OnlyRevClass2List VARCHAR(128) ='',
		@OnlyRevClass3List VARCHAR(128) ='',
		@OnlyRevClass4List VARCHAR(128) ='',
		@OnlyTrcTerminalList VARCHAR(128)='',
		@OnlyInvoiceTypeList VARCHAR(128)='', -- A, B, C, etc.	
		@OnlyDrvCompanyList VARCHAR(128)='',
		@OnlyOrderSubCompanyList VARCHAR(128)='',
		@OnlyCommodityList VARCHAR(128)='',
		@OnlyCommodityClassList VARCHAR(128)='',  
		@ExcludeChargeTypeList VARCHAR(128)=''
	)

AS
/*


drop table MetricCacheInvoiceDetail
drop table #InvoiceHeaderFinal
declare
		@Result DECIMAL(20, 5), 
		@ThisCount DECIMAL(20, 5) , 
		@ThisTotal DECIMAL(20, 5) , 
		@DateStart DATETIME, 
		@DateEnd DATETIME, 
		@UseMetricParms INT, 
		@ShowDetail INT,
		@MetricCode VARCHAR(255)

		--Additional/Optional Parameters
declare
		@Mode CHAR(50), --Count, Revenue, Miles, RevenuePerMile
		@DateType VARCHAR(100) , --Bill or Transfer
		@OnlyInvoiceStatusList VARCHAR(128) ,
		@OnlyRevClass1List VARCHAR(128) ,
		@OnlyRevClass2List VARCHAR(128) ,
		@OnlyRevClass3List VARCHAR(128) ,
		@OnlyRevClass4List VARCHAR(128) ,
		@OnlyTrcTerminalList VARCHAR(128),
		@OnlyInvoiceTypeList VARCHAR(128), -- A, B, C, etc.	
		@OnlyDrvCompanyList VARCHAR(128),
		@OnlyOrderSubCompanyList VARCHAR(128),
		@OnlyCommodityList VARCHAR(128),
		@OnlyCommodityClassList VARCHAR(128),
		@ExcludeChargeTypeList VARCHAR(128)
set @datestart = '04/01/05'
set @dateend = '04/02/05'
set @showdetail = 0
set		@Mode ='Revenue' --Count, Revenue, Miles, RevenuePerMile
set		@DateType  = 'Delivery' --Bill or Transfer
set		@OnlyInvoiceStatusList ='XFR,RTP,PRN,PRO'
set		@OnlyRevClass1List =''
set		@OnlyRevClass2List =''
set		@OnlyRevClass3List =''
set		@OnlyRevClass4List =''
set		@OnlyTrcTerminalList =''
set		@OnlyInvoiceTypeList ='' -- A, B, C, etc.	
set		@OnlyDrvCompanyList =''
set		@OnlyOrderSubCompanyList ='PHL'
set		@OnlyCommodityList =''
set		@OnlyCommodityClassList =''
set		@ExcludeChargeTypeList = 'GST'

*/
	SET NOCOUNT ON

	--Populate default currency and currency date types
	Exec PopulateSessionIDParamatersInProc 'Revenue',@MetricCode 

	--Standard Metric Initialization
	/*	<METRIC-INSERT-SQL>

		EXEC MetricInitializeItem
			@sMetricCode = 'CountIVDByCmd',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 300, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDecimal = 0,
			@nPlusDeltaIsGood = 1,
			@nCumulative = 0,
			@sCaption = 'Count of invoice details',
			@sCaptionFull = 'Invoice detail by commodity',
			@sProcedureName = 'Metric_InvoiceDetailByCmd',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'
	
		EXEC MetricInitializeItem
			@sMetricCode = 'RevIVDByCmd',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 300, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = 'CURR',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDecimal = 2,
			@nPlusDeltaIsGood = 1,
			@nCumulative = 1,
			@sCaption = 'Invoice totals',
			@sCaptionFull = 'Invoice detail by commodity',
			@sProcedureName = 'Metric_InvoiceDetailByCmd',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'

		EXEC MetricInitializeItem
			@sMetricCode = 'RevPMByCmd',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 300, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = 'CURR',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDecimal = 2,
			@nPlusDeltaIsGood = 1,
			@nCumulative = 0,
			@sCaption = 'Revenue per mile',
			@sCaptionFull = 'Invoice detail revenue per mile',
			@sProcedureName = 'Metric_InvoiceDetailByCmd',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'

		</METRIC-INSERT-SQL>
	*/

	--Standard Parameter Intialization
	SET @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	SET @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	SET @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	SET @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','
	SET @OnlyInvoiceStatusList= ',' + ISNULL(@OnlyInvoiceStatusList,'') + ','
	SET @OnlyTrcTerminalList= ',' + ISNULL(@OnlyTrcTerminalList,'') + ','
	SET @OnlyInvoiceTypeList= ',' + ISNULL(@OnlyInvoiceTypeList,'') + ','
	SET @OnlyDrvCompanyList= ',' + ISNULL(@OnlyDrvCompanyList,'') + ','
	SET @OnlyOrderSubCompanyList = ',' + ISNULL(@OnlyOrderSubCompanyList,'') + ','
	SET @OnlyCommodityList = ',' + ISNULL(@OnlyCommodityList,'') + ','
	SET @OnlyCommodityClassList = ',' + ISNULL(@OnlyCommodityClassList ,'') + ','
	SET @ExcludeChargeTypeList = ',' + ISNULL(@ExcludeChargeTypeList ,'') + ','

	--Metric Temp Table Creation

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MetricCacheInvoiceDetail')
	BEGIN
	CREATE TABLE MetricCacheInvoiceDetail	(	
									DateStart datetime,
									DateEnd datetime,
									DateType varchar(50),
									spid int,
									[Invoice Header #] INT, 
									[Invoice #] VARCHAR(12), -- need invoiceheader
									[Order #] INT, 
									[Invoice Detail #] INT,
									[Detail Charge] MONEY,
									[Billed Distance] FLOAT,   
									[Total Distance] FLOAT,   
									[Invoice Status] 	VARCHAR(6),
									[Description] VARCHAR(100),
									[Definition] VARCHAR(6), -- need invoiceheader
									[Delivery Date] DATETIME,  -- need invoiceheader
									[GL Post Date] DATETIME,  -- need invoiceheader
									[Print Date] DATETIME,  -- need invoiceheader
									[Bill Date] DATETIME, -- need invoiceheader
									[BillTo ID] VARCHAR(8), 
									[Bill To] VARCHAR(100), 
									[Shipper ID] VARCHAR(8),  -- need invoiceheader
									[Shipper] VARCHAR(100),  -- need invoiceheader
									[Consignee ID] VARCHAR(8), -- need invoiceheader
									[Consignee] VARCHAR(100),  -- need invoiceheader
									[Terms] VARCHAR(3),  -- need invoiceheader, Noted: ivh.terms=CHAR(3) versus ord.terms=VARCHAR(6)
									[Order Weight] DECIMAL(20, 5), 
									[Detail Ref #] VARCHAR(20), 
									[Cmd Class] VARCHAR(8), 
									[Cmd] VARCHAR(8), 
									[Detail Weight] FLOAT,
									[Detail Volume] FLOAT,
									[Driver] VARCHAR(8),
									[Tractor] VARCHAR(8),
 									[Trailer] VARCHAR(13),
									ivh_revtype1 VARCHAR(6), 
									ivh_revtype2 VARCHAR(6), 
									ivh_revtype3 VARCHAR(6), 
									ivh_revtype4 VARCHAR(6), 
									ord_subcompany VARCHAR(20),
									cht_itemcode CHAR(6)
								)
		GRANT INSERT,SELECT,UPDATE,DELETE ON dbo.MetricCacheInvoiceDetail TO public
		CREATE INDEX idxMetricCacheID ON MetricCacheInvoiceDetail (DateStart, DateEnd)
		END


	IF NOT EXISTS (SELECT * FROM MetricCacheInvoiceDetail
				WHERE @DateStart = DateStart
				AND @DateEnd = DateEnd
				AND @DateType = DateType
				AND @@SPID = SPID)
			BEGIN

			declare	@MTMilesFactor DECIMAL(7, 5)
			declare	@MTMilesTotal DECIMAL(20, 5)
			SET @MTMilesTotal = (select sum(IsNull(stp_lgh_mileage,0)) from stops (NOLOCK) where stp_arrivaldate between @DateStart and @DateEnd) 
			IF @MTMilesTotal > 0
				SET @MTMilesFactor = 1 + (select sum(IsNull(stp_lgh_mileage,0)) from stops (NOLOCK) where ord_hdrnumber = 0 and stp_arrivaldate between @DateStart and @DateEnd) / @MTMilesTotal 
			ELSE
				SET @MTMilesFactor = 1

		INSERT INTO MetricCacheInvoiceDetail
			SELECT 	@DateStart,
					@DateEnd,
					@DateType,
					@@SPID,
					IVD.ivh_hdrnumber, 
					IVH.ivh_invoicenumber,
					IVH.ord_hdrnumber,
					IVD.ivd_number,
					CASE WHEN ISNULL(IVD.cmd_code, 'UNKNOWN') = 'UNKNOWN' AND (select sum(ISNULL(IVD2.ivd_charge,0))
							FROM InvoiceDetail IVD2 (NOLOCK) 
							WHERE IVD2.ivh_hdrnumber = IVD.ivh_hdrnumber
							AND ISNULL(IVD2.cmd_code, 'UNKNOWN') <> 'UNKNOWN' 
							AND (@ExcludeChargeTypeList =',,' OR CHARINDEX(',' + RTRIM( RTrim(IVD2.cht_itemcode) ) + ',', @ExcludeChargeTypeList ) = 0))
							= 0
						THEN
							ISNULL(dbo.fnc_CONVERTcharge(ivd_charge,IVH.ivh_currency,'Revenue',IVD.ivh_hdrnumber,ivd_currencydate,IVH.ivh_shipdate,IVH.ivh_deliverydate,IVH.ivh_billdate, IVH.ivh_revenue_date,IVH.ivh_xferdate, DEFAULT,IVH.ivh_printdate, DEFAULT,DEFAULT,DEFAULT),0)
						WHEN ISNULL(IVD.cmd_code, 'UNKNOWN') = 'UNKNOWN' AND (select sum(ISNULL(IVD2.ivd_charge,0))
							FROM InvoiceDetail IVD2 (NOLOCK) 
							WHERE IVD2.ivh_hdrnumber = IVD.ivh_hdrnumber
							AND ISNULL(IVD2.cmd_code, 'UNKNOWN') <> 'UNKNOWN' 
							AND (@ExcludeChargeTypeList =',,' OR CHARINDEX(',' + RTRIM( RTrim(IVD2.cht_itemcode) ) + ',', @ExcludeChargeTypeList ) = 0))
							<> 0
						THEN
							0
						WHEN
					(	(select sum(ISNULL(IVD2.ivd_charge,0))
							FROM InvoiceDetail IVD2 (NOLOCK) 
							WHERE IVD2.ivh_hdrnumber = IVD.ivh_hdrnumber
							AND ISNULL(IVD2.cmd_code, 'UNKNOWN') <> 'UNKNOWN' 
							AND (@ExcludeChargeTypeList =',,' OR CHARINDEX(',' + RTRIM( RTrim(IVD2.cht_itemcode) ) + ',', @ExcludeChargeTypeList ) = 0))
							*
					                (select sum(ISNULL(IVD2.ivd_charge,0))
							FROM InvoiceDetail IVD2 (NOLOCK) 
							WHERE IVD2.ivh_hdrnumber = IVD.ivh_hdrnumber
							AND ISNULL(IVD2.cmd_code, 'UNKNOWN') = 'UNKNOWN' 
							AND (@ExcludeChargeTypeList =',,' OR CHARINDEX(',' + RTRIM( RTrim(IVD2.cht_itemcode) ) + ',', @ExcludeChargeTypeList) = 0)))
							 <> 0
						THEN  -- is more than just line charge so an accessorial exists
							CONVERT( DECIMAL (12,2),ISNULL(dbo.fnc_CONVERTcharge(
							ISNULL(ivd_charge,0)
							 + 
	  						(ISNULL(ivd_charge,0)
						 	/
							(select sum(ISNULL(IVD2.ivd_charge,0))
							FROM InvoiceDetail IVD2 (NOLOCK) 
							WHERE IVD2.ivh_hdrnumber = IVD.ivh_hdrnumber
							AND ISNULL(IVD2.cmd_code, 'UNKNOWN') <> 'UNKNOWN' 
							AND (@ExcludeChargeTypeList =',,' OR CHARINDEX(',' + RTRIM( RTrim(IVD2.cht_itemcode) ) + ',', @ExcludeChargeTypeList ) = 0))
							) *
					                (select sum(ISNULL(IVD2.ivd_charge,0))
							FROM InvoiceDetail IVD2 (NOLOCK) 
							WHERE IVD2.ivh_hdrnumber = IVD.ivh_hdrnumber
							AND ISNULL(IVD2.cmd_code, 'UNKNOWN') = 'UNKNOWN' 
							AND (@ExcludeChargeTypeList =',,' OR CHARINDEX(',' + RTRIM( RTrim(IVD2.cht_itemcode) ) + ',', @ExcludeChargeTypeList) = 0)), IVH.ivh_currency,'Revenue',IVD.ivh_hdrnumber,ivd_currencydate, IVH.ivh_shipdate, IVH.ivh_deliverydate, IVH.ivh_billdate, IVH.ivh_revenue_date,IVH.ivh_xferdate, DEFAULT,IVH.ivh_printdate,DEFAULT,DEFAULT,DEFAULT),0))
						ELSE
							ISNULL(dbo.fnc_CONVERTcharge(ivd_charge,IVH.ivh_currency,'Revenue',IVD.ivh_hdrnumber,ivd_currencydate,IVH.ivh_shipdate,IVH.ivh_deliverydate,IVH.ivh_billdate, IVH.ivh_revenue_date,IVH.ivh_xferdate, DEFAULT,IVH.ivh_printdate, DEFAULT,DEFAULT,DEFAULT),0)

						END,
   

					IVD.ivd_distance,
					0,
					IVH.ivh_invoicestatus,
					IVD.ivd_description,
					IVH.ivh_definition,
					IVH.ivh_deliverydate,
					IVH.ivh_gp_gl_postdate,
					IVH.ivh_printdate,
					IVH.ivh_billdate,
					IVD.ivd_billto,
					ISNULL( (Select Left(cmp_name,30) From company (NOLOCK) where cmp_id= IVD.ivd_billto ),''),
					IVH.ivh_shipper,
					ISNULL( (Select Left(cmp_name,30) From company (NOLOCK) where cmp_id= IVH.ivh_shipper ),''),
					IVH.ivh_consignee,
					ISNULL( (Select Left(cmp_name,30) From company (NOLOCK) where cmp_id= IVH.ivh_consignee ),''),
					IVH.ivh_terms,
					IVD.ivd_ordered_weight,
					IVD.ivd_refnum,
					CMD.cmd_class,
					IVD.cmd_code,
					IVD.ivd_wgt,
					IVD.ivd_volume,
					IVH.ivh_driver,
					IVH.ivh_tractor,
					IVH.ivh_trailer,
					IVH.ivh_revtype1, 
					IVH.ivh_revtype2, 
					IVH.ivh_revtype3, 
					IVH.ivh_revtype4, 
					ord_subcompany,
					IVD.cht_itemcode 
	
			FROM InvoiceDetail IVD (NOLOCK) JOIN invoiceheader IVH (NOLOCK) ON IVD.ivh_hdrnumber = IVH.ivh_hdrnumber
											left JOIN commodity CMD (NOLOCK) ON IVD.cmd_code = CMD.cmd_code
											left join orderheader (NOLOCK) on IVH.ord_hdrnumber = orderheader.ord_hdrnumber
											
			WHERE 	(
						(@DateType = 'Bill' and ivh_billdate >= @DateStart AND ivh_billdate < @DateEnd)
						OR
						(@DateType = 'Transfer' and ivh_xferdate >= @DateStart AND ivh_xferdate < @DateEnd)
						OR
						(@DateType = 'Delivery' and ivh_deliverydate >= @DateStart AND ivh_deliverydate < @DateEnd)
						OR
						(@DateType = 'GLPost' and ivh_gp_gl_postdate >= @DateStart AND ivh_gp_gl_postdate < @DateEnd)
					)
			
	END	


	select 	[Invoice Header #] , 
			[Invoice #] ,
			[Order #] , 
			[Invoice Detail #] ,
			[Detail Charge] ,
			[Billed Distance] ,   
			[Total Distance] ,   
			[Invoice Status] 	,
			[Description] ,
			[Definition] , 
			[Delivery Date], 
			[GL Post Date] , 
			[Print Date] , 
			[Bill Date] , 
			[BillTo ID] , 
			[Bill To] , 
			[Shipper ID] , 
			[Shipper] , 
			[Consignee ID] , 
			[Consignee] , 
			[Terms] , 
			[Order Weight], 
			[Detail Ref #] , 
			[Cmd Class] , 
			[Cmd] , 
			[Detail Weight] , 
			[Detail Volume] , 
			[Driver] , 
			[Tractor] , 
			[Trailer] 

	into #InvoiceHeaderFinal
	from MetricCacheInvoiceDetail (NOLOCK)
			WHERE @DateStart = DateStart
			AND @DateEnd = DateEnd
			AND @DateType = DateType
			AND @@SPID = SPID 
			AND (@OnlyRevClass1List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' OR CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @OnlyRevClass4List) >0)
			AND (@OnlyInvoiceStatusList =',,' OR CHARINDEX(',' + RTRIM( [Invoice Status] ) + ',', @OnlyInvoiceStatusList) >0)
			AND (@OnlyInvoiceTypeList =',,' OR CHARINDEX(',' + RTRIM( Right([Invoice #],1) ) + ',', @OnlyInvoiceTypeList) >0)
			AND (@OnlyOrderSubCompanyList=',,' OR CHARINDEX(',' + RTRIM( ord_subcompany ) + ',', @OnlyOrderSubCompanyList) >0)
			AND (@OnlyCommodityList =',,' OR CHARINDEX(',' + RTRIM( [cmd] ) + ',', @OnlyCommodityList) >0)
			AND (@OnlyCommodityClassList =',,' OR CHARINDEX(',' + RTRIM( [cmd class] ) + ',', @OnlyCommodityClassList) >0)
            AND (@ExcludeChargeTypeList =',,' OR CHARINDEX(',' + RTRIM( RTrim(cht_itemcode) ) + ',', @ExcludeChargeTypeList ) = 0)


	SELECT @ThisTotal = DATEDIFF(DAY, @DateStart, @DateEnd)
	IF @ThisTotal = 0 SET @ThisTotal = 1
	
	IF @Mode = 'Count'
	BEGIN
		SELECT @ThisCount = (SELECT COUNT(OrdNum) 
							FROM (	SELECT Distinct [Order #] as OrdNum 
									from #invoiceheaderFinal) xx
							)
	END
/*	Else If @Mode = 'Miles'
	BEGIN
		SELECT @ThisCount =	(
							SELECT SUM(ISNULL([Total Distance],0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							)	
	END */
	ELSE If @Mode = 'Revenue'
	BEGIN
		SELECT @ThisCount =	(
							SELECT SUM(ISNULL([Detail Charge],0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							)	
	END
/*	ELSE If @Mode = 'RevenuePerMile'
	BEGIN
		SELECT @ThisTotal =	(
							SELECT SUM(ISNULL([Total Distance],0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							)	
		SELECT @ThisCount =	(
							SELECT SUM(ISNULL([Detail Charge],0)) 
							FROM #invoiceheaderFinal (NOLOCK) 
							)	
	END */

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	IF (@ShowDetail=1)
		BEGIN
			SELECT 	*
			FROM #InvoiceHeaderFinal (NOLOCK)
			ORDER BY [Invoice Header #], [Invoice Detail #]
		End

GO
GRANT EXECUTE ON  [dbo].[Metric_Cached_InvoiceDetailByCmd] TO [public]
GO
