SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Total_Order_TA_Penafiel_JC]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT COUNT(*) as total FROM RtPenafiel WHERE fechaTimbrado !='null' AND estatus in ('1','2','9')
END
GO
