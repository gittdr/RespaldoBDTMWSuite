SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_carrier_price_hdr_sp] (@ordnum varchar(12))  
AS  


/************************************************************************************
 NAME:        d_carrier_price_hdr_sp
 TYPE:        stored procedure
 DATABASE:    TMW
 PURPOSE:     Obtains information for an order that is used to price carriers
        
        
 RETURNS:     The selected list of data.


REVISION LOG

DATE          WHO       REASON
---------    	------      ------------
08/29/08		pmill		PTS42231



*************************************************************************************/

SELECT o.ord_number, 
		o.ord_hdrnumber,
		o.ord_originpoint,
		ocmp.cmp_name origin_cmp_name,
		o.ord_origincity,
		oc.cty_nmstct origin_cty_nmstct,
		o.ord_origin_zip,
		o.ord_destpoint,
		dcmp.cmp_name dest_cmp_name,
		o.ord_destcity,
		dc.cty_nmstct dest_cty_nmstct,
		o.ord_dest_zip,
		o.ord_billto,
		bcmp.cmp_name billto_cmp_name,
		o.ord_startdate

FROM	orderheader o
	LEFT JOIN	city oc on oc.cty_code = o.ord_origincity
	LEFT JOIN	city dc on dc.cty_code = o.ord_destcity
	LEFT JOIN company bcmp on bcmp.cmp_id = o.ord_billto
	LEFT JOIN company dcmp on dcmp.cmp_id = o.ord_destpoint
	LEFT JOIN company ocmp on ocmp.cmp_id = o.ord_originpoint
	LEFT JOIN commodity cmd on cmd.cmd_code = o.cmd_code
WHERE ord_number = @ordnum
		
GO
GRANT EXECUTE ON  [dbo].[d_carrier_price_hdr_sp] TO [public]
GO
