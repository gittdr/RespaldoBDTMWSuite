SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill80_sp] (@p_reprintflag varchar(10),@p_mbnumber int,@p_billto varchar(8), 
	@p_revtype1 varchar(6), @p_mbstatus varchar(6),
	@p_shipstart datetime,@p_shipend datetime,@p_billdate datetime,@p_copy int)
AS

/*
 * 
 * NAME:d_masterbill80_sp
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
 * 005 - @p_mbstatus, int, output, null;
 *       status of masterbill ie XFR 
 * 006 - @p_shipstart, int, input, null;
 *       start date
 * 007 - @p_shipend, varchar(20), input, null;
 *       end date
 * 008 - @p_billdate, varchar(6), input, null;
 *       bill date
 * 009 - @p_copy, varchar(8), input, null;
 *       number of copies requested
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 - PTSnnnnn - AuthorName -Revision Description 
 *            - pts 6691  - dpete - change ivd_coutn and ivd_volume on temp tableto float
 *            - PTS 17762 - DPETE - When 'ALL' ispassed in @revtype1 (for format 03b), match to all revtypes. 
 * 04/06/2006 - PTS 25003 - Imari Bremer - Create new masterbill format for TruckLoad Services
 **/


DECLARE @v_int0  int, @v_TOTAL_GST MONEY, @v_TOTAL_PST MONEY, @v_Lh_total money,
        @v_code varchar(8), @v_ord_hdrnumber int, @v_gst_idnumber varchar(60),
        @v_MinOrd int, @v_total money, @v_taxes money, @v_qst_idnumber varchar(60),
        @v_TVQ_QST varchar(30),  @v_MinRef varchar(30),@v_MinType varchar(20),
        @v_count int,@v_MinRefType varchar(6),@v_MinSeq int, @v_ref_type varchar(20),
        @v_Ref_number varchar(30)
SELECT @v_int0 = 0

SELECT @p_shipstart = convert(char(12),@p_shipstart)+'00:00:00'
SELECT @p_shipend   = convert(char(12),@p_shipend  )+'23:59:59'
SELECT @v_total_gst = 0.00
SELECT @v_total_pst = 0.00


