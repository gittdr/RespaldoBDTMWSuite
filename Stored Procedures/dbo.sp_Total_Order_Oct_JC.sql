SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Total_Order_Oct_JC]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT COUNT(*) AS total,MONTH(try_CONVERT(DATETIME, fechaTimbrado)) AS MES FROM Reporte_Timbradas WHERE fechaTimbrado is not null AND MONTH(try_CONVERT(DATETIME, fechaTimbrado)) = 8 GROUP BY MONTH(try_CONVERT(DATETIME, fechaTimbrado))
END
GO
