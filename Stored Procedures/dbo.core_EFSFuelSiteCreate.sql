SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSFuelSiteCreate]
		@efs_fuel_site_efs_truckstop varchar (4),
		@efs_fuel_site_efs_chain_id varchar (2),
		@efs_fuel_site_efs_name varchar (25),
		@efs_fuel_site_efs_address varchar (25),
		@efs_fuel_site_efs_city varchar (18),
		@efs_fuel_site_efs_state varchar (2),
		@efs_fuel_site_efs_zip varchar (5),
		@efs_fuel_site_efs_phone varchar (10),
		@efs_fuel_site_efs_time_zone varchar (1),
		@efs_fuel_site_efs_importbatch varchar (20)
AS

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

INSERT INTO [efs_fuel_site] (
    	efs_truckstop,
	efs_chain_id,
	efs_name,
	efs_address,
	efs_city,
	efs_state,
	efs_zip,
	efs_phone,
	efs_time_zone,
	efs_importbatch,
	efs_updated_on,
	efs_updated_by,
	efs_created_date)
VALUES (@efs_fuel_site_efs_truckstop,
	@efs_fuel_site_efs_chain_id,
	@efs_fuel_site_efs_name,
	@efs_fuel_site_efs_address,
	@efs_fuel_site_efs_city,
	@efs_fuel_site_efs_state,
	@efs_fuel_site_efs_zip,
	@efs_fuel_site_efs_phone,
	@efs_fuel_site_efs_time_zone,
	@efs_fuel_site_efs_importbatch,
	getdate (),
	@tmwuser,
	getdate ()
)

SELECT efs_updated_on as CreatedOn
FROM [efs_fuel_site]
WHERE 	efs_truckstop = @efs_fuel_site_efs_truckstop

GO
GRANT EXECUTE ON  [dbo].[core_EFSFuelSiteCreate] TO [public]
GO
