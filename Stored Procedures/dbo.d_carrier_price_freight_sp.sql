SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_carrier_price_freight_sp] (@ordnum varchar(12))  
AS  


/************************************************************************************
 NAME:        d_carrier_price_freight_sp
 TYPE:        stored procedure
 DATABASE:    TMW
 PURPOSE:     Obtains freight information for an order that is used to price carriers
        
        
 RETURNS:     The selected list of data.


REVISION LOG

DATE          WHO       REASON
---------    	------      ------------
08/18/08		pmill		PTS42231



*************************************************************************************/

SELECT	fgt_sequence,
			f.cmd_code, 
			c.cmd_name,
			fgt_weight, 
			fgt_weightunit, 
			fgt_volume, 
			fgt_volumeunit, 
			fgt_count, 
			fgt_countunit
FROM		orderheader o
	JOIN stops  s ON s.ord_hdrnumber = o.ord_hdrnumber
	JOIN freightdetail f ON f.stp_number = s.stp_number
	LEFT JOIN commodity c ON c.cmd_code = f.cmd_code
WHERE ord_number = @ordnum
AND stp_type = 'DRP'
AND stp_sequence = (select max (stp_sequence) from stops where stp_type = 'DRP' and ord_hdrnumber = o.ord_hdrnumber)
ORDER BY fgt_sequence

GO
GRANT EXECUTE ON  [dbo].[d_carrier_price_freight_sp] TO [public]
GO
