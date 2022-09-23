SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricSetGrades] 
(
	@MetricCode varchar(200), 
	@A decimal(20, 5) = NULL, 
	@B decimal(20, 5) = NULL, 
	@C decimal(20, 5) = NULL, 
	@D decimal(20, 5) = NULL
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	-- MetricSetGrades 'MilesPerDrv', @A=99, @B=94, @C=89.2, @D=55.7
	DECLARE @GradingScaleCode varchar(100)

	SELECT @GradingScaleCode = GradingScaleCode FROM MetricItem WHERE MetricCode = @MetricCode
	IF ISNULL(@GradingScaleCode, '') = ''
	BEGIN
		PRINT 'No grading scale code is set.  Go to metric configuration to set this.'
		RETURN
	END

	UPDATE metricgradingscaledetail
	SET MinValue = 
		CASE WHEN Grade = 'A' THEN ISNULL(@A, MinValue)
			WHEN Grade = 'B' THEN ISNULL(@B, MinValue)
			WHEN Grade = 'C' THEN ISNULL(@C, MinValue)
			WHEN Grade = 'D' THEN ISNULL(@D, MinValue)
			WHEN Grade = 'F' THEN NULL
		END
	WHERE GradingScaleCode = @GradingScaleCode
GO
GRANT EXECUTE ON  [dbo].[MetricSetGrades] TO [public]
GO
