SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_ushertrans_billoflading](@ordnum int)
AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/12/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
SELECT       
       ORD.ORD_NUMBER,   
       ORD.ORD_HDRNUMBER,    
       ORD.ORD_REMARK REMARKS,       
       ORD.ORD_CHARGE TOTAL_CHARGE,
       ORD.ORD_REVTYPE1 TERMINAL,
       ORD.ORD_TRACTOR TRACTOR,
       ORD.ORD_TRAILER TRAILER,
       ORD.ORD_DRIVER1 DRIVER1,
       ORD.ORD_DRIVER2 DRIVER2,
       ORD.ORD_BOOKEDBY BOOKEDBY,
       ORD.ORD_STARTDATE START_DATE,
       ORD.ORD_COMPLETIONDATE DELIVERY_DATE,
       ORD.ORD_ORIGINPOINT SHIPPER_ID,
       shipper.cmp_name shipper_name ,
       shipper.cmp_address1 shipper_addr1,
       shipper.cmp_address2 shipper_addr2,
       shipper_cty.cty_name shipper_cty_name,
       shipper_cty.cty_state shipper_cty_state,
       shipper_cty.cty_zip shipper_cty_zip,
       Case
	     When isnull(shipper.cmp_address2,' ') = ' ' Then shipper.cmp_address1
	     When isnull(shipper.cmp_address2,' ')<> ' ' Then shipper.cmp_address1+' '+shipper.cmp_address2
	     Else ' '
	     End shipper_addr,	
       ORD.ORD_DESTPOINT CONSIGNEE_ID,
       consignee.cmp_name consignee_name,
       consignee.cmp_address1 consignee_addr1,
       consignee.cmp_address2 consignee_addr2,
       consignee_cty.cty_name consignee_cty_name,
       consignee_cty.cty_state consignee_cty_state,
       consignee_cty.cty_zip consignee_cty_zip,       
       Case
	     When isnull(consignee.cmp_address2,' ') = ' ' Then consignee.cmp_address1
	     When isnull(consignee.cmp_address2,' ')<> ' ' Then consignee.cmp_address1+' '+ consignee.cmp_address2
	     Else ' '
	     End consignee_addr,
       ORD.ORD_BILLTO ACCT_ID,      
       ORD.ORD_CHARGE,      
       FGT.CMD_CODE,
       FGT.FGT_DESCRIPTION,
       ORD.ORD_RATE,       
       consignee.cmp_misc3 consignee_misc3,
       consignee.cmp_misc4 consignee_misc4,
       cmd.cmd_haz_class haz_class,
       cmd.cmd_haz_subclass haz_subclass, 
       stp.stp_event event,       
       stp.stp_state stop_state,
       stop_cty.cty_name stop_city,
       stp.stp_address stop_address,
       stp.cmp_name company_name,       
       fgt.fgt_count cnt,  
       fgt.fgt_countunit cnt_unit,               
       fgt.fgt_weight wgt,     
       fgt.fgt_weightunit wgt_unit,
       fgt.fgt_volume vol,        
       fgt.fgt_volumeunit vol_unit, 
       (select count(stp_event) 
          from stops stp,freightdetail fgt
 	 where ord_hdrnumber = @ordnum and 
       	       stp.stp_number = fgt.stp_number and
               stp.stp_event = 'LLD') LLD, 
       (select count(stp_event) 
          From stops stp,freightdetail fgt 
         where ord_hdrnumber = @ordnum and 
	       stp.stp_number = fgt.stp_number and
               stp_event = 'LUL') LUL,                  
       fgt.fgt_weight,
       stp.stp_mfh_sequence
--pts40187 outer join conversion
FROM orderheader ord  LEFT OUTER JOIN  company shipper  ON  ORD.ord_shipper  = shipper.cmp_id   
			LEFT OUTER JOIN  company consignee  ON  ORD.ord_consignee  = consignee.cmp_id   
			LEFT OUTER JOIN  city consignee_cty  ON  ORD.ORD_destcity  = consignee_cty.cty_code   
			LEFT OUTER JOIN  city shipper_cty  ON  ORD.ORD_origincity  = shipper_cty.cty_code ,
	 stops stp  LEFT OUTER JOIN  city stop_cty  ON  STP.STP_city  = STOP_CTY.CTY_CODE ,
	 freightdetail fgt,
	 commodity cmd 
WHERE ORD.ORD_HDRNUMBER = @ordnum      AND
      STP.ORD_HDRNUMBER = ORD.ORD_HDRNUMBER AND
      STP.STP_NUMBER = FGT.STP_NUMBER AND
      STP.STP_EVENT IN ('LUL','LLD') AND
      fgt.cmd_code = cmd.cmd_code

group by
       ORD.ORD_NUMBER,   
       ORD.ORD_HDRNUMBER,    
       ORD.ORD_REMARK ,       
       ORD.ORD_CHARGE ,
       ORD.ORD_REVTYPE1 ,
       ORD.ORD_TRACTOR ,
       ORD.ORD_TRAILER ,
       ORD.ORD_DRIVER1 ,
       ORD.ORD_DRIVER2 ,
       ORD.ORD_BOOKEDBY ,
       ORD.ORD_STARTDATE ,
       ORD.ORD_COMPLETIONDATE ,
       ORD.ORD_ORIGINPOINT ,
       shipper.cmp_name  ,
       shipper.cmp_address1 ,
       shipper.cmp_address2 ,
       shipper_cty.cty_name ,
       shipper_cty.cty_state ,
       shipper_cty.cty_zip ,
       shipper.cmp_address2,	
       ORD.ORD_DESTPOINT ,
       consignee.cmp_name ,
       consignee.cmp_address1 ,
       consignee.cmp_address2 ,
       consignee_cty.cty_name ,
       consignee_cty.cty_state ,
       consignee_cty.cty_zip ,       
       consignee.cmp_address2,
       ORD.ORD_BILLTO ,      
       ORD.ORD_CHARGE,       
       FGT.CMD_CODE,
       FGT.FGT_DESCRIPTION,
       ORD.ORD_RATE,       
       consignee.cmp_misc3 ,
       consignee.cmp_misc4 ,
       cmd.cmd_haz_class ,
       cmd.cmd_haz_subclass , 
       stp.stp_event ,
       stp.stp_state ,
       stop_cty.cty_name ,
       stp.stp_address ,
       stp.cmp_name ,       
       fgt.fgt_count ,  
       fgt.fgt_countunit ,               
       fgt.fgt_weight ,     
       fgt.fgt_weightunit ,
       fgt.fgt_volume ,        
       fgt.fgt_volumeunit ,                     
       fgt.fgt_weight,
       stp.stp_mfh_sequence 

order by stp.stp_event,stp.stp_mfh_sequence
GO
GRANT EXECUTE ON  [dbo].[d_ushertrans_billoflading] TO [public]
GO
