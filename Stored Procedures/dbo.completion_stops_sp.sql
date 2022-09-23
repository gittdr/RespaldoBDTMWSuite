SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[completion_stops_sp]		@p_ord_hdrnumber int

AS

/**
 * 
 * NAME:
 * completion_stops_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: NONE
 *
 * REVISION HISTORY:
 * 6/28/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 * 9/9/11 PTS 57867 DPETE If a consoldiated trip is invoiced then unconsolidated in Dispatch
 * the completion tables are wrong they need to reflect the unconsoldiation
 **/

DECLARE	@v_refnum_count	int, @movnumber int,@nextstop int, @newmov int

SELECT	@v_refnum_count = COUNT(*)  
FROM	completion_referencenumber 
WHERE	completion_referencenumber.ref_table = 'stops' AND  
		completion_referencenumber.ord_hdrnumber = @p_ord_hdrnumber 
/* check for a consolidated order (orders on the completion stops move that don't match ours) */
SELECT @movnumber = mov_number FROM completion_orderheader WHERE ord_hdrnumber = @p_ord_hdrnumber
IF exists 		
  (SELECT 1
   FROM  completion_stops
   WHERE mov_number = @movnumber	
   and  ord_hdrnumber <> @p_ord_hdrnumber and ord_hdrnumber > 0)
  BEGIN
  /* it is consolidated , see if it might have been unconsolidated in the real stops */
  
     IF exists (SELECT 1 from completion_stops cs join stops s on cs.stp_number = s.stp_number
     where cs.ord_hdrnumber = @p_ord_hdrnumber
     and cs.mov_number <> s.mov_number)
      BEGIN
      /* the move and probably leg has changed in Dispatch */
         select @newmov = mov_number from orderheader where ord_hdrnumber = @p_ord_hdrnumber
         
         
         
         IF @newmov is not null
         BEGIN

           
           -- fix mov number and assets on completion_orderheader
           update completion_orderheader 
           set mov_number = orderheader.mov_number
           ,ord_driver1 = orderheader.ord_driver1
           ,ord_driver2 = orderheader.ord_driver2
           ,ord_tractor = orderheader.ord_tractor
           ,ord_trailer = orderheader.ord_trailer
           from orderheader_completion ocomp
           join orderheader on ocomp.ord_hdrnumber = orderheader.ord_hdrnumber
           where ocomp.ord_hdrnumber = @p_ord_hdrnumber
           
         END
         SELECT @nextstop = min( stp_number) FROM completion_stops where ord_hdrnumber = @p_ord_hdrnumber
       
         WHILE @nextstop is not null
           BEGIN
             Update cmpletion_stops 
             Set cs.lgh_number = s.lgh_number,
             cs.mov_number = s.mov_number,
             cs.stp_mfh_sequence = s.stp_mfh_sequence,
             cs.stp_arrivaldate = s.stp_arrivaldate,
             cs.stp_departuredate = s.stp_departuredate,
             cs.stp_lgh_mileage = s.stp_lghmileage,
             cs.stp_completion_driver1 = isnull(legheader.lgh_driver1,'UNKNOWN'),
             cs.stp_completion_driver2 = isnull(legheader.lgh_driver2,'UNKNOWN'),
             cs.stp_completion_tractor = isnull(legheader.lgh_tractor,'UNKNOWN'),
             cs.stp_completion_trailer = isnull(legheader.lgh_primary_trailer,'UNKNOWN')
             from stops s join completion_stops cs on s.stp_number = cs.stp_number
             left outer join legheader on s.lgh_number = legheader.lgh_number
             where s.stp_number = @nextstop
             
             SELECT @nextstop = min( stp_number) 
             FROM completion_stops
             WHERE ord_hdrnumber = @p_ord_hdrnumber
             and stp_number >  @nextstop
           END 
         select @movnumber = @newmov   
      END
  END

