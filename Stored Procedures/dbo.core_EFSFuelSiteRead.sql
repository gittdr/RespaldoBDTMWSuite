SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSFuelSiteRead]
	@efs_fuel_site_efs_truckstop varchar (4)
AS
	SELECT  efs_truckstop as efs_fuel_site_efs_truckstop,
		efs_chain_id as efs_fuel_site_efs_chain_id,
		efs_name as efs_fuel_site_efs_name,
		efs_address as efs_fuel_site_efs_address,
		efs_city as efs_fuel_site_efs_city,
		efs_state as efs_fuel_site_efs_state,
		efs_zip as efs_fuel_site_efs_zip,
		efs_phone as efs_fuel_site_efs_phone,
		efs_time_zone as efs_fuel_site_efs_time_zone,
		efs_importbatch as efs_fuel_site_efs_importbatch
	FROM [efs_fuel_site] 
	WHERE efs_truckstop = @efs_fuel_site_efs_truckstop
GO
GRANT EXECUTE ON  [dbo].[core_EFSFuelSiteRead] TO [public]
GO
