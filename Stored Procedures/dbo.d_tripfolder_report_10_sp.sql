SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE procedure [dbo].[d_tripfolder_report_10_sp] 	@mov_number integer
as

/**
 *
 * NAME:
 * dbo.d_tripfolder_report_10_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * source of data for d_tripfolder_report10 for FUnks livestock based on d_tripfolder_qdi
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
 * 6/27/07 DPETE PTS 37979
 * 12/10/2007 MDH PTS 40398: Added company name for order by company.
 * 10/21/2008 MDH PTS 44378: Added company 1 note and company 2 note (First and second bill to company first driver note
 *
 **/
/* 10/21/2008 MDH PTS 44378: BEGIN */
DECLARE @showexpired 			CHAR(1)
DECLARE @grace 					INTEGER
DECLARE @first_ord_hdrnumber	INTEGER
DECLARE @second_ord_hdrnumber	INTEGER
DECLARE @first_note				VARCHAR (254)
DECLARE @second_note			VARCHAR (254)
DECLARE @first_billto			VARCHAR (18)
DECLARE @second_billto			VARCHAR (18)

SELECT @showexpired = gi_string1
	FROM generalinfo
	WHERE gi_name = 'showexpirednotes'
SET @showexpired = COALESCE (@showexpired, 'Y')

SELECT @grace = gi_integer1
	FROM generalinfo
	WHERE gi_name = 'showexpirednotesgrace'
SET @grace = COALESCE (@grace, 0)


SELECT TOP 1 @first_ord_hdrnumber = stops.ord_hdrnumber, @first_billto = orderheader.ord_billto
	FROM stops LEFT OUTER JOIN orderheader ON stops.ord_hdrnumber = orderheader.ord_hdrnumber
	WHERE stops.ord_hdrnumber > 0
	  AND stops.ord_hdrnumber IS NOT NULL
	  AND stops.mov_number = @mov_number
	ORDER BY stops.ord_hdrnumber

SELECT TOP 1 @first_note = not_text
	FROM notes
	WHERE ntb_table = 'company'
	  AND not_type = 'D'
	  AND nre_tablekey = @first_billto
	  AND (DATEADD (day, @grace, not_expires) >=
			CASE @showexpired
				WHEN 'N' THEN getdate ()
				ELSE COALESCE (DATEADD (day, @grace, not_expires), GetDate())
			END
		  )
	ORDER BY not_sequence
SELECT TOP 1 @second_ord_hdrnumber = stops.ord_hdrnumber, @second_billto = orderheader.ord_billto
	FROM stops LEFT OUTER JOIN orderheader ON stops.ord_hdrnumber = orderheader.ord_hdrnumber
	WHERE stops.ord_hdrnumber > @first_ord_hdrnumber
	  AND stops.ord_hdrnumber IS NOT NULL
	  AND stops.mov_number = @mov_number
	ORDER BY stops.ord_hdrnumber
SELECT TOP 1 @second_note = not_text
	FROM notes
	WHERE ntb_table = 'company'
	  AND not_type = 'D'
	  AND nre_tablekey = @second_billto
	  AND (DATEADD (day, @grace, not_expires) >=
			CASE @showexpired
				WHEN 'N' THEN getdate ()
				ELSE COALESCE (DATEADD (day, @grace, not_expires), GetDate())
			END
		  )
	ORDER BY not_sequence
/* 10/21/2008 MDH PTS 44378: END */

SELECT   event.evt_driver1 driver1,
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
         Case evt_sequence when 1 then freightdetail.fgt_weight else 0 end weight,
         freightdetail.fgt_weightunit  weightunit,
         Case evt_sequence when 1 then freightdetail.fgt_count else 0 end cnt,
         freightdetail.fgt_countunit countunit,
         Case evt_sequence when 1 then freightdetail.fgt_volume else 0 end volume,
         freightdetail.fgt_volumeunit volumeunit,
         Case evt_sequence when 1 then freightdetail.fgt_quantity else 0 end quantity,
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
	 IsNull(orderheader.ord_revtype1, '') ord_revtype1,
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
	orderheader.ord_showshipper,
	orderheader.ord_showcons,
	orderheader.ord_bookdate,
	orderheader.cmd_code,
	orderheader.ord_description,
	orderheader.ord_shipper,
	orderheader.ord_consignee,
	orderheader.ord_origin_earliestdate,
	orderheader.ord_dest_earliestdate,
	orderheader.ord_totalweight,
	orderheader.ord_totalweightunits,
	isnull(fgt_count,0.0) fgt_count,
	orderheader.ord_totalcountunits,
	orderheader.ord_totalvolume,
	orderheader.ord_totalvolumeunits,
	orderheader.ord_subcompany,
    orderheader.ord_number s1_ord_hdrnumber,
    eventcodetable.name eventname,
    cast(isnull(cmp_directions,'** No directions on file **') as text)  cmp_directions,
    ord_mintemp,
    ord_maxtemp,
    ord_tempunits ,
 	 (select cmp_name
	  from company
	  where company.cmp_id = orderheader.ord_company) orderby_name,   /* 12/10/2007 MDH PTS 40398: Added */
/* 10/21/2008 MDH PTS 44378: BEGIN */
	@first_ord_hdrnumber	first_ord_hdrnumber	    ,
	@second_ord_hdrnumber	second_ord_hdrnumber	,
	@first_note				first_note				,
	@second_note			second_note			    ,
	@first_billto			first_billto			,
	@second_billto			second_billto			
/* 10/21/2008 MDH PTS 44378: END */
    FROM stops
    left outer join legheader on stops.lgh_number = legheader.lgh_number
    left outer join city on stops.stp_city = city.cty_code
	join event on stops.stp_number = event.stp_number
    join freightdetail on  stops.stp_number = freightdetail.stp_number
    join eventcodetable on event.evt_eventcode = eventcodetable.abbr
	left outer join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
    left outer join company on stops.cmp_id = company.cmp_id

   WHERE stops.mov_number = @mov_number

GO
GRANT EXECUTE ON  [dbo].[d_tripfolder_report_10_sp] TO [public]
GO
