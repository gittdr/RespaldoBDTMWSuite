SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Total_Year_2022_Penafiel_JC] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
    SELECT TOP 1
(SELECT COUNT(*) AS total FROM RtPenafiel WHERE fechaTimbrado is not null AND MONTH(try_CONVERT(DATETIME, fechaTimbrado)) = 08 AND YEAR(try_CONVERT(DATETIME, fechaTimbrado)) = '2022' GROUP BY MONTH(try_CONVERT(DATETIME, fechaTimbrado))) AS AGOSTO,
(SELECT COUNT(*) AS total FROM RtPenafiel WHERE fechaTimbrado is not null AND MONTH(try_CONVERT(DATETIME, fechaTimbrado)) = 09 AND YEAR(try_CONVERT(DATETIME, fechaTimbrado)) = '2022' GROUP BY MONTH(try_CONVERT(DATETIME, fechaTimbrado))) AS SEPTIEMBRE,
(SELECT COUNT(*) AS total FROM RtPenafiel WHERE fechaTimbrado is not null AND MONTH(try_CONVERT(DATETIME, fechaTimbrado)) = 10 AND YEAR(try_CONVERT(DATETIME, fechaTimbrado)) = '2022' GROUP BY MONTH(try_CONVERT(DATETIME, fechaTimbrado))) AS OCTUBRE,
(SELECT COUNT(*) AS total FROM RtPenafiel WHERE fechaTimbrado is not null AND MONTH(try_CONVERT(DATETIME, fechaTimbrado)) = 11 AND YEAR(try_CONVERT(DATETIME, fechaTimbrado)) = '2022' GROUP BY MONTH(try_CONVERT(DATETIME, fechaTimbrado))) AS NOVIEMBRE,
(SELECT COUNT(*) AS total FROM RtPenafiel WHERE fechaTimbrado is not null AND MONTH(try_CONVERT(DATETIME, fechaTimbrado)) = 12 AND YEAR(try_CONVERT(DATETIME, fechaTimbrado)) = '2022' GROUP BY MONTH(try_CONVERT(DATETIME, fechaTimbrado))) AS DICIEMBRE
FROM RtPenafiel        
END
GO
