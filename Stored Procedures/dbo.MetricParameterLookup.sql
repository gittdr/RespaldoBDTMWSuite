SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricParameterLookup] (@MetricCode varchar(255), @ParameterName varchar(255), @AddIfNotExistYN varchar(1) )
AS
	SET NOCOUNT ON

	DECLARE @Exists int, @ParameterValue varchar(255)

	SELECT @Exists = 1, @ParameterValue = ParmValue
		FROM MetricParameter WHERE Heading = 'metricstoredproc' AND SubHeading = @MetricCode AND ParmName = @ParameterName

	IF @AddIfNotExistYN = 'Y'
	BEGIN
		IF (ISNULL(@Exists, 0) = 0)
		BEGIN
			INSERT INTO MetricParameter (Heading, Subheading, ParmName, ParmValue, ParmDescription, ParmSort)
			SELECT 'metricstoredproc', @MetricCode, @ParameterName, @ParameterValue, @MetricCode + ', ' + @ParameterName, 0
		END
	END

	SELECT [Exists] = ISNULL(@Exists, 0), ParameterValue = ISNULL(@ParameterValue, '')
GO
GRANT EXECUTE ON  [dbo].[MetricParameterLookup] TO [public]
GO
