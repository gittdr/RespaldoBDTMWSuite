SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetSectionPages] (@MenuSectionSN varchar(10) = '')
AS
	SELECT t1.sn , t1.Sort, t1.ShowTime, t1.Caption, t1.PagePassword
	FROM ResNowPage t1 INNER JOIN Resnowmenusection t2 ON t1.MenuSectionSN = t2.sn 
	WHERE t2.sn = CASE WHEN @MenuSectionSN = '' THEN t2.sn ELSE CONVERT(int, @MenuSectionSN) END	
	ORDER BY t1.Sort
GO
GRANT EXECUTE ON  [dbo].[MetricGetSectionPages] TO [public]
GO
