SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_update_orderheader] (@orheader varchar(1000),@fecha varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        UPDATE orderheader SET ord_extrainfo1 = 'Timbrada - ' + @fecha WHERE ord_hdrnumber = @orheader	
END
GO
