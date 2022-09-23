SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSFuelSiteExists]
		@efs_fuel_site_efs_truckstop varchar (4)
AS
	IF Exists (	SELECT efs_truckstop
			FROM [efs_fuel_site] 
			WHERE efs_truckstop = @efs_fuel_site_efs_truckstop)
	Begin
		select cast (1 as bit)
	End
	Else Begin
		select cast (0 as bit)
	End

GO
GRANT EXECUTE ON  [dbo].[core_EFSFuelSiteExists] TO [public]
GO
