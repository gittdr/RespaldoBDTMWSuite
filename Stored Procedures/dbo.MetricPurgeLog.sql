SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricPurgeLog] 
AS
	SET NOCOUNT ON

	DECLARE @RowCountStart bigint
	DECLARE @Loops bigint
	DECLARE @iCur bigint
	DECLARE @dt_Too_Old datetime
	
	SET @dt_Too_Old = DATEADD(day, -21, GETDATE())
	
	SELECT @RowCountStart = COUNT(sn) FROM resnowlog WITH (NOLOCK) WHERE dateandtime < @dt_Too_Old
	
	SET @Loops = (@RowCountStart / 25000.0) + 1
	SET @iCur = 0
	
	SET ROWCOUNT 25000
	WHILE @iCur < @Loops
	BEGIN
		DELETE ResNowLog WHERE dateandtime < @dt_Too_Old
		SET @iCur = @iCur + 1
	END
	
	SET ROWCOUNT 0
GO
GRANT EXECUTE ON  [dbo].[MetricPurgeLog] TO [public]
GO
