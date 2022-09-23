SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Fuel_TCPurchase] (@Proveedor varchar(1000), @Unidad varchar(1000), @Tarjeta  varchar(1000), @Folio varchar(1000), @FechaTransaccion varchar(1000), @HoraTransaccion varchar(1000), @Estacion varchar(1000), @PrecioUnitario varchar(1000), @Litros decimal(10,2), @ImporteTransaccion decimal(10,2),@Direccion varchar(1000),@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
IF(@accion = 1)
BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

		-- Insert statements for procedure here
		insert into Fuel.[dbo].[purchase](Proveedor, Unidad, Tarjeta, Folio, FechaTransaccion, HoraTransaccion, Estacion, PrecioUnitario, Litros, ImporteTransaccion, Direccion)
		values(@Proveedor, @Unidad, @Tarjeta, @Folio, @FechaTransaccion, @HoraTransaccion, @Estacion, @PrecioUnitario, @Litros, @ImporteTransaccion,@Direccion)
END
IF(@accion = 2)
BEGIN
		insert into [dbo].[fuelpurchased](fp_id, fp_sequence, fp_cardnumber, fp_cac_id, fp_ccd_id, fp_purchcode, fp_date,
				 fp_quantity, fp_uom, fp_fueltype, fp_trc_trl, fp_cost_per, fp_amount, ord_number, ord_hdrnumber, mov_number,
				  lgh_number, stp_number, trc_number, trl_number, mpp_id, fp_owner, fp_odometer, ts_code, fp_vendorname,
				   fp_cityname, fp_city, fp_state, fp_invoice_no, fp_charge_yn, fp_enteredby, fp_processeddt, fp_processedby,
					fp_status, fp_statusdate, fp_rebateamount, fp_nonbillableitem, fp_network_ts, fp_contractnum,  cfp_identity,
					 fp_prevodometer, fp_chaincode, fp_servicefee)
 
			select Distinct 'TC-' +Cast(p.folio as varchar(500)) as fp_id,
					1 as fp_sequence,
					 p.Tarjeta as fp_cardnumber,  
					'TC' as fp_cac_id,
					null as fp_ccd_id, 
					'TC' as asfp_purchcode,
					 CONVERT (datetime, p.FechaTransaccion, 103)   as fp_date, 
					p.litros as fp_quantity,
					'LTR' as fp_uom,
					'DSL' as fp_fueltype,
					'C' as fp_trc_trc,
					p.PrecioUnitario AS fp_cost_per,
					p.ImporteTransaccion as fp_amount, 
					null as ord_number,
					null as ord_hdrnumber,
					null as mov_number,
					null as lgh_number,
					null as stp_number,
					p.Unidad as trc_number,
					'UNKNOWN' AS trl_number,
					-- (select max(mpp.mpp_id) from manpowerprofile mpp where mpp.mpp_lastname +' ' + mpp.mpp_firstname = (select) ) as mpp_id,
					null as mpp_id,
					'UNKNOWN' as fp_owner,
					 null as fp_odometer,
					t.ts_code as ts_code,
					t.ts_name as fp_vendorname,
					t.ts_city as fp_cityname,
					t.ts_cty as fp_city,
					t.ts_state as fp_state, 
					null as fp_invoice_no, 
					null as fp_charge_yn,
					'TCDataService' as fp_enteredby,	
					null as fp_processeddt,
					null as fp_processedby,
					'NPD' as fp_status,
					null as fp_statusdate,
					null as fp_rebateamount,
					null as fp_nonbillableitem,
					null as fp_network_ts,
					null as fp_contractnum,
					null as cfp_identity,
					null as fp_prevodometer,
					'TC' as fp_chaincode,
					null as fp_servicefee 

		 from Fuel.[dbo].[purchase] p
			inner join  [dbo].[truckstops] t on p.estacion = t.ts_name
			where p.proveedor = 'TC-1'
			and p.Unidad in (select trc_number from tractorprofile)
			--and p.fechatransaccion >= (Select Convert(varchar, DATEADD(day,1,max(fp.fp_date)),103) from fuelpurchased fp where fp.fp_cac_id = 'TC')
			and folio not in(
	select folio  from Fuel.[dbo].[purchase] p
	inner join fuelpurchased fp on 'TC-'+cast(folio as varchar) = fp.fp_id )
	union

 		 select distinct 'TC-' +Cast(p.folio as varchar(500)) as fp_id,
					1 as fp_sequence,
					 p.Tarjeta as fp_cardnumber,  
					'TC' as fp_cac_id,
					null as fp_ccd_id, 
					'TC' as asfp_purchcode,
					 CONVERT (datetime, p.FechaTransaccion, 103)   as fp_date, 
					p.litros as fp_quantity,
					'LTR' as fp_uom,
					'DSL' as fp_fueltype,
					'C' as fp_trc_trc,
					p.PrecioUnitario AS fp_cost_per,
					p.ImporteTransaccion as fp_amount, 
					null as ord_number,
					null as ord_hdrnumber,
					null as mov_number,
					null as lgh_number,
					null as stp_number,
					p.Unidad as trc_number,
					'UNKNOWN' AS trl_number,
					-- (select max(mpp.mpp_id) from manpowerprofile mpp where mpp.mpp_lastname +' ' + mpp.mpp_firstname = (select) ) as mpp_id,
					null as mpp_id,
					'UNKNOWN' as fp_owner,
					 null as fp_odometer,
					t.ts_code as ts_code,
					t.ts_name as fp_vendorname,
					t.ts_city as fp_cityname,
					t.ts_cty as fp_city,
					t.ts_state as fp_state, 
					null as fp_invoice_no, 
					null as fp_charge_yn,
					'TCDataService' as fp_enteredby,	
					null as fp_processeddt,
					null as fp_processedby,
					'NPD' as fp_status,
					null as fp_statusdate,
					null as fp_rebateamount,
					null as fp_nonbillableitem,
					null as fp_network_ts,
					null as fp_contractnum,
					null as cfp_identity,
					null as fp_prevodometer,
					'TC' as fp_chaincode,
					null as fp_servicefee 


	from Fuel.[dbo].[purchase] p
	inner join  [dbo].[truckstops] t on  p.direccion like '%'+t.ts_city +' '+t.ts_zip_code +'%' and t.ts_name  like '%'+ right(p.estacion,3) + '%'
	where p.proveedor = 'TC-1'
	and p.Unidad in (select trc_number from tractorprofile)
	--and p.fechatransaccion >= (Select Convert(varchar, DATEADD(day,1,max(fp.fp_date)),103) from fuelpurchased fp where fp.fp_cac_id = 'TC')
	and folio not in(
	select folio  from Fuel.[dbo].[purchase] p
	inner join fuelpurchased fp on 'TC-'+cast(folio as varchar) = fp.fp_id )
	and folio not in (
	select p.folio
	from Fuel.[dbo].[purchase] p
	inner join  [dbo].[truckstops] t on p.estacion = t.ts_name
	where p.proveedor = 'TC-1'
	--and p.fechatransaccion >= (Select Convert(varchar, DATEADD(day,1,max(fp.fp_date)),103) from fuelpurchased fp where fp.fp_cac_id = 'TC')
	)
	order by 1 desc
	--UNION
	--	 select DISTINCT 'TC-' +Cast(p.folio as varchar(500)) as fp_id,
	--				1 as fp_sequence,
	--				 p.Tarjeta as fp_cardnumber,  
	--				'TC' as fp_cac_id,
	--				null as fp_ccd_id, 
	--				'TC' as asfp_purchcode,
	--				 CONVERT (datetime, p.FechaTransaccion, 103)   as fp_date, 
	--				p.litros as fp_quantity,
	--				'LTR' as fp_uom,
	--				'DSL' as fp_fueltype,
	--				'C' as fp_trc_trc,
	--				p.PrecioUnitario AS fp_cost_per,
	--				p.ImporteTransaccion as fp_amount, 
	--				null as ord_number,
	--				null as ord_hdrnumber,
	--				null as mov_number,
	--				null as lgh_number,
	--				null as stp_number,
	--				p.Unidad as trc_number,
	--				'UNKNOWN' AS trl_number,
	--				-- (select max(mpp.mpp_id) from manpowerprofile mpp where mpp.mpp_lastname +' ' + mpp.mpp_firstname = (select) ) as mpp_id,
	--				null as mpp_id,
	--				'UNKNOWN' as fp_owner,
	--				 null as fp_odometer,
	--				t.ts_code as ts_code,
	--				t.ts_name as fp_vendorname,
	--				t.ts_city as fp_cityname,
	--				t.ts_cty as fp_city,
	--				t.ts_state as fp_state, 
	--				null as fp_invoice_no, 
	--				null as fp_charge_yn,
	--				'TCDataService' as fp_enteredby,	
	--				null as fp_processeddt,
	--				null as fp_processedby,
	--				'NPD' as fp_status,
	--				null as fp_statusdate,
	--				null as fp_rebateamount,
	--				null as fp_nonbillableitem,
	--				null as fp_network_ts,
	--				null as fp_contractnum,
	--				null as cfp_identity,
	--				null as fp_prevodometer,
	--				'TC' as fp_chaincode,
	--				null as fp_servicefee 


	--from Fuel.[dbo].[purchase] p
	--inner join  [dbo].[truckstops] t on  t.ts_name = (select top 1 ts_name from truckstops where p.direccion like '%'+ts_zip_code+'%')
	--	where p.proveedor = 'TC-1'
	--and p.Unidad in (select trc_number from tractorprofile)
	----and p.fechatransaccion >= (Select Convert(varchar, DATEADD(day,1,max(fp.fp_date)),103) from fuelpurchased fp where fp.fp_cac_id = 'TC')
	--and folio not in(
	--select folio  from Fuel.[dbo].[purchase] p
	--inner join fuelpurchased fp on 'TC-'+cast(folio as varchar) = fp.fp_id )
	--and folio not in (
	--select p.folio
	--from Fuel.[dbo].[purchase] p
	--inner join  [dbo].[truckstops] t on p.estacion = t.ts_name
	--where p.proveedor = 'TC-1'
	----and p.fechatransaccion >= (Select Convert(varchar, DATEADD(day,1,max(fp.fp_date)),103) from fuelpurchased fp where fp.fp_cac_id = 'TC')
	--)
END
IF(@accion = 3)
BEGIN
	delete from Fuel.[dbo].[purchase] where folio in(
	select folio  from Fuel.[dbo].[purchase] p
	inner join fuelpurchased fp on 'TC-'+cast(folio as varchar) = fp.fp_id )

	update  Fuel.[dbo].[purchase]  set Estacion = 'Estacion No Localizada' where proveedor = 'TC-1' and unidad in (select trc_number from tractorprofile where trc_status <> 'OUT')

END
END




--select * from Fuel.[dbo].[purchase]  where proveedor = 'tc-1' order by 7,5 desc

--select * from fuelpurchased order by 7 desc


--update  Fuel.[dbo].[purchase]  set Estacion = 'SERVICIO CHACHAPA 12609       ' where proveedor = 'TC-1' and unidad in (select trc_number from tractorprofile where trc_status <> 'OUT')



--select * from truckstops where ts_name like '%canon%' or ts_zip_code = '25900'

--select estacion,direccion,UNIDAD,(select top 1 ts_name from truckstops 
--where p.direccion like '%'+ts_zip_code+'%'), count(*) 
--from Fuel.[dbo].[purchase] p  
--where proveedor = 'TC-1'  and unidad in (select trc_number from tractorprofile where trc_status <> 'OUT')
--group by estacion,direccion,UNIDAD
--order by 5 desc

GO
