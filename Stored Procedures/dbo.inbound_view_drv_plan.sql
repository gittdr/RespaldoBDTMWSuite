SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE       [dbo].[inbound_view_drv_plan]
/*This uses the same args a inbound_view_drv so that it can use the same retrieve code
note: the location and date args have no affect in this proc.*/
/*
PTS40260 recode Pauls  11/30/06 - PTS35279 - jguo - remove index hints. Change "grant all".
PTS57841 JJF/DSK 20110707 - nolocks + argument requirement checks
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
 * dbo.inbound_view_drv_plan 
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
 *
 * 10/16/2006	PTS 32188 - DJM - Add the Prepay amount for Drivers to the Driver Plan grid.
 * 05/23/2007   PTS 37663 - JG - fixed performance problem caused by PTS35437
 * 08/22/2007	pts 39078 - vjh additional tweaking to performance enhancement
 * 11/28/2007   PTS 40187 - JG - Outer join conversion
 **/


declare 
	@lgh_index int,
	@currentactivity_lgh_number int,
	@lgh_driver1 varchar(8),
	@mpp_id_index varchar(8),
	@maxdate datetime,
	@modified char(1),
	@dummy char(1),
        --PTS 57841 JJF/DSK 20110707
	@ReqArgs VARCHAR(60),
	@ArgsOK CHAR(1)
        --END PTS 57841 JJF/DSK 20110707

--PTS 40155 JJF 20071128
declare @rowsecurity char(1)
--PTS 51570 JJF 20100510
--declare @tmwuser varchar(255)
--END PTS 51570 JJF 20100510
--END PTS 40155 JJF 20071128

--PTS 57841 JJF/DSK 20110707
SELECT @ReqArgs = UPPER(gi_string1) FROM generalinfo WHERE gi_name = 'IBViewRequiredArgs'
SET @ArgsOK = 'Y'
--IF @ReqArgs = '' SET @ArgsOK = 'Y' 
IF CHARINDEX('MPPTYPE1', @ReqArgs, 1) > 0 AND @mmptype1 = '' SET @ArgsOK = 'N'  
IF CHARINDEX('MPPTYPE2', @ReqArgs, 1) > 0 AND @mmptype2 = '' SET @ArgsOK = 'N'  
IF CHARINDEX('MPPTYPE3', @ReqArgs, 1) > 0 AND @mmptype3 = '' SET @ArgsOK = 'N'  
IF CHARINDEX('MPPTYPE4', @ReqArgs, 1) > 0 AND @mmptype4 = '' SET @ArgsOK = 'N'  
IF CHARINDEX('TEAMLEADER', @ReqArgs, 1) > 0 AND @teamleader = '' SET @ArgsOK = 'N'  
IF CHARINDEX('DOMICILE', @ReqArgs, 1) > 0 AND @domicile = '' SET @ArgsOK = 'N'  
IF CHARINDEX('FLEET', @ReqArgs, 1) > 0 AND @fleet = '' 	SET @ArgsOK = 'N' 
IF CHARINDEX('DIVISION', @ReqArgs, 1) > 0 AND @division = '' SET @ArgsOK = 'N'  
IF CHARINDEX('COMPANY', @ReqArgs, 1) > 0 AND  @company = '' SET @ArgsOK = 'N'  
IF CHARINDEX('TERMINAL', @ReqArgs, 1) > 0 AND @terminal = '' SET @ArgsOK = 'N'  
IF CHARINDEX('STATES', @ReqArgs, 1) > 0 AND @states = '' SET @ArgsOK = 'N'  
IF CHARINDEX('CMPIDS', @ReqArgs, 1) > 0 AND @cmpids = '' SET @ArgsOK = 'N'  
IF CHARINDEX('REGION1', @ReqArgs, 1) > 0 AND @region1 = 'UNK' SET @ArgsOK = 'N'  
IF CHARINDEX('REGION2', @ReqArgs, 1) > 0 AND @region2 = 'UNK' SET @ArgsOK = 'N'  
IF CHARINDEX('REGION3', @ReqArgs, 1) > 0 AND @region3 = 'UNK' SET @ArgsOK = 'N'  
IF CHARINDEX('REGION4', @ReqArgs, 1) > 0 AND @region4 = 'UNK' SET @ArgsOK = 'N'  
IF CHARINDEX('CITY', @ReqArgs, 1) > 0 AND @city = 0 SET @ArgsOK = 'N'  
IF CHARINDEX('SINGLEDRIVER', @ReqArgs, 1) > 0 AND @singledriver = 'UNKNOWN' SET @ArgsOK = 'N'  
IF CHARINDEX('DRVPLANTYPE1', @ReqArgs, 1) > 0 AND @drvplantype1 = '' SET @ArgsOK = 'N'  
IF CHARINDEX('DRVPLANTYPE2', @ReqArgs, 1) > 0 AND @drvplantype2 = '' SET @ArgsOK = 'N'  
IF CHARINDEX('DRVPLANTYPE3', @ReqArgs, 1) > 0 AND @drvplantype3 = '' SET @ArgsOK = 'N'  
IF CHARINDEX('DRVPLANTYPE4', @ReqArgs, 1) > 0 AND @drvplantype4 = '' SET @ArgsOK = 'N'  
--END PTS 57841 JJF/DSK 20110707

