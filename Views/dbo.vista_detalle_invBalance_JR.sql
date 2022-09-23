SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[vista_detalle_invBalance_JR] as
select *,(select ord_description from orderheader where ord_hdrnumber = orden) as mercan,
(Select max(v.Folio) from legheader  as h 
LEFT JOIN VISTA_Carta_Porte AS v ON v.Folio = h.lgh_number 
WHERE h.lgh_outstatus != 'CAN' AND h.lgh_number in 
(select lgh_number from legheader where ord_hdrnumber = orden)) AS cartaporte
from tts_bs_invoice_detail
GO
