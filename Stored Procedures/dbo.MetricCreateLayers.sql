SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCreateLayers] 
(
	@LayerSN int, 
	@Write int = 0, 
	@IgnoreUnknownYN varchar(1) = 'N'
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS	
	CREATE TABLE #Layers (LayerLevel int, ParentLayerSn int)
	CREATE TABLE #LayerItems0 (sn int identity, item varchar(100))
	CREATE TABLE #LayerItems1 (sn int identity, item varchar(100))
	CREATE TABLE #LayerItems2 (sn int identity, item varchar(100))
	CREATE TABLE #LayerItems3 (sn int identity, item varchar(100))

	SET NOCOUNT ON
	DECLARE @nLevel int, @ParentLayerSN int, @ValueList varchar(255), @LayerName varchar(100)
	DECLARE @sn0 int, @sn1 int, @sn2 int, @sn3 int
	DECLARE @SqlForSplit0 nvarchar(1000), @SqlForSplit1 nvarchar(1000), @SqlForSplit2 nvarchar(1000), @SqlForSplit3 nvarchar(1000)
	DECLARE @item0 varchar(100), @item1 varchar(100), @item2 varchar(100), @item3 varchar(100)
	DECLARE @LayerName0 varchar(100), @LayerName1 varchar(100), @LayerName2 varchar(100), @LayerName3 varchar(100)
	DECLARE @MetricParmName0 varchar(100), @MetricParmName1 varchar(100), @MetricParmName2 varchar(100), @MetricParmName3 varchar(100)
	DECLARE @MetricCode varchar(100), @NewMetricCode varchar(200)
	DECLARE @NewMetricCodeSort int

	EXEC MetricSetLayerCode @LayerSN

	SELECT @MetricCode = MetricCode, @LayerName = LayerName 
	FROM MetricLayer WITH (NOLOCK) 
	WHERE LayerSn = @LayerSn

	INSERT INTO #Layers(LayerLevel, ParentLayerSn) SELECT 0, 0

	SELECT @nLevel = 1

	SELECT @ParentLayerSN = ISNULL(ParentLayerSN, 0) 
	FROM MetricLayer WITH (NOLOCK) 
	WHERE LayerSN = @LayerSN

	WHILE @ParentLayerSN <> 0
	BEGIN
		INSERT INTO #Layers(LayerLevel, ParentLayerSn) SELECT @nLevel, @ParentLayerSN
		SELECT @nLevel = @nLevel + 1,
			@ParentLayerSN = ISNULL(ParentLayerSN, 0) FROM MetricLayer WITH (NOLOCK) WHERE LayerSN = @ParentLayerSN
	END

	SELECT @nLevel = MAX(LayerLevel) FROM #Layers 

	IF @nLevel = 0 
	BEGIN
		-- No parent metrics
		SELECT @LayerName0 = @LayerName

		SELECT @SqlForSplit0 = CASE WHEN ISNULL(ValueList, '') = '' THEN SqlForSplit ELSE 'MetricParseList ''' + ValueList + '''' END,
			@MetricParmName0 = MetricParmName
		FROM MetricLayer WITH (NOLOCK) 
		WHERE LayerSn = @LayerSN

		INSERT INTO #LayerItems0 (item) EXEC sp_executesql @stmt = @SqlForSplit0

		SELECT @sn0 = ISNULL(MIN(sn), 0) FROM #LayerItems0
		WHILE ISNULL(@sn0, 0) > 0
		BEGIN
			-- SELECT @item0 = (SELECT item FROM #LayerItems0 WHERE sn = @sn0)
			SELECT @NewMetricCode = @MetricCode + '@' + @LayerName0 + '=' + item, @item0 = item 
			FROM #LayerItems0 
			WHERE sn = @sn0

			SELECT @NewMetricCodeSort = sort
			FROM MetricItem
			WHERE MetricCode = @MetricCode

			IF (ISNULL(@IgnoreUnknownYN, 'N') = 'Y' 
				AND CHARINDEX('=UNKNOWN', @NewMetricCode) = 0)
				OR ISNULL(@IgnoreUnknownYN, 'N') = 'N'
			BEGIN
				IF NOT EXISTS(SELECT * FROM MetricItem WHERE MetricCode = @NewMetricCode)
				BEGIN
					IF ISNULL(@Write, 0) = 0 
						SELECT @NewMetricCode
					ELSE
					BEGIN
						INSERT INTO MetricItem (MetricCode, Caption, CaptionFull, Active, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, ProcedureName, StartDate, RefreshHistoryYN, LayerSN, Sort)
						SELECT @newMetricCode, @newMetricCode, @newMetricCode, Active, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, ProcedureName, StartDate, ISNULL(RefreshHistoryYN, ''), @LayerSN, @NewMetricCodeSort 
						FROM metricitem
						WHERE MetricCode = @MetricCode

						-- 2/16/2006: DAG: SNBC
						DELETE MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode

						-- Insert the default values from original metric below.
						IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, ParmName, ParmValue, ParmSort
										FROM MetricParameter 
										WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName <> @MetricParmName0)
						BEGIN
							INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
								SELECT 'MetricStoredProc', @NewMetricCode, ParmName, ParmValue, ParmSort
								FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName <> @MetricParmName0
						END
						
						IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName0, @item0, ParmSort
										FROM MetricParameter 
										WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName = @MetricParmName0)
						BEGIN
							INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
								SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName0, @item0, ParmSort
								FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @MetricParmName0
						END
						
						IF NOT EXISTS(	SELECT 'Metric', @NewMetricCode, 'REFRESH_HISTORY_AGE_DEFAULT', ParmValue, ParmSort
										FROM MetricParameter 
										WHERE Heading = 'Metric' AND SubHeading = @NewMetricCode AND ParmName = 'REFRESH_HISTORY_AGE_DEFAULT')
						BEGIN
							INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
								SELECT 'Metric', @NewMetricCode, 'REFRESH_HISTORY_AGE_DEFAULT', ParmValue, ParmSort
								FROM MetricParameter WHERE Heading = 'Metric' AND SubHeading = @MetricCode AND ParmName = 'REFRESH_HISTORY_AGE_DEFAULT'
						END
						
						IF NOT EXISTS(	SELECT 'Metric', @NewMetricCode, 'REFRESH_HISTORY_DAYS_BACK', ParmValue, ParmSort
										FROM MetricParameter 
										WHERE Heading = 'Metric' AND SubHeading = @NewMetricCode AND ParmName = 'REFRESH_HISTORY_DAYS_BACK')
						BEGIN
							INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
								SELECT 'Metric', @NewMetricCode, 'REFRESH_HISTORY_DAYS_BACK', ParmValue, ParmSort
								FROM MetricParameter WHERE Heading = 'Metric' AND SubHeading = @MetricCode AND ParmName = 'REFRESH_HISTORY_DAYS_BACK'
						END
					END
				END
				ELSE
				BEGIN
					IF ISNULL(@Write, 0) = 1
						UPDATE MetricItem SET LayerSN = @LayerSN
							WHERE MetricCode = @NewMetricCode
				END
			END
			SELECT @sn0 = ISNULL(MIN(sn), 0) FROM #LayerItems0 WHERE sn > @sn0
		END
	END
	ELSE IF @nLevel = 1
	BEGIN
		-- One parent metrics
		SELECT @SqlForSplit1 = CASE WHEN ISNULL(ValueList, '') = '' THEN SqlForSplit ELSE 'MetricParseList ''' + ValueList + '''' END,
				@LayerName1 = LayerName, @MetricParmName1 = MetricParmName
			FROM MetricLayer WITH (NOLOCK) WHERE LayerSn = (SELECT ParentLayerSN FROM #Layers WHERE LayerLevel = 1)
		INSERT INTO #LayerItems1 (item) EXEC sp_executesql @stmt = @SqlForSplit1
		SELECT @sn1 = ISNULL(MIN(sn), 0) FROM #LayerItems1
		WHILE ISNULL(@sn1, 0) > 0
		BEGIN
			-- SELECT @MetricCode + '@' + @LayerName1 + '=' + item FROM #LayerItems1 WHERE sn = @sn1
			SELECT @item1 = item FROM #LayerItems1 WHERE sn = @sn1
			SELECT @SqlForSplit0 = CASE WHEN ISNULL(ValueList, '') = '' THEN SqlForSplit ELSE 'MetricParseList ''' + ValueList + '''' END,
					@LayerName0 = LayerName, @MetricParmName0 = MetricParmName
				FROM MetricLayer WITH (NOLOCK) WHERE LayerSn = @LayerSn
			SELECT @SqlForSplit0 = Replace(@SqlForSplit0, '{' + @LayerName1 + '}', @item1)
			INSERT INTO #LayerItems0 (item) EXEC sp_executesql @stmt = @SqlForSplit0
			SELECT @sn0 = ISNULL(MIN(sn), 0) FROM #LayerItems0
			WHILE ISNULL(@sn0, 0) > 0
			BEGIN
				SELECT @item0 = (SELECT item FROM #LayerItems0 WHERE sn = @sn0)
				SELECT @NewMetricCode = @metriccode + '@' 
						+ @LayerName1 + '=' + @item1 + '_'
						+ @LayerName0 + '=' + @item0 

				SELECT @NewMetricCodeSort = sort
				FROM MetricItem
				WHERE MetricCode = @MetricCode

				IF (ISNULL(@IgnoreUnknownYN, 'N') = 'Y' 
					AND CHARINDEX('=UNKNOWN', @NewMetricCode) = 0)
					OR ISNULL(@IgnoreUnknownYN, 'N') = 'N'
				BEGIN
					IF NOT EXISTS(SELECT * FROM MetricItem WHERE MetricCode = @NewMetricCode)
					BEGIN
						IF ISNULL(@Write, 0) = 0 
							SELECT @NewMetricCode
						ELSE
						BEGIN
							INSERT INTO MetricItem (MetricCode, Caption, CaptionFull, Active, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, ProcedureName, StartDate, LayerSN, Sort)
							SELECT @newMetricCode, @newMetricCode, @newMetricCode, Active, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, ProcedureName, StartDate, @LayerSN, @NewMetricCodeSort FROM metricitem
								WHERE MetricCode = @MetricCode

							-- 2/16/2006: DAG: SNBC
							DELETE MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode

							-- Insert the default values from original metric below.
							IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, ParmName, ParmValue, ParmSort
											FROM MetricParameter 
											WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName <> @MetricParmName0 AND ParmName <> @MetricParmName1)
							BEGIN
								INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
									SELECT 'MetricStoredProc', @NewMetricCode, ParmName, ParmValue, ParmSort
									FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName <> @MetricParmName0 AND ParmName <> @MetricParmName1
							END
							
							IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName1, @item1, ParmSort
											FROM MetricParameter 
											WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName = @MetricParmName1)
							BEGIN
								INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
									SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName1, @item1, ParmSort
									FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @MetricParmName1
							END
							
							IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName0, @item0, ParmSort
											FROM MetricParameter 
											WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName = @MetricParmName0)
							BEGIN
								INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
									SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName0, @item0, ParmSort
									FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @MetricParmName0
							END
							
							IF NOT EXISTS(	SELECT 'Metric', @NewMetricCode, 'REFRESH_HISTORY_AGE_DEFAULT', ParmValue, ParmSort
											FROM MetricParameter 
											WHERE Heading = 'Metric' AND SubHeading = @NewMetricCode AND ParmName = 'REFRESH_HISTORY_AGE_DEFAULT')
							BEGIN
								INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
									SELECT 'Metric', @NewMetricCode, 'REFRESH_HISTORY_AGE_DEFAULT', ParmValue, ParmSort
									FROM MetricParameter WHERE Heading = 'Metric' AND SubHeading = @MetricCode AND ParmName = 'REFRESH_HISTORY_AGE_DEFAULT'
							END
							IF NOT EXISTS(	SELECT 'Metric', @NewMetricCode, 'REFRESH_HISTORY_DAYS_BACK', ParmValue, ParmSort
									FROM MetricParameter WHERE Heading = 'Metric' AND SubHeading = @NewMetricCode AND ParmName = 'REFRESH_HISTORY_DAYS_BACK')
							BEGIN
								INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
									SELECT 'Metric', @NewMetricCode, 'REFRESH_HISTORY_DAYS_BACK', ParmValue, ParmSort
									FROM MetricParameter WHERE Heading = 'Metric' AND SubHeading = @MetricCode AND ParmName = 'REFRESH_HISTORY_DAYS_BACK'
							END
						END
					END
					ELSE
					BEGIN
						IF ISNULL(@Write, 0) = 1
							UPDATE MetricItem SET LayerSN = @LayerSN
								WHERE MetricCode = @NewMetricCode
					END
				END
				SELECT @sn0 = ISNULL(MIN(sn), 0) FROM #LayerItems0 WHERE sn > @sn0
			END
			DELETE #LayerItems0
			SELECT @sn1 = ISNULL(MIN(sn), 0) FROM #LayerItems1 WHERE sn > @sn1
		END

	END
	ELSE IF @nLevel = 2
	BEGIN
		-- Two parent metrics
		SELECT @SqlForSplit2 = CASE WHEN ISNULL(ValueList, '') = '' THEN SqlForSplit ELSE 'MetricParseList ''' + ValueList + '''' END,
				@LayerName2 = LayerName, @MetricParmName2 = MetricParmName
			FROM MetricLayer WITH (NOLOCK) WHERE LayerSn = (SELECT ParentLayerSN FROM #Layers WHERE LayerLevel = 2)
		INSERT INTO #LayerItems2 (item) EXEC sp_executesql @stmt = @SqlForSplit2
		SELECT @sn2 = ISNULL(MIN(sn), 0) FROM #LayerItems2
		WHILE ISNULL(@sn2, 0) > 0
		BEGIN
			SELECT @item2 = item FROM #LayerItems2 WHERE sn = @sn2
			SELECT @SqlForSplit1 = CASE WHEN ISNULL(ValueList, '') = '' THEN SqlForSplit ELSE 'MetricParseList ''' + ValueList + '''' END,
					@LayerName1 = LayerName, @MetricParmName1 = MetricParmName
				FROM MetricLayer WITH (NOLOCK) WHERE LayerSn = (SELECT ParentLayerSN FROM #Layers WHERE LayerLevel = 1)
			SELECT @SqlForSplit1 = Replace(@SqlForSplit1, '{' + @LayerName2 + '}', @item2)

			INSERT INTO #LayerItems1 (item) EXEC sp_executesql @stmt = @SqlForSplit1
			SELECT @sn1 = ISNULL(MIN(sn), 0) FROM #LayerItems1
			WHILE ISNULL(@sn1, 0) > 0
			BEGIN
				-- SELECT @MetricCode + '@' + @LayerName1 + '=' + item FROM #LayerItems1 WHERE sn = @sn1
				SELECT @item1 = item FROM #LayerItems1 WHERE sn = @sn1
				SELECT @SqlForSplit0 = CASE WHEN ISNULL(ValueList, '') = '' THEN SqlForSplit ELSE 'MetricParseList ''' + ValueList + '''' END,
						@LayerName0 = LayerName, @MetricParmName0 = MetricParmName
					FROM MetricLayer WITH (NOLOCK) WHERE LayerSn = @LayerSn
				SELECT @SqlForSplit0 = Replace(@SqlForSplit0, '{' + @LayerName1 + '}', @item1)
				SELECT @SqlForSplit0 = Replace(@SqlForSplit0, '{' + @LayerName2 + '}', @item2)
				INSERT INTO #LayerItems0 (item) EXEC sp_executesql @stmt = @SqlForSplit0
				SELECT @sn0 = ISNULL(MIN(sn), 0) FROM #LayerItems0
				WHILE ISNULL(@sn0, 0) > 0
				BEGIN
					SELECT @item0 = (SELECT item FROM #LayerItems0 WHERE sn = @sn0)
					SELECT @NewMetricCode = @metriccode + '@' 
							+ @LayerName2 + '=' + @item2 + '_'
							+ @LayerName1 + '=' + @item1 + '_'
							+ @LayerName0 + '=' + @item0

					SELECT @NewMetricCodeSort = sort
					FROM MetricItem
					WHERE MetricCode = @MetricCode

					IF (ISNULL(@IgnoreUnknownYN, 'N') = 'Y' 
						AND CHARINDEX('=UNKNOWN', @NewMetricCode) = 0)
						OR ISNULL(@IgnoreUnknownYN, 'N') = 'N'
					BEGIN
						IF NOT EXISTS(SELECT * FROM MetricItem WHERE MetricCode = @NewMetricCode)
						BEGIN
							IF ISNULL(@Write, 0) = 0 
								SELECT @NewMetricCode
							ELSE
							BEGIN
								INSERT INTO MetricItem (MetricCode, Caption, CaptionFull, Active, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, ProcedureName, StartDate, LayerSN, Sort)
								SELECT @newMetricCode, @newMetricCode, @newMetricCode, Active, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, ProcedureName, StartDate, @LayerSN, @NewMetricCodeSort FROM metricitem
									WHERE MetricCode = @MetricCode

								-- 2/16/2006: DAG: SNBC
								DELETE MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode

								-- Insert the default values from original metric below.
								IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, ParmName, ParmValue, ParmSort
												FROM MetricParameter 
												WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName <> @MetricParmName0 AND ParmName <> @MetricParmName1 AND ParmName <> @MetricParmName2)
								BEGIN
									INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
										SELECT 'MetricStoredProc', @NewMetricCode, ParmName, ParmValue, ParmSort
										FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName <> @MetricParmName0 AND ParmName <> @MetricParmName1 AND ParmName <> @MetricParmName2
								END
								
								IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName2, @item2, ParmSort
												FROM MetricParameter 
												WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName = @MetricParmName2)
								BEGIN
									INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
										SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName2, @item2, ParmSort
										FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @MetricParmName2
								END
								
								IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName1, @item1, ParmSort
												FROM MetricParameter 
												WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName = @MetricParmName1)
								BEGIN
									INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
										SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName1, @item1, ParmSort
										FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @MetricParmName1
								END
								
								IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName0, @item0, ParmSort
												FROM MetricParameter 
												WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName = @MetricParmName0)
								BEGIN
									INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
										SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName0, @item0, ParmSort
										FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @MetricParmName0
								END
							END
						END
						ELSE
						BEGIN
							IF ISNULL(@Write, 0) = 1
								UPDATE MetricItem SET LayerSN = @LayerSN
									WHERE MetricCode = @NewMetricCode
						END
					END	
					SELECT @sn0 = ISNULL(MIN(sn), 0) FROM #LayerItems0 WHERE sn > @sn0
				END
				DELETE #LayerItems0
				SELECT @sn1 = ISNULL(MIN(sn), 0) FROM #LayerItems1 WHERE sn > @sn1
			END
			DELETE #LayerItems1
			SELECT @sn2 = ISNULL(MIN(sn), 0) FROM #LayerItems2 WHERE sn > @sn2
		END

	END

	ELSE IF @nLevel = 3
	BEGIN
		-- Three parent metrics
		
		SELECT @SqlForSplit3 = CASE WHEN ISNULL(ValueList, '') = '' THEN SqlForSplit ELSE 'MetricParseList ''' + ValueList + '''' END,
				@LayerName3 = LayerName, @MetricParmName3 = MetricParmName
			FROM MetricLayer WITH (NOLOCK) WHERE LayerSn = (SELECT ParentLayerSN FROM #Layers WHERE LayerLevel = 3)

		INSERT INTO #LayerItems3 (item) EXEC sp_executesql @stmt = @SqlForSplit3
		SELECT @sn3 = ISNULL(MIN(sn), 0) FROM #LayerItems3
		WHILE ISNULL(@sn3, 0) > 0
		BEGIN
			SELECT @item3 = item FROM #LayerItems3 WHERE sn = @sn3
			SELECT @SqlForSplit2 = CASE WHEN ISNULL(ValueList, '') = '' THEN SqlForSplit ELSE 'MetricParseList ''' + ValueList + '''' END,
					@LayerName2 = LayerName, @MetricParmName2 = MetricParmName
				FROM MetricLayer WITH (NOLOCK) WHERE LayerSn = (SELECT ParentLayerSN FROM #Layers WHERE LayerLevel = 2)
			SELECT @SqlForSplit2 = Replace(@SqlForSplit2, '{' + @LayerName3 + '}', @item3)
			INSERT INTO #LayerItems2 (item) EXEC sp_executesql @stmt = @SqlForSplit2
			SELECT @sn2 = ISNULL(MIN(sn), 0) FROM #LayerItems2
			WHILE ISNULL(@sn2, 0) > 0
			BEGIN
				SELECT @item2 = item FROM #LayerItems2 WHERE sn = @sn2
				SELECT @SqlForSplit1 = CASE WHEN ISNULL(ValueList, '') = '' THEN SqlForSplit ELSE 'MetricParseList ''' + ValueList + '''' END,
						@LayerName1 = LayerName, @MetricParmName1 = MetricParmName
					FROM MetricLayer WITH (NOLOCK) WHERE LayerSn = (SELECT ParentLayerSN FROM #Layers WHERE LayerLevel = 1)
				SELECT @SqlForSplit1 = Replace(@SqlForSplit1, '{' + @LayerName3 + '}', @item3)
				SELECT @SqlForSplit1 = Replace(@SqlForSplit1, '{' + @LayerName2 + '}', @item2)
	
				INSERT INTO #LayerItems1 (item) EXEC sp_executesql @stmt = @SqlForSplit1
				SELECT @sn1 = ISNULL(MIN(sn), 0) FROM #LayerItems1
				WHILE ISNULL(@sn1, 0) > 0
				BEGIN
					-- SELECT @MetricCode + '@' + @LayerName1 + '=' + item FROM #LayerItems1 WHERE sn = @sn1
					SELECT @item1 = item FROM #LayerItems1 WHERE sn = @sn1
					SELECT @SqlForSplit0 = CASE WHEN ISNULL(ValueList, '') = '' THEN SqlForSplit ELSE 'MetricParseList ''' + ValueList + '''' END,
							@LayerName0 = LayerName, @MetricParmName0 = MetricParmName
						FROM MetricLayer WITH (NOLOCK) WHERE LayerSn = @LayerSn
					SELECT @SqlForSplit0 = Replace(@SqlForSplit0, '{' + @LayerName3 + '}', @item3)
					SELECT @SqlForSplit0 = Replace(@SqlForSplit0, '{' + @LayerName2 + '}', @item2)
					SELECT @SqlForSplit0 = Replace(@SqlForSplit0, '{' + @LayerName1 + '}', @item1)
					INSERT INTO #LayerItems0 (item) EXEC sp_executesql @stmt = @SqlForSplit0
					SELECT @sn0 = ISNULL(MIN(sn), 0) FROM #LayerItems0
					WHILE ISNULL(@sn0, 0) > 0
					BEGIN
						SELECT @item0 = (SELECT item FROM #LayerItems0 WHERE sn = @sn0)
						SELECT @NewMetricCode = @metriccode + '@' 
								+ @LayerName3 + '=' + @item3 + '_'
								+ @LayerName2 + '=' + @item2 + '_'
								+ @LayerName1 + '=' + @item1 + '_'
								+ @LayerName0 + '=' + @item0 

						SELECT @NewMetricCodeSort = sort
						FROM MetricItem
						WHERE MetricCode = @MetricCode

						IF (ISNULL(@IgnoreUnknownYN, 'N') = 'Y' 
							AND CHARINDEX('=UNKNOWN', @NewMetricCode) = 0)
							OR ISNULL(@IgnoreUnknownYN, 'N') = 'N'
						BEGIN
							IF NOT EXISTS(SELECT * FROM MetricItem WHERE MetricCode = @NewMetricCode)
							BEGIN
								IF ISNULL(@Write, 0) = 0 
									SELECT @NewMetricCode
								ELSE
								BEGIN
									INSERT INTO MetricItem (MetricCode, Caption, CaptionFull, Active, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, ProcedureName, StartDate, RefreshHistoryYN, LayerSN, Sort)
									SELECT @newMetricCode, @newMetricCode, @newMetricCode, Active, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, ProcedureName, StartDate, RefreshHistoryYN = ISNULL(RefreshHistoryYN, ''), @LayerSN, @NewMetricCodeSort 
									FROM metricitem
										WHERE MetricCode = @MetricCode

									-- 2/16/2006: DAG: SNBC
									DELETE MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode

									-- Insert the default values from original metric below.
									IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, ParmName, ParmValue, ParmSort
													FROM MetricParameter 
													WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName <> @MetricParmName0 AND ParmName <> @MetricParmName1 AND ParmName <> @MetricParmName2 AND ParmName <> @MetricParmName3)
									BEGIN
										INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
											SELECT 'MetricStoredProc', @NewMetricCode, ParmName, ParmValue, ParmSort
											FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName <> @MetricParmName0 AND ParmName <> @MetricParmName1 AND ParmName <> @MetricParmName2 AND ParmName <> @MetricParmName3
									END
									
									IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName3, @item3, ParmSort 
													FROM MetricParameter 
													WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName = @MetricParmName3)
									BEGIN
										INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
											SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName3, @item3, ParmSort 
											FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @MetricParmName3
									END
									
									IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName2, @item2, ParmSort
													FROM MetricParameter 
													WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName = @MetricParmName2)
									BEGIN
										INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
											SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName2, @item2, ParmSort
											FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @MetricParmName2
									END
									
									IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName1, @item1, ParmSort
													FROM MetricParameter 
													WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName = @MetricParmName1)
									BEGIN
										INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
											SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName1, @item1, ParmSort
											FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @MetricParmName1
									END
									
									IF NOT EXISTS(	SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName0, @item0, ParmSort
													FROM MetricParameter 
													WHERE Heading = 'MetricStoredProc' AND SubHeading = @NewMetricCode AND ParmName = @MetricParmName0)
									BEGIN
										INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue, ParmSort)
											SELECT 'MetricStoredProc', @NewMetricCode, @MetricParmName0, @item0, ParmSort
											FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @MetricParmName0
									END
								END
							END
							ELSE
							BEGIN
								IF ISNULL(@Write, 0) = 1
									UPDATE MetricItem SET LayerSN = @LayerSN
										WHERE MetricCode = @NewMetricCode	
							END
						END
						SELECT @sn0 = ISNULL(MIN(sn), 0) FROM #LayerItems0 WHERE sn > @sn0
					END
					DELETE #LayerItems0
					SELECT @sn1 = ISNULL(MIN(sn), 0) FROM #LayerItems1 WHERE sn > @sn1
				END
				DELETE #LayerItems1
				SELECT @sn2 = ISNULL(MIN(sn), 0) FROM #LayerItems2 WHERE sn > @sn2
			END
			DELETE #LayerItems2
			SELECT @sn3 = ISNULL(MIN(sn), 0) FROM #LayerItems3 WHERE sn > @sn3
		END
	END

	DROP TABLE #Layers
	DROP TABLE #LayerItems0 
	DROP TABLE #LayerItems1 
	DROP TABLE #LayerItems2 
	DROP TABLE #LayerItems3 

GO
GRANT EXECUTE ON  [dbo].[MetricCreateLayers] TO [public]
GO