CREATE TABLE #masterbill_temp
	(ord_number varchar(12) NULL,
	ord_hdrnumber int,
	ivh_invoicenumber varchar(12) NULL ,  
	ivh_hdrnumber int NULL, 
	ivh_billto varchar(8) NULL,   
        ivh_totalcharge money NULL,   
        ivh_originpoint varchar(8) NULL,  
        ivh_destpoint varchar(8) NULL,   
        ivh_origincity int NULL,   
        ivh_destcity int NULL,   
        ivh_shipdate datetime NULL,   
        ivh_deliverydate datetime NULL,   
        ivh_revtype1 varchar(6) NULL,
	ivh_mbnumber int NULL,
	shipper_name varchar(30) NULL,
	shipper_addr varchar(40) NULL,
	shipper_addr2 varchar(40) NULL,
	shipper_nmstct varchar(25) NULL,
	shipper_zip varchar(10) NULL,
	ivh_billto_name varchar(30) NULL,
	ivh_billto_address varchar(40) NULL,
	ivh_billto_address2 varchar(40) NULL,
	ivh_billto_nmstct varchar(25) NULL,
	ivh_billto_zip varchar(10) NULL,
	dest_nmstct varchar(25) NULL,
	dest_state char(2) NULL,
	billdate datetime NULL,
	shipticket varchar(20) NULL,
	cmp_mailto_name varchar(30) NULL,
	ivd_wgt float NULL,
	ivd_wgtunit char(6) NULL,
	ivd_count float NULL,
	ivd_countunit char(6) NULL,
	ivd_volume float NULL,
	ivd_volunit char(6) NULL,
	ivd_quantity float NULL,
	ivd_unit varchar(6) NULL,
	ivd_rate money NULL,
	ivd_rateunit varchar(6) NULL,
	ivd_charge money NULL,
	ivd_volume2 float NULL,
	stp_nmstct varchar(25) NULL,
	stp_city int NULL,
	cmd_name varchar(60) NULL,
	tar_tarriff_number varchar(12) NULL,
	cmp_altid varchar(25) NULL,
	copy int NULL,
	cht_primary char(1) NULL,
	cht_description varchar(60) NULL,
	ivd_sequence int NULL,
	--ILB 10-18-2002 PTS# 15194
	ivh_ref_number varchar(20)NULL,
	--ILB 10-18-2002 PTS# 15194
        cht_itemcode varchar(8)NULL,
        gst_total MONEY NULL,
        pst_total MONEY NULL,
        gst_idnumber varchar(60) NULL,
        cht_basis varchar(6) null,
        lh_total money null,        
        ivh_remark varchar(254) null,
        qst_idnumber varchar(60) null,
        ivh_currency varchar(6)null,
        ivh_billto_addr3 varchar(40)null,
        ref_type1 varchar(20)null,
        ref_number1 varchar(30)null,
	ref_type2 varchar(20)null,
        ref_number2 varchar(30)null,
	ref_type3 varchar(20)null,
        ref_number3 varchar(30)null)
        --qst_desc varchar(30))

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@p_reprintflag) = 'REPRINT' 
  BEGIN

    INSERT INTO #masterbill_temp

    SELECT oh.ord_number,
	invoiceheader.ord_hdrnumber,
	invoiceheader.ivh_invoicenumber,  
	invoiceheader.ivh_hdrnumber, 
        invoiceheader.ivh_billto,   
        invoiceheader.ivh_totalcharge,   
        invoiceheader.ivh_originpoint,  
        invoiceheader.ivh_destpoint,   
        invoiceheader.ivh_origincity,   
        invoiceheader.ivh_destcity,   
        invoiceheader.ivh_shipdate,   
        invoiceheader.ivh_deliverydate,   
        invoiceheader.ivh_revtype1,
	invoiceheader.ivh_mbnumber,
	shipper_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	shipper_address = 
	   CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
		ELSE ISNULL(cmp3.cmp_mailto_address1,'')
	    END,
	shipper_address2 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
		ELSE ISNULL(cmp3.cmp_mailto_address2,'')
	    END,
	shipper_nmstct = 
	    CASE
		WHEN cmp3.cmp_id = 'UNKNOWN' THEN
		     'UNKNOWN'
		WHEN cmp3.cmp_mailto_name IS NULL THEN 

		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct)) - 1),'')
	    END,
	shipper_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    END,
	billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	billto_address = 
	   CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	billto_address2 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_id = 'UNKNOWN' THEN
		     'UNKNOWN'
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	    END,
	billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	cty2.cty_nmstct   dest_nmstct,
	cty2.cty_state		dest_state,
	ivh_billdate      billdate,
	'',
	ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	IsNull(ivd.ivd_wgt, 0),
	IsNull(ivd.ivd_wgtunit, ''),
	IsNull(ivd.ivd_count, 0),
	IsNull(ivd.ivd_countunit, ''),
	IsNull(ivd.ivd_volume, 0),
	IsNull(ivd.ivd_volunit, ''),
	IsNull(ivd.ivd_quantity, 0),
	IsNull(ivd.ivd_unit, ''),
	IsNull(ivd.ivd_rate, 0),
	IsNull(ivd.ivd_rateunit, ''),
	IsNull(ivd.ivd_charge, 0),
	IsNull(ivd.ivd_volume, 0),
	'',
	stops.stp_city,
	cmd.cmd_name,
	invoiceheader.tar_tarriffnumber,
	cmp1.cmp_altid,
	@p_copy,
	cht.cht_primary,
	cht.cht_description,
	ivd.ivd_sequence,
	--ILB 10-18-2002 PTS# 15194
	invoiceheader.ivh_ref_number,  
	--ILB 10-18-2002 PTS# 15194
        ivd.cht_itemcode,
        @v_total_gst gst_total,
        @v_total_pst pst_total,
        '' gst_idnumber,
        cht.cht_basis,
        @v_lh_total lh_total,        
        ivh_remark,
        '' qst_number,
        ivh_currency,
        ISNULL(cmp1.cmp_address3,'') ivh_billto_addr3,
        @v_ref_type ref_type1,
        @v_ref_number ref_number1,
	@v_ref_type ref_type2,
        @v_ref_number ref_number2,
	@v_ref_type ref_type3,
        @v_ref_number ref_number3
        --'' qst_desc --description from chargetype table based on cht_itemcode QST	   
    FROM city cty1, city cty2, chargetype cht,
	 invoiceheader join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
         left outer join orderheader as oh on oh.ord_hdrnumber = invoiceheader.ord_hdrnumber
         left outer join commodity as cmd on cmd.cmd_code = ivd.cmd_code 
	 left outer join stops as stops on stops.stp_number = ivd.stp_number
	 right outer join company as cmp1 on cmp1.cmp_id = invoiceheader.ivh_billto
         right outer join company as cmp3 on cmp3.cmp_id = invoiceheader.ivh_shipper
	 -- , company cmp1,invoicedetail ivd, stops,  commodity cmd, company cmp3,
   WHERE 
	( invoiceheader.ivh_mbnumber = @p_mbnumber ) 
	AND (ivd.cht_itemcode = cht.cht_itemcode)
	AND (cty1.cty_code = invoiceheader.ivh_origincity) 
	AND (cty2.cty_code = invoiceheader.ivh_destcity)
	--(invoiceheader.ord_hdrnumber *= oh.ord_hdrnumber)
	--AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
	--AND (ivd.stp_number *= stops.stp_number)
	--AND (ivd.cmd_code *= cmd.cmd_code)	
	--AND (cmp1.cmp_id =* invoiceheader.ivh_billto) 
	--AND (cmp3.cmp_id =* invoiceheader.ivh_shipper)	
	--AND (ivd.ivd_volume > 0 OR ivd_quantity > 0)

  END

