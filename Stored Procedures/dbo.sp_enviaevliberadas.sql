SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[sp_enviaevliberadas] (@tractor varchar (20))
as

---Declaracion de las varibles necesarioas para obtener el operador, y armar el mensaje
declare @nombre varchar(200),@oper1 varchar(200), @oper2 varchar(200), @mensaje varchar(MAX), @mensajeord varchar(max)


 select
 @oper1 = (select max(mpp_firstname) from manpowerprofile where mpp_id =  trc_driver),
 @oper2= (select max(mpp_firstname) from manpowerprofile where mpp_id = trc_driver2) 
 from tractorprofile where trc_number = @tractor

select @nombre = @oper1 +  case when @oper2 is not null then ('/' + @oper2) else '' end



---Armado del encabezado del mensaje.
select @mensaje = 'Hola ' + isnull(@nombre,'') +'! '+'el  dia de hoy te hemos liberado las siguientes evidencias:' + char(10) + char(13) +
				  
				  '(puedes ver el estado de pago y documentos faltantes presionando sobre el numero de cada orden)' + char(10) + char(13) 


----Armado del detalle del mensaje.
select
@mensajeord =  

 (stuff((select ',' +
(select  +' '+ max(name) from labelfile where labeldefinition = 'PaperWork' and labelfile.abbr = paperwork.abbr)
+ ' Orden: ' + cast(ord_hdrnumber as varchar(20))
from paperwork 
where datediff(dd,pw_dt, getdate()) = 0  
and pw_received = 'Y'
and lgh_number in (select lgh_number from legheader where lgh_tractor = @tractor)
FOR XML PATH('') ), 1, 1, ''))


--Se une el encabezado del mensaje con su detalle.
------------------------------------------
select @mensaje = @mensaje + @mensajeord

--Se inserta el mensaje en la tabla de total mail.
--------------------------------------------

--Sentencia para pruebas debugeo
--select @tractor, @mensaje

exec tm_insertamensaje @mensaje , @tractor
GO
