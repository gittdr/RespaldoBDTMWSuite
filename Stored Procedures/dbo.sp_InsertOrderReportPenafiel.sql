SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_InsertOrderReportPenafiel] (@rorderh varchar(100),@leg varchar(100),@gbilto varchar(100),@tipom varchar(100),@rfecha varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        INSERT INTO RtPenafiel(orden,segmento,billto,estatus,fechaTimbrado) 
		VALUES(@rorderh,@leg,@gbilto,@tipom,@rfecha)
END
GO
