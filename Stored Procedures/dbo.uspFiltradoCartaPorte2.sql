SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspFiltradoCartaPorte2]
@segmento varchar(100)
as
begin

if @segmento=''
    SELECT top 50 vista.Folio as Folio,vista.Fecha as Fecha,oh.ord_billto as ord_billto,vista.Serie as Serie,vista.UUID as UUID,vista.Pdf_xml_descarga as Pdf_xml_descarga,vista.Pdf_descargaFactura as Pdf_descargaFactura, replace(vista.xlm_descargaFactura,'}','') as xlm_descargaFactura
    FROM VISTA_Carta_Porte as vista 
		INNER JOIN legheader as lg ON vista.Folio = lg.lgh_number 
		INNER JOIN orderheader as oh ON lg.ord_hdrnumber = oh.ord_hdrnumber
		ORDER BY Fecha DESC
else 
    SELECT vista.Folio as Folio,vista.Fecha as Fecha,oh.ord_billto as ord_billto,vista.Serie as Serie,vista.UUID as UUID,vista.Pdf_xml_descarga as Pdf_xml_descarga,vista.Pdf_descargaFactura as Pdf_descargaFactura, replace(vista.xlm_descargaFactura,'}','') as xlm_descargaFactura
    FROM VISTA_Carta_Porte as vista 
		INNER JOIN legheader as lg ON vista.Folio = lg.lgh_number and vista.Serie = 'TDRXP'
		INNER JOIN orderheader as oh ON lg.ord_hdrnumber = oh.ord_hdrnumber
	WHERE 
		 oh.ord_billto like '%'+@segmento+'%' or 
		 vista.Folio like '%'+@segmento+'%' or
		 vista.UUID like '%'+@segmento+'%'
		 UNION
		 SELECT vista.Folio as Folio,vista.Fecha as Fecha,oh.ord_billto as ord_billto,vista.Serie as Serie,vista.UUID as UUID,vista.Pdf_xml_descarga as Pdf_xml_descarga,vista.Pdf_descargaFactura as Pdf_descargaFactura, replace(vista.xlm_descargaFactura,'}','') as xlm_descargaFactura
    FROM VISTA_Carta_Porte as vista 
        INNER JOIN invoiceheader as lg ON vista.Folio = lg.ivh_hdrnumber and vista.Serie = 'TDRZP' 
        INNER JOIN orderheader as oh ON lg.ord_hdrnumber = oh.ord_hdrnumber
   WHERE 
		 oh.ord_billto like '%'+@segmento+'%' or 
		 vista.Folio like '%'+@segmento+'%' or
		 vista.UUID like '%'+@segmento+'%'
	ORDER BY Fecha DESC
	--select Folio,Serie,UUID,Pdf_xml_descarga,Pdf_descargaFactura, replace(xlm_descargaFactura,'}','') as xlm_descargaFactura
	--from VISTA_Carta_Porte
	--where Folio like '%'+@segmento+'%' or UUID like '%'+@segmento+'%'
end
GO
