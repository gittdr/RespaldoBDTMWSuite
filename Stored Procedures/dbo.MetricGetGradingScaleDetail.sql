SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetGradingScaleDetail] (@GradingScaleCode varchar(30))
AS
	SET NOCOUNT ON

	SELECT sn FROM MetricGradingScaleDetail WHERE GradingScaleCode = @GradingScaleCode AND MinValue IS NOT NULL ORDER BY sn
GO
GRANT EXECUTE ON  [dbo].[MetricGetGradingScaleDetail] TO [public]
GO
