SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



create proc [dbo].[d_cur_avl_tractor_sp] (
	@cmp_id varchar(8),
	@zip  varchar(10),
	@citycode integer
	)
as
/**
 * 
 * REVISION HISTORY:
 * 10/25/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

create table #trc_ref
		(trc_number	varchar(8)
		,ref_count	int)

create table #temp(	
	 trc_number varchar(8) null ,   
         trc_avl_lgh integer null ,   
         trc_pln_lgh integer null ,   
         trc_owner varchar(12) null ,   
         trc_type1 varchar(6) null ,   
         trc_type2 varchar(6) null ,   
         trc_type3 varchar(6) null ,   
         trc_type4 varchar(6) null ,   
         trc_company varchar(6) null ,   
         trc_division varchar(6) null ,   
         trc_fleet varchar(6) null ,   
         trc_terminal varchar(6) null ,   
         trc_grosswgt integer null ,   
         trc_axles integer null ,   
         trc_status varchar(6) null ,   
         trc_make varchar(8) null ,   
         trc_model varchar(8) null ,   
         trc_avl_date datetime null ,   
         trc_avl_cmp_id varchar(8) null ,   
         trc_avl_city integer null ,   
         trc_avl_status varchar(6) null ,   
         trc_pln_date datetime null ,   
         trc_pln_cmp_id varchar(8) null ,   
         trc_pln_city integer null ,   
         trc_driver varchar(8) null ,   
         cty_nmstct varchar(30) null ,   
         cty_state varchar(6) null ,
	 cty_name varchar(18) null ,   
         dest_zip varchar(10) null ,   
         cty_region1 varchar(6) null ,   
         cty_region2 varchar(6) null ,   
         cty_region3 varchar(6) null ,   
         cty_region4 varchar(6) null , 
	 cty_latitude decimal(14,6) null , --PTS--PTS92864
	 cty_longitude decimal(14,6) null ,  
         trc_enginemake varchar(10) null ,   
         trc_enginemodel varchar(10) null ,   
         trc_engineserial varchar(20) null ,   
         trc_serial varchar(20) null ,   
         trc_licstate char(6) null ,   
         trc_licnum varchar(12) null ,
	      trc_gps_desc varchar(255) null ,
	      trc_gps_date datetime null ,
          Distance money null,
	      latseconds decimal (11,3) null ,
	      longseconds decimal(11,3) null,
	 trc_misc2 varchar(254) null,
	 refusal_count int null,
	 dnr_count int null,
	 ord_number varchar(12) null,
	 trc_note_date datetime null,
	 trc_alert_date datetime null,
	 at_home char(8) null,
	 maxrefcount int null )

declare @tablename 			int
		,@li_MaxRefDays		int
		,@ldt_begin_range	datetime
		,@city_latlong_units char(1)

select @tablename = isnull(gi_integer1,1)
from generalinfo
where gi_name = 'mileagelookup'
select @city_latlong_units = isnull(Left(gi_string1,1),'D')
from generalinfo where gi_name = 'CityLatLongUnits'

insert into  #temp 
	SELECT   tractorprofile.trc_number,   
         tractorprofile.trc_avl_lgh,   
         tractorprofile.trc_pln_lgh,   
         tractorprofile.trc_owner,   
         tractorprofile.trc_type1,   
         tractorprofile.trc_type2,   
         tractorprofile.trc_type3,   
         tractorprofile.trc_type4,   
         tractorprofile.trc_company,   
         tractorprofile.trc_division,   
         tractorprofile.trc_fleet,   
         tractorprofile.trc_terminal,   
         tractorprofile.trc_grosswgt,   
         tractorprofile.trc_axles,   
         tractorprofile.trc_status,   
         tractorprofile.trc_make,   
         tractorprofile.trc_model,   
         tractorprofile.trc_avl_date,   
         tractorprofile.trc_avl_cmp_id,   
         tractorprofile.trc_avl_city,   
         tractorprofile.trc_avl_status,   
         tractorprofile.trc_pln_date,   
         tractorprofile.trc_pln_cmp_id,   
         tractorprofile.trc_pln_city,   
         tractorprofile.trc_driver,   
         a.cty_nmstct,   
         a.cty_state,
	 a.cty_name,   
         isnull(c.cmp_zip,a.cty_zip),   
         a.cty_region1,   
         a.cty_region2,   
         a.cty_region3,   
         a.cty_region4, 
	 			 case @city_latlong_units when 'S' then a.cty_latitude / 3600.0 else a.cty_latitude end,
	 			 case @city_latlong_units when 'S' then a.cty_longitude / 3600.0 else a.cty_longitude end,  
         tractorprofile.trc_enginemake,   
         tractorprofile.trc_enginemodel,   
         tractorprofile.trc_engineserial,   
         tractorprofile.trc_serial,   
         tractorprofile.trc_licstate,   
         tractorprofile.trc_licnum,
	 trc_gps_desc,
	 trc_gps_date,
         100000 ,
	 cmp_latseconds,
	 cmp_longseconds,
	 tractorprofile.trc_misc2,

	 --vmj1+	PTS 16869	02/13/2003	Old code wasn't returning the correct refusal 
	 --count..
	 0,
--	 (SELECT count(*) 
--		FROM		preplan_assets
--		WHERE		ppa_tractor = tractorprofile.trc_number AND
--				ppa_status = 'Refused' AND
--				ppa_createdon between DateAdd(dd, (select -1*(gi_string1)
--								from generalinfo
--								where gi_name = 'MAXREFDAYS'), getdate()) and getdate()),
	 --vmj1-

	 (SELECT count(*) 
		FROM		preplan_assets
		WHERE		ppa_tractor = tractorprofile.trc_number AND
				ppa_status = 'No Response' AND
				ppa_createdon between DateAdd(dd, (select -1*(gi_string1)
								from generalinfo
								where gi_name = 'MAXDNRDAYS'), getdate()) and getdate()),
	'',
	tractorprofile.trc_note_date,
	tractorprofile.trc_alert_date
	, at_home = 
	case 
		when mpp_city = trc_avl_city and trc_status = 'avl' then 'At Home' else ''
	end
	, (SELECT gi_integer1 FROM generalinfo WHERE gi_name = 'MAXREFCOUNT')

FROM  tractorprofile  LEFT OUTER JOIN  manpowerprofile ON  tractorprofile.trc_driver  = manpowerprofile.mpp_id ,
	 city a,
	 company c 
WHERE	 tractorprofile.trc_avl_city  = a.cty_code
 AND	c.cmp_id  = tractorprofile.trc_avl_cmp_id
 AND	tractorprofile.trc_status  <> 'OUT'

update #temp set distance = 100000 where distance is null

update #temp 
set ord_number =
	(select IsNull (max(ord_number),'No Load')
	 FROM	orderheader, stops
	 WHERE	#temp.trc_pln_lgh = stops.lgh_number
	  AND 	orderheader.mov_number = stops.mov_number)


--vmj1+	Use a separate select & update to update #temp with refusal counts..
select	@li_MaxRefDays = gi_string1
  from	generalinfo
  where	gi_name = 'MAXREFDAYS'
select	@ldt_begin_range = DateAdd(dd, -1 * @li_MaxRefDays, getdate())

insert into #trc_ref
  select t.trc_number
		,count(*)
  from	#temp t
		,preplan_assets p
  where	p.ppa_tractor = t.trc_number
	and	p.ppa_status = 'Refused' 
	and	p.ppa_createdon between @ldt_begin_range and getdate()
  group by t.trc_number

update	#temp
  set	refusal_count = tr.ref_count
  from	#temp t
		,#trc_ref tr
  where	tr.trc_number = t.trc_number

select * from #temp  
where trc_avl_cmp_id <> 'UNKNOWN' OR dest_zip is NOT null OR trc_avl_city > 0
GO
GRANT EXECUTE ON  [dbo].[d_cur_avl_tractor_sp] TO [public]
GO
