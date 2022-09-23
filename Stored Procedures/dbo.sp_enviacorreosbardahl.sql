SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  PROCEDURE [dbo].[sp_enviacorreosbardahl]
AS


--Inicia consulta prueba que hay en la lista
--Ejecucion del sp para pruebas
--exec sp_enviacorreosbardahl

--Creamos las variables para el cursor
Declare 

@destinatarios varchar(900),
@cuerpo varchar(900),
@encabezado varchar(900),
@V_registros integer,
@V_i integer

---Creación de la tabla temporal que contendra la lista de distribución de correos
Declare @Distlist Table (Referencia varchar(50), Sucursal varchar(15), AltaOrden datetime,
Recipients varchar(900), Subject varchar(900), Body varchar(900) )

--Insertamos en la tabla temporal los registros.

insert into @Distlist
 
select 
isnull(stp_refnum,'Sin Ref')  as Referencia, 
cmp_id  as Sucursal, 
stp_schdtearliest as AltaOrden, 

Case cmp_id  

------------------------------------------------------------------------------------inicio correos en pruebas------------------------------------------------------------------------------
/*
when 'BDACA' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDAGS' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDATL' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDCAM' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDCAN' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDTUX' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDCHI' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDJUA' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDOBR' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDVAL' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDVIC' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDCOA' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDCOL' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDCUA' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDCUE' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDCUL' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDDUR' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDGDL' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDHER' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDLEO' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDMOC' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDMAZ' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDMER' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDMEX' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDMON' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDMTY' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDMOR' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDPAC' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDPOZ' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDQRO' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDRIO' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDSLP' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDTAM' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDTEX' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDTLA' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDTOL' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDTOR' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDVER' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDVHA' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDXAL' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
when 'BDZAC' then 'emolvera@tdr.com.mx;jyanez@tdr.com.mx;chernandez@tdr.com.mx'
----------------------------------------------------------------------------------fin envio de correos en pruebas-----------------------------------------------------------------------

*/
--------------------------------------------------------------------------------inicio envio correos en produccion----------------------------------------------------------------------
when 'BDACA' then 'acapulco@bardahl.com.mx;dis_acapulco@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDAGS' then 'ags@bardahl.com.mx;dis_ags@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDATL' then 'atlacomulco@bardahl.com.mx;dis_atlacomulco@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDCAM' then 'campeche@bardahl.com.mx;dis_campeche@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDCAN' then 'cancun@bardahl.com.mx;dis_cancun@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDTUX' then 'tuxtla@bardahl.com.mx;dis_tuxtla@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDCHI' then 'chihuahua@bardahl.com.mx;dis_chihuahua@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDJUA' then 'juarez@bardahl.com.mxdis_juarez@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDOBR' then 'obregon@bardahl.com.mx;dis_obregon@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDVAL' then 'valles@bardahl.com.mx;dis_valles@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDVIC' then 'victoria@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDCOA' then 'coatzacoalcos@bardahl.com.mx;d_coatzacoalcos@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDCOL' then 'colima@bardahl.com.mx;dis_colima@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDCUA' then 'cuautla@bardahl.com.mxdis_cuautla@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDCUE' then 'cuernavaca@bardahl.com.mx;dis_cuernavaca@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDCUL' then 'culiacan@bardahl.com.mx;dis_culiacan@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDDUR' then 'durango@bardahl.com.mx;dis_durango@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDGDL' then 'guadalajara@bardahl.com.mx;dis_guadalajara@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDHER' then 'hermosillo@bardahl.com.mx;dis_hermosillo@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDLEO' then 'karlab.lara@bardahl.com.mx;emma.martinez@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDMOC' then 'mochis@bardahl.com.mx;dis_mochis@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDMAZ' then 'mazatlan@bardahl.com.mx;dis_mazatlan@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDMER' then 'merida@bardahl.com.mx;dis_merida@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDMEX' then 'mario.galicia@bardahl.com.mx;juan.sanchez@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDMON' then 'sabinas@bardahl.com.mx;dis_monclova@bardahl.co.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDMTY' then 'monterrey@bardahl.com.mx;dis_monterrey@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDMOR' then 'morelia@bardahl.com.mx;dis_morelia@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDPAC' then 'pachuca@bardahl.com.mx;dis_pachuca@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDPOZ' then 'pozarica@bardahl.com.mx;dis_pozarica@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDQRO' then 'dis_queretaro@bardahl.com.mx;queretaro@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDRIO' then 'reynosa@bardahl.com.mx;dis_reynosa@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDSLP' then 'slp@bardahl.com.mx;dis_slp@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDTAM' then 'tampico@bardahl.com.mx;dis_tampico@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDTEX' then 'texcoco@bardahl.com.mx;dis_texcoco@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDTLA' then 'tlaxcala@bardahl.com.mx;dis_tlaxcala@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDTOL' then 'toluca@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDTOR' then 'torreon@bardahl.com.mx;dis_torreon@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDVER' then 'veracruz@bardahl.com.mx;dis_veracruz@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDVHA' then 'villahermosa@bardahl.com.mx;dis_viilahermosa@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDXAL' then 'xalapa@bardahl.com.mx;dis_xalapa@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
when 'BDZAC' then 'zacatecas@bardahl.com.mx;dis_zacatecas@bardahl.com.mx;chernandez@tdr.com.mx;javier.zamora@bardahl.com.mx,jose.gonzalezg@bardahl.com.mx'
else 'chernandez@tdr.com.mx'
-----------------------------------------------------------------------------------fin envio correos en produccion----------------------------------------------------------------------------------------------

