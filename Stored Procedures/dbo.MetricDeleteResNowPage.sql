SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricDeleteResNowPage] (
	@sn int
)
AS
	SET NOCOUNT ON

	IF @sn IS NULL 
	BEGIN
		RAISERROR ('MetricDeleteResNowPage was passed a NULL value.', 16, 1)
		RETURN
	END
	
	DELETE ResNowPage WHERE sn = @sn

GO
GRANT EXECUTE ON  [dbo].[MetricDeleteResNowPage] TO [public]
GO
