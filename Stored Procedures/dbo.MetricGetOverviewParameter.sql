SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetOverviewParameter] (@sn int)
AS
	SET NOCOUNT OFF

	SELECT * FROM RN_OverviewParameter WHERE sn = @sn
GO
GRANT EXECUTE ON  [dbo].[MetricGetOverviewParameter] TO [public]
GO
