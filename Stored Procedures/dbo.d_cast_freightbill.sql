SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_cast_freightbill](@invoice_nbr int,@copies int)
AS
 
DECLARE @counter int, @secondary_trailer varchar(13), @billdate datetime,
        @shipper_no varchar(20), @charge_type int, @remark varchar(254),
        @invoice_number  money, @trailer2_id varchar(13), @stp_no int, @rateby varchar(5),
        @quantity float, @rate2 money, @rate_unit varchar(6), @commodity_code varchar(8),
        @weight float, @distance float, @total_charge money, @order_number int,
        @ord_hdrnumber int, @ivh_invoicenumber varchar(12), @shipper_id varchar(8),
        @showshipper varchar(8), @consignee_id varchar(8), @showconsignee varchar(8),
        @ivh_sum money, @ivd_sum money,@comm_code varchar(8), @comm_desc varchar(256),
	@type varchar(6)
/*
DPETE PTS16314 allow mail to override
DPETE PTS 18656 display company zip rather than city if one provided
* 10/24/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
*/ 
--ILB 03/13/03
SELECT @rateby = ivh_rateby
  FROM invoiceheader
 WHERE ivh_hdrnumber = @invoice_nbr 
--ILB 03/13/03
 
CREATE TABLE #cfb (
ord_number varchar(12) NULL,
order_number int null,
shipper_no varchar(30)NULL,
date_shipped datetime NULL,                
driver1 varchar(8) NULL,
driver2 varchar(8) NULL,
truck_no varchar(8) NULL,
trailer_no varchar(13) NULL,
shipper_id varchar(8) NULL,
shipper_name varchar(100) NULL ,
shipper_addr1 varchar(100) NULL,
shipper_addr2 varchar(100) NULL,
shipper_cty_name varchar(18) NULL,
shipper_cty_state varchar(6) NULL,
shipper_cty_zip varchar(10) NULL,
consignee_id varchar(8) NULL,
consignee_name varchar(100) NULL,
consignee_addr1  varchar(100) NULL,
consignee_addr2 varchar(100) NULL,
consignee_cty_name varchar(18) NULL,
consignee_cty_state varchar(6) NULL,
consignee_cty_zip varchar(10) NULL,
billto_id varchar(8) NULL,
billto_name varchar(100) NULL,
billto_addr1 varchar(100) NULL ,
billto_addr2 varchar(100) NULL, 
billto_cty_code int,
billto_cty_name varchar(18) NULL,
billto_cty_state varchar(6) NULL,
billto_cty_zip varchar(10) NULL,
commodity_code varchar(8) NULL,
commodity_desc varchar(64) NULL,
charge_type int NULL,
remark varchar(254) NULL,
invoice_number money NULL,
shipper_addr varchar(201) NULL,
consignee_addr varchar(201) NULL,
bill_date datetime NULL,
invoice_remark varchar(254) NULL,
weight float NULL,
total_charge money NULL,   
billto_addr varchar(201) NULL,
terms varchar(6) NULL,
invoice_rate money null,
chargetype_desc varchar(30) null,
invoice_type varchar(6) null,
trailer_no2 varchar(13) null,
linehaul_charge money NULL,
billdate datetime null,
quantity float null,
charge_basis varchar(10) null,
unit_basis varchar(10) null,
copies int NULL
)
 
