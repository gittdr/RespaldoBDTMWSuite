SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_getRouteSpecList] 
	(
		@brn_id varchar(12)
		,@ord_route varchar(15)
		,@disp_date datetime
	)
as
set nocount on
	--get the master routes which are active
	--get the routes without a master on the @disp_date and is not CMP

declare @from_date datetime
	, @to_date datetime
	, @dt datetime

	IF @brn_id IS NULL or LTRIM(RTRIM(@brn_id)) = ''
		SELECT @brn_id = 'UNK'

	IF @ord_route IS NULL or LTRIM(RTRIM(@ord_route)) = ''
		SELECT @ord_route = 'UNK'
	else
		SELECT @ord_route = @ord_route + '%'

	set @from_date = convert(datetime, convert(varchar(12),@disp_date, 101) + ' 00:00:00')
	SET @to_date = CONVERT(DATETIME, CONVERT(VARCHAR(12), @disp_date, 101) + ' 23:59:59')
	set @dt=getdate()

	select 	isnull(ord_route, '') as RouteNo
		, isnull(ord_remark, '') as Description
		, isnull(convert(varchar(12),ord_route_effc_date, 101), '') as EffectiveDate
		, isnull(convert(varchar(12),ord_route_exp_date, 101), '') as ExpiryDate
		, (case ord_status when 'MST' then 'Yes' else 'No' end) as Master
		, (case ord_status when 'MST' then '' else convert(varchar(12),@disp_date, 101) end) as DispatchDate
		, isnull(ord_booked_revtype1, '') as Branch
		, ord_hdrnumber
		, ord_number
		, mov_number
	from orderheader oh
	where 	(ord_route like @ord_route or @ord_route='UNK')
		and @dt between ord_route_effc_date and ord_route_exp_date
		and (ord_booked_revtype1 = @brn_id or @brn_id='UNK')
		and
		(
			ord_status='MST'
			or 
			(
				(
					(
						ord_fromorder is null 
						or ord_fromorder not in 
							(select ord_number from orderheader where ord_status='MST')
					)
					and -- the schearliest of first stop of the match the dispatch date
					(
						(select min(stp_schdtearliest) from stops where  mov_number = oh.mov_number and stp_mfh_sequence=1) between @from_date and @to_date
					)
				) 
				--and ord_status not in ('CAN','ICO')
			)
		)
	order by ord_route, Master desc, DispatchDate

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_getRouteSpecList] TO [public]
GO
