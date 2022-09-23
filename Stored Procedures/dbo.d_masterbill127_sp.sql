SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
  
CREATE PROC [dbo].[d_masterbill127_sp](  
@p_reprintflag varchar(10),  
@p_mbnumber int,  
@p_billto varchar(8),   
@p_revtype1 varchar(6),   
@p_mbstatus varchar(6),  
@p_shipstart datetime,  
@p_shipend datetime, 
@p_billdate datetime,   
@p_shipper varchar(8),  
@p_consignee varchar(8),  
@p_copy int
)  
AS  
  
/*  
 *   
 * NAME:d_masterbill127_sp  
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
 * 010 - @p_ivh_invoicenumber, varchar(12), input, null;  
 *       invoiceheader invoice number (ie. Master)  
 * REFERENCES: (called by and calling references only, don't   
 *              include table/view/object references)  
 * N/A  
 *   
 *   
 *   
 * REVISION HISTORY:  
 * PMILL PTS 44542 for Coastal copy of format 
 * DPETE PTS 47311 custoemr does not want to see additonal PUP stops on printout.
 *     will have to also roll up bill miles to first delivery stop
 **/  
  



DECLARE @v_int0  int, @v_gst_total money, @v_fuelsurcharge_total money, @v_minord int,
        @v_subtotal money, @fuelsurcharge_total money, @v_min_chrg_found int, @v_min_seq int,
        @v_ref_number varchar(40)



CREATE TABLE #masterbill_temp (		
		ord_number varchar(12),
		ivh_invoicenumber varchar(12),  
		ivh_hdrnumber int NULL, 
		ivh_billto varchar(8) NULL,
		ivh_shipper varchar(8) NULL,
		ivh_consignee varchar(8) NULL,
		ivh_totalcharge money NULL,   
		ivh_originpoint  varchar(8) NULL,  
		ivh_destpoint varchar(8) NULL,   
		ivh_origincity int NULL,		--10   
		ivh_destcity int NULL,   
		ivh_shipdate datetime NULL,   
		ivh_deliverydate datetime NULL,   
		ivh_revtype1 varchar(6) NULL,
		ivh_mbnumber int NULL,
		ivh_billto_name varchar(100)  NULL,
		ivh_billto_address varchar(100) NULL,
		ivh_billto_address2 varchar(100) NULL,
		ivh_billto_nmstct varchar(25) NULL ,
		ivh_billto_zip varchar(10) NULL,		--20
		ivh_ref_number varchar(30) NULL,
		ivh_tractor varchar(8) NULL,
		ivh_trailer varchar(13) NULL,
		origin_nmstct varchar(25) NULL,
		origin_state varchar(6) NULL,
		dest_nmstct varchar(25) NULL,
		dest_state varchar(6) NULL,
		billdate datetime NULL,
		cmp_mailto_name varchar(30)  NULL,
		bill_quantity float  NULL,		--30
		ivd_refnumber varchar(30) NULL,
		ivd_weight float NULL,
		ivd_weightunit char(6) NULL,
		ivd_count float NULL,
		ivd_countunit char(6) NULL,
		ivd_volume float NULL,
		ivd_volunit char(6) NULL,
		ivd_unit varchar(6) NULL,
		ivd_rate money NULL,
		ivd_rateunit varchar(6) NULL,		--40
		ivd_charge money NULL,
		cht_description varchar(60) NULL,
		cht_primary char(1) NULL,
		cmd_name varchar(60)  NULL,
		cmd_class varchar(20) NULL,
		ivd_description varchar(60) NULL,
		ivd_type char(6) NULL,
		stp_name varchar(100),
		stp_city int NULL,
		stp_cty_nmstct varchar(30) NULL,
		stp_addr varchar(100),
		ivd_sequence int NULL,
		stp_number int NULL,		--50
		copy int NULL,
		ref_number varchar(1000) NULL,
		cmp_id varchar(8) NULL,
		cmp_name varchar(100) NULL,
		ivh_remark varchar(255) NULL,
                cht_itemcode varchar(6) null,
                ivh_billto_address3 varchar(100) null,
                ord_hdrnumber int null, 	
                ivh_currency varchar(6) null,
		fgt_number int null,
		ivh_totalmiles float null,
		ivh_rateby char(1) null,
		sortorder int null,
        ivd_distance float null,
        firstDRPSeq int null ) 
