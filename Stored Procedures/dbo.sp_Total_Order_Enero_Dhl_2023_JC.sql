SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Total_Order_Enero_Dhl_2023_JC]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT COUNT(*) AS total,MONTH(try_CONVERT(DATETIME, fechaTimbrado)) AS MES FROM RtDhl WHERE fechaTimbrado is not null AND MONTH(try_CONVERT(DATETIME, fechaTimbrado)) = 01 GROUP BY MONTH(try_CONVERT(DATETIME, fechaTimbrado))
END
GO
