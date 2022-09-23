SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_obtener_segmento_actualizado] (@leg varchar(1000),@tipom varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
BEGIN
			-- aqui se leen los archivos
	    UPDATE segmentosportimbrar_JR SET estatus = @tipom WHERE segmento = @leg
		
END

BEGIN
		--aqui va el update para los archivos
		SELECT segmento, estatus FROM segmentosportimbrar_JR WHERE segmento = @leg
		
		
END
END


GO
