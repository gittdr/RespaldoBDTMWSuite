SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Total_Year_2023_PalacioH_JC] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
    SELECT TOP 1
(SELECT COUNT(*) AS total FROM RtPlacioH WHERE fechaTimbrado is not null AND MONTH(try_CONVERT(DATETIME, fechaTimbrado)) = 01 AND YEAR(try_CONVERT(DATETIME, fechaTimbrado)) = '2023' GROUP BY MONTH(try_CONVERT(DATETIME, fechaTimbrado))) AS ENERO
FROM RtPlacioH        
END
GO
