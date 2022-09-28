SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetSegmentoJCPENAFIEL] (@leg varchar(100))
	-- Add the parameters for the stored procedure here
AS
BEGIN
    select TOP 1 orden,segmento,billto,estatus,fechaTimbrado FROM RtPenafiel WHERE segmento = @leg and estatus in ('3','5') and fechaTimbrado = 'null'
END
GO
