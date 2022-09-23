SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Fuel_exxia] (@id varchar(500), @fecha varchar(500), @camion varchar(500), @TagId varchar(500), @Store varchar(500), @Gasolinera varchar(500), @Conductor varchar(500), @Carga varchar(500), @Km varchar(500), @PPLT varchar(500), @PrecioCompetencia varchar(500), @Ahorro varchar(500), @Total varchar(500), @Facturado varchar(500), @MovID varchar(500), @accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	IF(@accion = 1)
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

		-- Insert statements for procedure here
		insert into [dbo].[FuelExxia](id, fecha, camion, TagId, Store, Gasolinera, Conductor, Carga, Km, PPLT, PrecioCompetencia, Ahorro, Total, Facturado, MovID)
		values(@id, @fecha, @camion, @TagId, @Store, @Gasolinera, @Conductor, @Carga, case when @Km = '' then null else @Km end, @PPLT, @PrecioCompetencia, @Ahorro, @Total, @Facturado, @MovID)
	END
	IF(@accion = 2)
	BEGIN
	insert into [dbo].[fuelpurchased](fp_id, fp_sequence, fp_cardnumber, fp_cac_id, fp_ccd_id, fp_purchcode, fp_date,
			 fp_quantity, fp_uom, fp_fueltype, fp_trc_trl, fp_cost_per, fp_amount, ord_number, ord_hdrnumber, mov_number,
			  lgh_number, stp_number, trc_number, trl_number, mpp_id, fp_owner, fp_odometer, ts_code, fp_vendorname,
			   fp_cityname, fp_city, fp_state, fp_invoice_no, fp_charge_yn, fp_enteredby, fp_processeddt, fp_processedby,
			    fp_status, fp_statusdate, fp_rebateamount, fp_nonbillableitem, fp_network_ts, fp_contractnum,  cfp_identity,
				 fp_prevodometer, fp_chaincode, fp_servicefee)

		 select distinct case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'AMX-' + id
				when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'AQRO-' + id 
				when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'APUE-' + id 
				when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'AMTY-' + id 
				when Fex.Gasolinera like '%Tdr Villahermosa%' then 'AVIL-' + id
				else id end as fp_id,
				1 as fp_sequence, Fex.TagId as fp_cardnumber,  
		   case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'AMX'
				when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'AQRO' 
				when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'APUE' 
				when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'AMTY'
				when Fex.Gasolinera like '%Tdr Villahermosa' then 'AVIL'
				else null end as fp_cac_id,
				null as fp_ccd_id, 
		   case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'AMX'
				when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'AQRO' 
				when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'APUE' 
				when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'AMTY'
				when Fex.Gasolinera like '%Tdr Villahermosa' then 'AVIL'
				else null end asfp_purchcode,
				Fex.fecha as fp_date, 
				carga as fp_quantity,
				'LTR' as fp_uom,
				'DSL' as fp_fueltype,
				'C' as fp_trc_trc,
				PPLT AS fp_cost_per,
				Total as fp_amount, 
				null as ord_number,
				null as ord_hdrnumber,
				null as mov_number,
				null as lgh_number,
				null as stp_number,
				camion as trc_number,
				'UNKNOWN' AS trl_number,
				 (select max(mpp.mpp_id) from manpowerprofile mpp where mpp.mpp_lastname +' ' + mpp.mpp_firstname = Conductor ) as mpp_id,
				'UNKNOWN' as fp_owner,
				 Fex.Km as fp_odometer,
				 case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'TDRMEX'
					when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'TDRQRO' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'TDRPUE' 
					when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'TDRMTY'
					when Fex.Gasolinera like '%Tdr Villahermosa' then 'TDRVILL'
					else null end as ts_code,
				 case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'AUTOABASTO TDR MEX'
					when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'AUTOABASTO TDR QRO' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'AUTOABASTO TDR PUE' 
					when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'AUTOABASTO TDR MTY'
					when Fex.Gasolinera like '%Tdr Villahermosa' then 'AUTOABASTO TDR VILL'
					else null end as fp_vendorname,
				  case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'CUAUTITLAN IZCALLI'
					when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'EL MARQUES' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'CUAUTLANCINGO' 
					when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'APODACA'
					when Fex.Gasolinera like '%Tdr Villahermosa' then 'VILLAHERMOSA'
					else null end as fp_cityname,
				 case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then '80884'
					when Fex.Gasolinera = 'TDR, Tdr Queretaro' then '81903' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then '81716' 
					when Fex.Gasolinera LIKE '%Quimica Delta, Tdr Monterrey' then '81060' 
					when Fex.Gasolinera LIKE '%Tdr Villahermosa' then '14952' 
					else null end as fp_city,
				 case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'EM'
				    when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'QA' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'PU' 
					when Fex.Gasolinera LIKE '%Quimica Delta, Tdr Monterrey' then 'NX'
					when Fex.Gasolinera LIKE '%Tdr Villahermosa' then 'TA' 
					else null end as fp_state, 
				null as fp_invoice_no, 
				null as fp_charge_yn,
				'ExxiaWS' as fp_enteredby,	
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
				 case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'AMX'
				when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'AQRO' 
				when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'APUE' 
				when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'AMTY'
				when Fex.Gasolinera LIKE '%Tdr Villahermosa' then 'AVIL' 
				else null end fp_chaincode,
				null as fp_servicefee 
	 from [dbo].[FuelExxia] Fex
	 inner join tractorprofile tpf on  Fex.camion = tpf.trc_number
	where tpf.trc_status <> 'OUT' and fecha >= '2018-10-01' and
	'AQRO-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and 
	'AMX-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and
	'APUE-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and
	'AMTY-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) AND 
	'AVIL-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased])
	and Fex.Gasolinera <> 'QUIMICA DELTA'  AND  Fex.Gasolinera <> 'PIPA 304' and Fex.Gasolinera like '%TDR%' 
	
	END
	IF(@accion = 3)
	BEGIN
		delete [dbo].[FuelExxia]
	END
	IF(@accion = 3)
	BEGIN
		update
			fuelpurchased
			set fuelpurchased.fp_cost_per =

			 (select fp.fp_cost_per from fuelpurchased fp where fp.fp_cac_id = fuelpurchased.fp_cac_id and fp_cost_per <> '0.00' and fp_amount <>  '0.00' and fp_date = (select MAX(fp.fp_date) from fuelpurchased fp where fp.fp_cac_id = fuelpurchased.fp_cac_id and fp_cost_per <> '0.00' and fp_amount <>  '0.00') )
			,
			fuelpurchased.fp_amount =
			 (select fp.fp_cost_per from fuelpurchased fp where fp.fp_cac_id = fuelpurchased.fp_cac_id and fp_cost_per <> '0.00' and fp_amount <>  '0.00' and fp_date = (select MAX(fp.fp_date) from fuelpurchased fp where fp.fp_cac_id = fuelpurchased.fp_cac_id and fp_cost_per <> '0.00' and fp_amount <>  '0.00') ) * fp_quantity

			where fp_cost_per = '0.00' and fp_amount =  '0.00'
	END
	IF(@accion = 4)
	BEGIN
	insert into [dbo].[fuelpurchased](fp_id, fp_sequence, fp_cardnumber, fp_cac_id, fp_ccd_id, fp_purchcode, fp_date,
			 fp_quantity, fp_uom, fp_fueltype, fp_trc_trl, fp_cost_per, fp_amount, ord_number, ord_hdrnumber, mov_number,
			  lgh_number, stp_number, trc_number, trl_number, mpp_id, fp_owner, fp_odometer, ts_code, fp_vendorname,
			   fp_cityname, fp_city, fp_state, fp_invoice_no, fp_charge_yn, fp_enteredby, fp_processeddt, fp_processedby,
			    fp_status, fp_statusdate, fp_rebateamount, fp_nonbillableitem, fp_network_ts, fp_contractnum,  cfp_identity,
				 fp_prevodometer, fp_chaincode, fp_servicefee)
		 select distinct case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'AMX-' + id
				when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'AQRO-' + id 
				when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'APUE-' + id 
				when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'AMTY-' + id 
				when Fex.Gasolinera like '%tepeji%' then 'NIETTEP-' + id 
				when Fex.Gasolinera like '%PLANTA GUADALAJARA%' then 'NIETGUA-' + id 
				when Fex.Gasolinera like '%Planta Hermosillo%' then 'NIETHER-' + id 
				when Fex.Gasolinera like '%LOS ANGELES%' then 'PERC-' + id 
				when Fex.Gasolinera like '%Planta Culiacan%' then 'NIETCUL-' + id 
				when Fex.Gasolinera like '%Planta Cd. Juarez%' then 'NIETCDJ-' + id 
				when Fex.Gasolinera like '%Planta Chihuahua%' then 'NIETCHI-' + id 
				else id end as fp_id,
				1 as fp_sequence, Fex.TagId as fp_cardnumber,  
		   case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'AMX'
				when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'AQRO' 
				when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'APUE' 
				when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'AMTY'
				when Fex.Gasolinera like '%tepeji%' then 'ANIET' 
				when Fex.Gasolinera like '%PLANTA GUADALAJARA%' then 'ANIET' 
				when Fex.Gasolinera like '%Planta Hermosillo%' then 'ANIET' 
				when Fex.Gasolinera like '%LOS ANGELES%' then 'PERC' 
				when Fex.Gasolinera like '%Planta Culiacan%' then 'ANIET' 
				when Fex.Gasolinera like '%Planta Cd. Juarez%' then 'ANIET'
				when Fex.Gasolinera like '%Planta Chihuahua' then 'ANIET'
				else null end as fp_cac_id,
				null as fp_ccd_id, 
		   case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'AMX'
				when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'AQRO' 
				when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'APUE' 
				when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'AMTY'
				when Fex.Gasolinera like '%tepeji%' then 'ANIET' 
				when Fex.Gasolinera like '%PLANTA %' then 'ANIET' 
				when Fex.Gasolinera like '%LOS ANGELES%' then 'PERC' 
				else null end asfp_purchcode,
				Replace(Fex.fecha, 'T',' ') as fp_date,
				carga as fp_quantity,
				'LTR' as fp_uom,
				'DSL' as fp_fueltype,
				'C' as fp_trc_trc,
				PPLT AS fp_cost_per,
				Total as fp_amount, 
				null as ord_number,
				null as ord_hdrnumber,
				null as mov_number,
				null as lgh_number,
				null as stp_number,
				Replace(camion, 'TDR','') as trc_number,
				'UNKNOWN' AS trl_number,
				 (select max(mpp.mpp_id) from manpowerprofile mpp where mpp.mpp_lastname +' ' + mpp.mpp_firstname = Conductor ) as mpp_id,
				'UNKNOWN' as fp_owner,
				 case when Fex.Gasolinera like '%LOS ANGELES%' then null else Fex.Km end as fp_odometer,
				 case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'TDRMEX'
					when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'TDRQRO' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'TDRPUE' 
					when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'TDRMTY'
					when Fex.Gasolinera like '%tepeji%' then 'NIETTEP' 
					when Fex.Gasolinera like '%PLANTA GUADALAJARA%' then 'NIETGUA' 
					when Fex.Gasolinera like '%Planta Hermosillo%' then 'NIETHER' 
					when Fex.Gasolinera like '%LOS ANGELES%' then '154615' 
					when Fex.Gasolinera like '%Planta Culiacan%' then 'NIETCUL'
					when Fex.Gasolinera like '%Planta Cd. Juarez%' then 'NIETCDJ'
					when Fex.Gasolinera like '%Planta Chihuahua%' then 'NIETCHI'
					else null end as ts_code,
				 case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'AUTOABASTO TDR MEX'
					when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'AUTOABASTO TDR QRO' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'AUTOABASTO TDR PUE' 
					when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'AUTOABASTO TDR MTY'
					when Fex.Gasolinera like '%tepeji%' then 'SERVICIO NIETO Tepeji' 
					when Fex.Gasolinera like '%PLANTA GUADALAJARA%' then 'SERVICIO NIETO Guadalajara' 
					when Fex.Gasolinera like '%Planta Hermosillo%' then 'SERVICIO NIETO Hermosillo' 
					when Fex.Gasolinera like '%LOS ANGELES%' then 'LOS ANGELES 7356' 
					when Fex.Gasolinera like '%Planta Culiacan%' then 'SERVICIO NIETO Planta Culiacan'
					when Fex.Gasolinera like '%Planta Cd. Juarez%' then 'SERVICIO NIETO Planta CD Juarez'
					when Fex.Gasolinera like '%Planta Chihuahua%' then 'SERVICIO NIETO Planta Chihuahua'

					else null end as fp_vendorname,
				  case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'CUAUTITLAN IZCALLI'
					when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'EL MARQUES' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'CUAUTLANCINGO' 
					when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'APODACA'
					when Fex.Gasolinera like '%tepeji%' then 'TEPEJI DEL RIO' 
					when Fex.Gasolinera like '%PLANTA GUADALAJARA%' then 'TLAQUEPAQUE'
					when Fex.Gasolinera like '%Planta Hermosillo%' then 'HERMOSILLO' 
					when Fex.Gasolinera like '%LOS ANGELES%' then 'PEDRO ESCOBEDO' 
					when Fex.Gasolinera like '%Planta Culiacan%' then 'CULIACAN'
					when Fex.Gasolinera like '%Planta Cd. Juarez%' then 'CD Juarez'
					when Fex.Gasolinera like '%Planta Chihuahua%' then 'Chihuahua'
					else null end as fp_cityname,
				 case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then '80884'
					when Fex.Gasolinera = 'TDR, Tdr Queretaro' then '81903' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then '81716' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Monterrey' then '81060' 
					when Fex.Gasolinera like '%tepeji%' then '64802' 
					when Fex.Gasolinera like '%PLANTA GUADALAJARA%' then '80736' 
					when Fex.Gasolinera like '%Planta Hermosillo%' then '14019' 
					when Fex.Gasolinera like '%LOS ANGELES%' then '15420' 
					when Fex.Gasolinera like '%Planta Culiacan%' then '15145'
					when Fex.Gasolinera like '%Planta Cd. Juarez%' then '80235'
					when Fex.Gasolinera like '%Planta Chihuahua%' then '72911'

					else null end as fp_city,
				 case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'EM'
				    when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'QA' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'PU' 
					when Fex.Gasolinera = 'Quimica Delta, Tdr Monterrey' then 'NX'
					when Fex.Gasolinera like '%tepeji%' then 'HG' 
					when Fex.Gasolinera like '%PLANTA GUADALAJARA%' then 'JA'
					when Fex.Gasolinera like '%Planta Hermosillo%' then 'SO' 
					when Fex.Gasolinera like '%LOS ANGELES%' then 'QA' 
					when Fex.Gasolinera like '%Planta Culiacan%' then 'SI' 
					when Fex.Gasolinera like '%Planta Cd. Juarez%' then 'CH'
					when Fex.Gasolinera like '%Planta Chihuahua%' then 'CH'
					else null end as fp_state, 
				null as fp_invoice_no, 
				null as fp_charge_yn,
				'NietoWS' as fp_enteredby,	
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
				 case when Fex.Gasolinera = 'TDR, Tdr Cuautitlan' then 'AMX'
				when Fex.Gasolinera = 'TDR, Tdr Queretaro' then 'AQRO' 
				when Fex.Gasolinera = 'Quimica Delta, Tdr Puebla' then 'APUE' 
				when Fex.Gasolinera like '%Quimica Delta, Tdr Monterrey' then 'AMTY'
				when Fex.Gasolinera like '%tepeji%' then 'ANIET' 
				when Fex.Gasolinera like '%PLANTA GUADALAJARA%' then 'ANIET' 
				when Fex.Gasolinera like '%PLANTA %' then 'ANIET' 
				when Fex.Gasolinera like '%LOS ANGELES%' then 'PERC'
				else null end fp_chaincode,
				null as fp_servicefee 
	from [dbo].[FuelExxia] Fex
	 inner join tractorprofile tpf on REPLACE(Fex.camion,'TDR','') = tpf.trc_number
	where tpf.trc_status <> 'OUT' and fecha >= '2018-10-01' and
	'AQRO-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and 
	'AMX-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and
	'APUE-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and
	'AMTY-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and
	'NIETTEP-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and
	'NIETGUA-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and
	'PERC-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and
	'NIETHER-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and
	'NIETCUL-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and
	'NIETCDJ-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased]) and
	'NIETCHI-'+Fex.id not in (select fp_id from [dbo].[fuelpurchased])

	and Fex.Gasolinera <> 'QUIMICA DELTA'  AND  Fex.Gasolinera <> 'PIPA 304' 
	
	END
	IF(@accion = 5)
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

		-- Insert statements for procedure here
		insert into [dbo].[FuelExxia](id, fecha, camion, TagId, Store, Gasolinera, Conductor, Carga, Km, PPLT, PrecioCompetencia, Ahorro, Total, Facturado, MovID)
		values(@id, @fecha, (select trc_number from tractorprofile where trc_licnum = @camion) , @TagId, @Store, @Gasolinera, @Conductor, @Carga, @Km, @PPLT, @PrecioCompetencia, @Ahorro, @Total, @Facturado, @MovID)
	END
	
END

GO
