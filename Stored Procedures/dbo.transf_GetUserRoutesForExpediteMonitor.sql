SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_GetUserRoutesForExpediteMonitor] 
	(	
		@transf_user_id int
	)
AS

set nocount on
declare @UNK varchar(3)	, @UNKOWN varchar (10)

	-- set constants
	select @UNK = 'UNK', @UNKOWN = 'UNKNOWN'

declare
	@branch varchar(12)
	, @invoice_type varchar(20)
	, @dataFilter varchar(6)
	, @ord_revtype3_list varchar(8000)

	if not exists (select * from transf_RMFilter where transf_user_id = @transf_user_id and rmf_name='BRANCH' and rmf_rm_name='ERM')
		set @branch = @UNK

	if not exists (select * from transf_RMFilter where transf_user_id = @transf_user_id and rmf_name='INVOICE TYPE' and rmf_rm_name='ERM')
		set @invoice_type = @UNK

	if not exists (select * from transf_RMFilter where transf_user_id = @transf_user_id and rmf_rm_name='ERM')
		set @dataFilter = @UNK

	SELECT @ord_revtype3_list = isNull(gi_string1,'')
		FROM generalinfo
		WHERE gi_name = 'TF_Rev3ListForPrimaryDelayDate'

	select	ord_number
		, ord_shipper
		, ord_miscdate1
		, ord_consignee
		, ord_completiondate
		, ord_revtype3
		, (
			select isnull(max(ref_number), '') 
				from referencenumber 
				where ref_table = 'orderheader'
					and ord_hdrnumber=oh.ord_hdrnumber
					and ref_type='AUTH'
		   )
			as auth_id
		, ord_status
		, isnull(lgh_extrainfo2, '') as Delay
		, (isnull(left(lbl.name, 1), '')) as ord_priority
		, ord_remark
		, isnull (lgh_extrainfo3, '') as Color
		, (case when lgh_extrainfo4 is null or lgh_extrainfo4 = '1' then '' else '*' end) as Confirmed
		, isnull(reverse(convert(char(20), reverse(lgh_extrainfo5))), 0) as DelayMinutes
		, lgh_number
		, oh.ord_hdrnumber
		, ord_booked_revtype1
	from orderheader oh
		join legheader_active la on oh.ord_hdrnumber = la.ord_hdrnumber
		join (select * from labelfile where labeldefinition = 'OrderPriority') as lbl on ord_priority = abbr
		join transf_userbranches ub on ord_booked_revtype1 = ub.brn_id and ub.transf_user_id = @transf_user_id
	where 1=1
		-- and ord_status <> 'AVL'
		and ord_revtype3 in (select convert(varchar(20), value) from transf_parseListToTable (@ord_revtype3_list, ','))
		and
		(
			@dataFilter = @UNK
			or
			(
				(@branch=@UNK or ord_booked_revtype1 in (select rmf_value from transf_RMFilter where rmf_name = 'BRANCH' and transf_user_id=@transf_user_id and rmf_rm_name='ERM'))
				and (@invoice_type=@UNK or ord_revtype3 in (select rmf_value from transf_RMFilter where rmf_name = 'INVOICE TYPE' and transf_user_id=@transf_user_id and rmf_rm_name='ERM'))
			)
		)
	order by lgh_extrainfo4, DelayMinutes desc

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_GetUserRoutesForExpediteMonitor] TO [public]
GO
