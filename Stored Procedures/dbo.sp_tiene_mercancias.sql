SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_tiene_mercancias] (@leg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        --SELECT COUNT(*) as total FROM freightdetail WHERE 
        --stp_number in (SELECT stp_number FROM stops WHERE ORD_hdrnumber = @leg) and cmd_code NOT in ('UNKNOWN', 'MERGENER')

		select count(*) as total from freightdetail where cmd_code NOT IN ('UNKNOWN', 'MERGENER')  AND
        stp_number in (select stp_number from stops where lgh_number = @leg)
END

		--SELECT COUNT(*) as total FROM freightdetail WHERE 
        --stp_number in (SELECT stp_number FROM stops WHERE ORD_hdrnumber = 1190049) and cmd_code NOT in ('UNKNOWN', 'MERGENER')
GO