end as recipients,

'NOTIFICACION envio de pedido ' + isnull(stp_refnum,'Sin Ref')+ ' a sucursal ' + isnull((select cmp_name from company where stops.cmp_id = company.cmp_id),'')  as Subject ,
' Por este medio le notificamos el arribo del pedido ' + isnull((stp_refnum),'Sin Ref') +' Orden TDR:' + cast(ord_hdrnumber as varchar)  + ' a su sucursal ' + isnull((select cmp_name from company where  stops.cmp_id = company.cmp_id) ,'') 
+ ' en la hora estimada de llegada entre ' + isnull(cast( stp_schdtearliest as varchar),'')  + ' y ' + isnull(cast(stp_schdtlatest as varchar),'') as Body
from stops
where ord_hdrnumber in (select ord_hdrnumber from orderheader with (nolock) where orderheader.ord_billto = 'BARDAHL' and orderheader.ord_Status = 'PLN')
and abs(datediff(n,stp_schdtearliest,getdate())) <= 60
and stp_event = 'LUL'


            update @Distlist set  body = 'Este destino no tiene configurados correos de bardahl para envio / ' where Recipients = 'chernandez@tdr.com.mx'
            update @Distlist set  Subject =  'Correo no enviado a destinatarios Bardahl / '+ @encabezado  where Recipients = 'chernandez@tdr.com.mx'


--Borramos los registros que no tienen recipientes para enviar el correo ya que son sucursales que no requieren el envio.
--delete from @Distlist where recipients is null

---sentecia de prueba para ver que hay en la lista de distribución
select * from @Distlist
--select datediff(hh,'2013-05-30 16:24:10.103',getdate())
--termina consulta prueba que hay en la lista 

--Se obtiene el total de registros de la tabla temporal
select @V_registros =  (Select count(*) From  @Distlist )
print @V_registros
--Se inicializa el contador en 1
select @V_i = 0

-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @Distlist )
	BEGIN --Si hay registros procedemos.

    
		--Creamos cursor que recorre la tabla temporal para enviar los correos contenidos en ella
		DECLARE Distribucion_Cursor CURSOR FOR 
		SELECT 	Recipients, Subject, Body 
		FROM @Distlist

		OPEN Distribucion_Cursor 
		FETCH NEXT FROM Distribucion_Cursor  INTO @destinatarios,@encabezado,@cuerpo
        WHILE (@@FETCH_STATUS = 0 and @V_i < @V_registros)
		  BEGIN -- del cursor 

             EXEC msdb.dbo.sp_send_dbmail
             @profile_name = 'smtp TDR',
             @recipients = @destinatarios,
             @copy_recipients = 'chernandez@tdr.com.mx',
             @body = @cuerpo ,
             @subject = @encabezado ,
             @attach_query_result_as_file = 0 ;

	      --Se aumenta el contador en 1.
		    select @V_i = @V_i + 1

		    FETCH NEXT FROM Distribucion_Cursor  INTO @destinatarios,@encabezado,@cuerpo
	
	       END -- del cursor
    
    CLOSE Distribucion_Cursor 
	DEALLOCATE Distribucion_Cursor 

END -- del if si hay registros en la tabla

GO
