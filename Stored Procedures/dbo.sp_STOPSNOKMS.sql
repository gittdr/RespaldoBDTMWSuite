SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera Yáñez
Fecha: 15 Jun 2019
Version: 1.5

Sentencia prueba 

exec sp_STOPSNOKMS
--Stops que no tienen kms
*/

CREATE proc [dbo].[sp_STOPSNOKMS] 
as


declare @stopsnokms table (Trc varchar(200), Proyectoabbr  varchar(100), Proyecto varchar(1000),
Cliente varchar(20),Movimiento varchar(200), Orden varchar(100), Segmento varchar(200), Stopnumber varchar(200), Secuencia int,
 CompaniaOrigen varchar(100), CiudadOrigen varchar(max),  EstadoOrigen varchar(10),
  CompaniaDestino varchar(max), CiudadDestino varchar(max),  EstadoDestino varchar(10),
Kms int, stp_loadstatus varchar(10)  )                  

insert into  @stopsnokms

select 
ev.evt_tractor                                             as Trc,
''                                                         as ProyectoAbbr,
''                                                         as Proyecto,
''                                                         as Cliente,
stp.mov_number                                             as Movimiento,
stp.ord_hdrnumber                                          as Orden,
stp.lgh_number                                             as Segmento,
stp.stp_number                                             as Stopnumber,
stp.stp_mfh_sequence                                       as Secuencia,
''                                                         as CompaniaOrigen,
''                                                         as CiudadOrigen,
''                                                         as EstadoOrigen,
stp.cmp_id + ' | ' +stp.cmp_name                           as CompaniaDestino,
(select cty_nmstct from city where cty_code =stp.stp_city) as CiudadDestino,
(select cty_state  from city where cty_code =stp.stp_city) as EstadoDestino,
isnull(stp_lgh_mileage,0)                                  as Kms,
stp_loadstatus                                             as StCarga


from stops stp
left join event ev on ev.stp_number= stp.stp_number
where 
stp.lgh_number in (select lgh_number from legheader where lgh_outstatus in ('STD','PLN'))
and stp.stp_ord_mileage <= 0
and year(stp.stp_arrivaldate) >= 2019

--Eliminar Stops que no tengan un TRC declarado
delete @stopsnokms where Secuencia = 1

--Update Compania, Ciudad y Estado de Origen + FechaInicio del recorrido y Duracion

update @stopsnokms set CompaniaOrigen = isnull((select cmp_id + ' | '+ cmp_name            from stops st where st.mov_number = Movimiento and st.stp_mfh_sequence = (Secuencia-1)),'')
update @stopsnokms set CiudadOrigen   = isnull((select (select cty_nmstct  from city     where cty_code =st.stp_city) from stops st where st.mov_number = Movimiento and st.stp_mfh_sequence = (Secuencia-1)),'')
update @stopsnokms set EstadoOrigen   = isnull((select (select cty_state   from city     where cty_code =st.stp_city) from stops st where st.mov_number = Movimiento and st.stp_mfh_sequence = (Secuencia-1)),'')

--Update cliente de la orden
update @stopsnokms set Cliente = isnull((select ord_billto from orderheader (nolock) where ord_hdrnumber = Orden),'')
update @stopsnokms set Cliente =  'Movimiento' where Cliente = ''
 
--Update Proyecto, Motor, Nivel Tanque, Cap Tanque y Ejes del Tractor
update @stopsnokms set  
                        ProyectoAbbr     = (select ord_revtype3 from orderheader where ord_hdrnumber = orden),
                        Proyecto         = isnull((select name from labelfile where labeldefinition = 'revtype3' and abbr = ((select ord_revtype3 from orderheader where ord_hdrnumber = orden)) ),'Movimiento')

from @stopsnokms left join tractorprofile on trc = trc_number
where trc_number = trc

--Eliminar mismos origenes y destinos con kms 0
delete @stopsnokms  where CompaniaOrigen = CompaniaDestino and kms = 0 



select distinct Cliente,Proyecto, Proyectoabbr, CompaniaOrigen, CiudadOrigen, EstadoOrigen,
                CompaniaDestino, CiudadDEstino, EstadoDestino, Segmento from @stopsnokms
GO
