SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_dddw_load_location_sp] @mov_number int 
as  

SELECT cmp_ord = (stops.cmp_id + '- ord ' + ord_number), 
		stops.cmp_id, 
         company.cmp_name,   
         company.cmp_address1,   
         company.cty_nmstct,   
         company.cmp_city,   
         company.cmp_zip,
			stops.stp_number,   
         stops.stp_type,   
         stops.stp_event,
			ord_consignee,
			stops.ord_hdrnumber
    FROM company,   
         stops,
			orderheader
   WHERE (stp_type = 'PUP' or stp_event = 'XDL') and
			stops.mov_number = @mov_number and 
			stops.cmp_id = company.cmp_id and
			orderheader.ord_hdrnumber = stops.ord_hdrnumber

GO
GRANT EXECUTE ON  [dbo].[d_dddw_load_location_sp] TO [public]
GO
