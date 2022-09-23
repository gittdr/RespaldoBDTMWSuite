SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Pull_Order_Report] (@orden varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        INSERT INTO Reporte_Timbradas(orden) VALUES(@orden)
END
GO
