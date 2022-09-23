SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetZip3Translation] (@ItemID varchar(6))
AS
	SET NOCOUNT ON

	SELECT State FROM ResNowZip3Translation (NOLOCK) WHERE PID = @ItemID
GO
GRANT EXECUTE ON  [dbo].[MetricGetZip3Translation] TO [public]
GO
