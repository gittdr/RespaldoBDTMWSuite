SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create PROC [dbo].[d_template_matching_accessorials] @mov_number  int 
		
AS 
/**  Proc Created for PTS 46628
 * 
 *
 **/

select lrq_equip_type,  lrq_type 
into   #temp_lrpt_xref
from loadreq_to_paytypes_xref
where mov_number = @mov_number 
and lrp_checked = 1

select tar_applyto_asset, tariffheaderstl.tar_number, tariffkey.trk_number, 
tariffheaderstl.cht_itemcode, tar_rate, cht_rateunit, tar_description, '' as 'dup'
into #temp_output
from tariffheaderstl,  tariffkey , #temp_lrpt_xref
where tariffheaderstl.tar_number = tariffkey.tar_number
and tariffheaderstl.cht_itemcode = #temp_lrpt_xref.lrq_type 
and ( tar_applyto_asset = #temp_lrpt_xref.lrq_equip_type OR tar_applyto_asset = 'UNK'  ) 
and tariffheaderstl.tar_number in (select tar_number from tariffkey where trk_primary = 'N')

select tar_applyto_asset, cht_itemcode
into #temp_duplicates
from #temp_output
group by tar_applyto_asset, cht_itemcode
having count(*) > 1

update #temp_output
set dup = 'D' 
from #temp_duplicates t1, #temp_output t2
where t1.tar_applyto_asset = t2.tar_applyto_asset 
AND   t1.cht_itemcode = t2.cht_itemcode

select * from #temp_output

GO
GRANT EXECUTE ON  [dbo].[d_template_matching_accessorials] TO [public]
GO
