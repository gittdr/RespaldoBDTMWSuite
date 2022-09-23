SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricUpdateResNowPage] (
	@sn int
	,@MenuSectionSN int
	,@Active int
	,@Sort int
	,@ShowTime int
	,@CategoryCode varchar(30)
	,@Caption varchar(50)
	,@CaptionFull varchar(255)
	,@PageType varchar(30)
	,@PageURL varchar(255) -- 10

	,@Password varchar(30)
	,@MetricCode varchar(200)
	,@PiePage int
	,@TruckMapLat int
	,@TruckMapLon int
	,@TruckMapFactor int
	,@MetricShowcased varchar(200)  -- A length of 40 in the table might be incorrect.
	,@DetailMetric varchar(200)   	-- A length of 40 in the table might be incorrect.
	,@DetailDate datetime
	,@CurDetailDate datetime

	,@ForcedGraph varchar(200)   	-- A length of 40 in the table might be incorrect.
	,@ForcedDetail varchar(200)   	-- A length of 40 in the table might be incorrect.
	,@TimeFrame varchar(10)
	,@DispMode varchar(40)
	,@DetailID int
	,@DetailFileName varchar(255)
	,@selTimeFrame varchar(40)
	,@txtTimeUnitsBack int
	,@MapType varchar(20)
	,@MapWidth int
	
	,@MapHeight int
	,@JavaScriptFunctionName varchar(100)
	,@BoundaryFileName varchar(255)
	,@ShowDetail int
	,@PrimaryIDColumn int
	,@SecondaryIDColumn int
	,@PostDataColumns varchar(20)
	,@VariableColumns varchar(20)
	,@ColorNumberColumn int
	,@OutputFolder varchar(255)
	
	,@ServerURL varchar(255)
	,@EffectiveDate datetime
	,@ExpirationDate datetime
	,@ProcessInterval datetime
	,@SubDirectory varchar(50)
	,@Chart1  varchar(200)   	-- A length of 40 in the table might be incorrect.
	,@Chart2  varchar(200)   	-- A length of 40 in the table might be incorrect.
	,@Chart3  varchar(200)   	-- A length of 40 in the table might be incorrect.
	,@Chart4  varchar(200)   	-- A length of 40 in the table might be incorrect.
	,@ReportCardMenuSN int
	
	,@GraphCompare_DateOrderLeftToRight varchar(15)
)
AS
	SET NOCOUNT ON

	UPDATE ResNowPage SET 
						MenuSectionSN = @MenuSectionSN
						,Active = @Active
						,Sort = @Sort
						,ShowTime = @ShowTime 
						,CategoryCode =  @CategoryCode 
						,MetricCategorySN = (SELECT sn FROM MetricCategory MC WHERE MC.CategoryCode = @CategoryCode)
						,Caption =  @Caption 
						,CaptionFull = @CaptionFull
						,PageType = @PageType
						,PageUrl = @PageUrl
						,PagePassword = @Password
						,MetricCode = @MetricCode
						,PiePage =  @PiePage
						,TruckMapLat = @TruckMapLat
						,TruckMapLon = @TruckMapLon
						,TruckMapFactor = @TruckMapFactor
						,MetricShowcased = @MetricShowcased
						,DetailMetric =  @DetailMetric
						,DetailDate =  @DetailDate
						,CurDetailDate = @CurDetailDate
						,FORCEDGRAPH = @FORCEDGRAPH
						,ForcedDetail = @ForcedDetail
						,TimeFrame = @TimeFrame
						,DispMode = @DispMode
						,DetailID = @DetailID
						,DetailFileName = @DetailFileName
						,selTimeFrame = @selTimeFrame
						,txtTimeUnitsBack = @txtTimeUnitsBack
						,MapType = @MapType
						,MapWidth = @MapWidth
						,MapHeight = @MapHeight
						,JavaScriptFunctionName = @JavaScriptFunctionName
						,BoundaryFileName = @BoundaryFileName
						,ShowDetail = @ShowDetail
						,PrimaryIDColumn = @PrimaryIDColumn
						,SecondaryIDColumn = @SecondaryIDColumn
						,PostDataColumns = @PostDataColumns
						,VariableColumns = @VariableColumns
						,ColorNumberColumn = @ColorNumberColumn
						,OutputFolder = @OutputFolder
						,ServerURL = @ServerURL
						,EffectiveDate = @EffectiveDate
						,ExpirationDate = @ExpirationDate
						,ProcessInterval = @ProcessInterval
						,SubDirectory = @SubDirectory
						,Chart1 = @Chart1
						,Chart2 = @Chart2
						,Chart3 = @Chart3
						,Chart4 = @Chart4
						,ReportCardMenuSN = @ReportCardMenuSN
						,GraphCompare_DateOrderLeftToRight = @GraphCompare_DateOrderLeftToRight
	WHERE sn = @sn

GO
GRANT EXECUTE ON  [dbo].[MetricUpdateResNowPage] TO [public]
GO
