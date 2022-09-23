SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_existe_segmentos] (@seg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT TOP 1 segmento FROM segmentosportimbrar_JR WHERE segmento = @seg and estatus = '1'
END

--- Comentario de prueba 2311
GO
