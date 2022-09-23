SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspFiltradoCartaPorte223]
@nombresucursal varchar(100)
as
begin

if @nombresucursal='' --and @uuid = '' and @cliente =''
begin 

   SELECT DISTINCT top 50 CAST(vista.Folio as int) Folio,vista.Fecha as Fecha,oh.ord_billto as ord_billto,vista.Serie as Serie,vista.UUID as UUID,vista.Pdf_xml_descarga as Pdf_xml_descarga,vista.Pdf_descargaFactura as Pdf_descargaFactura, replace(vista.xlm_descargaFactura,'}','') as xlm_descargaFactura
    FROM VISTA_Carta_Porte as vista 
		INNER JOIN legheader as lg ON vista.Folio = lg.lgh_number 
		INNER JOIN orderheader as oh ON lg.ord_hdrnumber = oh.ord_hdrnumber
		INNER JOIN canceladascartap as c ON c.Folio != vista.Folio
	ORDER BY Fecha DESC
	--WHERE 
		 --vista.Folio = @folio
   --Select TOP 100 h.lgh_number as Segmento ,v.Folio as Folio,v.Serie as Serie,v.Fecha as Fecha, v.UUID as UUID, h.lgh_startdate as Fechac, v.Fecha as Fechat, o.ord_billto as ord_billto, h.ord_hdrnumber as orden from legheader  as h LEFT JOIN VISTA_Carta_Porte AS v ON v.Folio = h.lgh_number LEFT JOIN orderheader as o ON o.ord_hdrnumber = h.ord_hdrnumber WHERE o.ord_startdate > '2022-03-01' AND h.lgh_outstatus != 'CAN' AND h.ord_hdrnumber > 0 ORDER BY v.Folio DESC
    --select TOP 50 Folio,Fecha,Serie,UUID,Pdf_xml_descarga,Pdf_descargaFactura, replace(xlm_descargaFactura,'}','') as xlm_descargaFactura
   -- from ResultadoCartaPorte
   end
else if @nombresucursal != '' --and @uuid = '' and @cliente =''


 begin

 SELECT DISTINCT CAST(vista.Folio as int) Folio,vista.Fecha as Fecha,oh.ord_billto as ord_billto,vista.Serie as Serie,vista.UUID as UUID,vista.Pdf_xml_descarga as Pdf_xml_descarga,vista.Pdf_descargaFactura as Pdf_descargaFactura, replace(vista.xlm_descargaFactura,'}','') as xlm_descargaFactura
    FROM VISTA_Carta_Porte as vista 
		INNER JOIN legheader as lg ON vista.Folio = lg.lgh_number 
		INNER JOIN orderheader as oh ON lg.ord_hdrnumber = oh.ord_hdrnumber
		INNER JOIN canceladascartap as c ON c.Folio != vista.Folio
	WHERE NOT EXISTS (SELECT * from canceladascartap where Folio like '%'+@nombresucursal+'%') AND vista.Folio like '%'+@nombresucursal+'%'
		 --vista.Folio like '%1263073%' or
		 --oh.ord_billto like '%'+@nombresucursal+'%' or
		 --vista.UUID like '%'+@nombresucursal+'%'
    --Select h.lgh_number as Segmento ,v.Folio as Folio,v.Serie as Serie,v.Fecha as Fecha, v.UUID as UUID, h.lgh_startdate as Fechac, v.Fecha as Fechat, o.ord_billto as ord_billto, h.ord_hdrnumber as orden from legheader  as h LEFT JOIN VISTA_Carta_Porte AS v ON v.Folio = h.lgh_number LEFT JOIN orderheader as o ON o.ord_hdrnumber = h.ord_hdrnumber WHERE o.ord_startdate > '2022-03-01' AND h.lgh_outstatus != 'CAN' AND h.ord_hdrnumber > 0 AND h.lgh_number = @folio
	--select Folio,fecha,Serie,UUID,Pdf_xml_descarga,Pdf_descargaFactura, replace(xlm_descargaFactura,'}','') as xlm_descargaFactura
	--from ResultadoCartaPorte
	--where Folio like '%'+@segmento+'%' OR UUID like '%'+@segmento+'%'
  end
end
GO
