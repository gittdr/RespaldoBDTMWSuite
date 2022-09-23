SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create  PROC [dbo].[invoice_template95](@invoice_nbr   int,@copies  int)
AS

set nocount on 
/**
 * 
 * NAME:
 * dbo.invoice_template95 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
  * PARAMETERS:
 * 001 - @invoice_nbr int, input, null;
 *       This parameter indicates the invoice number
 *     
 * 002 - @copies int, input, null;
 *       This parameter indicates the number of copies to print.
 *
 * 
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * 10/07/1999 PTS###    - dpete                   - retrieve cmp_id for d_mb_format05
 * 00/00/0000 pts6691   - dpete                   - make ivd_count and volume floats on temp table
 * 00/00/0000 pts7230   - vjh                     - roll up some data.
 * 07/25/2002 PTS 14924 - Vern Jewett(label=vmj1) - lengthen ivd_description from 30 to 60 chars
 * 07/24/2006 PTS 33254 - Imari Bremer            - New format invoice format 95
 * 04/30/2007 PTS 37296 - multiple copies not working
 * 05/15/2007 PTS 37360 - jds; several requests:  - Added new column: ivh_remark *** ref number for misc invoices... ***
 * 05/17/2007 PTS 37485 - (Consolitate w/37360) - Bob Piskac;  invoice retrieval will fail 
 *                        with incorrect label name - testing for numeric i.e. 'NET 20'
 * 5/18/2007 (Still PTS 37360 ) - jds;  ADD Reference Number Loop for MISC Invoices (order_hrd# = 0 )
 * 5/23/2007 (Still PTS 37360 ) - jds; Made delete statement conditional (incorrectly causing Line Haul not to print for Freight default)
 * 5/23/2007 (Still PTS 37360 ) - jds; Re-number the idh_sequence for CM and ReBill
 *                                where the database contains bad seq numbers. 
 * 5/25/2007 (Still PTS 37360 ) - jds; Improved the SQL per Donna Petersen's suggestions.
**/


DECLARE @int0  int, @billto_altid varchar(25),@drp_total float, @cht_basisunit varchar(6),
@MINORD INT, @MINSEQ INT, @BILL_QTY FLOAT,
@MinOrdShpCon int,
@MinShipper varchar(100), 
@MinShipperAddr varchar(100) ,
@MinShipperAddr2 varchar(100)  ,
@MinShipperNmctst varchar(25)   ,
@MinShipperZip VARCHAR(10) ,
@MinCon varchar(100) , 
@MinConAddr varchar(100) ,
@MinConAddr2 varchar(100)  ,
@MinConNmctst varchar(25),
@MinConZip varchar(10),
@v_counter int,
@v_ret_value int,
@v_temp int,
@v_invoice_terms int,
@v_cmp_terms    varchar(10),
@v_startpos int,
@minmov int,
@Minlgh int,
@v_lgh_trailer varchar(20),
@v_lgh_tractor varchar(20),
@v_cnt int,
@v_lghcnt int,
@stp_number int,
@v_primary_tractor_type1 varchar(20),
@v_minreftype varchar(6),
@v_refdesc varchar(20),
@v_REFSTRING varchar(550),
@v_REFseq int,
@v_MinRefSeq int,
@v_MinRefNumber varchar(30),
@lgh_cnt int

SELECT @int0 = 0
SELECT @v_invoice_terms = 0
SELECT @v_cmp_terms = ''

