SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


  
create procedure [dbo].[SSRS_RB_TRIPSHEET_03_LR]

--execute SSRS_RB_TRIPSHEET_03_LR @@lgh_number = 689
 @lgh_number integer  
as  

SELECT 
Case loadrequirement.lrq_equip_type
	When 'DRV' then 'Driver'
	When 'CAR' then 'Carrier'
	When 'TRC' then 'Tractor'
	When 'TRL' then 'Trailer'
	else Loadrequirement.lrq_equip_type
	END as 'lrq_equip_type', 
 loadrequirement.lrq_not,
loadrequirement.lrq_type, 
Case 	when loadrequirement.lrq_equip_type = 'CAR' then (select name from labelfile where loadrequirement.lrq_type = labelfile.abbr and labeldefinition = 'CarQual')
		when loadrequirement.lrq_equip_type = 'TRC' then (select name from labelfile where loadrequirement.lrq_type = labelfile.abbr and labeldefinition = 'TrcAcc')
		when loadrequirement.lrq_equip_type = 'TRL' then (select name from labelfile where loadrequirement.lrq_type = labelfile.abbr and labeldefinition = 'TrlAcc')
		when loadrequirement.lrq_equip_type = 'DRV' then (select name from labelfile where loadrequirement.lrq_type = labelfile.abbr and labeldefinition = 'DrvAcc')
	Else loadrequirement.lrq_equip_type
	End as 'lrq_equip_type',	
Case loadrequirement.lrq_manditory
	When 'Y' then 'Must have/be'
	else 'Should have/be'
	end as 'lrq_manditory',  
loadrequirement.ord_hdrnumber, 
loadrequirement.lrq_sequence, 
loadrequirement.lrq_quantity, 
orderheader.ord_number, 
loadrequirement.cmp_id, 
loadrequirement.def_id_type,
loadrequirement.stp_number,
loadrequirement.fgt_number,
loadrequirement.lgh_number,
loadrequirement.mov_number
FROM loadrequirement left outer join orderheader on loadrequirement.ord_hdrnumber = orderheader.ord_hdrnumber
WHERE ( loadrequirement.lgh_number = @lgh_number )



GO
