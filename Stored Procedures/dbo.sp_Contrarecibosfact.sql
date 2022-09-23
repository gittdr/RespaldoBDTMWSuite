SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*

SP que obtiene datos para crear reporte de contrarecibos para facturas
se le pasa como parametro el nombre del cliente, fecha de inicio y de fin para definir periodo

Creador por: Emilio Olvera Yanez
ver: 1.0
Fecha: 27 de Mayo 2014

reporte de informacion viva 
basado en la tabla invoceheader


prueba 
exec sp_Contrarecibosfact 'SAYER', '2014-05-28', '2014-06-01'

*/



CREATE proc [dbo].[sp_Contrarecibosfact]
(@cliente varchar (20), @fechaini datetime, @fechafin datetime )


as

SET NOCOUNT ON

--Caso invoice sencilla
select ivh_ref_number,
ivh_totalcharge,
ivh_billto,
(select cmp_name from company where cmp_id = ivh_billto) as RazonSocial,  
(select rtrim(cmp_address1)+' '+rtrim(cmp_address2) from company where cmp_id = ivh_billto) as Direccion,
(select rtrim(cmp_misc2)  from company where cmp_id = ivh_billto)  as diarevision
from tmwsuite.dbo.invoiceheader
where 
ivh_invoicestatus in ('PRN','XFR')  
and ivh_printdate between @fechaini and @fechafin
and ivh_billto = @cliente
and ivh_mbnumber = 0 

union

--Caso master bill agrupado por numero de master
select ivh_ref_number,
sum(ivh_totalcharge) as ivh_totalcharge,
ivh_billto,
(select cmp_name from company where cmp_id = ivh_billto) as RazonSocial,  
(select rtrim(cmp_address1)+' '+rtrim(cmp_address2) from company where cmp_id = ivh_billto) as Direccion,
(select rtrim(cmp_misc2)   from company where cmp_id = ivh_billto)  as diarevision
from tmwsuite.dbo.invoiceheader
where
ivh_invoicestatus in ('PRN','XFR')  
and ivh_printdate between @fechaini and @fechafin
and ivh_billto = @cliente
and ivh_mbnumber <> 0 
group by ivh_ref_number,ivh_billto

order by ivh_ref_number desc

/*

select 
bandera as ivh_ref_number,
total as ivh_totalcharge,
idreceptor as ivh_billto,
(select cmp_name from company where cmp_id = idreceptor) as RazonSocial,  
(select rtrim(cmp_address1)+' '+rtrim(cmp_address2) from company where cmp_id= idreceptor) as Direccion,
'Lunes' as diarevision
from vista_fe_generadas
where idreceptor = 'SAYER'
and
fhemision between @fechaini and @fechafin
order by bandera desc
*/
GO