select @dummy = null -- to return a value for the dummy columns that
		     -- cover each group of columns for drag and drop ID
--JLB PTS 33251 also get it from the GI if it is less than 0 (planning worksheet always passes -1)
--If @leg_rev_mode is null
If @leg_rev_mode is null or @leg_rev_mode < 0
--end 33251
	select @leg_rev_mode = gi_integer1 from generalinfo where gi_name='DrvPlanRev'
If @leg_rev_mode <> 0 and @leg_rev_mode <> 1 select @leg_rev_mode = 0
select @leg_rev_mode = isnull(@leg_rev_mode ,0)

--PTS 57841 JJF/DSK 20110707 #table to @table
declare @drivers table
(mpp_id varchar(8),
 minid int null,
 currentactivity_lgh_number int null,
 next_mfh_number int null)

--create index tmp_mppid on @drivers(mpp_id)

--PTS 57841 JJF/DSK 20110707 add primary key
create table #lgh
(id int identity primary key,
 lgh_driver1 varchar(8),
 lgh_number int null,
 mfh_number int null,
 mov_number int null,
 ord_hdrnumber int null,
 lgh_startdate datetime null,
 total_lgh_revenue float null,
 total_lgh_miles int null)
 
create table #lghminmax
(lgh_driver1 varchar(8), 
 firstid int null,
 lastid int null)

create index tmp_lghminmax on #lghminmax(lgh_driver1)

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

