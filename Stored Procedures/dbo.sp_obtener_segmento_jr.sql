SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_obtener_segmento_jr] (@leg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT top 1 segmento,billto,estatus FROM segmentosportimbrar_JR WHERE segmento = @leg
END
GO
