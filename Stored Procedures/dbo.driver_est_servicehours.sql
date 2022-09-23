SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


Create Procedure [dbo].[driver_est_servicehours] 
	@lgh_number	integer,
	@driver	varchar(12)
as

/*	
*	PTS 44736 - DJM - 10/10/2008 - If the Driver passed in is not currently assigned to the Trip Segment, retrieve the Trip Segment information.	
*/

declare @test_startdate		datetime,
	@servicerule				varchar(7),
	@serviceruledays			int,
	@servicerulehours			int,
	@mph						int

select @test_startdate = lgh_startdate from legheader where lgh_number = @lgh_number

select @mph = isNull(gi_integer1,45) from Generalinfo where gi_name = 'EstDriverHoursWindowMPH'
select @mph = isNull(@mph,45)

Declare @tlghlist Table(
	lgh_number		int		not null,
	lgh_outstatus	varchar(6)	null,
	lgh_startdate	datetime	null,
	lgh_driver		varchar(12))

/* 
Insert all the Trips to which the Driver is assigned between his last started or completed trip and the requested trip
*/
insert into @tlghlist
select lgh_number, lgh_outstatus, l1.lgh_startdate, lgh_driver1
from legheader l1,
	(select max(lgh_startdate) lgh_startdate
	from legheader l
	where lgh_outstatus in ('CMP','STD')
		and exists (select 1 from assetassignment a
						where a.lgh_number = l.lgh_number
							and a.asgn_type = 'DRV'
							and a.asgn_id = @driver)) lgh_start
where l1.lgh_startdate >= lgh_start.lgh_startdate
	and l1.lgh_startdate <= @test_startdate
	and exists (select 1 from assetassignment a
						where a.lgh_number = l1.lgh_number
							and a.asgn_type = 'DRV'
							and a.asgn_id = @driver)
/*
	PTS 44736 - Insert the data for the Requested trip if it's not already in the list of trips (ie - the driver isn't already planned on the trip)
*/
if not exists (select 1 from @tlghlist where lgh_number = @lgh_number) 
	insert into @tlghlist
	select lgh_number, lgh_outstatus, l1.lgh_startdate, lgh_driver1
	from legheader l1,
		(select max(lgh_startdate) lgh_startdate
		from legheader l
		where lgh_outstatus in ('CMP','STD')
			and exists (select 1 from assetassignment a
							where a.lgh_number = l.lgh_number
								and a.asgn_type = 'DRV'
								and a.asgn_id = @driver)) lgh_start
	where l1.lgh_startdate >= lgh_start.lgh_startdate
		and l1.lgh_number = @lgh_number 


/* Determine the correct amount of time to use for calculating Hours overage in a week	*/
select @servicerule = LTrim(mpp_servicerule) from manpowerprofile where mpp_id = @driver
select @serviceruledays = cast(left(@servicerule,1) as Int)
select @servicerulehours = cast(substring(@servicerule,charindex('/',@servicerule)+1, 2) as int)

--Print 'charindex value: ' + cast(charindex('/',@servicerule) as varchar(8))
--Print 'Servicerule: ' + @servicerule
--
--Print 'Servicerule Days: ' + cast(@serviceruledays as varchar(8))
--Print 'Servicerule Hours: ' + cast(@servicerulehours as varchar(8))

