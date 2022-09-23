SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tmail_findFreight] (@stp_number int, @searchType varchar(30), @searchCriteria varchar(60))
					 
AS

/*

	Purpose:	Determines the fgt_number at the provided stp_number matching the
			given criteria.
			
			searchTypes defined:
				CmdCode: searchCriteria is a commodity code
				CmdDesc: searchCriteria is a commodity description
				Sequence: searchCriteria is a freight sequence number.
*/
IF @searchType = 'CmdCode'
	SELECT fgt_number FROM freightdetail WHERE stp_number = @stp_number AND cmd_code = @searchCriteria
ELSE IF @searchType = 'CmdDesc'
	SELECT fgt_number FROM freightdetail WHERE stp_number = @stp_number AND fgt_description = @searchCriteria
ELSE IF @searchType = 'Sequence'
	SELECT fgt_number FROM freightdetail WHERE stp_number = @stp_number AND CONVERT(VARCHAR(20), fgt_sequence) = @searchCriteria
ELSE 
	SELECT fgt_number FROM freightdetail WHERE 1=2

GO
GRANT EXECUTE ON  [dbo].[tmail_findFreight] TO [public]
GO
