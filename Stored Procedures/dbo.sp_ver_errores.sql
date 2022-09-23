SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_ver_errores] (@leg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
		SELECT Erro1,Erro2 FROM VISTA_Carta_Porte_Errores WHERE Folio =  @leg
END
GO
