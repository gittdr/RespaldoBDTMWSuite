SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[BoardConfigurationDetailLoadRequirements] @lgh_number int
as
select 
(case when def_id_type = 'PUP' then 'At Pickup '
	  when def_id_type = 'DRP' then 'At Drop '
	  when def_id_type = 'BOTH' then 'At Pickup & Drop '
		else 'At '+ isnull(def_id_type,'Null') + ' ' end) + 
	(select isnull(labelfile.name, 'UNK') + ' '
		from labelfile
		where labelfile.labeldefinition = 'AssType'	and labelfile.abbr = loadrequirement.lrq_equip_type) +
	(case when lrq_manditory = 'N' then 'should '
		  when lrq_manditory = 'Y' then 'must '
			else isnull(lrq_manditory,'Null') + ' ' end) +
	(case when lrq_not = 'Y' then 'have/be '
		when lrq_not = 'N' then 'not have/be '
			else isnull(lrq_not,'Null') + ' ' end) + 
	(select max(isnull(labelfile.name, '') + ' ')
		from labelfile
		where labelfile.labeldefinition in ('TrlAcc', 'TrcAcc', 'DrvAcc') and labelfile.abbr = loadrequirement.lrq_type) + '- Qty ' +
 convert(char(3), lrq_quantity) as [Description],
lrq_equip_type, lrq_not, lrq_type, lrq_manditory, lrq_expire_date, loadrequirement.cmp_id, loadrequirement.cmd_code, legheader.lgh_number 
from legheader join loadrequirement on legheader.mov_number = loadrequirement.mov_number
where legheader.lgh_number = @lgh_number
GO
GRANT EXECUTE ON  [dbo].[BoardConfigurationDetailLoadRequirements] TO [public]
GO
