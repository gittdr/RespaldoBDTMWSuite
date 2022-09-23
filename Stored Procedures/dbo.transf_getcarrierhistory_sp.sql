SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_getcarrierhistory_sp] 
			(	
				@car varchar(8), @from_date datetime, @to_date datetime, @ord_reftype varchar(6)
				, @brn_id varchar (12)
				, @transf_user_id int
			)
AS

set nocount on
--set up fromdate and enddate
set @from_date = convert(datetime, convert(varchar(12),@from_date, 101) + ' 00:00:00')
SET @to_date = CONVERT(DATETIME, CONVERT(VARCHAR(12), @to_date, 101) + ' 23:59:59')

if @brn_id is null or ltrim(rtrim(@brn_id))=''
	set @brn_id='UNK'	--assuming no branch id is ALL
	
select 	ord_miscdate1 as Start_Date,
		/*
		(select 	min(evt_startdate)
				    from	event ,stops 
				   where 	stops.stp_number = event.stp_number
                   			and	stops.ord_hdrnumber = o.ord_hdrnumber) as 'Start_Date',
		*/
		isnull (ord_route, '') as 'Route',
		ord_hdrnumber as 'Order',
		(select 	isNull(min(ref_number),'')
		  from	referencenumber
		 where	ref_table = 'orderheader'
				and ref_tablekey = o.ord_hdrnumber
				and ref_type = @ord_reftype) as 'Reference_No',
		(select isNull(sum(isNull(pyd_amount,0)),0)
							   from	paydetail
							  where	paydetail.ord_hdrnumber = o.ord_hdrnumber
									and asgn_type = 'CAR'
									and asgn_id = @car) as 'Rate',
		isnull (ord_startdate,'') as 'Date',
		'' as 'Crossing_Date',
		isnull (ord_trailer, '') 'Trailer',
		(select isnull(name,'') from labelfile where ord_status = abbr and labeldefinition = 'DispStatus') as Conf,
		(case when ( select count(*) 
							   from	paydetail
							  where	paydetail.ord_hdrnumber = o.ord_hdrnumber
									and pyd_status = 'REL') > 0 then 'Y' else 'N' END) as PaidYN,
		b.brn_name as Branch,
		b.brn_id
from 	orderheader o
	join branch b on o.ord_booked_revtype1 = b.brn_id
where 	mov_number in (select mov_number from assetassignment where asgn_type='CAR' and asgn_id = @car)
		and ord_completiondate between @from_date and @to_date
		and ord_status IN( 'CMP', 'STD')
		and 
		(
			@brn_id='UNK' 
			or (
					@brn_id='*' and ord_booked_revtype1 in (select brn_id from transf_UserBranches where transf_user_id=@transf_user_id)
				)
			or ord_booked_revtype1 = @brn_id
		)
order by start_date ASC, route ASC, [order] ASC
GO
GRANT EXECUTE ON  [dbo].[transf_getcarrierhistory_sp] TO [public]
GO