select 	s.lgh_number,
              s.stp_reasonlate_depart_min,
              s.stp_reasonlate_min,
              s.stp_GeoCodeRequested,
              s.stp_dispatched_status,
              s.stp_transferred,
              s.stp_unload_paytype,
              s.last_updatedatedepart,              
              s.last_updatebydepart,              
              s.stp_ooa_mileage_mtid,
              s.stp_ord_mileage_mtid,
              s.last_updatedate,              
              s.last_updateby,
              s.stp_ord_toll_cost,
              s.stp_countunit2,              
              s.stp_count2,
              s.stp_lgh_mileage_mtid,
              s.nlm_time_diff,
              s.stp_est_activity,
              s.stp_est_drv_time,
              s.stp_reasonlate_depart_text,
              s.stp_reasonlate_text,
              s.stp_tmstatus,
              s.stp_gfc_arr_timeout,
              s.stp_gfc_arr_radiusunits,
              s.stp_gfc_arr_radius,
              s.stp_detstatus,
              s.stp_alloweddet,
              s.stp_extra_weight,
              s.stp_extra_count,
              s.stp_cod_currency,
              s.stp_cod_amount,
              s.stp_loadingmetersunit,
              s.stp_loadingmeters,
              s.stp_country,
              s.stp_advreturnempty,
              s.psh_number,
              s.stp_pallets_rejected,
              s.stp_pallets_shipped,
              s.stp_pallets_received,
              s.stp_pallets_out,
              s.stp_pallets_in,
              s.tmp_fgt_number,
              s.tmp_evt_number,
              s.stp_stl_mileage_flag,
              s.stp_trip_mileage,
              s.stp_transfer_type,
              s.stp_etd,
              s.stp_eta,
              s.stp_departure_status,
              s.stp_activityend_dt,
              s.stp_activitystart_dt,
              s.stp_cmp_close,
              s.stp_podname,
              s.stp_custdeliverydate,
              s.stp_custpickupdate,
              s.stp_contact,
              s.stp_address2,
              s.stp_phonenumber2,
              s.stp_transfer_stp,
              s.stp_address,
              s.stp_OOA_stop,
              s.stp_zipcode,
              s.stp_ooa_mileage,
              s.stp_delayhours,
              s.stp_phonenumber,              
              s.stp_pudelpref,
              s.stp_osd,
              s.stp_redeliver,
              s.stp_type1,
              s.stp_dep_confirmed,
              s.stp_arr_confirmed,
              s.stp_dispatched_sequence,
              s.stp_volumeunit,
              s.stp_volume,
              s.skip_trigger,
              s.stp_screenmode,
              s.stp_reasonlate_depart,
              s.stp_refnum,
              s.stp_reftype,
              s.stp_status,
              s.stp_comment,
              s.cmp_name,
              s.stp_countunit,
              s.stp_count,
              s.stp_description,
              s.cmd_code,
              s.stp_weightunit,
              s.stp_weight,
              s.stp_loadstatus,
              s.mov_number,
              isNull(s.stp_mfh_mileage,0) stp_mfh_mileage,
              isNull(s.stp_lgh_mileage,0) stp_lgh_mileage,
              isNull(s.stp_ord_mileage, 0) stp_ord_mileage,
              s.stp_lgh_status,
              s.stp_mfh_status,
              s.stp_lgh_position,
              s.stp_mfh_position,
              s.stp_event,
              s.stp_mfh_sequence,
              s.trl_id,
              s.stp_lgh_sequence,
              s.stp_region4,
              s.stp_sequence,
              s.shp_hdrnumber,
              s.stp_paylegpt,
              s.stp_type,
              s.mfh_number,
              s.stp_schdtlatest,
              s.stp_reasonlate,
              s.stp_departuredate,
              s.stp_arrivaldate,
              s.stp_origschdt,
              s.stp_schdtearliest,
              s.stp_state,
              s.stp_city,
              s.stp_region3,
              s.stp_region2,
              s.stp_region1,
              s.cmp_id,
              s.stp_number,
              s.ord_hdrnumber,
			  1 'actual_trip',
			  isNull(ord_number,'(None)') ord_number,
			  (select isNull(c.cty_nmstct,'UNKNOWN') from city c where c.cty_code = s.stp_city) cty_nmstct,
			  e.evt_tractor,
			  cast(trc.trc_mpg as decimal(2)) trc_mpg,
			  0 'travel_minutes',
			  e.evt_trailer1,
			  e.evt_trailer2,
			  e.evt_driver1,
			  @mph mph,
			  0 daily_log_hrs,
			  0 daily_hrs_left,
			  0 weekly_hrs_left,
			  cast('1900-01-01' as datetime) est_hrs_compute_date,
			  (select isNull(on_duty_hrs,0) from log_driverlogs where mpp_id = e.evt_driver1 and 1=2) old_log_hrs,
			  0 stp_reset_periods,
			  0 stp_delay_hrs,
			  s.stp_arrivaldate est_stp_arrivaldate,
			  s.stp_departuredate est_stp_departuredate,
			  0 est_stp_daily_hrs,
			  0 est_stp_weekly_hrs,
			  0 stp_drive_time,
			  @servicerulehours service_rule_hrs,
			  0 stp_daycount,
			  0 est_transit_time,
			  0 est_trip_transit_time,
			  @serviceruledays service_rule_days
