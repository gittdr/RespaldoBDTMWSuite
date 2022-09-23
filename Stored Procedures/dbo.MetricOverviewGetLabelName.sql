SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricOverviewGetLabelName] (@LabelDefinition varchar(20))
AS
	SET NOCOUNT ON

	SELECT Top 1 userlabelname FROM labelfile (nolock) WHERE labeldefinition = @LabelDefinition
GO
GRANT EXECUTE ON  [dbo].[MetricOverviewGetLabelName] TO [public]
GO
