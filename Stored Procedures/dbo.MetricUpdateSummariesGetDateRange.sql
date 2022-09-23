SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricUpdateSummariesGetDateRange]
(
	@MetricCodePassed VARCHAR(200) = NULL, 
	@DateFirstProcessDate datetime = NULL, 
	@Debug_Level int = NULL,
	@DateLastProcessDate datetime = NULL,
	@ActualDateStart datetime = NULL OUTPUT, 
	@ActualDateEnd datetime = NULL OUTPUT
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	DECLARE @PerceivedProcessAndViewingDate datetime
	-- DECLARE @WeekOneIsFirstFullWeekYN varchar(1)
	DECLARE @MetricDateStart datetime
	DECLARE @TempYear varchar(4)
	DECLARE @FirstDayOfLastWeekOfPreviousYear datetime  -- Based on StartDate
	DECLARE @LastDayOfFirstWeekOfNextYear datetime 		-- Based on EndDate
	DECLARE @MetricProcessingDaysToOffset int
	DECLARE @DateFirstProcessDateMINIMUM datetime
	DECLARE @DateFirstProcessDateMAXIMUM datetime
	DECLARE @GetDate datetime

	SELECT @GetDate = GETDATE()

	SELECT @DateFirstProcessDate = CONVERT(datetime, CONVERT(varchar(10), @DateFirstProcessDate, 121))
	SELECT @DateLastProcessDate = CONVERT(datetime, CONVERT(varchar(10), @DateLastProcessDate, 121))

	--******************************************************************************************
	-- Determine the starting date
	--		Function of: @DateFirstProcessDate AND MetricItem.StartDate
	--******************************************************************************************
	IF EXISTS(SELECT * FROM MetricItem WHERE MetricCode = @MetricCodePassed)
		SELECT @MetricDateStart = ISNULL(StartDate, '19000101') FROM MetricItem WHERE MetricCode = @MetricCodePassed
	ELSE 
		SELECT @MetricDateStart = '19000101'

	IF @MetricCodePassed IS NULL 
	BEGIN
		SELECT @DateFirstProcessDateMINIMUM = MIN(PlainDate) FROM MetricDetail WITH (NOLOCK) 
		SELECT @DateFirstProcessDateMAXIMUM = MAX(PlainDate) FROM MetricDetail WITH (NOLOCK) 
	END
	ELSE
	BEGIN
		SELECT @DateFirstProcessDateMINIMUM = MIN(PlainDate) FROM MetricDetail WITH (NOLOCK) WHERE MetricCode = @MetricCodePassed 
		SELECT @DateFirstProcessDateMAXIMUM = MAX(PlainDate) FROM MetricDetail WITH (NOLOCK) WHERE MetricCode = @MetricCodePassed 
	END

	SET @MetricProcessingDaysToOffset = ISNULL((SELECT SettingValue FROM metricgeneralsettings WHERE SettingName = 'MetricProcessingDaysToOffset'), 0)
	SELECT @PerceivedProcessAndViewingDate = @DateFirstProcessDateMAXIMUM--CONVERT(datetime, CONVERT(varchar(10), DATEADD(day, -@MetricProcessingDaysToOffset, @GetDate), 121))
	IF (@DateFirstProcessDate IS NULL)
	BEGIN
		IF @PerceivedProcessAndViewingDate > @DateFirstProcessDateMINIMUM 
				AND DATEPART(month, @PerceivedProcessAndViewingDate) = 1
				AND DATEPART(day, @PerceivedProcessAndViewingDate) <= 7
		BEGIN
			IF CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @PerceivedProcessAndViewingDate)) + '0101') < @DateFirstProcessDateMINIMUM 
				SELECT @DateFirstProcessDate = @DateFirstProcessDateMINIMUM 
			ELSE
				SELECT @DateFirstProcessDate = @PerceivedProcessAndViewingDate 
		END
		ELSE IF @PerceivedProcessAndViewingDate > @DateFirstProcessDateMINIMUM 
		BEGIN
			SELECT @DateFirstProcessDate = CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @PerceivedProcessAndViewingDate)) + '0101') 
		END
	END
	ELSE
	BEGIN
		IF @DateFirstProcessDate > @DateFirstProcessDateMINIMUM 
				AND DATEPART(month, @DateFirstProcessDate) = 1
				AND DATEPART(day, @DateFirstProcessDate) <= 7
		BEGIN
			IF CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @DateFirstProcessDate)) + '0101') < @DateFirstProcessDateMINIMUM 
			BEGIN
				SELECT @DateFirstProcessDate = @DateFirstProcessDateMINIMUM 
			END
			ELSE
			BEGIN
				SELECT @DateFirstProcessDate = CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @DateFirstProcessDate)-1) + '0101')
			END
		END
		ELSE IF @DateFirstProcessDate > @DateFirstProcessDateMINIMUM 
		BEGIN
			SELECT @DateFirstProcessDate = CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @DateFirstProcessDate)) + '0101') 
		END
	END
	IF @DateFirstProcessDate < @DateFirstProcessDateMINIMUM 
		SELECT @DateFirstProcessDate = @DateFirstProcessDateMINIMUM 
	SELECT @ActualDateStart = @DateFirstProcessDate
	SELECT @ActualDateEnd = @PerceivedProcessAndViewingDate

