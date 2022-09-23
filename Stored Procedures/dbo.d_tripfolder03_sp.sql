SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [dbo].[d_tripfolder03_sp]
	@mov_number integer 
as
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
	dpete pts 10775 ad cht_basisunit ro return set, part of rating in VisDisp. 6/11/01
	dpete pts9647 add tariff fields to freightdetail return set to record what tariff applied when pre rating by detail
	dpete pts12066 bring back fgt_ratingquantity and fgt_ratingunit
	DPETE 12/3/01 PTS12523 allow fixing rate
	DPETE PTS12599 add cmp_geoloc 12/13/01
	JET PTS 16016, added stp_country 11/18/2002
	MBR PTS16217 Added and (evt_sequence = 1 or fgt_sequence = 1) to where clause
	DPETE 18410 add lgh_comment to return set
	DPETE 22760 add scm_subcode and cpr_density
 * 11/07/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

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
         freightdetail.fgt_sequence, 
         freightdetail.fgt_number, 
         freightdetail.cmd_code, 
         freightdetail.fgt_description cmd_description, 
         freightdetail.fgt_weight weight, 
         freightdetail.fgt_weightunit weightunit, 
         freightdetail.fgt_count cnt, 
         freightdetail.fgt_countunit countunit, 
         freightdetail.fgt_volume volume, 
         freightdetail.fgt_volumeunit volumeunit,
         freightdetail.fgt_quantity quantity, 
         freightdetail.fgt_unit quantityunit, 
         freightdetail.fgt_reftype, 
         freightdetail.fgt_refnum, 
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
         0 fgt_refnumcount,
         0 ord_refnumcount, 
         stops.stp_loadstatus, 
         0 notes_count,
         eventcodetable.mile_typ_to_stop to_miletype,
         eventcodetable.mile_typ_from_stop from_miletype,
         freightdetail.tare_weight, 
         freightdetail.tare_weightunit,
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
         freightdetail.fgt_pallets_in, 
         freightdetail.fgt_pallets_out, 
         freightdetail.fgt_pallets_on_trailer, 
         freightdetail.fgt_carryins1, 
         freightdetail.fgt_carryins2, 
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
         freightdetail.fgt_length,
         freightdetail.fgt_width,
         freightdetail.fgt_height,
         freightdetail.fgt_stackable,
         stops.stp_podname,
         legheader.lgh_feetavailable,
         stops.stp_cmp_close,
         stops.stp_departure_status,
         freightdetail.fgt_ordered_count,
         freightdetail.fgt_ordered_weight,
         stops.stp_activitystart_dt,
         stops.stp_activityend_dt,
         stops.stp_eta,
         stops.stp_etd,
         freightdetail.fgt_rate,
         freightdetail.fgt_charge,
         freightdetail.fgt_rateunit,
         freightdetail.cht_itemcode,
         stops.stp_transfer_type,
         freightdetail.cht_basisunit,
         ISNULL(freightdetail.fgt_quantity_type, 0),
         ISNULL(freightdetail.fgt_charge_type, 0),
         freightdetail.tar_number,
         freightdetail.tar_tariffnumber,
         freightdetail.tar_tariffitem,
         ISNULL(freightdetail.fgt_ratingquantity,fgt_quantity),
         ISNULL(freightdetail.fgt_ratingunit,fgt_unit),
         0 inv_protect,
         ISNULL(freightdetail.fgt_rate_type,0),
         cmp_geoloc = (SELECT ISNULL(cmp_geoloc,'') From company Where company.cmp_id = stops.cmp_id),
         lgh_type2,
         'LghType2' lgh_type2_t,
         stops.psh_number,
         stops.stp_advreturnempty, 
         stops.stp_country,
	 freightdetail.fgt_loadingmeters loadingmeters,
	 freightdetail.fgt_loadingmetersunit loadingmetersunit,
         fgt_additionl_description,
	 stops.stp_cod_amount,
	 stops.stp_cod_currency,
	 freightdetail.fgt_specific_flashpoint,
	 freightdetail.fgt_specific_flashpoint_unit,
	 freightdetail.fgt_ordered_volume,
         freightdetail.fgt_ordered_loadingmeters,
         freightdetail.fgt_pallet_type,
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
-- PTS 19228 -- BL (start)
	 stops.stp_reasonlate_text,
	 stops.stp_reasonlate_depart_text
-- PTS 19228 -- BL (end)
	,cpr_density 
	,scm_subcode,
	 stops.nlm_time_diff, 
-- JET - PTS 24078 - 8/31/2004, return the routed mileage type
	 stops.stp_lgh_mileage_mtid 
-- PTS 24527 -- DPM (start)
	,freightdetail.fgt_consignee, 
	 freightdetail.fgt_shipper, 
	 freightdetail.fgt_leg_origin, 
	 freightdetail.fgt_leg_dest,
	 freightdetail.fgt_bolid, 
	 freightdetail.fgt_count2, 
	 freightdetail.fgt_count2unit,
	 freightdetail.fgt_terms
-- PTS 24527 -- DPM (end)
-- PTS 21014 -- DPM (start)
	,fgt_bol_status
-- PTS 21014 -- DPM (end)
	,0 inv_protect
	--pts40187 jguo outer join conversion
    FROM  stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code   
				LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number   
				LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber ,
	 event,
	 freightdetail,
	 eventcodetable 
   WHERE freightdetail.stp_number = stops.stp_number and  --pts40187 removed the outer join since it is not necessary any more
		stops.stp_number = event.stp_number and 
		event.evt_eventcode = eventcodetable.abbr and
        stops.mov_number = @mov_number and
		(evt_sequence = 1 or fgt_sequence = 1)
--   FROM city,
--	 legheader,
--	 event, 
--	 stops, 
--	 freightdetail,
--	 eventcodetable, 
--         orderheader
--   WHERE stops.stp_city *= city.cty_code and
--	 stops.lgh_number *= legheader.lgh_number and
--	 freightdetail.stp_number =* stops.stp_number and 
--               stops.stp_number = event.stp_number and 
--	 event.evt_eventcode = eventcodetable.abbr and
--               stops.mov_number = @mov_number and
--   	 stops.ord_hdrnumber *= orderheader.ord_hdrnumber and
--	 (evt_sequence = 1 or fgt_sequence = 1)

GO
GRANT EXECUTE ON  [dbo].[d_tripfolder03_sp] TO [public]
GO
