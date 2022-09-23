SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricGetPiePageDetails]
AS
	SET NOCOUNT ON

	SELECT RNOP.*, 'Pie Page ' + Convert(Varchar(3),RNOP.Page) AS Caption,
		PageCaption = ISNULL((SELECT TOP 1 Caption FROM resnowpage 
						WHERE PageURL LIKE 'Overview.asp?Page=' + Convert(Varchar(3), RNOP.Page) 
							OR PageURL LIKE 'Overview.asp?Page=' + Convert(Varchar(3), RNOP.Page) + '&%'
					), 'No page assigned'),
		MultiIndicator = CASE WHEN (SELECT COUNT(*) FROM resnowpage 
						WHERE PageURL LIKE 'Overview.asp?Page=' + Convert(Varchar(3), RNOP.Page) 
							OR PageURL LIKE 'Overview.asp?Page=' + Convert(Varchar(3), RNOP.Page) + '&%'
				) > 1 THEN '+' ELSE '' END

	FROM RN_OverviewParameter RNOP 
	ORDER BY Page, Side, Sort 
GO
GRANT EXECUTE ON  [dbo].[MetricGetPiePageDetails] TO [public]
GO
