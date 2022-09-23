SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetLayerForMetric]
(
	@MetricCode varchar(200), @OrderByLayerSN_YN varchar(1) = 'N'
)
AS
	SET NOCOUNT ON

	IF @OrderByLayerSN_YN = 'N'
	BEGIN

		SELECT LayerSN, MetricCode, LayerName, MetricParmName, SqlForSplit, ValueList, ParentLayerSN,
			NewMetricCodeFormat, UseOtherOrigParmsYN, 
			DependentLayers = (SELECT COUNT(*) FROM metriclayer WHERE parentlayersn = t1.LayerSn),
			Split = CASE WHEN ISNULL(ValueList, '') = '' THEN SqlForSplit ELSE ValueList END
		FROM metriclayer t1
		WHERE MetricCode = @MetricCode
		ORDER BY LayerName
	END
	ELSE
	BEGIN
		SELECT LayerSN, MetricCode, LayerName, MetricParmName, SqlForSplit, ValueList, ParentLayerSN,
			NewMetricCodeFormat, UseOtherOrigParmsYN, 
			DependentLayers = (SELECT COUNT(*) FROM metriclayer WHERE parentlayersn = t1.LayerSn) 
		FROM metriclayer t1
		WHERE MetricCode = @MetricCode
		ORDER BY LayerSN	
	END
GO
GRANT EXECUTE ON  [dbo].[MetricGetLayerForMetric] TO [public]
GO
