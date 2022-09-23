SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_getUserRoutesForConfigurableMonitor] 
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
	, @domicile varchar(6)
	, @function varchar(6)
	, @route_type varchar(6)
	, @dataFilter varchar(6)

	if not exists (select * from transf_RMFilter where transf_user_id = @transf_user_id and rmf_name='BRANCH' and rmf_rm_name='CRM')
		set @branch = @UNK

	if not exists (select * from transf_RMFilter where transf_user_id = @transf_user_id and rmf_name='DOMICILE' and rmf_rm_name='CRM')
		set @domicile = @UNK

	if not exists (select * from transf_RMFilter where transf_user_id = @transf_user_id and rmf_name='FUNCTION' and rmf_rm_name='CRM')
		set @function = @UNK

	if not exists (select * from transf_RMFilter where transf_user_id = @transf_user_id and rmf_name='ROUTE TYPE' and rmf_rm_name='CRM')
		set @route_type = @UNK

	if not exists (select * from transf_RMFilter where transf_user_id = @transf_user_id and rmf_rm_name='CRM')
		set @dataFilter = @UNK


	select 	distinct isnull(lgh_route, '') as lgh_route
		, ord_hdrnumber
		, lgh_booked_revtype1 as BranchID
		, lgh_class2
		, lgh_class3
		, (case 
			when ((lgh_driver1 is not null and lgh_driver1 <> @UNKOWN) and (lgh_carrier is not null and lgh_carrier <> @UNKOWN)) then lgh_driver1 + ' / ' + lgh_carrier
			when lgh_driver1 is not null and lgh_driver1 <> @UNKOWN then lgh_driver1
			when lgh_carrier is not null and lgh_carrier <> @UNKOWN then lgh_carrier
			else ''
			end
		) as Driver_Carrier
		, lgh_carrier
		, lgh_tractor
		, isnull((select trc_mctid from tractorprofile where trc_number = lgh_tractor), '') as trc_mctid
		, lgh_primary_trailer
		, lgh_startdate as Dispatched
		, lgh_extrainfo2 as Delay
		, (case when lgh_extrainfo4 is null or lgh_extrainfo4 = '1' then '' else '*' end) as Confirmed
		, (case when lgh_extrainfo5 is null then 0 else convert(int, ltrim(rtrim(lgh_extrainfo5))) end) as DelayMinutes
		, isnull (lgh_extrainfo3, '') as Color
		, lgh_number
		, isnull(lgh_etaalert1, '') as lgh_etaalert1
		, (
			case
				when lgh_etaalert1 is null or lgh_etaalert1='' then ''
				when lgh_etaalert1 = '0' then 'On Time'
				when lgh_etaalert1 in ('1', '2', '3') then 'Late'
				else ''
			end
		) as ETA_Status
		, lgh_type1 as RouteType
	from	legheader_active
		join transf_userbranches ub on lgh_booked_revtype1 = ub.brn_id and ub.transf_user_id = @transf_user_id
	where	lgh_extrainfo5 is not null
		and ltrim(rtrim(lgh_extrainfo5)) <> ''
		and convert (int, ltrim(rtrim(lgh_extrainfo5)))>15
		and lgh_outstatus in ('PLN', 'STD', 'AVL')
		and
		(
			@dataFilter = @UNK
			or
			(
				(@branch=@UNK or lgh_booked_revtype1 in (select rmf_value from transf_RMFilter where rmf_name = 'BRANCH' and transf_user_id=@transf_user_id and rmf_rm_name='CRM'))
				and (@domicile=@UNK or lgh_class2 in (select rmf_value from transf_RMFilter where rmf_name = 'DOMICILE' and transf_user_id=@transf_user_id and rmf_rm_name='CRM'))
				and (@function=@UNK or lgh_class3 in (select rmf_value from transf_RMFilter where rmf_name = 'FUNCTION' and transf_user_id=@transf_user_id and rmf_rm_name='CRM'))
				and (@route_type=@UNK or lgh_type1 in (select rmf_value from transf_RMFilter where rmf_name = 'ROUTE TYPE' and transf_user_id=@transf_user_id and rmf_rm_name='CRM'))
			)
		)
	order by Confirmed, DelayMinutes desc

GO
GRANT EXECUTE ON  [dbo].[transf_getUserRoutesForConfigurableMonitor] TO [public]
GO
