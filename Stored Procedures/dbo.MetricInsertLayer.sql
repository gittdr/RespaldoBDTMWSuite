SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInsertLayer] 
(
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

	INSERT INTO MetricLayer (MetricCode, LayerName, MetricParmName, SqlForSplit, ValueList, ParentLayerSN, NewMetricCodeFormat, UseOtherOrigParmsYN)
    SELECT @MetricCode, @LayerName, @ParmName, @SqlForSplit, @ValueList, @Parent, @NewFormat, @DefaultOtherParmsYN
GO
GRANT EXECUTE ON  [dbo].[MetricInsertLayer] TO [public]
GO
