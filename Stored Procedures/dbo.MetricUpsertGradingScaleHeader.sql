SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpsertGradingScaleHeader] (@GradingScaleCode varchar(30), @PlusDeltaIsGood int, @FormatText varchar(12) )
AS
	SET NOCOUNT ON

	IF NOT EXISTS(SELECT * FROM MetricGradingScaleHeader WHERE GradingScaleCode = @GradingScaleCode)
		INSERT INTO MetricGradingScaleHeader (GradingScaleCode, SystemScale, PlusDeltaIsGood, FormatText) VALUES (@GradingScaleCode, 0, @PlusDeltaIsGood, @FormatText)
	ELSE
		UPDATE MetricGradingScaleHeader SET PlusDeltaIsGood = @PlusDeltaIsGood, FormatText = @FormatText WHERE GradingScaleCode = @GradingScaleCode
GO
GRANT EXECUTE ON  [dbo].[MetricUpsertGradingScaleHeader] TO [public]
GO
