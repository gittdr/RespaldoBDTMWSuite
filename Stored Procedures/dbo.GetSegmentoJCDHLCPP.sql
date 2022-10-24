SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetSegmentoJCDHLCPP] (@leg varchar(100))
	-- Add the parameters for the stored procedure here
AS
BEGIN
    SELECT top 1 Fecha FROM VISTA_Carta_Porte WHERE Folio = @leg and Serie != 'TDRZP'
END
GO
