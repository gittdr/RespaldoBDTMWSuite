SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetPageSNs] (@MenuSectionSN int)
AS
	SET NOCOUNT OFF

	SELECT sn 
	FROM resnowpage 
	WHERE MenuSectionSN = @MenuSectionSN
		AND Active = 1
GO
GRANT EXECUTE ON  [dbo].[MetricGetPageSNs] TO [public]
GO
