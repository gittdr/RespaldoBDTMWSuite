SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
  Returns information from the freghtdetail table need for
  rating 
*/
  



CREATE PROC [dbo].[d_freightdataforrating_sp] (@ordhdrnumber int, @stopoffevents varchar(200))
AS 


SELECT   freightdetail.cmd_code,   
         freightdetail.fgt_description,   
         freightdetail.fgt_weight,   
         freightdetail.fgt_weightunit,   
         freightdetail.fgt_count,   
         freightdetail.fgt_countunit,   
         freightdetail.fgt_volume,   
         freightdetail.fgt_volumeunit,
         freightdetail.fgt_number,   
         freightdetail.stp_number,   
         freightdetail.fgt_sequence,
	 stops.cmp_id company_cmp_id,   
	 stops.stp_type stops_stp_type,			
	 stops.stp_sequence stops_stp_sequence,
	 stops.stp_event stp_event,
	 freightdetail.fgt_quantity fgt_quantity,   
         freightdetail.fgt_rate,   
         freightdetail.fgt_charge,   
         freightdetail.fgt_rateunit,   
         freightdetail.cht_itemcode,  
	 freightdetail.cht_basisunit,
	 freightdetail.fgt_unit ,
	 @stopoffevents stopoffevents   
   FROM freightdetail,   
         dbo.stops  
   WHERE ( stops.ord_hdrnumber = @ordhdrnumber ) and  
         ( freightdetail.stp_number = stops.stp_number )
   ORDER BY stops.Stp_sequence, freightdetail.fgt_sequence 



GO
GRANT EXECUTE ON  [dbo].[d_freightdataforrating_sp] TO [public]
GO
