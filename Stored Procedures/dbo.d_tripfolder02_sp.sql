SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [dbo].[d_tripfolder02_sp] @p_mov_number integer 
as
/*
 * 
 * NAME:d_tripfolder02_sp
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the trip information based on the mov number
 *
 * RETURNS:
 * 0  - uniqueness has not been violated 
 * >0 - uniqueness has been violated   
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_mov_number, int, input, null;
 *       mov number 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 - PTSnnnnn - AuthorName -Revision Description 
 *
 * dpete pts 10775 ad cht_basisunit ro return set, part of rating in VisDisp. 6/11/01
 * dpete pts9647 add tariff fields to freightdetail return set to record what tariff applied when pre rating by detail
 * dpete pts12066 bring back fgt_ratingquantity and fgt_ratingunit
 * DPETE 12/3/01 PTS12523 allow fixing rate
 * DPETE PTS12599 add cmp_geoloc 12/13/01
 * JET PTS 16016, added stp_country 11/18/2002
 * MBR PTS16217 Added and (evt_sequence = 1 or fgt_sequence = 1) to where clause
 * DPETE 18410 add lgh_comment to return set
 * DPETE 22760 add scm_subcode and cpr_density
 * ILB 24892 add code to print labefile descriptions 
 * 04/06/2006 - PTS 25129 - Imari Bremer - Create new masterbill format for Arrow Trucking
 **/
 


  DECLARE
  @v_maxseq int,
  @v_minname varchar(8),
  @v_minstp int,
  @v_ord_hdrnumber int,
  @v_fgt_length int,
  @v_fgt_width int,
  @v_fgt_height int

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
	 --PTS# 24892 ILB 10/06/04 
	 stops.stp_arrivaldate latestdate,
	 --event.evt_latedate latestdate, 
	 --PTS# 24892 ILB 10/06/04          
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
         isnull(freightdetail.fgt_weight,'') weight, 
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
	 @p_mov_number mov_number, 
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
          --PTS# 24892 ILB 10/06/04  
         l1.name ord_revtype1,
         --ord_revtype1, 
	 l2.name ord_revtype2, 
         --ord_revtype2,	 
         l3.name ord_revtype3,  
	 --ord_revtype3,	 
	 l4.name ord_revtype4, 
	 --ord_revtype4,	 
         isnull(l1.userlabelname + ':', 'RevType1:') ord_revtype1_t,
	 isnull(l2.userlabelname + ':', 'RevType2:') ord_revtype2_t,
	 isnull(l3.userlabelname + ':', 'RevType3:') ord_revtype3_t,
	 isnull(l4.userlabelname + ':', 'RevType4:') ord_revtype4_t,	  
	 --'RevType1' ord_revtype1_t, 
         --'RevType2' ord_revtype2_t,
         --'RevType3' ord_revtype3_t, 
         --'RevType4' ord_revtype4_t,
	 --END PTS# 24892 ILB 10/06/04
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
         ISNULL(freightdetail.fgt_quantity_type, 0) fgt_quantity_type,
         ISNULL(freightdetail.fgt_charge_type, 0)fgt_charge_type,
         freightdetail.tar_number,
         freightdetail.tar_tariffnumber,
         freightdetail.tar_tariffitem,
         ISNULL(freightdetail.fgt_ratingquantity,fgt_quantity)fgt_ratingquantity,
         ISNULL(freightdetail.fgt_ratingunit,fgt_unit)fgt_ratingunit,
         0 inv_protect,
         ISNULL(freightdetail.fgt_rate_type,0)fgt_rate_type,
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
	 ISNULL(
		ISNULL(
			stops.stp_alloweddet, 
			ISNULL(
				(SELECT MIN(cmp_maxdetmins) 
					FROM company, orderheader o1
					where o1.ord_billto = company.cmp_id 
					and o1.ord_hdrnumber = stops.ord_hdrnumber
					and cmp_maxdetmins is not null), 
				(SELECT cmp_maxdetmins 
					FROM company WHERE company.cmp_id = stops.cmp_id))
			),
		0) stp_alloweddet,
	 Case IsNull(stops.stp_gfc_arr_radius, 0)
		When 0 then (select gfc_auto_radius
					FROM geofence_defaults
					WHERE gfc_auto_cmp_id = 'UNKNOWN' AND
							gfc_auto_evt = 'ALL' AND
							gfc_auto_type = 'ARVING')
		Else stops.stp_gfc_arr_radius
	 End stp_gfc_arr_radius,
	 Case IsNull(stops.stp_gfc_arr_radiusunits, '')
		When '' then (select gfc_auto_radiusunits
					FROM geofence_defaults
					WHERE gfc_auto_cmp_id = 'UNKNOWN' AND
							gfc_auto_evt = 'ALL' AND
							gfc_auto_type = 'ARVING')
		Else stops.stp_gfc_arr_radiusunits
	 End stp_gfc_arr_radiusunits,
	 Case IsNull(stops.stp_gfc_arr_timeout, 0)
		When 0 then (select gfc_auto_timeout
					FROM geofence_defaults
					WHERE gfc_auto_cmp_id = 'UNKNOWN' AND
							gfc_auto_evt = 'ALL' AND
							gfc_auto_type = 'ARVING')
		Else stops.stp_gfc_arr_timeout
	 End stp_gfc_arr_timeout,
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
eventcodetable.name event_name,
0 max_stop --, 
-- JET - PTS 24078 - 8/31/2004, return the routed mileage type
--stops.stp_lgh_mileage_mtid
    into #ordtemp_tbl
    FROM eventcodetable,  
	 --PTS# 24892 ILB 10/06/04 
	 labelfile l1,
	 labelfile l2,
	 labelfile l3,
	 labelfile l4,
	 --END PTS# 24892 ILB 10/06/04 
	 stops join event as event on (stops.stp_number = event.stp_number )         
         left outer join city as city on (stops.stp_city = city.cty_code)
         left outer join legheader as legheader on ( stops.lgh_number = legheader.lgh_number)
         right outer join freightdetail as freightdetail on (freightdetail.stp_number = stops.stp_number)
         left outer join orderheader as orderheader on (stops.ord_hdrnumber = orderheader.ord_hdrnumber)         
         --city,
	 --legheader,
	 --event, 
	 --stops, 
	 --freightdetail,	 
         --orderheader,
   WHERE event.evt_eventcode = eventcodetable.abbr and
         stops.mov_number = @p_mov_number and   	
	 (evt_sequence = 1 or fgt_sequence = 1) and
	 eventcodetable.primary_event = 'Y' and
	 --PTS# 24892 ILB 10/06/04         
	 l1.labeldefinition = 'RevType1' and
	 l1.abbr = (select ord_revtype1
                      from orderheader
                     where mov_number = @p_mov_number)and
	 l2.labeldefinition = 'RevType2' and
	 l2.abbr = (select ord_revtype2 
                     from orderheader
                    where mov_number = @p_mov_number) and
	 l3.labeldefinition = 'RevType3' and
	 l3.abbr = (select ord_revtype3
                      from orderheader
                     where mov_number = @p_mov_number)and
	 l4.labeldefinition = 'RevType4' and
	 l4.abbr = (select ord_revtype4 
                     from orderheader
                    where mov_number = @p_mov_number)  
	 --END PTS# 24892 ILB 10/06/04 
	 --stops.stp_city *= city.cty_code and
	 --stops.lgh_number *= legheader.lgh_number and
	 --freightdetail.stp_number =* stops.stp_number and 
         --stops.stp_number = event.stp_number and 
	 --stops.ord_hdrnumber *= orderheader.ord_hdrnumber and
