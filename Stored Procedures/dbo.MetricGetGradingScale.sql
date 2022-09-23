SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetGradingScale] (@GradingScaleCode varchar(30), @PlusDeltaIsGood int = 1)
AS
	SET NOCOUNT ON

	IF @PlusDeltaIsGood = 1
		SELECT t1.PlusDeltaIsGood, t2.sn, t2.GradingScaleCode, t1.SystemScale, t2.Grade, t2.MinValue 
		FROM MetricGradingScaleHeader t1 INNER JOIN MetricGradingScaleDetail t2 ON t1.GradingScaleCode = t2.GradingScaleCode
		WHERE t1.GradingScaleCode = @GradingScaleCode ORDER BY  ISNUMERIC(t2.minvalue) DESC, t2.MinValue DESC
	ELSE
		SELECT t1.PlusDeltaIsGood, t2.sn, t2.GradingScaleCode, t1.SystemScale, t2.Grade, t2.MinValue 
		FROM MetricGradingScaleHeader t1 INNER JOIN MetricGradingScaleDetail t2 ON t1.GradingScaleCode = t2.GradingScaleCode
		WHERE t1.GradingScaleCode = @GradingScaleCode ORDER BY  ISNUMERIC(t2.minvalue) DESC, t2.MinValue 
GO
GRANT EXECUTE ON  [dbo].[MetricGetGradingScale] TO [public]
GO