-- for master bills with 'RTP' status

IF UPPER(@p_reprintflag) <> 'REPRINT' 
  BEGIN

	
     INSERT INTO #masterbill_temp

    SELECT oh.ord_number,
	invoiceheader.ord_hdrnumber,
	invoiceheader.ivh_invoicenumber,  
	invoiceheader.ivh_hdrnumber, 
        invoiceheader.ivh_billto,   
        invoiceheader.ivh_totalcharge,   
        invoiceheader.ivh_originpoint,  
        invoiceheader.ivh_destpoint,   
        invoiceheader.ivh_origincity,   
        invoiceheader.ivh_destcity,   
        invoiceheader.ivh_shipdate,   
        invoiceheader.ivh_deliverydate,   
        invoiceheader.ivh_revtype1,
-- JET - 1/28/00 - PTS #7169, this was not returning a mb number
--	invoiceheader.ivh_mbnumber,
        @p_mbnumber ivh_mbnumber, 
	shipper_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	shipper_address = 
	   CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
		ELSE ISNULL(cmp3.cmp_mailto_address1,'')
	    END,
	shipper_address2 = 

	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
		ELSE ISNULL(cmp3.cmp_mailto_address2,'')
	    END,
	shipper_nmstct = 
	    CASE
		WHEN cmp3.cmp_id = 'UNKNOWN' THEN
		     'UNKNOWN'
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct)) - 1),'')
	    END,
	shipper_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    END,
	billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	billto_address = 
	   CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	billto_address2 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_id = 'UNKNOWN' THEN
		     'UNKNOWN'
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	    END,
	billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	cty2.cty_nmstct   dest_nmstct,
	cty2.cty_state		dest_state,
        --PTS# 23284 ILB 09/16/2004
	@p_billdate billdate,
	--ivh_billdate      billdate,
	--END PTS# 23284 ILB 09/16/2004
	'',
	ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	IsNull(ivd.ivd_wgt, 0),
	IsNull(ivd.ivd_wgtunit, ''),
	IsNull(ivd.ivd_count, 0),
	IsNull(ivd.ivd_countunit, ''),
	IsNull(ivd.ivd_volume, 0),
	IsNull(ivd.ivd_volunit, ''),
	IsNull(ivd.ivd_quantity, 0),
	IsNull(ivd.ivd_unit, ''),
	IsNull(ivd.ivd_rate, 0),
	IsNull(ivd.ivd_rateunit, ''),
	IsNull(ivd.ivd_charge, 0),
	IsNull(ivd.ivd_volume, 0),
	'',
	stops.stp_city,
	cmd.cmd_name,
	invoiceheader.tar_tarriffnumber,
	IsNull(cmp1.cmp_altid, ''),
	@p_copy,
	cht.cht_primary,
	cht.cht_description,
	ivd.ivd_sequence,
	--ILB 10-18-2002 PTS# 15194
	invoiceheader.ivh_ref_number, 
	--ILB 10-18-2002 PTS# 15194
        ivd.cht_itemcode,
        @v_total_gst gst_total,
        @v_total_pst pst_total,
        '' gst_idnumber,
        cht.cht_basis,
        @v_lh_total lh_total,        
        ivh_remark,
        '' qst_number,
        ivh_currency,
	ISNULL(cmp1.cmp_address3,'') ivh_billto_addr3,
        @v_ref_type ref_type1,
        @v_ref_number ref_number1,
	@v_ref_type ref_type2,
        @v_ref_number ref_number2,
	@v_ref_type ref_type3,
        @v_ref_number ref_number3
	--'' qst_desc --description from chargetype table based on cht_itemcode QST	   
    FROM city cty1, city cty2, company cmp3, chargetype cht,
	 invoiceheader join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
	 left outer join orderheader as oh on oh.ord_hdrnumber = invoiceheader.ord_hdrnumber
	 left outer join stops as stops on stops.stp_number = ivd.stp_number
	 left outer join commodity as cmd on cmd.cmd_code = ivd.cmd_code
	 right outer join company as cmp1 on cmp1.cmp_id = invoiceheader.ivh_billto
	 --orderheader oh, invoiceheader, company cmp1,invoicedetail ivd, stops,  commodity cmd,
   WHERE 
     ( invoiceheader.ivh_billto = @p_billto )     
     AND (ivd.cht_itemcode = cht.cht_itemcode)
     AND (invoiceheader.ivh_shipdate between @p_shipstart AND @p_shipend ) 
     AND (invoiceheader.ivh_mbstatus = 'RTP') 
     AND (@p_revtype1 in (invoiceheader.ivh_revtype1,'UNK'))     
     AND (cmp3.cmp_id = invoiceheader.ivh_shipper)
     AND (cty1.cty_code = invoiceheader.ivh_origincity) 
     AND (cty2.cty_code = invoiceheader.ivh_destcity) 
     --(invoiceheader.ord_hdrnumber *= oh.ord_hdrnumber)   
     --AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
     --AND (ivd.stp_number *= stops.stp_number) 
     --AND (ivd.cmd_code *= cmd.cmd_code)
     --AND (@revtype1 in (invoiceheader.ivh_revtype1,'ALL')) 
     --AND (cmp1.cmp_id =* invoiceheader.ivh_billto)          
  END


