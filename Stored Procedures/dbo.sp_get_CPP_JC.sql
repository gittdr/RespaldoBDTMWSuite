SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_get_CPP_JC] (@folio varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
    select Folio,Serie,UUID,Pdf_descargaFactura,xlm_descargaFactura  
	from VISTA_Carta_Porte WHERE
	Folio = @folio and Serie != 'TDRZP'
END
GO
