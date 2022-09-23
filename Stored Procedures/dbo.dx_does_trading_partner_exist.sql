SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Pass a trading partner ID and this proc will return a 1 if the trading partner ID is valid in TMWSuite
   or a -1if it is not.  Call should look like:

           DECLARE @trp_id varchar(20), @ret int, @@cmp_id VARCHAR(8)
           SELECT @TP = 'TPFORD'
           EXEC @ret =  dx_does_trading_partner_exist @tp_id, @@cmp_id
   where @trp_id is varchar(20) and contains the trading partner id, @@cmp_id is a varchar(8);  @ret is an int 
*/
CREATE PROCEDURE [dbo].[dx_does_trading_partner_exist]
	@trp_id varchar(20), @@cmp_id varchar(8) OUTPUT
 AS 

 /*******************************************************************************************************************  
  Object Description:
  dx_does_trading_partner_exist

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

SELECT @@cmp_id = ISNULL(etp_CompanyID,'') FROM edi_tender_partner WHERE etp_partnerID = @trp_id
IF @@ROWCOUNT > 0 
	RETURN 1
ELSE
	RETURN -1

GO
GRANT EXECUTE ON  [dbo].[dx_does_trading_partner_exist] TO [public]
GO