--Select @TVQ_QST = cht_description
--  From #invtemp_tbl
-- Where upper(cht_itemcode) = 'QST'

--Update #invtemp_tbl
--   Set qst_desc = @TVQ_QST 

SET @v_MinOrd = 0
SET @v_Lh_Total = 0
SET @v_Total_Gst = 0
SET @v_Total_Pst = 0
SET @v_total = 0

WHILE (SELECT COUNT(*) FROM #masterbill_temp WHERE ord_hdrnumber > @v_MinOrd) > 0
	BEGIN
		SELECT @v_MinOrd = (SELECT MIN(ord_hdrnumber) FROM #masterbill_temp WHERE ord_hdrnumber > @v_MinOrd)		

		
		--GST TAX GRAND TOTAL  
		select @v_total_gst = isnull(SUM(ivd_charge),0)
                  from #masterbill_temp
                 where ord_hdrnumber = @v_MinOrd and
                       cht_itemcode = 'GST'		

		--PST TAX GRAND TOTAL  
		select @v_total_pst = isnull(SUM(ivd_charge),0)
                  from #masterbill_temp
                 where ord_hdrnumber = @v_MinOrd and
					   cht_itemcode = 'TAX3' --pts 37428 
                       --cht_itemcode = 'QST'
                       --cht_itemcode = 'PST'		

		--total charge of the invoice
		select @v_total = isnull(ivh_totalcharge,0)
                  from #masterbill_temp
                 where ord_hdrnumber = @v_MinOrd
                 
              
		--get the line haul charge total 		
                select @v_taxes = isnull(@v_total_gst,0) + isnull(@v_total_pst,0)
		select @v_lh_total = isnull(@v_total - @v_taxes,0)

		
		--UPDATE GRAND TOTALS  
		UPDATE #masterbill_temp
               	   SET gst_total = isnull(@v_total_gst,0),
                       pst_total  = isnull(@v_total_pst,0),
                       lh_total  = isnull(@v_lh_total,0)
                 WHERE ord_hdrnumber = @v_MinOrd       
     
     		--Reset variables ILB 03/27/03 
     		SELECT @v_lh_total = 0     		
     		SELECT @v_total_pst = 0
     		SELECT @v_total_gst = 0
		SELECT @v_total = 0


	   SET @v_MinRef = ''
	   SET @v_count = 0
	   SET @v_MinType = ''
	   SET @v_MinRefType = ''
	   SET @v_MinSeq = 0

	   WHILE (SELECT COUNT(*) 
                    FROM referencenumber 
	           WHERE ref_sequence > @v_Minseq and 
		         ref_tablekey = @v_MinOrd and 
		         ref_table = 'orderheader' ) > 0

	     BEGIN	   	    

               SELECT @v_count = @v_count + 1	
		
	       SELECT @v_MinSeq = (SELECT MIN(ref_sequence) 
			    	   FROM referencenumber 
				  WHERE ref_sequence > @v_MinSeq and 
					ref_tablekey = @v_MinOrd and 
					ref_table = 'orderheader')	       
		       
	       SELECT @v_MinRefType = (SELECT ref_type 
			    	   FROM referencenumber 
				  WHERE ref_sequence = @v_MinSeq and 
					ref_tablekey = @v_MinOrd and 
					ref_table = 'orderheader')
		
	      SELECT @v_MinRef = (select ref_number
                 		  FROM referencenumber
                		 WHERE ref_sequence = @v_MinSeq and 
		        	       ref_tablekey = @v_MinOrd and 
		         	       ref_table = 'orderheader')	       

	       SELECT @v_MinType = labelfile.Name
                 FROM labelfile
                WHERE labelfile.abbr = @v_MInRefType and
                      labelfile.labeldefinition = 'ReferenceNumbers' 

		--print   @v_MinRef
		--print   @v_MinRefType
		--print   cast(@v_MinOrd as varchar(20))
		--print   cast(@v_Count as varchar(20))
	
		IF @v_count = 1
		BEGIN     
			UPDATE #masterbill_temp
               	           SET REF_TYPE1 = ISNULL(@v_MinType,''),
          		       REF_NUMBER1 = ISNULL(@v_MinRef,'')
                         WHERE ord_hdrnumber = @v_MinOrd       	 		
                END
		
		IF @v_count = 2
		BEGIN         
	 		UPDATE #masterbill_temp
               	           SET REF_TYPE2 = ISNULL(@v_MinType,''),
          		       REF_NUMBER2 = ISNULL(@v_MinRef,'')
                         WHERE ord_hdrnumber = @v_MinOrd 
                END

		IF @v_count = 3
		BEGIN       
	 		UPDATE #masterbill_temp
               	           SET REF_TYPE3 = ISNULL(@v_MinType,''),
          		       REF_NUMBER3 = ISNULL(@v_MinRef,'')
                         WHERE ord_hdrnumber = @v_MinOrd 
			 BREAK
                END
	       
		SET @v_MinType = ''
                SET @v_MinRef = ''
		SET @v_MinRefType = ''
	     END		
       
      END  
  
--UPDATE #masterbill_temp 
--   set shipticket = (SELECT IsNUll(ref_number, '')
--	  	       FROM referencenumber ref, #masterbill_temp
--		      WHERE ref.ref_table = 'orderheader' AND
--			    ref.ref_tablekey = #masterbill_temp.ord_hdrnumber AND
--			    ref.ref_sequence = 1)


update #masterbill_temp
   set ivh_remark = (select ivh_remark
                       from #masterbill_temp
                      where ord_hdrnumber =(select min(ord_hdrnumber)
                                              from #masterbill_temp
                                              where ivd_sequence = 1) and
                            ivd_sequence = 1)
                                               
select @v_gst_idnumber = gi_string1     
  from generalinfo
 where upper(gi_name) = 'GSTNUMBER'

select @v_qst_idnumber = gi_string1     
  from generalinfo
 where upper(gi_name) = 'QSTNUMBER'


update #masterbill_temp
   set gst_idnumber = @v_gst_idnumber,
       qst_idnumber = @v_qst_idnumber



  SELECT * 
    from #masterbill_temp
   where ivd_sequence = 1
ORDER by ivh_invoicenumber,ivd_sequence

DROP TABLE #masterbill_temp
GO
GRANT EXECUTE ON  [dbo].[d_masterbill80_sp] TO [public]
GO