SELECT  @v_int0 = 0

SELECT  @p_shipstart = convert(char(12),@p_shipstart)+'00:00:00'
SELECT  @p_shipend   = convert(char(12),@p_shipend  )+'23:59:59'
-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@p_reprintflag) = 'REPRINT' 
  BEGIN
    
    INSERT INTO	#masterbill_temp
    SELECT 	IsNull(invoiceheader.ord_number, ''),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		invoiceheader.ivh_billto,
		invoiceheader.ivh_shipper,
		invoiceheader.ivh_consignee,   
		invoiceheader.ivh_totalcharge,   
		invoiceheader.ivh_originpoint,  
		invoiceheader.ivh_destpoint,   
		invoiceheader.ivh_origincity,		--10   
		invoiceheader.ivh_destcity,   
		invoiceheader.ivh_shipdate,   
		invoiceheader.ivh_deliverydate,   
		invoiceheader.ivh_revtype1,
		invoiceheader.ivh_mbnumber,
		ivh_billto_name = cmp1.cmp_name,
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
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	    END,
	ivh_billto_zip = 
	    CASE		--20
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		isnull(invoiceheader.ivh_ref_number,''),
		invoiceheader.ivh_tractor,
		invoiceheader.ivh_trailer,
		cty1.cty_nmstct   origin_nmstct,
		substring(cty1.cty_state,1,2)		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		substring(cty2.cty_state,1,2)		dest_state,
		ivh_billdate      billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',		--30
		IsNull(ivd.ivd_refnum, '') ivd_refnumber,

		IsNull(ivd.ivd_wgt, 0),
		IsNull(ivd.ivd_wgtunit, ''),
		IsNull(ivd.ivd_count, 0),
		IsNull(ivd.ivd_countunit, ''),
		IsNull(ivd.ivd_volume, 0),
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
		Case cht.cht_basis WHEN 'TAX' then IsNull(ivd.ivd_rate, 0)/ 100.0000 else IsNull(ivd.ivd_rate, 0) end,
		IsNull(ivd.ivd_rateunit, ''),		--40
		ivd.ivd_charge,
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		ccl.ccl_description,
		IsNull(ivd_description, ''),
		ivd.ivd_type,
		'UNKNOWN',
		stp.stp_city,
		'',
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),		--50
		@p_copy,
        '', --case ivd_type when 'DRP' then dbo.refnbrseplist_fn('orderheader',invoiceheader.ord_hdrnumber,'Y',',','BOL','PO','','') else '' end,
		ivd.cmp_id cmp_id,
		cmp2.cmp_name,
		invoiceheader.ivh_remark,
                cht.cht_itemcode,
                isnull(cmp1.cmp_address3,''),
                invoiceheader.ord_hdrnumber, 	
                invoiceheader.ivh_currency,
	        IsNull(ivd.fgt_number, 0),
			ivh_totalmiles,
			isnull(ivh_rateby, 'T'),
			0,
         isnull(ivd_distance,0),
         firstDRPSeq = case ord_number
           when '0' then 0
           else (select min(ivd_sequence) from invoicedetail id2 
              where id2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and ivd_type = 'DRP')
           end
    FROM invoiceheader
         join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber) 	
         left outer join commodity as cmd on (ivd.cmd_code = cmd.cmd_code) 
		left outer join commodityclass ccl on (ccl.ccl_code = cmd.cmd_class)
         left outer join stops as stp on (ivd.stp_number = stp.stp_number)
         left outer join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
         left outer join city cty1 on invoiceheader.ivh_origincity = cty1.cty_code
         left outer join city cty2 on invoiceheader.ivh_destcity = cty2.cty_code
         join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id
         left outer join company cmp2 on  ivd.cmp_id = cmp2.cmp_id

   WHERE	(invoiceheader.ivh_mbnumber = @p_mbnumber )	
   and ivd_type <> 'PUP'	


  END

-- for master bills with 'RTP' status

