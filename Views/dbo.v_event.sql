SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/****** Object:  View dbo.v_event    Script Date: 6/1/99 11:54:01 AM ******/
/****** Object:  View dbo.v_event    Script Date: 12/10/97 1:56:58 PM ******/
/****** Object:  View dbo.v_event    Script Date: 4/17/97 3:25:34 PM ******/
CREATE VIEW [dbo].[v_event]  
    ( ord_hdrnumber,   
      stp_number,   
      evt_eventcode,   
      evt_number,   
      evt_startdate,   
      evt_enddate,   
      evt_status,   
      evt_earlydate,   
      evt_latedate,   
      evt_weight,   
      evt_weightunit,   
      fgt_number,   
      evt_count,   
      evt_countunit,   
      evt_volume,   
      evt_volumeunit,   
      evt_pu_dr,   
      evt_sequence,   
      evt_contact,   
      evt_driver1,   
      evt_driver2,   
      evt_tractor,   
      evt_trailer1,   
      evt_trailer2,   
      evt_chassis,   
      evt_dolly,   
      evt_carrier,   
      evt_refype,   
      evt_refnum,   
      evt_reason,   
      evt_enteredby ) AS   
  SELECT event.ord_hdrnumber,   
         event.stp_number,   
         event.evt_eventcode,   
         event.evt_number,   
         event.evt_startdate,   
         event.evt_enddate,   
         event.evt_status,   
         event.evt_earlydate,   
         event.evt_latedate,   
         event.evt_weight,   
         event.evt_weightunit,   
         event.fgt_number,   
         event.evt_count,   
         event.evt_countunit,   
         event.evt_volume,   
         event.evt_volumeunit,   
         event.evt_pu_dr,   
         event.evt_sequence,   
         event.evt_contact,   
         event.evt_driver1,   
         event.evt_driver2,   
         event.evt_tractor,   
         event.evt_trailer1,   
         event.evt_trailer2,   
         event.evt_chassis,   
         event.evt_dolly,   
         event.evt_carrier,   
         event.evt_refype,   
         event.evt_refnum,   
         event.evt_reason,   
         event.evt_enteredby  
    FROM event   



GO
GRANT DELETE ON  [dbo].[v_event] TO [public]
GO
GRANT INSERT ON  [dbo].[v_event] TO [public]
GO
GRANT REFERENCES ON  [dbo].[v_event] TO [public]
GO
GRANT SELECT ON  [dbo].[v_event] TO [public]
GO
GRANT UPDATE ON  [dbo].[v_event] TO [public]
GO
