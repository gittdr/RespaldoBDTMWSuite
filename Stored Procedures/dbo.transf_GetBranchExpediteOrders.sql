SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_GetBranchExpediteOrders] 
	(
		@brn_id varchar(12)
		, @ord_revtype3_list varchar(8000)
	)
AS

set nocount on
	select	ord_number
		, ord_shipper
		, ord_miscdate1
		, ord_consignee
		, ord_completiondate
		, ord_revtype3
		, '' as auth_id
		, ord_status
		, isnull(lgh_extrainfo2, '') as Delay
		, (isnull(left(lbl.name, 1), '')) as ord_priority
		, ord_remark
		, isnull (lgh_extrainfo3, '') as Color
		, (case when lgh_extrainfo4 is null or lgh_extrainfo4 = '1' then '' else '*' end) as Confirmed
		, isnull(reverse(convert(char(20), reverse(lgh_extrainfo5))), 0) as DelayMinutes
		, lgh_number
		, oh.ord_hdrnumber
	from orderheader oh
		join legheader_active la on oh.ord_hdrnumber = la.ord_hdrnumber
		join (select * from labelfile where labeldefinition = 'OrderPriority') as lbl on ord_priority = abbr
	where ord_booked_revtype1 = @brn_id
		-- and ord_status <> 'AVL'
		and ord_revtype3 in (select convert(varchar(20), value) from transf_parseListToTable (@ord_revtype3_list, ','))
	order by lgh_extrainfo4, DelayMinutes desc

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_GetBranchExpediteOrders] TO [public]
GO
