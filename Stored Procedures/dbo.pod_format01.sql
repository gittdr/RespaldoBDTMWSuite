SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[pod_format01](@ord_hdrnumber int) 
as  

  
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
		det_description varchar(255) null)

select @lgh = min(lgh_number) from stops where ord_hdrnumber = @ord_hdrnumber
select @ls_rateby = ord_rateby from orderheader where ord_hdrnumber = @ord_hdrnumber
IF @ls_rateby = 'T' -- For rate by total create a line for linehaul from orderheader and details from invoicedetails
BEGIN
/*JLB PTS 39106 only pull from the orderheader if there are no details in the invoicedetail
	Insert into #temp( cht_itemcode ,ref_type ,ref_num ,fgt_vol ,fgt_volunits ,quantity ,rate ,charge,unit,rateunit,stp_number,fgt_description  )
	(select cht_itemcode, ord_reftype,ord_refnum, ord_totalvolume ,ord_totalvolumeunits, ord_quantity,ord_rate,ord_charge,ord_unit,ord_rateunit,
	 0,ord_description
	 from orderheader where ord_hdrnumber = @ord_hdrnumber )
*/
	if (select count(*) from invoicedetail where ord_hdrnumber = @ord_hdrnumber and ivd_type = 'SUB') < 1
	begin
		Insert into #temp( cht_itemcode ,ref_type ,ref_num ,fgt_vol ,fgt_volunits ,quantity ,rate ,charge,unit,rateunit,stp_number,fgt_description  )
		(select cht_itemcode, ord_reftype,ord_refnum, ord_totalvolume ,ord_totalvolumeunits, ord_quantity,ord_rate,ord_charge,ord_unit,ord_rateunit,
		 0,ord_description
		 from orderheader where ord_hdrnumber = @ord_hdrnumber )
	end
	/* end of 39106*/

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
from company where ord_shipper = company.cmp_id 

Update #temp set consignee_name = company.cmp_name ,
consignee_addr = cmp_address1,
consignee_addr2 = IsNull(cmp_address2,''),
-- PTS 32435 -- BL (start)
--consignee_nmstct = substring(cty_nmstct,1,charindex('/',cty_nmstct) - 1) + '  '+cmp_zip
consignee_nmstct = case cty_nmstct when 'UNKNOWN' then 'UNKNOWN' else substring(cty_nmstct,1,charindex('/',cty_nmstct) - 1) + '  '+cmp_zip end
-- PTS 32435 -- BL (end)
from company where ord_consignee = company.cmp_id 

/* FINAL SELECT - FORMS RETURN SET */  
select *  
from #temp

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value  
GO
GRANT EXECUTE ON  [dbo].[pod_format01] TO [public]
GO
