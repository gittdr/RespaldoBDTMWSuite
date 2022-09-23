SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteItemBySN] (@DeleteSN int)
AS
	SET NOCOUNT ON

	DECLARE @MetricCode varchar(200)

	SELECT @MetricCode = MetricCode FROM MetricItem WHERE sn = @DeleteSN

	DELETE MetricCategoryItems WHERE MetricCode = @MetricCode
	DELETE FROM MetricParameter where heading = 'MetricStoredProc' and Subheading = @MetricCode
	DELETE MetricItem WHERE sn = @DeleteSN

GO
GRANT EXECUTE ON  [dbo].[MetricDeleteItemBySN] TO [public]
GO
