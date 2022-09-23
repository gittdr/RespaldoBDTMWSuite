SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInsertIntoCategory] 
(
	@MetricCode VARCHAR(200), 
	@CategoryCode VARCHAR(30), 
	@nSort INT
)
AS
	SET NOCOUNT ON

	IF (@CategoryCode <> '@@NOCATEGORY')
	BEGIN
		IF NOT EXISTS(SELECT * FROM MetricCategory WHERE CategoryCode = @CategoryCode)
			INSERT INTO MetricCategory (CategoryCode, Active, Sort, ShowTime, Caption, CaptionFull, PagePassword, LoopGraphs)
			VALUES (@CategoryCode, 1, 10, 20, @CategoryCode, @CategoryCode, '', 1)
	
		IF NOT EXISTS(SELECT * FROM MetricCategoryItems WHERE MetricCode = @MetricCode AND CategoryCode = @CategoryCode)
			INSERT INTO MetricCategoryItems (CategoryCode, MetricCode, Active, Sort)
			VALUES (@CategoryCode, @MetricCode, 1, @nSort)

		IF EXISTS(SELECT * FROM MetricItem WHERE MetricCode = @MetricCode AND ShowDetailByDefaultYN = 'Y')
			UPDATE MetricCategory SET ShowTime = 0 WHERE CategoryCode = @CategoryCode
	END
GO
GRANT EXECUTE ON  [dbo].[MetricInsertIntoCategory] TO [public]
GO
