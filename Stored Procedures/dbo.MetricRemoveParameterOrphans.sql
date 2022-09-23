SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricRemoveParameterOrphans] (@MetricCode varchar(200) = NULL)
AS
	SET NOCOUNT ON

	-- Created per PTS46276.
	SELECT @MetricCode = ISNULL(@MetricCode, '')

	BEGIN TRAN
		INSERT INTO MetricParameterOrphans (sn, Heading, SubHeading, ParmName, ParmValue, ParmDescription, Format )
		SELECT sn, Heading, SubHeading, ParmName, ParmValue, ParmDescription, Format 
		FROM metricparameter t0 
		WHERE heading = 'MetricStoredProc'
			AND t0.Subheading = CASE WHEN @MetricCode = '' THEN t0.Subheading ELSE @metriccode END
			AND NOT EXISTS(SELECT t3.id FROM metricitem t1 
											INNER JOIN sysobjects t2 ON t1.ProcedureName = t2.name 
											INNER JOIN syscolumns t3 ON t2.id = t3.id WHERE t1.metriccode = t0.Subheading AND t3.name = t0.ParmName)

		DELETE metricparameter
		WHERE metricparameter.heading = 'MetricStoredProc'
			AND metricparameter.Subheading = CASE WHEN @MetricCode = '' THEN metricparameter.Subheading ELSE @metriccode END
			AND NOT EXISTS(SELECT t3.id FROM metricitem t1 
											INNER JOIN sysobjects t2 ON t1.ProcedureName = t2.name 
											INNER JOIN syscolumns t3 ON t2.id = t3.id WHERE t1.metriccode = metricparameter.Subheading AND t3.name = metricparameter.ParmName)
	COMMIT
GO
GRANT EXECUTE ON  [dbo].[MetricRemoveParameterOrphans] TO [public]
GO
