SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteGradingScale] (@GradingScaleCode varchar(30))
AS
	SET NOCOUNT ON

	UPDATE MetricItem SET GradingScaleCode = NULL WHERE ISNULL(GradingScaleCode, '') = @GradingScaleCode
	DELETE MetricGradingScaleDetail WHERE GradingScaleCode = @GradingScaleCode
	DELETE MetricGradingScaleHeader WHERE GradingScaleCode = @GradingScaleCode
GO
GRANT EXECUTE ON  [dbo].[MetricDeleteGradingScale] TO [public]
GO