/* SET FOR A SUCCESSFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @v_ret_value = 1  

CREATE TABLE #invoice_temp (		ord_hdrnumber int null,
		ivh_invoicenumber varchar(12)null,  
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
		ivh_shipper_name varchar(60) NULL ,
		ivh_shipper_address varchar(50) NULL,
		ivh_shipper_address2 varchar(50) NULL,
		ivh_shipper_nmstct varchar(40) NULL ,
		ivh_shipper_zip varchar(10) NULL,
		ivh_billto_name varchar(60)  NULL,
		ivh_billto_address varchar(50) NULL,
		ivh_billto_address2 varchar(50) NULL,
		ivh_billto_nmstct varchar(40) NULL ,
		ivh_billto_zip varchar(10) NULL,
		ivh_consignee_name varchar(60)  NULL,
		ivh_consignee_address varchar(50) NULL,
		ivh_consignee_address2 varchar(50) NULL,
		ivh_consignee_nmstct varchar(30)  NULL,
		ivh_consignee_zip varchar(10) NULL,
		origin_nmstct varchar(30) NULL,
		origin_state varchar(6) NULL,
		dest_nmstct varchar(30) NULL,
		dest_state varchar(6) NULL,
		billdate datetime NULL,
		cmp_mailto_name varchar(60)  NULL,
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
		ivd_description varchar(60) NULL,			
		ivd_type char(6) NULL,
		stp_city int NULL,
		stp_cty_nmstct varchar(30) NULL,
		ivd_sequence int NULL,
		stp_number int NULL,
		copy int NULL,
		cmp_id varchar(8) NULL,
		ord_firstref varchar(20) NULL,                
		ivh_totalweight float NULL,
		billto_altid varchar(25) null,
                cht_basis varchar(6) null,
                cht_basisunit varchar(6)null,
                ivd_distance float null,
                ivd_distunit char(6)null,
		ivd_groupcontrol int null,  
                billto_cmp_othertype1 varchar(6) null,
                cmp_contact varchar(30) null,
                cmp_primaryphone varchar(20) null,
		cmp_terms varchar(20) null,
                pay_date varchar(20) null,
                cust_po_no varchar(30) null,
                company_loc varchar(200)null,
                primary_tractor_type1 varchar(20)null,
                secondary_tractor_type1 varchar(20) null,               
                mov_number int null,
                tractor1 varchar(8)null,
                tractor2 varchar(8)null,
                trailer1 varchar(13) null,
                trailer2 varchar(13) null,
                reference_numbers varchar(550)null,				
		ivh_definition varchar(6) null,
                lgh_count int null,
                rebill_creditmemo varchar(30) null,
		ivh_remark varchar(254) null, -- added for PTS 37360 (add remark #s)
		ivd_number int )  -- added for PTS 37360 (Credit memo  sequence# problem)

     INSERT INTO 	#invoice_temp
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
		invoiceheader.ivh_mbnumber,		
		ivh_shipto_name = cmp2.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_shipto_address = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address1,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address1,'')
		ELSE ISNULL(cmp2.cmp_mailto_address1,'')
	    END,
	 ivh_shipto_address2 = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address2,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address2,'')
		ELSE ISNULL(cmp2.cmp_mailto_address2,'')
	    END,
	 ivh_shipto_nmstct = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN  0
			ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
			END),'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
			END),'')
		ELSE ISNULL(SUBSTRING(cmp2.mailto_cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp2.mailto_cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp2.mailto_cty_nmstct) -1
			END),'')
	    END,
	ivh_shipto_zip = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL  THEN ISNULL(cmp2.cmp_zip ,'')  
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_zip,'')
		ELSE ISNULL(cmp2.cmp_mailto_zip,'')
	    END,
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
			WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
			END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
			END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1 < 0 THEN 0
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
	 ivh_consignee_address = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_consignee_address2 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 ivh_consignee_nmstct = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
			WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
			END),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
			WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
			END),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1
			END),'')
	    END,
	ivh_consignee_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    END,
		cty1.cty_nmstct   origin_nmstct,
		cty1.cty_state		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state		dest_state,	
		invoiceheader.ivh_billdate,
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
		1 copy,  --@copies,
		ivd.cmp_id cmp_id,
		'',		
		0,
		'',--billto alt id
		cht.cht_basis,
                cht.cht_basisunit,
		ivd_distance,
                ivd_distunit,
		1,		
		cmp1.cmp_othertype1,
                cmp1.cmp_contact,
                cmp1.cmp_primaryphone,
		cmp1.cmp_terms,
		'' pay_date,
		'' cust_po_no,
                '' company_loc,
		'' primary_tractor_type1 ,
		'' secondary_tractor_type1,
		invoiceheader.mov_number,
		invoiceheader.ivh_tractor ,
                '' ,
                invoiceheader.ivh_trailer,
                '',
		'',  	
		invoiceheader.ivh_definition,
                0,
                '', --rebill_creditmemo
		ivh_remark,	---- added for PTS 37360
		ivd_number  ---- added for PTS 37360
		
	FROM 	--invoiceheader, 
		company cmp1,
		company cmp2,
		company cmp3,
		city cty1, 
		city cty2,
		--stops stp, 
		--invoicedetail ivd, 
		--commodity cmd, 
		chargetype cht,
		invoiceheader JOIN invoicedetail as ivd ON (ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )  
        	LEFT OUTER JOIN STOPS AS STP ON ( IVD.STP_NUMBER = STP.STP_NUMBER)   
         	LEFT OUTER JOIN commodity AS CMD ON (ivd.cmd_code = CMD.cmd_code) 
	WHERE 	(invoiceheader.ivh_hdrnumber = @invoice_nbr )                  
		--AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		--AND (ivd.stp_number *= stp.stp_number) 		            
		--AND (ivd.cmd_code *= cmd.cmd_code)		
		AND (cmp1.cmp_id = invoiceheader.ivh_billto)
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
	 	AND (cmp3.cmp_id = invoiceheader.ivh_consignee)
		AND (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND (cty2.cty_code = invoiceheader.ivh_destcity)
		AND (ivd.cht_itemcode = cht.cht_itemcode)
	--* donna's suggestions.... order by...
	ORDER BY ivd_sequence

  --PTS# 24399 ILB 11/15/2004
  --select @billto_altid = cmp_altid
  --  from company
  -- where cmp_id = @billto
  
  --Update #invoice_temp
  --   set billto_altid = @billto_altid  


--  PTS 37360 jds 5-25-2007. --------------------------------------------
--====================================================================================================
----* a release went out where the ivd_sequence was not reset to 1 (one) for Creditmemo's and REbills.
----* Due to this when Credit Memos and Re-Bills print - they fail to print the LINE HAUL amount.
----* the following resequences the row numbers to account for the problem.  PTS 37360 jds 5-25-2007.
--====================================================================================================

declare @v_CRD_ivh_definition varchar(6)
declare @v_CRD_ivd_sequence int
SET @v_CRD_ivh_definition = (select min(ivh_definition) from #invoice_temp)
SET @v_CRD_ivd_sequence = (select min(ivd_sequence) from #invoice_temp)

IF ( upper(@v_CRD_ivh_definition) = 'CRD' OR upper(@v_CRD_ivh_definition) = 'RBIL') AND @v_CRD_ivd_sequence <> 1
BEGIN

	select	ivd_number, 
			IDENTITY (INT, 1, 1 ) AS 'new_ivd_sequence'
			into #temp_re_sequence
			from #invoice_temp
			ORDER BY ivd_sequence	
	 
	Update #invoice_temp
	SET ivd_sequence = (select new_ivd_sequence from #temp_re_sequence				
				        where #invoice_temp.ivd_number = #temp_re_sequence.ivd_number) 

END 
-------- END OF  PTS 37360 jds 5-25-2007. -----------------------------------------------


SET @MinOrd = ''
SET @DRP_TOTAL = 0
SET @MINSEQ = 0
SET @BILL_QTY = 0 
WHILE (SELECT COUNT(*) FROM #invoice_temp WHERE ord_hdrnumber > @MinOrd) > 0
	BEGIN
	   SELECT @MinOrd = (SELECT MIN(ord_hdrnumber) FROM #invoice_temp WHERE ord_hdrnumber > @MinOrd)
	
           SELECT @BILL_QTY = BILL_QUANTITY 
	     FROM #invoice_temp 
	    WHERE ORD_HDRNUMBER = @MINORD AND
                  IVD_TYPE = 'SUB' 
	
	  IF @BILL_QTY <> 0 
	     BEGIN	
		   UPDATE #invoice_temp
	              SET BILL_QUANTITY = @BILL_QTY
	            WHERE ORD_HDRNUMBER = @MINORD AND
	                  IVD_TYPE = 'DRP'
             END             

	   --RESET VARIABLE
           SET @BILL_QTY = 0

	   WHILE (SELECT COUNT(*) FROM #invoice_temp WHERE ivd_sequence > @minseq and ord_hdrnumber = @MinOrd) > 0
	   BEGIN             
          
		select @MinSeq = min(ivd_sequence)
		  from #invoice_temp 
	         where ord_hdrnumber = @MinOrd and
                       ivd_sequence > @MinSeq 	
 	     
		select @cht_basisunit = UPPER(ivd_rateunit)	
	          from #invoice_temp
	         where ord_hdrnumber = @minord and
	               ivd_type = 'sub'	
		
	        IF @cht_basisunit = 'MIL' or @cht_basisunit = 'IN' or @cht_basisunit = 'MM' or 
		   @cht_basisunit = 'FT' or @cht_basisunit = 'CM' or @cht_basisunit = 'KMS' or 
	           @cht_basisunit = 'HUB' 

	         begin
		   SELECT @DRP_TOTAL = SUM(IVD_DISTANCE)
	             from #invoice_temp
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP' AND
                          IVD_SEQUENCE = @MINSEQ
	
		   UPDATE #invoice_temp
	              SET IVD_DISTANCE = @DRP_TOTAL,
                          IVD_WEIGHT = 0,
                          IVD_VOLUME = 0,
                          IVD_COUNT = 0
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP' AND
                          IVD_SEQUENCE = @MINSEQ	
	         end
	
		IF @cht_basisunit = 'LBS' OR @cht_basisunit = 'KGS' or @cht_basisunit = 'MTN' or 
	           @cht_basisunit = 'TON' OR @cht_basisunit = 'CWT'  
	         begin
		   SELECT @DRP_TOTAL = SUM(IVD_WEIGHT)
	             from #invoice_temp
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
	
		   UPDATE #invoice_temp
	              SET IVD_WEIGHT = @DRP_TOTAL,
                          IVD_DISTANCE = 0,
                          IVD_VOLUME = 0,
                          IVD_COUNT = 0
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
	
	         end
	
		IF @cht_basisunit = 'PCS' OR @cht_basisunit = 'BOX' or @cht_basisunit = 'SLP' or 
	           @cht_basisunit = 'CAS' or @cht_basisunit = 'PLT' or @cht_basisunit = 'COIL' 
	         begin
		   SELECT @DRP_TOTAL = SUM(IVD_COUNT)
	             from #invoice_temp
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
	
		    UPDATE #invoice_temp
	              SET IVD_COUNT = @DRP_TOTAL,
			  IVD_WEIGHT = 0,
                          IVD_VOLUME = 0,
                          IVD_DISTANCE = 0
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
		   
	         end
	
		IF @cht_basisunit = 'GAL' OR @cht_basisunit = 'BSH' or @cht_basisunit = 'LTR' or 
		   @cht_basisunit = 'CYD' or @cht_basisunit = 'CMM' or @cht_basisunit = 'CUB' 
	         
		BEGIN
		   SELECT @DRP_TOTAL = SUM(IVD_VOLUME)
	             from #invoice_temp
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
	
		    UPDATE #invoice_temp
	              SET IVD_VOLUME = @DRP_TOTAL,
                          IVD_WEIGHT = 0,
                          IVD_DISTANCE = 0,
                          IVD_COUNT = 0
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
	         END

		IF @cht_basisunit <> 'MIL' and @cht_basisunit <> 'IN' and @cht_basisunit <> 'MM' and 
		   @cht_basisunit <> 'FT' and @cht_basisunit <> 'CM' and @cht_basisunit <> 'KMS' and 
	           @cht_basisunit <> 'HUB' and @cht_basisunit <> 'LBS' and @cht_basisunit <> 'KGS' and 
		   @cht_basisunit <> 'MTN' and @cht_basisunit <> 'TON' and @cht_basisunit <> 'PCS' and 
	           @cht_basisunit <> 'BOX' and @cht_basisunit <> 'SLP' and @cht_basisunit <> 'CAS' and 
                   @cht_basisunit <> 'PLT' and @cht_basisunit <> 'COIL' and @cht_basisunit <> 'GAL' and 
                   @cht_basisunit <> 'BSH' and @cht_basisunit <> 'LTR' and @cht_basisunit <> 'CWT' AND
		   @cht_basisunit <> 'CYD' and @cht_basisunit <> 'CMM' and @cht_basisunit <> 'CUB' and
                   @cht_basisunit <> ''
	         
		 BEGIN                      
		   --SELECT @DRP_TOTAL = SUM(IVD_VOLUME)
	           --  from #invoice_temp
	           -- where ord_hdrnumber = @minord AND
	           --       IVD_TYPE = 'DRP'
	
		    UPDATE #invoice_temp
	              SET IVD_VOLUME = 0,
                          IVD_WEIGHT = 0,
                          IVD_DISTANCE = 0,
                          IVD_COUNT = 0
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'
	         END	
              
		--Reset the variable
         	SET @DRP_TOTAL = 0
                SET @CHT_BASISUNIT = ''		

	    END
		SET @MINSEQ = 0
	END
--END PTS# 24399 ILB 11/15/2004


  UPDATE 	#invoice_temp 
     SET	#invoice_temp.stp_cty_nmstct = city.cty_nmstct    
    FROM	#invoice_temp, city    
   WHERE	#invoice_temp.stp_city = city.cty_code    

  UPDATE 	#invoice_temp 
     SET	#invoice_temp.ord_firstref = ref_number    
    FROM	#invoice_temp, referencenumber   
   WHERE	#invoice_temp.ord_hdrnumber = ref_tablekey and  
		referencenumber.ref_table='orderheader' and
		referencenumber.ref_sequence= (select min(ref_sequence)
						 from referencenumber, #invoice_temp
                                                where #invoice_temp.ord_hdrnumber = ref_tablekey
						  and ref_type = 'TICKET' 
                                                  and ref_table = 'orderheader') and
                referencenumber.ref_type ='TICKET'and
		ivd_sequence=1

  UPDATE 	#invoice_temp 
     SET	#invoice_temp.ivh_totalweight = i.ivh_totalweight
    FROM	#invoice_temp, invoiceheader i  
   WHERE	#invoice_temp.ivh_hdrnumber = i.ivh_hdrnumber and
 		ivd_sequence=1

-- rolling charges together ----
  UPDATE 	a 
  SET		a.ivd_rate=b.ivd_rate,
		a.ivd_rateunit=b.ivd_rateunit,
		a.ivd_charge=b.ivd_charge,
                a.bill_quantity = b.bill_quantity	
  FROM		#invoice_temp  a ,#invoice_temp b
  WHERE		a.ivh_invoicenumber = b.ivh_invoicenumber and
		a.ivd_sequence =1 and
		b.ivd_sequence =(select min(c.ivd_sequence) 
		   		  from #invoice_temp c 
		  	         where c.ivd_type='SUB' and 
                                       c.ivh_invoicenumber=a.ivh_invoicenumber)
-- end of rolling charges together ----




   SELECT @MinOrdShpCon = MIN(ord_hdrnumber)
     FROM #invoice_temp

--print cast(@minordshpcon as varchar(20))

   SELECT @MinShipper = ivh_shipper_Name, 
	  @MinShipperAddr = ivh_shipper_Address ,
	  @MinShipperAddr2 = ivh_shipper_Address2 ,
          @MinShipperNmctst = ivh_shipper_nmstct ,
	  @MinShipperZip = ivh_shipper_zip ,
	  @MinCon = ivh_consignee_name, 
	  @MinConAddr = ivh_consignee_Address ,
	  @MinConAddr2 = ivh_consignee_Address2 ,
	  @MinConNmctst = ivh_consignee_nmstct ,
	  @MinConZip = ivh_consignee_zip 	                       
     FROM #invoice_temp 
    where ord_hdrnumber = @MinOrdShpCon

   UPDATE #invoice_temp
      SET ivh_shipper_name = @minshipper,
          ivh_shipper_address = @minshipperaddr,
          ivh_shipper_address2 = @minshipperaddr2,
          ivh_shipper_nmstct = @minshippernmctst,
          ivh_shipper_zip = @minshipperzip,
          ivh_consignee_name = @mincon,
          ivh_consignee_address = @minconaddr,
          ivh_consignee_address2 = @minconaddr2,
          ivh_consignee_nmstct = @minconnmctst,
          ivh_consignee_zip = @minconzip 	



--=============================  try Donna's suggestion ======================
--**********************************************************************************************
--*** leaving this code here for now.  It produces slightly different results for the
--*** NUMBER of lines produced on the invoice (the final invoice total remains the same ) jds
--**********************************************************************************************


----* jds 5/23/2007 PTS 37360 - Make Delete Statement conditional.
----* PTS 37360 - DON'T delete the SUB row if:  ivh_rateby = 'T', ivd_sequence = 1, ivd_rate > 0, ivd_charge > 0 
--
----select 'DEBUG - jds 5-22-07... Before the DELETE',
----		bill_quantity, ivd_rate, ivd_unit, ivd_charge, 
----		ivd_type, rebill_creditmemo, ord_hdrnumber, 
----		ivd_sequence, cht_description  from #invoice_temp ORDER BY	ord_hdrnumber, ivd_sequence
------ end of debug select.. 
--
--
--declare @v_ivh_rateby char(1) 
--declare @v_T_ivd_seq int
--declare @v_T_ivd_rate money
--declare @v_T_ivd_charge money
--declare @v_delete_sub char(1)
--set @v_delete_sub = 'Y'
--
--set @v_ivh_rateby = ''
--set @v_ivh_rateby = (select ivh_rateby from invoiceheader where ivh_hdrnumber = @invoice_nbr )
--
--IF @v_ivh_rateby = 'T'
--BEGIN
--	set  @v_T_ivd_seq		= (select ivd_sequence from #invoice_temp where ivd_type='SUB'  )
--	set	 @v_T_ivd_rate		= (select ivd_rate	   from #invoice_temp where ivd_type='SUB'  )
--	set  @v_T_ivd_charge	= (select ivd_charge   from #invoice_temp where ivd_type='SUB'  )
--
--	IF @v_T_ivd_seq = 1 AND ( @v_T_ivd_rate > 0  OR @v_T_ivd_charge > 0 ) 
--	BEGIN
--		-- 'DO NOT DELETE !!!!!!!!!!!!!!!' 
--		set @v_delete_sub = 'N'
--	END 
--END
--
--IF @v_delete_sub = 'Y'			-- Make the following conditional PTS-37360
--BEGIN
--	delete from #invoice_temp
--    where ivd_sequence=(select min(c.ivd_sequence) 
--                        from #invoice_temp c 
--		                where c.ivd_type='SUB' 
--                        and c.ivh_invoicenumber=#invoice_temp.ivh_invoicenumber)  
--END 
----* end of jds 5/23/2007 PTS 37360 - Make Delete Statement conditional.
--
----select 'DEBUG - jds 5-22-07... AFTER the DELETE',
----		bill_quantity, ivd_rate, ivd_unit, ivd_charge, 
----		ivd_type, rebill_creditmemo, ord_hdrnumber, 
----		ivd_sequence, cht_description  from #invoice_temp ORDER BY	ord_hdrnumber, ivd_sequence
------ end of debug select.. 

--======================  DONNA's Suggestion Instead of the above - do this: ============
delete from #invoice_temp
where ivd_type = 'SUB' 
and ivd_sequence > 1
--=============   end of try Donna's suggestion =========================================



UPDATE #invoice_temp
   SET cust_po_no = ref.ref_number
  FROM REFERENCENUMBER REF
 WHERE ref_type = 'PO #' and
       ref_table = 'orderheader' and
       ref_tablekey = @MinOrdShpCon and
       ref_sequence = (select min(ref_sequence)
                         from referencenumber
                        where ref_type = 'PO #' and
			      ref_table = 'orderheader' and
                              ref_tablekey = @MinOrdShpCon)

UPDATE #invoice_temp
   SET company_loc = ivs_logocompanyloc
  FROM invoiceselection
 WHERE ivs_invoicedatawindow = 'd_inv_format95'  

SELECT @v_cmp_terms = min(name)
  FROM #invoice_temp, labelfile
 WHERE abbr = cmp_terms and
       labeldefinition = 'CreditTerms' --PTS# 33254 ILB 10/16/2006

--PRINT @v_cmp_terms

SELECT @v_startpos = rtrim(ltrim(CHARINDEX(' ',@v_cmp_terms))) 

--PRINT CAST(@v_startpos AS VARCHAR(20))

-- 05/17/2007 PTS 37485 - (Consolitate w/37360) - Bob Piskac; 
-- IF @v_startpos > 0 (remove this - add line below for PTS 37485.
IF @v_startpos > 0 and isnumeric(SUBSTRING(@v_cmp_terms,@v_startpos + 1,999)) = 1
-- end of PTS 37485 
	BEGIN
		SELECT @v_invoice_terms = cast(SUBSTRING(@v_cmp_terms,@v_startpos + 1,999) as INT)
		UPDATE #invoice_temp
   		SET pay_date = cast(DATEADD(day, @v_invoice_terms, getdate()) as varchar(20))	

		UPDATE #invoice_temp
		SET cmp_terms = @v_cmp_terms
	END
ELSE
	BEGIN
		Update #invoice_temp
   		SET cmp_terms = @v_cmp_terms
	END

select @minmov = 0
select @MinLgh = 0
select @v_lgh_trailer = ''
select @v_lgh_tractor = ''
select @v_cnt = 0 
select @v_lghcnt = 0
select @minmov = min(mov_number) from #invoice_temp
select @stp_number = 0
select @v_primary_tractor_type1 = ''

SELECT @v_lghcnt = COUNT(*) FROM legheader WHERE mov_number = @MinMov

select @lgh_cnt = count(distinct(lgh_number))
  from legheader
 where mov_number = @MinMov  
		
  IF @lgh_cnt = 1 
     Begin		  
   	   update #invoice_temp
     	      set lgh_count  = @lgh_cnt
            where mov_number = @MinMov 
	      and ivd_sequence = (select min(a.ivd_sequence)
                                    from #invoice_temp a
                                   where a.mov_number = @minmov)
     END

  IF @lgh_cnt > 1 
     Begin
	   update #invoice_temp
     	      set lgh_count  = @lgh_cnt
            where mov_number = @MinMov 			      			
     End
			 

WHILE (SELECT COUNT(*) 
	 FROM legheader 
        WHERE mov_number = @MinMov 
          and lgh_number > @MinLgh ) > 0
	BEGIN	   

	   SELECT @Minlgh = (SELECT MIN(lgh_number) 
			       FROM legheader 
                              WHERE mov_number = @MinMov and
                                    lgh_number > @minlgh)

           SELECT @v_lgh_tractor = lgh_tractor ,
                  @v_lgh_trailer = lgh_primary_trailer                               
	     FROM legheader 
	    WHERE lgh_number = @Minlgh 
	
           select @v_cnt = count(*)                 
	     from #invoice_temp, stops 
	    where #invoice_temp.stp_number = stops.stp_number and
                  stops.lgh_number = @Minlgh AND
                  #invoice_temp.ord_hdrnumber = @MinOrdShpCon	
	   
        --print cast(@v_cnt as varchar(20))
	    --print cast(@Minlgh as varchar(20))
	    --print cast(@MinOrdShpCon as varchar(20))

	   select @stp_number = stops.stp_number 
             from stops 
            where stops.lgh_number = @Minlgh 
              and stops.ord_hdrnumber = @MinOrdShpCon

	   --print cast(@stp_number as varchar(20))	   

	   IF @v_cnt = 0 
		BEGIN			
	
			select @stp_number = stops.stp_number 
		          from stops 
		         where stops.lgh_number = @Minlgh 
	                   and stops.ord_hdrnumber = @MinOrdShpCon

			select @v_lgh_tractor = lgh_tractor,
                               @v_lgh_trailer = lgh_primary_trailer
			  from legheader 
			 where lgh_number = @minLgh			 
		      
			   select @v_primary_tractor_type1 = name		  
			     from stops, legheader,tractorprofile trc, labelfile
			    where stops.lgh_number = @Minlgh and 
		                  trc.trc_number = @v_lgh_tractor and
		                  labeldefinition = 'TrcType1' and
		                  abbr = trc.trc_type1	
	 	END	

	      ELSE   

	 	BEGIN
			   update #invoice_temp
		              set primary_tractor_type1 = @v_primary_tractor_type1,
				  secondary_tractor_type1 = name,	
				  tractor2 = @v_lgh_tractor,
				  trailer2 = @v_lgh_trailer	  
			     from stops, legheader,#invoice_temp, tractorprofile trc, labelfile
			    where #invoice_temp.stp_number = @stp_number and
				  #invoice_temp.stp_number = stops.stp_number and
		                  stops.lgh_number = @Minlgh and 
		                  trc.trc_number = @v_lgh_tractor and
		                  labeldefinition = 'TrcType1' and
		                  abbr = trc.trc_type1
                  END
	   
	END

SELECT @v_Minreftype = ''
SELECT @v_refdesc = ''
SELECT @v_REFSTRING = ''
SELECT @v_minREFseq = 0


--* PTS 37360 jds; 5/18/2007:  ADD Reference Number Loop for MISC Invoices (order_hrd# = 0 ) so look for INV_hrd#
	-- (copied from Imari's looping code below) -----
--* IF ord_hdr is zero - look for ref#'s by inv_hdr.
IF @MinOrdShpCon = 0 
BEGIN 	
	DECLARE @v_ref_tablekey int
	SET @v_ref_tablekey = 0 	
	SET @v_ref_tablekey = (select min(ivh_hdrnumber) from #invoice_temp)	

			WHILE (SELECT COUNT(*) FROM referencenumber 
			       WHERE ref_tablekey = @v_ref_tablekey
			       and ref_table = 'invoiceheader'
				   and ref_type > @v_Minreftype) > 0
			          	--and ref_type NOT IN ('TICKET','PO #')  --* don't limit return refs for these.
			          	--and ref_type > @v_Minreftype) > 0
				BEGIN	   				
					SELECT @v_Minreftype = (SELECT MIN(ref_type) 
					                    FROM referencenumber 
			                            WHERE ref_tablekey = @v_ref_tablekey  
			         			        AND ref_table = 'invoiceheader' 
							            AND REF_TYPE > @v_Minreftype)	
			          			                  --and ref_type NOT IN ('TICKET','PO #')
			                                      --AND REF_TYPE > @v_Minreftype)
			
					SELECT @v_refdesc = name			              
			        FROM labelfile
			        WHERE labeldefinition = 'ReferenceNumbers' 
			        AND abbr = @v_Minreftype
			
					SELECT @v_REFSTRING = @v_REFSTRING + @v_refdesc+':'   
			
					WHILE (SELECT COUNT(*)
			               FROM referencenumber
			               WHERE ref_type = @v_Minreftype
			               AND ref_tablekey = @v_ref_tablekey 
			               and ref_sequence > @v_MinRefSeq) > 0
						BEGIN							
							SELECT @v_MinrefSeq = (SELECT min(ref_sequence)
			                    				   FROM referencenumber
						                           WHERE ref_type = @v_Minreftype
						                           AND ref_tablekey = @v_ref_tablekey 
						                           AND ref_sequence > @v_MinRefSeq)
							SELECT @v_MinRefNumber = ref_number
							FROM referencenumber
							WHERE ref_type = @v_Minreftype
							AND ref_tablekey = @v_ref_tablekey 
							AND ref_sequence = @v_MinRefSeq
			 
							--* jds 5/18/2007: Added a blank char following comma in next line 
							--* to avoid trucation in autosize report (invoice) column.							
							SELECT @v_REFSTRING = @v_REFSTRING + @v_MinRefNumber+', '				
						END
			
					SET @v_MinRefSeq = 0

				END
	END	--* End of IF statement
--* PTS 37360 jds; 5/18/2007: END of Misc Invoice Ref # loop



--* PTS 37360 jds (Made original code Conditional for Ref # loop (below)  
IF @MinOrdShpCon > 0 
	BEGIN	
			WHILE (SELECT COUNT(*) 
				 FROM referencenumber 
			     WHERE ref_tablekey = @MinOrdShpCon 
		         and ref_table = 'orderheader' 
		         and ref_type NOT IN ('TICKET','PO #')
		         and ref_type > @v_Minreftype) > 0
			BEGIN	   							
				--PRINT 'jr'
				SELECT @v_Minreftype = (SELECT MIN(ref_type) 
					                    FROM referencenumber 
			                            WHERE ref_tablekey = @MinOrdShpCon 
			         			        AND ref_table = 'orderheader' 
			          			        and ref_type NOT IN ('TICKET','PO #')
			                            AND REF_TYPE > @v_Minreftype)
				--print @v_Minreftype 
			
				SELECT @v_refdesc = name
			    FROM labelfile
				WHERE labeldefinition = 'ReferenceNumbers' 
			    AND abbr = @v_Minreftype
			
				SELECT @v_REFSTRING = @v_REFSTRING + @v_refdesc+':'
			
				--print @v_refstring       
			
				   WHILE (SELECT COUNT(*)
			              FROM referencenumber
			              WHERE ref_type = @v_Minreftype
			              AND ref_tablekey = @MinOrdShpCon
			              and ref_sequence > @v_MinRefSeq) > 0
						BEGIN
						--print 'imari'
							SELECT @v_MinrefSeq = (SELECT min(ref_sequence)
			                    				   FROM referencenumber
						                           WHERE ref_type = @v_Minreftype
						                           AND ref_tablekey = @MinOrdShpCon
						                           AND ref_sequence > @v_MinRefSeq)
						 --print @v_minreftype
						 --print cast(@v_minrefseq as varchar(20))
						 --print cast(@MinOrdShpCon as varchar(20))
					
							SELECT @v_MinRefNumber = ref_number
							FROM referencenumber
							WHERE ref_type = @v_Minreftype
							AND ref_tablekey = @MinOrdShpCon
							AND ref_sequence = @v_MinRefSeq
			 
							--* jds 5/18/2007: Added a blank char following comma in next line 
							--* to avoid trucation in autosize report (invoice) column.					
							SELECT @v_REFSTRING = @v_REFSTRING + @v_MinRefNumber+', '		
						
							--print @v_refstring
					        --print cast(@v_minrefseq as varchar(20))
						END			
				   SET @v_MinRefSeq = 0
			END
END -- end of new if stmt (jds)
--* PTS 37360 jds END of original code new IF statment.

UPDATE #invoice_temp
   SET tractor1 = '',
       tractor2 = '',
       trailer1 = '',
       trailer2 = ''
 WHERE stp_number < 1

IF len(@v_REFSTRING) > 1 
	BEGIN
		UPDATE #invoice_temp
	   	   SET reference_numbers = SUBSTRING(@v_REFSTRING , 1 , len(@v_REFSTRING) - 1 ) 
                 WHERE ivd_sequence = (select min(inv_tmp.ivd_sequence)
                                         from #invoice_temp inv_tmp)
	END   

UPDATE #invoice_temp
   SET rebill_creditmemo = name
  FROM labelfile, #invoice_temp
 WHERE labelfile.abbr = #invoice_temp.ivh_definition
   and labelfile.labeldefinition = 'InvoiceDefinitions'


/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
select @v_counter = 1  

while @v_counter <>  @copies  
 begin 

 	select @v_counter = @v_counter + 1
    insert into #invoice_temp  
 	select 
		ord_hdrnumber,
		ivh_invoicenumber ,  
		ivh_hdrnumber , 
		ivh_billto ,
		ivh_shipper ,
		ivh_consignee ,
		ivh_totalcharge ,   
		ivh_originpoint  ,  
		ivh_destpoint ,   
		ivh_origincity ,   
		ivh_destcity ,   
		ivh_shipdate ,   
		ivh_deliverydate ,   
		ivh_revtype1 ,
		ivh_mbnumber ,
		ivh_shipper_name  ,
		ivh_shipper_address ,
		ivh_shipper_address2 ,
		ivh_shipper_nmstct  ,
		ivh_shipper_zip ,
		ivh_billto_name ,
		ivh_billto_address ,
		ivh_billto_address2 ,
		ivh_billto_nmstct  ,
		ivh_billto_zip ,
		ivh_consignee_name ,
		ivh_consignee_address ,
		ivh_consignee_address2 ,
		ivh_consignee_nmstct ,
		ivh_consignee_zip ,
		origin_nmstct ,
		origin_state ,
		dest_nmstct ,
		dest_state ,
		billdate ,
		cmp_mailto_name ,
		bill_quantity ,
		ivd_weight ,
		ivd_weightunit ,
		ivd_count ,
		ivd_countunit ,
		ivd_volume ,
		ivd_volunit ,
		ivd_unit ,
		ivd_rate ,
		ivd_rateunit ,
		ivd_charge ,
		cht_description ,
		cht_primary ,
		cmd_name ,
		ivd_description ,
		ivd_type,
		stp_city ,
		stp_cty_nmstct ,
		ivd_sequence ,
		stp_number ,
		@v_counter, --copy ,
		cmp_id ,
		ord_firstref ,                
		ivh_totalweight ,
		billto_altid ,
		cht_basis ,
		cht_basisunit ,
		ivd_distance ,
		ivd_distunit ,
		ivd_groupcontrol,
		billto_cmp_othertype1,
		cmp_contact,
		cmp_primaryphone,
		cmp_terms,
		pay_date,
		cust_po_no,
		company_loc,		
		primary_tractor_type1 ,
		secondary_tractor_type1 ,
		mov_number ,
       tractor1 varchar,
        tractor2 varchar,
        trailer1 varchar,
        trailer2 varchar,
        reference_numbers varchar,
		ivh_definition varchar,
                lgh_count,
                rebill_creditmemo,
	    ivh_remark,	-- added for PTS 37360
        ivd_number
	FROM     #invoice_temp
	where    copy = 1 
     ORDER BY ord_hdrnumber, ivd_sequence 

end   
  
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */ 
select 
	ord_hdrnumber,
	ivh_invoicenumber ,  
	ivh_hdrnumber , 
	ivh_billto ,
	ivh_shipper ,
	ivh_consignee ,
	ivh_totalcharge ,   
	ivh_originpoint  ,  
	ivh_destpoint ,   
	ivh_origincity ,   
	ivh_destcity ,   
	ivh_shipdate ,   
	ivh_deliverydate ,   
	ivh_revtype1 ,
	ivh_mbnumber ,
	ivh_shipper_name  ,
	ivh_shipper_address ,
	ivh_shipper_address2 ,
	ivh_shipper_nmstct  ,
	ivh_shipper_zip ,
	ivh_billto_name ,
	ivh_billto_address ,
	ivh_billto_address2 ,
	ivh_billto_nmstct  ,
	ivh_billto_zip ,
	ivh_consignee_name ,
	ivh_consignee_address ,
	ivh_consignee_address2 ,
	ivh_consignee_nmstct ,
	ivh_consignee_zip ,
	origin_nmstct ,
	origin_state ,
	dest_nmstct ,
	dest_state ,
	billdate ,
	cmp_mailto_name ,
	bill_quantity ,
	ivd_weight ,
	ivd_weightunit ,
	ivd_count ,
	ivd_countunit ,
	ivd_volume ,
	ivd_volunit ,
	ivd_unit ,
	ivd_rate ,
	ivd_rateunit ,
	ivd_charge ,
	cht_description ,
	cht_primary ,
	cmd_name ,
	ivd_description ,
	ivd_type,
	stp_city ,
	stp_cty_nmstct ,
	ivd_sequence ,
	stp_number ,
	copy ,
	cmp_id ,
	ord_firstref ,                
	ivh_totalweight ,
	billto_altid ,
	cht_basis ,
	cht_basisunit ,
	ivd_distance ,
	ivd_distunit ,
	ivd_groupcontrol,
	billto_cmp_othertype1,
	cmp_contact,
	cmp_primaryphone,
	cmp_terms	,
	pay_date,
	cust_po_no,
	company_loc,
	primary_tractor_type1 ,
	secondary_tractor_type1,
	tractor1 ,
        tractor2 ,
        trailer1,
        trailer2,
        reference_numbers,
	ivh_definition,
	lgh_count,
        rebill_creditmemo,
	ivh_remark, --added for PTS 37360 	
    ivd_number              
	--mov_number
    FROM #invoice_temp
ORDER BY ord_hdrnumber, ivd_sequence

DROP TABLE #invoice_temp

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @v_ret_value = @@ERROR   
return @v_ret_value
GO
GRANT EXECUTE ON  [dbo].[invoice_template95] TO [public]
GO
