SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[d_pod_format02_sp](@ord_hdrnumber int) 
as  
/**
 * 
 * NAME:
 * dbo.d_pod_format02_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data for d_pod_format02
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * 001 - sort_sequence int identity not null
 * 002 - ord_number varchar(20) null
 * 003 - ord_billto varchar(8) null         
 * 004 - billto_name varchar(100) null  
 * 005 - billto_addr varchar(100)  null  
 * 006 - billto_addr2 varchar(100) null           
 * 007 - billto_nmstct varchar(30) null  
 * 008 - ord_shipper  varchar(8) null     
 * 009 - shipper_name varchar(100) null 
 * 010 - shipper_addr varchar(100) null  
 * 011 - shipper_addr2 varchar(100) null  
 * 012 - shipper_nmstct varchar(30) null  
 * 013 - ord_consignee varchar(8) null     
 * 014 - consignee_name varchar(100) null 
 * 015 - consignee_addr varchar(100) null  
 * 016 - consignee_addr2 varchar(100) null  
 * 017 - consignee_nmstct varchar(30) null
 * 018 - ord_rateby char(1) null
 * 019 - cht_itemcode varchar(8) null 
 * 020 - ref_type varchar(6) null
 * 021 - ref_num varchar(30) null
 * 022 - fgt_vol money null
 * 024 - fgt_volunits varchar(6) null
 * 025 - quantity money null   
 * 026 - rate money null   
 * 027 - charge money null
 * 028 - pod_cmp_addr1 varchar(100) null   
 * 029 - pod_cmp_addr2 varchar(100) null   
 * 030 - pod_cmp_addr3 varchar(100) null   
 * 031 - pod_cmp_addr4 varchar(100) null
 * 032 - ord_bookdate datetime null
 * 033 - ord_startdate datetime null
 * 034 - ord_reftype varchar(6) null
 * 035 - ord_refnum varchar(30) null
 * 036 - tractor varchar(8) null
 * 037 - trailer varchar(13) null
 * 038 - driver varchar(8) null
 * 039 - ord_revtype1_t varchar(20) null
 * 040 - ord_revtype2_t varchar(20) null
 * 041 - ord_revtype3_t varchar(20) null
 * 042 - ord_revtype4_t varchar(20) null
 * 043 - ord_revtype1 varchar(20) null
 * 044 - ord_revtype2 varchar(20) null
 * 045 - ord_revtype3 varchar(20) null
 * 046 - ord_revtype4 varchar(20) null
 * 047 - unit varchar(6) null
 * 048 - rateunit varchar(6) null
 * 049 - unitdesc varchar(20) null
 * 050 - rateunitdesc varchar(20) null
 * 051 - stp_number int null
 * 052 - cmp_id varchar(8) null
 * 053 - cmp_name varchar(100) null
 * 054 - cmp_nmstct varchar(30) null
 * 055 - fgt_description varchar(60) null
 * 056 - cht_description varchar(30) null
 * 057 - det_description varchar(255) null
 * 058 - consignee_phone varchar(20) null
 * 059 - shipper_phone varchar(20) null
 *
 * PARAMETERS:
 * 001 - @temp_name varchar(30)   
 * 002 - @temp_addr varchar(30)   
 * 003 - @temp_addr2 varchar(30)  
 * 004 - @temp_nmstct varchar(30)  
 * 005 - @temp_altid varchar(25)  
 * 006 - @counter int  
 * 007 - @ret_value int  
 * 008 - @temp_terms varchar(20)  
 * 009 - @varchar50 varchar(50)  
 * 010 - @ls_rateby char(1)
 * 011 - @lgh int
 * REFERENCES:
 *
 * 
 * REVISION HISTORY:
 * 09/25/2006.01 EMK - Created POD Format 02 for user request.  Most code Copied from pod_format01.sql      
 * 09/26/2006.02 EMK - Added comments and changed "select asterisk" statement to comply with standards
 * 10/06/2006.03 EMK - Changed name to d_pod_format02_sp to comply with standards.
 */
  
