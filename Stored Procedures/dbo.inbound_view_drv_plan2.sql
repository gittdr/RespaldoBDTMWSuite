SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create  PROCEDURE       [dbo].[inbound_view_drv_plan2] 
/*This uses the same args a inbound_view_drv so that it can use the same retrieve code
note: the location and date args have no affect in this proc.*/
/*
40260 Pauls recode 4/19/08  PTS35279 - jguo - remove index hints and double quote. Change "grant all".
*/

	@mmptype1       varchar(254),
	@mmptype2       varchar(254),
	@mmptype3       varchar(254),
	@mmptype4       varchar(254),
	@teamleader     varchar(254),
	@domicile       varchar(254),
	@fleet          varchar(254),
	@division       varchar(254),
	@company        varchar(254),
	@terminal       varchar(254),
	@states         varchar(254),
	@cmpids         varchar(254),
	@region1        varchar(254),
	@region2        varchar(254),
	@region3        varchar(254),
	@region4        varchar(254),
	@city           int,
	@hoursback      int,
	@hoursout       int,
	@days           int,
	@singledriver	varchar(8),
	@offset		int,
	@leg_rev_mode	int,
	@drvplantype1	varchar(254),
	@drvplantype2	varchar(254),
	@drvplantype3	varchar(254),
	@drvplantype4	varchar(254)
AS
/**
 * 
 * NAME:
 * dbo.inbound_view_drv_plan2 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 * 10/16/2006	PTS 32188 - DJM - Add the Prepay amount for Drivers to the Driver Plan grid.
 * 11/12/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax. Changed index hint syntax to with(index(u_mpp_id)). 
 *
 **/

declare 
	@lgh_index int,
	@lgh_driver1 varchar(8),
	@modified char(1),
	@dummy char(1)

select @dummy = null -- to return a value for the dummy columns that
		     -- cover each group of columns for drag and drop ID
--JLB PTS 33251 also get it from the GI if it is less than 0 (planning worksheet always passes -1)
--If @leg_rev_mode is null
If @leg_rev_mode is null or @leg_rev_mode < 0
--end 33251
	select @leg_rev_mode = gi_integer1 from generalinfo where 	gi_name='DrvPlanRev'

select @leg_rev_mode = isnull(@leg_rev_mode ,0)

create table #drivers
(mpp_id varchar(8))

create index tmp_mppid on #drivers(mpp_id)

create table #lgh
(id int identity,
 lgh_driver1 varchar(8),
 lgh_number int null,
 mfh_number int null,
 mov_number int null,
 lgh_startdate datetime null)
create clustered index tmp_id on #lgh(id)

create table #lghminmax
(lgh_driver1 varchar(8), 
 firstid int null,
 lastid int null)

create index tmp_lghminmax on #lghminmax(lgh_driver1)

-- PTS 32188 - Added columns to keep in synch with the main Driver Plan proc.
create table #out
(mpp_id varchar(8),
 next_mfh_number int null,
 total_driver_revenue float null,
 total_driver_miles int null,
 total_driver_epm float null,
 lgh1 int null,
 lgh2 int null,
 lgh3 int null,
 lgh4 int null,
 total_driver_pay	float	null,
 lgh1_driver_pay	float	null,
 lgh2_driver_pay	float	null,
 lgh3_driver_pay	float	null,
 lgh4_driver_pay	float	null)

if @singledriver <> 'UNKNOWN'
	insert into #drivers (mpp_id) values (@singledriver)
else
insert into #drivers
select mpp_id
FROM    manpowerprofile, labelfile
WHERE   ( manpowerprofile.mpp_status = abbr AND labeldefinition = 'DrvStatus') AND
	( labelfile.code < 200 ) AND
	( ',' +@mmptype1 like '%,'+manpowerprofile.mpp_type1+'%' OR @mmptype1 = '') AND
	( ',' +@mmptype2 like '%,'+manpowerprofile.mpp_type2+'%' OR @mmptype2 = '') AND
	( ',' +@mmptype3 like '%,'+manpowerprofile.mpp_type3+'%' OR @mmptype3 = '') AND
	( ',' +@mmptype4 like '%,'+manpowerprofile.mpp_type4+'%' OR @mmptype4 = '') AND
	( ',' +@teamleader like '%,'+manpowerprofile.mpp_teamleader+'%' OR @teamleader = '') AND
	( ',' +@domicile like '%,'+manpowerprofile.mpp_domicile+'%' OR @domicile = '') AND
	( ',' +@fleet like '%,'+manpowerprofile.mpp_fleet+'%' OR @fleet = '') AND
	( ',' +@division like '%,'+manpowerprofile.mpp_division+'%' OR @division = '') AND
	( ',' +@company like '%,'+manpowerprofile.mpp_company+'%' OR @company = '') AND
	( ',' +@terminal like '%,'+manpowerprofile.mpp_terminal+'%' OR @terminal = '') and
	mpp_id <> 'UNKNOWN'
