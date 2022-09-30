SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_obtener_order_header_ONLY] (@leg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        SELECT TOP 1 ord_hdrnumber FROM legheader where lgh_number = @leg 
        --SELECT TOP 1 ord_hdrnumber FROM legheader where lgh_number = @leg
END
GO
