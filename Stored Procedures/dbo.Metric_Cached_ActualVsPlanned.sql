SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create PROCEDURE [dbo].[Metric_Cached_ActualVsPlanned]	
	(
		@Result DECIMAL(20, 5) OUTPUT, 
		@ThisCount DECIMAL(20, 5) OUTPUT,
		@ThisTotal DECIMAL(20, 5) OUTPUT, 
		@DateStart DATETIME, 
		@DateEnd DATETIME,
		@UseMetricParms INT, 
		@ShowDetail INT,
		@Mode CHAR(50)='DELTA', --PCT, NETCHG
		@OnlyRevClass1List VARCHAR(128) ='',
		@OnlyRevClass2List VARCHAR(128) ='',
		@OnlyRevClass3List VARCHAR(128) ='',
		@OnlyRevClass4List VARCHAR(128) ='',
		@OnlyTrcTerminalList VARCHAR(128)='',
		@OnlyDrvCompanyList VARCHAR(128)='',
		@OnlyOrderSubCompanyList VARCHAR(128)=''

	)

AS

/* Version History
Corrected problem with @SPID value.  This value is NOT sufficient to guarantee correct
results when used as a unique identifier.
Steve Pembridge 2008
*/

SET NOCOUNT ON

	--Standard Metric Initialization
	/* 	<METRIC-INSERT-SQL>
	
		EXEC MetricInitializeItem
			@sMetricCode = 'ActualVsPlannedDELTA',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 107, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDECIMAL = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 0,
			@sCaption = 'Actual vs Planned',
			@sCaptionFull = Delta of the distance that hubs were different from planned distance. Lower distance is reported as a positive delta.',
			@sProcedureName = 'Metric_Cached_ActualVsPlanned2',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'
	
		</METRIC-INSERT-SQL>
	*/

/*
		declare @Result DECIMAL(20, 5)
		declare @ThisCount DECIMAL(20, 5)
		declare @ThisTotal DECIMAL(20, 5)

		declare @DateStart DATETIME 
		set @DateStart = '03/01/05'
		declare @DateEnd DATETIME 
		set @DateEnd = '03/31/05'
		declare @UseMetricParms INT 
		set @UseMetricParms =0
		declare @ShowDetail INT
		set @ShowDetail =1
		--Additional/Optional Parameters
		declare @OnlyRevClass1List varchar (50)
		set @OnlyRevClass1List=''
		declare @OnlyRevClass2List varchar (50)
		set @OnlyRevClass2List=''
		declare @OnlyRevClass3List varchar (50)
		set @OnlyRevClass3List=''
		declare @OnlyRevClass4List varchar (50)
		set @OnlyRevClass4List=''
		declare @OnlyTrcTerminalList varchar (255)
		set @OnlyTrcTerminalList =''
		declare @OnlyDrvCompanyList varchar (255)
		set @OnlyDrvCompanyList =''
		declare @OnlyOrderSubCompanyList varchar (255)
		set @OnlyOrderSubCompanyList =''
		declare @Mode varchar(50)
		set @Mode = 'DELTA' -- 
		drop table MetricCacheTempTrips2 
		drop table #TempTrips

*/


	SET @OnlyRevClass1List = ',' + ISNULL(@OnlyRevClass1List,'') + ','
	SET @OnlyRevClass2List = ',' + ISNULL(@OnlyRevClass2List,'') + ','
	SET @OnlyRevClass3List = ',' + ISNULL(@OnlyRevClass3List,'') + ','
	SET @OnlyRevClass4List = ',' + ISNULL(@OnlyRevClass4List,'') + ','
	SET @OnlyTrcTerminalList = ',' + ISNULL(@OnlyTrcTerminalList,'') + ','
	SET @OnlyDrvCompanyList = ',' + ISNULL(@OnlyDrvCompanyList,'') + ','
	SET @OnlyOrderSubCompanyList = ',' + ISNULL(@OnlyOrderSubCompanyList,'') + ','

