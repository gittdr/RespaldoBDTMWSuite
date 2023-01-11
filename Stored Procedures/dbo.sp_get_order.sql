SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_get_order] (@segmento varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
    SELECT ord_hdrnumber FROM legheader WHERE lgh_number = @segmento
END
GO
