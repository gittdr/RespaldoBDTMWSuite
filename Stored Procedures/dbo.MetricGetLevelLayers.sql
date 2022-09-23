SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetLevelLayers] 
(
	@CategoryCode varchar(30), 
	@LayerCodeFilter varchar(200), 
	@LayerLevel int
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	SELECT DISTINCT LayerName FROM metriclayer WITH (NOLOCK)
	WHERE ISNULL(LayerLevel, 0) = @LayerLevel
		AND metriccode IN 
			(SELECT t2.MetricCode
			 FROM metriccategoryitems t1 WITH (NOLOCK) INNER JOIN metricitem t2 WITH (NOLOCK) ON t1.MetricCode = t2.MetricCode
			 WHERE t1.Active = 1 AND t1.CategoryCode = @CategoryCode)
		AND LayerCode LIKE @LayerCodeFilter + '%'
		AND LayerCode <> @LayerCodeFilter 
GO
GRANT EXECUTE ON  [dbo].[MetricGetLevelLayers] TO [public]
GO
