SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetParameterOptions_TMWSuite] (@Step int = 1, @Filter1 varchar(200) = '')
AS
	IF @Step = 1
	BEGIN
		SELECT DISTINCT LabelDefinition from labelfile ORDER BY LabelDefinition
	END
	ELSE IF @Step = 2
	BEGIN
		SELECT DISTINCT abbr, name, UserLabelName = ISNULL(UserLabelName, '') FROM labelfile WHERE LabelDefinition = @Filter1 ORDER BY abbr
	END
GO
GRANT EXECUTE ON  [dbo].[MetricGetParameterOptions_TMWSuite] TO [public]
GO
