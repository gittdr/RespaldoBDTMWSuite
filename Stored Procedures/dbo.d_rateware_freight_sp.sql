SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_rateware_freight_sp] (@ord_hdrnumber int)  
AS  


/************************************************************************************
 NAME:        d_rateware_freight_sp
 TYPE:        stored procedure
 DATABASE:    TMW
 PURPOSE:     Obtains freight information for an order that is used to rate carriers for pay
        
 PARAMETERS:  @ord_hdrnumber       
 RETURNS:     The selected list of data.


REVISION LOG

DATE          WHO       REASON
---------    	------      ------------
08/20/08		pmill		PTS42233



*************************************************************************************/

SELECT		f.cmd_code, 
			c.cmd_name,
			c.cmd_NMFC_Class,
			fgt_weight, 
			fgt_weightunit, 
			fgt_volume, 
			fgt_volumeunit, 
			fgt_count, 
			fgt_countunit
FROM stops  s
	JOIN freightdetail f ON f.stp_number = s.stp_number
	LEFT JOIN commodity c ON c.cmd_code = f.cmd_code
WHERE ord_hdrnumber = @ord_hdrnumber
AND stp_type = 'DRP'
AND stp_sequence = (select max (stp_sequence) from stops where stp_type = 'DRP' and ord_hdrnumber = @ord_hdrnumber)

GO
GRANT EXECUTE ON  [dbo].[d_rateware_freight_sp] TO [public]
GO
