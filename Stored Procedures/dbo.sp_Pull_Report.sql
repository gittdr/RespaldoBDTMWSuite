SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Pull_Report] (@segmento varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        INSERT INTO Reporte_Timbradas(segmento) VALUES(@segmento)
END
GO
