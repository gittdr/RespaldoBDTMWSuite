SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricPagesSort_Update] (@sn int, @Sort int, @ShowTime int)
AS
	SET NOCOUNT OFF

	UPDATE ResNowPage SET 
                Sort = @Sort,
                ShowTime = @ShowTime
	WHERE sn = @sn
GO
GRANT EXECUTE ON  [dbo].[MetricPagesSort_Update] TO [public]
GO
