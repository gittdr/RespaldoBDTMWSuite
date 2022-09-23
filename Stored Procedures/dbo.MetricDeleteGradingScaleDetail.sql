SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteGradingScaleDetail] (@ValueTemp int, @GradingScaleCode varchar(30))
AS
	SET NOCOUNT ON
	DECLARE @DetailCount int

	DELETE MetricGradingScaleDetail WHERE sn = @ValueTemp

	IF ((SELECT COUNT(*) FROM MetricGradingScaleDetail WHERE GradingScaleCode = @GradingScaleCode) = 1)
		DELETE MetricGradingScaleDetail WHERE GradingScaleCode = @GradingScaleCode

	SELECT @DetailCount = COUNT(*) FROM MetricGradingScaleDetail WHERE GradingScaleCode = @GradingScaleCode

    IF @DetailCount = 0
		DELETE MetricGradingScaleHeader WHERE GradingScaleCode = @GradingScaleCode


	SELECT @DetailCount
GO
GRANT EXECUTE ON  [dbo].[MetricDeleteGradingScaleDetail] TO [public]
GO
