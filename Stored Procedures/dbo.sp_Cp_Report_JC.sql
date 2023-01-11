SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Cp_Report_JC] (@folio varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
SELECT folio,uuid,segmento,serie,rorder,aplica,billto,totalinvoice,totalvcartaporte,estatus FROM InsertRegCp WHERE folio =@folio ORDER BY id_num DESC
             
END
GO
