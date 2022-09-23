SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera Yáñez
Fecha: 11 Jun 2019
Version: 1.5

Sentencia prueba 

exec sp_DIESELCALCSTOP

delete stopsdiesel

--Regresar la Tabla de STOPS Diesel
select * from stopsdiesel order by Kms desc

--Regresar la Cantidad de Diesel a Dispersar por Proveedor
select Trc, Proveedor, sum(Litros) as Litros
from stopsdiesel
group by Trc,Proveedor
order by Litros desc



--Consulta para obtener stops en los cuales no se pudo calcular rendimiento--
select distinct Trc,ORden, Movimiento, Proyecto, Motor, ejes, peso, 
(replace(replace(replace(replace(StCarga,'MT','Vacio'),'NON','Vacio'),'BT','VACIO'),'LD','Cargado')), Rendimiento  from stopsdiesel where rendimiento = 0 




*/

CREATE proc [dbo].[sp_DIESELCALCSTOP] 
as



insert into  stopsdiesel

select 
ev.evt_tractor                                             as Trc,
''                                                         as ProyectoAbbr,
''                                                         as Proyecto,
''                                                         as Motor,
0                                                          as CapacidadTanque,
0                                                          as NivelTanque,
''                                                         as Cliente,
stp.mov_number                                             as Movimiento,
stp.ord_hdrnumber                                          as Orden,
stp.lgh_number                                             as Segmento,
stp.stp_number                                             as Stopnumber,
stp.stp_mfh_sequence                                       as Secuencia,
''                                                         as CompaniaOrigen,
''                                                         as CiudadOrigen,
''                                                         as EstadoOrigen,
stp.cmp_name                                               as CompaniaDestino,
(select cty_nmstct from city where cty_code =stp.stp_city) as CiudadDestino,
(select cty_state  from city where cty_code =stp.stp_city) as EstadoDestino,
isnull(stp_lgh_mileage,0)                                  as Kms,
stp_loadstatus                                             as StCarga,
isnull(stp_weight,0)                                       as Peso,
replace(ev.evt_trailer1,'UNKNOWN','')                      as Trailer1,
replace(ev.evt_trailer2,'UNKNOWN','')                      as Trailer2,
replace(ev.evt_dolly   ,'UNKNOWN','')                      as Dolly,
0                                                          as EjesTRC,
0                                                          as EjesTRL1,
0                                                          as EjesTRL2,
0                                                          as EjesDolly,
0                                                          as Ejes,
0                                                          as Rendimiento,
0                                                          as Litros,
''                                                         as Proveedor,
null                                                       as Inicio,
stp_arrivaldate                                            as Fin,
0                                                          as Duracion

from stops stp
left join event ev on ev.stp_number = stp.stp_number
where 
--Obtenemos los stops comppletados el Dia de Hoy
stp_status = 'DNE' and stp_departure_status  ='DNE'
and  datediff(day,stp_departuredate, getdate()) = 1  
and stp.stp_number not in (select stopnumber from stopsdiesel)

/* 
--- Para obtenerlo por LEGS Completados
lgh_number in  (select lgh_number from legheader
where lgh_outstatus = 'CMP'
and datediff(day,lgh_enddate,getdate()) = 0)
order by Movimiento asc, Secuencia asc
*/

--Eliminar Stops que no tengan un TRC declarado
delete stopsdiesel where trc = 'UNKNOWN'
delete stopsdiesel where Secuencia = 1

--Update Compania, Ciudad y Estado de Origen + FechaInicio del recorrido y Duracion
update stopsdiesel set Inicio         = isnull((select stp_departuredate   from stops st where st.mov_number = Movimiento and st.stp_mfh_sequence = (Secuencia-1)),'')
update stopsdiesel set Duracion       = DATEDIFF(day,Inicio,Fin)
update stopsdiesel set CompaniaOrigen = isnull((select cmp_name            from stops st where st.mov_number = Movimiento and st.stp_mfh_sequence = (Secuencia-1)),'')
update stopsdiesel set CiudadOrigen   = isnull((select (select cty_nmstct  from city     where cty_code =st.stp_city) from stops st where st.mov_number = Movimiento and st.stp_mfh_sequence = (Secuencia-1)),'')
update stopsdiesel set EstadoOrigen   = isnull((select (select cty_state   from city     where cty_code =st.stp_city) from stops st where st.mov_number = Movimiento and st.stp_mfh_sequence = (Secuencia-1)),'')

