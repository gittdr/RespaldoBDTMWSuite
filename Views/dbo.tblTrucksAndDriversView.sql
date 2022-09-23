SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

	CREATE VIEW [dbo].[tblTrucksAndDriversView] 
	WITH SCHEMABINDING
	AS
		SELECT SN,'TRC' AS Type, CurrentDispatcher AS DispatchGroupSN
		FROM dbo.tblTrucks
		UNION SELECT SN,'DRV', CurrentDispatcher AS DispatchGroupSN
		FROM dbo.tblDrivers
		
GO
