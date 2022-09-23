SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetCategoryAttibutes] (@code varchar(30))
AS
	SET NOCOUNT ON

	SELECT DateOrderLeftToRight, ShowFullTimeFrameDay, ShowFullTimeFrameWeek, ShowFullTimeFrameMonth
			, ShowFullTimeFrameQuarter, ShowFullTimeFrameYear , ShowFullTimeFrameFiscalYear
			,Caption
	FROM MetricCategory 
	WHERE CategoryCode = @code
GO
GRANT EXECUTE ON  [dbo].[MetricGetCategoryAttibutes] TO [public]
GO
