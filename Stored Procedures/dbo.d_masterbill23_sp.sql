SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill23_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	@revtype1 varchar(6), @mbstatus varchar(6),
	@shipstart datetime,@shipend datetime,@billdate datetime,@copy int,
--	LOR	PTS# 18983
--	@batch varchar(254), @batch_count int)
	@batch varchar(10), @batch_count int)
--	LOR
AS
/**
 * DESCRIPTION:
 *  Created to allow reprinting of masterbills
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
 * 10/26/2007.01 ? PTS40029 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @int0  int
DECLARE @periodend datetime
SELECT @int0 = 0

select @periodend = @shipend
SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'

--	LOR	PTS# 18983	commented out
/*
DECLARE	@batch_id_1 	varchar(10),
	@i_batch	int,
	@batch_string	varchar(254),
	@count          int

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
*/	
--	LOR

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
        ivd_refnum varchar(30) NULL,
	unit       varchar(20) null,
	cht_name   varchar(20) null,
	shipper_state varchar(6) null,
	shipper_displayname varchar(100) null,
	charge_display varchar(60) null,
	period_ending  datetime null,
	rate           money null,
	cht_itemcode  varchar(6))

  

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
		WHEN cmp3.cmp_mailto_name IS NULL  THEN
                   case when CHARINDEX('/',isnull(cmp3.cty_nmstct,''))>0 then  
		        ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		   else
			ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))),'')
		   end
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN
   		   case when CHARINDEX('/',isnull(cmp3.cty_nmstct,''))>0 then 
		        ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		   else
			ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))),'')
		   end
		ELSE 
		   case when CHARINDEX('/',isnull(cmp3.mailto_cty_nmstct,'')) > 0 then
			ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct)) - 1),'')
		   else
			ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct))),'')
		   end
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
	isnull(cmp1.cmp_altid,''),
	@copy,
	cht.cht_primary,
	cht.cht_description,
	ivd.ivd_sequence, 
        isnull(ivd.ivd_refnum,''),
	null,
       	lab.name,
	cty1.cty_state,
        case charindex('-',cmp3.cmp_name) when 0 then  cmp3.cmp_name else right(cmp3.cmp_name, Len(cmp3.cmp_name) - charindex('-',cmp3.cmp_name))  end,
        case charindex('-',cht.cht_description) when 0 then cht.cht_description else right(cht.cht_description,len(cht.cht_description) - charindex('-',cht.cht_description) )end,
	isnull(ivh_mbperiod,@periodend),
	0,
	case ivd.cht_itemcode when 'Tec31' then 'Tec30' else ivd.cht_itemcode end

    FROM invoiceheader  LEFT OUTER JOIN  orderheader oh  ON  invoiceheader.ord_hdrnumber  = oh.ord_hdrnumber   
		LEFT OUTER JOIN  company cmp1  ON  cmp1.cmp_id  = invoiceheader.ivh_billto   
		LEFT OUTER JOIN  company cmp3  ON  cmp3.cmp_id  = invoiceheader.ivh_shipper ,
	 invoicedetail ivd  LEFT OUTER JOIN  stops  ON  ivd.stp_number  = stops.stp_number   
		LEFT OUTER JOIN  commodity cmd  ON  ivd.cmd_code  = cmd.cmd_code ,
	 city cty1,
	 city cty2,
	 chargetype cht,
	 labelfile lab 
   WHERE ( invoiceheader.ivh_mbnumber = @mbnumber ) 
	AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
	AND (ivd.cht_itemcode = cht.cht_itemcode)
	AND (cty1.cty_code = invoiceheader.ivh_origincity) 
	AND (cty2.cty_code = invoiceheader.ivh_destcity)
	--AND (ivd.ivd_volume > 0 OR ivd_quantity > 0)
	AND (cht.cht_basisunit = lab.abbr) 
	AND (lab.labeldefinition = 'chrgunitbasis')

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
		WHEN cmp3.cmp_mailto_name IS NULL  THEN
                   case when CHARINDEX('/',isnull(cmp3.cty_nmstct,''))>0 then  
		        ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		   else
			ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))),'')
		   end
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN
   		   case when CHARINDEX('/',isnull(cmp3.cty_nmstct,''))>0 then 
		        ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		   else
			ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))),'')
		   end
		ELSE 
		   case when CHARINDEX('/',isnull(cmp3.mailto_cty_nmstct,'')) > 0 then
			ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct)) - 1),'')
		   else
			ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct))),'')
		   end
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
	billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	cty2.cty_nmstct   dest_nmstct,
	cty2.cty_state		dest_state,
	@billdate      billdate,
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
	case charindex('Tec31',cht.cht_description) when 0 then cht.cht_description else 'Tec30' + right(cht.cht_description,len(cht.cht_description) - charindex('-',cht.cht_description) + 1) end,
	ivd.ivd_sequence, 
        isnull(ivd.ivd_refnum,''),
	null,
       	lab.name,
	cty1.cty_state,
        ltrim(case charindex('-',cmp3.cmp_name) when 0 then  cmp3.cmp_name else right(cmp3.cmp_name, Len(cmp3.cmp_name) - charindex('-',cmp3.cmp_name))  end),
        ltrim(case charindex('-',cht.cht_description) when 0 then cht.cht_description else right(cht.cht_description,len(cht.cht_description) - charindex('-',cht.cht_description) )end),
	@periodend,
	0,
	case ivd.cht_itemcode when 'Tec31' then 'Tec30' else ivd.cht_itemcode end

    FROM invoiceheader  LEFT OUTER JOIN  orderheader oh  ON  invoiceheader.ord_hdrnumber  = oh.ord_hdrnumber   
		LEFT OUTER JOIN  company cmp1  ON  cmp1.cmp_id  = invoiceheader.ivh_billto ,
	 invoicedetail ivd  LEFT OUTER JOIN  stops  ON  ivd.stp_number  = stops.stp_number   
		LEFT OUTER JOIN  commodity cmd  ON  ivd.cmd_code  = cmd.cmd_code ,
	 city cty1,
	 city cty2,
	 company cmp3,
	 chargetype cht,
	 labelfile lab 
