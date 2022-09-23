SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricRemoveLayerAndLayerData] 
(
	@LayerSn int, 
	@ConfirmYN char(1) = NULL
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	DECLARE @LayerName varchar(30), @MetricCodeOrig varchar(200)

	CREATE TABLE #RemoveMetricCodes (MetricCode varchar(200))

	IF EXISTS(SELECT * FROM metriclayer WHERE parentlayersn = @LayerSN)
	BEGIN
		SELECT 'This layer has sub-layers defined.  It cannot be deleted until sub-layers are deleted first.'
		RETURN
	END

	SELECT @LayerName = LayerName, @MetricCodeOrig = MetricCode 
	FROM MetricLayer 
	WHERE LayerSn = @LayerSn

	-- Determine all metriccodes
	INSERT INTO #RemoveMetricCodes
		SELECT metriccode 
		FROM metricitem 
		WHERE LayerSn = @LayerSn AND metriccode LIKE @MetricCodeOrig + '@%' + @LayerName + '%'
			
	IF @ConfirmYN = 'Y'
	BEGIN
		DELETE metricdetail FROM MetricDetail, #RemoveMetricCodes WHERE MetricDetail.MetricCode = #RemoveMetricCodes.MetricCode
		DELETE metricitem FROM MetricItem, #RemoveMetricCodes WHERE MetricItem.MetricCode = #RemoveMetricCodes.MetricCode
		DELETE metriclayer WHERE layersn = @LayerSn AND MetricCode = @MetricCodeOrig
		DELETE metricparameter FROM 
				metricparameter, #RemoveMetricCodes 
			WHERE metricparameter.subheading = #RemoveMetricCodes.metriccode 
				AND (metricparameter.heading = 'MetricStoredProc' or metricparameter.heading = 'Metric')
	END
	ELSE
	BEGIN
		SELECT 'You must set second parameter of this procedure to Y to actually delete data.  Rows listed would be deleted.'	
		SELECT * FROM #RemoveMetricCodes ORDER BY MetricCode
	END
GO
GRANT EXECUTE ON  [dbo].[MetricRemoveLayerAndLayerData] TO [public]
GO
