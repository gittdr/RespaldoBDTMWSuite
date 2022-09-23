SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckForMetricCodeParm] (@metriccode varchar(200))
AS
	SET NOCOUNT ON

	SELECT COUNT(syscolumns.name) AS CountOf 
	FROM syscolumns INNER JOIN sysobjects ON syscolumns.id = sysobjects.id 
		INNER JOIN MetricItem ON sysobjects.name = MetricItem.ProcedureName 
	WHERE sysobjects.type = 'P' AND syscolumns.name = '@MetricCode' AND MetricItem.MetricCode = @MetricCode
GO
GRANT EXECUTE ON  [dbo].[MetricCheckForMetricCodeParm] TO [public]
GO
