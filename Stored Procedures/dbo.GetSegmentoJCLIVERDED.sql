SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetSegmentoJCLIVERDED] (@leg varchar(100))
	-- Add the parameters for the stored procedure here
AS
BEGIN
    select TOP 1 orden,segmento,billto,estatus,fechaTimbrado FROM Reporte_Timbradas WHERE segmento = @leg and estatus in ('3','5') and fechaTimbrado = 'null'
END
GO