/*
	IF @MetricDateStart > @ActualDateStart SELECT @ActualDateStart = @MetricDateStart 
    IF (1=2) -- This will mess up the last week of the year data.
	BEGIN
		IF (@DateFirstProcessDate IS NULL)	SELECT @DateFirstProcessDate = @PerceivedProcessAndViewingDate
		--	If (DateStart is NULL) or (DateStart < the 1st DAY of LAST WEEK of Year(start)-1), then 1st DAY of LAST WEEK of Year(start)-1
		--	Else DateStart

		-- BEGIN: Calculate @FirstDayOfLastWeekOfPreviousYear
		SELECT @TempYear = CONVERT(varchar(4), DATEPART(year, @DateFirstProcessDate)- 1)
		SELECT @FirstDayOfLastWeekOfPreviousYear = DATEADD(day, 1-DATEPART(dw, CONVERT(datetime, @TempYear + '1231')), CONVERT(datetime, @TempYear + '1231'))
		-- END: Calculate @FirstDayOfLastWeekOfPreviousYear

		IF EXISTS(SELECT * FROM MetricItem WHERE MetricCode = @MetricCodePassed)
			SELECT @MetricDateStart = ISNULL(StartDate, '19000101') FROM MetricItem WHERE MetricCode = @MetricCodePassed
		ELSE 
			SELECT @MetricDateStart = '19000101'
		IF @MetricDateStart < @FirstDayOfLastWeekOfPreviousYear OR @MetricDateStart > @DateFirstProcessDate
			-- In actuality, we should also check 'yearweek before or equal to the yearweek of' ~~ @FirstDayOfLastWeekOfPreviousYear
			-- Look at logic in MetricUpdateSummaries
			SELECT @ActualDateStart = @FirstDayOfLastWeekOfPreviousYear
		ELSE
		BEGIN
			SELECT @ActualDateStart = @MetricDateStart
		END
	END
*/
	--******************************************************************************************
	-- Determine the ending date
	--		Function of: @DateLastProcessDate AND @PerceivedProcessAndViewingDate
	--******************************************************************************************

/*
	IF (@DateLastProcessDate IS NULL)
	BEGIN
		-- SELECT @DateLastProcessDate = @PerceivedProcessAndViewingDate
		SELECT @DateLastProcessDate = @PerceivedProcessAndViewingDate 
	END
	--select @DateLastProcessDate as lastprocessdate, @PerceivedProcessAndViewingDate as Precevieddate
	SELECT @ActualDateEnd = CONVERT(datetime, CONVERT(varchar(4), DATEPART(year, @DateLastProcessDate)) + '1231')

	--select @ActualDateEnd
	IF (@ActualDateEnd > @PerceivedProcessAndViewingDate) SELECT @ActualDateEnd = @PerceivedProcessAndViewingDate
	IF 1=2 -- This will mess up the last week of the year data.
	BEGIN
		IF (@DateLastProcessDate IS NULL)		SELECT @DateLastProcessDate = @PerceivedProcessAndViewingDate
		--	If Year(end)+1 < Year(ProcessDate), Then Last DAY of FIRST WEEK of Year(end)+1. ==>> Because only summarizing in 2003
		--	Else ProcessDate

		-- BEGIN: Calculate @LastDayOfLastWeekOfPreviousYear
		SELECT @TempYear = CONVERT(varchar(4), DATEPART(year, @DateLastProcessDate) + 1)
		SELECT @LastDayOfFirstWeekOfNextYear = DATEADD(day, -DATEPART(dw, CONVERT(datetime, @TempYear + '0107')), CONVERT(datetime, @TempYear + '0107'))
		-- END: Calculate @LastDayOfLastWeekOfPreviousYear
	
		-- The next statement says use @PerceivedProcessAndViewingDate if the last date processed is the same as the PerceivedProcessAndViewingDate
		IF @DateLastProcessDate = @PerceivedProcessAndViewingDate 
		BEGIN
			SELECT @ActualDateEnd = @DateLastProcessDate
		END
		ELSE
		BEGIN
			IF DATEPART(year, @DateLastProcessDate) < DATEPART(year, @PerceivedProcessAndViewingDate)
				SELECT @ActualDateEnd = @LastDayOfFirstWeekOfNextYear
			ELSE 
				SELECT @ActualDateEnd = @PerceivedProcessAndViewingDate

			IF (@ActualDateEnd IS NULL)		SELECT @ActualDateEnd = @PerceivedProcessAndViewingDate  -- DEFAULT TO THIS.
		END
	END
*/
	--******************************************************************************************
	-- Print out the resulting dates for verification.
	--******************************************************************************************
/*	SELECT -- @MetricCodePassed AS 'MetricCodeToUpdate',
			CONVERT(varchar(10), @PerceivedProcessAndViewingDate, 110) AS 'Process And View',
			CONVERT(varchar(10), @DateFirstProcessDate, 110) AS 'Process Start', 
			CONVERT(varchar(10), @DateLastProcessDate, 110) AS 'Process End', 
			CONVERT(varchar(10), @ActualDateStart, 110) AS 'Update Summary Start', 
			CONVERT(varchar(10), @ActualDateEnd, 110) AS 'Update Summary End'
*/

	-- EXEC MetricGetParameterText @WeekOneIsFirstFullWeekYN OUTPUT, 'Y', 'Config', 'All', 'WEEK_ONE_IS_FIRST_FULL_WEEK_YN'
	-- Get the perceived processing and viewing date.
	-- EXEC MetricGetPerceivedDate @ExecuteOnly = 1, @VirtualDate = @PerceivedProcessAndViewingDate OUTPUT, @Adjusted = 1
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateSummariesGetDateRange] TO [public]
GO
