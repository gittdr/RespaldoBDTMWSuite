SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteCategoryItems] (@MetricCode varchar(200) )
AS
	SET NOCOUNT ON

	DELETE MetricCategoryItems WHERE MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricDeleteCategoryItems] TO [public]
GO
