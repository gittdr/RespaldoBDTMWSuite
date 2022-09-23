SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  View dbo.v_stops    Script Date: 6/1/99 11:54:02 AM ******/
/****** Object:  View dbo.v_stops    Script Date: 12/10/97 1:56:59 PM ******/
/****** Object:  View dbo.v_stops    Script Date: 4/17/97 3:25:51 PM ******/
CREATE VIEW [dbo].[v_stops]  
    ( ord_hdrnumber,   
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
      stp_refnum ) AS   
  SELECT stops.ord_hdrnumber,   
         stops.stp_number,   
         stops.cmp_id,   
         stops.stp_region1,   
         stops.stp_region2,            stops.stp_region3,   
         stops.stp_city,   
         stops.stp_state,   
         stops.stp_schdtearliest,   
         stops.stp_origschdt,   
         stops.stp_arrivaldate,   
         stops.stp_departuredate,   
         stops.stp_reasonlate,   
         stops.stp_schdtlatest,   
         stops.lgh_number,   
         stops.mfh_number,   
         stops.stp_type,   
         stops.stp_paylegpt,   
         stops.shp_hdrnumber,   
         stops.stp_sequence,   
         stops.stp_region4,   
         stops.stp_lgh_sequence,   
         stops.trl_id,   
         stops.stp_mfh_sequence,   
         stops.stp_event,   
         stops.stp_mfh_position,   
         stops.stp_lgh_position,   
         stops.stp_mfh_status,   
         stops.stp_lgh_status,   
         stops.stp_ord_mileage,   
         stops.stp_lgh_mileage,   
         stops.stp_mfh_mileage,   
         stops.mov_number,   
         stops.stp_loadstatus,   
         stops.stp_weight,   
         stops.stp_weightunit,   
         stops.cmd_code,   
         stops.stp_description,   
         stops.stp_count,   
         stops.stp_countunit,   
         stops.cmp_name,   
         stops.stp_comment,   
         stops.stp_status,   
         stops.stp_reftype,   
         stops.stp_refnum  
    FROM stops   



GO
GRANT DELETE ON  [dbo].[v_stops] TO [public]
GO
GRANT INSERT ON  [dbo].[v_stops] TO [public]
GO
GRANT REFERENCES ON  [dbo].[v_stops] TO [public]
GO
GRANT SELECT ON  [dbo].[v_stops] TO [public]
GO
GRANT UPDATE ON  [dbo].[v_stops] TO [public]
GO
