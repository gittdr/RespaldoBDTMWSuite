SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Total_Order_Procesadas_Penafiel_JC]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT COUNT(*) as total FROM RtPenafiel
END
GO
