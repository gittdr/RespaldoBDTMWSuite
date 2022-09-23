SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteParameters] (@MetricCode varchar(200) )
AS
	SET NOCOUNT ON

	DELETE MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode

GO
GRANT EXECUTE ON  [dbo].[MetricDeleteParameters] TO [public]
GO