IF @ArgsOK = 'n'
BEGIN
--PTS 57841 JJF/DSK 20110707 nolocks
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
	(select ord_number from orderheader (NOLOCK)
	 where orderheader.ord_hdrnumber = leg1.ord_hdrnumber) ord_number1,
	leg1.lgh_tractor lgh_tractor1,
	leg1.lgh_primary_trailer lgh_primary_trailer1,
	leg2.lgh_startdate startdate2,   
	leg2.lgh_enddate enddate2,  
	leg2.cmp_id_start startid2,   
	leg2.lgh_startcty_nmstct startcity2,   
	leg2.cmp_id_end endid2,   
	leg2.lgh_endcty_nmstct endcity2, 
	(select ord_number from orderheader (NOLOCK)
	 where orderheader.ord_hdrnumber = leg2.ord_hdrnumber) ord_number2,
	leg2.lgh_tractor lgh_tractor2,
	leg2.lgh_primary_trailer lgh_primary_trailer2,
	leg3.lgh_startdate startdate3,   
	leg3.lgh_enddate enddate3,   
	leg3.cmp_id_start startid3,   
	leg3.lgh_startcty_nmstct startcity3,   
	leg3.cmp_id_end endid3,   
	leg3.lgh_endcty_nmstct endcity3,
	(select ord_number from orderheader (NOLOCK)
	 where orderheader.ord_hdrnumber = leg3.ord_hdrnumber) ord_number3,
	leg3.lgh_tractor lgh_tractor3,
	leg3.lgh_primary_trailer lgh_primary_trailer3,
	leg4.lgh_startdate startdate4,   
	leg4.lgh_enddate enddate4,   
	leg4.cmp_id_start startid4,   
	leg4.lgh_startcty_nmstct startcity4,   
	leg4.cmp_id_end endid4,   
	leg4.lgh_endcty_nmstct endcity4,
	(select ord_number from orderheader (NOLOCK)
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
from #out  LEFT OUTER JOIN  legheader_active leg1 (NOLOCK) ON  #out.lgh1  = leg1.lgh_number   
		LEFT OUTER JOIN  legheader_active leg2 (NOLOCK) ON  #out.lgh2  = leg2.lgh_number   
		LEFT OUTER JOIN  legheader_active leg3 (NOLOCK) ON  #out.lgh3  = leg3.lgh_number   
		LEFT OUTER JOIN  legheader_active leg4 (NOLOCK) ON  #out.lgh4  = leg4.lgh_number ,
	 manpowerprofile --with(index(u_mpp_id))
where #out.mpp_id = manpowerprofile.mpp_id  --pts40187 outer join conversion
RETURN
END

if @singledriver <> 'UNKNOWN'
	insert into @drivers (mpp_id) values (@singledriver)
else
insert into @drivers (mpp_id)
select mpp_id
FROM    manpowerprofile WITH (NOLOCK), labelfile WITH (NOLOCK)
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

-- Walk through the drivers and find the current activity for each
-- to avoid doint this inside the select
select @mpp_id_index = min(mpp_id) from @drivers
while @mpp_id_index is not null
begin
	SELECT @maxdate = max(assetassignment.asgn_enddate)
		FROM 	assetassignment WITH (NOLOCK)
		WHERE 	(assetassignment.asgn_type = 'DRV') AND  
			(assetassignment.asgn_id = @mpp_id_index) AND  
			(assetassignment.asgn_status IN ('STD', 'CMP')) AND
			(assetassignment.asgn_enddate <= '20491231 23:59')
	select @currentactivity_lgh_number = min(assetassignment.lgh_number)
		from assetassignment WITH (NOLOCK)
		where (assetassignment.asgn_type = 'DRV') AND  
			(assetassignment.asgn_id = @mpp_id_index) AND  
			(assetassignment.asgn_status IN ('STD', 'CMP')) AND
			(assetassignment.asgn_enddate = @maxdate)
	update @drivers set currentactivity_lgh_number = @currentactivity_lgh_number
		where mpp_id = @mpp_id_index

	select @mpp_id_index = min(mpp_id) from @drivers where mpp_id > @mpp_id_index
end

insert into #lgh (lgh_driver1,
                  lgh_number, 
                  mfh_number, 
                  mov_number,
                  ord_hdrnumber, 
                  lgh_startdate, 
                  total_lgh_revenue,
                  total_lgh_miles
)
	select lgh_driver1, lgh_number, mfh_number, mov_number, ord_hdrnumber, lgh_startdate, 0,0
		from legheader_active legheader WITH (NOLOCK), @drivers d
		where lgh_driver1 = d.mpp_id and
			(lgh_outstatus = 'PLN' OR
			lgh_outstatus = 'DSP' OR
			lgh_number in (select currentactivity_lgh_number from @drivers d))
		order by lgh_driver1, isnull(mfh_number,2147483647), lgh_startdate