declare @temp_name   varchar(30) ,  
 @temp_addr   varchar(30) ,  
 @temp_addr2  varchar(30),  
 @temp_nmstct varchar(30),  
 @temp_altid  varchar(25),  
 @counter    int,  
 @ret_value  int,  
 @temp_terms    varchar(20),  
 @varchar50 varchar(50)  ,
 @ls_rateby char(1),
 @lgh int
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET  */
Create table #temp(
		sort_sequence int identity not null,
		ord_number varchar(20) null,
		ord_billto varchar(8) null,
-- PTS 32435 -- BL (start)
--		billto_name varchar(30) null,  
--		billto_addr varchar(30)  null,  
--		billto_addr2 varchar(30) null,           
		billto_name varchar(100) null,  
		billto_addr varchar(100)  null,  
		billto_addr2 varchar(100) null,           
-- PTS 32435 -- BL (end)
		billto_nmstct varchar(30) null,  
		ord_shipper  varchar(8) null,     
-- PTS 32435 -- BL (start)
--		shipper_name varchar(30) null,  
--		shipper_addr varchar(30) null,  
--		shipper_addr2 varchar(30) null,  
		shipper_name varchar(100) null,  
		shipper_addr varchar(100) null,  
		shipper_addr2 varchar(100) null,  
-- PTS 32435 -- BL (end)
		shipper_nmstct varchar(30) null,  
		ord_consignee varchar(8) null,     
-- PTS 32435 -- BL (start)
--		consignee_name varchar(30) null,  
--		consignee_addr varchar(30) null,  
--		consignee_addr2 varchar(30) null,  
		consignee_name varchar(100) null,  
		consignee_addr varchar(100) null,  
		consignee_addr2 varchar(100) null,  
-- PTS 32435 -- BL (end)
		consignee_nmstct varchar(30) null,
		ord_rateby char(1) null,
		cht_itemcode varchar(8) null, 
		ref_type varchar(6) null,
		ref_num varchar(30) null,
		fgt_vol money null,
		fgt_volunits varchar(6) null,
		quantity money null,   
		rate money null,   
		charge money null,
-- PTS 32435 -- BL (start)
--		pod_cmp_addr1 varchar(60) null,   
--		pod_cmp_addr2 varchar(60) null,   
--		pod_cmp_addr3 varchar(60) null,   
--		pod_cmp_addr4 varchar(60) null,
		pod_cmp_addr1 varchar(100) null,   
		pod_cmp_addr2 varchar(100) null,   
		pod_cmp_addr3 varchar(100) null,   
		pod_cmp_addr4 varchar(100) null,
-- PTS 32435 -- BL (end)
		ord_bookdate datetime null,
		ord_startdate datetime null,
		ord_reftype varchar(6) null,
		ord_refnum varchar(30) null,
		tractor varchar(8) null,
		trailer varchar(13) null,
		driver varchar(8) null,
		ord_revtype1_t varchar(20) null,
		ord_revtype2_t varchar(20) null,
		ord_revtype3_t varchar(20) null,
		ord_revtype4_t varchar(20) null,
		ord_revtype1 varchar(20) null,
		ord_revtype2 varchar(20) null,
		ord_revtype3 varchar(20) null,
		ord_revtype4 varchar(20) null,
		unit varchar(6) null,
		rateunit varchar(6) null,
		unitdesc varchar(20) null,
		rateunitdesc varchar(20) null,
		stp_number int null,
		cmp_id varchar(8) null,
-- PTS 32435 -- BL (start)
--		cmp_name varchar(30) null,
		cmp_name varchar(100) null,
-- PTS 32435 -- BL (end)
		cmp_nmstct varchar(30) null,
		fgt_description varchar(60) null,
-- PTS 32435 -- BL (start)
--		cht_description varchar(20) null,
		cht_description varchar(30) null,
-- PTS 32435 -- BL (end)
		det_description varchar(255) null,
-- PTS 33233 -- EK (start)
		consignee_phone varchar(20) null,
		shipper_phone varchar(20) null)
