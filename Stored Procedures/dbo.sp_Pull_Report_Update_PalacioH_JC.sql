SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Pull_Report_Update_PalacioH_JC] (@orden varchar(100),@segmento varchar(100),@billto varchar(100),@estatus varchar(100),@fecha varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        UPDATE RtPlacioH SET segmento = @segmento, billto = @billto, estatus = @estatus, fechaTimbrado = @fecha WHERE orden = @orden
END
GO
