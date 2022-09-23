SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_obtener_segmento_JC](
@orden varchar(100)
)
as

begin
        Select h.lgh_number as Segmento ,v.Folio as Folio, v.Fecha as Fechatimbrado, o.ord_billto as cliente, h.ord_hdrnumber as orden, v.cancelfactura cancelada , v.pdf_descargafactura PDF
        from legheader as h LEFT JOIN VISTA_Carta_Porte AS v ON v.Folio = h.lgh_number LEFT JOIN orderheader as o ON o.ord_hdrnumber = h.ord_hdrnumber WHERE  v.Folio != 'NULL' AND o.ord_startdate > '2022-03-01' AND h.lgh_outstatus != 'CAN' AND h.ord_hdrnumber > 0 AND h.lgh_number in (	select lgh_number from legheader where ord_hdrnumber = @orden)
end
GO
