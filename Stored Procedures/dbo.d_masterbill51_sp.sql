SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill51_sp] (@p_reprintflag varchar(10),@p_mbnumber int,@p_billto varchar(8), 
	                       @p_revtype1 varchar(6), @p_revtype2 varchar(6),@p_mbstatus varchar(6),
	                       @p_shipstart datetime,@p_shipend datetime,@p_billdate datetime, 
                               @p_shipper varchar(8), @p_consignee varchar(8),
                               @p_copy int,@p_ivh_invoicenumber varchar(12))
AS


/*
 * 
 * NAME:d_masterbill51_sp
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoices 
 * based on the Billto selected in the interface.
 *
 * RETURNS:
 * 0  - uniqueness has not been violated 
 * >0 - uniqueness has been violated   
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_reprintflag, int, input, null;
 *       Has the masterbill been printed
 * 002 - @p_mbnumber, varchar(20), input, null;
 *       masterbill number
 * 003 - @p_billto, varchar(6), input, null;
 *       Billto selected
 * 004 - @p_revtype1, varchar(8), input, null;
 *       revtype 1 value
 * 005 - @p_revtype2, varchar(8), input, null;
 *       revtype 2 value
 * 006 - @p_mbstatus, int, output, null;
 *       status of masterbill ie XFR 
 * 007 - @p_shipstart, int, input, null;
 *       start date
 * 008 - @p_shipend, varchar(20), input, null;
 *       end date
 * 009 - @p_billdate, varchar(6), input, null;
 *       bill date
 * 010 - @p_shipper, varchar(8), input, null;
 *       number of copies requested
 * 011 - @p_consignee, varchar(8), input, null;
 *       number of copies requested
 * 012 - @p_copy, varchar(8), input, null;
 *       number of copies requested
 * 013 - @p_ivh_invoicenumber varchar(12), input null;
 *       invoice header number

 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 - PTSnnnnn - AuthorName -Revision Description 
 * 10/7/99      -          - dpete      -retrieve cmp_id for d_mb_format05
 *              - pts6691  - dpete      -make ivd_count and volume floats on temp table
 * 07/25/2002	- PTS14924 - Vern Jewett-lengthen ivd_description from 30 to 60 chars.
 * 04/12/2006   - PTS25132 - Imari Bremer - Create new masterbill format for TruckLoad Services
 **/



DECLARE @v_int0  int, @v_minord int , @v_minstp int, @v_tariffkey_startdate datetime,
        @v_ref_number varchar(20),
@v_MinShipper varchar(100), 
@v_MinShipperAddr varchar(100) ,
@v_MinShipperAddr2 varchar(100)  ,
@v_MinShipperNmctst varchar(47)   ,
@v_MinShipperZip VARCHAR(10) ,
@v_MinCon varchar(100) , 
@v_MinConAddr varchar(100) ,
@v_MinConAddr2 varchar(100)  ,
@v_MinConNmctst varchar(47),
@v_MinConZip varchar(10),
@v_tar_tariffitem varchar(12),
@v_tar_number int,
@v_showcons varchar(8),
@v_showshipper varchar(8),
@v_MinShipperAddr3 varchar(100)  ,
@v_MinConAddr3 varchar(100),
@v_MinShipperCountry varchar(50),
@v_MinConsigneeCountry varchar(50),
@v_MinBilltoCountry varchar(50),
@v_MinBilltoNmctst varchar(50),
@v_length float,
@v_width float,
@v_height float


SELECT @v_int0 = 0
SELECT @p_shipstart = convert(char(12),@p_shipstart)+'00:00:00'
SELECT @p_shipend   = convert(char(12),@p_shipend  )+'23:59:59'
Set @v_MinOrd = 0


