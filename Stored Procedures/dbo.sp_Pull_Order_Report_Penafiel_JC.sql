SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Pull_Order_Report_Penafiel_JC] (@orden varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        INSERT INTO RtPenafiel(orden) VALUES(@orden)
END
GO
