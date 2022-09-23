SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_existe_status] (@seg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT TOP 1 estatus FROM segmentosportimbrar_JR WHERE segmento = @seg
END
GO
