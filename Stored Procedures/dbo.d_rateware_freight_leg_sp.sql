SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_rateware_freight_leg_sp] (@lgh_number int)  
AS  


/************************************************************************************
 NAME:        d_rateware_freight_leg_sp
 TYPE:        stored procedure
 DATABASE:    TMW
 PURPOSE:     Obtains freight information for an order that is used to rate carriers for pay
        
 PARAMETERS:  @lgh_number       
 RETURNS:     The selected list of data.


REVISION LOG

DATE          WHO       REASON
---------    	------      ------------
08/21/08		pmill		PTS42233



*************************************************************************************/

SELECT	f.cmd_code, 
	c.cmd_name, 
	c.cmd_nmfc_class, 
	f.fgt_weight, 
	f.fgt_weightunit
FROM	stops  s
	JOIN freightdetail f ON f.stp_number = s.stp_number
	LEFT JOIN commodity c ON c.cmd_code = f.cmd_code
WHERE	s.lgh_number = @lgh_number
	AND stp_type = 'DRP'
	AND stp_sequence = (select max (stp_sequence) from stops where stp_type = 'DRP' and lgh_number = @lgh_number)

GO
GRANT EXECUTE ON  [dbo].[d_rateware_freight_leg_sp] TO [public]
GO
