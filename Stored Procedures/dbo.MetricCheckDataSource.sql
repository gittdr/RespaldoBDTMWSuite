SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricCheckDataSource] (@Caption varchar(20) )
AS
	SET NOCOUNT ON

	SELECT CaptionExists = CASE WHEN EXISTS(SELECT * FROM rnExternalDataSource WHERE Caption = @Caption) THEN 1 ELSE 0 END
GO
GRANT EXECUTE ON  [dbo].[MetricCheckDataSource] TO [public]
GO