-- and mpp_id='001'

insert into #lgh (lgh_driver1, lgh_number, mfh_number, mov_number, lgh_startdate)
select lgh_driver1, lgh_number, mfh_number, mov_number, lgh_startdate
from legheader_active legheader, #drivers
where 
    --lgh_active = 'Y' and  --pts40187 not needed, column does not exist
	lgh_driver1 = #drivers.mpp_id
order by lgh_driver1, isnull(mfh_number,2147483647), lgh_startdate

-- vjh populate any null mfh_number columns and write back to legheaders
select @modified='N'
select @lgh_index=min(id)
from #lgh where mfh_number is null
while @lgh_index is not null
begin
	select @modified='Y'
	select @lgh_driver1 = lgh_driver1
	from #lgh
	where id=@lgh_index
	update #lgh set mfh_number = 
		(select(isnull(max(mfh_number),0) + 1) from #lgh where lgh_driver1 = @lgh_driver1)
	where id=@lgh_index

	select @lgh_index=min(id)
	from #lgh where mfh_number is null
end
if @modified='Y'
	/* PTS 35437 - DJM - Modify to update the Legheader table instead of the Legheader_active to prevent the 
	value from getting overwritten the next time the leheader is modified.			*/
	update legheader
	set mfh_number = #lgh.mfh_number
	from #lgh
	where legheader.lgh_number=#lgh.lgh_number

insert #lghminmax
select lgh_driver1, min(id) firstid, max(id) lastid
from #lgh
group by lgh_driver1

insert #out (mpp_id, lgh1, lgh2, lgh3, lgh4)
select mpp_id, (select lgh_number
		from #lgh
		where #lgh.id = #lghminmax.firstid + @offset and
			#lghminmax.firstid  <= #lghminmax.lastid -  @offset) lgh1,
		(select lgh_number
		from #lgh
		where #lgh.id = #lghminmax.firstid+1 + @offset and
			#lghminmax.firstid  <= #lghminmax.lastid - 1 - @offset) lgh2,
		(select lgh_number
		from #lgh
		where #lgh.id = #lghminmax.firstid+2 + @offset and
			#lghminmax.firstid <= #lghminmax.lastid - 2 - @offset) lgh3,
				(select lgh_number
		from #lgh
		where #lgh.id = #lghminmax.firstid + 3 + @offset and
			#lghminmax.firstid <= #lghminmax.lastid  - 3 - @offset) lgh4
FROM  #lghminmax RIGHT OUTER JOIN  #drivers  ON  #lghminmax.lgh_driver1  = #drivers.mpp_id 
--pts40187 jguo outer join conversion
--from #drivers, #lghminmax
--where lgh_driver1 =* #drivers.mpp_id

/* PTS 32188 - DJM - Include Driver PrePay information.			*/
if exists (select 1 from generalinfo where gi_name = 'StlEstimateInDispatch' and gi_string1 = 'Y' and
	charindex('DRV', gi_string2) > 0) 

	Update #out
	set lgh1_driver_pay = (select sum(pyd_amount) from prepay_detail pd
							where pd.lgh_number = #out.lgh1
								and pd.asgn_type = 'DRV'
								and pd.asgn_id = #out.mpp_id),
	lgh2_driver_pay = (select sum(pyd_amount) from prepay_detail pd
								where pd.lgh_number = #out.lgh2
									and pd.asgn_type = 'DRV'
									and pd.asgn_id = #out.mpp_id),
	lgh3_driver_pay = (select sum(pyd_amount) from prepay_detail pd
								where pd.lgh_number = #out.lgh3
									and pd.asgn_type = 'DRV'
									and pd.asgn_id = #out.mpp_id),
	lgh4_driver_pay = (select sum(pyd_amount) from prepay_detail pd
								where pd.lgh_number = #out.lgh4
									and pd.asgn_type = 'DRV'
									and pd.asgn_id = #out.mpp_id)

select #out.mpp_id, 
	manpowerprofile.mpp_lastfirst,
	manpowerprofile.mpp_type1,
	manpowerprofile.mpp_type2,
	manpowerprofile.mpp_type3,
	manpowerprofile.mpp_type4,
	manpowerprofile.mpp_teamleader,
	manpowerprofile.mpp_domicile,
	manpowerprofile.mpp_fleet,
	manpowerprofile.mpp_division,
	manpowerprofile.mpp_company,
	manpowerprofile.mpp_terminal,

	leg1.lgh_startdate startdate1,   
	leg1.lgh_enddate enddate1,   
	leg1.cmp_id_start startid1,   
	leg1.lgh_startcty_nmstct startcity1,   
	leg1.cmp_id_end endid1,   
	leg1.lgh_endcty_nmstct endcity1, 				
	(select ord_number from orderheader
	 where orderheader.ord_hdrnumber = leg1.ord_hdrnumber) ord_number1,
	leg1.lgh_tractor lgh_tractor1,
	leg1.lgh_primary_trailer lgh_primary_trailer1,

	leg2.lgh_startdate startdate2,   
	leg2.lgh_enddate enddate2,   
	leg2.cmp_id_start startid2,   
	leg2.lgh_startcty_nmstct startcity2,   
	leg2.cmp_id_end endid2,   
	leg2.lgh_endcty_nmstct endcity2, 
	(select ord_number from orderheader
	 where orderheader.ord_hdrnumber = leg2.ord_hdrnumber) ord_number2,
	leg2.lgh_tractor lgh_tractor2,
	leg2.lgh_primary_trailer lgh_primary_trailer2,

	leg3.lgh_startdate startdate3,   
	leg3.lgh_enddate enddate3,   
	leg3.cmp_id_start startid3,   
	leg3.lgh_startcty_nmstct startcity3,   
	leg3.cmp_id_end endid3,   
	leg3.lgh_endcty_nmstct endcity3,
	(select ord_number from orderheader
	 where orderheader.ord_hdrnumber = leg3.ord_hdrnumber) ord_number3,
	leg3.lgh_tractor lgh_tractor3,
	leg3.lgh_primary_trailer lgh_primary_trailer3,

	leg4.lgh_startdate startdate4,   
	leg4.lgh_enddate enddate4,   
	leg4.cmp_id_start startid4,   
	leg4.lgh_startcty_nmstct startcity4,   
	leg4.cmp_id_end endid4,   
	leg4.lgh_endcty_nmstct endcity4,
	(select ord_number from orderheader
	 where orderheader.ord_hdrnumber = leg4.ord_hdrnumber) ord_number4,
	leg4.lgh_tractor lgh_tractor4,
	leg4.lgh_primary_trailer lgh_primary_trailer4,
	leg1.lgh_number lgh_number1,
	leg2.lgh_number lgh_number2,
	leg3.lgh_number lgh_number3,
	leg4.lgh_number lgh_number4,
	leg1.mfh_number,
	leg2.mfh_number,
	leg3.mfh_number,
	leg4.mfh_number,
	leg1.mov_number,
	leg2.mov_number,
	leg3.mov_number,
	leg4.mov_number,
	leg1.lgh_startlat,
	leg1.lgh_startlong,
	leg1.lgh_endlat,
	leg1.lgh_endlong,
	leg1.lgh_rstartdate,
	leg1.lgh_rstartcity,
	leg1.lgh_rstartcty_nmstct,
	leg1.lgh_rstartstate,
	leg1.lgh_rstartlat,
	leg1.lgh_rstartlong,
	leg1.stp_number_rstart,
	leg1.cmp_id_rstart,
	leg1.lgh_rstartregion1,
	leg1.lgh_rstartregion2,
	leg1.lgh_rstartregion3,
	leg1.lgh_rstartregion4,
	leg1.lgh_renddate,
	leg1.lgh_rendcity,
	leg1.lgh_rendcty_nmstct,
	leg1.lgh_rendstate,
	leg1.lgh_rendlat,
	leg1.lgh_rendlong,
	leg1.stp_number_rend,
	leg1.cmp_id_rend,
	leg1.lgh_rendregion1,
	leg1.lgh_rendregion2,
	leg1.lgh_rendregion3,
	leg1.lgh_rendregion4,
	leg2.lgh_startlat,
	leg2.lgh_startlong,
	leg2.lgh_endlat,
	leg2.lgh_endlong,
	leg2.lgh_rstartdate,
	leg2.lgh_rstartcity,
	leg2.lgh_rstartcty_nmstct,
	leg2.lgh_rstartstate,
	leg2.lgh_rstartlat,
	leg2.lgh_rstartlong,
	leg2.stp_number_rstart,
	leg2.cmp_id_rstart,
	leg2.lgh_rstartregion1,
	leg2.lgh_rstartregion2,
	leg2.lgh_rstartregion3,
	leg2.lgh_rstartregion4,
	leg2.lgh_renddate,
	leg2.lgh_rendcity,
	leg2.lgh_rendcty_nmstct,
	leg2.lgh_rendstate,
	leg2.lgh_rendlat,
	leg2.lgh_rendlong,
	leg2.stp_number_rend,
	leg2.cmp_id_rend,
	leg2.lgh_rendregion1,
	leg2.lgh_rendregion2,
	leg2.lgh_rendregion3,
	leg2.lgh_rendregion4,
	leg3.lgh_startlat,
	leg3.lgh_startlong,
	leg3.lgh_endlat,
	leg3.lgh_endlong,
	leg3.lgh_rstartdate,
	leg3.lgh_rstartcity,
	leg3.lgh_rstartcty_nmstct,
	leg3.lgh_rstartstate,
	leg3.lgh_rstartlat,
	leg3.lgh_rstartlong,
	leg3.stp_number_rstart,
	leg3.cmp_id_rstart,
	leg3.lgh_rstartregion1,
	leg3.lgh_rstartregion2,
	leg3.lgh_rstartregion3,
	leg3.lgh_rstartregion4,
	leg3.lgh_renddate,
	leg3.lgh_rendcity,
	leg3.lgh_rendcty_nmstct,
	leg3.lgh_rendstate,
	leg3.lgh_rendlat,
	leg3.lgh_rendlong,
	leg3.stp_number_rend,
	leg3.cmp_id_rend,
	leg3.lgh_rendregion1,
	leg3.lgh_rendregion2,
	leg3.lgh_rendregion3,
	leg3.lgh_rendregion4,
	leg4.lgh_startlat,
	leg4.lgh_startlong,
	leg4.lgh_endlat,
	leg4.lgh_endlong,
	leg4.lgh_rstartdate,
	leg4.lgh_rstartcity,
	leg4.lgh_rstartcty_nmstct,
	leg4.lgh_rstartstate,
	leg4.lgh_rstartlat,
	leg4.lgh_rstartlong,
	leg4.stp_number_rstart,
	leg4.cmp_id_rstart,
	leg4.lgh_rstartregion1,
	leg4.lgh_rstartregion2,
	leg4.lgh_rstartregion3,
	leg4.lgh_rstartregion4,
	leg4.lgh_renddate,
	leg4.lgh_rendcity,
	leg4.lgh_rendcty_nmstct,
	leg4.lgh_rendstate,
	leg4.lgh_rendlat,
	leg4.lgh_rendlong,
	leg4.stp_number_rend,
	leg4.cmp_id_rend,
	leg4.lgh_rendregion1,
	leg4.lgh_rendregion2,
	leg4.lgh_rendregion3,
	leg4.lgh_rendregion4,
	@leg_rev_mode,
	@dummy,
	@offset,
	leg1.lgh_outstatus lgh_outstatus1,
	leg2.lgh_outstatus lgh_outstatus2,
	leg3.lgh_outstatus lgh_outstatus3,
	leg4.lgh_outstatus lgh_outstatus4,
	#out.next_mfh_number,
	total_driver_revenue,
	total_driver_miles,
	total_driver_epm,
	total_driver_miles AS total_miles_with_dh,
	isNull(lgh1_driver_pay, 0) as lgh1_driver_pay,
	isNull(lgh2_driver_pay, 0) as lgh2_driver_pay,
	isNull(lgh3_driver_pay, 0) as lgh3_driver_pay,
	isNull(lgh4_driver_pay, 0) as lgh4_driver_pay

FROM  #out  LEFT OUTER JOIN  legheader_active leg1  ON  #out.lgh1  = leg1.lgh_number   
			LEFT OUTER JOIN  legheader_active leg2  ON  #out.lgh2  = leg2.lgh_number   
			LEFT OUTER JOIN  legheader_active leg3  ON  #out.lgh3  = leg3.lgh_number   
			LEFT OUTER JOIN  legheader_active leg4  ON  #out.lgh4  = leg4.lgh_number ,
	 manpowerprofile --with(index(u_mpp_id)) 
where --pts40187 jguo outer join conversion
--	#out.lgh1 *= leg1.lgh_number and
--	#out.lgh2 *= leg2.lgh_number and
--	#out.lgh3 *= leg3.lgh_number and
--	#out.lgh4 *= leg4.lgh_number and
	#out.mpp_id = manpowerprofile.mpp_id
order by #out.mpp_id
GO
GRANT EXECUTE ON  [dbo].[inbound_view_drv_plan2] TO [public]
GO
