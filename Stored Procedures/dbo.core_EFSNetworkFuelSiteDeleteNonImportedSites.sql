SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSNetworkFuelSiteDeleteNonImportedSites]
    @efs_network_fuel_site_efs_account varchar (6),
    @efs_network_fuel_site_efs_branch varchar (6),
    @efs_network_fuel_site_efs_importbatch varchar(20)
AS
	DELETE FROM efs_network_fuel_site
	WHERE efs_account = @efs_network_fuel_site_efs_account
	AND efs_branch = @efs_network_fuel_site_efs_branch
	AND IsNull (efs_importbatch, '') <> @efs_network_fuel_site_efs_importbatch

	SELECT 1 As result


GO
GRANT EXECUTE ON  [dbo].[core_EFSNetworkFuelSiteDeleteNonImportedSites] TO [public]
GO
