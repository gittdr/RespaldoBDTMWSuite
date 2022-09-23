SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSNetworkFuelSiteRead]
	@efs_network_fuel_site_efs_truckstop varchar (4)
AS
	SELECT  efs_truckstop as efs_network_fuel_site_efs_truckstop,
		efs_account as efs_network_fuel_site_efs_account,
		efs_branch as efs_network_fuel_site_efs_branch,
		efs_name as efs_network_fuel_site_efs_name,
		efs_address as efs_network_fuel_site_efs_address,
		efs_city as efs_network_fuel_site_efs_city,
		efs_state as efs_network_fuel_site_efs_state,
		efs_zip5 as efs_network_fuel_site_efs_zip5,
		efs_zip4 as efs_network_fuel_site_efs_zip4,
		efs_truckstop_location as efs_network_fuel_site_efs_truckstop_location,
		efs_interstate as efs_network_fuel_site_efs_interstate,
		efs_exit3 as efs_network_fuel_site_efs_exit3,
		efs_exit4 as efs_network_fuel_site_efs_exit4,
		efs_area_code as efs_network_fuel_site_efs_area_code,
		efs_phone_exchange as efs_network_fuel_site_efs_phone_exchange,
		efs_phone_number as efs_network_fuel_site_efs_phone_number,
		efs_account_type as efs_network_fuel_site_efs_account_type,
		efs_chain_id as efs_network_fuel_site_efs_chain_id,
		efs_chain_suffix as efs_network_fuel_site_efs_chain_suffix,
		efs_start_time as efs_network_fuel_site_efs_start_time,
		efs_end_time as efs_network_fuel_site_efs_end_time,
		efs_maximum_fuel as efs_network_fuel_site_efs_maximum_fuel,
		efs_rack_average as efs_network_fuel_site_efs_rack_average,
		efs_federal_tax as efs_network_fuel_site_efs_federal_tax,
		efs_state_tax as efs_network_fuel_site_efs_state_tax,
		efs_freight as efs_network_fuel_site_efs_freight,
		efs_miscellaneous as efs_network_fuel_site_efs_miscellaneous,
		efs_sales_tax as efs_network_fuel_site_efs_sales_tax,
		efs_plus as efs_network_fuel_site_efs_plus,
		efs_total_cost as efs_network_fuel_site_efs_total_cost,
		efs_pump_price as efs_network_fuel_site_efs_pump_price,
		efs_savings_sign as efs_network_fuel_site_efs_savings_sign,
		efs_savings as efs_network_fuel_site_efs_savings,
		efs_service_minor_repairs as efs_network_fuel_site_efs_service_minor_repairs,
		efs_service_tire_repair as efs_network_fuel_site_efs_service_tire_repair,
		efs_service_truck_wash as efs_network_fuel_site_efs_service_truck_wash,
		efs_service_scales as efs_network_fuel_site_efs_service_scales,
		efs_service_filler as efs_network_fuel_site_efs_service_filler,
		efs_service_showers as efs_network_fuel_site_efs_service_showers,
		efs_service_restaurant as efs_network_fuel_site_efs_service_restaurant,
		efs_service_deli as efs_network_fuel_site_efs_service_deli,
		efs_importbatch as efs_network_fuel_site_efs_importbatch
	FROM [efs_network_fuel_site] 
	WHERE efs_truckstop = @efs_network_fuel_site_efs_truckstop
GO
GRANT EXECUTE ON  [dbo].[core_EFSNetworkFuelSiteRead] TO [public]
GO
