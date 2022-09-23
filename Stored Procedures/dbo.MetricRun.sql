SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricRun]
(
	@MetricCode varchar(200), 
	@DateStart datetime = NULL, 
	@DateEnd datetime = NULL, 
	@ShowDetail int = NULL,
	@DetailOnly int = 0,
	@Parm1Name varchar(255) = NULL, -- Overide
	@Parm1Value varchar(512) = NULL, -- Overide
	@Parm2Name varchar(255) = NULL, -- Overide
	@Parm2Value varchar(512) = NULL, -- Overide
	@Parm3Name varchar(255) = NULL, -- Overide
	@Parm3Value varchar(512) = NULL, -- Overide
	@Parm4Name varchar(255) = NULL, -- Overide
	@Parm4Value varchar(512) = NULL,-- Overide
	@Parm5Name varchar(255) = NULL, -- Overide
	@Parm5Value varchar(512) = NULL -- Overide
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	/*
		Date range passed in is converted to be inclusive.

		MetricRun 'OrdersBookedPerDay', '1/22/2003'
		MetricRun 'OrdersBookedPerDay', '1/22/2003', '1/24/2003'
		MetricRun 'ETALATe', '1/22/2003', @ShowDetail = 1

		NOTE: Does not support minutes right now for simplicity.
	*/
	DECLARE @Result decimal(20, 5), @ThisCount decimal(20, 5), @ThisTotal decimal(20, 5)
	DECLARE @SQL NVARCHAR(1000)
	DECLARE @ProcName varchar(255)
	DECLARE @NextParameter varchar(255)
	DECLARE @NextParameterValue varchar(512)
	DECLARE @NextParmSN int

	IF (@DateStart IS NULL) 	SELECT @DateStart = CONVERT(datetime, CONVERT(varchar(10), GETDATE(), 101))
	ELSE 						SELECT @DateStart = CONVERT(datetime, CONVERT(varchar(10), @DateStart, 101))

	IF (@DateEnd IS NULL)		SELECT @DateEnd = DATEADD(DAY, 1, @DateStart)
	ELSE 						SELECT @DateEnd = DATEADD(DAY, 0, CONVERT(datetime, CONVERT(varchar(10), @DateEnd, 101)))

	IF (@ShowDetail IS NULL) SELECT @ShowDetail = 0

	SELECT @ProcName = ProcedureName FROM MetricItem WHERE MetricCode = @MetricCode
	IF NOT EXISTS(SELECT * FROM sysobjects WHERE type = 'p' AND name = @ProcName)
	BEGIN
		PRINT 'Stored procedure does not exist for this metric.'
		RETURN
	END

	SELECT @SQL = 'EXEC ' + @ProcName + ' 0, 0, 0, ''' 
							+ CONVERT(varchar(16), @DateStart, 20) + ''', ''' 
							+ CONVERT(varchar(16), @DateEnd, 20) + ''', ' 
							+ '1, ' + CONVERT(varchar(10), @ShowDetail)

	-- Parameters
	SET @NextParameter=''
	SET @NextParmSN =0
	WHILE 1=1
		BEGIN
			SET @NextParmSN =	(	
						SELECT MIN(sn) 
						FROM MetricParameter
						WHERE MetricParameter.Heading = 'MetricStoredProc'
							AND	MetricParameter.SubHeading = @MetricCode
							AND	ISNULL(sn,0) > @NextParmSN
						)
			IF @NextParmSN IS NULL BREAK 

			SELECT @NextParameterValue = ParmValue, @NextParameter = ParmName
			FROM MetricParameter
			WHERE MetricParameter.Heading = 'MetricStoredProc'
				AND MetricParameter.SubHeading = @MetricCode
				AND ISNULL(sn,0) = @NextParmSN

			IF @NextParameterValue IS NOT NULL
			BEGIN
				IF @Parm1Name = @NextParameter and @NextParameter <> '@MetricCode'
				BEGIN
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @Parm1Value + '''' 
				END
				ELSE IF @Parm2Name = @NextParameter and @NextParameter <> '@MetricCode'
				BEGIN
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @Parm2Value + '''' 
				END
				ELSE IF @Parm3Name = @NextParameter and @NextParameter <> '@MetricCode'
				BEGIN
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @Parm3Value + '''' 
				END
				ELSE IF @Parm4Name = @NextParameter and @NextParameter <> '@MetricCode'
				BEGIN
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @Parm4Value + '''' 
				END
				ELSE IF @Parm5Name = @NextParameter and @NextParameter <> '@MetricCode'
				BEGIN
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @Parm5Value + '''' 
				END
				ELSE
				BEGIN
					IF (@NextParameter <> '@MetricCode')  -- 'MetricCode' is a reserved parameter not allowed.
					BEGIN
						SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @NextParameterValue + '''' 
					END
				END
			END
			ELSE
			BEGIN
				IF @Parm1Name = @NextParameter and @NextParameter <> '@MetricCode'
				BEGIN
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @Parm1Value + '''' 
				END
				ELSE IF @Parm2Name = @NextParameter and @NextParameter <> '@MetricCode'
				BEGIN
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @Parm2Value + '''' 
				END
				ELSE IF @Parm3Name = @NextParameter and @NextParameter <> '@MetricCode'
				BEGIN
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @Parm3Value + '''' 
				END
				ELSE IF @Parm4Name = @NextParameter and @NextParameter <> '@MetricCode'
				BEGIN
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @Parm4Value + '''' 
				END
				ELSE IF @Parm5Name = @NextParameter and @NextParameter <> '@MetricCode'
				BEGIN
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @Parm5Value + '''' 
				END
			END
			/*
			IF @Parm1Name IS NOT NULL
			BEGIN
				IF @NextParameter = @Parm1Name
				BEGIN
					SET @NextParameterValue = @Parm1Value
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @NextParameterValue + '''' 
				END	
			END
			IF @Parm2Name IS NOT NULL
			BEGIN
				IF @NextParameter = @Parm2Name
				BEGIN
					SET @NextParameterValue = @Parm2Value
					SET @SQL = @SQL + ', ' + @NextParameter + '=''' + @NextParameterValue + '''' 
				END	
			END
			*/
		END

		IF EXISTS(SELECT * FROM sysobjects t1, syscolumns t2 WHERE t1.id = t2.id AND t1.name = @ProcName AND t2.name = '@MetricCode')
		BEGIN
			SET @SQL = @SQL + ', @MetricCode=''' + @MetricCode + '''' 
		END

	EXECUTE (@SQL)
	Set  	@Result= ISNULL((Select Result from MetricTemp where SN=(Select max(SN) from MetricTemp) ), 0)
	Set  	@ThisCount= (Select ThisCount from MetricTemp where SN=(Select max(SN) from MetricTemp) )
	Set  	@ThisTotal= (Select ThisTotal from MetricTemp where SN=(Select max(SN) from MetricTemp) )
	DELETE MetricTemp where sn < ISNULL( (select max(sn) from MetricTemp),0) +1000 

	IF @DetailOnly = 0
		SELECT @Result AS Result, @ThisCount AS ThisCount, @ThisTotal AS ThisTotal, 
				@DateStart AS DateStartPassed, @DateEnd AS DateEndPassed, DATEDIFF(day, @DateStart, @DateEnd) AS NumberOfDaysIncluded
	
	/*
		DECLARE @result decimal(20, 5), @thiscount decimal(20, 5), @thistotal decimal(20, 5)
		EXEC Metric_ordersbookedperday @result output, @thiscount output, @thistotal output, '2003-01-10 00:00', '2003-03-31 00:00', 1, 1, @OnlyRevClass2List='oh'
		Set  	@Result= ISNULL((Select Result from MetricTemp where SN=(Select max(SN) from MetricTemp) ), 0)
		Set  	@ThisCount= (Select ThisCount from MetricTemp where SN=(Select max(SN) from MetricTemp) )
		Set  	@ThisTotal= (Select ThisTotal from MetricTemp where SN=(Select max(SN) from MetricTemp) )
		select @result, @thiscount, @thistotal
	*/


GO
GRANT EXECUTE ON  [dbo].[MetricRun] TO [public]
GO
