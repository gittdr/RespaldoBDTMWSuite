SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_TCKFuelSiteExists]
		@tck_fuel_site_tfs_site_number varchar (10)
AS
	IF Exists (	SELECT tfs_site_number
			FROM [tck_fuel_site] 
			WHERE tfs_site_number = @tck_fuel_site_tfs_site_number)
	Begin
		select cast (1 as bit)
	End
	Else Begin
		select cast (0 as bit)
	End

GO
GRANT EXECUTE ON  [dbo].[core_TCKFuelSiteExists] TO [public]
GO
