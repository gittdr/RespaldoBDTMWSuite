SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Procedure [dbo].[d_hierarchyreport_sp] 
AS


/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	------------------------------------------------------------------------------------

   01/24/14		vjh				71977	show items from a deduction hierarchical view

*/
select 'PayType  ' as tablename, t.pyt_itemcode as abbr, t.pyt_description as descr, isnull(t.pyt_AdjustWithNegativePay,'') as adj, isnull(t.pyt_sth_abbr,'') as hierarchy, isnull(h.sth_priority,999) as priority, isnull(t.pyt_sth_priority,0) as sequence
into #tempreport
from paytype t
left join stdhierarchy h on t.pyt_sth_abbr = h.sth_abbr

insert #tempreport
select 'Deduction' as tablename, t.sdm_itemcode as abbr, t.sdm_description as descr, isnull(t.sdm_adjustwithnegativepay,'') as adj, isnull(t.sth_abbr,'') as hierarchy, isnull(h.sth_priority,999) as priority, isnull(t.sdm_sth_priority,0) as sequence
from stdmaster t
left join stdhierarchy h on t.sth_abbr = h.sth_abbr




select * from #tempreport
where (adj <> '' and adj <> 'UNKNOWN') or (priority <> 999) or (sequence <> 0)
order by priority, sequence, descr

drop table #tempreport

GO
GRANT EXECUTE ON  [dbo].[d_hierarchyreport_sp] TO [public]
GO
