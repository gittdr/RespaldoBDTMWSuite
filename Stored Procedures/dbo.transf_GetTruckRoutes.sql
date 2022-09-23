SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_GetTruckRoutes]
	(
		@trc_number varchar(8)
		,@disp_date datetime
	)
AS

set nocount on
	declare @from_date datetime
		, @to_date datetime

	set @from_date = convert(datetime, convert(varchar(12),@disp_date, 101) + ' 00:00:00')
	SET @to_date = CONVERT(DATETIME, CONVERT(VARCHAR(12), @disp_date, 101) + ' 23:59:59')

	select oh.ord_route
		, oh.ord_number
		, oh.ord_status
		, (select name from labelfile where oh.ord_status = abbr and labeldefinition = 'DispStatus') as OrdStatus
		, oh.ord_hdrnumber
		, oh.mov_number
		/*
		, (select min(stp_schdtearliest) 
				from stops
			where  mov_number = oh.mov_number and stp_mfh_sequence=1 ) as DispatchDate
		*/
		, (oh.ord_miscdate1) as DispatchDate
		, (select stp_schdtlatest 
				from stops
			where  mov_number = oh.mov_number 
				and stp_mfh_sequence in (select max(stp_mfh_sequence) from stops where mov_number = oh.mov_number)
			) as RlsPlannedDate
		, (select stp_departuredate 
				from stops
			where  mov_number = oh.mov_number
				and stp_mfh_sequence in (select max(stp_mfh_sequence) from stops where mov_number = oh.mov_number)
			) as RlsActualDate
			, isnull(om.ord_hdrnumber, 0) as mstOrder
			, isnull(convert(varchar(12),om.ord_route_effc_date, 101), '') as mstEffectiveDate
			, isnull(convert(varchar(12),om.ord_route_exp_date, 101), '') as mstExpiryDate
			, isnull(om.ord_route, '') as mstRoute
			, isnull(om.ord_number, '') as mstOrdNum 
			, isnull(om.mov_number, 0) as mstMove
	from orderheader oh
		left outer join orderheader om on om.ord_number = oh.ord_fromorder
	where (
			(select min(stp_schdtearliest) 
				from stops
			where  mov_number = oh.mov_number and stp_mfh_sequence=1) between @from_date and @to_date
		)
		and exists (select * from event where oh.mov_number = evt_mov_number and evt_tractor=@trc_number)

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_GetTruckRoutes] TO [public]
GO
