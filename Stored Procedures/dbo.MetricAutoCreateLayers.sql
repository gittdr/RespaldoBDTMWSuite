SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricAutoCreateLayers]
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	DECLARE @sn int

	SELECT @sn = ISNULL(MIN(LayerSn), 0) FROM metriclayer 
	WHILE @sn > 0
	BEGIN
		EXEC MetricCreateLayers @LayerSN = @sn, @Write = 1, @IgnoreUnknownYN = 'Y'
		SELECT @sn = ISNULL(MIN(LayerSn), 0) FROM metriclayer WHERE LayerSn > @sn
	END

GO
GRANT EXECUTE ON  [dbo].[MetricAutoCreateLayers] TO [public]
GO
