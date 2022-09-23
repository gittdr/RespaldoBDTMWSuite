SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_update_orderheader_procesada_API_JC] (@order varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
  SELECT ord_extrainfo2 FROM orderheader WHERE ord_extrainfo2 IS NULL and ord_hdrnumber = @order	
END
GO