--	LOR	PS# 18983	,#batch
   WHERE ( invoiceheader.ivh_billto = @billto )  
     AND    (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
     AND	(ivd.cht_itemcode = cht.cht_itemcode)
     AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
     AND    (invoiceheader.ivh_mbstatus = 'RTP') 
     AND    (@revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
     AND    (cmp3.cmp_id = invoiceheader.ivh_shipper)
     AND    (cty1.cty_code = invoiceheader.ivh_origincity) 
     AND    (cty2.cty_code = invoiceheader.ivh_destcity)
     --AND    (ivd.ivd_volume > 0 OR ivd_quantity > 0)
     AND    (cht.cht_basisunit = lab.abbr) 
     AND    (lab.labeldefinition = 'chrgunitbasis')
--	LOR	PTS# 18983
	And   isnull(ivh_batch_id,0) = @batch
--   And   isnull(ivh_batch_id,0) = case when @batch_count > 0 then #batch.batch_id else isnull(ivh_batch_id,0) end
--	LOR 
END

/*UPDATE #masterbill_temp set shipticket = (SELECT 	IsNull(MIN(ref_number), '')
						FROM 	referencenumber ref
						WHERE 	ref.ref_table = 'orderheader' AND
							ref.ref_tablekey = #masterbill_temp.ord_hdrnumber AND
							ref.ref_type = 'SHIPTK')*/
UPDATE	 	#masterbill_temp 
SET		#masterbill_temp.stp_nmstct = city.cty_nmstct
FROM		#masterbill_temp, city 
WHERE		#masterbill_temp.stp_city = city.cty_code

						
UPDATE	 	#masterbill_temp 
SET		#masterbill_temp.unit = case when ivd_wgt <> 0 and ivd_wgtunit <> '' then ivd_wgtunit
					     when ivd_volume  <> 0 and ivd_volunit <> '' then ivd_volunit
                                             when ivd_count <> 0 and ivd_countunit <> '' then ivd_countunit
					     else ivd_unit end

UPDATE	 	#masterbill_temp 
SET		#masterbill_temp.unit = 'MIL'                                            
Where           charge_display = 'MILEAGE CHARGE'

--solve the sorting problem, when charge item have the same display but differece cht_itemcode, then set to the same itemcode
select  min(cht_itemcode) cht_itemcode,
	charge_display
into    #chtitem
from    #masterbill_temp
group by charge_display

update #masterbill_temp
set    charge_display = #chtitem.charge_display
from   #chtitem
where  #masterbill_temp.charge_display = #chtitem.charge_display

select sum(ivd_charge) ivd_charge,ivh_originpoint,cht_itemcode,unit,ivd_rate
into   #tempcharge
from   #masterbill_temp
group by ivh_originpoint,cht_itemcode,unit,ivd_rate

update #masterbill_temp
set    ivd_charge = 0
from   #tempcharge
where  #masterbill_temp.ivh_originpoint = #tempcharge.ivh_originpoint and
	#masterbill_temp.cht_itemcode = #tempcharge.cht_itemcode and
	#masterbill_temp.unit = #tempcharge.unit and 
	#masterbill_temp.ivd_rate = #tempcharge.ivd_rate and
	#tempcharge.ivd_charge = 0

/*UPDATE	 	#masterbill_temp 
SET		#masterbill_temp.unit = case when (select count( distinct unit) 
						   from  #masterbill_temp A 
						   where A.charge_display = #masterbill_temp.charge_display 
				   		     and a.ivh_originpoint = #masterbill_temp.ivh_originpoint ) > 1    then
					      cht_name
					      else
					      unit	
					 end   	 
UPDATE	 	#masterbill_temp 
SET		#masterbill_temp.rate = case when (select count( distinct ivd_rate) 
						   from  #masterbill_temp A 
						   where A.charge_display = #masterbill_temp.charge_display 
				   		     and a.ivh_originpoint = #masterbill_temp.ivh_originpoint ) > 1  then
					     -9999
					      else
					      ivd_rate
					 end   */     
SELECT * from #masterbill_temp where ivd_charge <> 0
ORDER by shipper_name, cht_itemcode,unit,ivd_rate
DROP TABLE #masterbill_temp

GO
GRANT EXECUTE ON  [dbo].[d_masterbill23_sp] TO [public]
GO
