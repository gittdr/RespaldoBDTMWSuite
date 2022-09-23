SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_cast_billoflading](@ordnum int)
AS
/**
 * 
 * REVISION HISTORY:
 * 10/24/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

declare @cmd_code varchar(8), @count float, @weight float, @volume float,
        @stp_number int, @ord_number int, @ord_rate float


CREATE TABLE #cbol (
ord_number varchar(12) NULL,
remarks varchar(254)null,
total_charge money NULL,
DELIVERY_INSTR varchar(254)null,
DELIVERY_DATE datetime NULL, 
shipper_id varchar(8) NULL,
shipper_name varchar(100) NULL ,
shipper_addr1 varchar(100) NULL,
shipper_addr2 varchar(100) NULL,
shipper_cty_name varchar(18) NULL,
shipper_cty_state varchar(6) NULL,
shipper_cty_zip varchar(10) NULL,
shipper_addr varchar(201) NULL,
consignee_id varchar(8) NULL,
consignee_name varchar(100) NULL,
consignee_addr1  varchar(100) NULL,
consignee_addr2 varchar(100) NULL,
consignee_cty_name varchar(18) NULL,
consignee_cty_state varchar(6) NULL,
consignee_cty_zip varchar(10) NULL,
consignee_addr varchar(201) NULL,
ORD_CHARGE money null,
CMD_CODE varchar(8) null,
DRIVER1 varchar(25) null,
DRIVER2 varchar(25) null,
TRACTOR varchar(8) null,
TRAILER1 varchar(8) null,
TRAILER2 varchar(13)null,
FGT_DESCRIPTION varchar(60)null,
ORD_RATE float null,
FGT_WEIGHT float null
)

INSERT INTO  #cbol 
SELECT       
       ORD.ORD_NUMBER,       
       ORD.ORD_REMARK REMARKS,       
       ORD.ORD_CHARGE TOTAL_CHARGE,
       STP.STP_COMMENT DELIVERY_INSTR,      
       ORD.ORD_ORIGIN_EARLIESTDATE DELIVERY_DATE,
       ORD.ORD_ORIGINPOINT SHIPPER_ID,
       shipper.cmp_name shipper_name ,
       shipper.cmp_address1 shipper_addr1,
       shipper.cmp_address2 shipper_addr2,
       shipper_cty.cty_name shipper_cty_name,
       shipper_cty.cty_state shipper_cty_state,
       --DPH PTS 24905
       shipper_cty_zip = Case Rtrim(Isnull(shipper.cmp_zip,'')) When '' Then shipper_cty.cty_zip Else shipper.cmp_zip End,
       --shipper_cty.cty_zip shipper_cty_zip,
       --DPH PTS 24905
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
       --DPH PTS 24905
       consignee_cty_zip = Case Rtrim(IsNull(consignee.cmp_zip,'')) When '' Then consignee_cty.cty_zip Else consignee.cmp_zip End ,
       --consignee_cty.cty_zip consignee_cty_zip,   
       --DPH PTS 24905    
       Case
	     When isnull(consignee.cmp_address2,' ') = ' ' Then consignee.cmp_address1
	     When isnull(consignee.cmp_address2,' ')<> ' ' Then consignee.cmp_address1+' '+ consignee.cmp_address2
	     Else ' '
	     End consignee_addr,
       ORD.ORD_CHARGE,
       FGT.CMD_CODE,
       Case
	     When isnull(MP1.MPP_FIRSTNAME,' ') = ' ' Then MP1.MPP_LASTNAME
	     When isnull(MP1.MPP_LASTNAME,' ')<> ' ' Then MP1.MPP_LASTNAME +','+ SUBSTRING(MP1.MPP_FIRSTNAME,1,1)
	     Else ' '
	     End DRIVER1,
       Case
	     When isnull(MP2.MPP_FIRSTNAME,' ') = ' ' Then MP2.MPP_LASTNAME
	     When isnull(MP2.MPP_LASTNAME,' ')<> ' ' Then MP2.MPP_LASTNAME +','+ SUBSTRING(MP2.MPP_FIRSTNAME,1,1)
	     Else ' '
	     End DRIVER2,
       LGH.LGH_TRACTOR TRACTOR,
       LGH.LGH_PRIMARY_TRAILER TRAILER1,
       LGH.LGH_PRIMARY_PUP TRAILER2,
       FGT.FGT_DESCRIPTION,
       case 
             When ord.ord_rate = 0 Then fgt.fgt_rate
             else 0
             End ord_rate,
       --ORD.ORD_RATE,
       FGT.FGT_WEIGHT      
FROM  ORDERHEADER ORD  LEFT OUTER JOIN  company shipper  ON  ORD.ord_shipper  = shipper.cmp_id   
						LEFT OUTER JOIN  company consignee  ON  ORD.ord_consignee  = consignee.cmp_id   
						LEFT OUTER JOIN  city consignee_cty  ON  ORD.ORD_destcity  = consignee_cty.cty_code   
						LEFT OUTER JOIN  city shipper_cty  ON  ORD.ORD_origincity  = shipper_cty.cty_code ,
		LEGHEADER LGH  LEFT OUTER JOIN  MANPOWERPROFILE MP1  ON  LGH.LGH_DRIVER1  = MP1.MPP_ID   
						LEFT OUTER JOIN  MANPOWERPROFILE MP2  ON  LGH.LGH_DRIVER2  = MP2.MPP_ID ,
		STOPS STP,
		FREIGHTDETAIL FGT 
WHERE	ORD.ORD_HDRNUMBER  = @ordnum
 AND	STP.ORD_HDRNUMBER  = ORD.ORD_HDRNUMBER
 AND	STP.ORD_HDRNUMBER  = LGH.ORD_HDRNUMBER
 AND	STP.STP_NUMBER  = FGT.STP_NUMBER
 AND	STP.STP_EVENT  = 'LUL'

--Create a cursor based on the select statement below
DECLARE freight_cursor CURSOR FOR  
SELECT #cbol.cmd_code, stp.stp_number, stp.ord_hdrnumber, ord_rate
 from stops stp, #cbol, freightdetail fgt
where stp.ord_hdrnumber = @ordnum and
      stp.stp_event = 'LUL' and
      fgt.stp_number = stp.stp_number and
      fgt.cmd_code = #cbol.cmd_code  
    
--Populate the cursor based on the select statement above  
OPEN freight_cursor  
  
--Execute the initial fetch of the first secondary trailer based on the leg
FETCH NEXT FROM freight_cursor INTO @cmd_code, @stp_number, @ord_number, @ord_rate 
 
 
--If the fetch is succesful continue to loop
WHILE @@fetch_status = 0  
 BEGIN  
  
  select @count = fgt.fgt_count, 
         @weight = fgt.fgt_weight,
         @volume = fgt.fgt_volume
    from freightdetail fgt
   where fgt.stp_number =  @stp_number and
         cmd_code = @cmd_code 

  
If @ord_rate = 0 
   begin
	update #cbol
	  set ord_rate = ord.ord_rate
	 from orderheader ord
	where ord.ord_hdrnumber = @ordnum and
	      #cbol.cmd_code = @cmd_code      
   end

IF @weight > 0 
     BEGIN
        update #cbol
     	   set fgt_weight = @weight 
          from stops stp, freightdetail fgt
	 where stp.ord_hdrnumber = @ordnum and
      	       stp.stp_event = 'LUL' and
      	       fgt.stp_number = stp.stp_number and
      	       fgt.cmd_code = #cbol.cmd_code AND
               #cbol.cmd_code = @cmd_code
     END
	
IF @volume > 0 
     BEGIN
        update #cbol
     	   set fgt_weight = @volume
          from stops stp, freightdetail fgt
	 where stp.ord_hdrnumber = @ordnum and
      	       stp.stp_event = 'LUL' and
      	       fgt.stp_number = stp.stp_number and
      	       fgt.cmd_code = #cbol.cmd_code AND
               #cbol.cmd_code = @cmd_code
     END
	
IF @count > 0 
     BEGIN
        update #cbol
     	   set fgt_weight = @count
          from stops stp, freightdetail fgt
	 where stp.ord_hdrnumber = @ordnum and
      	       stp.stp_event = 'LUL' and
      	       fgt.stp_number = stp.stp_number and
      	       fgt.cmd_code = #cbol.cmd_code AND
               #cbol.cmd_code = @cmd_code
               
     END


IF @ord_rate > 0
  Begin
	  IF @weight > 0 
	     BEGIN
	        update #cbol
	     	   set ord_charge = @weight * @ord_rate    
	          from stops stp, freightdetail fgt
		 where stp.ord_hdrnumber = @ordnum and
	      	       stp.stp_event = 'LUL' and
	      	       fgt.stp_number = stp.stp_number and
	      	       fgt.cmd_code = #cbol.cmd_code AND
	               #cbol.cmd_code = @cmd_code
	     END
	
	  IF @volume > 0 
	     BEGIN
	        update #cbol
	     	   set ord_charge = @volume * @ord_rate 
	          from stops stp, freightdetail fgt
		 where stp.ord_hdrnumber = @ordnum and
	      	       stp.stp_event = 'LUL' and
	      	       fgt.stp_number = stp.stp_number and
	      	       fgt.cmd_code = #cbol.cmd_code AND
	               #cbol.cmd_code = @cmd_code
	     END
	
	  IF @count > 0 
	     BEGIN
	        update #cbol
	     	   set ord_charge = @count * @ord_rate 
	          from stops stp, freightdetail fgt
		 where stp.ord_hdrnumber = @ordnum and
	      	       stp.stp_event = 'LUL' and
	      	       fgt.stp_number = stp.stp_number and
	      	       fgt.cmd_code = #cbol.cmd_code AND
	               #cbol.cmd_code = @cmd_code
	               
	     END

   END	
 
 
   --Fetch the next secondary trailer in the list
   FETCH NEXT FROM freight_cursor INTO @cmd_code, @stp_number, @ord_number, @ord_rate
  
 END  
  
--Close cursor  
CLOSE freight_cursor
--Release cusor resources  
DEALLOCATE freight_cursor

Select * from #cbol

GO
GRANT EXECUTE ON  [dbo].[d_cast_billoflading] TO [public]
GO
