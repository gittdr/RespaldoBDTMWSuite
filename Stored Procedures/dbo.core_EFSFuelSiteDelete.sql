SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSFuelSiteDelete]
	@efs_fuel_site_efs_truckstop varchar (4)
AS
	DELETE FROM [efs_fuel_site] 
	WHERE efs_truckstop = @efs_fuel_site_efs_truckstop

GO
GRANT EXECUTE ON  [dbo].[core_EFSFuelSiteDelete] TO [public]
GO
