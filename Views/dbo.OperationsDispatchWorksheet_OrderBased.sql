SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*sample call
select * from OperationsDispatchWorksheet_OrderBased
*/

CREATE VIEW [dbo].[OperationsDispatchWorksheet_OrderBased]
AS
--PTS 62111 from Mindy to enhance performance
--PTS 79441 removed hardcoded index hints in 2 places.
WITH  CheckCallInfo(ckc_number, ckc_lghnumber, last_location, ckc_date)
        AS (SELECT  ckc_number
                   ,ckc_lghnumber
                   ,ISNULL((ISNULL(CONVERT(VARCHAR(12), ckc_milesfrom)
                                   + ' miles ', '')
                            + ISNULL(ckc_directionfrom + ' of ', ' ')
                            + ISNULL(ckc_cityname, '') + ISNULL(', '
                                                              + ckc_state
                                                              + ' ', ' ')
                            + ISNULL(ckc_zip, '')), 'None Available') last_location
                   ,ckc_date
            FROM    checkcall (NOLOCK)
            WHERE   ckc_number IN (SELECT MAX(ck2.ckc_number)
                                   FROM   checkcall ck2 WITH (NOLOCK)
                                   GROUP BY ckc_lghnumber))
--END PTS 62111
SELECT	lh.lgh_number, 
		lh.lgh_outstatus, 
		lh.lgh_startdate, 
		lh.lgh_schdtearliest, 
		lh.lgh_schdtlatest, 
		lh.lgh_enddate, 
		lh.lgh_tractor, 
		lh.lgh_driver1, 
		lh.lgh_carrier, 
		lh.lgh_primary_trailer, 
		lh.lgh_primary_pup, 
		lh.cmp_id_start, 
		lh.lgh_startcty_nmstct, 
		lh.cmp_id_end, 
		lh.lgh_endcty_nmstct, 
		lh.lgh_booked_revtype1, 
		ISNULL(oh.ord_number, '0') ord_number, 
		oh.ord_billto, 
		(select cmp_name 
		   -- JET - 5/6/09 - PTS 47384, added no lock and index hint
		   from dbo.company with (nolock) --, index(pk_id)) PTS57430 removed index hint
		  where lh.cmp_id_start = cmp_id) cmp_name_start, 
		(select cmp_name 
		   -- JET - 5/6/09 - PTS 47384, added no lock and index hint
		   from dbo.company with (nolock)--, index(pk_id)) PTS57430 removed index hint
		  where lh.cmp_id_end = cmp_id) cmp_name_end, 
		(select cmp_name 
		   -- JET - 5/6/09 - PTS 47384, added no lock and index hint
		   from dbo.company with (nolock)--, index(pk_id)) PTS57430 removed index hint
		  where oh.ord_billto = cmp_id) ord_billto_name, 
		lh.mov_number, 
		oh.ord_refnum, 
		oh.ord_reftype, 
		oh.ord_booked_revtype1, 
		lh.ord_hdrnumber, 
		oh.ord_revtype1, 
		oh.ord_revtype2, 
		oh.ord_revtype3, 
		oh.ord_revtype4, 
		--'RevType1' ord_revtype1_t, 
		--'RevType2' ord_revtype2_t, 
		--'RevType3' ord_revtype3_t, 
		--'RevType4' ord_revtype4_t, 
		--ISNULL(generalinfo.gi_string2, 'Branch') ord_booked_revtype1_t, 
		--ISNULL(generalinfo.gi_string3, 'Branch') lgh_booked_revtype1_t, 
		-- JET - 5/6/09 - PTS 47384, set no lock and index hint
		ISNULL((select top 1 st2.stp_event from dbo.stops st2 with (nolock)--, index(dk_leghdrnum)) 
				 where st2.lgh_number = lh.lgh_number 
				--   JET - 5/6/09 - PTS 47384
				--   and st2.stp_mfh_sequence = (select min(st3.stp_mfh_sequence) 
				--							     from dbo.stops st3 
				--							    where st3.lgh_number = lh.lgh_number 
				   and st2.stp_status = 'OPN' 
                order by st2.stp_arrivaldate), 'NONE') next_event, 
		0 new_trailer1, 
		0 new_trailer2, 
		lh.lgh_startcity, 
		oh.ord_shipper, 
		oh.ord_consignee, 
		oh.ord_company, 
		oh.ord_status, 
		lh.lgh_driver2, 
		lh.lgh_endcity, 
		st.stp_schdtearliest, 
		st.stp_schdtlatest, 
		ISNULL((select count(distinct(fd.cmd_code)) 
				  -- JET - 5/6/09 - PTS 47384, added nolock and index hint
				  from dbo.freightdetail fd WITH (nolock) 
                                    join dbo.stops st4 WITH (nolock)--, index(sk_stp_ordnum)) 
                                         on (fd.stp_number = st4.stp_number 
                                             and st4.ord_hdrnumber = oh.ord_hdrnumber 
                                             -- JET - 5/6/09 - PTS 47384, changed from UKNOWN to UNKNOWN
                                             and ISNULL(fd.cmd_code, 'UNKNOWN') <> 'UNKNOWN')), 0) commodity_count, 
		oh.ord_totalweight weight, 
		oh.ord_stopcount order_stops, 
		lh.lgh_prev_seg_status, 
		dbo.RefNumLookup(1, dv_id, lh.lgh_number, oh.ord_hdrnumber) reference_col1, 
		
		dbo.RefNumLookup(2, dv_id, lh.lgh_number, oh.ord_hdrnumber) reference_col2, 
		
		dv_id, 
		lh.lgh_startstate, 
		lh.lgh_endstate, 
		carrier.car_type1 cartype1, 
		carrier.car_type2 cartype2, 
		carrier.car_type3 cartype3, 
		carrier.car_type4 cartype4, 
		--'CarType1' cartype1_t, 
		--'CarType2' cartype2_t, 
		--'CarType3' cartype3_t, 
		--'CarType4' cartype4_t, 
		t1.trl_type1 trailer1_trltype1, 
		t1.trl_type2 trailer1_trltype2, 
		t1.trl_type3 trailer1_trltype3, 
		t1.trl_type4 trailer1_trltype4, 
		--'TrlType1' trailer1_trltype1_t, 
		--'TrlType2' trailer1_trltype2_t, 
		--'TrlType3' trailer1_trltype3_t, 
		--'TrlType4' trailer1_trltype4_t, 
		t2.trl_type1 trailer2_trltype1, 
		t2.trl_type2 trailer2_trltype2, 
		t2.trl_type3 trailer2_trltype3, 
		t2.trl_type4 trailer2_trltype4, 
		--'TrlType1' trailer2_trltype1_t, 
		--'TrlType2' trailer2_trltype2_t, 
		--'TrlType3' trailer2_trltype3_t, 
		--'TrlType4' trailer2_trltype4_t, 
		lh.lgh_type1,  
		lh.lgh_type2,  
		lh.lgh_type3,  
		lh.lgh_type4,  
		--'LghType1' lgh_type1_t, 
		--'LghType2' lgh_type2_t, 
		--'LghType3' lgh_type3_t, 
		--'LghType4' lgh_type4_t, 
		oh.ord_origin_earliestdate shipper_earliest, 
		oh.ord_origin_latestdate shipper_latest, 
		oh.ord_dest_earliestdate consignee_earliest, 
		oh.ord_dest_latestdate consignee_latest, 
		oh.ord_completiondate, 
		lh.lgh_dispatchdate, 
		ISNULL(oh.ord_railramporig, '') origin_railramp, 
		ISNULL(oh.ord_railrampdest, '') destination_railramp, 
		(select top 1 md1.mdt_value 
		   from dbo.miscdates md1 
		  where md1.mdt_table = 'stops' 
		    and md1.mdt_type = 'I1' 
		    and md1.mdt_tablekey in (select stp_number from stops smd1 where smd1.lgh_number = lh.lgh_number)) railingate_date, 
		(select top 1 md2.mdt_value 
		   from dbo.miscdates md2 
		  where md2.mdt_table = 'stops' 
		    and md2.mdt_type = 'OA' 
		    and md2.mdt_tablekey in (select stp_number from stops smd1 where smd1.lgh_number = lh.lgh_number)) railoutgate_date, 
		(select top 1 md3.mdt_value 
		   from dbo.miscdates md3 
		  where md3.mdt_table = 'stops' 
		    and md3.mdt_type = 'D1' 
		    and md3.mdt_tablekey in (select stp_number from stops smd1 where smd1.lgh_number = lh.lgh_number)) railnotification_date, 
		(select top 1 md4.mdt_value 
		   from dbo.miscdates md4 
		  where md4.mdt_table = 'stops' 
		    and md4.mdt_type = 'AF' 
		    and md4.mdt_tablekey in (select stp_number from stops smd1 where smd1.lgh_number = lh.lgh_number)) railactualarrival_date, 
		(select top 1 md5.mdt_value 
		   from dbo.miscdates md5 
		  where md5.mdt_table = 'stops' 
		    and md5.mdt_type = 'AG' 
		    and md5.mdt_tablekey in (select stp_number from stops smd1 where smd1.lgh_number = lh.lgh_number)) raileta_date, 
		--PTS 62111 commented out 2 lines below
		--ISNULL((ISNULL(CONVERT(varchar(12), ck.ckc_milesfrom) + ' miles ', '') + ISNULL(ck.ckc_directionfrom + ' of ', ' ') 
		--		+ ISNULL(ck.ckc_cityname, '')  + ISNULL(', ' + ck.ckc_state + ' ', ' ') + ISNULL(ck.ckc_zip, '')), 'None Available') last_location, 
		ck.last_location,
		--End 62111
		ck.ckc_date location_date, 
		st.stp_status trip_atend_status, 
		st.stp_departure_status trip_end_status,
		oh.ord_fromorder,
		lh.lgh_raildispatchstatus,
		carrier.car_204tender,
		carrier.car_204update,
  		lh.lgh_204status,
		lh.lgh_204date,
		--PTS 51639 JJF 20100412 - not sure why, but some columns were missing ...so..add them
		e.evt_chassis,
		0 new_chassis,
		e.evt_chassis2,
		0 new_chassis2,
		e.evt_dolly,
		0 new_dolly,
		e.evt_dolly2,
		0 new_dolly2,
		e.evt_trailer3,
		0 new_trailer3,
		e.evt_trailer4,
		0 new_trailer4,
		--PTS 51639 JJF 20100412
		--PTS 51570 JJF 20100510
		--oh.ord_BelongsTo as ord_BelongsTo
		oh.rowsec_rsrv_id as rowsec_rsrv_id,
		--END PTS 51570 JJF 20100510
		--END PTS 51639 JJF 20100412
  		/* 04/23/2010 MDH PTS 51454: <<BEGIN>> */
		t1.trl_equipmenttype trl_equipmenttype1,
 		/* 12/31/2010 MDH PTS 54854: <<BEGIN>> */
		oh.ord_extrainfo1  ord_extrainfo1, 
		oh.ord_extrainfo2  ord_extrainfo2, 
		oh.ord_extrainfo3  ord_extrainfo3, 
		oh.ord_extrainfo4  ord_extrainfo4, 
		oh.ord_extrainfo5  ord_extrainfo5, 
		oh.ord_extrainfo6  ord_extrainfo6, 
		oh.ord_extrainfo7  ord_extrainfo7, 
		oh.ord_extrainfo8  ord_extrainfo8, 
		oh.ord_extrainfo9  ord_extrainfo9, 
		oh.ord_extrainfo10 ord_extrainfo10,
		oh.ord_extrainfo11 ord_extrainfo11,
		oh.ord_extrainfo12 ord_extrainfo12,
		oh.ord_extrainfo13 ord_extrainfo13,
		oh.ord_extrainfo14 ord_extrainfo14,
		oh.ord_extrainfo15 ord_extrainfo15,
		oh.ord_totalpieces ord_totalpieces,
		oh.ord_totalvolume ord_totalvolume,
		oh.ord_totalweightunits ord_totalweightunits, 
		oh.ord_totalcountunits  ord_totalcountunits , 
		oh.ord_totalvolumeunits ord_totalvolumeunits , 
		CASE 
			WHEN lblDispStatus.code < 300 THEN (SELECT cmp_id FROM stops with (nolock) where stops.lgh_number = lh.lgh_number AND stops.stp_mfh_sequence = 1)
			ELSE (SELECT TOP 1 cmp_id FROM stops with (nolock) where stops.lgh_number = lh.lgh_number AND stops.stp_status = 'OPN' ORDER BY stops.stp_mfh_sequence)
		END next_stop,
				CASE 
			WHEN lblDispStatus.code < 300 THEN (SELECT cmp_name FROM stops with (nolock) where stops.lgh_number = lh.lgh_number AND stops.stp_mfh_sequence = 1)
			ELSE (SELECT TOP 1 cmp_name FROM stops with (nolock) where stops.lgh_number = lh.lgh_number AND stops.stp_status = 'OPN' ORDER BY stops.stp_mfh_sequence)
		END next_stop_name,
				CASE 
			WHEN lblDispStatus.code < 300 THEN (SELECT cty_nmstct FROM stops with (nolock) join company with (nolock)--, index(pk_id)) PTS57430 removed index hint
