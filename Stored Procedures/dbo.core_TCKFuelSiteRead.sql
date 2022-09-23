SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_TCKFuelSiteRead]
	@tck_fuel_site_tfs_site_number varchar (10)
AS
	SELECT  tfs_site_number as tck_fuel_site_tfs_site_number,
		tfs_site_type  as tck_fuel_site_tfs_site_type,
		tfs_site_name  as tck_fuel_site_tfs_site_name,
		tfs_network_flag as tck_fuel_site_tfs_network_flag,
		tfs_physical_address as tck_fuel_site_tfs_physical_address,
		tfs_physical_city as tck_fuel_site_tfs_physical_city,
		tfs_physical_state as tck_fuel_site_tfs_physical_state,
		tfs_physical_postal_code as tck_fuel_site_tfs_physical_postal_code,
		tfs_physical_country_code as tck_fuel_site_tfs_physical_country_code,
		tfs_phone as tck_fuel_site_tfs_phone,
		tfs_fax as tck_fuel_site_tfs_fax,
		tfs_site_manager as tck_fuel_site_tfs_site_manager,
		tfs_longitude as tck_fuel_site_tfs_longitude,
		tfs_longitude_direction as tck_fuel_site_tfs_longitude_direction,
		tfs_latitude as tck_fuel_site_tfs_latitude,
		tfs_latitude_direction as tck_fuel_site_tfs_latitude_direction,
		tfs_importbatch as tck_fuel_site_tfs_importbatch
	FROM [tck_fuel_site] 
	WHERE tfs_site_number = @tck_fuel_site_tfs_site_number

GO
GRANT EXECUTE ON  [dbo].[core_TCKFuelSiteRead] TO [public]
GO
