SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteCategoryAndItemsBySN] (@sn int)
AS
	SET NOCOUNT ON

	DECLARE @CategoryCode varchar(30)
	
	SELECT @CategoryCode = CategoryCode FROM MetricCategory where SN = @sn

	DELETE MetricCategory WHERE SN = @sn
	
	DELETE MetricCategoryItems WHERE CategoryCode = @CategoryCode
GO
GRANT EXECUTE ON  [dbo].[MetricDeleteCategoryAndItemsBySN] TO [public]
GO
