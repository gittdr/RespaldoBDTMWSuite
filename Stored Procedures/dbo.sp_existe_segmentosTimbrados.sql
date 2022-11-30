SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_existe_segmentosTimbrados] (@seg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT TOP 1 segmento FROM segmentosportimbrar_JR WHERE segmento = @seg and estatus in ('2','9')
END
GO