CREATE TABLE #masterbill_temp (ord_hdrnumber int,
		ivh_invoicenumber varchar(12),  
		ivh_hdrnumber int NULL, 
		ivh_billto varchar(8) NULL,
		ivh_shipper varchar(8) NULL,
		ivh_consignee varchar(8) NULL,
		ivh_totalcharge money NULL,   
		ivh_originpoint  varchar(8) NULL,  
		ivh_destpoint varchar(8) NULL,   
		ivh_origincity int NULL,   
		ivh_destcity int NULL,   
		ivh_shipdate datetime NULL,   
		ivh_deliverydate datetime NULL,   
		ivh_revtype1 varchar(6) NULL,
		ivh_mbnumber int NULL,
		ivh_shipper_name varchar(100) NULL ,
		ivh_shipper_address varchar(100) NULL,
		ivh_shipper_address2 varchar(100) NULL,
		ivh_shipper_nmstct varchar(47) NULL ,
		ivh_shipper_zip varchar(10) NULL,
		ivh_billto_name varchar(100)  NULL,
		ivh_billto_address varchar(100) NULL,
		ivh_billto_address2 varchar(100) NULL,
		ivh_billto_nmstct varchar(47) NULL ,
		ivh_billto_zip varchar(10) NULL,
		ivh_consignee_name varchar(100)  NULL,
		ivh_consignee_address varchar(100) NULL,
		ivh_consignee_address2 varchar(100) NULL,
		ivh_consignee_nmstct varchar(47)  NULL,
		ivh_consignee_zip varchar(10) NULL,
		origin_nmstct varchar(30) NULL,
		origin_state varchar(6) NULL,
		dest_nmstct varchar(30) NULL,
		dest_state varchar(6) NULL,
		billdate datetime NULL,
		cmp_mailto_name varchar(30)  NULL,
		bill_quantity float  NULL,
		ivd_weight float NULL,
		ivd_weightunit char(6) NULL,
		ivd_count float NULL,
		ivd_countunit char(6) NULL,
		ivd_volume float NULL,
		ivd_volunit char(6) NULL,
		ivd_unit char(6) NULL,
		ivd_rate money NULL,
		ivd_rateunit char(6) NULL,
		ivd_charge money NULL,
		cht_description varchar(30) NULL,
		cht_primary char(1) NULL,
		cmd_name varchar(60)  NULL,
		--vmj1+
		ivd_description varchar(60) NULL,
--		ivd_description varchar(30) NULL,
		--vmj1-
		ivd_type char(6) NULL,
		stp_city int NULL,
		stp_cty_nmstct varchar(25) NULL,
		ivd_sequence int NULL,
		stp_number int NULL,
		copy int NULL,
		cmp_id varchar(8) NULL,
		ivh_billto_address3 varchar(100) null,
                tar_tariffitem varchar(12) null,
                stp_refnum varchar(20) null,
                trk_startdate datetime null,
                tar_number int null,
                cmp_altid varchar(25)null,
		ivh_showshipper varchar(25)null,  
        	ivh_showcons varchar (8) null,
		cmp_name varchar(100)null,
                ivh_trailer varchar(13) null,
                ivh_tractor varchar(8) null ,
                ivh_user_id1 varchar(20) null,
                ivh_shipper_address3 varchar(100) null,
                ivh_consignee_address3 varchar(100) null,
		billto_country  varchar(50) null,
		shipper_country varchar(50) null,
		consignee_country varchar(50) null,
		fgt_length float null,
		fgt_height float null,
		fgt_width float null,
                ivh_invoicestatus varchar(6) null,
                Balance_due float null,
                Total_Paid float null,
                ivh_revtype2 varchar(60),
        	revtype1_desc varchar(20),
 		revtype2_desc varchar(20))


