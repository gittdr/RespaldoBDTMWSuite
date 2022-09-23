SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_obtener_order_header] (@leg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT TOP 1 l.ord_hdrnumber as ord_hdrnumber, c.Fecha as fecha FROM legheader as l INNER JOIN VISTA_Carta_Porte AS c ON c.Folio = l.lgh_number  where lgh_number = @leg and c.Serie != 'TDRZP'
        --SELECT TOP 1 ord_hdrnumber FROM legheader where lgh_number = @leg
END
GO
