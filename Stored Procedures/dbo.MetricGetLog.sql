SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricGetLog] (@MetricCode varchar(200) )
AS
	SELECT TOP 1000 [Date/Time] = dateandtime, [Source], [Description] = longdesc 
	FROM resnowlog WITH (NOLOCK)
	WHERE metriccode = @MetricCode
	ORDER BY dateandtime DESC
GO
GRANT EXECUTE ON  [dbo].[MetricGetLog] TO [public]
GO
