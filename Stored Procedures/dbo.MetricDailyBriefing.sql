SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDailyBriefing] (@MetricCode varchar(200), @BriefingEmailAddress varchar(2000), @ProcessFlags int,
		@MetricCaption VARCHAR(200), @DateCur varchar(100), @Result decimal(20, 5), @ThisCount decimal(20, 5), @ThisTotal decimal(20, 5)
		, @ThisTotalTempFix varchar(100) = NULL -- This is a temporary fix for international.  Real fix will be in .NET code and this will be replaced by original procedure.
)
AS
	SET NOCOUNT ON

	DECLARE @DelimiterStart int, @DelimiterEnd int
	DECLARE @TempEmailAddress varchar(1000), @BriefingMessage varchar(2000)
	DECLARE @ThisTotalTempFix_Number float
	DECLARE @DateCur_DT datetime

	SELECT @DateCur_DT = @DateCur
	------------------
	--Daily Briefing--
	------------------
					
	-- 1) Parse email list into #TheseEmails, add entry for each email to #emailmetrics for each day processed.
	--		CREATE TABLE #TheseEmails (sn int identity, email varchar(255))
	--		CREATE TABLE #emailmetrics (email varchar(255), 
	--							MetricCode varchar(100), MetricCaption varchar(100), PlainDate datetime,
	--							Result decimal(20, 5), @ThisCount decimal(20, 5), @ThisTotal decimal(20, 5)

	IF @BriefingEmailAddress <> '' AND NOT (@ProcessFlags & 256 = 256)
	BEGIN
		SELECT @DelimiterStart = 1
		WHILE 1=1
		BEGIN
			SELECT @DelimiterEnd = CHARINDEX(';', @BriefingEmailAddress, @DelimiterStart)
			IF @DelimiterEnd > 0 
			BEGIN
				SELECT @TempEmailAddress = LTRIM(SUBSTRING(@BriefingEmailAddress, @DelimiterStart, @DelimiterEnd - @DelimiterStart))
				IF @TempEmailAddress <> ''
					IF NOT EXISTS(SELECT * FROM MetricTempEmails WHERE email = @TempEmailAddress)
						INSERT INTO MetricTempEmails (email) SELECT @TempEmailAddress
			END
			ELSE
			BEGIN
				BREAK
			END
			SELECT @DelimiterStart = @DelimiterEnd + 1
		END
		SELECT @TempEmailAddress = LTRIM(SUBSTRING(@BriefingEmailAddress, @DelimiterStart, LEN(@BriefingEmailAddress) - @DelimiterStart + 1))
		IF @TempEmailAddress <> ''				
			IF NOT EXISTS(SELECT * FROM MetricTempEmails WHERE email = @TempEmailAddress)
				INSERT INTO MetricTempEmails (email) SELECT @TempEmailAddress

		IF @ThisTotalTempFix IS NOT NULL
		BEGIN
			IF ISNUMERIC(@ThisTotalTempFix) = 1
			BEGIN
				SET @ThisTotalTempFix_Number = CONVERT(float, '.' + @ThisTotalTempFix)
				SET @ThisTotal = @ThisTotal + @ThisTotalTempFix_Number 
			END
		END

		INSERT INTO MetricTempEmailMetrics (email, MetricCode, MetricCaption, PlainDate, Result, ThisCount, ThisTotal)
			SELECT email, @MetricCode, @MetricCaption, @DateCur_DT, @Result, @ThisCount, @ThisTotal FROM MetricTempEmails
		DELETE MetricTempEmails
	END
	-- ******* Daily Briefing: END *****************
GO
GRANT EXECUTE ON  [dbo].[MetricDailyBriefing] TO [public]
GO
