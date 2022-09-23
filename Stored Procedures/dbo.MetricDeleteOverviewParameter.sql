SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteOverviewParameter] (@sn int)
AS
	SET NOCOUNT ON

	DELETE RN_OverviewParameter WHERE sn = @sn
GO
GRANT EXECUTE ON  [dbo].[MetricDeleteOverviewParameter] TO [public]
GO