-- PTS 33233 -- EK (end)
select @lgh = min(lgh_number) from stops where ord_hdrnumber = @ord_hdrnumber
select @ls_rateby = ord_rateby from orderheader where ord_hdrnumber = @ord_hdrnumber
IF @ls_rateby = 'T' -- For rate by total create a line for linehaul from orderheader and details from invoicedetails
BEGIN
	Insert into #temp( cht_itemcode ,ref_type ,ref_num ,fgt_vol ,fgt_volunits ,quantity ,rate ,charge,unit,rateunit,stp_number,fgt_description  )
	(select cht_itemcode, ord_reftype,ord_refnum, ord_totalvolume ,ord_totalvolumeunits, ord_quantity,ord_rate,ord_charge,ord_unit,ord_rateunit,
	 0,ord_description
	 from orderheader where ord_hdrnumber = @ord_hdrnumber )
	
	Insert into #temp( cht_itemcode ,ref_type ,ref_num ,fgt_vol ,fgt_volunits ,quantity ,rate ,charge,unit,rateunit,stp_number,fgt_description  )
	(select cht_itemcode, ivd_reftype,ivd_refnum, ivd_volume ,ivd_volunit, ivd_quantity,ivd_rate,ivd_charge,ivd_unit,ivd_rateunit,
	 stp_number,ivd_description
	 from invoicedetail where ord_hdrnumber = @ord_hdrnumber )
END

ELSE -- For rate by detail get all the information from freightdetails
BEGIN
	Insert into #temp( cht_itemcode ,ref_type ,ref_num ,fgt_vol ,fgt_volunits ,quantity ,rate ,charge, unit,rateunit,stp_number,fgt_description )
	(select cht_itemcode, fgt_reftype,fgt_refnum, fgt_volume ,fgt_volumeunit, fgt_quantity,fgt_rate,fgt_charge,fgt_unit,fgt_rateunit,
	 stp_number,fgt_description
	 from freightdetail where stp_number in (select stp_number from stops where ord_hdrnumber = @ord_hdrnumber and stp_type = 'DRP'))

	--19568 JD
	Insert into #temp( cht_itemcode ,ref_type ,ref_num ,fgt_vol ,fgt_volunits ,quantity ,rate ,charge,unit,rateunit,stp_number,fgt_description  )
	(select cht_itemcode, ivd_reftype,ivd_refnum, ivd_volume ,ivd_volunit, ivd_quantity,ivd_rate,ivd_charge,ivd_unit,ivd_rateunit,
	 stp_number,ivd_description
	 from invoicedetail where ord_hdrnumber = @ord_hdrnumber )


END
update #temp set cht_description = chargetype.cht_description from chargetype where #temp.cht_itemcode = chargetype.cht_itemcode

update #temp set #temp.cmp_id = stops.cmp_id,#temp.cmp_name = company.cmp_name
from stops,company where #temp.stp_number > 0 and #temp.stp_number = stops.stp_number and stops.cmp_id = company.cmp_id

update #temp set #temp.cmp_nmstct = substring(city.cty_nmstct,1,charindex('/',city.cty_nmstct) - 1) from company,city
where #temp.cmp_id = company.cmp_id and company.cmp_city = city.cty_code

update #temp set unitdesc = name  from labelfile where labeldefinition like '%Units%' and unit = abbr
update #temp set rateunitdesc = name  from labelfile where labeldefinition = 'RateBy' and rateunit = abbr

update #temp set driver = lgh_driver1 , tractor = lgh_tractor, trailer = lgh_primary_trailer
from legheader where lgh_number = @lgh

Update #temp set  pod_cmp_addr1 = gi_string1,pod_cmp_addr2 = gi_string2,
pod_cmp_addr3 = gi_string3,pod_cmp_addr4 = gi_string4 from generalinfo where gi_name = 'PODCompany'

update #temp set ord_number = orderheader.ord_number,
ord_bookdate = orderheader.ord_bookdate,
ord_startdate = orderheader.ord_bookdate ,
ord_reftype =orderheader.ord_reftype ,
ord_refnum = orderheader.ord_refnum
from orderheader where ord_hdrnumber = @ord_hdrnumber

