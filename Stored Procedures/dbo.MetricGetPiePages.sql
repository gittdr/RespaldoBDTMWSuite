SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricGetPiePages]
AS
	SET NOCOUNT ON

	SELECT Page, 'Pie Page ' + CONVERT(varchar(3),Page) AS Caption 
		INTO #t1
	FROM RN_OverviewParameter 
	GROUP BY Page 

	SELECT *, 
		PageCaption = (SELECT TOP 1 Caption FROM resnowpage 
						WHERE PageURL LIKE 'Overview.asp?Page=' + Convert(Varchar(3), t1.Page) 
							OR PageURL LIKE 'Overview.asp?Page=' + Convert(Varchar(3), t1.Page) + '&%'
					),
		PageCount = (SELECT COUNT(*) FROM resnowpage 
						WHERE PageURL LIKE 'Overview.asp?Page=' + Convert(Varchar(3), t1.Page) 
							OR PageURL LIKE 'Overview.asp?Page=' + Convert(Varchar(3), t1.Page) + '&%'
				)
	FROM #t1 t1
	ORDER BY Page
GO
GRANT EXECUTE ON  [dbo].[MetricGetPiePages] TO [public]
GO
