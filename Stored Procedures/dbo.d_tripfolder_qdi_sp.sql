SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE procedure [dbo].[d_tripfolder_qdi_sp] 	@mov_number integer 
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
 * 11/07/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

declare	@ord_revtype1	varchar(6)

select distinct ord_revtype1,
		ord_showshipper,
		ord_showcons,
		ord_bookdate,
		orderheader.cmd_code ord_cmd_code,
		ord_description,
		ord_shipper,
		ord_consignee,
		ord_origin_earliestdate,
		ord_dest_earliestdate,
		ord_totalweight, 
		ord_totalpieces, 
		ord_totalvolume, 
		ord_totalweightunits, 
		ord_totalcountunits, 
		ord_totalvolumeunits,
		ord_subcompany,
		convert(varchar(12), stops.ord_hdrnumber) s1_ord_hdrnumber
into #tmp
FROM stops LEFT OUTER JOIN orderheader ON stops.ord_hdrnumber = orderheader.ord_hdrnumber 
WHERE stops.mov_number = @mov_number and
	stops.ord_hdrnumber > 0

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
	 IsNull(orderheader.ord_revtype1, t.ord_revtype1) ord_revtype1, 
	 orderheader.ord_revtype2, 
         orderheader.ord_revtype3, 
         orderheader.ord_revtype4, 
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
         stops.stp_departure_status evt_departure_status,
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
         stops.stp_departure_status,
         stops.stp_transfer_type,
         0 inv_protect,
	IsNull(orderheader.ord_showshipper, t.ord_showshipper) ord_showshipper,
	IsNull(orderheader.ord_showcons, t.ord_showcons) ord_showcons,
	IsNull(orderheader.ord_bookdate, t.ord_bookdate) ord_bookdate,
	IsNull(orderheader.cmd_code, t.ord_cmd_code) ord_cmd_code,
	IsNull(orderheader.ord_description, t.ord_description) ord_description,
	IsNull(orderheader.ord_shipper, t.ord_shipper) ord_shipper,
	IsNull(orderheader.ord_consignee, t.ord_consignee) ord_consignee,
	IsNull(orderheader.ord_origin_earliestdate, t.ord_origin_earliestdate) ord_origin_earliestdate,
	IsNull(orderheader.ord_dest_earliestdate, t.ord_dest_earliestdate) ord_dest_earliestdate,
	IsNull(orderheader.ord_totalweight, t.ord_totalweight) ord_totalweight, 
	IsNull(orderheader.ord_totalweightunits, t.ord_totalweightunits) ord_totalweightunits,
	IsNull(orderheader.ord_totalpieces, t.ord_totalpieces) ord_totalpieces,
	IsNull(orderheader.ord_totalcountunits, t.ord_totalcountunits) ord_totalcountunits,
	IsNull(orderheader.ord_totalvolume, t.ord_totalvolume) ord_totalvolume,
	IsNull(orderheader.ord_totalvolumeunits, t.ord_totalvolumeunits) ord_totalvolumeunits,
	IsNull(orderheader.ord_subcompany, t.ord_subcompany) ord_subcompany,
	t.s1_ord_hdrnumber
	--pts40187 jguo outer join conversion
    FROM stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code   
		LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number   
		LEFT OUTER JOIN  freightdetail  ON  freightdetail.stp_number  = stops.stp_number   
		LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber ,
	 event,
	 eventcodetable,
	 #tmp t 
   WHERE 
	 --stops.stp_city *= city.cty_code and
	 --stops.lgh_number *= legheader.lgh_number and
	 --freightdetail.stp_number =* stops.stp_number and 
     stops.stp_number = event.stp_number and 
	 event.evt_eventcode = eventcodetable.abbr and
     stops.mov_number = @mov_number 
   	 --and stops.ord_hdrnumber *= orderheader.ord_hdrnumber
GO
GRANT EXECUTE ON  [dbo].[d_tripfolder_qdi_sp] TO [public]
GO
