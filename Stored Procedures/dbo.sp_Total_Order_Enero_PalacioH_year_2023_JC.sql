SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Total_Order_Enero_PalacioH_year_2023_JC] (@nfecha varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT COUNT(*) AS total,MONTH(try_CONVERT(DATETIME, fechaTimbrado)) AS MES FROM RtPlacioH WHERE fechaTimbrado is not null AND MONTH(try_CONVERT(DATETIME, fechaTimbrado)) = 01 AND YEAR(try_CONVERT(DATETIME, fechaTimbrado)) = @nfecha GROUP BY MONTH(try_CONVERT(DATETIME, fechaTimbrado))
END
GO