INSERT INTO  #cfb 
SELECT   ivh.ord_number,
         ivh.ord_hdrnumber order_number,    
         @shipper_no shipper_no,                      
  	 ivh.ivh_shipdate date_shipped,
  	 ivh.ivh_driver driver1,
         ivh.ivh_driver2 driver2,
         ivh.ivh_tractor truck_no,
         ivh.ivh_trailer trailer_no,         
  	 ivh.ivh_shipper shipper_id,
         shipper.cmp_name shipper_name ,
         shipper.cmp_address1 shipper_addr1,
         shipper.cmp_address2 shipper_addr2,
  	 shipper_cty.cty_name shipper_cty_name,
         shipper_cty.cty_state shipper_cty_state,
         shipper_cty_zip = Case Rtrim(Isnull(shipper.cmp_zip,'')) When '' Then shipper_cty.cty_zip Else shipper.cmp_zip End,         
  	 ivh.ivh_consignee consignee_id,
         consignee.cmp_name consignee_name,
         consignee.cmp_address1 consignee_addr1,
         consignee.cmp_address2 consignee_addr2,
  	 consignee_cty.cty_name consignee_cty_name,
         consignee_cty.cty_state consignee_cty_state,
         consignee_cty_zip = Case Rtrim(IsNull(consignee.cmp_zip,'')) When '' Then consignee_cty.cty_zip Else consignee.cmp_zip End ,        
  	 ivh.ivh_billto billto_id,
  	 billto.cmp_name billto_name,
  	 billto.cmp_address1 billto_addr1 ,
         billto.cmp_address2 billto_addr2, 
         billto.cmp_city billto_cty_code,
         (select cty_name 
           from city 
          where cty_code = billto.cmp_city )billto_cty_name,
         (select cty_state 
           from city 
          where cty_code = billto.cmp_city )billto_cty_state,
         billto_cty_zip = Case Rtrim(IsNull(billto.cmp_zip,'')) When '' Then (select cty_zip 
           from city 
         where cty_code = billto.cmp_city )Else billto.cmp_zip End ,
  	 ivd.cmd_code commodity_code,
         cmd.cmd_name commodity_desc,         
   	 @charge_type charge_type,  
   	 @remark remark,         
         ivd.ivd_number,
         Case
     		When isnull(shipper.cmp_address2,' ') = ' ' Then shipper.cmp_address1
      		When isnull(shipper.cmp_address2,' ')<> ' ' Then shipper.cmp_address1+' '+shipper.cmp_address2
      		Else ' '
      		End shipper_addr,
 	Case
      		When isnull(consignee.cmp_address2,' ') = ' ' Then consignee.cmp_address1
      		When isnull(consignee.cmp_address2,' ')<> ' ' Then consignee.cmp_address1+' '+ consignee.cmp_address2
      		Else ' '
      		End consignee_addr,
 	ivh.ivh_billdate bill_date,
        ivh.ivh_remark   invoice_remark,
        ivd.ivd_wgt  weight,   
        ivd.ivd_charge total_charge,   
        Case
     		When isnull(billto.cmp_address2,' ') = ' ' Then billto.cmp_address1
     		When isnull(billto.cmp_address2,' ')<> ' ' Then billto.cmp_address1+' '+ billto.cmp_address2
     		Else ' '
     		End billto_addr,
        ivh.ivh_terms terms,
        ivd.ivd_rate invoice_rate,
        cht.cht_description chargetype_desc,
        ivd.ivd_type invoice_type,
        @secondary_trailer        trailer_no2,
 	IsNull(ivh.ivh_charge,0.0) linehaul_charge,
        @billdate billdate,
        ivd.ivd_quantity quantity,
        ivd.cht_basisunit charge_basis,
        ivd_unit unit_basis,
 	1
FROM  invoiceheader ivh  LEFT OUTER JOIN  company billto  ON  ivh.ivh_billto  = billto.cmp_id   
						LEFT OUTER JOIN  company shipper  ON  ivh.ivh_shipper  = shipper.cmp_id   
						LEFT OUTER JOIN  company consignee  ON  ivh.ivh_consignee  = consignee.cmp_id   
						LEFT OUTER JOIN  city consignee_cty  ON  ivh.ivh_destcity  = consignee_cty.cty_code   
						LEFT OUTER JOIN  city shipper_cty  ON  ivh.ivh_origincity  = shipper_cty.cty_code ,
	 invoicedetail ivd,
	 commodity cmd,
	 chargetype cht 
WHERE	 ivh.ivh_hdrnumber  = @invoice_nbr
 AND	ivd.ivh_hdrnumber  = ivh.ivh_hdrnumber
 AND	ivd.cmd_code  = cmd.cmd_code
 AND	cht.cht_itemcode  = ivd.cht_itemcode

