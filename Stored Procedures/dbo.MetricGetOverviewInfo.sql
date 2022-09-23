SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetOverviewInfo] (@mode varchar(255) )
AS
	SET NOCOUNT ON


	SELECT Heading, labeldefinition, CannedMode FROM RN_OverviewParameter WHERE Mode = @mode
GO
GRANT EXECUTE ON  [dbo].[MetricGetOverviewInfo] TO [public]
GO
