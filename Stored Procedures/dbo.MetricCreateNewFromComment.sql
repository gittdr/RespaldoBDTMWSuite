SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCreateNewFromComment] (@Debug_Level int = 0)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	/*
		Purpose:	Gets called when MetricProcessing is called to automatically create new metricitems and categoryitem entries when new metric items are created.
					After this gets called, metricdetail should be backfilled for the last 60 days (or starting 60 days before the mock date).
                    Backfill should happen in MetricProcessing - not here.
	*/

	DECLARE @id int, @NewMetricProc varchar(100), @SQL varchar(4000)
	DECLARE @NewItemCategoryCode VARCHAR(30), @NewItemSort int

	-- CREATE TABLE #tempDebugCreateFromComment (sn int identity, sText varchar(2000))

	SELECT @NewItemCategoryCode = 'NewItems'
	SELECT @NewItemCategoryCode = ISNULL(ParmValue, 'NewItems') from MetricParameter WHERE Heading = 'MetricGeneral' AND SubHeading = 'AutoCreateMetric' AND ParmName = 'NewItemCategoryCode'

	-- Start with first id in sysobjects that appears to be a metric item stored procedure, and then loop through all of these.
	SELECT @id = MIN(id) FROM sysobjects 
	WHERE name LIKE 'Metric%' 
			AND type = 'p' 
			AND SUBSTRING(name, 7, 1) = '_' 
			AND name NOT IN (SELECT ProcedureName FROM MetricItem)
			AND RIGHT(name, 3) <> '_TM'								-- Ignore TotalMail specific... Maybe these should be called HELPER procs.

	-- As long as we have a valid id, keep looping.
	WHILE ISNULL(@id, 0) > 0
	BEGIN
		SELECT @NewMetricProc = name FROM sysobjects WHERE id = @id AND type = 'p'
		IF @Debug_Level > 0 PRINT 'New Metric Proc = ' + @NewMetricProc

		-- Requirement is that the SQL to be inserted needs to be contained within the tags <METRIC-INSERT-SQL> and </METRIC-INSERT-SQL>.
		IF EXISTS(SELECT * FROM sysobjects t1, syscomments t2 WHERE t1.id = t2.id AND t1.name = @NewMetricProc AND t2.text LIKE '%<METRIC-INSERT-SQL>%')
			AND EXISTS(SELECT * FROM sysobjects t1, syscomments t2 WHERE t1.id = t2.id AND t1.name = @NewMetricProc AND t2.text LIKE '%</METRIC-INSERT-SQL>%')
		BEGIN
			SELECT @SQL = SUBSTRING(text, 
				(SELECT CHARINDEX('<METRIC-INSERT-SQL>', t2.text, 1) from syscomments WHERE id = t1.id AND colid = 1) + LEN('<METRIC-INSERT-SQL>'),
				(SELECT CHARINDEX('</METRIC-INSERT-SQL>', t2.text, 1) from syscomments WHERE id = t1.id AND colid = 1) 
					- (SELECT CHARINDEX('<METRIC-INSERT-SQL>', t2.text, 1) from syscomments WHERE id = t1.id AND colid = 1) 
					- LEN('</METRIC-INSERT-SQL>')
				)
			FROM sysobjects t1, syscomments t2 
			WHERE t1.id = t2.id 
				AND t1.name = @NewMetricProc -- 'Metric_InvoicedAmount'
				AND colid = 1
		
			IF @Debug_Level > 0 PRINT 'DEBUG INFO' + CHAR(13) + CHAR(10) + @SQL
			EXEC (@SQL)		-- Insert the new metric into the MetricItem table if it exists.
		END
		ELSE
		BEGIN
			IF @Debug_Level > 0 PRINT @NewMetricProc + ': There is no <METRIC-INSERT-INFO> tag for this new metric stored procedure.'
		END
		
		SELECT @id = MIN(id) FROM sysobjects 
		WHERE name LIKE 'Metric%' 
				AND type = 'p' 
				AND SUBSTRING(name, 7, 1) = '_' 
				AND name NOT IN (SELECT ProcedureName FROM MetricItem)
				AND RIGHT(name, 3) <> '_TM'		-- Don't do Totalmail based stored procedures.
				AND id > @id
	END

	-- IF @Debug_Level > 0
	--	SELECT sText FROM #tempDebugCreateFromComment ORDER BY sn
GO
GRANT EXECUTE ON  [dbo].[MetricCreateNewFromComment] TO [public]
GO