SELECT	ord_hdrnumber, 
	stp_number, 
	cmp_id, 
	stp_region1, 
	stp_region2, 
	stp_region3, 
	stp_city, 
	stp_state, 
	stp_schdtearliest, 
	stp_origschdt, 
	stp_arrivaldate, 
	stp_departuredate, 
	stp_reasonlate, 
	stp_schdtlatest, 
	lgh_number, 
	mfh_number, 
	stp_type, 
	stp_paylegpt, 
	shp_hdrnumber, 
	stp_sequence, 
	stp_region4, 
	stp_lgh_sequence, 
	trl_id, 
	stp_mfh_sequence, 
	stp_event, 
	stp_mfh_position, 
	stp_lgh_position, 
	stp_mfh_status, 
	stp_lgh_status, 
	stp_ord_mileage, 
	stp_lgh_mileage, 
	stp_mfh_mileage, 
	mov_number, 
	stp_loadstatus, 
	stp_weight, 
	stp_weightunit, 
	cmd_code, 
	stp_description,
	stp_count, 
	stp_countunit, 
	cmp_name, 
	stp_comment, 
	stp_status, 
	stp_reftype, 
	stp_refnum, 
	stp_reasonlate_depart, 
	stp_screenmode, 
	skip_trigger, 
	stp_volume, 
	stp_volumeunit, 
	stp_dispatched_sequence, 
	stp_arr_confirmed, 
	stp_dep_confirmed, 
	stp_type1, 
	stp_redeliver, 
	stp_osd, 
	stp_pudelpref, 
	stp_phonenumber, 
	stp_delayhours, 
	stp_ooa_mileage, 
	stp_zipcode, 
	stp_OOA_stop, 
	stp_address, 
	stp_transfer_stp, 
	stp_phonenumber2, 
	stp_address2, 
	stp_contact, 
	stp_custpickupdate, 
	stp_custdeliverydate, 
	stp_podname, 
	stp_cmp_close, 
	stp_activitystart_dt, 
	stp_activityend_dt, 
	stp_departure_status, 
	stp_eta, 
	stp_etd, 
	stp_transfer_type,
	stp_trip_mileage, 
	stp_stl_mileage_flag, 
	tmp_evt_number, 
	tmp_fgt_number, 
	stp_pallets_in, 
	stp_pallets_out, 
	stp_pallets_received, 
	stp_pallets_shipped, 
	stp_pallets_rejected, 
	psh_number, 
	stp_advreturnempty, 
	stp_country, 
	stp_loadingmeters, 
	stp_loadingmetersunit, 
	stp_cod_amount, 
	stp_cod_currency, 
	stp_extra_count, 
	stp_extra_weight, 
	stp_alloweddet, 
	stp_detstatus, 
	stp_gfc_arr_radius, 
	stp_gfc_arr_radiusunits, 
	stp_gfc_arr_timeout, 
	stp_tmstatus, 
	stp_reasonlate_text, 
	stp_reasonlate_depart_text, 
	stp_est_drv_time, 
	stp_est_activity, 
	nlm_time_diff, 
	stp_lgh_mileage_mtid, 
	stp_count2, 
	stp_countunit2, 
	stp_ord_toll_cost, 
	stp_ord_mileage_mtid, 
	stp_ooa_mileage_mtid, 
	last_updateby, 
	last_updatedate, 
	last_updatebydepart, 
	last_updatedatedepart, 
	stp_unload_paytype,
	stp_completion_odometer,
	stp_completion_driver1,
	stp_completion_driver2,
	stp_completion_tractor,
	stp_completion_trailer,
	stp_completion_shift_date,
	stp_completion_shift_id,
	city_cty_nmstct,
	@v_refnum_count refnum_count
FROM 	completion_stops
WHERE	mov_number = @movnumber
--  AND	lgh_number > 0
ORDER BY stp_mfh_sequence

GO
GRANT EXECUTE ON  [dbo].[completion_stops_sp] TO [public]
GO