update #lgh set total_lgh_revenue = (select isnull(ord_totalcharge,0)
				    from orderheader WITH (NOLOCK) 
				    where #lgh.ord_hdrnumber = orderheader.ord_hdrnumber), --pts40187 removed the left outer join from the correlated query
                total_lgh_miles = (select sum(isnull(stp_lgh_mileage,0))
				  from stops with (NOLOCK)
				  where #lgh.lgh_number=stops.lgh_number)

-- vjh populate any null mfh_number columns and write back to legheaders
-- vjh fix duplicate mfh_number for same driver

update @drivers set minid= s.minid
from (select lgh_driver1, min(id) minid from #lgh group by lgh_driver1) s
inner join @drivers d on s.lgh_driver1 = d.mpp_id

update #lgh set mfh_number= id - minid + 1
from @drivers d
where lgh_driver1 = d.mpp_id

--if @modified='Y'
/* PTS 35437 - DJM - Modify to update the Legheader table instead of the Legheader_active to prevent the 
	value from getting overwritten the next time the leheader is modified.			*/
	update legheader 
	set mfh_number = #lgh.mfh_number
	from #lgh
	where legheader.lgh_number= #lgh.lgh_number
	and (legheader.mfh_number is null or legheader.mfh_number <> #lgh.mfh_number)  --jg and is null by vjh on 39078
	--PTS57814
	AND #lgh.mfh_number IS NOT NULL 
	AND #lgh.mfh_number > 0

--vjh 010130 put next_mfh_number on driver table
update @drivers set next_mfh_number=s.max_mfh_num
from (select lgh_driver1, isnull(max(mfh_number),0) + 1 as max_mfh_num from #lgh group by lgh_driver1) s
inner join @drivers d on s.lgh_driver1 = d.mpp_id

insert #lghminmax
select lgh_driver1, min(id) firstid, max(id) lastid
from #lgh
group by lgh_driver1

insert #out
select mpp_id, 
		d.next_mfh_number,null,null,0,
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
			#lghminmax.firstid <= #lghminmax.lastid  - 3 - @offset) lgh4,
		0,0,0,0,0
from #lghminmax RIGHT OUTER JOIN @drivers d ON #lghminmax.lgh_driver1 = d.mpp_id  --pts40187 outer join conversion

-- PTS 51570 JJF 20100510
----PTS 40155 JJF 20071128
--SELECT @rowsecurity = gi_string1
--FROM generalinfo 
--WHERE gi_name = 'RowSecurity'
--
----PTS 41877
----SELECT @tmwuser = suser_sname()
--exec @tmwuser = dbo.gettmwuser_fn
--
--IF @rowsecurity = 'Y' AND EXISTS(SELECT * 
--				FROM UserTypeAssignment
--				WHERE usr_userid = @tmwuser) BEGIN 
--
--	DELETE #out
--	from #out tp inner join manpowerprofile mpp on tp.mpp_id = mpp.mpp_id
--	where NOT (isnull(mpp.mpp_terminal, 'UNK') = 'UNK' 
--			or EXISTS(SELECT * 
--						FROM UserTypeAssignment
--						WHERE usr_userid = @tmwuser	
--								and (uta_type1 = mpp.mpp_terminal
--										or uta_type1 = 'UNK')))
--END
----END PTS 40155 JJF 20071128

SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN 
	DELETE	#out
	from	#out tp 
			inner join manpowerprofile mpp with (NOLOCK) on tp.mpp_id = mpp.mpp_id
	WHERE	NOT EXISTS	(	SELECT	*  
							FROM	RowRestrictValidAssignments_manpowerprofile_fn() rsva 
							WHERE	mpp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0
						)
END
--END PTS 51570 JJF 20100510

update #out set
 total_driver_revenue = isnull((select sum(total_lgh_revenue) from #lgh where #out.mpp_id=#lgh.lgh_driver1),0),
 total_driver_miles = isnull((select sum(total_lgh_miles) from #lgh where #out.mpp_id=#lgh.lgh_driver1),0)

update #out set total_driver_epm = total_driver_revenue / total_driver_miles
 where total_driver_revenue <> 0 and total_driver_miles <> 0

/* PTS 32188 - DJM - Include Driver PrePay information.			*/
if exists (select 1 from generalinfo where gi_name = 'StlEstimateInDispatch' and gi_string1 = 'Y' and
	charindex('DRV', gi_string2) > 0) 

	Update #out
	set lgh1_driver_pay = (select sum(pyd_amount) from prepay_detail pd WITH (NOLOCK)
							where pd.lgh_number = #out.lgh1 
								and pd.asgn_type = 'DRV'
								and pd.asgn_id = #out.mpp_id),
	lgh2_driver_pay = (select sum(pyd_amount) from prepay_detail pd WITH (NOLOCK)
								where pd.lgh_number = #out.lgh2
									and pd.asgn_type = 'DRV'
									and pd.asgn_id = #out.mpp_id),
	lgh3_driver_pay = (select sum(pyd_amount) from prepay_detail pd WITH (NOLOCK)
								where pd.lgh_number = #out.lgh3
									and pd.asgn_type = 'DRV'
									and pd.asgn_id = #out.mpp_id),
	lgh4_driver_pay = (select sum(pyd_amount) from prepay_detail pd WITH (NOLOCK)
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
	(select ord_number from orderheader WITH (NOLOCK)
	 where orderheader.ord_hdrnumber = leg1.ord_hdrnumber) ord_number1,
	leg1.lgh_tractor lgh_tractor1,
	leg1.lgh_primary_trailer lgh_primary_trailer1,
	leg2.lgh_startdate startdate2,   
	leg2.lgh_enddate enddate2,   
	leg2.cmp_id_start startid2,   
	leg2.lgh_startcty_nmstct startcity2,   
	leg2.cmp_id_end endid2,   
	leg2.lgh_endcty_nmstct endcity2, 
	(select ord_number from orderheader WITH (NOLOCK)
	 where orderheader.ord_hdrnumber = leg2.ord_hdrnumber) ord_number2,
	leg2.lgh_tractor lgh_tractor2,
	leg2.lgh_primary_trailer lgh_primary_trailer2,
	leg3.lgh_startdate startdate3,   
	leg3.lgh_enddate enddate3,   
	leg3.cmp_id_start startid3,   
	leg3.lgh_startcty_nmstct startcity3,   
	leg3.cmp_id_end endid3,   
	leg3.lgh_endcty_nmstct endcity3,
	(select ord_number from orderheader WITH (NOLOCK)
	 where orderheader.ord_hdrnumber = leg3.ord_hdrnumber) ord_number3,
	leg3.lgh_tractor lgh_tractor3,
	leg3.lgh_primary_trailer lgh_primary_trailer3,
	leg4.lgh_startdate startdate4,   
	leg4.lgh_enddate enddate4,   
	leg4.cmp_id_start startid4,   
	leg4.lgh_startcty_nmstct startcity4,   
	leg4.cmp_id_end endid4,   
	leg4.lgh_endcty_nmstct endcity4,
	(select ord_number from orderheader WITH (NOLOCK)
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
from #out  LEFT OUTER JOIN  legheader_active leg1 WITH (NOLOCK) ON  #out.lgh1  = leg1.lgh_number   
		LEFT OUTER JOIN  legheader_active leg2 WITH (NOLOCK) ON  #out.lgh2  = leg2.lgh_number   
		LEFT OUTER JOIN  legheader_active leg3 WITH (NOLOCK) ON  #out.lgh3  = leg3.lgh_number   
		LEFT OUTER JOIN  legheader_active leg4 WITH (NOLOCK) ON  #out.lgh4  = leg4.lgh_number ,
	 manpowerprofile --with(index(u_mpp_id))
where #out.mpp_id = manpowerprofile.mpp_id  --pts40187 outer join conversion

order by #out.mpp_id

GO
GRANT EXECUTE ON  [dbo].[inbound_view_drv_plan] TO [public]
GO
