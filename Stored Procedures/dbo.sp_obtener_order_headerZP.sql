SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_obtener_order_headerZP] (@leg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT TOP 1 Fecha FROM VISTA_Carta_Porte WHERE Folio = @leg and Serie != 'TDRXP'
        --SELECT TOP 1 ord_hdrnumber FROM legheader where lgh_number = @leg
END
GO
