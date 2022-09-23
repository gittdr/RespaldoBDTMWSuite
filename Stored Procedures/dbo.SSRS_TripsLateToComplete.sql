SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE proc [dbo].[SSRS_TripsLateToComplete]

(@DaysBack int,
 @Company varchar(6),
 @TeamLeader varchar(6))

as

select case when ord_hdrnumber = 0 then 'M' + convert(varchar(10), mov_number) 
       else (select ord_number from orderheader with(NOLOCK)  where ord_hdrnumber = legheader_active.ord_hdrnumber) end 'order', 
       case when (len(lgh_tractor) > 0 and lgh_tractor = 'UNKNOWN') or lgh_tractor is null then '' when lgh_tractor is null then '' else lgh_tractor end 'tractor', 
       case when (len(evt_driver1_name) > 0 and evt_driver1_name = 'UNKNOWN') or evt_driver1_name is null then '' else evt_driver1_name end 'driver', 
       case when (len(lgh_carrier) > 0 and lgh_carrier = 'UNKNOWN') or lgh_carrier is null then '' 
            else (select car_name from carrier where car_id = lgh_carrier) end 'carrier', 
       case when (len(lgh_carrier) > 0 and lgh_carrier = 'UNKNOWN') or lgh_carrier is null then '' else lgh_carrier end 'Carrier Id',
       lgh_startdate as 'start date', 
       lgh_enddate as 'end date',  
       datediff(hh, lgh_enddate, getdate()) 'hours late',
       case when ord_hdrnumber = 0 then convert(varchar(8), lgh_startdate, 1)
       else (select convert(varchar(8), ord_origin_latestdate, 1) from orderheader with(NOLOCK)  where ord_hdrnumber = legheader_active.ord_hdrnumber) end 'latest start date', 
       case when ord_hdrnumber = 0 then convert(varchar(8), lgh_enddate, 1)
       else (select convert(varchar(8), ord_dest_latestdate, 1) from orderheader with(NOLOCK)  where ord_hdrnumber = legheader_active.ord_hdrnumber) end 'latest end date', 
       case lgh_outstatus when 'AVL' then 'Available' when 'PLN' then 'Planned' when  'DSP' then 'Planned' when 'STD' then 'Started' else lgh_outstatus end 'status',  lgh_startregion1 as 'Starting Region', 
	 mpp_teamleader as 'DrvMgrID',
    (select name from labelfile where abbr = mpp_teamleader and labeldefinition = 'TeamLeader') as [DrvMgr],
     ord_bookedby as 'Booked By',
		case when o_cmpname = 'UNKNOWN' then '' else o_cmpname end 'orig company', 
		case when lgh_startcity = 0 then '' when lgh_startcity is null then '' else (select cty_nmstct from city where cty_code = lgh_startcity) end 'orig city', 
		case when d_cmpname = 'UNKNOWN' then '' else d_cmpname end 'dest company', 
		case when lgh_endcity = 0 then '' when lgh_endcity is null then '' else (select cty_nmstct from city where cty_code = lgh_endcity) end 'dest city', 
		lgh_number 'trip segment'     
       ,ISNULL((select ord_revtype2 from orderheader  with(NOLOCK) where ord_hdrnumber = legheader_active.ord_hdrnumber),'') as [Agency]   
	   ,ISNULL((select name from labelfile with(NOLOCK)  where labeldefinition = 'RevType2' and abbr = (select ord_revtype2 from orderheader with(NOLOCK)  where ord_hdrnumber = legheader_active.ord_hdrnumber)),'') as [Agency Name]   
  
 from legheader_active  with(NOLOCK) 
 
 where lgh_outstatus in ('STD') 
 and lgh_enddate <= getdate() 
 and datediff(hh, lgh_enddate, getdate()) > @DaysBack
 and lgh_class1 = @Company
 and (mpp_teamleader = @TeamLeader or @TeamLeader = 'All')






GO
