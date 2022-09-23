SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateGradingScaleDetailRow] (@GradingScaleCode varchar(30), @GradeTemp varchar(4), @ValueTemp varchar(20), @sn int)

AS
	SET NOCOUNT ON

	UPDATE MetricGradingScaleDetail SET Grade = @GradeTemp, MinValue = @ValueTemp 
	WHERE GradingScaleCode = @GradingScaleCode AND sn = @sn
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateGradingScaleDetailRow] TO [public]
GO
