SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_late_legheader_wc_sp] @vf_hoursout	float, @vl_lgh_number	int
as
/*	based on d_late_legheader_sp with option to filter based on billto.
	exec  d_late_legheader_wc_sp @vf_hoursout = 999, @vl_lgh_number	= 0
declare @vf_hoursout float, @vl_lgh_number int 
select @vf_hoursout = 9999, @vl_lgh_number = 0
*/	

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @EnhancedCarrierETA		varchar(60), @billto_list varchar(60)
declare @EtaUseCurrTime4OldCKC	char(1)
declare @UseThisTimeForOldCKC	int
declare @billto_count			int


Select @EnhancedCarrierETA = upper(left(isnull(gi_string1,'N'),1)) From generalinfo Where gi_name = 'EnhancedCarrierETA'
Select @EtaUseCurrTime4OldCKC = upper(left(isnull(gi_string1,'N'),1)) From generalinfo Where gi_name = 'EtaUseCurrTime4OldCKC'
Select @UseThisTimeForOldCKC = isnull(gi_integer1,96) From generalinfo Where gi_name = 'EtaUseCurrTime4OldCKC'
select @UseThisTimeForOldCKC = -1 * abs(@UseThisTimeForOldCKC)
SELECT @billto_list = ltrim(rtrim(gi_string1)) from generalinfo where gi_name = 'ETAWCBillToList'

declare @billtos table (bill_to varchar(8))

declare @lgh table
		(mov_number				int			null
		,lgh_number				int			null
		,lgh_startdate			datetime	null
		,lgh_enddate  			datetime	null
		,lgh_startcity			int			null
		,lgh_endcity  			int			null
		,lgh_startregion1		varchar(6)	null
		,lgh_outstatus 			varchar(6)	null
		,lgh_tractor  			varchar(8)	null
		,lgh_driver1   			varchar(8)	null
		,mpp_teamleader			varchar(6)	null
		,lgh_etaalert1   		char(1)		null
		,lgh_etamins1   		int			null
		,ord_hdrnumber			int			null
		,lgh_startcty_nmstct	varchar(30)	null
		,lgh_endcty_nmstct  	varchar(30)	null
		,lgh_prjdate1  			datetime	null
		,lgh_carrier			varchar(8)	null
		,car_board				char(1)		null
		,lgh_etacalcdate		datetime	null
		,lgh_etacomment			text		null
		,ord_number				char(12)	null
		,ord_origincity			int			null
		,ord_destcity			int			null
		,ord_revtype1			varchar(6)	null
		,ord_refnum				varchar(30)	null
		,ord_destpoint			varchar(8)	null
		,lgh_eta_cmp_list		varchar(1000)	null
		,max_carrier_ckc_date	datetime	null
		,lgh_booked_revtype1	varchar(12)	null)
	
declare @trc table 
		(trc_number				varchar(8)	null)

declare @ckc table
		(ckc_number				int			null
		,ckc_tractor			char(8)		null
		,trc_gps_date			datetime	null
		,trc_gps_desc			varchar(50)	null
		,ckc_comment			varchar(254) null
		,ckc_commentlarge		varchar(254) null)

--use the value(s) from the GI setting
insert into @billtos (bill_to) select value from CSVStringsToTable_fn (@billto_list)

--PTS 87136 - DJM - Use new flag to build list of Bill To companies for ETA Agent
Insert into @billtos
select cmp_id 
from company
where cmp_active = 'Y'
	and isNull(cmp_etawcbillto, 'N') = 'Y'
	and not exists (select 1 from @billtos where bill_to = cmp_id)


