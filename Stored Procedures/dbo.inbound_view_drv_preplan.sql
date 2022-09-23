SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create  PROCEDURE       [dbo].[inbound_view_drv_preplan] 
/*This uses the same args a inbound_view_drv so that it can use the same retrieve code
note: the location and date args have no affect in this proc.*/

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
 * dbo.inbound_view_drv_preplan 
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
 * 11/12/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 10/28/2008.01 - PTS44618 - vjh - create a blank row if no preplan rows found
 *
 **/


declare 
	@lgh_index int,
	@currentactivity_lgh_number int,
	@drvplan_number int,
	@drvplan_number_index int,
	@maxdate datetime,
	@modified char(1),
	@dummy	char(1),
	@drvpln	int,
	@count	int

select @dummy = null -- to return a value for the dummy columns that
		     -- cover each group of columns for drag and drop ID
--JLB PTS 33251 also get it from the GI if it is less than 0 (planning worksheet always passes -1)
--If @leg_rev_mode is null
If @leg_rev_mode is null or @leg_rev_mode < 0
--end 33251
	select @leg_rev_mode = gi_integer1 from generalinfo where gi_name='DrvPlanRev'
If @leg_rev_mode <> 0 and @leg_rev_mode <> 1 select @leg_rev_mode = 0
select @leg_rev_mode = isnull(@leg_rev_mode ,0)

create table #driver_plan
(drvplan_number int,
 minid int null,
 next_mfh_number int null)

create index tmp_mppid on #driver_plan(drvplan_number)

create table #lgh
(id int identity,
 drvplan_number int,
 lgh_number int null,
 mfh_number int null,
 mov_number int null,
 ord_hdrnumber int null,
 lgh_startdate datetime null,
 total_lgh_revenue float null,
 total_lgh_miles int null)
create clustered index tmp_id on #lgh(id)

create table #lghminmax
(drvplan_number int, 
 firstid int null,
 lastid int null)

create index tmp_lghminmax on #lghminmax(drvplan_number)

create table #out
(drvplan_number int,
 next_mfh_number int null,
 total_driver_revenue float null,
 total_driver_miles int null,
 total_driver_epm float null,
 lgh1 int null,
 lgh2 int null,
 lgh3 int null,
 lgh4 int null)

if @singledriver <> 'UNKNOWN'
	insert into #driver_plan (drvplan_number) values (cast(@singledriver as integer))
else begin
	--vjh 44618
	insert into #driver_plan (drvplan_number)
	select drvplan_number
	FROM    driver_plan
	WHERE   ( ',' +@drvplantype1 like '%,'+driver_plan.drvplan_type1+'%' OR @drvplantype1 = '') AND
		( ',' +@drvplantype2 like '%,'+driver_plan.drvplan_type2+'%' OR @drvplantype2 = '') AND
		( ',' +@drvplantype3 like '%,'+driver_plan.drvplan_type3+'%' OR @drvplantype3 = '') AND
		( ',' +@drvplantype4 like '%,'+driver_plan.drvplan_type4+'%' OR @drvplantype4 = '')
	select @count = count(*) from #driver_plan
	if @count=0 begin
		execute @drvpln = getsystemnumber 'DRVPLN',''
		insert driver_plan (drvplan_number, drvplan_type1, drvplan_type2, drvplan_type3, drvplan_type4)
		values 
			(
				@drvpln,
				case @drvplantype1 when '' then 'UNK' else @drvplantype1 end,
				case @drvplantype2 when '' then 'UNK' else @drvplantype2 end,
				case @drvplantype3 when '' then 'UNK' else @drvplantype3 end,
				case @drvplantype4 when '' then 'UNK' else @drvplantype4 end
			)
		insert into #driver_plan (drvplan_number)
		select drvplan_number
		FROM    driver_plan
		WHERE   ( ',' +@drvplantype1 like '%,'+driver_plan.drvplan_type1+'%' OR @drvplantype1 = '') AND
			( ',' +@drvplantype2 like '%,'+driver_plan.drvplan_type2+'%' OR @drvplantype2 = '') AND
			( ',' +@drvplantype3 like '%,'+driver_plan.drvplan_type3+'%' OR @drvplantype3 = '') AND
			( ',' +@drvplantype4 like '%,'+driver_plan.drvplan_type4+'%' OR @drvplantype4 = '')
	end
end

