SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_obtener_segmento_repetido_reporte] (@leg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
		SELECT Folio,Fecha FROM VISTA_Carta_Porte WHERE Folio = @leg and Serie != 'TDRZP'
END
GO