update #temp set
ord_revtype1 = labelfile.name , ord_revtype1_t = labelfile.userlabelname
from labelfile, orderheader
where ord_hdrnumber = @ord_hdrnumber and
			labelfile.labeldefinition= 'RevType1' and
			orderheader.ord_revtype1 = labelfile.abbr


update #temp set ord_billto = orderheader.ord_billto,
								 ord_shipper = orderheader.ord_shipper,
								 ord_consignee = orderheader.ord_consignee,
								 ord_rateby = orderheader.ord_rateby
from orderheader where ord_hdrnumber = @ord_hdrnumber

Update #temp set billto_name = company.cmp_name ,
billto_addr = cmp_address1,
billto_addr2 = Isnull(cmp_address2,''),
-- PTS 32435 -- BL (start)
--billto_nmstct = substring(cty_nmstct,1,charindex('/',cty_nmstct) - 1) + '  '+cmp_zip
billto_nmstct = case cty_nmstct when 'UNKNOWN' then 'UNKNOWN' else substring(cty_nmstct,1,charindex('/',cty_nmstct) - 1) + '  '+cmp_zip end
-- PTS 32435 -- BL (end)
from company where ord_billto = company.cmp_id 

Update #temp set shipper_name = company.cmp_name ,
shipper_addr = cmp_address1,
shipper_addr2 = Isnull(cmp_address2,''),
-- PTS 32435 -- BL (start)
--shipper_nmstct = substring(cty_nmstct,1,charindex('/',cty_nmstct) - 1) + '  '+cmp_zip
shipper_nmstct = case cty_nmstct when 'UNKNOWN' then 'UNKNOWN' else substring(cty_nmstct,1,charindex('/',cty_nmstct) - 1) + '  '+cmp_zip end
-- PTS 32435 -- BL (end)
,shipper_phone = Isnull(cmp_primaryphone,'')
from company where ord_shipper = company.cmp_id 

Update #temp set consignee_name = company.cmp_name ,
consignee_addr = cmp_address1,
consignee_addr2 = IsNull(cmp_address2,''),

-- PTS 33233 -- EK (start)
consignee_phone = IsNull(cmp_primaryphone,''),
-- PTS 33233 -- EK (end)

-- PTS 32435 -- BL (start)
--consignee_nmstct = substring(cty_nmstct,1,charindex('/',cty_nmstct) - 1) + '  '+cmp_zip
consignee_nmstct = case cty_nmstct when 'UNKNOWN' then 'UNKNOWN' else substring(cty_nmstct,1,charindex('/',cty_nmstct) - 1) + '  '+cmp_zip end
-- PTS 32435 -- BL (end)



from company where ord_consignee = company.cmp_id 

/* FINAL SELECT - FORMS RETURN SET */  
select sort_sequence,
		ord_number,
		ord_billto,
		billto_name,  
		billto_addr,  
		billto_addr2,           
		billto_nmstct,  
		ord_shipper,    
		shipper_name, 
		shipper_addr,
		shipper_addr2, 
		shipper_nmstct, 
		ord_consignee,   
		consignee_name,  
		consignee_addr,
		consignee_addr2,
		consignee_nmstct,
		ord_rateby,
		cht_itemcode,
		ref_type,
		ref_num,
		fgt_vol,
		fgt_volunits,
		quantity,
		rate,   
		charge,
		pod_cmp_addr1,   
		pod_cmp_addr2,   
		pod_cmp_addr3,   
		pod_cmp_addr4,
		ord_bookdate,
		ord_startdate,
		ord_reftype,
		ord_refnum,
		tractor,
		trailer,
		driver,
		ord_revtype1_t,
		ord_revtype2_t,
		ord_revtype3_t,
		ord_revtype4_t,
		ord_revtype1,
		ord_revtype2,
		ord_revtype3,
		ord_revtype4,
		unit,
		rateunit,
		unitdesc,
		rateunitdesc,
		stp_number,
		cmp_id,
		cmp_name,
		cmp_nmstct,
		fgt_description,
		cht_description,
		det_description,
		consignee_phone,
		shipper_phone
from #temp

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value  
GO
GRANT EXECUTE ON  [dbo].[d_pod_format02_sp] TO [public]
GO
