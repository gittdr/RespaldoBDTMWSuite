SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_get_estatus] (@orden varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
    select lgh_outstatus as estatus 
	from legheader WHERE
	ord_hdrnumber in (SELECT ord_hdrnumber from orderheader where ord_hdrnumber = @orden)
END
GO
