SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[SSRS_TripsLateToComplete_BillTo]

(@DaysBack int,
 @Company varchar(6),
 @TeamLeader varchar(6),
 @BillTo varchar(8))

as

select case when ord_hdrnumber = 0 then 'M' + convert(varchar(10), mov_number) 
       else (select ord_number from orderheader where ord_hdrnumber = legheader_active.ord_hdrnumber) end 'order', 
       case when (len(lgh_tractor) > 0 and lgh_tractor = 'UNKNOWN') or lgh_tractor is null then '' when lgh_tractor is null then '' else lgh_tractor end 'tractor', 
       case when (len(evt_driver1_name) > 0 and evt_driver1_name = 'UNKNOWN') or evt_driver1_name is null then '' else evt_driver1_name end 'driver', 
       case when (len(lgh_carrier) > 0 and lgh_carrier = 'UNKNOWN') or lgh_carrier is null then '' 
            else (select car_name from carrier where car_id = lgh_carrier) end 'carrier', 
       lgh_startdate as 'start date', 
       lgh_enddate as 'end date',  
       lgh_schdtearliest as 'LegHdr earliest del date',
       lgh_schdtlatest as 'LegHdr latest del date' ,
       (select ord_dest_earliestdate from orderheader where 
            orderheader.ord_hdrnumber = legheader_active.ord_hdrnumber) 
                 as 'OrdHdr earliest dest date', 
       (select ord_dest_latestdate from orderheader where 
            orderheader.ord_hdrnumber = legheader_active.ord_hdrnumber) 
                 as 'OrdHdr latest dest date', 
       -- lgh_schdtearliest as 'earliest del date',
       -- lgh_schdtlatest as 'latest del date' ,
       datediff(hh, lgh_enddate, getdate()) 'hours late',
       case when ord_hdrnumber = 0 then convert(varchar(8), lgh_startdate, 1)
       else (select convert(varchar(8), ord_origin_latestdate, 1) from orderheader where ord_hdrnumber = legheader_active.ord_hdrnumber) end 'latest start date', 
       case when ord_hdrnumber = 0 then convert(varchar(8), lgh_enddate, 1)
       else (select convert(varchar(8), ord_dest_latestdate, 1) from orderheader where ord_hdrnumber = legheader_active.ord_hdrnumber) end 'latest end date', 
       case lgh_outstatus when 'AVL' then 'Available' when 'PLN' then 'Planned' when  'DSP' then 'Planned' when 'STD' then 'Started' else lgh_outstatus end 'status',  lgh_startregion1 as 'Starting Region', 
       isnull(ord_billto, 'UNKNOWN') as 'Bill To', 
       ---  jm ord_billto as 'Bill To', 
     mpp_teamleader as 'DrvMgrID',
    (select name from labelfile where abbr = mpp_teamleader and labeldefinition = 'TeamLeader') as [DrvMgr],     
       isnull(ord_bookedby, 'UNKNOWN') as 'Booked By',
       case when o_cmpname = 'UNKNOWN' then '' else o_cmpname end 'orig company', 
       case when lgh_startcity = 0 then '' when lgh_startcity is null then '' else (select cty_nmstct from city where cty_code = lgh_startcity) end 'orig city', 
       case when d_cmpname = 'UNKNOWN' then '' else d_cmpname end 'dest company', 
       case when lgh_endcity = 0 then '' when lgh_endcity is null then '' else (select cty_nmstct from city where cty_code = lgh_endcity) end 'dest city', 
      lgh_startstate as 'orig state',
     lgh_endstate as 'dest state',
     isnull ((select isnull(cty_name, ' ')
     from orderheader 
     join city on orderheader.ord_destcity = city.cty_code
     where ord_hdrnumber = legheader_active.ord_hdrnumber), ' ')  'OrdHdr Dest City', 
     isnull((select isnull(ord_deststate, ' ')
     from orderheader 
      where ord_hdrnumber = legheader_active.ord_hdrnumber), ' ')  'OrdHdr Dest State', 
       lgh_number 'trip segment' , 
       isnull((select isnull(cty_name, ' ')
     from orderheader(nolock) 
     join company on orderheader.ord_shipper = company.cmp_id
     join city on company.cmp_city = city.cty_code
     where ord_hdrnumber = legheader_active.ord_hdrnumber), ' ')  'Shipper City', 
     isnull((select isnull(cty_state, ' ')
     from orderheader(nolock) 
     join company on orderheader.ord_shipper = company.cmp_id
     join city on company.cmp_city = city.cty_code
     where ord_hdrnumber = legheader_active.ord_hdrnumber), ' ')  'Shipper State', 
       (select trc_gps_desc from TractorProfile where lgh_tractor = trc_number)  'GPS Desc' ,
       -- User only wants the Lat/Long information in ETA comment field 
       --isnull((select isnull( lgh_etacomment, ' ') from legheader (nolock) where legheader.lgh_number =   
       --legheader_active.lgh_number), ' ') 'ETA'  
       (select isnull(substring(lgh_etacomment,
                       charindex('Lat/Long',lgh_etacomment) ,
                       len(lgh_etacomment)),' ') as [ETA]
       from legheader
       where legheader.lgh_number = legheader_active.lgh_number ) 'ETA Lat/Long'
  from legheader_active(nolock) 
 where lgh_outstatus in ('STD') 
 and lgh_enddate <= getdate() 
 and datediff(hh, lgh_enddate, getdate()) > @DaysBack
 and lgh_class1 =  @Company
 and (ord_billto = @BillTo or @BillTo = 'All')


GO
