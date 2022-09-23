SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInsertGradingScaleDetail] (@GradingScaleCode varchar(30), @GradeNew varchar(4), @ValueNew varchar(255) )
AS
	SET NOCOUNT ON

	INSERT INTO MetricGradingScaleDetail (MinValue, Grade, GradingScaleCode)
	SELECT CASE WHEN @ValueNew = '@@NULL@@' THEN NULL ELSE @ValueNew END, @GradeNew, @GradingScaleCode
GO
GRANT EXECUTE ON  [dbo].[MetricInsertGradingScaleDetail] TO [public]
GO
