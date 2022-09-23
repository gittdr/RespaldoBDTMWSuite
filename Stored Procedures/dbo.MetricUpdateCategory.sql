SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateCategory] 
(
	@sn int,
	@Active int,
	@Caption varchar(50),
	@Parent varchar(30),
	@ShowFullTimeFrameDay int,
	@ShowFullTimeFrameWeek int,
	@ShowFullTimeFrameMonth int,
	@ShowFullTimeFrameQuarter int,
	@sShowFullTimeFrameYear int,
	@ShowFullTimeFrameFiscalYear int,
	@AllowChartDisplay_YN varchar(1),
	@DateOrderLeftToRight varchar(15)
)
AS
	SET NOCOUNT ON

	UPDATE MetricCategory SET 
					Active = @Active,
					Caption = @Caption,
					Parent = @Parent,
					ShowFullTimeFrameDay = @ShowFullTimeFrameDay,
   					ShowFullTimeFrameWeek = @ShowFullTimeFrameWeek,
					ShowFullTimeFrameMonth = @ShowFullTimeFrameMonth,
					ShowFullTimeFrameQuarter = @ShowFullTimeFrameQuarter,
					ShowFullTimeFrameYear = @sShowFullTimeFrameYear,
					ShowFullTimeFrameFiscalYear = @ShowFullTimeFrameFiscalYear,
					AllowChartDisplay_YN = @AllowChartDisplay_YN,
					DateOrderLeftToRight = @DateOrderLeftToRight
	WHERE sn = @sn
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateCategory] TO [public]
GO
