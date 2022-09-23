SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_update_orderheader_API_JC] (@order varchar(1000),@idd varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        UPDATE orderheader SET ord_extrainfo2 = 'Procesada', ord_extrainfo3 = @idd WHERE ord_hdrnumber = @order	
END
GO