-- if no billto filter, get all
select @billto_count = count(*) from @billtos
if @billto_count = 0
	insert	@lgh
			(mov_number
			,lgh_number
			,lgh_startdate
			,lgh_enddate
			,lgh_startcity
			,lgh_endcity
			,lgh_startregion1
			,lgh_outstatus
			,lgh_tractor
			,lgh_driver1
			,mpp_teamleader
			,lgh_etaalert1
			,lgh_etamins1
			,ord_hdrnumber
			,lgh_startcty_nmstct
			,lgh_endcty_nmstct
			,lgh_prjdate1
			,lgh_carrier
			,car_board
			,lgh_etacalcdate
			,lgh_etacomment
			,ord_number
			,ord_origincity
			,ord_destcity
			,ord_revtype1
			,ord_refnum
			,ord_destpoint
			,lgh_eta_cmp_list
			,lgh_booked_revtype1
			)
	  select l.mov_number
			,l.lgh_number
			,l.lgh_startdate
			,l.lgh_enddate  
			,l.lgh_startcity
			,l.lgh_endcity  
			,l.lgh_startregion1
			,l.lgh_outstatus 
			,l.lgh_tractor  
			,l.lgh_driver1   
			,l.mpp_teamleader
			,l.lgh_etaalert1   
			,l.lgh_etamins1   
			,l.ord_hdrnumber
			,l.lgh_startcty_nmstct
			,l.lgh_endcty_nmstct  
			,l.lgh_prjdate1  
			,l.lgh_carrier
			,isnull(c.car_board, 'T')
			,l.lgh_etacalcdate
			,l.lgh_etacomment
			,isnull(o.ord_number, 0)
			,isnull(o.ord_origincity, 0)
			,isnull(o.ord_destcity, 0)
			,isnull(o.ord_revtype1, '')
			,isnull(o.ord_refnum, '')
			,o.ord_destpoint
			,lgh_eta_cmp_list
			,l.lgh_booked_revtype1
	  from	legheader l LEFT OUTER JOIN orderheader o ON o.ord_hdrnumber = l.ord_hdrnumber
				LEFT OUTER JOIN carrier c ON c.car_id = l.lgh_carrier
	  where	l.lgh_active = 'Y'
		and	l.lgh_outstatus <> 'CMP'
		and	l.lgh_startdate < dateadd(hour, @vf_hoursout, getdate())
		and	l.ord_hdrnumber <> 0
		and	(@vl_lgh_number = 0
				or l.lgh_number = @vl_lgh_number)
else 
	insert	@lgh
			(mov_number
			,lgh_number
			,lgh_startdate
			,lgh_enddate
			,lgh_startcity
			,lgh_endcity
			,lgh_startregion1
			,lgh_outstatus
			,lgh_tractor
			,lgh_driver1
			,mpp_teamleader
			,lgh_etaalert1
			,lgh_etamins1
			,ord_hdrnumber
			,lgh_startcty_nmstct
			,lgh_endcty_nmstct
			,lgh_prjdate1
			,lgh_carrier
			,car_board
			,lgh_etacalcdate
			,lgh_etacomment
			,ord_number
			,ord_origincity
			,ord_destcity
			,ord_revtype1
			,ord_refnum
			,ord_destpoint
			,lgh_eta_cmp_list
			,lgh_booked_revtype1
			)
	  select distinct l.mov_number
			,l.lgh_number
			,l.lgh_startdate
			,l.lgh_enddate  
			,l.lgh_startcity
			,l.lgh_endcity  
			,l.lgh_startregion1
			,l.lgh_outstatus 
			,l.lgh_tractor  
			,l.lgh_driver1   
			,l.mpp_teamleader
			,l.lgh_etaalert1   
			,l.lgh_etamins1   
			,l.ord_hdrnumber
			,l.lgh_startcty_nmstct
			,l.lgh_endcty_nmstct  
			,l.lgh_prjdate1  
			,l.lgh_carrier
			,isnull(c.car_board, 'T')
			,l.lgh_etacalcdate
			,l.lgh_etacomment
			,isnull(o.ord_number, 0)
			,isnull(o.ord_origincity, 0)
			,isnull(o.ord_destcity, 0)
			,isnull(o.ord_revtype1, '')
			,isnull(o.ord_refnum, '')
			,o.ord_destpoint
			,lgh_eta_cmp_list
			,l.lgh_booked_revtype1
	  from	legheader l LEFT OUTER JOIN orderheader o ON o.ord_hdrnumber = l.ord_hdrnumber
				join @billtos on bill_to = o.ord_billto
				LEFT OUTER JOIN carrier c ON c.car_id = l.lgh_carrier
				join stops s on s.lgh_number = l.lgh_number
	  where	l.lgh_active = 'Y'
		and	l.lgh_outstatus <> 'CMP'
		and	l.lgh_startdate < dateadd(hour, @vf_hoursout, getdate())
		and	l.ord_hdrnumber <> 0
		and s.ord_hdrnumber <> 0
		and	(@vl_lgh_number = 0
				or l.lgh_number = @vl_lgh_number)

--Get CheckCall info..
insert into @trc
		(trc_number)
  select distinct lgh_tractor
  from	@lgh

insert into @ckc
		(ckc_tractor
		,trc_gps_date)
  select t.trc_number,
		(select max(ck.ckc_date) 
           from checkcall ck   
           where ck.ckc_tractor = t.trc_number
             and ck.ckc_date <= getdate())
  from	@trc t