--ILB 03/14/03 
--Remove Billable stop record 
IF @rateby = 'D' --Rate By Detail
 BEGIN
 SELECT @total_charge = ivh_totalcharge 
    FROM invoiceheader
   WHERE ivh_hdrnumber = @invoice_nbr 
  IF @total_charge > 0 
  BEGIN
--ILB 03/26/03
  select @comm_code = COMMODITY_CODE,
	 @comm_desc = COMMODITY_DESC
  from  #cfb
  where total_charge = 0
  select @invoice_number = min(invoice_number)
   from #cfb

     UPDATE #CFB
     SET COMMODITY_CODE = @comm_code,
	 COMMODITY_DESC = @comm_desc
   WHERE invoice_number = @invoice_number and
	(isnull(commodity_code, 'UNKNOWN') = 'UNKNOWN' OR COMMODITY_CODE= '') and
        (isnull(commodity_desc, 'UNKNOWN') = 'UNKNOWN' OR COMMODITY_desc= '')  
--ILB 03/26/03
    DELETE FROM #cfb WHERE total_charge = 0 
  END
  --Reset variables
  SELECT @total_charge = 0
  SELECT @invoice_number = 0
  SELECT @comm_desc = ''
  SELECT @comm_code = ''
 END

--Remove null records
IF @rateby IS NULL --Misc Invoice
BEGIN
  DELETE FROM #cfb WHERE total_charge IS NULL
END
--ILB 03/14/03 
 
--ILB 03/13/03 
IF @rateby = 'T' --Rate By Total
 BEGIN
     --ILB 03/26/03
    	select @invoice_number = min(invoice_number)
     	  from #cfb
   	
	--Create a cursor based on the select statement below
	DECLARE wipp_cursor CURSOR FOR  
	SELECT commodity_desc, commodity_code
	  FROM #cfb
	 WHERE chargetype_desc = 'Billable Stop'
	
	--Populate the cursor based on the select statement above  
	OPEN wipp_cursor  
	  
	--Execute the initial fetch of the first secondary trailer based on the leg
	FETCH NEXT FROM wipp_cursor INTO @comm_desc, @comm_code 
	  
	--If the fetch is succesful continue to loop
	WHILE @@fetch_status = 0  
	 BEGIN  
	  
	  --Get the secondary trailer
	   UPDATE #CFB
	      SET COMMODITY_CODE = @comm_code,
		  COMMODITY_DESC = @comm_desc
	    WHERE invoice_number = @invoice_number and
		  (isnull(commodity_code, 'UNKNOWN') = 'UNKNOWN' OR COMMODITY_CODE= '') and
	          (isnull(commodity_desc, 'UNKNOWN') = 'UNKNOWN' OR COMMODITY_desc= '')
	 
	   --Fetch the next secondary trailer in the list
	   FETCH NEXT FROM wipp_cursor INTO @comm_desc, @comm_code
	  
	 END  
	  
	--Close cursor  
	CLOSE wipp_cursor
	--Release cusor resources  
	DEALLOCATE wipp_cursor
	
	
     --ILB 03/26/03
   --DELETE FROM #cfb WHERE invoice_type = 'DRP'
   DELETE FROM #cfb WHERE chargetype_desc = 'Billable Stop'

  --Reset variables
  SELECT @comm_desc = ''
  SELECT @comm_code = ''
  SELECT @invoice_number = 0
 END
--ILB 03/13/03
 
--ILB 03/31/03
SELECT  distinct @order_number = #cfb.order_number
  FROM #cfb
--ILB 03/31/03

--Create a cursor based on the select statement below
DECLARE trailer_cursor CURSOR FOR  
--SELECT IsNull(lgh.lgh_primary_pup,''), lgh.lgh_number
--  FROM legheader lgh, stops stp, #cfb
-- WHERE #cfb.order_number = stp.ord_hdrnumber and
--       stp.stp_type = 'DRP' and
--       stp.lgh_number = lgh.lgh_number

