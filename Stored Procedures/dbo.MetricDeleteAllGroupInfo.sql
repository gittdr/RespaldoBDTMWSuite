SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteAllGroupInfo] (@GroupSN int) 
AS
	SET NOCOUNT ON

	DELETE MetricPermission WHERE GroupSN = @GroupSN
	DELETE MetricGroupUsers WHERE GroupSN = @GroupSN
	DELETE MetricGroup		WHERE SN = @GroupSN
GO
GRANT EXECUTE ON  [dbo].[MetricDeleteAllGroupInfo] TO [public]
GO