update	@ckc
  set	ckc_number = c.ckc_number
		,trc_gps_desc = convert(varchar(20), convert(money, c.ckc_latseconds) / 3600, 2) + 
						replicate('N, ', sign(isnull(c.ckc_latseconds, 0))) + 
						convert(varchar(20), convert(money, c.ckc_longseconds) / 3600, 2) + 
						replicate('W', sign(isnull(c.ckc_longseconds, 0)))
		,ckc_comment = c.ckc_comment
		,ckc_commentlarge = c.ckc_commentlarge
  from	@ckc tc
		,checkcall c
  where	c.ckc_tractor = tc.ckc_tractor
	and	c.ckc_date = tc.trc_gps_date

if @EnhancedCarrierETA = 'Y' begin
	update @lgh 
	set max_carrier_ckc_date = (select max(ck.ckc_date) from checkcall ck where ck.ckc_lghnumber = l.lgh_number and ck.ckc_date <= getdate())
	from @lgh l
	where lgh_tractor='UNKNOWN'
	and lgh_carrier <> 'UNKNOWN'
end

--Final select..
select	l.mov_number
		,l.lgh_number
		,l.lgh_startdate
		,l.lgh_enddate
		,l.lgh_startcity
		,l.lgh_endcity
		,l.lgh_startregion1
		,l.lgh_outstatus
		,l.lgh_tractor
		,l.lgh_driver1
		,l.mpp_teamleader
		,l.lgh_etaalert1
		,l.lgh_etamins1
		,l.ord_hdrnumber
		,l.lgh_startcty_nmstct
		,l.lgh_endcty_nmstct
		,l.lgh_prjdate1
		,l.lgh_carrier
		,l.car_board
		,l.lgh_etacalcdate
		,l.lgh_etacomment
		,l.ord_number
		,isnull(c1.cty_nmstct, '') as ord_origincty_nmstct
		,isnull(c2.cty_nmstct, '') as ord_destcty_nmstct
		,case when max_carrier_ckc_date is null 
			then isnull(ck.trc_gps_desc, '') 
			else convert(varchar(20), convert(money, checkcall.ckc_latseconds) / 3600, 2) + 
				 replicate('N, ', sign(isnull(checkcall.ckc_latseconds, 0))) + 
				 convert(varchar(20), convert(money, checkcall.ckc_longseconds) / 3600, 2) + 
				 replicate('W', sign(isnull(checkcall.ckc_longseconds, 0)))
		 end as trc_gps_desc
		--JLB PTS 46897 HotFix changing the checkcall time to the current system time if it is over x number of hours old
		--,isnull(max_carrier_ckc_date,isnull(ck.trc_gps_date, '1950-01-01')) as trc_gps_date
		,case when @EtaUseCurrTime4OldCKC = 'Y' and ck.trc_gps_date < dateadd(hh,@UseThisTimeForOldCKC,getdate())
                   then getdate()
                   else isnull(max_carrier_ckc_date,isnull(ck.trc_gps_date, '1950-01-01'))
          end as trc_gps_date
		,case when max_carrier_ckc_date is null 
			then isnull(ck.ckc_comment, '')  
			else isnull(checkcall.ckc_comment, '')
		 end as ckc_comment
		,case when max_carrier_ckc_date is null 
			then isnull(ck.ckc_commentlarge, '')  
			else isnull(checkcall.ckc_commentlarge, '')
		 end as ckc_commentlarge
		,isnull(l.ord_revtype1, '') as ord_revtype1
		,isnull(l.ord_refnum, '') as ord_refnum
		,isnull(co.cmp_name, '') as	ord_dest_name
		,isnull(t.trc_eta_skip, 'N') as trc_eta_skip
		,lgh_eta_cmp_list
		,l.lgh_booked_revtype1 as branch
		,isNull (cs.cty_gmtdelta, 999)
		,isNull (cs.cty_dstapplies, 'N')
		,isNull (cs.cty_tzmins, 999)
  from	@lgh l
left outer join checkcall on checkcall.ckc_lghnumber=l.lgh_number and checkcall.ckc_date = l.max_carrier_ckc_date
		join city c1 (nolock) on c1.cty_code = l.ord_origincity 
		join city c2 (nolock) on c2.cty_code = l.ord_destcity
		join @ckc ck on ck.ckc_tractor = l.lgh_tractor
		join company co on co.cmp_id = l.ord_destpoint
		join tractorprofile t on t.trc_number = l.lgh_tractor
		join city cs (nolock) on l.lgh_startcity = cs.cty_code


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
GRANT EXECUTE ON  [dbo].[d_late_legheader_wc_sp] TO [public]
GO