insert into #lgh (drvplan_number, 
                  lgh_number, 
                  mfh_number, 
                  mov_number,
                  ord_hdrnumber, 
                  lgh_startdate, 
                  total_lgh_revenue,
                  total_lgh_miles
)
	select #driver_plan.drvplan_number, lgh_number, mfh_number, mov_number, ord_hdrnumber, lgh_startdate, 0,0
		from legheader_active legheader, #driver_plan
		where legheader.drvplan_number = #driver_plan.drvplan_number
		order by #driver_plan.drvplan_number, isnull(mfh_number,2147483647), lgh_startdate

update #lgh set total_lgh_revenue = (select isnull(ord_totalcharge,0)
				    from orderheader 
				    where #lgh.ord_hdrnumber = orderheader.ord_hdrnumber),  --pts40187 removed leftouter join from correlated query
                total_lgh_miles = (select sum(isnull(stp_lgh_mileage,0))
				  from stops
				  where #lgh.lgh_number=stops.lgh_number)

-- vjh fix duplicate mfh_number for same driver
update #driver_plan set minid=(select min(id) from #lgh where drvplan_number = #driver_plan.drvplan_number)
update #lgh set mfh_number= id - minid + 1
from #driver_plan
where #lgh.drvplan_number = #driver_plan.drvplan_number

--if @modified='Y'
	update legheader_active 
	set mfh_number = #lgh.mfh_number
	from #lgh
	where legheader_active.lgh_number=#lgh.lgh_number

--vjh 010130 put next_mfh_number on driver table
update #driver_plan set next_mfh_number = 
     (select isnull(max(mfh_number),0) + 1 from #lgh where drvplan_number = #driver_plan.drvplan_number)

insert #lghminmax
select #lgh.drvplan_number, min(id) firstid, max(id) lastid
from #lgh
group by #lgh.drvplan_number

insert #out
select #driver_plan.drvplan_number, #driver_plan.next_mfh_number, null,null,0,
                (select lgh_number
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
FROM  #lghminmax  RIGHT OUTER JOIN  #driver_plan  ON  #lghminmax.drvplan_number  = #driver_plan.drvplan_number  --pts40187 jguo outer join conversion
--from #driver_plan, #lghminmax
--where #lghminmax.drvplan_number =* #driver_plan.drvplan_number

update #out set
 total_driver_revenue = isnull((select sum(total_lgh_revenue) from #lgh where #out.drvplan_number=#lgh.drvplan_number),0),
 total_driver_miles = isnull((select sum(total_lgh_miles) from #lgh where #out.drvplan_number=#lgh.drvplan_number),0)

update #out set total_driver_epm = total_driver_revenue / total_driver_miles
 where total_driver_revenue <> 0 and total_driver_miles <> 0

select cast(#out.drvplan_number as varchar(8)),
drvplan_type1, --manpowerprofile.mpp_lastfirst,
'', --manpowerprofile.mpp_type1,
'', --manpowerprofile.mpp_type2,
'', --manpowerprofile.mpp_type3,
'', --manpowerprofile.mpp_type4,
'', --manpowerprofile.mpp_teamleader,
'', --manpowerprofile.mpp_domicile,
'', --manpowerprofile.mpp_fleet,
'', --manpowerprofile.mpp_division,
'', --manpowerprofile.mpp_company,
'', --manpowerprofile.mpp_terminal,

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
total_driver_miles as total_miles_with_dh
FROM  #out  LEFT OUTER JOIN  legheader_active leg1  ON  #out.lgh1  = leg1.lgh_number   
		LEFT OUTER JOIN  legheader_active leg2  ON  #out.lgh2  = leg2.lgh_number   
		LEFT OUTER JOIN  legheader_active leg3  ON  #out.lgh3  = leg3.lgh_number   
		LEFT OUTER JOIN  legheader_active leg4  ON  #out.lgh4  = leg4.lgh_number ,
	 driver_plan 
--from #out, legheader_active leg1, legheader_active leg2, legheader_active leg3, legheader_active leg4, driver_plan
where 
	--lgh1 *= leg1.lgh_number and
	--lgh2 *= leg2.lgh_number and
	--lgh3 *= leg3.lgh_number and
	--lgh4 *= leg4.lgh_number and
	#out.drvplan_number = driver_plan.drvplan_number
order by #out.drvplan_number
GO
GRANT EXECUTE ON  [dbo].[inbound_view_drv_preplan] TO [public]
GO
