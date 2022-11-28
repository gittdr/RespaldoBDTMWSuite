SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Total_Year_2022_Diciembre_JC] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
    SELECT orden, segmento, billto, fechaTimbrado FROM Reporte_Timbradas WHERE fechaTimbrado is not null AND MONTH(try_CONVERT(DATETIME, fechaTimbrado)) = 12 AND YEAR(try_CONVERT(DATETIME, fechaTimbrado)) = '2022' GROUP BY orden, segmento, billto, fechaTimbrado ORDER BY fechaTimbrado DESC         
END
GO