Into #driver_trips
from stops s inner join @tlghlist t on s.lgh_number = t.lgh_number
	inner join event e on s.stp_number = e.stp_number and e.evt_sequence = 1
	left outer join orderheader o on s.ord_hdrnumber = o.ord_hdrnumber
	left outer join tractorprofile trc on e.evt_tractor = trc.trc_number
where e.evt_driver1 = t.lgh_driver
Order By stp_arrivaldate, s.lgh_number


-- Update the field holding the 'old' log hours that should drop off for the week
--		ensure that only one record in the table is updated for each individual day (since that is how hours are logged)
--update #driver_trips
--set old_log_hrs = isNull((select sum(isNull(on_duty_hrs,0)) 
--					from log_driverlogs 
--					where mpp_id = #driver_trips.evt_driver1 
--						and (log_date > convert(datetime, Convert(varchar(30), dateadd(dd, -@serviceruledays, dt2.stp_arrivaldate), 110), 110) 
--							and log_date <= convert(datetime, Convert(varchar(30), dateadd(dd, -@serviceruledays, #driver_trips.stp_arrivaldate), 110), 110))
--						OR (convert(datetime, Convert(varchar(30), dt2.stp_arrivaldate,110), 110) = convert(datetime, Convert(varchar(30), #driver_trips.stp_arrivaldate,110), 110)
--							and log_date = convert(datetime, Convert(varchar(30), dateadd(dd, -@serviceruledays, #driver_trips.stp_arrivaldate), 110), 110))),0)
--from #driver_trips,
--	(select isNull(stp_arrivaldate, cast('1900-01-01' as datetime)) stp_arrivaldate from #driver_trips ) dt2
--where #driver_trips.stp_arrivaldate = (select max(dt1.stp_arrivaldate) from #driver_trips dt1 
--								where convert(datetime, Convert(varchar(30), dt1.stp_arrivaldate,110),110) =  convert(datetime, Convert(varchar(30), #driver_trips.stp_arrivaldate,110),110))
--	and dt2.stp_arrivaldate  = (select max(dt1.stp_arrivaldate) from #driver_trips dt1 
--								where dt1.stp_arrivaldate <  #driver_trips.stp_arrivaldate)

update #driver_trips
set old_log_hrs = isNull((select sum(isNull(on_duty_hrs,0)) 
					from log_driverlogs 
					where mpp_id = #driver_trips.evt_driver1 
						and (log_date > convert(datetime, Convert(varchar(30), dateadd(dd, -@serviceruledays, dt2.stp_arrivaldate), 110), 110) 
							and log_date <= convert(datetime, Convert(varchar(30), dateadd(dd, -@serviceruledays, #driver_trips.stp_arrivaldate), 110), 110))
						OR (convert(datetime, Convert(varchar(30), isNull(dt2.stp_arrivaldate,DateAdd(mi, -1, #driver_trips.stp_arrivaldate)),110), 110) = convert(datetime, Convert(varchar(30), #driver_trips.stp_arrivaldate,110), 110)
							and log_date = convert(datetime, Convert(varchar(30), dateadd(dd, -@serviceruledays, #driver_trips.stp_arrivaldate), 110), 110))),0)
from #driver_trips left join (select isNull(stp_arrivaldate, cast('1900-01-01' as datetime)) stp_arrivaldate from #driver_trips ) dt2
	on dt2.stp_arrivaldate  = (select isNull(max(dt1.stp_arrivaldate),DateAdd(mm, -1, #driver_trips.stp_arrivaldate))  from #driver_trips dt1 
								where convert(datetime, Convert(varchar(30), dt1.stp_arrivaldate,110),110) <  convert(datetime, Convert(varchar(30), #driver_trips.stp_arrivaldate,110),110))
where #driver_trips.stp_arrivaldate = (select min(dt3.stp_arrivaldate) from #driver_trips dt3 
								where convert(datetime, Convert(varchar(30), dt3.stp_arrivaldate,110),110) =  convert(datetime, Convert(varchar(30), #driver_trips.stp_arrivaldate,110),110))



select 	lgh_number,
  stp_reasonlate_depart_min,
  stp_reasonlate_min,
  stp_GeoCodeRequested,
  stp_dispatched_status,
  stp_transferred,
  stp_unload_paytype,
  last_updatedatedepart,              
  last_updatebydepart,              
  stp_ooa_mileage_mtid,
  stp_ord_mileage_mtid,
  last_updatedate,              
  last_updateby,
  stp_ord_toll_cost,
  stp_countunit2,              
  stp_count2,
  stp_lgh_mileage_mtid,
  nlm_time_diff,
  stp_est_activity,
  stp_est_drv_time,
  stp_reasonlate_depart_text,
  stp_reasonlate_text,
  stp_tmstatus,
  stp_gfc_arr_timeout,
  stp_gfc_arr_radiusunits,
  stp_gfc_arr_radius,
  stp_detstatus,
  stp_alloweddet,
  stp_extra_weight,
  stp_extra_count,
  stp_cod_currency,
  stp_cod_amount,
  stp_loadingmetersunit,
  stp_loadingmeters,
  stp_country,
  stp_advreturnempty,
  psh_number,
  stp_pallets_rejected,
  stp_pallets_shipped,
  stp_pallets_received,
  stp_pallets_out,
  stp_pallets_in,
  tmp_fgt_number,
  tmp_evt_number,
  stp_stl_mileage_flag,
  stp_trip_mileage,
  stp_transfer_type,
  stp_etd,
  stp_eta,
  stp_departure_status,
  stp_activityend_dt,
  stp_activitystart_dt,
  stp_cmp_close,
  stp_podname,
  stp_custdeliverydate,
  stp_custpickupdate,
  stp_contact,
  stp_address2,
  stp_phonenumber2,
  stp_transfer_stp,
  stp_address,
  stp_OOA_stop,
  stp_zipcode,
  stp_ooa_mileage,
  stp_delayhours,
  stp_phonenumber,              
  stp_pudelpref,
  stp_osd,
  stp_redeliver,
  stp_type1,
  stp_dep_confirmed,
  stp_arr_confirmed,
  stp_dispatched_sequence,
  stp_volumeunit,
  stp_volume,
  skip_trigger,
  stp_screenmode,
  stp_reasonlate_depart,
  stp_refnum,
  stp_reftype,
  stp_status,
  stp_comment,
  cmp_name,
  stp_countunit,
  stp_count,
  stp_description,
  cmd_code,
  stp_weightunit,
  stp_weight,
  stp_loadstatus,
  mov_number,
  isNull(stp_mfh_mileage,0) stp_mfh_mileage,
  isNull(stp_lgh_mileage,0) stp_lgh_mileage,
  isNull(stp_ord_mileage, 0) stp_ord_mileage,
  stp_lgh_status,
  stp_mfh_status,
  stp_lgh_position,
  stp_mfh_position,
  stp_event,
  stp_mfh_sequence,
  trl_id,
  stp_lgh_sequence,
  stp_region4,
  stp_sequence,
  shp_hdrnumber,
  stp_paylegpt,
  stp_type,
  mfh_number,
  stp_schdtlatest,
  stp_reasonlate,
  stp_departuredate,
  stp_arrivaldate,
  stp_origschdt,
  stp_schdtearliest,
  stp_state,
  stp_city,
  stp_region3,
  stp_region2,
  stp_region1,
  cmp_id,
  stp_number,
  ord_hdrnumber,
  actual_trip,
  isNull(ord_number,'(None)') ord_number,
  cty_nmstct,
  evt_tractor,
  trc_mpg,
  travel_minutes,
  evt_trailer1,
  evt_trailer2,
  evt_driver1,
  mph,
  daily_log_hrs,
  daily_hrs_left,
  weekly_hrs_left,
  cast('1900-01-01' as datetime) est_hrs_compute_date,
  isNull(old_log_hrs,0),
  stp_reset_periods,
  stp_delay_hrs,
  stp_arrivaldate est_stp_arrivaldate,
  stp_departuredate est_stp_departuredate,
  est_stp_daily_hrs,
  est_stp_weekly_hrs,
  stp_drive_time,
  service_rule_hrs,
  stp_daycount,
  est_transit_time,
  est_trip_transit_time,
  service_rule_days
from #driver_trips
order by stp_arrivaldate, lgh_number 

GO
GRANT EXECUTE ON  [dbo].[driver_est_servicehours] TO [public]
GO