/*********************************************************************************************
	Step 1:
	
*********************************************************************************************/
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MetricCacheTempTrips2')
	BEGIN
	CREATE TABLE MetricCacheTempTrips2
	(   
		DateStart datetime,
		DateEnd datetime,
		spid float,
--		spid int,
		[LegHeader #] INT,
		[Order #] int,
		[Move #] int,
		[Driver] VARCHAR(8),
		[Tractor] VARCHAR(8),
		[Trailer] VARCHAR(13),
		[Hub Distance] INT,
		[Planned Distance] INT,
		[Delta Distance] INT,
		[Start Company] VARCHAR(8),
		[Start Company Name] VARCHAR(30),
		[Start City] VARCHAR(30),
		[End Company] VARCHAR(8),
		[End Company Name] VARCHAR(30),
		[End City] VARCHAR(30),
		ord_revtype1 VARCHAR(6), 
		ord_revtype2 VARCHAR(6), 
		ord_revtype3 VARCHAR(6), 
		ord_revtype4 VARCHAR(6), 
		mpp_company VARCHAR(6),
		ord_subcompany VARCHAR(8),
		trc_terminal VARCHAR(6)
	) 
		GRANT ALL ON dbo.MetricCacheTempTrips2 TO public
		END



	DECLARE	
		@LegHeader_# INT,
		@Order_# int,
		@Move_# int,
		@Driver VARCHAR(8),
		@Tractor VARCHAR(8),
		@Trailer VARCHAR(13),
		@Hub_Value INT,
		@Planned_Distance INT,
		@CompanyID VARCHAR(8),
		@CompanyName VARCHAR(30),
		@ord_revtype1 VARCHAR(6), 
		@ord_revtype2 VARCHAR(6), 
		@ord_revtype3 VARCHAR(6), 
		@ord_revtype4 VARCHAR(6), 
		@mpp_company VARCHAR(6),
		@ord_subcompany VARCHAR(8),
		@trc_terminal VARCHAR(6),
		@Hub_Distance INT,
		@StartCity VARCHAR(30),
		@EndCity VARCHAR(30)


	DECLARE	@Save_LegHeader_# INT,
			@Save_Hub_Value INT,
			@Save_CompanyID VARCHAR(8),
			@Save_CompanyName VARCHAR(30),
			@ActualDistance INT,
			@Delta_Distance INT,
			@SPIDSubstitute float

	Set @SPIDSubstitute = @@SPID + Round(Convert(float,GetDate()) - Round(Convert(float,GetDate()),0,1),5,1)

	DECLARE evt_cursor CURSOR FOR
	select t1.lgh_number,
		t1.ord_hdrnumber, 
		evt_mov_number,
		evt_driver1,
		evt_tractor, 
		evt_trailer1,
		evt_hubmiles,
		stp_lgh_mileage, 
		cmp_id, 
		cmp_name,
		ord_revtype1,
		ord_revtype2,
		ord_revtype3,
		ord_revtype4,
		mpp_company,
		ord_subcompany,
		trc_terminal
	FROM stops t1 (nolock) join event t2 (nolock) on t1.stp_number = t2.stp_number
--			join orderheader t3 (nolock) on t1.mov_number = t3.mov_number
			join orderheader t3 (nolock) on t1.ord_hdrnumber = t3.ord_hdrnumber
			join manpowerprofile t4 (nolock) on t2.evt_driver1 = t4.mpp_id
			join tractorprofile t5 (nolock) on t2.evt_tractor = t5.trc_number
	WHERE ISNULL(t2.evt_hubmiles, 0) <> 0
 	AND stp_arrivaldate BETWEEN @DateStart AND @DateEnd
	ORDER BY t1.lgh_number, t1.stp_mfh_sequence
	OPEN evt_cursor 
	--FETCH NEXT FROM asset_cursor 
	-- Perform the first fetch.

	FETCH NEXT FROM evt_cursor INTO 
		@LegHeader_#,
		@Order_#,
		@Move_#,
		@Driver,
		@Tractor,
		@Trailer,
		@Hub_Value,
		@Planned_Distance,
		@CompanyID,
		@CompanyName,
		@ord_revtype1, 
		@ord_revtype2, 
		@ord_revtype3, 
		@ord_revtype4, 
		@mpp_company,
		@ord_subcompany,
		@trc_terminal

	SET	@Save_LegHeader_# = @LegHeader_#
	SET @Save_Hub_Value = @Hub_Value
	SET @Save_CompanyID = @CompanyID
	SET @Save_CompanyName = @CompanyName

-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @Save_LegHeader_# <> @LegHeader_# 
			BEGIN
				SET	@Save_LegHeader_# = @LegHeader_#
				SET @Save_Hub_Value = @Hub_Value
				SET @Save_CompanyID = @CompanyID
				SET @Save_CompanyName = @CompanyName
			END
		ELSE IF @Save_CompanyID <> @CompanyID
			BEGIN
			SET @ActualDistance = @Hub_Value - @Save_Hub_Value 
			IF @ActualDistance > 0 AND @ActualDistance <> @Planned_Distance 
				BEGIN
				SET @Delta_Distance = @ActualDistance - @Planned_Distance
				SET @EndCity = (select cty_nmstct from city (NOLOCK) where cty_code = (select cmp_city FROM company c (NOLOCK) WHERE c.cmp_id = @CompanyID)) 
				SET @StartCity = (select cty_nmstct from city (NOLOCK) where cty_code = (select cmp_city FROM company c (NOLOCK) WHERE c.cmp_id = @Save_CompanyID)) 
				INSERT INTO [MetricCacheTempTrips2]([DateStart], [DateEnd], [spid], [LegHeader #], [Order #], [Move #], [Driver], [Tractor], [Trailer], [Hub Distance], [Planned Distance], [Delta Distance], [Start Company], [Start Company Name], [Start City], [End Company], [End Company Name], [End City], [ord_revtype1], [ord_revtype2], [ord_revtype3], [ord_revtype4], [mpp_company], [ord_subcompany], [trc_terminal])
				VALUES(	@DateStart,
					@DateEnd,
					@SPIDSubstitute,
--					@@SPID,
					@LegHeader_#,
					@Order_#,
					@Move_#,
					@Driver,
					@Tractor,
					@Trailer,
					@ActualDistance,
					@Planned_Distance,
					@Delta_Distance,
					@Save_CompanyID,
					@Save_CompanyName,
					@StartCity, 
					@CompanyID,
					@CompanyName,
					@EndCity, 
					@ord_revtype1, 
					@ord_revtype2, 
					@ord_revtype3, 
					@ord_revtype4, 
					@mpp_company,
					@ord_subcompany,
					@trc_terminal)
				END
		END

		SET	@Save_LegHeader_# = @LegHeader_#
		SET @Save_Hub_Value = @Hub_Value
		SET @Save_CompanyID = @CompanyID
		SET @Save_CompanyName = @CompanyName
	
		-- This is executed as long as the previous fetch succeeds.
		FETCH NEXT FROM evt_cursor INTO 
			@LegHeader_#,
			@Order_#,
			@Move_#,
			@Driver,
			@Tractor,
			@Trailer,
			@Hub_Value,
			@Planned_Distance,
			@CompanyID,
			@CompanyName,
			@ord_revtype1, 
			@ord_revtype2, 
			@ord_revtype3, 
			@ord_revtype4, 
			@mpp_company,
			@ord_subcompany,
			@trc_terminal
	END

	CLOSE evt_cursor 
	DEALLOCATE evt_cursor 

	SELECT	[LegHeader #], [Order #], [Move #], [Driver], [Tractor], [Trailer], [Hub Distance], [Planned Distance], [Delta Distance], [Start Company], [Start Company Name], [Start City], [End Company], [End Company Name], [End City]
	INTO #TempTrips
	FROM MetricCacheTempTrips2 (NOLOCK)
			WHERE @DateStart = DateStart
			AND @DateEnd = DateEnd
			AND @SPIDSubstitute = SPID
--			AND @@SPID = SPID 
			AND (@OnlyTrcTerminalList =',,' OR CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminalList) >0)
			AND (@OnlyRevClass1List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' OR CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
			AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( mpp_company ) + ',', @OnlyDrvCompanyList) >0)
			AND (@OnlyOrderSubCompanyList=',,' OR CHARINDEX(',' + RTRIM( ord_subcompany ) + ',', @OnlyOrderSubCompanyList) >0)


	IF	@Mode ='DELTA'  
		BEGIN
		SET @ThisCount = ISNULL((SELECT sum([Delta Distance]) from #TempTrips), 0)
		SET @ThisTotal = 1
		END
	ELSE If @Mode ='PCT'   
		BEGIN
		SET @ThisCount = ISNULL((SELECT sum([Delta Distance]) from #TempTrips), 0)
		SET @ThisTotal = ISNULL((SELECT sum([Planned Distance]) from #TempTrips), 0)
		END
	ELSE If @Mode ='NETCHG'   
		BEGIN
		SET @ThisCount = ISNULL((SELECT sum([Hub Distance] - [Planned Distance]) from #TempTrips), 0)
		SET @ThisTotal = 1
		END

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	If @ShowDetail = 1
		SELECT * from #TempTrips



GO
GRANT EXECUTE ON  [dbo].[Metric_Cached_ActualVsPlanned] TO [public]
GO