--Update cliente de la orden
update stopsdiesel set Cliente = isnull((select ord_billto from orderheader (nolock) where ord_hdrnumber = Orden),'')

--Update Proyecto, Motor, Nivel Tanque, Cap Tanque y Ejes del Tractor
update stopsdiesel set  
                        ProyectoAbbr     = trc_type3,
                        Proyecto         = ( select name from labelfile where labeldefinition = 'trctype3' and abbr = trc_type3),
                        Motor            = trc_enginemake, 
						EjesTrc          = trc_axles,
						CapacidadTanque  = isnull(trc_tank_capacity,0),
						NivelTanque      = isnull(trc_gal_in_tank,0)
from stopsdiesel left join tractorprofile on trc = trc_number
where trc_number = trc

--Update Ejes Trc,Trl, Dolly
update stopsdiesel set  EjesTrl1  = (select isnull(max(trl_axles),0) from trailerprofile where trl_number  =  Trailer1 and trl_status <> 'OUT'),
                         EjesTrl2  = (select isnull(max(trl_axles),0) from trailerprofile where trl_number  =  Trailer2 and trl_status <> 'OUT'),
						 EjesDolly = (select isnull(max(trl_axles),0) from trailerprofile where trl_number  =  Dolly    and trl_status <> 'OUT')

--Update Ejes Totales
update stopsdiesel set  Ejes = (EjesTrc+EjesTrl1+EjesDolly+EjesTrl2)

--Update Calculo del Rendimiento del STOP
Update stopsdiesel set Rendimiento = case 
                                      
                                      when StCarga in ('MT','BT','NON') then
                                          (select isnull(max(fec_mpg_empty),0)  from fueleconomy where fec_engine = Motor and fec_num_axles = Ejes and fec_region =  ProyectoAbbr )
                                      when StCarga = 'LD' then
                                          (select isnull(max(fec_mpg_loaded),0) from fueleconomy where fec_engine = Motor and fec_num_axles = Ejes and Peso between fec_min_weight 
										  and fec_max_weight  and fec_region  = ProyectoAbbr) end

--Update Calculo de Litros
update stopsdiesel set Litros  = case when Rendimiento = 0 then 0 else Kms / Rendimiento end


--Update Proveedor Diesel
update stopsdiesel set Proveedor = 'EXXIA'  where EstadoDestino in ('QA','EM','DF','NX','PU','AG','MX','TL','HG')
update stopsdiesel set Proveedor = 'NIETO2' where EstadoDestino in ('JA')
update stopsdiesel set Proveedor = 'TCAR'   where EstadoDestino in ('BJ','BS','CP','CH','CI','CU','CL','DG','GR','MH','MR','NA','OA','QR','SL','SI','SO','TA','TM','VZ','YC','ZT','GJ')
--update casos particulares de Clientes
update stopsdiesel set Proveedor = 'PERC'   where EstadoDestino in ('AG','QA','GJ') and Cliente = 'SAYER'
update stopsdiesel set Proveedor = 'PERC'   where CompaniaDestino  = 'SAYER LACK MEXICANA S.A. DE C.'
update stopsdiesel set Proveedor = 'NIETO1' where  (Cliente = 'PILGRIMS' and   EstadoDestino in ('HG'))
update stopsdiesel set Proveedor = 'NIETO2' where  (Cliente = 'GNV' and   EstadoDestino in ('SO'))
update stopsdiesel set Proveedor = 'EXXIA'  where (Cliente = 'PEÑAFIEL' and Litros < 550)


--Eliminar mismos origenes y destinos con litros 0
delete stopsdiesel where CompaniaOrigen = CompaniaDestino and Litros = 0 

GO
