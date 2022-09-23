SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSFuelSiteDeleteNonImportedSites]
    @efs_fuel_site_efs_importbatch varchar(20)
AS
	DELETE FROM efs_fuel_site 
	WHERE IsNull (efs_importbatch, '') <> @efs_fuel_site_efs_importbatch

	SELECT 1 As result


GO
GRANT EXECUTE ON  [dbo].[core_EFSFuelSiteDeleteNonImportedSites] TO [public]
GO
