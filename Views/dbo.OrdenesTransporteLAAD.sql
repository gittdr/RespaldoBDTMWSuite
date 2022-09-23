SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[OrdenesTransporteLAAD] AS 
SELECT row_number() OVER(ORDER BY o.ord_revtype2 ASC) AS 'No.', o.ord_revtype2 AS 'Id_regional',lf.name AS 'Regional', 
	substring(o.ord_refnum,1,7) AS 'Proyecto', o.ord_hdrnumber AS 'Orden', o.ord_refnum AS 'Transporte', o.ord_status AS 'Estatus', 
	o.ord_shipper AS Origen, o.ord_consignee AS Destino, o.cmd_code AS Producto, o.trl_type1, o.ord_carrier, o.ord_startdate AS 
	'FechaInicio', o.ord_bookdate AS 'FechaCarga', o.ord_completiondate AS 'FechaFin', o.ord_bookedby, replace(replace(replace(replace(replace(o.ord_Status,'AVL',0),
	'PLN',1),'STD',2),'CMP',3),'CAN',4) AS Estgrap
	FROM orderheader AS o
	INNER JOIN labelfile AS lf
	ON o.ord_revtype2 = lf.abbr
	WHERE o.ord_billto = 'SAE'
	AND lf.labeldefinition = 'revtype2'
    --Trae el detallede todo el año 
	--AND ord_startdate > GETDATE() - 365
	--Trae detalle ultimo 7 días
	--AND datediff(dd,o.ord_startdate,getdate()) <= 7
GO
