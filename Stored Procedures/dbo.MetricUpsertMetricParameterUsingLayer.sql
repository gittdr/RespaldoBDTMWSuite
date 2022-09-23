SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpsertMetricParameterUsingLayer] (@MetricCode varchar(200), @Column_Name varchar(255), @ThisParm varchar(255), @Ordinal_Position int)
AS

	SET NOCOUNT ON
	IF EXISTS(SELECT * FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading Like @MetricCode + '%' AND ParmName = @Column_Name)
    BEGIN
		UPDATE metricparameter SET ParmValue = CASE WHEN @ThisParm = '' THEN NULL ELSE @ThisParm END
		WHERE Heading = 'MetricStoredProc' AND SubHeading LIKE @MetricCode + '@%'
			AND ParmName = @Column_Name
			AND NOT EXISTS(SELECT * FROM MetricLayer WHERE MetricCode LIKE @MetricCode + '@%'
							AND MetricParmName = ParmName and Subheading like ('%'+MetricLayer.LayerName+'=%'))

		UPDATE metricparameter
		SET ParmValue = CASE WHEN @ThisParm = '' THEN NULL ELSE @ThisParm END
		WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @Column_Name
	END
	ELSE
		INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmSort, ParmValue)
		SELECT 'MetricStoredProc', @MetricCode, @Column_Name, @Ordinal_Position, CASE WHEN @ThisParm = '' THEN NULL ELSE @ThisParm END
GO
GRANT EXECUTE ON  [dbo].[MetricUpsertMetricParameterUsingLayer] TO [public]
GO