--ILB 03/31/03
SELECT IsNull(evt.evt_trailer2,''), evt.stp_number
  FROM event evt, stops stp
 WHERE evt.ord_hdrnumber = @order_number and
       evt.ord_hdrnumber = stp.ord_hdrnumber and
       stp.stp_number = evt.stp_number and
       evt.evt_trailer2 <> 'UNKNOWN'
--ILB 03/31/03
    
--Populate the cursor based on the select statement above  
OPEN trailer_cursor  
  
--Execute the initial fetch of the first secondary trailer based on the leg
FETCH NEXT FROM trailer_cursor INTO @trailer2_id, @stp_no 
  
--If the fetch is succesful continue to loop
WHILE @@fetch_status = 0  
 BEGIN  
  
  --Get the secondary trailer
  UPDATE #cfb
     SET #cfb.trailer_no2 = IsNull(@trailer2_id,'')
    FROM stops stp
   --ILB 03/31/03
   WHERE #cfb.order_number = stp.ord_hdrnumber and
	 stp.stp_number = @stp_no and
	 stp.ord_hdrnumber = @order_number
   --ILB 03/31/03
         --stp.stp_type = 'DRP' and
         --stp.lgh_number = @lgh_no
 
   --Fetch the next secondary trailer in the list
   FETCH NEXT FROM trailer_cursor INTO @trailer2_id, @stp_no
  
 END  
  
--Close cursor  
CLOSE trailer_cursor
--Release cusor resources  
DEALLOCATE trailer_cursor

--ILB 03/31/03
select @order_number = 0
--ILB 03/31/03 

UPDATE #cfb
   SET invoice_rate = ivd.ivd_rate,
       unit_basis   = ivd.ivd_unit,
       quantity     = ivd.ivd_quantity
  FROM invoicedetail ivd
 WHERE #cfb.invoice_type = 'DRP' and
       ivd.ivd_type = 'SUB' and
       #cfb.order_number = ivd.ord_hdrnumber
 
--Update the valid quantity text
UPDATE #cfb
   SET unit_basis = lf.name
  FROM labelfile lf
 WHERE lf.labeldefinition in ('FlatUnits','DistanceUnits','VolumneUnits','TimeUnits','WeightUnits','CountUnits') and
       lf.abbr = #cfb.unit_basis
 
--Update order information       
UPDATE #cfb
   SET shipper_no  = oh.ord_refnum,
       charge_type = oh.ord_charge_type,
       remark      = oh.ord_remark       
  FROM orderheader oh
 WHERE oh.ord_hdrnumber = #cfb.order_number
 
--Update reference number information
UPDATE #cfb
   SET shipper_no = rn.ref_number
  FROM referencenumber rn
 WHERE rn.ord_hdrnumber = #cfb.order_number and
       rn.ref_table = 'orderheader'
-- PTS 22967 -- BL (start)
	and rn.ref_sequence = 1
-- PTS 22967 -- BL (end)
 
--ILB 03/14/03
IF @Rateby = 'D' OR @Rateby = 'T'
 BEGIN
