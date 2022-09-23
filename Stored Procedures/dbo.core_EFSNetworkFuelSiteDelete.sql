SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_EFSNetworkFuelSiteDelete]
		@efs_network_fuel_site_efs_truckstop varchar (4)
AS
	Delete FROM [efs_network_fuel_site] 
	WHERE efs_truckstop = @efs_network_fuel_site_efs_truckstop

GO
GRANT EXECUTE ON  [dbo].[core_EFSNetworkFuelSiteDelete] TO [public]
GO
