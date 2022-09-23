SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE procedure [dbo].[d_tripsheetformat05_sp]
	@mov_number integer 
as

declare	@varchar100	varchar(100)

select @varchar100 = ''

  SELECT event.evt_driver1 driver1, 
         event.evt_driver2 driver2, 
         event.evt_tractor tractor, 
         event.evt_trailer1 trailer1, 
         event.evt_trailer2 trailer2, 
         stops.ord_hdrnumber, 
         stops.stp_number, 
         stops.stp_city stp_city, 
         event.evt_startdate arrivaldate, 
         event.evt_earlydate earliestdate, 
         event.evt_latedate latestdate, 
         stops.cmp_id, 
         stops.cmp_name, 
         evt_enddate departuredate, 
         stops.stp_reasonlate reasonlate_arrival, 
         stops.lgh_number, 
         stops.stp_reasonlate_depart reasonlate_depart, 
         stops.stp_sequence, 
         stops.stp_comment comment, 
         event.evt_hubmiles hubmiles, 
         orderheader.ord_refnum, 
         event.evt_carrier carrier, 
         orderheader.ord_reftype, 
         event.evt_sequence, 
         stops.stp_mfh_sequence mfh_sequence, 
         orderheader.ord_billto customer,   
         event.evt_number, 
         event.evt_pu_dr evt_pu_dr, 
         event.evt_eventcode eventcode, 
         event.evt_status evt_status, 
         stops.stp_mfh_mileage mfh_mileage, 
         stops.stp_ord_mileage ord_mileage, 
         stops.stp_lgh_mileage lgh_mileage, 
         stops.mfh_number, 
 	 (select cmp_name
	  from company
	  where company.cmp_id = orderheader.ord_billto) billto_name,
         city.cty_nmstct cty_nmstct, 
	 @mov_number mov_number, 
         stops.stp_origschdt, 
         stops.stp_paylegpt, 
         stops.stp_region1, 
         stops.stp_region2, 
         stops.stp_region3, 
         stops.stp_region4, 
         stops.stp_state ,
         1 skip_trigger,
         lgh_outstatus,
         0 user0,
         stops.stp_reftype,
         stops.stp_refnum, 
         ' ' user1,  
         ' ' user2,
         ' ' user3,
         0 stp_refnumcount,
         0 ord_refnumcount, 
         stops.stp_loadstatus, 
         0 notes_count,
         eventcodetable.mile_typ_to_stop to_miletype,
         eventcodetable.mile_typ_from_stop from_miletype,
         lgh_type1,
         'LghType1' lgh_type1_t, 
         stops.stp_type1, 
         stops.stp_redeliver, 
         stops.stp_osd, 
         stops.stp_pudelpref, 
         orderheader.ord_company, 
         stops.stp_phonenumber, 
         stops.stp_delayhours, 
         stops.stp_ooa_mileage, 
         stops.stp_zipcode, 
         stops.stp_OOA_stop, 
         stops.stp_address, 
         stops.stp_transfer_stp, 
         stops.stp_contact, 
         stops.stp_phonenumber2, 
         stops.stp_address2, 
         CASE stops.ord_hdrnumber 
             WHEN 0 THEN 0
             WHEN NULL THEN 0
             ELSE 1
         END billable_flag, 
         ord_revtype1, 
         ord_revtype2, 
         ord_revtype3, 
         ord_revtype4, 
         'RevType1' ord_revtype1_t, 
         'RevType2' ord_revtype2_t, 
         'RevType3' ord_revtype3_t, 
         'RevType4' ord_revtype4_t,
         stops.stp_custpickupdate,
         stops.stp_custdeliverydate,
         legheader.lgh_dispatchdate,
         stops.stp_podname,
         legheader.lgh_feetavailable,
         stops.stp_cmp_close,
         stops.stp_departure_status,
         stops.stp_activitystart_dt,
         stops.stp_activityend_dt,
         stops.stp_eta,
         stops.stp_etd,
         stops.stp_transfer_type,
         0 inv_protect,
         cmp_geoloc = (SELECT ISNULL(cmp_geoloc,'') From company Where company.cmp_id = stops.cmp_id),
         lgh_type2,
         'LghType2' lgh_type2_t,
         stops.psh_number,
         stops.stp_advreturnempty, 
         stops.stp_country,
	 stops.stp_cod_amount,
	 stops.stp_cod_currency,
	 orderheader.ord_tareweight act_weight,
	 orderheader.ord_totalweight est_weight,
	 lgh_comment, 
	 legheader.lgh_reftype,
	 legheader.lgh_refnum,
	 0 lgh_refnumcount,
	 case stp_type
		when 'PUP' then
		 ISNULL(
			ISNULL(
				stops.stp_alloweddet, 
				ISNULL(
					(SELECT MIN(cmp_puptimeallowance) 
						FROM company, orderheader o1
						where o1.ord_billto = company.cmp_id 
						and o1.ord_hdrnumber = stops.ord_hdrnumber
						and cmp_puptimeallowance is not null), 
					(SELECT cmp_puptimeallowance 
						FROM company WHERE company.cmp_id = stops.cmp_id))
				),
			0)
		else
		 ISNULL(
			ISNULL(
				stops.stp_alloweddet, 
				ISNULL(
					(SELECT MIN(cmp_drptimeallowance) 
						FROM company, orderheader o1
						where o1.ord_billto = company.cmp_id 
						and o1.ord_hdrnumber = stops.ord_hdrnumber
						and cmp_drptimeallowance is not null), 
					(SELECT cmp_drptimeallowance 
						FROM company WHERE company.cmp_id = stops.cmp_id))
				),
			0)
	 end stp_alloweddet,
	 Case IsNull(stops.stp_gfc_arr_radius, 0)
		When 0 then (select gfc_auto_radius
					FROM geofence_defaults
					WHERE gfc_auto_cmp_id = 'UNKNOWN' AND
							gfc_auto_evt = 'ALL' AND
							gfc_auto_type = 'ARVING')
		Else stops.stp_gfc_arr_radius
	 End,
	 Case IsNull(stops.stp_gfc_arr_radiusunits, '')
		When '' then (select gfc_auto_radiusunits
					FROM geofence_defaults
					WHERE gfc_auto_cmp_id = 'UNKNOWN' AND
							gfc_auto_evt = 'ALL' AND
							gfc_auto_type = 'ARVING')
		Else stops.stp_gfc_arr_radiusunits
	 End,
	 Case IsNull(stops.stp_gfc_arr_timeout, 0)
		When 0 then (select gfc_auto_timeout
					FROM geofence_defaults
					WHERE gfc_auto_cmp_id = 'UNKNOWN' AND
							gfc_auto_evt = 'ALL' AND
							gfc_auto_type = 'ARVING')
		Else stops.stp_gfc_arr_timeout
	 End,
	 stops.stp_tmstatus,
	 (SELECT ISNULL(mpp_lastfirst, ' ') FROM manpowerprofile WHERE mpp_id = evt_driver1) Driver1name,
	 (SELECT ISNULL(mpp_lastfirst, ' ') FROm manpowerprofile WHERE mpp_id = evt_driver2) Driver2name,
	 stops.stp_reasonlate_text,
	 stops.stp_reasonlate_depart_text,
		stops.nlm_time_diff, 
		stops.stp_lgh_mileage_mtid 
		,stp_ord_mileage_mtid = IsNull(stops.stp_ord_mileage_mtid,0)
		,stp_ooa_mileage_mtid = IsNull(stops.stp_ooa_mileage_mtid,0),
		eventcodetable.fgt_event,
		eventcodetable.name event_name,
		IsNull(ord_consignee, ''),
		IsNull(ord_showcons, ''),
		@varchar100 list_orders,
		ord_number,
		cmp_directions

    FROM stops
    join event on stops.stp_number = event.stp_number and evt_sequence = 1
    join eventcodetable on event.evt_eventcode = eventcodetable.abbr
    join company on stops.cmp_id = company.cmp_id
    left outer join city on stops.stp_city = city.cty_code
    left outer join legheader on stops.lgh_number = legheader.lgh_number
    left outer join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
    WHERE stops.mov_number = @mov_number 
/*
    FROM city,
	 legheader,
	 event, 
	 stops, 
	 eventcodetable, 
    orderheader,
	 company
   WHERE stops.stp_city *= city.cty_code and
	 stops.lgh_number *= legheader.lgh_number and
               stops.stp_number = event.stp_number and 
	 event.evt_eventcode = eventcodetable.abbr and
               stops.mov_number = @mov_number and
   	 stops.ord_hdrnumber *= orderheader.ord_hdrnumber and
	 (evt_sequence = 1) and
	stops.cmp_id = company.cmp_id
*/
GO
GRANT EXECUTE ON  [dbo].[d_tripsheetformat05_sp] TO [public]
GO
