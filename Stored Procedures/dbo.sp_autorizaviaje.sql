SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/***********************
Autor: Emilio Olvera
Version: 1.0
fecha: % de Sept 2108

SP que inserta notas en las ordenes sobre quien autoriza el viaje desde ESTAT
recibe parametros

@orden: numero de la orden
@token: token de seguridad para ejecucion
@first: nombre usuario estat que autoriza
@last : apellido usuario estat que autoriza

setencia de de prueba

exec sp_autorizaviaje '588728','TK8993588728A45CBGH23JT67', 'ADMIN', 'TDR'

**************************/

CREATE proc [dbo].[sp_autorizaviaje] (@orden varchar(10), @token varchar(100), @First varchar(100), @Last varchar(100))
as

declare @refnumber as varchar (20), @ordercomp as varchar(20)

select @refnumber= isnull(ord_refnum,''), @ordercomp = ord_hdrnumber from
orderheader (nolock) where ord_hdrnumber = @orden


if ( 'TK8993'+@orden+'A45CBGH23JT67' = @token)
begin

	update orderheader set ord_status = 'AVL',  ord_revtype2 ='QRO' where ord_hdrnumber = @orden
	update legheader set lgh_outstatus = 'AVL' where  ord_hdrnumber = @orden


	declare @autoriza varchar(500) = 'Orden Autorizada por: ' + @First + ' ' + @Last + ' el ' + cast(getdate() as varchar (120))

	exec notes_add_sp 'orderheader',@orden, @autoriza,'NONE','A','E'

	select 'Se ha creado la Bitacora: ' + cast(lgh_number  as varchar(20)) + ' Origen: ' + ord_shipper  + ' Destino: ' + ord_consignee + 'Con Motivo: ' + ord_remark + ' Autorizado por: ' + @First + ' ' + @Last   as Mensaje from legheader left join orderheader on
	legheader.ord_hdrnumber = orderheader.ord_hdrnumber
	 where orderheader.ord_hdrnumber = @orden

end
else
 begin 
   select 'No se ha podido crear el viaje, favor de autorizar el viaje desde el mensaje recibido por correo' as Mensaje
 end




--select * from notes  where not_text like 'Orden Autorizada%' order by last_updatedatetime desc
--delete notes where not_text like 'Orden Autorizada%'

GO