IF UPPER(@p_reprintflag) <> 'REPRINT' 
  BEGIN
     --print 'what now'
     INSERT INTO 	#masterbill_temp
     SELECT IsNull(invoiceheader.ord_number,''),
       	    invoiceheader.ivh_invoicenumber,  
            invoiceheader.ivh_hdrnumber, 
            invoiceheader.ivh_billto,   
            invoiceheader.ivh_shipper,
            invoiceheader.ivh_consignee,
            invoiceheader.ivh_totalcharge,   
            invoiceheader.ivh_originpoint,  
            invoiceheader.ivh_destpoint,   
            invoiceheader.ivh_origincity,		--10   
            invoiceheader.ivh_destcity, 
            invoiceheader.ivh_shipdate,   
            invoiceheader.ivh_deliverydate,
            invoiceheader.ivh_revtype1,
            @p_mbnumber     ivh_mbnumber,
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
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	      END,
            ivh_billto_zip = 
	      CASE		--20
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	      END,
	    isnull(invoiceheader.ivh_ref_number,''),
	    invoiceheader.ivh_tractor,
	    invoiceheader.ivh_trailer,
            cty1.cty_nmstct   origin_nmstct,
            substring(cty1.cty_state,1,2)		origin_state,
            cty2.cty_nmstct   dest_nmstct,
            substring(cty2.cty_state,1,2)		dest_state,
            --PTS#23284 ILB 07/28/2004 
	    @p_billdate billdate,
	    --ivh_billdate      billdate,
	    --PTS#23284 ILB 07/28/2004
            ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
            ivd.ivd_quantity 'bill_quantity',		--30
	    IsNull(ivd.ivd_refnum, '') ivd_refnumber,   
            IsNull(ivd.ivd_wgt, 0),
            IsNull(ivd.ivd_wgtunit, ''),
            IsNull(ivd.ivd_count, 0),
            IsNull(ivd.ivd_countunit, ''),
            IsNull(ivd.ivd_volume, 0),
            IsNull(ivd.ivd_volunit, ''),
            IsNull(ivd.ivd_unit, ''),
            Case cht.cht_basis WHEN 'TAX' then IsNull(ivd.ivd_rate, 0)/ 100.0000 else IsNull(ivd.ivd_rate, 0) end,
            IsNull(ivd.ivd_rateunit, ''),		--40
            ivd.ivd_charge,
            cht.cht_description,
            cht.cht_primary,
            cmd.cmd_name,
		   ccl.ccl_description,
            IsNull(ivd_description, ''),
            ivd.ivd_type,
			'UNKNOWN',
            stp.stp_city,
            '',
		   '',
            ivd_sequence,
            IsNull(stp.stp_number, -1),		--50
            @p_copy,
            '', --case ivd_type when 'DRP' then dbo.refnbrseplist_fn('orderheader',invoiceheader.ord_hdrnumber,'Y',',','BOL','PO','','') else '' end,
            ivd.cmp_id cmp_id,
	    cmp2.cmp_name,
	    invoiceheader.ivh_remark,
            cht.cht_itemcode,
            isnull(cmp1.cmp_address3,''),
            invoiceheader.ord_hdrnumber,	
            invoiceheader.ivh_currency,
	    IsNull(ivd.fgt_number, 0),
		ivh_totalmiles,
		isnull(ivh_rateby, 'T'),
		0,
        isnull(ivd_distance,0),
        firstDRPSeq = case ord_number
           when '0' then 0
           else (select min(ivd_sequence) from invoicedetail id2 
              where id2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and ivd_type = 'DRP')
           end
       FROM invoiceheader
         join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber) 	
         left outer join commodity as cmd on (ivd.cmd_code = cmd.cmd_code) 
		left outer join commodityclass ccl on (ccl.ccl_code = cmd.cmd_class)
         left outer join stops as stp on (ivd.stp_number = stp.stp_number)
         left outer join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
         left outer join city cty1 on invoiceheader.ivh_origincity = cty1.cty_code
         left outer join city cty2 on invoiceheader.ivh_destcity = cty2.cty_code
         join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id
         left outer join company cmp2 on  ivd.cmp_id = cmp2.cmp_id

       WHERE invoiceheader.ivh_billto = @p_billto and 
            invoiceheader.ivh_shipdate between @p_shipstart AND @p_shipend and 
            invoiceheader.ivh_mbstatus = 'RTP' and 
            @p_revtype1 in (invoiceheader.ivh_revtype1,'UNK') and 
            @p_shipper in (invoiceheader.ivh_shipper,'UNKNOWN') and
            @p_consignee IN (invoiceheader.ivh_consignee,'UNKNOWN') and
            ivd.ivd_type <> 'PUP'

  END

