SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCreateViewAll] 
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	DECLARE @SQL VARCHAR(8000), @sn int

	IF EXISTS(SELECT * FROM sysobjects WHERE name = 'vw_MetricAll' AND type = 'V') DROP VIEW vw_MetricAll
	SELECT @SQL = 'CREATE VIEW dbo.vw_MetricAll AS '
				+ 'SELECT DISTINCT t1.plaindate, ' + CHAR(13) + CHAR(10) 
	SELECT @sn = MIN(t2.sn) FROM metricdetail t1, metricitem t2 WHERE t1.metriccode = t2.metriccode 
	WHILE ISNULL(@sn, 0) > 0
    BEGIN
		SELECT @SQL = @SQL + '(SELECT DailyValue FROM metricdetail WHERE metriccode = ''' + metriccode + ''' AND plaindate = t1.plaindate) AS ''' + Caption + ''',' + CHAR(13) + CHAR(10) 
			FROM metricitem WHERE sn = @sn
		SELECT @sn = MIN(t2.sn) FROM metricdetail t1, metricitem t2 WHERE t1.metriccode = t2.metriccode AND t2.sn > @sn
    END
	SET @SQL = LEFT(@SQL, LEN(@SQL)-3) + CHAR(13) + CHAR(10) + 'FROM metricdetail t1 '
	IF (SELECT COUNT(*) FROM metricdetail) > 0
		EXEC (@SQL)
GO
GRANT EXECUTE ON  [dbo].[MetricCreateViewAll] TO [public]
GO