--ILB 03/14/03
  --Create a cursor based on the select statement below 
  DECLARE rateunit_cursor CURSOR FOR  
  SELECT quantity, invoice_rate, commodity_code, weight, order_number, invoice_number
    FROM #cfb
    
  --Populate the cursor based on the select statement above  
  OPEN rateunit_cursor  
  
  --Execute the initial fetch of the first secondary trailer based on the leg
  FETCH NEXT FROM rateunit_cursor INTO @quantity, @rate2, @commodity_code , @weight, @order_number, @invoice_number
  
  --If the fetch is succesful continue to loop
  WHILE @@fetch_status = 0  
   BEGIN  
    
    SELECT @rate_unit = ivd.ivd_rateunit, 
           @weight = ivd.ivd_wgt,
           @distance = ivd.ivd_distance	  
      FROM invoicedetail ivd
     WHERE ord_hdrnumber = @order_number and
           cmd_code = @commodity_code and  
         ivd.ivd_number = @invoice_number 
 
    IF @rate_unit = 'UNK' --rate by total    
      BEGIN
        SELECT @rate_unit = ivd.ivd_rateunit         
       FROM invoicedetail ivd
         WHERE ord_hdrnumber = @order_number and
               ivd.ivd_type = 'SUB' 
      END
   
    IF @rate_unit = 'CWT' --(Rate * Quantity)/100
       BEGIN
         SELECT @total_charge = (@quantity*@rate2)/100
 
          UPDATE #cfb
             SET total_charge = @total_charge
       WHERE commodity_code = @commodity_code and
                 invoice_number = @invoice_number
       END
 
    IF @rate_unit = 'MLB' --(Miles * weight)/10000
       BEGIN
         SELECT @total_charge = (@weight*@distance)/10000
       
     UPDATE #cfb
           SET total_charge = @total_charge
       WHERE commodity_code = @commodity_code and
                 invoice_number = @invoice_number
       END
 
    IF @rate_unit = 'FLT' --(1 * rate)
       BEGIN
         SELECT @total_charge = (1*@rate2)
       
     UPDATE #cfb
           SET total_charge = @total_charge
       WHERE commodity_code = @commodity_code and
                 invoice_number = @invoice_number
       END
 
    IF @rate_unit <> 'MLB' and @rate_unit <> 'CWT' AND @rate_unit <> 'FLT'
        BEGIN
          SELECT @total_charge = (@quantity*@rate2)     
 
          UPDATE #cfb
           SET total_charge = @total_charge
       WHERE commodity_code = @commodity_code and
                 invoice_number = @invoice_number
        END
     --Reset variables ILB 03/27/03 
     SELECT @total_charge = 0
     SELECT @rate_unit = ''
     SELECT @weight = 0
     SELECT @distance = 0     
     --ILB 03/27/03

     --Fetch the next secondary trailer in the list
     FETCH NEXT FROM rateunit_cursor INTO @quantity, @rate2, @commodity_code , @weight, @order_number,@invoice_number
   END  
  
  --Close cursor  
  CLOSE rateunit_cursor
  --Release cusor resources  
  DEALLOCATE rateunit_cursor
--ILB 03/14/03
 END
--ILB 03/14/03
 
--PTS# 17346 ILB 02/25/03
--Display the ivh_invoicenumber when the user prints a supplemental
--or miscellaneous invoice, because the order number is zero. 
SELECT @ord_hdrnumber = ord_hdrnumber, 
       @ivh_invoicenumber = ivh_invoicenumber
  FROM invoiceheader
 WHERE ivh_hdrnumber = @invoice_nbr 
 
IF @ord_hdrnumber = 0
   BEGIN
     UPDATE #cfb
        SET ord_number = @ivh_invoicenumber
   END
 
--if the showshipper and/or showconignee values for the order are 
--different than the shipper and/or consignee displayed on the order,
--the showshipper and/or showconsignee take precedence.
SELECT @ord_hdrnumber = 0
SELECT @ord_hdrnumber = order_number,
       @shipper_ID = shipper_id,
       @consignee_ID = consignee_id
  FROM #cfb
 
SELECT @showshipper = ord_showshipper,
       @showconsignee = ord_showcons
  FROM orderheader
 WHERE ord_hdrnumber = @ord_hdrnumber
 
