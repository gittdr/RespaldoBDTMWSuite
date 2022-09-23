SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*          
                 CHANGE LOG
  


 10/22/08 DPETE copied from d_masterbill14_sp for new format 123. Unlike 14 this does not have a summary page and shows invoice details

*/

CREATE PROC [dbo].[d_masterbill123_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                       @shipstart datetime,@shipend datetime,@billdate datetime, 
                               @shipper varchar(8), @consignee varchar(8),
                               @copy int,@ps_fromorder varchar(13),@pdtm_delstart datetime,@pdtm_delend datetime)
AS

DECLARE @int0  int, @level smallint
SELECT @int0 = 0, @level = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'





-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
 
    SELECT 	totalordetail = 1,
		ord_number = IsNull(invoiceheader.ord_number, ''),
		ord_hdrnumber = IsNull(invoiceheader.ord_hdrnumber, -1),
		ivh_invoicenumber = invoiceheader.ivh_invoicenumber,  
		ivh_hdrnumber = invoiceheader.ivh_hdrnumber, 
		ivh_billto = invoiceheader.ivh_billto ,
		ivh_shipper = invoiceheader.ivh_shipper ,
		ivh_consignee = invoiceheader.ivh_consignee ,   
		ivd_charge = ivd.ivd_charge,   
		ivh_shipdate =  CAST( FLOOR( CAST( invoiceheader.ivh_shipdate AS FLOAT ) ) AS DATETIME),  
		ivh_deliverydate = invoiceheader.ivh_deliverydate,
		mbnumber = invoiceheader.ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
		ivh_billto_name = case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then cmp1.cmp_name
          else cmp1.cmp_mailto_name
          end,
		ivh_billto_address = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,''))
          when '' then   cmp1.cmp_address1
          else cmp1.cmp_mailto_address1
          end,''),
		ivh_billto_address2 = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then   cmp1.cmp_address2
          else cmp1.cmp_mailto_address2
          end,''),
        ivh_billto_address3 = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then   cmp1.cmp_address3
          else ''
          end,''),

		ivh_billto_city = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then  SUBSTRING(cmp1.cty_nmstct,1, CHARINDEX(',',cmp1.cty_nmstct + ',/')- 1 ) 
                --+ ', ' + substring(cmp1.cty_nmstct,CHARINDEX(',',cmp1.cty_nmstct + ',/') + 1,charindex('/',cmp1.cty_nmstct+',/') - (CHARINDEX(',',cmp1.cty_nmstct + ',/') + 1))
          else  SUBSTRING(cmp1.mailto_cty_nmstct,1, CHARINDEX(',',cmp1.mailto_cty_nmstct + ',/')- 1 ) 
                --+ ', ' + substring(cmp1.mailto_cty_nmstct,CHARINDEX(',',cmp1.mailto_cty_nmstct + ',/') + 1,charindex('/',cmp1.mailto_cty_nmstct+',/') - (CHARINDEX(',',cmp1.mailto_cty_nmstct + ',/') + 1))
        end,''),
        ivh_billto_state = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then   substring(cmp1.cty_nmstct,CHARINDEX(',',cmp1.cty_nmstct + ',/') + 1,charindex('/',cmp1.cty_nmstct+',/') - (CHARINDEX(',',cmp1.cty_nmstct + ',/') + 1))
          else   substring(cmp1.mailto_cty_nmstct,CHARINDEX(',',cmp1.mailto_cty_nmstct + ',/') + 1,charindex('/',cmp1.mailto_cty_nmstct+',/') - (CHARINDEX(',',cmp1.mailto_cty_nmstct + ',/') + 1))
        end,''),
        ivh_billto_zip = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then   cmp1.cmp_zip
          else cmp1.cmp_mailto_zip
          end,''),
		ivh_consignee_name = cmp3.cmp_name,
		ivh_consignee_misc1 = cmp3.cmp_misc1,
		ivh_consignee_misc2 = cmp3.cmp_misc2,
		ivh_consignee_misc3 = cmp3.cmp_misc3,
		ivh_consignee_misc4 = cmp3.cmp_misc4,
		billdate = ivh_billdate      ,
		ivd_quantity = ISNULL(ivd_quantity,0)  ,
		ivd_unit = ISNULL(ivd_unit,'UNK') ,
		ivd_rate = ISNULL(ivd.ivd_rate,0) ,
		ivd_rateunit = IsNull(ivd.ivd_rateunit, '') ,
		cmd_code = ivd.cmd_code,
		description = case ivd_description        --cmd_description = ISNULL(cmd.cmd_name,'') ,
          when 'UNKNOWN' then cht_description
          else ivd_description + case ivd.cht_itemcode when 'MIN' then ' (MIN)' else '' end
          end,
		copy = @copy ,
		ivh_tractor,
		jobnumber = ivh_ref_number,
        ivh_driver,
        ivh_trailer,
        ivd_type,
        ivd_sequence,
        ord_description
    FROM 	invoiceheader
        left outer join orderheader on invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
		join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id
		join company cmp2 on invoiceheader.ivh_shipper = cmp2.cmp_id
		join company cmp3 on invoiceheader.ivh_consignee = cmp3.cmp_id
		join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
		join chargetype on ivd.cht_itemcode = chargetype.cht_itemcode
        join city cmpcity on cmp1.cmp_city = cmpcity.cty_code
        left outer join city mailcity on cmp1.cmp_mailto_city = mailcity.cty_code
   WHERE	( invoiceheader.ivh_mbnumber = @mbnumber )
		AND  ivd_charge <> 0 -- cust does nto want to see delivery lines
	order by ivh_shipdate,ivh_hdrnumber,ivd_sequence	

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
    
     SELECT 	totalordetail = 1,
		ord_number = IsNull(invoiceheader.ord_number, ''),
		ord_hdrnumber = IsNull(invoiceheader.ord_hdrnumber, -1),
		ivh_invoicenumber = invoiceheader.ivh_invoicenumber,  
		ivh_hdrnumber = invoiceheader.ivh_hdrnumber, 
		ivh_billto = invoiceheader.ivh_billto ,
		ivh_shipper = invoiceheader.ivh_shipper ,
		ivh_consignee = invoiceheader.ivh_consignee ,   
		ivd_charge = ivd.ivd_charge,  
		ivh_shipdate =  CAST( FLOOR( CAST( invoiceheader.ivh_shipdate AS FLOAT ) ) AS DATETIME),   /* to help group on date */
		ivh_deliverydate = invoiceheader.ivh_deliverydate,
		mbnumber = @mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
		ivh_billto_name = case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then cmp1.cmp_name
          else cmp1.cmp_mailto_name
          end,
		ivh_billto_address = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,''))
          when '' then   cmp1.cmp_address1
          else cmp1.cmp_mailto_address1
          end,''),
		ivh_billto_address2 = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then   cmp1.cmp_address2
          else cmp1.cmp_mailto_address2
          end,''),
        ivh_billto_address3 = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then   cmp1.cmp_address3
          else ''
          end,''),

		ivh_billto_city = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then  SUBSTRING(cmp1.cty_nmstct,1, CHARINDEX(',',cmp1.cty_nmstct + ',/')- 1 ) 
                --+ ', ' + substring(cmp1.cty_nmstct,CHARINDEX(',',cmp1.cty_nmstct + ',/') + 1,charindex('/',cmp1.cty_nmstct+',/') - (CHARINDEX(',',cmp1.cty_nmstct + ',/') + 1))
          else  SUBSTRING(cmp1.mailto_cty_nmstct,1, CHARINDEX(',',cmp1.mailto_cty_nmstct + ',/')- 1 ) 
                --+ ', ' + substring(cmp1.mailto_cty_nmstct,CHARINDEX(',',cmp1.mailto_cty_nmstct + ',/') + 1,charindex('/',cmp1.mailto_cty_nmstct+',/') - (CHARINDEX(',',cmp1.mailto_cty_nmstct + ',/') + 1))
        end,''),
        ivh_billto_state = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then   substring(cmp1.cty_nmstct,CHARINDEX(',',cmp1.cty_nmstct + ',/') + 1,charindex('/',cmp1.cty_nmstct+',/') - (CHARINDEX(',',cmp1.cty_nmstct + ',/') + 1))
          else   substring(cmp1.mailto_cty_nmstct,CHARINDEX(',',cmp1.mailto_cty_nmstct + ',/') + 1,charindex('/',cmp1.mailto_cty_nmstct+',/') - (CHARINDEX(',',cmp1.mailto_cty_nmstct + ',/') + 1))
        end,''),
        ivh_billto_zip = isnull(case rtrim(isnull(cmp1.cmp_mailto_name,'')) 
          when '' then   cmp1.cmp_zip
          else cmp1.cmp_mailto_zip
          end,''),
		ivh_consignee_name = cmp3.cmp_name,
		ivh_consignee_misc1 = cmp3.cmp_misc1,
		ivh_consignee_misc2 = cmp3.cmp_misc2,
		ivh_consignee_misc3 = cmp3.cmp_misc3,
		ivh_consignee_misc4 = cmp3.cmp_misc4,
		billdate = @billdate,  --10015  ivh_billdate      ,
		ivd_quantity = ISNULL(ivd_quantity,0)  ,
		ivd_unit = ISNULL(ivd_unit,'UNK') ,
		ivd_rate = ISNULL(ivd.ivd_rate,0) ,
		ivd_rateunit = IsNull(ivd.ivd_rateunit, '') ,
		cmd_code = ivd.cmd_code,
		description = case ivd_description        --cmd_description = ISNULL(cmd.cmd_name,'') ,
          when 'UNKNOWN' then cht_description
          else ivd_description + case ivd.cht_itemcode when 'MIN' then ' (MIN)' else '' end
          end,
		copy = @copy ,
		ivh_tractor,
		jobnumber = ivh_ref_number,
        ivh_driver,
        ivh_trailer,
        ivd_type,
        ivd_sequence,
        ord_description
	 FROM 	invoiceheader
        left outer join orderheader on invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
		join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id
		join company cmp2 on invoiceheader.ivh_shipper = cmp2.cmp_id
		join company cmp3 on invoiceheader.ivh_consignee = cmp3.cmp_id
		join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
		join chargetype on ivd.cht_itemcode = chargetype.cht_itemcode
	WHERE 	( invoiceheader.ivh_billto = @billto )  
		AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		AND     (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
        and @shipper in (ivh_shipper,'UNKNOWN')
        and @consignee in (ivh_consignee,'UNKNOWN')
        and @ps_fromorder = ISNULL(ord_fromorder,'') -- client uses format for TOE orders only
        and invoiceheader.ivh_deliverydate between @pdtm_delstart and @pdtm_delend
        and ivd_charge <> 0  -- client does not want to see delivery lines
	order by ivh_shipdate,ivh_hdrnumber,ivd_sequence	

  END

  
GO
GRANT EXECUTE ON  [dbo].[d_masterbill123_sp] TO [public]
GO
