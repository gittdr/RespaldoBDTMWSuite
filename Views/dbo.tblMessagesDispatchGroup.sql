SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

		
	CREATE VIEW [dbo].[tblMessagesDispatchGroup] 
	WITH SCHEMABINDING
	AS
	SELECT MAV.sn, ISNULL(TND.DispatchGroupSN,1) DispatchGroupSN
	FROM dbo.tblmessagesattachedview MAV
		left join dbo.tblTrucksAndDriversview TND on AttachedSN = TND.SN and AttachedType = TND.Type


GO
