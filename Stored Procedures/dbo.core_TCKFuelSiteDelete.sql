SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_TCKFuelSiteDelete] @tck_fuel_site_tfs_site_number varchar (10)
AS
	DELETE FROM [tck_fuel_site] 
	WHERE tfs_site_number = @tck_fuel_site_tfs_site_number

GO
GRANT EXECUTE ON  [dbo].[core_TCKFuelSiteDelete] TO [public]
GO