-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@p_reprintflag) = 'REPRINT' 
  BEGIN
    INSERT INTO	#masterbill_temp
    SELECT 	IsNull(invoiceheader.ord_hdrnumber, -1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		invoiceheader.ivh_billto,
		invoiceheader.ivh_shipper,
		invoiceheader.ivh_consignee,   
		invoiceheader.ivh_totalcharge,   
		invoiceheader.ivh_originpoint,  
		invoiceheader.ivh_destpoint,   
		invoiceheader.ivh_origincity,   
		invoiceheader.ivh_destcity,   
		invoiceheader.ivh_shipdate,   
		invoiceheader.ivh_deliverydate,   
		invoiceheader.ivh_revtype1,
		invoiceheader.ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 	ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),
	 	ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),
	 	ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
			      WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN   0
			      ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
			      END),''),
		ivh_shipto_zip = ISNULL(cmp2.cmp_zip,''),
		ivh_billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	    ivh_billto_address = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	    ivh_billto_address2 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	    ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) -1
						      END),'')
	    END,
	    ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		ivh_consignee_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	    ivh_consignee_address = ISNULL(cmp3.cmp_address1,''), 
	    ivh_consignee_address2 = ISNULL(cmp3.cmp_address2,''),
	    ivh_consignee_nmstct =ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
			      WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN   0
			      ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
			      END),'') ,
	    ivh_consignee_zip =ISNULL(cmp3.cmp_zip,''),
		cty1.cty_nmstct   origin_nmstct,
		cty1.cty_state		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state		dest_state,
		ivh_billdate      billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		IsNull(ivd.ivd_wgt, 0),
		IsNull(ivd.ivd_wgtunit, ''),
		IsNull(ivd.ivd_count, 0),
		IsNull(ivd.ivd_countunit, ''),
		IsNull(ivd.ivd_volume, 0),
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
		IsNull(ivd.ivd_rate, 0),
		IsNull(ivd.ivd_rateunit, ''),
		ivd.ivd_charge,
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		IsNull(ivd_description, ''),
		ivd.ivd_type,
		stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@p_copy,
		ivd.cmp_id cmp_id,
		ivh_billto_address3 = 
   		 CASE
 			WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
 			WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
 			ELSE ''
    		 END,
		'',
		0,--first reference number for each stop
		@v_tariffkey_startdate,
		0,
                '', --placeholder for billto alt id
		ivh_showshipper,
                ivh_showcons,
                '', --place holder for company name
		ivh_trailer,
                ivh_tractor ,
                ivh_user_id1,
                cmp2.cmp_address3,
		cmp3.cmp_address3  ,
                --PTS# 27140 ILB 03/09/2005
		isnull(cmp1.cmp_country,''),
		@v_MinShipperCountry shipper_country,
		@v_MinConsigneeCountry consignee_country,
                --06/02/2005 ILB
		--isnull(fgt.fgt_length,0),
		--isnull(fgt.fgt_height,0),
		--isnull(fgt.fgt_width,0),
                0,--length
                0,--height
                0,--width
                --06/02/2005 ILB
		ivh_invoicestatus,
                0, --Balance Due
                0, --Total_Paid,
                ivh_revtype2,
                '',
                ''
		--PTS# 27140 ILB 03/09/2005           
    FROM 	
		company cmp1, 
		company cmp2,
		company cmp3,
		city cty1, 
		city cty2, 		
                invoiceheader join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
                join chargetype as cht on (ivd.cht_itemcode = cht.cht_itemcode)
		left outer join stops as stp on (ivd.stp_number = stp.stp_number)
                left outer join commodity as cmd on (ivd.cmd_code = cmd.cmd_code)
		--chargetype cht,		
		--invoiceheader, 
		--invoicedetail ivd, 
		--commodity cmd,
		--stops stp,
                --06/02/2005 ILB
		--,
		--freightdetail fgt
                --06/02/2005 ILB
   WHERE	( invoiceheader.ivh_mbnumber = @p_mbnumber )		
		AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
		AND (cmp3.cmp_id = invoiceheader.ivh_consignee) 
		AND (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND (cty2.cty_code = invoiceheader.ivh_destcity)		
		AND (@p_shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@p_consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		--AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		--AND (ivd.cht_itemcode = cht.cht_itemcode)
		--AND (ivd.stp_number *= stp.stp_number)
		--AND (ivd.cmd_code *= cmd.cmd_code)
		--06/02/2005 ILB
		--PTS# 27140 ILB 03/08/2005
  		--AND (ivd.stp_number *= fgt.stp_number) 
    		--PTS# 27140 ILB 03/08/2005 
		--06/02/2005 ILB


      SELECT @v_MinOrd = MIN(ord_hdrnumber) FROM #masterbill_temp
      SELECT @v_MinShipper = ivh_shipper_Name, 
	     @v_MinShipperAddr = ivh_shipper_Address ,
             @v_MinShipperAddr2 = ivh_shipper_Address2 ,
             @v_MinShipperNmctst = ivh_shipper_nmstct ,
             @v_MinShipperZip = ivh_shipper_zip ,
             @v_MinCon = ivh_consignee_name, 
	     @v_MinConAddr = ivh_consignee_Address ,
             @v_MinConAddr2 = ivh_consignee_Address2 ,
             @v_MinConNmctst = ivh_consignee_nmstct ,
             @v_MinConZip = ivh_consignee_zip,
             @v_showcons = ivh_showcons,
             @v_showshipper = ivh_showshipper , 
             @v_MinShipperAddr3 = ivh_shipper_address3,    
             @v_MinConAddr3 = ivh_consignee_address3,
             @v_MinBilltoCountry = billto_country
        FROM #masterbill_temp where ord_hdrnumber = @v_minord

	--PTS# 27140 ILB 03/09/2005
        select @v_MinShipperCountry = isnull(cmp_country,'')	       
          from company
         where cmp_id = @v_showshipper
        
	IF UPPER(@v_MinShipperCountry) = 'MX' or UPPER(@v_MinShipperCountry) = 'MEX' or UPPER(@v_MinShipperCountry) = 'MEXICO'
		BEGIN
		  SELECT @v_MinShipperNmctst = city.alk_city+','+isnull(cmp.cmp_state, '')
		    FROM company cmp, city 
		   WHERE cmp.cmp_id = @v_showshipper and
			 cmp.cmp_city = city.cty_code and 
                         cmp.cmp_country IN('MX','MEX','MEXICO')		
		END

	
        select @v_MinConsigneeCountry = isnull(cmp_country,'')
          from company
         where cmp_id = @v_showcons	

	IF UPPER(@v_MinConsigneeCountry) = 'MX' or UPPER(@v_MinConsigneeCountry) = 'MEX' or UPPER(@v_MinConsigneeCountry) = 'MEXICO'
		BEGIN
		  SELECT @v_MinConNmctst = city.alk_city+','+isnull(cmp.cmp_state, '')
		    FROM company cmp, city 
		   WHERE cmp.cmp_id = @v_showcons and
			 cmp.cmp_city = city.cty_code and 
                         cmp.cmp_country IN('MX','MEX','MEXICO')		
		END
	
	--END PTS# 27140 ILB 03/09/2005

	--Get the Billto information based on the first order
	select @v_MinBilltoNmctst = city.alk_city+','+isnull(company.cmp_state,'')         
	  from #masterbill_temp, company,city  
	 where #masterbill_temp.ord_hdrnumber =  @v_minord and
	       company.cmp_id = #masterbill_temp.ivh_billto and
	       company.cmp_city = city.cty_code      	

	select @v_tar_tariffitem = isnull(ivh.tar_tariffitem,''),
               @v_tar_number  = ivh.tar_number
          from invoiceheader ivh
         where ivh.ord_hdrnumber = @v_minord   

      Update #masterbill_temp
         set #masterbill_temp.tar_tariffitem = @v_tar_tariffitem,
             #masterbill_temp.tar_number     = @v_tar_number

      UPDATE #masterbill_temp
         SET ivh_shipper_name = @v_minshipper,
	     ivh_shipper_address = @v_minshipperaddr,
	     ivh_shipper_address2 = @v_minshipperaddr2,
	     ivh_shipper_address3= @v_MinShipperAddr3 ,    
	     ivh_shipper_nmstct = @v_minshippernmctst,
	     ivh_shipper_zip = @v_minshipperzip,
	     ivh_consignee_name = @v_mincon,
	     ivh_consignee_address = @v_minconaddr,
	     ivh_consignee_address2 = @v_minconaddr2,
	     ivh_consignee_address3 = @v_MinConAddr3,   
	     ivh_consignee_nmstct = @v_minconnmctst,
	     ivh_consignee_zip = @v_minconzip,
             ivh_showcons = @v_showcons,
             ivh_showshipper = @v_showshipper,
	     --END PTS# 27140 ILB 03/09/2005 
             shipper_country = @v_MinShipperCountry,
             consignee_country = @v_MinConsigneeCountry 
	     --END PTS# 27140 ILB 03/09/2005                      

	UPDATE #masterbill_temp
           SET #masterbill_temp.cmp_name = company.cmp_name  
          FROM company,#masterbill_temp    
	 WHERE #masterbill_temp.cmp_id = company.cmp_id
                            
     --Set the stp_refnum column equal to the first stop reference number for 
     --for each stop	
     Set @v_MinOrd = 0
     Set @v_MinStp = 0
     --06/01/2005 ILB
     Set @v_length = 0 
     Set @v_width  = 0
     Set @v_height = 0
     --06/01/2005 ILB

     WHILE (SELECT COUNT(*) FROM #masterbill_temp WHERE ord_hdrnumber > @v_MinOrd) > 0
	BEGIN
	  
	  SELECT @v_MinOrd = (SELECT MIN(ord_hdrnumber) 
                              FROM #masterbill_temp 
                             WHERE ord_hdrnumber > @v_MinOrd)	

	  UPDATE #masterbill_temp
             SET IVH_TRACTOR = '',
                 IVH_TRAILER = ''
           WHERE ORD_HDRNUMBER = @v_MINORD AND
                 IVD_SEQUENCE <> (SELECT MAX(IVD_SEQUENCE)
                                   FROM #masterbill_temp
                                  WHERE ORD_HDRNUMBER = @v_MINORD)	
          
	  WHILE (SELECT COUNT(*) FROM invoicedetail WHERE stp_number > @v_MinStp and ord_hdrnumber = @v_MinOrd) > 0	  
	  
		BEGIN	

		    	--Get the first stop for the current order.
		        select @v_MinStp = min(stp_number)
		          from invoicedetail 
	                 where ord_hdrnumber = @v_MinOrd and 
	                       stp_number is not null and
                               stp_number > @v_MinStp 		
			
		        --Get the first reference number for the current stop
		        --multiple reference numbers may exist for a single stop.
		        select @v_ref_number = ref_number
		          from referencenumber 
		         where REF_TABLE = 'STOPS' AND 
	                       REF_TABLEKEY = @v_MinStp AND
			       --PTS#25445 ILB 11/04/2004 
                               REF_TYPE <> 'EXTOPS' AND
			       --PTS#25445 ILB 11/04/2004 
	                       ref_sequence = 1	 		 
	 
		         --Set the stp_refnum equal to the first stop number extracted
		         --based on the order header number and stop number.
			 Update #masterbill_temp
		            set stp_refnum = @v_ref_number
		          where ord_hdrnumber = @v_MinOrd and
		                stp_number = @v_MinStp
			  
			  --Reset the ref number variable
			  Set @v_ref_number = 0

			  --06/02/2005 ILB
			  --Get the freight information from the freight detail
			  select @v_length = fgt_length,
                                 @v_height = fgt_height,
                                 @v_width  = fgt_width
                            from freightdetail
                           where stp_number = @v_minstp

			  --Set the length, height, width from freightdetail
                          --based on the stp_number
                          Update #masterbill_temp
                             set fgt_length = @v_length,
                                 fgt_height = @v_height,
                                 fgt_width  = @v_width
                           where ord_hdrnumber = @v_MinOrd and
				 stp_number = @v_MinStp
			
			   --Reset the length, width, height  variables
                           Set @v_length = 0 
     			   Set @v_width  = 0
     			   Set @v_height = 0
			   --06/02/2005 ILB
			  
		END

	  
	END

	--Set the date for the tariff 
	update #masterbill_temp
	   set #masterbill_temp.trk_startdate = isnull(tar.trk_startdate,'')
	  from #masterbill_temp,tariffkey tar
	 where #masterbill_temp.tar_number = tar.tar_number

	--Set Billto altid	
        update #masterbill_temp  
           set #masterbill_temp.cmp_altid = company.cmp_altid	         	         
          from #masterbill_temp, company  
         where company.cmp_id = #masterbill_temp.ivh_billto

	--PTS# 27140 ILB 04/14/2005
	IF UPPER(@v_MinBilltoCountry) = 'MX' or UPPER(@v_MinBilltoCountry) = 'MEX' or UPPER(@v_MinBilltoCountry) = 'MEXICO'
		Begin
	   		update #masterbill_temp  
	          	 set ivh_billto_nmstct = @v_MinBilltoNmctst  	       
		End
	--END PTS# 27140 ILB 04/14/2005

	

  END

-- for master bills with 'RTP' status

IF UPPER(@p_reprintflag) <> 'REPRINT' 
  BEGIN
     INSERT INTO 	#masterbill_temp
     SELECT 	IsNull(invoiceheader.ord_hdrnumber,-1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		invoiceheader.ivh_billto,   
		invoiceheader.ivh_shipper,
		invoiceheader.ivh_consignee,
		invoiceheader.ivh_totalcharge,   
		invoiceheader.ivh_originpoint,  
		invoiceheader.ivh_destpoint,   
		invoiceheader.ivh_origincity,   
		invoiceheader.ivh_destcity,   
		invoiceheader.ivh_shipdate,   
		invoiceheader.ivh_deliverydate,   	
   	        invoiceheader.ivh_revtype1,
		@p_mbnumber     ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),
	 ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),
	 ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
			      WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN   0
			      ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
			      END),''),
	ivh_shipto_zip = ISNULL(cmp2.cmp_zip,''),	 
		ivh_billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_billto_address = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_billto_address2 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
						      END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
								  WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1 < 0 THEN
								     0
								  ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1
						      END),'')
	    END,
	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		ivh_consignee_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_consignee_address = ISNULL(cmp3.cmp_address1,''), 
	 ivh_consignee_address2 =ISNULL(cmp3.cmp_address2,''),
	 ivh_consignee_nmstct =ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
			      WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN   0
			      ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
			      END),''),
	ivh_consignee_zip =ISNULL(cmp3.cmp_zip,''),
		cty1.cty_nmstct   origin_nmstct,
		cty1.cty_state		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state		dest_state,
		@p_billdate	billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		IsNull(ivd.ivd_wgt, 0),
		IsNull(ivd.ivd_wgtunit, ''),
		IsNull(ivd.ivd_count, 0),
		IsNull(ivd.ivd_countunit, ''),
		IsNull(ivd.ivd_volume, 0),
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
		IsNull(ivd.ivd_rate, 0),
		IsNull(ivd.ivd_rateunit, ''),
		ivd.ivd_charge,
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		IsNull(ivd_description, ''),
		ivd.ivd_type,		stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@p_copy,
		ivd.cmp_id cmp_id,
		ivh_billto_address3 = 
	    	  CASE
	 	    WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
	 	    WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
	 	    ELSE ''
	    	    END,
	        ivd.tar_tariffnumber,
	        0, --first reference number for each stop
	        @v_tariffkey_startdate,
	        ISNULL(invoiceheader.tar_number,0),
		'', --placeholder for billto alt id
		ivh_showshipper,
                ivh_showcons,
  		'', --place holder for company name
		ivh_trailer,
                ivh_tractor  ,
		ivh_user_id1,
                cmp2.cmp_address3,
		cmp3.cmp_address3,
		--PTS# 27140 ILB 03/09/2005
		isnull(cmp1.cmp_country,''),
		@v_MinShipperCountry shipper_country,
		@v_MinConsigneeCountry consignee_country,
		--06/02/2005 ILB
		--isnull(fgt.fgt_length,0),
		--isnull(fgt.fgt_height,0),
		--isnull(fgt.fgt_width,0),
                0,--length
                0,--height
                0,--width
                --06/02/2005 ILB		
                ivh_invoicestatus,
                0, --Balance Due
                0, --Total_Paid
		ivh_revtype2,
                '',
                ''
		--PTS# 27140 ILB 03/09/2005            
	FROM 	company cmp1,
		company cmp2,
		company cmp3,
		city cty1, 
		city cty2,
		invoiceheader join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
                join chargetype as cht on (ivd.cht_itemcode = cht.cht_itemcode)
		left outer join stops as stp on (ivd.stp_number = stp.stp_number)
                left outer join commodity as cmd on (ivd.cmd_code = cmd.cmd_code)
		--stops stp, 
		--invoicedetail ivd, 
		--commodity cmd, 
		--chargetype cht
		--invoiceheader, 
		--06/02/2005 ILB
		--,
		--freightdetail fgt
                --06/02/2005 ILB                
	WHERE 	(invoiceheader.ivh_billto = @p_billto ) 		
		AND (invoiceheader.ivh_shipdate between @p_shipstart AND @p_shipend ) 
		AND (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@p_revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@p_revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
		AND (cmp1.cmp_id = invoiceheader.ivh_billto)
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
	 	AND (cmp3.cmp_id = invoiceheader.ivh_consignee)
		AND (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND (cty2.cty_code = invoiceheader.ivh_destcity)		
		AND (@p_shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@p_consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND (@p_ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master'))
		--AND (ivd.cht_itemcode = cht.cht_itemcode)
		--AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		--AND (ivd.stp_number *= stp.stp_number)
		--AND (ivd.cmd_code *= cmd.cmd_code)
                --06/02/2005 ILB
		--PTS# 27140 ILB 03/08/2005
  		--AND (ivd.stp_number *= fgt.stp_number) 
    		--PTS# 27140 ILB 03/08/2005 
		--06/02/2005 ILB	         

      SELECT @v_MinOrd = MIN(ord_hdrnumber) FROM #masterbill_temp

      SELECT @v_MinShipper = ivh_shipper_Name, 
	     @v_MinShipperAddr = ivh_shipper_Address ,
             @v_MinShipperAddr2 = ivh_shipper_Address2 ,
             @v_MinShipperNmctst = ivh_shipper_nmstct ,
             @v_MinShipperZip = ivh_shipper_zip ,
             @v_MinCon = ivh_consignee_name, 
	     @v_MinConAddr = ivh_consignee_Address ,
             @v_MinConAddr2 = ivh_consignee_Address2 ,
             @v_MinConNmctst = ivh_consignee_nmstct ,
             @v_MinConZip = ivh_consignee_zip,
             @v_showcons = ivh_showcons,
             @v_showshipper = ivh_showshipper, 
             @v_MinShipperAddr3 = ivh_shipper_address3 ,   
             @v_MinConAddr3 = ivh_consignee_address3,   
             @v_MinBilltoCountry = billto_country
        FROM #masterbill_temp where ord_hdrnumber = @v_minord

	--PTS# 27140 ILB 03/09/2005
        select @v_MinShipperCountry = isnull(cmp_country,'')	       
          from company
         where cmp_id = @v_showshipper
        
	IF UPPER(@v_MinShipperCountry) = 'MX' or UPPER(@v_MinShipperCountry) = 'MEX' or UPPER(@v_MinShipperCountry) = 'MEXICO'
		BEGIN
		  SELECT @v_MinShipperNmctst = city.alk_city+','+isnull(cmp.cmp_state, '')
		    FROM company cmp, city 
		   WHERE cmp.cmp_id = @v_showshipper and
			 cmp.cmp_city = city.cty_code and 
                         cmp.cmp_country IN('MX','MEX','MEXICO')		
		END

	
        select @v_MinConsigneeCountry = isnull(cmp_country,'')
          from company
         where cmp_id = @v_showcons	

	IF UPPER(@v_MinConsigneeCountry) = 'MX' or UPPER(@v_MinConsigneeCountry) = 'MEX' or UPPER(@v_MinConsigneeCountry) = 'MEXICO'
		BEGIN
		  SELECT @v_MinConNmctst = city.alk_city+','+isnull(cmp.cmp_state, '')
		    FROM company cmp, city 
		   WHERE cmp.cmp_id = @v_showcons and
			 cmp.cmp_city = city.cty_code and 
                         cmp.cmp_country IN('MX','MEX','MEXICO')		
		END
	
	--END PTS# 27140 ILB 03/09/2005

	--Get the Billto information based on the first order
	select @v_MinBilltoNmctst = city.alk_city+','+isnull(company.cmp_state,'')              
	  from #masterbill_temp, company,city  
	 where #masterbill_temp.ord_hdrnumber =  @v_minord and
	       company.cmp_id = #masterbill_temp.ivh_billto and
	       company.cmp_city = city.cty_code 

	select @v_tar_tariffitem = isnull(ivh.tar_tariffitem,''),
               @v_tar_number  = ivh.tar_number
          from invoiceheader ivh
         where ivh.ord_hdrnumber = @v_minord   

      Update #masterbill_temp
         set #masterbill_temp.tar_tariffitem = @v_tar_tariffitem,
             #masterbill_temp.tar_number     = @v_tar_number

      UPDATE #masterbill_temp
         SET ivh_shipper_name = @v_minshipper,
	     ivh_shipper_address = @v_minshipperaddr,
	     ivh_shipper_address2 = @v_minshipperaddr2,
	     ivh_shipper_address3= @v_MinShipperAddr3 ,    
	     ivh_shipper_nmstct = @v_minshippernmctst,
	     ivh_shipper_zip = @v_minshipperzip,
	     ivh_consignee_name = @v_mincon,
	     ivh_consignee_address = @v_minconaddr,
	     ivh_consignee_address2 = @v_minconaddr2,
	     ivh_consignee_address3 = @v_MinConAddr3,   
	     ivh_consignee_nmstct = @v_minconnmctst,
	     ivh_consignee_zip = @v_minconzip,
             ivh_showcons = @v_showcons,
             ivh_showshipper = @v_showshipper,  
	     --END PTS# 27140 ILB 03/09/2005 
             shipper_country = @v_MinShipperCountry,
             consignee_country = @v_MinConsigneeCountry 
	     --END PTS# 27140 ILB 03/09/2005     

	UPDATE #masterbill_temp
           SET #masterbill_temp.cmp_name = company.cmp_name  
          FROM company,#masterbill_temp    
	 WHERE #masterbill_temp.cmp_id = company.cmp_id

     --Set the stp_refnum column equal to the first stop reference number for 
     --for each stop	
     Set @v_MinOrd = 0
     Set @v_MinStp = 0
     --06/01/2005 ILB
     Set @v_length = 0 
     Set @v_width  = 0
     Set @v_height = 0
     --06/01/2005 ILB
     WHILE (SELECT COUNT(*) FROM #masterbill_temp WHERE ord_hdrnumber > @v_MinOrd) > 0
	BEGIN
	  
	  SELECT @v_MinOrd = (SELECT MIN(ord_hdrnumber) 
                              FROM #masterbill_temp 
                             WHERE ord_hdrnumber > @v_MinOrd)	

	  UPDATE #masterbill_temp
             SET IVH_TRACTOR = '',
                 IVH_TRAILER = ''
           WHERE ORD_HDRNUMBER = @v_MINORD AND
                 IVD_SEQUENCE <> (SELECT MAX(IVD_SEQUENCE)
                                   FROM #masterbill_temp
                                  WHERE ORD_HDRNUMBER = @v_MINORD)	
          
	  WHILE (SELECT COUNT(*) FROM invoicedetail WHERE stp_number > @v_MinStp and ord_hdrnumber = @v_MinOrd) > 0	  
	  
		BEGIN	
			--PRINT 'ORDER#'+CAST(@v_MINORD AS VARCHAR(20))
		    	--Get the first stop for the current order.
		        select @v_MinStp = min(stp_number)
		          from invoicedetail 
	                 where ord_hdrnumber = @v_MinOrd and 
	                       stp_number is not null and
                               stp_number > @v_MinStp 		
			
			--PRINT 'STOP#'+CAST(@v_MINSTP AS VARCHAR(20))
		        --Get the first reference number for the current stop
		        --multiple reference numbers may exist for a single stop.
		       	select @v_ref_number = ref_number
			  from referencenumber 
			 where REF_TABLE = 'STOPS' AND 
			       REF_TABLEKEY = @v_MinStp AND
			       --PTS#25445 ILB 11/04/2004 
			       REF_TYPE <> 'EXTOPS' AND
			       --PTS#25445 ILB 11/04/2004 
			       ref_sequence = (SELECT MIN(REF_SEQUENCE)
			                         FROM REFERENCENUMBER
			                        WHERE REF_TABLEKEY = @v_MinStp AND
			                              REF_TYPE <> 'EXTOPS')	
						 
	 		 --PRINT 'REF#'+CAST(@v_ref_number AS VARCHAR(20))
		         --Set the stp_refnum equal to the first stop number extracted
		         --based on the order header number and stop number.
			 Update #masterbill_temp
		            set stp_refnum = @v_ref_number
		          where ord_hdrnumber = @v_MinOrd and
		                stp_number = @v_MinStp
			  
			  --Reset the ref number variable
			  Set @v_ref_number = 0

			  --06/02/2005 ILB
			  --Get the freight information from the freight detail
			  select @v_length = fgt_length,
                                 @v_height = fgt_height,
                                 @v_width  = fgt_width
                            from freightdetail
                           where stp_number = @v_minstp

			  --Set the length, height, width from freightdetail
                          --based on the stp_number
                          Update #masterbill_temp
                             set fgt_length = @v_length,
                                 fgt_height = @v_height,
                                 fgt_width  = @v_width
                           where ord_hdrnumber = @v_MinOrd and
				 stp_number = @v_MinStp
			
			   --Reset the length, width, height  variables
                           Set @v_length = 0 
     			   Set @v_width  = 0
     			   Set @v_height = 0
			   --06/02/2005 ILB
			  
		END

	  
	END

	--Set the date for the tariff 
	update #masterbill_temp
	   set #masterbill_temp.trk_startdate = isnull(tar.trk_startdate,'')
	  from #masterbill_temp,tariffkey tar
	 where #masterbill_temp.tar_number = tar.tar_number

	--Set Billto altid	
        update #masterbill_temp  
           set #masterbill_temp.cmp_altid = company.cmp_altid	         	         
          from #masterbill_temp, company  
         where company.cmp_id = #masterbill_temp.ivh_billto
	
	--PTS# 27140 ILB 04/14/2005
	IF UPPER(@v_MinBilltoCountry) = 'MX' or UPPER(@v_MinBilltoCountry) = 'MEX' or UPPER(@v_MinBilltoCountry) = 'MEXICO'
		Begin
	   		update #masterbill_temp  
	          	 set ivh_billto_nmstct = @v_MinBilltoNmctst  	       
		End
	--END PTS# 27140 ILB 04/14/2005


  END  

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.stp_cty_nmstct = city.cty_nmstct
  FROM		#masterbill_temp, city 
  WHERE		#masterbill_temp.stp_city = city.cty_code 

  --27140
Update #masterbill_temp
   set revtype1_desc = l.name
  from #masterbill_temp mbtmp
       inner join labelfile l on mbtmp.ivh_revtype1 = l.abbr
 where upper(l.labeldefinition) = 'REVTYPE1'

Update #masterbill_temp
   set revtype2_desc = l.name
  from #masterbill_temp mbtmp
       inner join labelfile l on mbtmp.ivh_revtype2 = l.abbr
 where upper(l.labeldefinition) = 'REVTYPE2'
--27140

  SELECT * 
  FROM		#masterbill_temp
  ORDER BY	ord_hdrnumber, ivd_sequence

  DROP TABLE 	#masterbill_temp

GO
GRANT EXECUTE ON  [dbo].[d_masterbill51_sp] TO [public]
GO
