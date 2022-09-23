SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInsertIntoCategoryItems] 
(
	@MetricCode VARCHAR(200), 
	@CategorySN INT
)
AS
	SET NOCOUNT ON

	INSERT INTO MetricCategoryItems (CategoryCode, MetricCode, Active)
	SELECT CategoryCode, @MetricCode, 1 FROM MetricCategory WHERE sn = @CategorySN
GO
GRANT EXECUTE ON  [dbo].[MetricInsertIntoCategoryItems] TO [public]
GO
