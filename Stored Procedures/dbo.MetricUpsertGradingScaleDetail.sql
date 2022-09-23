SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpsertGradingScaleDetail] (@GradingScaleCode varchar(30), @GradeTemp varchar(4))
AS
	SET NOCOUNT ON

	IF NOT EXISTS(SELECT * FROM MetricGradingScaleDetail WHERE GradingScaleCode = @GradingScaleCode AND MinValue IS NULL)
		INSERT INTO MetricGradingScaleDetail (GradingScaleCode, MinValue, Grade)
		VALUES (@GradingScaleCode, NULL, @GradeTemp)
	ELSE 
		UPDATE MetricGradingScaleDetail SET Grade = @GradeTemp 
		WHERE GradingScaleCode = @GradingScaleCode AND MinValue IS NULL
GO
GRANT EXECUTE ON  [dbo].[MetricUpsertGradingScaleDetail] TO [public]
GO