set @v_maxseq = 0
set @v_minname = ''
set @v_minstp = 0

WHILE (SELECT COUNT(*) FROM #ordtemp_tbl WHERE stp_number > @v_minstp) > 0

	BEGIN   
	  select @v_minstp = (select min(stp_number) from #ordtemp_tbl where stp_number > @v_minstp)
	  --print cast(@v_minstp as varchar(20))	 
	  	  
          SELECT @v_MinName = (select cmp_id from #ordtemp_tbl where stp_number = @v_minstp)
	  --print @v_minname		  
	  
          SELECT @v_MaxSeq = (SELECT MAX(stp_sequence) FROM #ordtemp_tbl WHERE cmp_id = @v_MinName)
          --print cast(@v_MaxSeq as varchar(20))	  
       
	 Update #ordtemp_tbl
             set max_stop = @v_MaxSeq
           where cmp_id = @v_minname  and
                 stp_sequence = @v_MaxSeq
                 

         set @v_minname = ''
         set @v_MaxSeq = 0
                 
	END     
--END PTS# 26601 ILB 01/27/2005

--PTS# 27677 ILB 04/07/2005
SELECT @v_ord_hdrnumber = MIN(ord_hdrnumber) 
  FROM #ordtemp_tbl 
 WHERE ord_hdrnumber > 0 
	
IF @v_ord_hdrnumber IS NOT NULL
 BEGIN
   IF exists (SELECT * 
                FROM orderheader 
                WHERE ord_hdrnumber = @v_ord_hdrnumber AND 
                     (ord_length > 0 or ord_width > 0 or ord_height > 0))
	BEGIN
	       
	       select @v_fgt_length = ord_length
                 from orderheader,#ordtemp_tbl
                where orderheader.ord_hdrnumber = @v_ord_hdrnumber AND 
                      #ordtemp_tbl.ord_hdrnumber = @v_ord_hdrnumber

		select @v_fgt_width = ord_width
                 from orderheader,#ordtemp_tbl
                where orderheader.ord_hdrnumber = @v_ord_hdrnumber AND 
                      #ordtemp_tbl.ord_hdrnumber = @v_ord_hdrnumber

		select @v_fgt_height = ord_height
                 from orderheader,#ordtemp_tbl
                where orderheader.ord_hdrnumber = @v_ord_hdrnumber AND 
                      #ordtemp_tbl.ord_hdrnumber = @v_ord_hdrnumber
		
  	       UPDATE #ordtemp_tbl 
                  SET fgt_length = @v_fgt_length , 
                      fgt_width = @v_fgt_width , 
                      fgt_height = @v_fgt_height
		 
	END
 END
--END PTS# 27677 ILB 04/07/2005 	
SELECT * FROM #ordtemp_tbl
GO
GRANT EXECUTE ON  [dbo].[d_tripfolder02_sp] TO [public]
GO
