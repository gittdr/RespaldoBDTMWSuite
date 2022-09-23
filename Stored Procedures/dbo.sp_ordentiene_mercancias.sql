SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_ordentiene_mercancias] (@leg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        select count(*) as total from freightdetail where 
stp_number in (select stp_number from stops where ORD_hdrnumber = @leg)
		
END
GO
