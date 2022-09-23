SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCountCategoryItems] (@CategoryCode varchar(30) )
AS
	SET NOCOUNT ON

	SELECT count(*) AS CountRecords
	FROM MetricCategoryItems
	WHERE Active = 1
		AND CategoryCode = @CategoryCode
GO
GRANT EXECUTE ON  [dbo].[MetricCountCategoryItems] TO [public]
GO
