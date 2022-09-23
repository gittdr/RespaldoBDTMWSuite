SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSNetworkFuelSiteUpdate]
		@efs_network_fuel_site_efs_truckstop varchar (4),
		@efs_network_fuel_site_efs_account varchar (6),
		@efs_network_fuel_site_efs_branch varchar (6),
		@efs_network_fuel_site_efs_name varchar (25),
		@efs_network_fuel_site_efs_address varchar (25),
		@efs_network_fuel_site_efs_city varchar (15),
		@efs_network_fuel_site_efs_state varchar (2),
		@efs_network_fuel_site_efs_zip5 varchar (5),
		@efs_network_fuel_site_efs_zip4 varchar (4),
		@efs_network_fuel_site_efs_truckstop_location varchar (25),
		@efs_network_fuel_site_efs_interstate varchar (3),
		@efs_network_fuel_site_efs_exit3 varchar (3),
		@efs_network_fuel_site_efs_exit4 varchar (1),
		@efs_network_fuel_site_efs_area_code varchar (3),
		@efs_network_fuel_site_efs_phone_exchange varchar (3),
		@efs_network_fuel_site_efs_phone_number varchar (4),
		@efs_network_fuel_site_efs_account_type varchar (1),
		@efs_network_fuel_site_efs_chain_id varchar (1),
		@efs_network_fuel_site_efs_chain_suffix varchar (1),
		@efs_network_fuel_site_efs_start_time varchar (4),
		@efs_network_fuel_site_efs_end_time varchar (4),
		@efs_network_fuel_site_efs_maximum_fuel varchar (3),
		@efs_network_fuel_site_efs_rack_average	decimal (18,6),
		@efs_network_fuel_site_efs_federal_tax decimal (18,6),
		@efs_network_fuel_site_efs_state_tax decimal (18,6),
		@efs_network_fuel_site_efs_freight decimal (18,6),
		@efs_network_fuel_site_efs_miscellaneous decimal (18,6),
		@efs_network_fuel_site_efs_sales_tax decimal (18,6),
		@efs_network_fuel_site_efs_plus	decimal (18,6),
		@efs_network_fuel_site_efs_total_cost decimal (18,6),
		@efs_network_fuel_site_efs_pump_price decimal (18,6),
		@efs_network_fuel_site_efs_savings_sign varchar (1),
		@efs_network_fuel_site_efs_savings decimal (18,6),
		@efs_network_fuel_site_efs_service_minor_repairs varchar (1),
		@efs_network_fuel_site_efs_service_tire_repair varchar (1),
		@efs_network_fuel_site_efs_service_truck_wash varchar (1),
		@efs_network_fuel_site_efs_service_scales varchar (1),
		@efs_network_fuel_site_efs_service_filler varchar (1),
		@efs_network_fuel_site_efs_service_showers varchar (1),
		@efs_network_fuel_site_efs_service_restaurant varchar (1),
		@efs_network_fuel_site_efs_service_deli varchar (1),
		@efs_network_fuel_site_efs_importbatch varchar (20)

AS

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

    UPDATE [efs_network_fuel_site]
    SET
	efs_name = @efs_network_fuel_site_efs_name,
	efs_address = @efs_network_fuel_site_efs_address,
	efs_city = @efs_network_fuel_site_efs_city,
	efs_state = @efs_network_fuel_site_efs_state,
	efs_zip5 = @efs_network_fuel_site_efs_zip5,
	efs_zip4 = @efs_network_fuel_site_efs_zip4,
	efs_truckstop_location = @efs_network_fuel_site_efs_truckstop_location,
	efs_interstate = @efs_network_fuel_site_efs_interstate,
	efs_exit3 = @efs_network_fuel_site_efs_exit3,
	efs_exit4 = @efs_network_fuel_site_efs_exit4,
	efs_area_code = @efs_network_fuel_site_efs_area_code,
	efs_phone_exchange = @efs_network_fuel_site_efs_phone_exchange,
	efs_phone_number = @efs_network_fuel_site_efs_phone_number,
	efs_account_type = @efs_network_fuel_site_efs_account_type,
	efs_chain_id = @efs_network_fuel_site_efs_chain_id,
	efs_chain_suffix = @efs_network_fuel_site_efs_chain_suffix,
	efs_start_time = @efs_network_fuel_site_efs_start_time,
	efs_end_time = @efs_network_fuel_site_efs_end_time,
	efs_maximum_fuel = @efs_network_fuel_site_efs_maximum_fuel,
	efs_rack_average = @efs_network_fuel_site_efs_rack_average,
	efs_federal_tax = @efs_network_fuel_site_efs_federal_tax,
	efs_state_tax = @efs_network_fuel_site_efs_state_tax,
	efs_freight = @efs_network_fuel_site_efs_freight,
	efs_miscellaneous = @efs_network_fuel_site_efs_miscellaneous,
	efs_sales_tax = @efs_network_fuel_site_efs_sales_tax,
	efs_plus = @efs_network_fuel_site_efs_plus,
	efs_total_cost = @efs_network_fuel_site_efs_total_cost,
	efs_pump_price = @efs_network_fuel_site_efs_pump_price,
	efs_savings_sign = @efs_network_fuel_site_efs_savings_sign,
	efs_savings = @efs_network_fuel_site_efs_savings,
	efs_service_minor_repairs = @efs_network_fuel_site_efs_service_minor_repairs,
	efs_service_tire_repair = @efs_network_fuel_site_efs_service_tire_repair,
	efs_service_truck_wash = @efs_network_fuel_site_efs_service_truck_wash,
	efs_service_scales = @efs_network_fuel_site_efs_service_scales,
	efs_service_showers = @efs_network_fuel_site_efs_service_showers,
	efs_service_restaurant = @efs_network_fuel_site_efs_service_restaurant,
	efs_service_deli = @efs_network_fuel_site_efs_service_deli,
	efs_importbatch = @efs_network_fuel_site_efs_importbatch,
	efs_updated_on = getdate (),
	efs_updated_by = user

    WHERE efs_truckstop = @efs_network_fuel_site_efs_truckstop
    AND	efs_account = @efs_network_fuel_site_efs_account
    AND	efs_branch = @efs_network_fuel_site_efs_branch

GO
GRANT EXECUTE ON  [dbo].[core_EFSNetworkFuelSiteUpdate] TO [public]
GO