IF (@shipper_id <> @showshipper) and (@showshipper <> 'UNKNOWN') 
   BEGIN
    UPDATE #cfb
       SET #cfb.shipper_id = @showshipper,
    	   #cfb.shipper_name = shipper.cmp_name,
           #cfb.shipper_addr1 = shipper.cmp_address1,	  
           #cfb.shipper_addr2 = shipper.cmp_address2,
	   --PTS# 19417
 	   --ILB 08/07/2003
	   #cfb.shipper_addr = Case
              			When isnull(shipper.cmp_address2,' ') = ' ' Then shipper.cmp_address1
              			When isnull(shipper.cmp_address2,' ')<> ' ' Then shipper.cmp_address1+' '+shipper.cmp_address2
              			Else ' '
             			End,	   
 	  --ILB 08/07/2003
    	  #cfb.shipper_cty_name = shipper_cty.cty_name,
          #cfb.shipper_cty_state = shipper_cty.cty_state,
          #cfb.shipper_cty_zip =  Case Rtrim(IsNull(shipper.cmp_zip,'')) When '' Then shipper_cty.cty_zip Else shipper.cmp_zip End
      FROM company shipper,city shipper_cty, #cfb
     WHERE @showshipper = shipper.cmp_id and
           shipper.cmp_city = shipper_cty.cty_code and
           #cfb.order_number = @ord_hdrnumber  
   END
 
IF (@consignee_id <> @showconsignee) and (@showconsignee <> 'UNKNOWN')
   BEGIN
     UPDATE #cfb
 	SET #cfb.consignee_id = @showconsignee,
     	    #cfb.consignee_name = consignee.cmp_name,
    	    #cfb.consignee_addr1 = consignee.cmp_address1,
     	    #cfb.consignee_addr2 = consignee.cmp_address2,
	    --PTS# 19417
 	    --ILB 08/07/2003 	    
 	    #cfb.consignee_addr = Case
      					When isnull(consignee.cmp_address2,' ') = ' ' Then consignee.cmp_address1
      					When isnull(consignee.cmp_address2,' ')<> ' ' Then consignee.cmp_address1+' '+ consignee.cmp_address2
      					Else ' '
      					End ,	
	    --ILB 08/07/2003 
	    #cfb.consignee_cty_name = consignee_cty.cty_name,
            #cfb.consignee_cty_state = consignee_cty.cty_state,
            #cfb.consignee_cty_zip = Case Rtrim(Isnull(consignee.cmp_zip,'')) When '' Then consignee_cty.cty_zip Else consignee.cmp_zip End
       FROM company consignee,city consignee_cty, #cfb
      WHERE @showconsignee = consignee.cmp_id and
            consignee.cmp_city = consignee_cty.cty_code and
            #cfb.order_number = @ord_hdrnumber 
   END
--PTS# 17346 ILB 02/25/03

IF  Exists (SELECT c.cmp_mailto_name FROM company c, #cfb t
        WHERE c.cmp_id = t.billto_id
   And RTRIM(ISNULL(c.cmp_mailto_name,'')) > ''
   And t.terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3, 
    CASE ISNULL(cmp_mailtoTermsMatchFlag,'Y') WHEN 'Y' THEN '^^' ELSE t.terms END)
   And t.linehaul_charge <> CASE ISNULL(cmp_MailtToForLinehaulFlag,'Y') WHEN 'Y' THEN 0.00 Else t.linehaul_charge + 1.00 End ) 
   UPDATE #cfb
 SET billto_name = cmp_mailto_name,
	  billto_addr = IsNull(cmp_mailto_address1,'')+' '+IsNull(cmp_mailto_address2,''),
     billto_addr1 = IsNull(cmp_mailto_address1,''),
     billto_addr2 = IsNull(cmp_mailto_address2,''),
     billto_cty_name = CASE CHARINDEX(',', company.mailto_cty_nmstct) WHEN 0 THEN company.mailto_cty_nmstct ELSE SUBSTRING(company.mailto_cty_nmstct,1, (charindex(',', company.mailto_cty_nmstct) - 1)) END,
     billto_cty_state = CASE CHARINDEX(',', company.mailto_cty_nmstct) + CHARINDEX('/', company.mailto_cty_nmstct) WHEN 0 THEN '' Else  substring(company.mailto_cty_nmstct,(charindex(',', company.mailto_cty_nmstct)+ 1),2) END,
      billto_cty_zip = ISNULL(company.cmp_mailto_zip,'')
       FROM company WHERE company.cmp_id = #cfb.billto_id

