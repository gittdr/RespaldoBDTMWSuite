SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Pull_Report_Update2_PalacioH_JC] (@orden varchar(100),@segmento varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        UPDATE RtPlacioH SET segmento = @segmento WHERE orden = @orden
END
GO
