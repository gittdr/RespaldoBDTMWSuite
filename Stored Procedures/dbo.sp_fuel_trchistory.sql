SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
SP fuel tractor history

Autor: Emilio Olvera
Fecha: 11 Oct 2021
Version: 1.0

SP que trae los datos de compra de diesel para una unidad especifica en el tiempo 
dado.

sentencia de prueba


exec sp_fuel_trchistory '1777', '2021-10-01 00:00:00.000', '2021-10-11 17:32:56.000'
exec sp_fuel_trchistory 'LISTA', NULL, NULL


*/


CREATE proc [dbo].[sp_fuel_trchistory] (@trc varchar(20), @fini datetime, @ffin datetime)

as

if (@trc not in  ('TODOS','LISTA'))

begin

select trc_number, fp_id as ID, fp_vendorname as Sitio, fp_chaincode as Proveedor, fp_cardnumber as Tarjeta, fp_date as Fecha,fp_quantity as Litros,
fp_cost_per as CostoPorLitro, fp_amount as Total from fuelpurchased where trc_number = @trc
and fp_date between @fini and @ffin

end

if (@trc = 'TODOS')

begin
 select trc_number, fp_id as ID, fp_vendorname as Sitio, fp_chaincode as Proveedor, fp_cardnumber as Tarjeta, fp_date as Fecha,fp_quantity as Litros,
fp_cost_per as CostoPorLitro, fp_amount as Total from fuelpurchased where 
fp_date between @fini and @ffin

end

if (@trc = 'LISTA')
begin
 select trc_number from tractorprofile where trc_status <> 'OUT'
 and trc_number <> 'UNKNOWN'
 union
 select 'TODOS'
end
GO
