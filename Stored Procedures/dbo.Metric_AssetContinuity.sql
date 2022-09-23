SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_AssetContinuity]	
	(
		--Standard Parameters
		@Result DECIMAL(20, 5) OUTPUT, 
		@ThisCount DECIMAL(20, 5) OUTPUT,
		@ThisTotal DECIMAL(20, 5) OUTPUT, 
		@DateStart DATETIME, 
		@DateEnd DATETIME,
		@UseMetricParms INT, 
		@ShowDetail INT,
		--Additional/Optional Parameters
		@AssetTypes varchar (50)='',
		@AssetList varchar (255)='',
		@Mode varchar(50) = 'All', -- 'Planned'
		@IncludeOnlyDrvType1List varchar(255)='',
		@IncludeOnlyDrvType2List varchar(255)='',
		@IncludeOnlyDrvType3List varchar(255)='',
		@IncludeOnlyDrvType4List varchar(255)='',
		@ExcludeDrvType1List varchar(255)='',
		@ExcludeDrvType2List varchar(255)='',
		@ExcludeDrvType3List varchar(255)='',
		@ExcludeDrvType4List varchar(255)='',
		@IncludeOnlyTrcType1List varchar(255)='',
		@IncludeOnlyTrcType2List varchar(255)='',
		@IncludeOnlyTrcType3List varchar(255)='',
		@IncludeOnlyTrcType4List varchar(255)='',
		@ExcludeTrcType1List varchar(255)='',
		@ExcludeTrcType2List varchar(255)='',
		@ExcludeTrcType3List varchar(255)='',
		@ExcludeTrcType4List varchar(255)='',
		@IncludeOnlyTrlType1List varchar(255)='',
		@IncludeOnlyTrlType2List varchar(255)='',
		@IncludeOnlyTrlType3List varchar(255)='',
		@IncludeOnlyTrlType4List varchar(255)='',
		@ExcludeTrlType1List varchar(255)='',
		@ExcludeTrlType2List varchar(255)='',
		@ExcludeTrlType3List varchar(255)='',
		@ExcludeTrlType4List varchar(255)='',
		@ExcludeCarrierYN char(1) = 'Y',
		@OnlyDrvTerminalList varchar(255)=''

	)

AS

SET NOCOUNT ON

	--Standard Metric Initialization
	/* 	<METRIC-INSERT-SQL>
	
		EXEC MetricInitializeItem
			@sMetricCode = 'AssetContinuity',
			@nActive = 1,	-- 1=active, 0=inactive.
			@nSort = 107, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDECIMAL = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 0,
			@sCaption = 'Asset Disconnect',
			@sCaptionFull = 'Number of undocumented asset moves per day',
			@sProcedureName = 'Metric_AssetContinuity',
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
		set @DateEnd = '03/02/05'
		declare @UseMetricParms INT 
		set @UseMetricParms =0
		declare @ShowDetail INT
		set @ShowDetail =1
		--Additional/Optional Parameters
		declare @AssetTypes varchar (50)
		set @AssetTypes =''
		declare @AssetList varchar (255)
		set @AssetList =''
		declare @Mode varchar(50)
		set @Mode = 'All' -- 'Planned'
		drop table #TempAssets	
		drop table #TempAssetMoves

*/
	--Standard Parameter Initialization	
	SET @AssetTypes = ',' + ISNULL(@AssetTypes,'') + ','
	SET @AssetList = ',' + ISNULL(@AssetList,'') + ','
	SET @IncludeOnlyDrvType1List = ',' + ISNULL(@IncludeOnlyDrvType1List,'') + ','
	SET @IncludeOnlyDrvType2List = ',' + ISNULL(@IncludeOnlyDrvType2List,'') + ','
	SET @IncludeOnlyDrvType3List = ',' + ISNULL(@IncludeOnlyDrvType3List,'') + ','
	SET @IncludeOnlyDrvType4List = ',' + ISNULL(@IncludeOnlyDrvType4List,'') + ','
	SET @ExcludeDrvType1List = ',' + ISNULL(@ExcludeDrvType1List,'') + ','
	SET @ExcludeDrvType2List = ',' + ISNULL(@ExcludeDrvType2List,'') + ','
	SET @ExcludeDrvType3List = ',' + ISNULL(@ExcludeDrvType3List,'') + ','
	SET @ExcludeDrvType4List = ',' + ISNULL(@ExcludeDrvType4List,'') + ','
	SET @IncludeOnlyTrcType1List = ',' + ISNULL(@IncludeOnlyTrcType1List,'') + ','
	SET @IncludeOnlyTrcType2List = ',' + ISNULL(@IncludeOnlyTrcType2List,'') + ','
	SET @IncludeOnlyTrcType3List = ',' + ISNULL(@IncludeOnlyTrcType3List,'') + ','
	SET @IncludeOnlyTrcType4List = ',' + ISNULL(@IncludeOnlyTrcType4List,'') + ','
	SET @ExcludeTrcType1List = ',' + ISNULL(@ExcludeTrcType1List,'') + ','
	SET @ExcludeTrcType2List = ',' + ISNULL(@ExcludeTrcType2List,'') + ','
	SET @ExcludeTrcType3List = ',' + ISNULL(@ExcludeTrcType3List,'') + ','
	SET @ExcludeTrcType4List = ',' + ISNULL(@ExcludeTrcType4List,'') + ','
	SET @IncludeOnlyTrlType1List = ',' + ISNULL(@IncludeOnlyTrlType1List,'') + ','
	SET @IncludeOnlyTrlType2List = ',' + ISNULL(@IncludeOnlyTrlType2List,'') + ','
	SET @IncludeOnlyTrlType3List = ',' + ISNULL(@IncludeOnlyTrlType3List,'') + ','
	SET @IncludeOnlyTrlType4List = ',' + ISNULL(@IncludeOnlyTrlType4List,'') + ','
	SET @ExcludeTrlType1List = ',' + ISNULL(@ExcludeTrlType1List,'') + ','
	SET @ExcludeTrlType2List = ',' + ISNULL(@ExcludeTrlType2List,'') + ','
	SET @ExcludeTrlType3List = ',' + ISNULL(@ExcludeTrlType3List,'') + ','
	SET @ExcludeTrlType4List = ',' + ISNULL(@ExcludeTrlType4List,'') + ','
	SET @OnlyDrvTerminalList = ',' + ISNULL(@OnlyDrvTerminalList,'') + ','
	

