SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInsertCategory] (
	@Active int,
	@CategoryCode varchar(30),
	@Caption varchar(50),
	@Parent varchar(30),
	@ShowFullTimeFrameDay int,
	@ShowFullTimeFrameWeek int,
	@ShowFullTimeFrameMonth int,
	@ShowFullTimeFrameQuarter int,
	@ShowFullTimeFrameYear int,
	@ShowFullTimeFrameFiscalYear int,
	@AllowChartDisplay_YN varchar(1),
	@DateOrderLeftToRight varchar(15) ) 
AS
	SET NOCOUNT ON

	INSERT INTO MetricCategory (Active, CategoryCode, Caption, Parent, ShowFullTimeFrameDay, ShowFullTimeFrameWeek, ShowFullTimeFrameMonth, 
								ShowFullTimeFrameQuarter, ShowFullTimeFrameYear, ShowFullTimeFrameFiscalYear, DateOrderLeftToRight, AllowChartDisplay_YN) 
	SELECT @Active, @CategoryCode, @Caption, @Parent, @ShowFullTimeFrameDay, @ShowFullTimeFrameWeek, @ShowFullTimeFrameMonth, 
			@ShowFullTimeFrameQuarter, @ShowFullTimeFrameYear, @ShowFullTimeFrameFiscalYear, @DateOrderLeftToRight, @AllowChartDisplay_YN
GO
GRANT EXECUTE ON  [dbo].[MetricInsertCategory] TO [public]
GO
