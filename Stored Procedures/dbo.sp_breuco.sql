SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
SP REPORTE BR EUCOMEX
AUTOR: EMILIO OLVERA YANEZ
FECHA: 16/10/2014
VERSION:1.0

STORED PROCCEDURE QUE REGRESA UNA TABLA CON EL RESUMEN DEL REPORTE BR DE EUCOMEX

1) RECIBE COMO PARAMETRO FINI / FECHA DESDE LA CUAL SE QUIERE GENERAR EL REPORTE EN BASE A FECHA TERMINO ORDEN
2) RECIBE COMO PARAMETRO FFIN / FECHA HASTA LA CUAL SE QUIERE GENERAR EL REPORTE EN BASE A FECHA TERMINO ORDEN

3) RECIBE COMO PARAMETRO TDR SI  SE VA A GENERAR REPORTE PARA VIAJES HECHOS POR TDR
   O
   RECIBE COMO PARAMETRO CARRIER SI SE VA A GENERAR REPORTE PARA VIAJES TERCERIZADOS

EJEMPLOS


EXEC SP_BREUCO '2014-01-01','2014-12-01','TDR'
EXEC SP_BREUCO '2014-01-01','2014-12-01','CARRIER'


*/


CREATE proc [dbo].[sp_breuco] (@fini datetime,@ffin datetime,@modo varchar(10))

as


-------------------------------------------------------------------------------------------------------------------------------------------------
--CREAMOS LA TABLA TEMPORAL DONDE SE ALMACENARAN LOS CARRIERS
declare @carrier  table (carrier varchar(20))

-------------------------------------------------------------------------------------------------------------------------------------------------
--DE ACUERDO AL VALOR PASADO AL STORE PROC SI ES TDR INSERTA UNKNOW PARA QUE SOLO TRAIGA VIAJES HECHOS POR TDR SI NO ES ASI INSERTA LA LISTA DE CARRIERS

If (@modo = 'TDR' )
 begin
   insert into @carrier values ('UNKNOWN')
 end
else
 begin
  insert into @carrier  select car_id from carrier
 end


-------------------------------------------------------------------------------------------------------------------------------------------------
--CREAMOS LA TABLA TEMPORAL DONDE SE ALMACENARAN LOS DATOS BRUTOS


declare @resumbytrl  table   (mes int, kmsrecorridos int, litrosDesplazados int, Capacidad int, CostoXLitro float, Remolque varchar(10), EficienciaCarga float, Viajes int, Region varchar (500))


-------------------------------------------------------------------------------------------------------------------------------------------------
--INSERTAMOS LOS VALORES DE NUESTRA CONSULTA EN LA TABLA TEMPORAL DE DONDE RESUMIREMOS LOS DATOS

insert into  @resumbytrl 
select   
Mes = month(ord_completiondate)
,KmsRecorridos = sum(ord_totalmiles)
,LitrosDesplazados = (sum(ord_totalvolume) *1000)
,Capacidad = 
 case when ord_trailer <> 'UNKNOWN' then
(select (case  trl_type2 when '30MLTS' then 40000  when '53' then 53000 end) from trailerprofile where trl_number = ord_trailer)

else
(10000)
end

,CostoXLitro =   (sum(ord_totalvolume) * 1000) / sum(ord_totalcharge)
--,CostoXLitro =   (sum(ord_totalvolume)) / sum(ord_totalcharge)
,Remolque = replace(Ord_trailer,'UNKNOWN','TORTHON')
,EficienciaCarga = isnull((sum(ord_totalvolume)*1000) /

--,EficienciaCarga = isnull((sum(ord_totalvolume)) /



case when ord_trailer <> 'UNKNOWN' then
(select (case  trl_type2 when '30MLTS' then 40000  when '53' then 53000 end) from trailerprofile where trl_number = ord_trailer)

else
(16000)
end,0)
,Viajes = count(ord_hdrnumber)
,Region =  (STUFF((select  '; ' + cmp_state    from company where cmp_id in (select cmp_id from stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber ) FOR XML PATH('')) , 1, 1, ''))




---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CONDICIONES PARA LA CONSULTA

from orderheader where   ord_completiondate between @fini and @ffin
and ord_billto = 'EUCOMEX' 
and ord_totalmiles > 0
and ord_status = 'CMP'  and ord_carrier in (select carrier from @carrier)
group by month(ord_completiondate), ord_trailer, ord_hdrnumber

--group by datename(mm, ord_completiondate), ord_trailer, ord_hdrnumber


update  @resumbytrl
set Region = case 

-----------------------------------------------
--NORTE
when Region like '%NX%' then 'NORTE'
when Region like '%TM%' then 'NORTE'
when Region like '%CI%' then 'NORTE'
when Region like '%CU%' then 'NORTE'
when Region like '%DG%' then 'NORTE'
-----------------------------------------------
--TIJUANA
when Region like '%BJ%' then 'TIJUANA'
when Region like '%BS%' then 'TIJUANA'
-----------------------------------------------
--MINA
when Region like '%ZT%' then 'MINA'
when Region like '%DG%' then 'MINA'
when Region like '%CI%' then 'MINA'
when Region like '%SO%' then 'MINA'
-----------------------------------------------
--PACIFICO
when Region like '%CL%' then 'PACIFICO'
when Region like '%NA%' then 'PACIFICO'
when Region like '%SI%' then 'PACIFICO'
when Region like '%SO%' then 'PACIFICO'
-----------------------------------------------
--SURESTE
when Region like '%CH%' then 'SURESTE'
when Region like '%TA%' then 'SURESTE'
when Region like '%CP%' then 'SURESTE'
when Region like '%QR%' then 'SURESTE'
when Region like '%OA%' then 'SURESTE'
when Region like '%YC%' then 'SURESTE'
-----------------------------------------------
--FORANEO CORTO
when Region like '%PU%' then 'FORANEO CORTO' 
when Region like '%VZ%' then 'FORANEO CORTO'
when Region like '%GJ%' then 'FORANEO CORTO'
when Region like '%JA%' then 'FORANEO CORTO'
when Region like '%SL%' then 'FORANEO CORTO'
when Region like '%QA%' then 'FORANEO CORTO'
when Region like '%AG%' then 'FORANEO CORTO'
when Region like '%GR%' then 'FORANEO CORTO'
when Region like '%MH%' then 'FORANEO CORTO'
when Region like '%ZT%' then 'FORANEO CORTO'
-----------------------------------------------
--METROPOLITANA
when Region like '%EM%' then 'METROPOLITANA'
when Region like '%HG%' then 'METROPOLITANA'
when Region like '%MR%' then 'METROPOLITANA'
when Region like '%TL%' then 'METROPOLITANA'
when Region like '%DF%' then 'METROPOLITANA'
-----------------------------------------------
end


----------------------------------------------------------------------------------------------------------------------------------------------------------------
--DESPLIEGUE DE LA CONSULTA FINAL RESUMIDA

select 
Mes
--,Fecha
,KmsRecorridos=sum(KmsRecorridos) 
,LitrosDesplazados=sum(LitrosDesplazados)
,CostoXLitro=avg(CostoXLitro)
,EficienciaCarga=avg(EficienciaCarga)
,viajes= sum(viajes)
,Region

from @resumbytrl
group by Mes,Region
order by Mes
GO
