SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricCopyResNowPage] (
	@sn int
)
AS
	SET NOCOUNT ON

	IF @sn IS NULL 
	BEGIN
		RAISERROR ('MetricCopyResNowPage was passed a NULL value.', 16, 1)
		RETURN
	END
	
	INSERT INTO [ResNowPage] 
		([MenuSectionSN], [Active], [Sort], [ShowTime], [Caption], [PageURL], [CaptionFull], [PagePassword], [MetricCode], [PageType], 
			[CategoryCode], [MetricCategorySN], [PiePage], [SubDirectory], [TruckMapLat], [TruckMapLon], [TruckMapFactor], [MetricShowcased], [DetailMetric], [DetailDate], 
			[CurDetailDate], [ForcedGraph], [ForcedDetail], [DispMode], [DetailID], [DetailFileName], [TimeFrame], [selTimeFrame], [txtTimeUnitsBack], [MapType], 
			[MapWidth], [MapHeight], [JavaScriptFunctionName], [BoundaryFileName], [StartDate], [EndDate], [ShowDetail], [PrimaryIDColumn], [SecondaryIDColumn], [PostDataColumns], 
			[VariableColumns], [ColorNumberColumn], [OutputFolder], [ServerURL], [EffectiveDate], [ExpirationDate], [ProcessInterval], [Chart1], [Chart2], [Chart3], 
			[Chart4], [ReportCardMenuSN])
	SELECT [MenuSectionSN], [Active], [Sort], [ShowTime], [Caption], [PageURL], [CaptionFull], [PagePassword], [MetricCode], [PageType], 
			[CategoryCode], [MetricCategorySN], [PiePage], [SubDirectory], [TruckMapLat], [TruckMapLon], [TruckMapFactor], [MetricShowcased], [DetailMetric], [DetailDate], 
			[CurDetailDate], [ForcedGraph], [ForcedDetail], [DispMode], [DetailID], [DetailFileName], [TimeFrame], [selTimeFrame], [txtTimeUnitsBack], [MapType], 
			[MapWidth], [MapHeight], [JavaScriptFunctionName], [BoundaryFileName], [StartDate], [EndDate], [ShowDetail], [PrimaryIDColumn], [SecondaryIDColumn], [PostDataColumns], 
			[VariableColumns], [ColorNumberColumn], [OutputFolder], [ServerURL], [EffectiveDate], [ExpirationDate], [ProcessInterval], [Chart1], [Chart2], [Chart3], 
			[Chart4], [ReportCardMenuSN]
	FROM ResNowPage WHERE SN = @sn

GO
GRANT EXECUTE ON  [dbo].[MetricCopyResNowPage] TO [public]
GO
