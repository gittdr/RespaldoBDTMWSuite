SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateLayer] 
(
	@LayerSN int,
	@MetricCode varchar(200),
	@LayerName varchar(50),
	@ParmName varchar(100),
	@SqlForSplit varchar(500),
	@ValueList varchar(256),
	@Parent int,
	@NewFormat varchar(60),
	@DefaultOtherParmsYN varchar(1)
)
AS
	SET NOCOUNT ON

	UPDATE MetricLayer
	SET
		LayerName = @LayerName,
		MetricParmName = @ParmName,
		SqlForSplit = @SqlForSplit,
		ValueList = @ValueList,
		ParentLayerSN = @Parent,
		NewMetricCodeFormat = @NewFormat,
		UseOtherOrigParmsYN = @DefaultOtherParmsYN
	WHERE LayerSN = @LayerSN AND MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateLayer] TO [public]
GO