/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */
SELECT @counter = 1
WHILE @counter <>  @copies
 BEGIN
   SELECT @counter = @counter + 1
   INSERT INTO #cfb
   SELECT ord_number ,
          order_number,
          shipper_no ,
          date_shipped ,               
          driver1 ,
	  driver2 ,
	  truck_no ,
	  trailer_no ,
	  shipper_id ,
	  shipper_name ,
	  shipper_addr1 ,
	  shipper_addr2 ,
	  shipper_cty_name ,
	  shipper_cty_state ,
	  shipper_cty_zip ,
	  consignee_id ,
	  consignee_name ,
	  consignee_addr1  ,
	  consignee_addr2 ,
	  consignee_cty_name ,
	  consignee_cty_state ,
	  consignee_cty_zip ,
	  billto_id ,
	  billto_name ,
	  billto_addr1 ,
	  billto_addr2 , 
	  billto_cty_code ,
	  billto_cty_name ,
	  billto_cty_state ,
	  billto_cty_zip ,
	  commodity_code ,
	  commodity_desc ,
	  charge_type ,
	  remark ,
	  invoice_number ,
	  shipper_addr ,
	  consignee_addr ,
	  bill_date ,
	  invoice_remark ,
	  weight ,  
	  total_charge,   
	  billto_addr ,
	  terms ,
	  invoice_rate,
	  chargetype_desc,
	  invoice_type,
	  trailer_no2,
	  linehaul_charge,
	  billdate,
	  quantity,
	  charge_basis,
	  unit_basis,
	  @counter
     FROM #cfb
    WHERE copies = 1   
 END
 
  --ILB 03/13/03
  --Get the invoiceheader total charge for the order selected
  SELECT @ivh_sum = ivh_totalcharge
    FROM invoiceheader
   WHERE ivh_hdrnumber = @invoice_nbr 
 
  --Get the Order Number from the temp table
  SELECT @ord_hdrnumber = 0
  SELECT @ord_hdrnumber = order_number
    FROM #cfb
 
  --Get the sum of the invoicedetail records total_charge
  SELECT @ivd_sum = sum(total_charge)
    FROM #cfb
   WHERE order_number = @ord_hdrnumber
 /*
  --Create a cursor based on the select statement below 
  DECLARE invoicenumber_cursor CURSOR FOR  
  SELECT  invoice_number, invoice_type
    FROM #cfb
    
  --Populate the cursor based on the select statement above  
  OPEN invoicenumber_cursor 
  
  --Execute the initial fetch of the the invoice type and invoice number
  FETCH NEXT FROM invoicenumber_cursor INTO @invoice_number,@type  
  
  --If the fetch is succesful continue to loop
  WHILE @@fetch_status = 0  
   BEGIN
 
    --Set sort to reflect the sort displayed on the invoice
    Update #cfb
       set invoice_type = CAST(@invoice_number AS VARCHAR(4096))
     WHERE invoice_number = @invoice_number   
     --set invoice_type = convert(varchar, rate)
    --ILB 03/13/03

    --Fetch the next invoice type and invoice number in the list
    FETCH NEXT FROM invoicenumber_cursor INTO @invoice_number,@type  
   END  
  
  --Close cursor  
  CLOSE invoicenumber_cursor
  --Release cusor resources  
  DEALLOCATE invoicenumber_cursor
*/ 
--ILB 03/14/03
--This accounts for when total_charge on the invoicedetails
--are null for zero balance invoices.
--Verify the Detail records are equivalent to the Header record

--ILB 07/07/03 REMOVE TOTAL CHECK PER CAST
--IF (abs(isnull(@ivh_sum,0.00) - isnull(@ivd_sum,0.00))<.01) 
--BEGIN
 SELECT * FROM #cfb
  order by invoice_number 
--END
--ILB 07/07/03 REMOVE TOTAL CHECK PER CAST
GO
GRANT EXECUTE ON  [dbo].[d_cast_freightbill] TO [public]
GO
