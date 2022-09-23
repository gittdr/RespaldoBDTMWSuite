SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspListarCartaPorte2]
as
begin
SELECT top 50 vista.Folio as Folio,vista.Fecha as Fecha,oh.ord_billto as ord_billto,vista.Serie as Serie,vista.UUID as UUID,vista.Pdf_xml_descarga as Pdf_xml_descarga,vista.Pdf_descargaFactura as Pdf_descargaFactura, replace(vista.xlm_descargaFactura,'}','') as xlm_descargaFactura
    FROM VISTA_Carta_Porte as vista 
		INNER JOIN legheader as lg ON vista.Folio = lg.lgh_number 
		INNER JOIN orderheader as oh ON lg.ord_hdrnumber = oh.ord_hdrnumber
		ORDER BY Fecha DESC
end
GO
