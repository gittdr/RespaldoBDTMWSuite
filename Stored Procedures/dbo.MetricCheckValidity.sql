SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckValidity] 
	@ShowDetail int = NULL, 
	@DetailToShow int = NULL
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	--***** RULES
	-- 1) Any NULL dates for PlainDate indicates somthing has gone wrong.
	--       RESULT: MetricCode, FirstOccuranceDate (Show SN), LastOccuranceDate (Show SN)

	-- 2) Any NULL dates for Upd_Sumary indicates somthing has gone wrong.
	--       RESULT: MetricCode, FirstOccuranceDate, LastOccuranceDate

	-- 3) Any NULL dates for Upd_Daily indicates somthing has gone wrong.
	--		If there is an entry in MetricDetail, then it should have a non-NULL value in field Upd_Daily - meaning a value has been calculated for that metric for that day indicating MetricProcessing has run.
	--       RESULT: MetricCode, FirstOccuranceDate, LastOccuranceDate

	-- 4) Every metric needs to be continuous from it oldest entry to its most recent entry.
	--       RESULT: MetricCode, FirstOccuranceDate, LastOccuranceDate

	-- 5) For a metric, any time Upd_Daily occurs after Upd_sumnmary, the metric is invalid.
	--       RESULT: MetricCode, FirstOccuranceDate, LastOccuranceDate
 
	DECLARE @DateToUse datetime, @GlobalStartDate datetime
	DECLARE @ValidData int, @ReasonInvalidData VARCHAR(1000)
	DECLARE @TEXTOUT_Rule01 VARCHAR(255), @TEXTOUT_Rule02 VARCHAR(255), @TEXTOUT_Rule03 VARCHAR(255), @TEXTOUT_Rule04 VARCHAR(255), @TEXTOUT_Rule05 VARCHAR(255)
	DECLARE @RunPreviousDayYN varchar(1)

	SELECT @ValidData = 1, @ReasonInvalidData = '', 
		   @TEXTOUT_Rule01 = 'NULL values discovered in PlainDate',
		   @TEXTOUT_Rule02 = 'NULL values discovered in Upd_Summary',
		   @TEXTOUT_Rule03 = 'NULL values discovered in Upd_Daily',
		   @TEXTOUT_Rule04 = 'Interuption in data flow',
		   @TEXTOUT_Rule05 = 'Upd_Summary less than Upd_Daily',
		   @ShowDetail = ISNULL(@ShowDetail, 0), @DetailToShow = ISNULL(@DetailToShow, 0)

	-- RULE #1::: PlainDate is NULL (Probably not going to happen.)
	SELECT metriccode, 
		FirstOccurance = (SELECT 'SN=' + CONVERT(varchar(10), MIN(sn)) FROM metricdetail where metriccode = t1.metriccode and PlainDate is null),
		LastOccurance = (SELECT 'SN=' + CONVERT(varchar(10), MAX(sn)) FROM metricdetail where metriccode = t1.metriccode and PlainDate is null)
	FROM metricitem t1 WHERE Active = 1 AND EXISTS(SELECT MetricCode FROM metricdetail where metriccode = t1.metriccode and PlainDate is null)

	-- RULE #2::: Upd_Summary is NULL
	SELECT metriccode, 
		FirstOccurance = (SELECT MIN(Plaindate) FROM metricdetail where metriccode = t1.metriccode and upd_summary is null ),
		LastOccurance = (SELECT MAX(Plaindate) FROM metricdetail where metriccode = t1.metriccode and upd_summary  is null )
	FROM metricitem t1 WHERE Active = 1 AND EXISTS(SELECT MetricCode FROM metricdetail where metriccode = t1.metriccode and upd_summary  is null )

	-- RULE #3::: Upd_Daily is NULL
	SELECT metriccode, 
		FirstOccurance = (SELECT MIN(Plaindate) FROM metricdetail where metriccode = t1.metriccode and upd_daily is null ),
		LastOccurance = (SELECT MAX(Plaindate) FROM metricdetail where metriccode = t1.metriccode and upd_daily is null )
	FROM metricitem t1 WHERE Active = 1 AND EXISTS(SELECT MetricCode FROM metricdetail where metriccode = t1.metriccode and upd_daily is null )


	-- RULE #4: Continuous data flow. 
	SELECT metriccode,
		FirstOccurance = (SELECT DATEADD(day, 1, MIN(PlainDate))
			FROM MetricDetail t2
			WHERE metriccode = t1.MetricCode 
				AND NOT EXISTS(SELECT MetricCode FROM MetricDetail WHERE metriccode = t1.MetricCode AND PlainDate = DATEADD(day, 1, t2.PlainDate))
		),
		LastOccurance = (SELECT DATEADD(day, -1, MAX(PlainDate))
			FROM MetricDetail t2
			WHERE metriccode = t1.MetricCode 
				AND NOT EXISTS(SELECT MetricCode FROM MetricDetail WHERE metriccode = t1.MetricCode AND PlainDate = DATEADD(day, -1, t2.PlainDate))
		)
	FROM metricitem t1 WHERE Active = 1 AND
		(SELECT COUNT(*) FROM MetricDetail WHERE metriccode = t1.MetricCode) <>
			(SELECT 1 + DATEDIFF(day, (SELECT MIN(PlainDate) FROM MetricDetail WHERE metriccode = t1.metriccode), (SELECT MAX(PlainDate) FROM MetricDetail WHERE metriccode = t1.metriccode) ))


	-- RULE #5: Upd_Daily is after Upd_Summary indicates metricprocessing ran but UpdateSummaries did not run.
	SELECT metriccode,
		FirstOccurance = (SELECT MIN(PlainDate) FROM metricdetail WHERE metriccode = t1.metriccode AND upd_daily > Upd_summary ),
		LastOccurance = (SELECT MAX(PlainDate) FROM metricdetail WHERE metriccode = t1.metriccode AND upd_daily > Upd_summary ) 
	FROM metricitem t1 WHERE Active = 1 AND
		EXISTS(SELECT metriccode FROM metricdetail WHERE metriccode = t1.metriccode AND upd_daily > Upd_summary)

GO
GRANT EXECUTE ON  [dbo].[MetricCheckValidity] TO [public]
GO
