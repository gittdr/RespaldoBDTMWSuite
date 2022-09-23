SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[CarrierHubTicketManagementView] as
SELECT        c.ImportContentId AS ImportId, d .Description AS Description, c.CreatedDate AS [Created Date], isnull(err.Errors, 0) Errors, stuff(Orders.OrderIds, 1, 1, '') AS Orders
FROM            ImportContent AS c 
JOIN
	ImportDefinition AS d ON c.ImportDefinitionId = d .ImportDefinitionId
LEFT JOIN
	(SELECT        i.ImportContentId, count(DISTINCT re.ImportRowContentLinkErrorId) AS [Errors]
	  FROM            ImportContent AS i JOIN
	                            ImportRowContent AS r ON r.ImportContentId = i.ImportContentId LEFT JOIN
	                            ImportColumnContent AS c ON c.ImportRowContentId = r.ImportRowContentId LEFT OUTER JOIN
	                            ImportRowContentLinkError AS re ON re.ImportRowContentId = r.ImportRowContentId
	  WHERE        re.ImportRowContentLinkErrorId IS NOT NULL
	  GROUP BY i.ImportContentId) AS err ON err.ImportContentId = c.ImportContentId
JOIN
	(SELECT        c.ImportContentId,
	                                (SELECT DISTINCT ',' + CONVERT(varchar, o.ord_hdrnumber)
	                                  FROM            ImportRowContentLinkOrder AS o JOIN
	                                                            ImportRowContent AS r ON r.ImportRowContentId = o.ImportRowContentId
	                                  WHERE        r.ImportContentId = c.ImportContentId FOR XML PATH('')) AS OrderIds
	  FROM            ImportContent AS c) AS Orders ON c.ImportContentId = Orders.ImportContentId
GO
GRANT SELECT ON  [dbo].[CarrierHubTicketManagementView] TO [public]
GO
