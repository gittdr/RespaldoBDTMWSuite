SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricSetLayerCode] 
(
	@sn int
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	CREATE TABLE #used (LayerSN int)
	DECLARE @subSn int, @Path varchar(255), @Stack varchar(255), @LayerCode varchar(255), @tempSn int, @iStack int, @Level int
	DECLARE @CircularRefString varchar(2000)
	IF @sn > 0
	BEGIN
		-- SELECT 'NODE:', @sn
		SELECT @Path = CONVERT(varchar(10), @sn) + ';', @Stack = LayerName + ';' FROM MetricLayer WHERE LayerSn = @sn
		SELECT @subSN = ParentLayerSN FROM MetricLayer WHERE LayerSn = @sn
		SELECT @CircularRefString = ''
		WHILE @subSN > 0
		BEGIN
			SELECT @Path = CONVERT(varchar(10), @subsn) + ';' + @Path,
					@Stack = LayerName + ';' + @Stack FROM MetricLayer WHERE LayerSn = @subsn
			-- SELECT 'Traversing:', @subSN
			INSERT INTO #used VALUES (@subsn)
			IF CHARINDEX(CONVERT(varchar(10), @subsn) + ';', @CircularRefString, 1) > 0
			BEGIN
				SELECT 0
				RETURN
			END
			SELECT @CircularRefString = @CircularRefString + CONVERT(varchar(10), @subsn) + ';'
			SELECT @subSN = ParentLayerSN FROM MetricLayer WHERE LayerSn = @subsn	
		END
		-- We've looped UP to the parent.
		SELECT @iStack = 1, @Level = 0
		WHILE @Path <> ''
		BEGIN
			SELECT @iStack = CHARINDEX(';', @Stack, @iStack+1)
			SELECT @LayerCode = SUBSTRING(@Stack, 1, @iStack)
			SELECT @tempSn = CONVERT(int, SUBSTRING(@Path, 1, CHARINDEX(';', @Path)-1))
			SELECT @path = SUBSTRING(@Path, CHARINDEX(';', @Path)+1, LEN(@Path))
			SELECT @Level = @Level + 1
		END
		-- SELECT @tempsn, @Path, @Stack, @LayerCode, @iStack, @Level
		IF ISNULL(@tempsn, 0) <> 0
			UPDATE MetricLayer SET LayerCode = @LayerCode, LayerLevel = @Level WHERE LayerSn = @tempsn

	END
	DROP TABLE #used 

GO
GRANT EXECUTE ON  [dbo].[MetricSetLayerCode] TO [public]
GO
