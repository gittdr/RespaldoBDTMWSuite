SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricReinitializeLayerCodes]
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	CREATE TABLE #used (LayerSN int)
	DECLARE @sn int, @subSn int, @Path varchar(255), @Stack varchar(255), @LayerCode varchar(255), @tempSn int, @iStack int
	SELECT @sn = ISNULL(MIN(LayerSN), 0) FROM MetricLayer WHERE ParentLayerSN <> 0
	WHILE @sn > 0
	BEGIN
		-- SELECT 'NODE:', @sn
		SELECT @Path = CONVERT(varchar(10), @sn) + ';', @Stack = LayerName + ';' FROM MetricLayer WHERE LayerSn = @sn
		SELECT @subSN = ParentLayerSN FROM MetricLayer WHERE LayerSn = @sn
		WHILE @subSN > 0
		BEGIN
			SELECT @Path = CONVERT(varchar(10), @subsn) + ';' + @Path,
					@Stack = LayerName + ';' + @Stack FROM MetricLayer WHERE LayerSn = @subsn
			-- SELECT 'Traversing:', @subSN
			INSERT INTO #used VALUES (@subsn)
			SELECT @subSN = ParentLayerSN FROM MetricLayer WHERE LayerSn = @subsn	
		END
		-- We've looped UP to the parent.
		SELECT @iStack = 1
		WHILE @Path <> ''
		BEGIN
			SELECT @iStack = CHARINDEX(';', @Stack, @iStack+1)
			SELECT @LayerCode = SUBSTRING(@Stack, 1, @iStack)
			SELECT @tempSn = CONVERT(int, SUBSTRING(@Path, 1, CHARINDEX(';', @Path)-1))
			SELECT @path = SUBSTRING(@Path, CHARINDEX(';', @Path)+1, LEN(@Path))
			select @tempsn, @Path, @Stack, @LayerCode, @iStack
			UPDATE MetricLayer SET LayerCode = @LayerCode WHERE LayerSn = @tempsn
		END
		SELECT @sn = ISNULL(MIN(LayerSN), 0) FROM MetricLayer WHERE LayerSn > @sn AND ParentLayerSN <> 0 
			AND NOT EXISTS(SELECT * FROM #used WHERE LayerSN = MetricLayer.LayerSn)
	END
	DROP TABLE #used 
GO
GRANT EXECUTE ON  [dbo].[MetricReinitializeLayerCodes] TO [public]
GO
