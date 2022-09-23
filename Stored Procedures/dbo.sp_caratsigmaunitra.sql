SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera Yanez
Fecha: 09/06/2014
Vewrsion 1:00

Parametros: Fecha inicial y Fecha final en la que empezaron las ordenes
Descripción: SP que arroja l las unidaes que trabajaron en Sigma en base al 
sp caratsigma
Ejemplo 
exec sp_caratsigmaunitra '2014-05-01','2014-06-01'
*/

CREATE proc [dbo].[sp_caratsigmaunitra] 
 @fechaini datetime,
 @fechafin datetime
 

as

BEGIN

declare @tempo table
(tractor varchar(6),Fecha varchar(10))

declare @tempo2 table
(tractor varchar(6),Fecha varchar(10))

insert into @tempo


select
Tractor  =  (( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number))
,Fecha = cast(year(stp_arrivaldate) as varchar)+cast(month(stp_arrivaldate) as varchar)+cast(day(stp_arrivaldate) as varchar)

from stops
where stops.ord_hdrnumber in (select ord_hdrnumber from invoiceheader where ivh_billto = 'SIGMAALI' and ivh_invoicestatus in ('PRN','XFR'))
and  stp_arrivaldate  between  @fechaini and @fechafin
and ord_hdrnumber <> '0'
and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null
order by ord_hdrnumber


insert into @tempo2
select distinct tractor,fecha  from @tempo

select count(tractor) from @tempo2

END
GO
