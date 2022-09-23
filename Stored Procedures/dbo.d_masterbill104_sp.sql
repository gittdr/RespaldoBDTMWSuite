SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill104_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	@revtype1 varchar(6), @mbstatus varchar(6),@shipstart datetime,
        @shipend datetime,@billdate datetime, @shipper varchar(8),@consignee varchar(8),
        @copy int, @ivh_invoicenumber varchar(12), @lastupdateby varchar(50))

AS
/**
 * 
 * NAME:
 * dbo.d_masterbill104_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure seveloped from d_masterbill08_sp is for Samual Coraluzzo
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * See belowd
 *
 * PARAMETERS:
 * 001 - @ord int the ord_hdrnumber of the order being rated
 * 002 - @tar the tar_number of the tariff selected by the rating engine for this order
 *
 * REFERENCES: (NONE)

 * 
 * REVISION HISTORY:
 * 11/16/07 PTS 39336 DPETE created from format 08
 * 2/28/08 PTS 41338 BDH returning the cht_itemcode
 * 01/06/2009 PTS 45400 pmill - allow filtering on last updated by field
 **/


DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'






-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN

    SELECT 	IsNull(invoiceheader.ord_number, ivh_invoicenumber),
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
		ivh_billto_name = 
         CASE RTRIM(isnull(cmp1.cmp_mailto_name,'')) 
         WHEN '' then cmp1.cmp_name
         ELSE cmp1.cmp_mailto_name
         END,
	 ivh_billto_address = 
	    CASE  RTRIM(isnull(cmp1.cmp_mailto_name,'')) 
        WHEN '' THEN  ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_billto_address2 = 
        CASE RTRIM(isnull(cmp1.cmp_mailto_name,'')) 
        WHEN '' THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 ivh_billto_nmstct = 
	    CASE RTRIM(isnull(cmp1.cmp_mailto_name,'')) 
        WHEN '' THEN 
		   CASE CHARINDEX('/',cmp1.cty_nmstct)
           WHEN 0 THEN cmp1.cty_nmstct
           ELSE ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
           END
		ELSE 
           CASE CHARINDEX('/',cmp1.mailto_cty_nmstct)
           WHEN 0 then cmp1.mailto_cty_nmstct
           ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
           END
	    END,
	ivh_billto_zip = 
        CASE isnull(cmp1.cmp_mailto_name,'') 
        WHEN '' THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		invoiceheader.ivh_ref_number,
		invoiceheader.ivh_tractor,
		invoiceheader.ivh_trailer,
		cty1.cty_nmstct   origin_nmstct,
		cty1.cty_state		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state		dest_state,
		ivh_billdate      billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		IsNull(ivd.ivd_refnum, ''),
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
		(select cty_nmstct from city cty3 where cty3.cty_code = stp.stp_city and stp.stp_city > 0) stp_cty_nmstct ,
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		ivd.cmp_id cmp_id,
		isnull(stp.cmp_name,'') cmp_name,
		invoiceheader.ivh_remark,
		ivd.cht_itemcode  -- 41338

    FROM 	invoiceheader 
	   join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id 
	   join city cty1 on ivh_origincity = cty1.cty_code 
	   join city cty2 on ivh_destcity = cty2.cty_code 
	   join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
       left outer join stops stp on ivd.stp_number = stp.stp_number 
       left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code 
	   left outer join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
   WHERE	( invoiceheader.ivh_mbnumber = @mbnumber )
   order by ivh_invoicenumber,ivd_sequence

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN

     SELECT IsNull(invoiceheader.ord_number,ivh_invoicenumber),
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
            ivh_billto_name = 
         CASE RTRIM(isnull(cmp1.cmp_mailto_name,'')) 
         WHEN '' then cmp1.cmp_name
         ELSE cmp1.cmp_mailto_name
         END,
	 ivh_billto_address = 
	    CASE  RTRIM(isnull(cmp1.cmp_mailto_name,'')) 
        WHEN '' THEN  ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_billto_address2 = 
        CASE RTRIM(isnull(cmp1.cmp_mailto_name,'')) 
        WHEN '' THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	  ivh_billto_nmstct = 
	    CASE RTRIM(isnull(cmp1.cmp_mailto_name,'')) 
        WHEN '' THEN 
		   CASE CHARINDEX('/',cmp1.cty_nmstct)
           WHEN 0 THEN cmp1.cty_nmstct
           ELSE ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
           END
		ELSE 
           CASE CHARINDEX('/',cmp1.mailto_cty_nmstct)
           WHEN 0 then cmp1.mailto_cty_nmstct
           ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
           END
	    END,
	ivh_billto_zip = 
        CASE isnull(cmp1.cmp_mailto_name,'') 
        WHEN '' THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	    invoiceheader.ivh_ref_number,
	    invoiceheader.ivh_tractor,
	    invoiceheader.ivh_trailer,
	    cty1.cty_nmstct   origin_nmstct,
            cty1.cty_state		origin_state,
            cty2.cty_nmstct   dest_nmstct,
            cty2.cty_state		dest_state,
            @billdate	billdate,
            ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
            ivd.ivd_quantity 'bill_quantity',
	    IsNull(ivd.ivd_refnum, ''),
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
            (select cty_nmstct from city cty3 where cty3.cty_code = stp.stp_city and stp.stp_city > 0) stp_cty_nmstct ,
            ivd_sequence,
            IsNull(stp.stp_number, -1),
            @copy,
        ivd.cmp_id cmp_id,
	    isnull(stp.cmp_name,'') cmp_name,
	    invoiceheader.ivh_remark,
		ivd.cht_itemcode  -- 41338
       FROM 	invoiceheader 
	   join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id 
	   join city cty1 on ivh_origincity = cty1.cty_code 
	   join city cty2 on ivh_destcity = cty2.cty_code 
	   join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
       left outer join stops stp on ivd.stp_number = stp.stp_number 
       left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code 
	   left outer join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
      WHERE invoiceheader.ivh_billto = @billto and
            invoiceheader.ivh_shipdate between @shipstart AND @shipend and 
            invoiceheader.ivh_mbstatus = 'RTP' and 
            @revtype1 in (invoiceheader.ivh_revtype1,'UNK') and 
            @shipper in (invoiceheader.ivh_shipper,'UNKNOWN') and
            @consignee IN (invoiceheader.ivh_consignee,'UNKNOWN') and
            @ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master') and
			@lastupdateby IN ( CASE isnull(ivh_user_id2, 'NULL') WHEN 'NULL' THEN ivh_user_id1 ELSE ivh_user_id2  END, 'UNK' )  --45400 pmill
     order by ivh_invoicenumber,ivd_sequence

  END

GO
GRANT EXECUTE ON  [dbo].[d_masterbill104_sp] TO [public]
GO