/*********************************************************************************************
	Step 1:
	
*********************************************************************************************/
Declare @AssetAssignements Table
(
	rownum int IDENTITY (1, 1) Primary key NOT NULL , 
	ord_hdrnumber int,
	lgh_mov_number int,
	lgh_createdby varchar(128),
	asgn_type varchar(6),
	asgn_id varchar(13),
	start_cmp_id varchar(12),
	start_city int,
	end_cmp_id varchar(12),
	end_city int,
	asgn_date datetime,
	asgn_status varchar(6) 
)
declare @RowCnt int 
declare @MaxRows int 

CREATE TABLE #TempAssets
(   
	ord_hdrnumber int,
	lgh_mov_number int,
	asgn_type varchar(6),
	asgn_id varchar(13),
	previous_cmp_id varchar(12),
	previous_city int,
	lgh_createdby varchar(128),
	asgn_date datetime,
	createdby varchar(8),
	start_cmp_id varchar(12),
	start_city int,
	end_cmp_id varchar(12),
	end_city int,
	asgn_status varchar(6), 
	distance int
) 


	DECLARE	@ord_hdrnumber int,
			@lgh_mov_number int,
			@lgh_createdby varchar(128),
			@asgn_type varchar(6),
			@asgn_id varchar(13),
			@start_cmp_id varchar(12),
			@start_city int,
			@end_cmp_id varchar(12),
			@end_city int,
			@asgn_date datetime,
			@asgn_status varchar(6), 
			@distance int

	DECLARE	@Save_asgn_type varchar(6),
			@Save_asgn_id varchar(13),
			@Save_asgn_status varchar(6),
			@Save_end_cmp_id varchar(12),
			@Save_end_city Int,
			@Save_lgh_mov_number int



	insert into @AssetAssignements 
	select lgh.ord_hdrnumber, 
		lgh.mov_number,
		lgh.lgh_createdby,
		asgn_type,
		asgn_id, 
		sstops.cmp_id start_cmp_id, 
		Start_City = (select cmp_city FROM company c (NOLOCK) WHERE c.cmp_id = sstops.cmp_id),
		estops.cmp_id end_cmp_id,
		End_City = (select cmp_city FROM company c (NOLOCK) WHERE c.cmp_id = estops.cmp_id),
		asgn_date, 
		asgn_status
	FROM assetassignment (NOLOCK), legheader lgh (NOLOCK),
		event sevent (NOLOCK), stops sstops (NOLOCK), event eevent (NOLOCK), stops estops (NOLOCK)
 	WHERE asgn_date between DateAdd(d,-14,@DateStart) AND @DateEnd
		AND (@AssetTypes =',,' or CHARINDEX(',' + RTRIM( asgn_type ) + ',', @AssetTypes) >0)
		AND (@AssetList =',,' or CHARINDEX(',' + RTRIM( asgn_ID ) + ',', @AssetList) >0)
		AND (@IncludeOnlyDrvType1List =',,' or CHARINDEX(',' + RTRIM( lgh.mpp_type1 ) + ',', @IncludeOnlyDrvType1List) >0)
		AND (@IncludeOnlyDrvType2List =',,' or CHARINDEX(',' + RTRIM( lgh.mpp_type2 ) + ',', @IncludeOnlyDrvType2List) >0)
		AND (@IncludeOnlyDrvType3List =',,' or CHARINDEX(',' + RTRIM( lgh.mpp_type3 ) + ',', @IncludeOnlyDrvType3List) >0)
		AND (@IncludeOnlyDrvType4List =',,' or CHARINDEX(',' + RTRIM( lgh.mpp_type4 ) + ',', @IncludeOnlyDrvType4List) >0)
		AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + RTRIM( lgh.mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
		AND (@ExcludeDrvType1List =',,' or CHARINDEX(',' + RTRIM( lgh.mpp_type1 ) + ',', @ExcludeDrvType1List) =0)
		AND (@ExcludeDrvType2List =',,' or CHARINDEX(',' + RTRIM( lgh.mpp_type2 ) + ',', @ExcludeDrvType2List) =0)
		AND (@ExcludeDrvType3List =',,' or CHARINDEX(',' + RTRIM( lgh.mpp_type3 ) + ',', @ExcludeDrvType3List) =0)
		AND (@ExcludeDrvType4List =',,' or CHARINDEX(',' + RTRIM( lgh.mpp_type4 ) + ',', @ExcludeDrvType4List) =0)
		AND (@IncludeOnlyTrcType1List =',,' or CHARINDEX(',' + RTRIM( lgh.trc_type1 ) + ',', @IncludeOnlyTrcType1List) >0)
		AND (@IncludeOnlyTrcType2List =',,' or CHARINDEX(',' + RTRIM( lgh.trc_type2 ) + ',', @IncludeOnlyTrcType2List) >0)
		AND (@IncludeOnlyTrcType3List =',,' or CHARINDEX(',' + RTRIM( lgh.trc_type3 ) + ',', @IncludeOnlyTrcType3List) >0)
		AND (@IncludeOnlyTrcType4List =',,' or CHARINDEX(',' + RTRIM( lgh.trc_type4 ) + ',', @IncludeOnlyTrcType4List) >0)
		AND (@ExcludeTrcType1List =',,' or CHARINDEX(',' + RTRIM( lgh.trc_type1 ) + ',', @ExcludeTrcType1List) =0)
		AND (@ExcludeTrcType2List =',,' or CHARINDEX(',' + RTRIM( lgh.trc_type2 ) + ',', @ExcludeTrcType2List) =0)
		AND (@ExcludeTrcType3List =',,' or CHARINDEX(',' + RTRIM( lgh.trc_type3 ) + ',', @ExcludeTrcType3List) =0)
		AND (@ExcludeTrcType4List =',,' or CHARINDEX(',' + RTRIM( lgh.trc_type4 ) + ',', @ExcludeTrcType4List) =0)
		AND (@IncludeOnlyTrlType1List =',,' or CHARINDEX(',' + RTRIM( lgh.trl_type1 ) + ',', @IncludeOnlyTrlType1List) >0)
		AND (@IncludeOnlyTrlType2List =',,' or CHARINDEX(',' + RTRIM( lgh.trl_type2 ) + ',', @IncludeOnlyTrlType2List) >0)
		AND (@IncludeOnlyTrlType3List =',,' or CHARINDEX(',' + RTRIM( lgh.trl_type3 ) + ',', @IncludeOnlyTrlType3List) >0)
		AND (@IncludeOnlyTrlType4List =',,' or CHARINDEX(',' + RTRIM( lgh.trl_type4 ) + ',', @IncludeOnlyTrlType4List) >0)
		AND (@ExcludeTrlType1List =',,' or CHARINDEX(',' + RTRIM( lgh.trl_type1 ) + ',', @ExcludeTrlType1List) =0)
		AND (@ExcludeTrlType2List =',,' or CHARINDEX(',' + RTRIM( lgh.trl_type2 ) + ',', @ExcludeTrlType2List) =0)
		AND (@ExcludeTrlType3List =',,' or CHARINDEX(',' + RTRIM( lgh.trl_type3 ) + ',', @ExcludeTrlType3List) =0)
		AND (@ExcludeTrlType4List =',,' or CHARINDEX(',' + RTRIM( lgh.trl_type4 ) + ',', @ExcludeTrlType4List) =0)
		AND (	
				(@ExcludeCarrierYN ='Y' AND lgh.lgh_Carrier = 'UNKNOWN')
				OR
				(@ExcludeCarrierYN <>'Y')
			)
		AND assetassignment.lgh_number = lgh.lgh_number
		AND assetassignment.evt_number = sevent.evt_number
		AND sevent.stp_number = sstops.stp_number
		AND assetassignment.last_evt_number = eevent.evt_number
		AND eevent.stp_number = estops.stp_number
	order by asgn_type, asgn_id, asgn_date

select @MaxRows=count(*) from @AssetAssignements 

select @RowCnt = 1 

select 	@ord_hdrnumber=ord_hdrnumber, 
	@lgh_mov_number=lgh_mov_number, 
	@lgh_createdby=lgh_createdby,
	@asgn_type=asgn_type,
	@asgn_id=asgn_id,
	@start_cmp_id=start_cmp_id,
	@start_city=start_city,
	@end_cmp_id=end_cmp_id,
	@end_city=end_city,
	@asgn_date=asgn_date,
	@asgn_status=asgn_status
from @AssetAssignements
where rownum = @RowCnt 

Select @RowCnt = @RowCnt + 1 

	SET @Save_asgn_type = @asgn_type 
	SET @Save_asgn_id = @asgn_id 
	SET @Save_asgn_status = @asgn_status 
	SET @Save_end_cmp_id = @end_cmp_id 
	SET @Save_lgh_mov_number = @lgh_mov_number
	SET @Save_end_city = @end_city 

while @RowCnt <= @MaxRows 
begin 
		IF @start_cmp_id <> @Save_end_cmp_id AND (@Mode = 'ALL' OR @Mode = 'Planned' AND @asgn_status = 'PLN') AND @Save_asgn_type = @asgn_type AND @Save_asgn_id = @asgn_id AND @Save_lgh_mov_number <> @lgh_mov_number and @asgn_date between @DateStart AND @DateEnd
			BEGIN
			SET @distance = dbo.fnc_MilesBetweenCityCodes(@start_city, @end_city)
			IF @distance = 0 SET @distance = null
			INSERT INTO #TempAssets([ord_hdrnumber], [lgh_mov_number], [lgh_createdby], [asgn_type], [asgn_id], [previous_cmp_id], [previous_city], [start_cmp_id], [start_city], [end_cmp_id], [end_city], [asgn_date], [asgn_status], [distance])
			VALUES(@ord_hdrnumber, @lgh_mov_number, @lgh_createdby, @asgn_type, @asgn_id, @Save_end_cmp_id, @Save_End_City, @start_cmp_id, @start_city, @end_cmp_id, @end_city, @asgn_date, @asgn_status, @distance)
			END

		SET @Save_asgn_type = @asgn_type 
		SET @Save_asgn_id = @asgn_id 
		SET @Save_asgn_status = @asgn_status 
		SET @Save_end_cmp_id = @end_cmp_id 
		SET @Save_lgh_mov_number = @lgh_mov_number
		SET @Save_end_city = @end_city 
		-- This is executed as long as the previous fetch succeeds.
select 	@ord_hdrnumber=ord_hdrnumber, 
	@lgh_mov_number=lgh_mov_number, 
	@lgh_createdby=lgh_createdby,
	@asgn_type=asgn_type,
	@asgn_id=asgn_id,
	@start_cmp_id=start_cmp_id,
	@start_city=start_city,
	@end_cmp_id=end_cmp_id,
	@end_city=end_city,
	@asgn_date=asgn_date,
	@asgn_status=asgn_status
from @AssetAssignements
where rownum = @RowCnt 
Select @RowCnt = @RowCnt + 1 
END

	SELECT
	ord_hdrnumber AS [Order #],
	lgh_mov_number AS [Move #],
	asgn_type AS [Asset Type],
	asgn_id [Asset ID],
	previous_cmp_id AS [Previous Company],
	(select cty_nmstct from city (NOLOCK) where cty_code = previous_city) AS [Previous City],
	asgn_date AS [Assign Date],
	lgh_createdby AS [Assign User],
	start_cmp_id AS [Start Company],
	(select cty_nmstct from city (NOLOCK) where cty_code = start_city) AS [Start City],
	end_cmp_id AS [End Company],
	(select cty_nmstct from city (NOLOCK) where cty_code =end_city) AS [End City],
	asgn_status AS [Assignment Status], 
	IsNull(Convert(varchar(30), distance),'Unknown') AS [Discrepancy Miles]

	INTO #TempAssetMoves
	FROM #TempAssets
	
	SET @ThisCount = ISNULL((SELECT count(*) from #TempAssetMoves), 0)
	SET @ThisTotal = 1
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	If @ShowDetail = 1
		SELECT * from #TempAssetMoves
		ORDER BY [Asset Type], [Asset ID], [Assign Date]

GO
GRANT EXECUTE ON  [dbo].[Metric_AssetContinuity] TO [public]
GO
