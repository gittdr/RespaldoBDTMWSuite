SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Total_Order_C_JC]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT COUNT(*) as total FROM Reporte_Timbradas WHERE segmento IS NULL OR fechaTimbrado = 'null'
END

GO
