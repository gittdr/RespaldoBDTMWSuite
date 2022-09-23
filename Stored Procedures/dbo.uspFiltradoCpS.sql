SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspFiltradoCpS]
@segmento varchar(100),
@cliente varchar(100)
as
begin

if @segmento='' and @cliente =''
begin 
   Select TOP 100 h.lgh_number as Segmento ,v.Folio as Folio, h.lgh_startdate as Fechac, v.Fecha as Fechat, o.ord_billto as cliente, h.ord_hdrnumber as orden from legheader  as h LEFT JOIN VISTA_Carta_Porte AS v ON v.Folio = h.lgh_number LEFT JOIN orderheader as o ON o.ord_hdrnumber = h.ord_hdrnumber WHERE o.ord_startdate > '2022-03-01' AND h.lgh_outstatus != 'CAN' AND h.ord_hdrnumber > 0 ORDER BY v.Folio DESC
    --select TOP 50 Folio,Fecha,Serie,UUID,Pdf_xml_descarga,Pdf_descargaFactura, replace(xlm_descargaFactura,'}','') as xlm_descargaFactura
   -- from ResultadoCartaPorte
   end
else if @segmento != '' and @cliente=''
 begin
    Select h.lgh_number as Segmento ,v.Folio as Folio, h.lgh_startdate as Fechac, v.Fecha as Fechat, o.ord_billto as cliente, h.ord_hdrnumber as orden from legheader  as h LEFT JOIN VISTA_Carta_Porte AS v ON v.Folio = h.lgh_number LEFT JOIN orderheader as o ON o.ord_hdrnumber = h.ord_hdrnumber WHERE o.ord_startdate > '2022-03-01' AND h.lgh_outstatus != 'CAN' AND h.ord_hdrnumber > 0 AND h.lgh_number = @segmento
	--select Folio,fecha,Serie,UUID,Pdf_xml_descarga,Pdf_descargaFactura, replace(xlm_descargaFactura,'}','') as xlm_descargaFactura
	--from ResultadoCartaPorte
	--where Folio like '%'+@segmento+'%' OR UUID like '%'+@segmento+'%'
  end
  else if @cliente != '' and @segmento=''
  begin
  Select h.lgh_number as Segmento ,v.Folio as Folio, h.lgh_startdate as Fechac, v.Fecha as Fechat, o.ord_billto as cliente, h.ord_hdrnumber as orden from legheader  as h LEFT JOIN VISTA_Carta_Porte AS v ON v.Folio = h.lgh_number LEFT JOIN orderheader as o ON o.ord_hdrnumber = h.ord_hdrnumber WHERE o.ord_startdate > '2022-03-01' AND h.lgh_outstatus != 'CAN' AND h.ord_hdrnumber > 0 AND o.ord_billto like '%'+@cliente+'%'
--else if(select count(Folio) from ResultadoCartaPorte where Folio like '%'+@segmento+'%')<1
  --begin
    --select Folio,Serie,UUID,Pdf_xml_descarga,Pdf_descargaFactura, replace(xlm_descargaFactura,'}','') as xlm_descargaFactura
    --from ResultadoCartaPorte
  --end
  end
  else if @cliente != '' and @segmento !=''
  begin
  Select h.lgh_number as Segmento ,v.Folio as Folio, h.lgh_startdate as Fechac, v.Fecha as Fechat, o.ord_billto as cliente, h.ord_hdrnumber as orden from legheader  as h LEFT JOIN VISTA_Carta_Porte AS v ON v.Folio = h.lgh_number LEFT JOIN orderheader as o ON o.ord_hdrnumber = h.ord_hdrnumber WHERE o.ord_startdate > '2022-03-01' AND h.lgh_outstatus != 'CAN' AND h.ord_hdrnumber > 0 AND h.lgh_number = @segmento AND o.ord_billto like '%'+@cliente+'%'
--else if(select count(Folio) from ResultadoCartaPorte where Folio like '%'+@segmento+'%')<1
  --begin
    --select Folio,Serie,UUID,Pdf_xml_descarga,Pdf_descargaFactura, replace(xlm_descargaFactura,'}','') as xlm_descargaFactura
    --from ResultadoCartaPorte
  --end
  end
end
GO
