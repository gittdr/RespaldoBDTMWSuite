SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_groundair_billoflading](@ordnum int)
AS
/**
 * DESCRIPTION:
 *
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

declare @charge_type varchar(30), @quantity float, @rate float, @charge float,
        @sr int, @bol int, @ord_rate float, @ord_hdrnumber int,
        @showshipper varchar(8), @shipper_id varchar(8), @consignee_id varchar(8),
        @showconsignee varchar(8), @REMARKS VARCHAR(256), @TERMS VARCHAR(20)

CREATE TABLE #gabol (
SR varchar(12) NULL,
BOL varchar(30) NULL,
GROSS FLOAT NULL,
MILES INT NULL,
CHT_ITEMCODE VARCHAR(30)NULL,
remarks varchar(254)null,
total_charge money NULL,
DELIVERY_INSTR varchar(254)null,
ship_date datetime NULL, 
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
billto_id varchar(8) NULL,
billto_name varchar(100) NULL,
billto_addr1  varchar(100) NULL,
billto_addr2 varchar(100) NULL,
billto_cty_code INT NULL,
billto_cty_name varchar(18) NULL,
billto_cty_state varchar(6) NULL,
billto_cty_zip varchar(10) NULL,
billto_addr varchar(201) NULL,
DRIVER1 varchar(25) null,
DRIVER2 varchar(25) null,
TRACTOR varchar(8) null,
TRAILER1 varchar(8) null,
TRAILER2 varchar(13)null,
LANE1 VARCHAR(12) NULL,
LANE2 INT NULL,
LANE3 VARCHAR(12) NULL,
FGT_DESCRIPTION varchar(60)null,
ORD_RATE MONEY null,
ORD_TERMS VARCHAR(20)NULL,
ORD_HDRNUMBER INT NULL,
ORD_RATEUNIT VARCHAR(6) NULL,
FGT_WEIGHT float null
)

INSERT INTO  #gabol 
SELECT       
       ORD.ORD_NUMBER ,
       '',
       ORD.ORD_QUANTITY ,
       ORD.ORD_TOTALMILES ,
       ORD.CHT_ITEMCODE ,            
       ORD.ORD_REMARK ,       
       ORD.ORD_CHARGE ,
       STP.STP_COMMENT ,      
       ORD.ORD_ORIGIN_EARLIESTDATE ,
       ORD.ORD_ORIGINPOINT ,
       shipper.cmp_name  ,
       shipper.cmp_address1 ,
       shipper.cmp_address2 ,
       shipper_cty.cty_name ,
       shipper_cty.cty_state ,
       shipper_cty.cty_zip ,
       Case
	     When isnull(shipper.cmp_address2,' ') = ' ' Then shipper.cmp_address1
	     When isnull(shipper.cmp_address2,' ')<> ' ' Then shipper.cmp_address1+' '+shipper.cmp_address2
	     Else ' '
	     End ,	
       ORD.ORD_DESTPOINT ,
       consignee.cmp_name ,
       consignee.cmp_address1 ,
       consignee.cmp_address2 ,
       consignee_cty.cty_name ,
       consignee_cty.cty_state ,
       consignee_cty.cty_zip ,       
       Case
	     When isnull(consignee.cmp_address2,' ') = ' ' Then consignee.cmp_address1
	     When isnull(consignee.cmp_address2,' ')<> ' ' Then consignee.cmp_address1+' '+ consignee.cmp_address2
	     Else ' '
	     End ,
       ORD.ORD_BILLTO ,
       billto.cmp_name ,
       billto.cmp_address1 ,
       billto.cmp_address2 ,	
       billto.cmp_city ,
       (select cty_name 
         from city 
         where cty_code = billto.cmp_city ),
       (select cty_state 
          from city 
         where cty_code = billto.cmp_city ),
       (select cty_zip 
          from city 
         where cty_code = billto.cmp_city ),       
       Case
	     When isnull(billto.cmp_address2,' ') = ' ' Then billto.cmp_address1
	     When isnull(billto.cmp_address2,' ')<> ' ' Then billto.cmp_address1+' '+ billto.cmp_address2
	     Else ' '
	     End ,	       
       Case
	     When isnull(MP1.MPP_FIRSTNAME,' ') = ' ' Then MP1.MPP_LASTNAME
	     When isnull(MP1.MPP_LASTNAME,' ')<> ' ' Then MP1.MPP_LASTNAME +','+ SUBSTRING(MP1.MPP_FIRSTNAME,1,1)
	     Else ' '
	     End ,
       Case
	     When isnull(MP2.MPP_FIRSTNAME,' ') = ' ' Then MP2.MPP_LASTNAME
	     When isnull(MP2.MPP_LASTNAME,' ')<> ' ' Then MP2.MPP_LASTNAME +','+ SUBSTRING(MP2.MPP_FIRSTNAME,1,1)
	     Else ' '
	     End ,
       LGH.LGH_TRACTOR ,
       LGH.LGH_PRIMARY_TRAILER ,
       LGH.LGH_PRIMARY_PUP ,
       ORD.TAR_TARRIFFNUMBER,
       ORD.TAR_NUMBER,
       ORD.TAR_TARIFFITEM,
       FGT.FGT_DESCRIPTION,
       ORD.ORD_RATE,
       ORD.ORD_TERMS, 
       ORD.ORD_HDRNUMBER ,
       ORD_RATEUNIT, 
       FGT.FGT_WEIGHT      

FROM  ORDERHEADER ORD  LEFT OUTER JOIN  company shipper  ON  ORD.ord_shipper  = shipper.cmp_id   
		LEFT OUTER JOIN  company consignee  ON  ORD.ord_consignee  = consignee.cmp_id   
		LEFT OUTER JOIN  company billto  ON  ORD.ord_billto  = billto.cmp_id   
		LEFT OUTER JOIN  city consignee_cty  ON  ORD.ORD_destcity  = consignee_cty.cty_code   
		LEFT OUTER JOIN  city shipper_cty  ON  ORD.ORD_origincity  = shipper_cty.cty_code ,
	  LEGHEADER LGH  LEFT OUTER JOIN  MANPOWERPROFILE MP1  ON  LGH.LGH_DRIVER1  = MP1.MPP_ID   
		LEFT OUTER JOIN  MANPOWERPROFILE MP2  ON  LGH.LGH_DRIVER2  = MP2.MPP_ID ,
	 STOPS STP,
	 FREIGHTDETAIL FGT 

WHERE	 ORD.ORD_HDRNUMBER  = @ORDNUM
 AND	STP.ORD_HDRNUMBER  = ORD.ORD_HDRNUMBER
 AND	STP.ORD_HDRNUMBER  = LGH.ORD_HDRNUMBER
 AND	STP.STP_NUMBER  = FGT.STP_NUMBER
 AND	STP.STP_EVENT  = 'LUL'

--Create a cursor based on the select statement below
--Get accesorials which have been attached pre-invoicing
DECLARE accesorial_cursor CURSOR FOR  
SELECT ivd.cht_itemcode, 
       ivd.ivd_quantity, 
       ivd.ivd_rate, 
       ivd.ivd_charge
  FROM invoicedetail ivd
 WHERE ivd.ord_hdrnumber = @ordnum and
       ivd.ivd_type = 'LI'  
    
--Populate the cursor based on the select statement above  
OPEN accesorial_cursor  
  
--Execute the initial fetch of the first secondary trailer based on the leg
FETCH NEXT FROM accesorial_cursor INTO @charge_type, 
				       @quantity, 
				       @rate, 
				       @charge                                         
 
--If the fetch is succesful continue to loop
WHILE @@fetch_status = 0  
 BEGIN  
  
  --Create an accessorial record
  INSERT INTO #gabol DEFAULT VALUES

  --Get order# and order header values
  select @sr = sr,
         @bol = bol
    from #gabol
   where ord_hdrnumber = @ordnum

  --Populate the new accessorial record
  UPDATE #gabol
     SET sr = @sr,
         bol = @bol,
         gross = @quantity,
         ord_rate = @rate,
         cht_itemcode = @charge_type,
         total_charge = @charge
    WHERE SR IS NULL

  UPDATE #gabol
     set fgt_description = cht.cht_description
    from chargetype cht, #gabol
   where cht.cht_itemcode = #gabol.cht_itemcode
   
  --Fetch the next secondary trailer in the list
  FETCH NEXT FROM accesorial_cursor INTO @charge_type, @quantity, @rate, @charge
  
 END  
  
--Close cursor  
CLOSE accesorial_cursor
--Release cusor resources  
DEALLOCATE accesorial_cursor

--Display Show Shipper/Consignee if applicable
select @ord_hdrnumber = ord_hdrnumber,
       @shipper_id = shipper_id,
       @consignee_id = consignee_id
  from #gabol

select @showshipper   = ord_showshipper,
       @showconsignee = ord_showcons
  from orderheader
 where ord_hdrnumber = @ord_hdrnumber

If (@shipper_id <> @showshipper) and (@showshipper <> 'UNKNOWN') 
   Begin
    Update #gabol
       set #gabol.shipper_id = @showshipper,
	   #gabol.shipper_name = shipper.cmp_name,
           #gabol.shipper_addr1 = shipper.cmp_address1,
           #gabol.shipper_addr2 = shipper.cmp_address2,
	   #gabol.shipper_cty_name = shipper_cty.cty_name,
           #gabol.shipper_cty_state = shipper_cty.cty_state,
           #gabol.shipper_cty_zip = shipper_cty.cty_zip
       from company shipper,city shipper_cty, #gabol
      where @showshipper = shipper.cmp_id and
            shipper.cmp_city = shipper_cty.cty_code and
            #gabol.sr = @ord_hdrnumber  
   End

If (@consignee_id <> @showconsignee) and (@showconsignee <> 'UNKNOWN')
   Begin
     Update #gabol
	set #gabol.consignee_id = @showconsignee,
	    #gabol.consignee_name = consignee.cmp_name,
            #gabol.consignee_addr1 = consignee.cmp_address1,
            #gabol.consignee_addr2 = consignee.cmp_address2,
	    #gabol.consignee_cty_name = consignee_cty.cty_name,
            #gabol.consignee_cty_state = consignee_cty.cty_state,
            #gabol.consignee_cty_zip = consignee_cty.cty_zip
       from company consignee,city consignee_cty, #gabol
      where @showconsignee = consignee.cmp_id and
            consignee.cmp_city = consignee_cty.cty_code and
            #gabol.sr = @ord_hdrnumber	
   End

--Insert remarks for every record, to allow the remarks to display at the 
--end of each BOL form
SELECT @REMARKS = REMARKS 
  FROM #GABOL 
 WHERE ORD_HDRNUMBER = @ORDNUM

UPDATE #GABOL
   SET REMARKS = @REMARKS

--Display the credit text value instead of the code
SELECT @terms = ord_terms
  FROM #GABOL
 WHERE ORD_HDRNUMBER = @ORDNUM

Update #gabol
   set #gabol.ord_terms = labelfile.name 
  from labelfile,#gabol
 where labelfile.abbr = @TERMS

--Display the BOL number
Update #GABOL
   set bol = referencenumber.ref_number
  from referencenumber
 where referencenumber.ord_hdrnumber = @ordnum and
       referencenumber.ref_type = 'BL#' and
       referencenumber.ref_table = 'orderheader'      
       

SELECT * FROM #gabol
GO
GRANT EXECUTE ON  [dbo].[d_groundair_billoflading] TO [public]
GO
