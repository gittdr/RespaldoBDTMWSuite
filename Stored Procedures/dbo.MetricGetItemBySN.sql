SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetItemBySN] (@sn int)
AS
	SET NOCOUNT ON

	SELECT sn, MetricCode
	FROM MetricItem
	WHERE sn = @sn
GO
GRANT EXECUTE ON  [dbo].[MetricGetItemBySN] TO [public]
GO