on stops.cmp_id = company.cmp_id where stops.lgh_number = lh.lgh_number AND stops.stp_mfh_sequence = 1)
			ELSE (SELECT TOP 1 cty_nmstct FROM stops with (nolock) join company with (nolock)--, index(pk_id)) PTS57430 removed index hint
 on stops.cmp_id = company.cmp_id where stops.lgh_number = lh.lgh_number AND stops.stp_status = 'OPN' ORDER BY stops.stp_mfh_sequence)
		END next_stop_nmstct
		/* 12/31/2010 MDH PTS 54854: <<END>> */
		,e_begin.evt_hubmiles begin_hub
		,e.evt_hubmiles end_hub
		,oh.ord_priority
		,lh.cmd_code
		--PTS 63598 JJF 20121011
		,oh.ord_subcompany
		,lblCompany.name as ord_subcompany_name,
		--END PTS 63598 JJF 20121011
		--PTS 64934 JJF 20130503
		(	SELECT	count(*)
			FROM	stops stp_inner
			WHERE	stp_inner.mov_number = lh.mov_number
		) as stop_count,
		lh.lgh_comment as lgh_comment
		--END PTS 64934 JJF 20130503
FROM	orderheader oh JOIN legheader lh with (nolock) /*57464*/ ON oh.mov_number = lh.mov_number 
					   LEFT OUTER JOIN stops st with (nolock) /*57464*/ON lh.stp_number_end = st.stp_number
  				       LEFT OUTER JOIN dbo.stops st_begin with (nolock) /*57464*/ON lh.stp_number_start = st_begin.stp_number 
					   LEFT OUTER JOIN event e with (nolock) /*57464*/ON e.stp_number = st.stp_number and e.evt_sequence = 1 
					   LEFT OUTER JOIN dbo.event e_begin with (nolock) /*57464*/ON e_begin.stp_number = st_begin.stp_number and e_begin.evt_sequence = 1
					   JOIN carrier with (nolock) /*57464*/ON lh.lgh_carrier = carrier.car_id 
					   JOIN trailerprofile t1 with (nolock) /*57464*/ON lh.lgh_primary_trailer = t1.trl_id 
					   JOIN trailerprofile t2 with (nolock) /*57464*/ON lh.lgh_primary_pup = t2.trl_id 
					   --PTS 62111
					   --LEFT OUTER JOIN checkcall ck with (nolock) /*57464*/ON (ck.ckc_number = (select max(ck2.ckc_number) 
					   --												   from checkcall ck2 with (nolock) /*57464*/
					   --										  where ck2.ckc_lghnumber = lh.lgh_number))
					   LEFT OUTER JOIN checkcallInfo ck WITH (NOLOCK) ON ck.ckc_lghnumber = lh.lgh_number
					   --PTS 63598 JJF 20121011
					   LEFT OUTER JOIN labelfile lblCompany with (nolock) on (oh.ord_subcompany = lblCompany.abbr and lblCompany.labeldefinition = 'Company')
					   --END PTS 63598 JJF 20121011
					   --End 62111
					   LEFT OUTER JOIN labelfile lblDispStatus with (nolock) /*57464*/on (lh.lgh_outstatus = lblDispStatus.abbr AND lblDispStatus.labeldefinition='DispStatus'), 
        dispatchview dv 
  WHERE	dv.dv_type = 'DW' AND dv.dv_view_type = '1' 
    AND lh.lgh_number = (select MAX(lh2.lgh_number) 
                           from legheader_active lh2 with (nolock) /*57464*/
                          where lh2.lgh_startdate = (select MIN(lh3.lgh_startdate) 
                                                       from legheader_active lh3 with (nolock) /*57464*/
                                                      where lh3.mov_number = oh.mov_number)
                            and lh2.mov_number = oh.mov_number) 
GO
GRANT REFERENCES ON  [dbo].[OperationsDispatchWorksheet_OrderBased] TO [public]
GO
GRANT SELECT ON  [dbo].[OperationsDispatchWorksheet_OrderBased] TO [public]
GO
