SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspListarSegmentos]
as
begin
Select TOP 100 h.lgh_number as Segmento ,v.Folio as Folio, h.lgh_startdate as Fechac, v.Fecha as Fechat, o.ord_billto as cliente, h.ord_hdrnumber as orden from legheader  as h LEFT JOIN VISTA_Carta_Porte AS v ON v.Folio = h.lgh_number LEFT JOIN orderheader as o ON o.ord_hdrnumber = h.ord_hdrnumber WHERE o.ord_startdate > '2022-03-01' AND h.lgh_outstatus != 'CAN' AND h.ord_hdrnumber > 0 ORDER BY v.Folio DESC
--Select h.lgh_number as segmento,ISNULL(v.Folio,'Sin timbrar')as timbrada from legheader  as h LEFT JOIN VISTA_Carta_Porte AS v ON v.Folio = h.lgh_number WHERE h.lgh_startdate > '2022-01-01' AND h.lgh_outstatus != 'CAN'
--Select h.lgh_number as Segmento,v.Folio as Folio from legheader  as h LEFT JOIN VISTA_Carta_Porte AS v ON v.Folio = h.lgh_number WHERE h.lgh_startdate > '2022-01-01' AND h.lgh_outstatus != 'CAN'

end

--select * from legheader

--select top 5 * from orderheader

--select top 10 * from VISTA_Carta_Porte
GO
