SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill17b_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	@originpoint varchar(8),@revtype1 varchar(6), @mbstatus varchar(6),
	@shipstart datetime,@shipend datetime,@billdate datetime, @shipper varchar(8), 
        @consignee varchar(8), @copy int, @ivh_invoicenumber varchar(12),
	@batch varchar(254), @batch_count int)
AS
/**
 * DESCRIPTION:
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
-- 10/7/99 dpete retrieve cmp_id for d_mb_format05
-- 07/25/2002	Vern Jewett (label=vmj1)	PTS 14924: lengthen ivd_description from 30 to
--											60 chars
 * 10/26/2007.01 ? PTS40029 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
DECLARE @order int
DECLARE @ivd int
DECLARE @min_ref varchar(30)
DECLARE @label varchar(20)
Declare @ref   varchar(30)
DECLARE @int0  int
Declare @totalref int
DECLARE @count INT

SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'

DECLARE	@batch_id_1 	varchar(10),
	@i_batch	int,
	@batch_string	varchar(254)

select @batch_string = RTRIM(@batch)
select @i_batch = 0
select @count = 1

create table #batch (batch_id varchar(10) not null)
insert #batch (batch_id) values('XXX,')

WHILE @count <= @batch_count
BEGIN
	select @i_batch = charindex(',', @batch_string)
	If @i_batch > 0
	BEGIN
		SELECT @batch_id_1 = substring(@batch_string, 1, (@i_batch - 1))
		select @batch_string = substring(@batch_string, (@i_batch + 1), (254 - @i_batch))
		insert #batch (batch_id) values(@batch_id_1)
		select @count = @count + 1
	END
	If @count > 1 and @i_batch = 0
	BEGIN
		insert #batch (batch_id) values(@batch_string)
		select @count = @count + 1
	END
END

CREATE TABLE #masterbill_temp (		ord_hdrnumber int,
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
		ivh_billto_name varchar(30)  NULL,
		ivh_billto_address varchar(40) NULL,
		ivh_billto_address2 varchar(40) NULL,
		ivh_billto_nmstct varchar(25) NULL ,
		ivh_billto_zip varchar(9) NULL,
		ivh_ref_number varchar(30) NULL,
		ivh_tractor varchar(8) NULL,
		ivh_trailer varchar(13) NULL,
		origin_nmstct varchar(25) NULL,
		origin_state varchar(2) NULL,
		dest_nmstct varchar(25) NULL,
		dest_state varchar(2) NULL,
		billdate datetime NULL,
		cmp_mailto_name varchar(30)  NULL,
		bill_quantity decimal(12,3)  NULL,
		ivd_refnumber varchar(30) NULL,
		ivd_weight decimal(12,3) NULL,
		ivd_weightunit char(6) NULL,
		ivd_count decimal(12,3) NULL,
		ivd_countunit char(6) NULL,
		ivd_volume decimal(12,3) NULL,
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
		ref_number varchar(30) NULL,
		cmp_id varchar(8) NULL,
		cmp_name varchar(30) NULL,
		ivh_remark varchar(254) NULL,
		ref_count int null,
		cmp_altid varchar(25))

CREATE TABLE #cmd_name(
             cmd_name 		varchar(60) null,
	     ord_hdrnumber      int null)

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
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
		WHEN cmp1.cmp_mailto_name IS NULL  THEN
                   case when CHARINDEX('/',isnull(cmp1.cty_nmstct,''))>0 then  
		        ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		   else
			ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))),'')
		   end
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN
   		   case when CHARINDEX('/',isnull(cmp1.cty_nmstct,''))>0 then 
		        ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		   else
			ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))),'')
		   end
		ELSE 
		   case when CHARINDEX('/',isnull(cmp1.mailto_cty_nmstct,'')) > 0 then
			ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
		   else
			ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct))),'')
		   end
	    END,
	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
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
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		ref.ref_number,
		ivd.cmp_id cmp_id,
		cmp2.cmp_name,
		invoiceheader.ivh_remark,
		0,
		isnull(cmp1.cmp_altid,'')
      --pts40029 outer join conversion          
      FROM 	invoiceheader left outer join referencenumber ref 
				on (invoiceheader.ord_hdrnumber = ref.ref_tablekey and ref.ref_table = 'orderheader' and ref.ref_type = 'BL#' and
					ref.ref_sequence = (select min(ref_sequence) from referencenumber r1
                                        where r1.ref_table = 'orderheader' and r1.ref_type = 'BL#'and
                                              r1.ref_tablekey = invoiceheader.ord_hdrnumber) ), 
		company cmp1,
		company cmp2, 
		city cty1, 
		city cty2, 
		invoicedetail ivd left outer join stops stp on ivd.stp_number = stp.stp_number left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code, 
		chargetype cht
   WHERE	( invoiceheader.ivh_mbnumber = @mbnumber )
		AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
		AND (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND (cty2.cty_code = invoiceheader.ivh_destcity)
		AND (ivd.cht_itemcode = cht.cht_itemcode)
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND ivd.cmp_id = cmp2.cmp_id 
  order by      invoiceheader.ord_hdrnumber, ivd_sequence

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     INSERT INTO 	#masterbill_temp
     SELECT IsNull(invoiceheader.ord_hdrnumber,-1),
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
		WHEN cmp1.cmp_mailto_name IS NULL  THEN
                   case when CHARINDEX('/',isnull(cmp1.cty_nmstct,''))>0 then  
		        ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		   else
			ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))),'')
		   end
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN
   		   case when CHARINDEX('/',isnull(cmp1.cty_nmstct,''))>0 then 
		        ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		   else
			ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))),'')
		   end
		ELSE 
		   case when CHARINDEX('/',isnull(cmp1.mailto_cty_nmstct,'')) > 0 then
			ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
		   else
			ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct))),'')
		   end
	    END,
            ivh_billto_zip = 
	      CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	      END,
	    invoiceheader.ivh_ref_number,
	    invoiceheader.ivh_tractor,
	    invoiceheader.ivh_trailer,
            cty1.cty_nmstct   origin_nmstct,
            cty1.cty_state    origin_state,
            cty2.cty_nmstct   dest_nmstct,
            cty2.cty_state	dest_state,
            @billdate      billdate,
            ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
            ivd.ivd_quantity 'bill_quantity',
	    ivd.ivd_refnum,
            ivd.ivd_wgt,
            ivd.ivd_wgtunit,
            ivd.ivd_count,
            ivd.ivd_countunit,
            ivd.ivd_volume,
            ivd.ivd_volunit,
            ivd.ivd_unit,
            ivd.ivd_rate,
            ivd.ivd_rateunit,
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
            @copy,
	    ref.ref_number,
            ivd.cmp_id cmp_id,
	    cmp2.cmp_name,
	    invoiceheader.ivh_remark,
	    0,
	    isnull(cmp1.cmp_altid,'')
	   --pts40029 outer join conversion
       FROM invoiceheader left outer join referencenumber ref 
				on (invoiceheader.ord_hdrnumber = ref.ref_tablekey and ref.ref_table = 'orderheader' and ref.ref_type = 'BL#' and
						ref.ref_sequence = (select min(ref_sequence) from referencenumber r1
                                where r1.ref_table = 'orderheader' and r1.ref_type = 'BL#'and
                                      r1.ref_tablekey = invoiceheader.ord_hdrnumber) ), 
            company cmp1,
	        company cmp2,
            city cty1, 
            city cty2,
            invoicedetail ivd left outer join stops stp on ivd.stp_number = stp.stp_number left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code, 
            chargetype cht,
	        #batch
      WHERE invoiceheader.ivh_billto = @billto and
            --invoiceheader.ivh_originpoint = @originpoint and 
            invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber and
            invoiceheader.ivh_shipdate between @shipstart AND @shipend and 
            invoiceheader.ivh_mbstatus = 'RTP' and 
            @revtype1 in (invoiceheader.ivh_revtype1,'UNK') and 
            cmp1.cmp_id = invoiceheader.ivh_billto and
            cty1.cty_code = invoiceheader.ivh_origincity and 
            cty2.cty_code = invoiceheader.ivh_destcity and
            ivd.cht_itemcode = cht.cht_itemcode and
            @shipper in (invoiceheader.ivh_shipper,'UNKNOWN') and
            @consignee IN (invoiceheader.ivh_consignee,'UNKNOWN') and
            @ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master') and
	        ivd.cmp_id = cmp2.cmp_id and
	        isnull(ivh_batch_id,0) = case when @batch_count > 0 then #batch.batch_id else isnull(ivh_batch_id,0) end
	order by invoiceheader.ord_hdrnumber, ivd_sequence

  END

  INSERT INTO 	#cmd_name
  SELECT   max(cmd_name),ord_hdrnumber
  FROM     #masterbill_temp
  WHERE    cmd_name <> 'UNKNOWN'
  GROUP BY ord_hdrnumber

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.cmd_name = #cmd_name.cmd_name
  FROM          #cmd_name
  WHERE         #masterbill_temp.ord_hdrnumber = #cmd_name.ord_hdrnumber 

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.cmd_name = ''
  WHERE         #masterbill_temp.cmd_name = 'UNKNOWN' 

 
  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.stp_cty_nmstct = city.cty_nmstct
  FROM		#masterbill_temp, city 
  WHERE		#masterbill_temp.stp_city = city.cty_code 

  /*update        #masterbill_temp
  set           ref_count = (SELECT count(distinct labelfile.name)     
  FROM          referencenumber ,
                labelfile     
  WHERE      ( referencenumber.ref_type = labelfile.abbr ) and          
			  ( ( referencenumber.ref_table = 'orderheader' ) and          
			  ( referencenumber.ref_tablekey = #masterbill_temp.ord_hdrnumber ) and          
			  ( labelfile.labeldefinition = 'ReferenceNumbers' ) AND
			  ( referencenumber.ref_type in ('BL#','INB','SHI','HEE','COB','OUT','WHR','CBL') )))*/
 

delete from  #masterbill_temp where cht_primary = 'Y' and (ivd_charge = 0 or ivd_charge is null)
  
SELECT * 
  FROM		#masterbill_temp
  --ORDER BY	ivh_shipdate,ord_hdrnumber,cht_primary,cht_description
  DROP TABLE 	#masterbill_temp
  DROP TABLE 	#cmd_name
  
GO
GRANT EXECUTE ON  [dbo].[d_masterbill17b_sp] TO [public]
GO
