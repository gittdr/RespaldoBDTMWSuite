SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_TCKFuelSiteCreate]
		@tck_fuel_site_tfs_site_number varchar (10),
		@tck_fuel_site_tfs_site_type varchar (2),
		@tck_fuel_site_tfs_site_name varchar (46),
		@tck_fuel_site_tfs_network_flag char (1),
		@tck_fuel_site_tfs_physical_address varchar (30),
		@tck_fuel_site_tfs_physical_city varchar (30),
		@tck_fuel_site_tfs_physical_state varchar (2),
		@tck_fuel_site_tfs_physical_postal_code varchar (10),
		@tck_fuel_site_tfs_physical_country_code varchar (3),
		@tck_fuel_site_tfs_phone varchar (12),
		@tck_fuel_site_tfs_fax varchar (12),
		@tck_fuel_site_tfs_site_manager varchar (30),
		@tck_fuel_site_tfs_longitude varchar (8),
		@tck_fuel_site_tfs_longitude_direction char (1),
		@tck_fuel_site_tfs_latitude varchar (8),
		@tck_fuel_site_tfs_latitude_direction char (1),
		@tck_fuel_site_tfs_importbatch varchar (20)
AS

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

INSERT INTO [tck_fuel_site] (
    	tfs_site_number,
	tfs_site_type,
	tfs_site_name,
	tfs_network_flag,
	tfs_physical_address,
	tfs_physical_city,
	tfs_physical_state,
	tfs_physical_postal_code,
	tfs_physical_country_code,
	tfs_phone,
	tfs_fax,
	tfs_site_manager,
	tfs_longitude,
	tfs_longitude_direction,
	tfs_latitude,
	tfs_latitude_direction,
	tfs_importbatch,
	tfs_updated_on,
	tfs_updated_by,
	tfs_created_date)
VALUES (@tck_fuel_site_tfs_site_number,
	@tck_fuel_site_tfs_site_type,
	@tck_fuel_site_tfs_site_name,
	@tck_fuel_site_tfs_network_flag,
	@tck_fuel_site_tfs_physical_address,
	@tck_fuel_site_tfs_physical_city,
	@tck_fuel_site_tfs_physical_state,
	@tck_fuel_site_tfs_physical_postal_code,
	@tck_fuel_site_tfs_physical_country_code,
	@tck_fuel_site_tfs_phone,
	@tck_fuel_site_tfs_fax,
	@tck_fuel_site_tfs_site_manager,
	@tck_fuel_site_tfs_longitude,
	@tck_fuel_site_tfs_longitude_direction,
	@tck_fuel_site_tfs_latitude,
	@tck_fuel_site_tfs_latitude_direction,
	@tck_fuel_site_tfs_importbatch,
	getdate (),
	@tmwuser,
	getdate ()
)

SELECT tfs_updated_on as CreatedOn
FROM [tck_fuel_site]
WHERE 	tfs_site_number = @tck_fuel_site_tfs_site_number

GO
GRANT EXECUTE ON  [dbo].[core_TCKFuelSiteCreate] TO [public]
GO
