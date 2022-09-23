SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_TCKFuelSiteDeleteNonImportedSites]
    @tck_fuel_site_tfs_importbatch varchar(20)
AS
	DELETE FROM tck_fuel_site 
	WHERE IsNull (tfs_importbatch, '') <> @tck_fuel_site_tfs_importbatch

	SELECT 1 As result


GO
GRANT EXECUTE ON  [dbo].[core_TCKFuelSiteDeleteNonImportedSites] TO [public]
GO
