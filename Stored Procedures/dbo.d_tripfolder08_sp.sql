SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE procedure [dbo].[d_tripfolder08_sp]
	@mov_number integer
as
/**      
 *       
 * NAME:      
 * dbo.d_tripfolder08_sp 
 *      
 * TYPE:      
 * StoredProcedure      
 *      
 * DESCRIPTION:      
 * based on d_tripfolder_sp
 *      
 *            
 * RETURNS:      
 * no return code       
 *      
 * RESULT SETS:       
 *  see below   
 *      
 * PARAMETERS:      
 * 001 -  @mov_number
 *      
 * REFERENCES:      
 *       
 * REVISION HISTORY:      
 * 7/16/07 OS PTS 37540
 *     
 *      
 **/      

Declare @Service_revtype	varchar(10),
	@servicezone_labelname varchar(20),
	@servicecenter_labelname varchar(20),
	@serviceregion_labelname varchar(20),
	@sericearea_labelname varchar(20),
	@localization	char(1),
	@lgh_permit_status varchar(20)


/* PTS 26791 - DJM - Display the Localization profiles for Eagle Global on the Tripfolder.			*/
Select @service_revtype = Upper(LTRIM(RTRIM(isNull(gi_string1,'')))) from generalinfo where gi_name = 'ServiceRegionRevType'
select @servicezone_labelname =  ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceZone' )
select @servicecenter_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceCenter' )
select @serviceregion_labelname =  (SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceRegion' )
select @sericearea_labelname = ( SELECT TOP 1 userlabelname FROM labelfile WHERE labeldefinition = 'ServiceArea' )
select @lgh_permit_status = ( SELECT TOP 1 LGHPermitStatus FROM labelfile_headers)

/* PTS 26791 - DJM - Check setting used control use of the Localization values in the Planning 
	worksheet and Tripfolder. To eliminate potential performance issues for customers
	not using this feature - SQL 2000 ONLY
*/
select @localization = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'ServiceLocalization'


if Left(@localization,1) <> 'Y'
	Begin
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
			--PTS 37496 SGB 05/22/07 use stop status for stops and event status for events
			--stops.stp_departure_status,
			CASE EVT_Sequence 
				WHEN 1 THEN isnull(stops.stp_departure_status,'OPN')
				ELSE isnull(EVENT.evt_departure_status,'OPN')
			END, 
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
				ISNULL(
					stops.stp_alloweddet, 
					ISNULL(
						(SELECT MIN(cmp_PUPalert) 
							FROM company, orderheader o1
							where o1.ord_billto = company.cmp_id 
							and o1.ord_hdrnumber = stops.ord_hdrnumber
							and cmp_PUPalert is not null), 
						(SELECT cmp_PUPalert 
							FROM company WHERE company.cmp_id = stops.cmp_id))
					),
				(select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionPUPMinsAlert')),
				-1)
			else
			 ISNULL(
			 ISNULL(
				ISNULL(
					stops.stp_alloweddet, 
					ISNULL(
						(SELECT MIN(cmp_drpalert) 
							FROM company, orderheader o1
							where o1.ord_billto = company.cmp_id 
							and o1.ord_hdrnumber = stops.ord_hdrnumber
							and cmp_drpalert is not null), 
						(SELECT cmp_drpalert 
							FROM company WHERE company.cmp_id = stops.cmp_id))
					),
				(select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionDRPMinsAlert')),
				-1)
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
			,legheader.lgh_nexttrailer1
			,legheader.lgh_nexttrailer2
			,stops.stp_detstatus
			,stops.stp_est_drv_time
			,stops.stp_est_activity,
			-- PTS 26791 Begin
			'UNKNOWN' service_zone,
			'Service Zone' service_zone_t,
			'UNKNOWN' service_area,
			'Service Area' service_area_t,
			'UNKNOWN' service_center,
			'Service Center' service_center_t,
			'UNKNOWN' service_region,
			'Service Reqion' service_region_t
			-- PTS 26791 END
			,stp_mileage_mtid = IsNull(stops.stp_ord_mileage_mtid,0) -- RE - PTS #28205
			,stp_ooa_mileage_mtid = IsNull(stops.stp_ooa_mileage_mtid,0),
			lgh_route,
			lgh_booked_revtype1,
			'ExecutingTerminal' booked_revtype1_t,
			stops.last_updateby,
			stops.last_updatedate,
			ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,
			@lgh_permit_status lgh_permit_status_t,
			stops.last_updatebydepart,
			stops.last_updatedatedepart,
			freightdetail.fgt_osdreason,	   --AROSS PTS 27619
			freightdetail.fgt_osdquantity,
			freightdetail.fgt_osdunit,
			freightdetail.fgt_osdcomment,
			orderheader.ord_no_recalc_miles,
			legheader.lgh_204status,
			legheader.lgh_204date,	
			0 cmp_pri1now,
			0 cmp_pri1soon,
			0 cmp_pri2now,
			0 cmp_pri2soon,
			fgt_packageunit = ISNULL(freightdetail.fgt_packageunit, 'UNK'),
			stp_unload_paytype = ISNULL(stops.stp_unload_paytype, 'UNK'),
			stops.stp_transferred,
			legheader.lgh_type3,
			'LghType3' lgh_type3_t,
			legheader.lgh_type4,
			'LghType4' lgh_type4_t,
			'PackageUnits' fgt_packageunit_t,
			--PTS 32408 JJF 9/27/06
			event.evt_hubmiles_trailer1,
			event.evt_hubmiles_trailer2,
			--END PTS 32408 JJF 9/27/06
			--PTS 34405 JJF 10/31/06
			orderheader.ord_dest_zip,
			orderheader.ord_remark,
			ord_totalvolume,
			ord_totalvolumeunits,
			--PTS 34405 JJF 10/31/06
			stp_reasonlate_min,
			stp_reasonlate_depart_min,
			0 reasonlate_count,
			0 reasonlate_depart_count
		from stops left outer join city on stops.stp_city = city.cty_code
			left outer join legheader on stops.lgh_number = legheader.lgh_number
			left outer join freightdetail on freightdetail.stp_number = stops.stp_number
			join event on stops.stp_number = event.stp_number
			join eventcodetable on event.evt_eventcode = eventcodetable.abbr
			left outer join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber        
		WHERE stops.mov_number = @mov_number 
		and (evt_sequence = 1 or fgt_sequence = 1)

	End
else
	Begin

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
			--PTS 37496 SGB 05/22/07 use stop status for stops and event status for events
			--stops.stp_departure_status,
			CASE EVT_Sequence 
					WHEN 1 THEN isnull(stops.stp_departure_status,'OPN')
					ELSE isnull(EVENT.evt_departure_status,'OPN')
			END, 
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
				ISNULL(
					stops.stp_alloweddet, 
					ISNULL(
						(SELECT MIN(cmp_PUPalert) 
							FROM company, orderheader o1
							where o1.ord_billto = company.cmp_id 
							and o1.ord_hdrnumber = stops.ord_hdrnumber
							and cmp_PUPalert is not null), 
						(SELECT cmp_PUPalert 
							FROM company WHERE company.cmp_id = stops.cmp_id))
					),
				(select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionPUPMinsAlert')),
				-1)
			else
			 ISNULL(
			 ISNULL(
				ISNULL(
					stops.stp_alloweddet, 
					ISNULL(
						(SELECT MIN(cmp_drpalert) 
							FROM company, orderheader o1
							where o1.ord_billto = company.cmp_id 
							and o1.ord_hdrnumber = stops.ord_hdrnumber
							and cmp_drpalert is not null), 
						(SELECT cmp_drpalert 
							FROM company WHERE company.cmp_id = stops.cmp_id))
					),
				(select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionDRPMinsAlert')),
				-1)
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
			,legheader.lgh_nexttrailer1
			,legheader.lgh_nexttrailer2
			,stops.stp_detstatus
			,stops.stp_est_drv_time
			,stops.stp_est_activity,
			-- PTS 26791 Begin
			isNull((select cz_zone from cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip),'UNK') service_zone,
			@servicezone_labelname service_zone_t,
			isNull((select cz_area from cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip),'UNK') service_area,
			@sericearea_labelname service_area_t,
			isNull(Case isNull(@service_revtype,'UNKNOWN')
				when 'REVTYPE1' then
					(select max(svc_center) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
				when 'REVTYPE2' then
					(select max(svc_center) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
				when 'REVTYPE3' then
					(select max(svc_center) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
				when 'REVTYPE4' then
					(select max(svc_center) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
				else
				 	'UNKNOWN'
			End,'UNKNOWN') service_center,
			@servicecenter_labelname service_center_t,
			isNull(Case isNull(@service_revtype,'UNKNOWN')
				when 'REVTYPE1' then
					(select max(svc_region) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype1 = sc.svc_revcode)
				when 'REVTYPE2' then
					(select max(svc_region) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype2 = sc.svc_revcode)
				when 'REVTYPE3' then
					(select max(svc_region) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype3 = sc.svc_revcode)
				when 'REVTYPE4' then
					(select max(svc_region) from serviceregion sc, cityzip where city.cty_nmstct = cityzip.cty_nmstct and stops.stp_zipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND orderheader.ord_revtype4 = sc.svc_revcode)
				else 'UNKNOWN'
			End,'UNKNOWN') service_region,
			@serviceregion_labelname service_region_t
			-- PTS 26791 END
			,stp_ord_mileage_mtid = IsNull(stops.stp_ord_mileage_mtid,0) -- RE - PTS #28205
			,stp_ooa_mileage_mtid = IsNull(stops.stp_ooa_mileage_mtid,0),
			lgh_route,
			lgh_booked_revtype1,
			'ExecutingTerminal' booked_revtype1_t,
			stops.last_updateby,
			stops.last_updatedate,
			ISNULL(legheader.lgh_permit_status, 'UNK') lgh_permit_status,
			@lgh_permit_status lgh_permit_status_t,
			stops.last_updatebydepart,
			stops.last_updatedatedepart,
			freightdetail.fgt_osdreason,	   --AROSS PTS 27619
			freightdetail.fgt_osdquantity,
			freightdetail.fgt_osdunit,
			freightdetail.fgt_osdcomment,
			orderheader.ord_no_recalc_miles,
			legheader.lgh_204status,
			legheader.lgh_204date,
			0 cmp_pri1now,
			0 cmp_pri1soon,
			0 cmp_pri2now,
			0 cmp_pri2soon,
			fgt_packageunit = ISNULL(freightdetail.fgt_packageunit, 'UNK'),
			stp_unload_paytype = ISNULL(stops.stp_unload_paytype, 'UNK'),
			stops.stp_transferred,
			legheader.lgh_type3,
			'LghType3' lgh_type3_t,
			legheader.lgh_type4,
			'LghType4' lgh_type4_t,
			'PackageUnits' fgt_packageunit_t,
			--PTS 32408 JJF 9/27/06
			event.evt_hubmiles_trailer1,
			event.evt_hubmiles_trailer2,
			--END PTS 32408 JJF 9/27/06
			--PTS 34405 JJF 10/31/06
			orderheader.ord_dest_zip,
			orderheader.ord_remark,
			ord_totalvolume,
			ord_totalvolumeunits,
			--PTS 34405 JJF 10/31/06
			stp_reasonlate_min,
			stp_reasonlate_depart_min,
			0 reasonlate_count,
			0 reasonlate_depart_count
		from stops left outer join city on stops.stp_city = city.cty_code
			left outer join legheader on stops.lgh_number = legheader.lgh_number
			left outer join freightdetail on freightdetail.stp_number = stops.stp_number
			join event on stops.stp_number = event.stp_number
			join eventcodetable on event.evt_eventcode = eventcodetable.abbr
			left outer join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber       
		WHERE stops.mov_number = @mov_number 
		and (evt_sequence = 1 or fgt_sequence = 1)


	End
GO
GRANT EXECUTE ON  [dbo].[d_tripfolder08_sp] TO [public]
GO
