SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_remwebapp]
AS
SELECT     ord_billto AS cliente, ord_number AS orden, ord_driver1 AS operador, ord_tractor AS tractor, ord_trailer AS remolque, ord_description AS descripcion, 
                      ord_startdate AS inicio, ord_completiondate AS completada,
                          (SELECT     cmp_name
                            FROM          dbo.company
                            WHERE      (dbo.orderheader.ord_originpoint = cmp_id)) AS origen,
                          (SELECT     cmp_name
                            FROM          dbo.company AS company_1
                            WHERE      (dbo.orderheader.ord_destpoint = cmp_id)) AS destino, ord_invoicestatus AS statusfactura, ord_status AS statusorden
FROM         dbo.orderheader
WHERE     (ord_status NOT IN ('MST', 'AVL', 'CAN'))

GO
