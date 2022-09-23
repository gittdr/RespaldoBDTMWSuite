SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetLayerValues]
(
	@CategoryCode varchar(30), 
	@LayerLevel int, 
	@LayerFilter varchar(200)
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	-- This is used to return a list for the drop downs in the ASP page.
	SELECT  DISTINCT t2.LayerName, 
		SUBSTRING(t1.MetricCode, 
			LEN(t2.LayerName + '=') 
				+ CHARINDEX(t2.LayerName + '=', t1.MetricCode, CHARINDEX(t1.MetricCode, '@')), 100)
	FROM metriccategoryitems t3 WITH (NOLOCK), metricitem t1 WITH (NOLOCK), metriclayer t2 WITH (NOLOCK)
	WHERE  t3.MetricCode = LEFT(t1.MetricCode, CHARINDEX('@', t1.MetricCode) - CASE WHEN CHARINDEX('@', t1.MetricCode) > 0 THEN 1 ELSE 0 END)
		AND t1.MetricCode like '%' + @LayerFilter + '%'
		AND t3.CategoryCode = @CategoryCode
		AND t1.LayerSN = t2.LayerSn 
		AND t2.LayerLevel = @LayerLevel
	ORDER BY t2.LayerName, SUBSTRING(t1.MetricCode, LEN(t2.LayerName + '=') + CHARINDEX(t2.LayerName + '=', t1.MetricCode, CHARINDEX(t1.MetricCode, '@')), 100)
GO
GRANT EXECUTE ON  [dbo].[MetricGetLayerValues] TO [public]
GO
