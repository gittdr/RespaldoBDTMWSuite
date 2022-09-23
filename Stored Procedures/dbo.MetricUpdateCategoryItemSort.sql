SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateCategoryItemSort] (	@sn int, @Sort int)
AS
	SET NOCOUNT ON

	UPDATE MetricCategoryItems SET Sort = @Sort WHERE sn = @sn
GO
GRANT EXECUTE ON  [dbo].[MetricUpdateCategoryItemSort] TO [public]
GO