UPDATE #masterbill_temp 
   --SET #masterbill_temp.stp_cty_nmstct = city.cty_nmstct
SET #masterbill_temp.stp_cty_nmstct = CASE WHEN charindex('/', city.cty_nmstct) > 0 THEN substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct))-1) ELSE city.cty_nmstct END + ' ' +city.cty_zip
  FROM #masterbill_temp, city 
 WHERE #masterbill_temp.stp_city = city.cty_code
 AND   #masterbill_temp.stp_city > 0
 AND stp_number > 0

-- PTS47962 MBR 07/10/09 Added code to get the company zip from the company table.
UPDATE #masterbill_temp
   SET stp_name = company.cmp_name,
       stp_addr = company.cmp_address1,
       stp_cty_nmstct = CASE 
                           WHEN charindex('/', company.cty_nmstct) > 0 THEN substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct))-1) 
                           ELSE company.cty_nmstct 
                        END + ' ' + company.cmp_zip
  FROM #masterbill_temp JOIN company ON #masterbill_temp.cmp_id = company.cmp_id
 WHERE #masterbill_temp.stp_number > 0 AND
       #masterbill_temp.cmp_id <> 'UNKNOWN'

--make sure minimum charges are after line haul and before other accessorials
UPDATE #masterbill_temp
SET sortorder = 1
WHERE cht_primary = 'Y'

UPDATE #masterbill_temp
SET sortorder = 3
WHERE cht_primary = 'N'

UPDATE #masterbill_temp
SET sortorder = 2
WHERE cht_primary = 'Y' and cht_itemcode = 'MIN'

-- Make sure bill miles include those from any e

update #masterbill_temp
set ivd_distance = (select sum(isnull(ivd_distance,0))
   from invoicedetail id 
   where   #masterbill_temp.ivh_hdrnumber = id.ivh_hdrnumber
   and id.ivd_sequence <= #masterbill_temp.firstDRPSeq)
where ivd_sequence = firstDRPSeq

  SELECT ord_number ,
		ivh_invoicenumber, 
		ivh_hdrnumber, 
		ivh_billto,
		ivh_shipper,
		ivh_consignee,
		ivh_totalcharge,   
		ivh_originpoint,  
		ivh_destpoint,   
		ivh_origincity ,		--10   
		ivh_destcity ,   
		ivh_shipdate ,   
		ivh_deliverydate ,   
		ivh_revtype1 ,
		ivh_mbnumber ,
		ivh_billto_name ,
		ivh_billto_address ,
		ivh_billto_address2 ,
		ivh_billto_nmstct ,
		ivh_billto_zip,		--20
		ivh_ref_number ,
		ivh_tractor ,
		ivh_trailer ,
		origin_nmstct ,
		origin_state ,
		dest_nmstct ,
		dest_state ,
		billdate,
		cmp_mailto_name ,
		bill_quantity ,		--30
		ivd_refnumber ,
		ivd_weight ,
		ivd_weightunit ,
		ivd_count ,
		ivd_countunit ,
		ivd_volume ,
		ivd_volunit ,
		ivd_unit ,
		ivd_rate,
		ivd_rateunit ,		--40
		ivd_charge ,
		cht_description ,
		cht_primary ,
		cmd_name,
		cmd_class,
		ivd_description,
		ivd_type ,
		stp_name,
		stp_city,
		stp_cty_nmstct ,
		stp_addr,
		ivd_sequence ,
		stp_number,		--50
		copy ,
		ref_number ,
		cmp_id ,
		cmp_name,
		ivh_remark ,
         cht_itemcode,
        ivh_billto_address3 ,
        ord_hdrnumber ,
        ivh_currency,
	fgt_number,
	ivh_totalmiles,
	ivh_rateby,
	sortorder,
    ivd_distance
  FROM		#masterbill_temp
  ORDER BY	ivh_ref_number, ord_number, sortorder, ivd_sequence

  DROP TABLE 	#masterbill_temp
GO
GRANT EXECUTE ON  [dbo].[d_masterbill127_sp] TO [public]
GO
