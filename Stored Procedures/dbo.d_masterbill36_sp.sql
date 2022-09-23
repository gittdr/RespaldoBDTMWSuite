SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill36_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	@revtype1 varchar(6), @mbstatus varchar(6),
	@shipstart datetime,@shipend datetime,@billdate datetime,@copy int)
AS

/**
 * DESCRIPTION:
 * Created to allow reprinting of masterbills
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
-- dpete pts 6691 change ivd_coutn and ivd_volume on temp tableto float
--DPETE PTS17762 When 'ALL' ispassed in @revtype1 (for format 03b), match to all revtypes.
 * 10/30/2007.01 ? PTS40029 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @int0  int, @TOTAL_GST MONEY, @TOTAL_PST MONEY, @charge money,
        @code varchar(8), @ord_hdrnumber int, @gst_idnumber varchar(60)
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
SELECT @total_gst = 0.00
SELECT @total_pst = 0.00


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
	shipticket varchar(30) NULL,
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
	ivh_ref_number varchar(30)NULL,
	--ILB 10-18-2002 PTS# 15194
        cht_itemcode varchar(8)NULL,
        gst_total MONEY NULL,
        pst_total MONEY NULL,
        gst_idnumber varchar(60) NULL)
  

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
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
	@copy,
	cht.cht_primary,
	cht.cht_description,
	ivd.ivd_sequence,
	--ILB 10-18-2002 PTS# 15194
	invoiceheader.ivh_ref_number,  
	--ILB 10-18-2002 PTS# 15194
        ivd.cht_itemcode,
        @total_gst gst_total,
        @total_pst pst_total,
        '' gst_idnumber
    FROM invoiceheader  LEFT OUTER JOIN  orderheader oh  ON  invoiceheader.ord_hdrnumber  = oh.ord_hdrnumber   
			LEFT OUTER JOIN  company cmp1  ON  cmp1.cmp_id  = invoiceheader.ivh_billto   
			LEFT OUTER JOIN  company cmp3  ON  cmp3.cmp_id  = invoiceheader.ivh_shipper ,
	 invoicedetail ivd  LEFT OUTER JOIN  stops  ON  ivd.stp_number  = stops.stp_number   
			LEFT OUTER JOIN  commodity cmd  ON  ivd.cmd_code  = cmd.cmd_code ,
	 city cty1,
	 city cty2,
	 chargetype cht 
   WHERE ( invoiceheader.ivh_mbnumber = @mbnumber ) 
	AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
	AND (ivd.cht_itemcode = cht.cht_itemcode)
	AND (cty1.cty_code = invoiceheader.ivh_origincity) 
	AND (cty2.cty_code = invoiceheader.ivh_destcity)
	--AND (ivd.ivd_volume > 0 OR ivd_quantity > 0)

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
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
        @mbnumber ivh_mbnumber, 
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
	@billdate billdate,
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
	@copy,
	cht.cht_primary,
	cht.cht_description,
	ivd.ivd_sequence,
	--ILB 10-18-2002 PTS# 15194
	invoiceheader.ivh_ref_number, 
	--ILB 10-18-2002 PTS# 15194
        ivd.cht_itemcode,
        @total_gst gst_total,
        @total_pst pst_total,
        '' gst_idnumber
    FROM invoiceheader  LEFT OUTER JOIN  orderheader oh  ON  invoiceheader.ord_hdrnumber  = oh.ord_hdrnumber   
			LEFT OUTER JOIN  company cmp1  ON  cmp1.cmp_id  = invoiceheader.ivh_billto ,
	 invoicedetail ivd  LEFT OUTER JOIN  stops  ON  ivd.stp_number  = stops.stp_number   
			LEFT OUTER JOIN  commodity cmd  ON  ivd.cmd_code  = cmd.cmd_code ,
	 city cty1,
	 city cty2,
	 company cmp3,
	 chargetype cht 
   WHERE ( invoiceheader.ivh_billto = @billto )  
     AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
     AND (ivd.cht_itemcode = cht.cht_itemcode)
     AND (invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
     AND (invoiceheader.ivh_mbstatus = 'RTP') 
     AND (@revtype1 in (invoiceheader.ivh_revtype1,'ALL')) 
     AND (cmp3.cmp_id = invoiceheader.ivh_shipper)
     AND (cty1.cty_code = invoiceheader.ivh_origincity) 
     AND (cty2.cty_code = invoiceheader.ivh_destcity)           
  END

--Create a cursor based on the select statement below 
  DECLARE pstgst_cursor CURSOR FOR  
     SELECT ivd_charge,
            cht_itemcode,
            ord_hdrnumber       
       FROM #masterbill_temp
      WHERE cht_itemcode IN ('G.S.T.','P.S.T.') 
    
  OPEN pstgst_cursor  
    
  FETCH NEXT FROM pstgst_cursor INTO @charge, @code,@ord_hdrnumber
  
  --If the fetch is succesful continue to loop
  WHILE @@fetch_status = 0  
   BEGIN  
    
    IF @code = 'G.S.T.' --GST TAX GRAND TOTAL  
      BEGIN
        SELECT @total_gst = @charge 

         UPDATE #masterbill_temp
            SET gst_total = @total_gst
          WHERE cht_itemcode = 'G.S.T.' and 
                ord_hdrnumber = @ord_hdrnumber                            
      END
   
    IF @code = 'P.S.T.' --PST TAX GRAND TOTAL
       BEGIN
         SELECT @total_pst = @charge 	
         
         UPDATE #masterbill_temp
            SET pst_total = @total_pst
          WHERE cht_itemcode = 'P.S.T.' and 
                ord_hdrnumber = @ord_hdrnumber                   
       END
     
     --Reset variables ILB 03/27/03 
     SELECT @charge = 0
     SELECT @code = ''
     SELECT @total_pst = 0
     SELECT @total_gst = 0
       
     --Fetch the next set of variables
     FETCH NEXT FROM pstgst_cursor INTO @charge, @code, @ord_hdrnumber
   END  
  
--Close cursor  
CLOSE pstgst_cursor
--Release cusor resources  
DEALLOCATE pstgst_cursor

UPDATE #masterbill_temp 
   set shipticket = (SELECT IsNull(MIN(ref_number), '')
	  	       FROM referencenumber ref
		      WHERE ref.ref_table = 'orderheader' AND
			    ref.ref_tablekey = #masterbill_temp.ord_hdrnumber AND
			    ref.ref_type = 'SHIPTK')

UPDATE #masterbill_temp 
   SET #masterbill_temp.stp_nmstct = city.cty_nmstct
  FROM #masterbill_temp, city 
 WHERE #masterbill_temp.stp_city = city.cty_code


select @gst_idnumber = gi_string1
  from generalinfo
 where upper(gi_name) = 'GSTNUMBER'

update #masterbill_temp
   set gst_idnumber = @gst_idnumber

  SELECT * 
    from #masterbill_temp
ORDER by ivh_invoicenumber,ivd_sequence

DROP TABLE #masterbill_temp
GO
GRANT EXECUTE ON  [dbo].[d_masterbill36_sp] TO [public]
GO
