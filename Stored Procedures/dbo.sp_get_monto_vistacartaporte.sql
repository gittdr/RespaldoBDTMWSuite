SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_get_monto_vistacartaporte] (@folio varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
    SELECT Total FROM VISTA_Carta_Porte WHERE Folio = @folio
END
GO
