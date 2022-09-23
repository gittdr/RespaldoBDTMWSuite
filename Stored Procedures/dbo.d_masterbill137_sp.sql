SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill137_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                       @shipstart datetime,@shipend datetime,@billdate datetime, 
                               @shipper varchar(8), @consignee varchar(8),
                               @copy int,@ivh_invoicenumber varchar(12),@refnum varchar(30))
AS


/**
 * 
 * NAME:
 * dbo.d_masterbill137_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data for Masterbill 103
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * 001 - ord_hdrnumber int,
 * 002 - ivh_invoicenumber varchar(12),  
 * 003 - ivh_hdrnumber int NULL, 
 * 004 - ivh_billto varchar(8) NULL,
 * 005 - ivh_shipper varchar(8) NULL,
 * 006 - ivh_consignee varchar(8) NULL,
 * 007 - ivh_totalcharge money NULL,   
 * 008 - ivh_originpoint  varchar(8) NULL,  
 * 009 - ivh_destpoint varchar(8) NULL,   
 * 010 - ivh_origincity int NULL,   
 * 011 - ivh_destcity int NULL,   
 * 012 - ivh_shipdate datetime NULL,   
 * 013 - ivh_deliverydate datetime NULL,   
 * 014 - ivh_revtype1 varchar(6) NULL,
 * 015 - ivh_mbnumber int NULL,
 * 016 - ivh_shipper_name varchar(100) NULL ,
 * 017 - ivh_shipper_address varchar(100) NULL,
 * 018 - ivh_shipper_address2 varchar(100) NULL,
 * 019- ivh_shipper_nmstct varchar(25) NULL ,
 * 020 - ivh_shipper_zip varchar(9) NULL,
 * 021 - ivh_billto_name varchar(100)  NULL,
 * 022 - ivh_billto_address varchar(100) NULL,
 * 023 - ivh_billto_address2 varchar(100) NULL,
 * 024 - ivh_billto_nmstct varchar(25) NULL ,
 * 025 - ivh_billto_zip varchar(10) NULL,
 * 026 - ivh_consignee_name varchar(100)  NULL,
 * 027 - ivh_consignee_address varchar(100) NULL,
 * 028 - ivh_consignee_address2 varchar(100) NULL,
 * 029 - ivh_consignee_nmstct varchar(25)  NULL,
 * 030 - ivh_consignee_zip varchar(10) NULL,
 * 031 - origin_nmstct varchar(25) NULL,
 * 032 - origin_state varchar(6) NULL,
 * 033 - dest_nmstct varchar(25) NULL,
 * 034 - dest_state varchar(6) NULL,
 * 035 - billdate datetime NULL,
 * 036 - cmp_mailto_name varchar(30)  NULL,
 * 037 - bill_quantity float  NULL,
 * 038 - ivd_weight float NULL,
 * 039 - ivd_weightunit char(6) NULL,
 * 040 - ivd_count float NULL,
 * 041 - ivd_countunit char(6) NULL,
 * 042 - ivd_volume float NULL,
 * 043 - ivd_volunit char(6) NULL,
 * 044 - ivd_unit char(6) NULL,
 * 045 - ivd_rate money NULL,
 * 046 - ivd_rateunit char(6) NULL,
 * 047 - ivd_charge money NULL,
 * 048 - cht_description varchar(30) NULL,
 * 049 - cht_primary char(1) NULL,
 * 050 - cmd_name varchar(60)  NULL,
 * 051 - ivd_description varchar(60) NULL,
 * 052 - ivd_type char(6) NULL,
 * 053 - stp_city int NULL,
 * 054 - stp_cty_nmstct varchar(25) NULL,
 * 055 - ivd_sequence int NULL,
 * 056 - stp_number int NULL,
 * 057 - copy int NULL,
 * 058 - cmp_id varchar(8) NULL,
 * 059 - cht_basis varchar(6) null,
 * 060 - cht_basisunit varchar(6)null,
 * 061 - ivd_distance float null,
 * 062 - ivd_distunit char(6)null,
 * 063 - mb_ordercount int null
 * 064 - ivh_arcurrency varchar(6) null
 *
 * PARAMETERS:
 * 001 - @reprintflag varchar(10),
 * 002 - @mbnumber int,
 * 003 - @billto varchar(8),
 * 004 - @revtype1 varchar(6),
 * 005 - @revtype2 varchar(6),
 * 006 - @mbstatus varchar(6),
 * 007 - @shipstart datetime,
 * 008 - @shipend datetime,
 * 009 - @billdate datetime, 
 * 010 - @shipper varchar(8),
 * 011 - @consignee varchar(8),
 * 012 - @copy int,
 * 013 - @ivh_invoicenumber varchar(12),
 *
 * REFERENCES:
 * 001 - dbo.notes
 * 
 * REVISION HISTORY:
 * 09/21/2006.01 EMK - Created stored proc for use with Master Bill Format 91
 * 				 Adjusted varchar lengths to match databases.  Moved ivd_type filter 
 *				 from final select to initial selects.          
 * 1/23/09 PTS 45768 minimum on accessroail not rolling into lint haul
 *    minacc charges are not right after the original in the invoice details
 * 1/06/2010 PTS 50122 Copied d_masterbill103_sp and created d_masterbill137_sp
 **/



SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'




-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
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
	    ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),
	    ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),
	    ivh_shipto_nmstct =  ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),''),
	   ivh_shipto_zip = ISNULL(cmp2.cmp_zip,''),
	   ivh_billto_name = CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_name,'')
		ELSE ISNULL(cmp1.cmp_mailto_name,'')
	    END,
	    ivh_billto_address = CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	   ivh_billto_address2 = CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	   ivh_billto_nmstct = CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN 
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
	   ivh_billto_zip = CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		ivh_consignee_name = cmp3.cmp_name,

	    ivh_consignee_address = ISNULL(cmp3.cmp_address1,''),

	    ivh_consignee_address2 =  ISNULL(cmp3.cmp_address2,''),
	
	    ivh_consignee_nmstct = 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
						      END),''),
	   ivh_consignee_zip = ISNULL(cmp3.cmp_mailto_zip,''),
		cty1.cty_nmstct   origin_nmstct,
		cty1.cty_state		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state		dest_state,
		ivh_billdate      billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		case ivd_type when 'SUB' then ivh_totalweight else IsNull(ivd.ivd_wgt, 0) end,
		IsNull(ivd.ivd_wgtunit, ''),
		case ivd_type when 'SUB'  then ivh_totalpieces else IsNull(ivd.ivd_count, 0)end,
		IsNull(ivd.ivd_countunit, ''),
		case ivd_type when 'SUB' then ivh_totalvolume else IsNull(ivd.ivd_volume, 0) end,
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
		IsNull(ivd.ivd_rate, 0),
		IsNull(ivd.ivd_rateunit, ''),
		ivd.ivd_charge,
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		IsNull(ivd_description, '') ivd_description,
		ivd.ivd_type,		
		ivd_sequence = case ivd.cht_rollintolh when 1 then 999 else ivd_sequence end, /* put rollins at end */
		copy = @copy,
		ivd.cmp_id cmp_id,
                cht.cht_basis,
                cht.cht_basisunit,
         case ivd_type when 'SUB' then ivh_totalmiles else IsNull(ivd.ivd_distance, 0) end,
                ivd_distunit,
				invoiceheader.ivh_currency,
        case ivd.cht_itemcode  -- note this customers charges are all scrambled
          when 'MINACC' then (select cg2.cht_rollintolh from invoicedetail ivd2
                 join chargetype cg2 on ivd2.cht_itemcode =  cg2.cht_itemcode 
                 where ivd2.ivh_hdrnumber = ivd.ivh_hdrnumber
                 and ivd2.tar_number = ivd.tar_number
                 and ivd2.cht_itemcode <> 'MINACC'  )
          else isnull(ivd.cht_rollintolh,0) 
        end cht_rollintolh,
        ivd.tar_number

    FROM 	invoiceheader  
		join company cmp1 on cmp1.cmp_id = invoiceheader.ivh_billto
		join company cmp2 on cmp2.cmp_id = invoiceheader.ivh_shipper
		join company cmp3 on cmp3.cmp_id = invoiceheader.ivh_consignee
		join city cty1 on cty1.cty_code = invoiceheader.ivh_origincity
		join city cty2 on cty2.cty_code = invoiceheader.ivh_destcity
		join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
		left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code
		join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode

   WHERE	( invoiceheader.ivh_mbnumber = @mbnumber )
			AND isnull(ivd_charge,0) <> 0
   ORDER BY ivh_invoicenumber,  ivd_sequence 


  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     
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
		@mbnumber     ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
	    ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),
	    ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),
	    ivh_shipto_nmstct =  ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),''),
	   ivh_shipto_zip = ISNULL(cmp2.cmp_zip,''),
	   ivh_billto_name = CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_name,'')
		ELSE ISNULL(cmp1.cmp_mailto_name,'')
	    END,
	    ivh_billto_address = CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	   ivh_billto_address2 = CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	   ivh_billto_nmstct = CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN 
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
	   ivh_billto_zip = CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		ivh_consignee_name = cmp3.cmp_name,

	    ivh_consignee_address = ISNULL(cmp3.cmp_address1,''),

	    ivh_consignee_address2 =  ISNULL(cmp3.cmp_address2,''),
	
	    ivh_consignee_nmstct = 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
						      END),''),
	   ivh_consignee_zip = ISNULL(cmp3.cmp_mailto_zip,''),
		cty1.cty_nmstct   origin_nmstct,
		cty1.cty_state		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state		dest_state,
		@billdate	billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		case ivd_type when 'SUB' then ivh_totalweight else IsNull(ivd.ivd_wgt, 0) end,
		IsNull(ivd.ivd_wgtunit, ''),
		case ivd_type when 'SUB'  then ivh_totalpieces else IsNull(ivd.ivd_count, 0)end,
		IsNull(ivd.ivd_countunit, ''),
		case ivd_type when 'SUB' then ivh_totalvolume else IsNull(ivd.ivd_volume, 0) end,
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
		IsNull(ivd.ivd_rate, 0),
		IsNull(ivd.ivd_rateunit, ''),
		ivd.ivd_charge,
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		IsNull(ivd_description, '') ivd_description,
		ivd.ivd_type,		
		ivd_sequence = case ivd.cht_rollintolh when 1 then 999 else ivd_sequence end, /* put rollins at end */
		copy = @copy,
		ivd.cmp_id cmp_id,
                cht.cht_basis,
                cht.cht_basisunit,
         case ivd_type when 'SUB' then ivh_totalmiles else IsNull(ivd.ivd_distance, 0) end,
                ivd_distunit,
				invoiceheader.ivh_currency,
       case ivd.cht_itemcode  -- note this customers charges are all scrambled
          when 'MINACC' then (select cg2.cht_rollintolh from invoicedetail ivd2
                 join chargetype cg2 on ivd2.cht_itemcode =  cg2.cht_itemcode 
                 where ivd2.ivh_hdrnumber = ivd.ivh_hdrnumber
                 and ivd2.tar_number = ivd.tar_number
                 and ivd2.cht_itemcode <> 'MINACC'  )
          else isnull(ivd.cht_rollintolh,0) 
        end cht_rollintolh,
        ivd.tar_number
   
	FROM 	invoiceheader
		join company cmp1 on cmp1.cmp_id = invoiceheader.ivh_billto
		join company cmp2 on cmp2.cmp_id = invoiceheader.ivh_shipper
		join company cmp3 on cmp3.cmp_id = invoiceheader.ivh_consignee
		join city cty1 on cty1.cty_code = invoiceheader.ivh_origincity
		join city cty2 on cty2.cty_code = invoiceheader.ivh_destcity
		join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
		left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code
		join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
	WHERE 	( invoiceheader.ivh_billto = @billto )  
		AND (invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		AND (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
		AND (@shipper in( invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee in ( invoiceheader.ivh_consignee,'UNKNOWN'))
        AND (@refnum IN (invoiceheader.ivh_ref_number,''))
		AND isnull(ivd_charge,0) <> 0
		ORDER BY ivh_invoicenumber, ivd_sequence

  END



GO
GRANT EXECUTE ON  [dbo].[d_masterbill137_sp] TO [public]
GO
