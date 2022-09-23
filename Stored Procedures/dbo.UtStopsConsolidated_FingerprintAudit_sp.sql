SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_FingerprintAudit_sp]
(
  @inserted     UtStopsConsolidated READONLY,
  @deleted      UtStopsConsolidated READONLY,
  @tmwuser      VARCHAR(255),
  @getdate      DATETIME,
  @usetripaudit CHAR(1)
)
AS

SET NOCOUNT ON

DECLARE @stops TABLE 
  (expedite_audit_ident INTEGER     NOT NULL, 
   key_value            INT         NOT NULL,
   activity             VARCHAR(20) NOT NULL);

WITH InsertedDeleted AS
(
  SELECT  i.stp_number,
          i.ord_hdrnumber ord_hdrnumber,
          i.mov_number mov_number,
          i.lgh_number lgh_number,
          i.stp_custpickupdate stp_custpickupdate_inserted,
          d.stp_custpickupdate stp_custpickupdate_deleted,
          CASE WHEN i.stp_custpickupdate <> d.stp_custpickupdate THEN 1 ELSE 0 END stp_custpickupdate_updated,
          i.stp_custdeliverydate stp_custdeliverydate_inserted,
          d.stp_custdeliverydate stp_custdeliverydate_deleted,
          CASE WHEN i.stp_custdeliverydate <> d.stp_custdeliverydate THEN 1 ELSE 0 END stp_custdeliverydate_updated,
          i.stp_schdtearliest stp_schdtearliest_inserted,
          d.stp_schdtearliest stp_schdtearliest_deleted,
          CASE WHEN i.stp_schdtearliest <> d.stp_schdtearliest THEN 1 ELSE 0 END stp_schdtearliest_updated,
          i.stp_schdtlatest stp_schdtlatest_inserted,
          d.stp_schdtlatest stp_schdtlatest_deleted,
          CASE WHEN i.stp_schdtlatest <> d.stp_schdtlatest THEN 1 ELSE 0 END stp_schdtlatest_updated,
          i.stp_departuredate stp_departuredate_inserted,
          d.stp_departuredate stp_departuredate_deleted,
          CASE WHEN i.stp_departuredate <> d.stp_departuredate THEN 1 ELSE 0 END stp_departuredate_updated,
          i.stp_arrivaldate stp_arrivaldate_inserted,
          d.stp_arrivaldate stp_arrivaldate_deleted,
          CASE WHEN i.stp_arrivaldate <> d.stp_arrivaldate THEN 1 ELSE 0 END stp_arrivaldate_updated,
          i.stp_event stp_event_inserted,
          d.stp_event stp_event_deleted,
          CASE WHEN i.stp_event <> d.stp_event THEN 1 ELSE 0 END stp_event_updated,
          i.cmp_id cmp_id_inserted,
          d.cmp_id cmp_id_deleted,
          CASE WHEN COALESCE(i.cmp_id, 'nU1L') <> COALESCE(d.cmp_id, 'nU1L') THEN 1 ELSE 0 END cmp_id_updated,
          i.stp_city stp_city_inserted,
          d.stp_city stp_city_deleted,
          CASE WHEN COALESCE(i.stp_city, -1) <> COALESCE(d.stp_city, -1) THEN 1 ELSE 0 END stp_city_updated,
          i.stp_reasonlate stp_reasonlate_inserted,
          d.stp_reasonlate stp_reasonlate_deleted,
          CASE WHEN COALESCE(i.stp_reasonlate , '$$$$$$$') <> COALESCE(d.stp_reasonlate , '$$$$$$$') THEN 1 ELSE 0 END stp_reasonlate_updated,
          i.stp_reasonlate_depart stp_reasonlate_depart_inserted,
          d.stp_reasonlate_depart stp_reasonlate_depart_deleted,
          CASE WHEN COALESCE(i.stp_reasonlate_depart, '$$$$$$$') <> COALESCE(d.stp_reasonlate_depart, '$$$$$$$') THEN 1 ELSE 0 END stp_reasonlate_depart_updated,
          i.stp_type stp_type_inserted,
          d.stp_type stp_type_deleted,
          CASE WHEN i.stp_type <> d.stp_type THEN 1 ELSE 0 END stp_type_updated,
          i.stp_eta stp_eta_inserted,
          d.stp_eta stp_eta_deleted,
          CASE WHEN i.stp_eta <> d.stp_eta THEN 1 ELSE 0 END stp_eta_updated,
          i.stp_departure_status stp_departure_status_inserted,
          d.stp_departure_status stp_departure_status_deleted,
          CASE WHEN i.stp_departure_status <> d.stp_departure_status THEN 1 ELSE 0 END stp_departure_status_updated,
          i.stp_status stp_status_inserted,
          d.stp_status stp_status_deleted,
          CASE WHEN i.stp_status <> d.stp_status THEN 1 ELSE 0 END stp_status_updated,
          i.stp_sequence stp_sequence_inserted,
          d.stp_sequence stp_sequence_deleted,
          CASE WHEN i.stp_sequence <> d.stp_sequence THEN 1 ELSE 0 END stp_sequence_updated,
          i.stp_podname stp_podname_inserted,
          d.stp_podname stp_podname_deleted,
          CASE WHEN i.stp_podname <> d.stp_podname THEN 1 ELSE 0 END stp_podname_updated,
          i.stp_comment stp_comment_inserted,
          d.stp_comment stp_comment_deleted,
          CASE WHEN COALESCE(i.stp_comment, 'nU1L') <> COALESCE(d.stp_comment, 'nU1L') THEN 1 ELSE 0 END stp_comment_updated
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
),
CTE AS
(
  SELECT  stp_number,
          ord_hdrnumber,
          'TIME_MDF' activity,
          'PICKUP DATE WAS ' + CONVERT(VARCHAR(20), stp_custpickupdate_deleted , 20) update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_custpickupdate_updated = 1
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'TIME_MDF' activity,
          'DELIVERY DATE WAS ' + CONVERT(VARCHAR(20), stp_custdeliverydate_deleted , 20) update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_custdeliverydate_updated = 1 
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'DEST EARLIEST DATE' activity,
          CONVERT(VARCHAR, stp_schdtearliest_deleted, 20)+' -> '+CONVERT(VARCHAR, stp_schdtearliest_inserted, 20) update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_schdtearliest_updated = 1
     AND  ord_hdrnumber = 0
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'DEST LATEST DATE' activity,
          CONVERT(VARCHAR, stp_schdtlatest_deleted, 20)+' -> '+CONVERT(VARCHAR, stp_schdtlatest_inserted, 20) update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_schdtlatest_updated = 1
     AND  ord_hdrnumber = 0
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'Depart Date Changed' activity,
          stp_event_inserted + '(' + cmp_id_inserted + '):  ' + COALESCE(CONVERT(VARCHAR(20), stp_departuredate_deleted, 120), 'null') + ' -> ' + COALESCE(CONVERT(VARCHAR(20), stp_departuredate_deleted, 120), 'null') update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_departuredate_updated = 1
     AND  @tmwuser <> 'TOTALMAIL'
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'Arrival Date Changed' activity,
          stp_event_inserted + '(' + cmp_id_inserted + '):  ' + COALESCE(CONVERT(VARCHAR(20), stp_arrivaldate_deleted, 120), 'null') + ' -> ' + COALESCE(CONVERT(VARCHAR(20), stp_arrivaldate_deleted, 120), 'null') update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_arrivaldate_updated = 1
     AND  @tmwuser <> 'TOTALMAIL'  
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'Event Updated' activity,
          stp_event_deleted + ' -> ' + stp_event_inserted update_note, 
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_event_updated = 1
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'ReasonLate(Arr) Chgd' activity,
          stp_event_inserted + '(' + cmp_id_inserted + '):  ' + COALESCE(stp_reasonlate_deleted, 'null') + ' -> ' + COALESCE(stp_reasonlate_deleted, 'null') update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_reasonlate_updated = 1
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'ReasonLate(Dep) Chgd' activity,
          stp_event_inserted + '(' + cmp_id_inserted + '):  ' + COALESCE(stp_reasonlate_depart_deleted, 'null') + ' -> ' + COALESCE(stp_reasonlate_depart_deleted, 'null') update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_reasonlate_depart_updated = 1
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          CASE WHEN stp_type_inserted = 'PUP' THEN 'ETA_SHIP' ELSE 'ETA_CONS' END activity,
          COALESCE(CONVERT(VARCHAR(20), stp_eta_deleted, 120), 'null') + ' -> ' + COALESCE(CONVERT(VARCHAR(20), stp_eta_inserted, 120), 'null') update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_eta_updated = 1 
     AND  stp_type_inserted IN ('PUP', 'DRP')
  UNION
  SELECT  id.stp_number,
          id.ord_hdrnumber,
          CASE
            WHEN stp_type_inserted = 'PUP' THEN 'LOADED'
            WHEN stops.stp_number IS NULL THEN 'ARR_CONS'
            ELSE 'Depart Extra Drop'
          END activity,
          null update_note,
          id.mov_number,
          id.lgh_number
    FROM  InsertedDeleted id
            LEFT OUTER JOIN stops WITH(NOLOCK) ON stops.ord_hdrnumber = id.ord_hdrnumber AND stops.stp_sequence > stp_sequence_inserted AND stops.stp_type = 'DRP'
   WHERE  stp_departure_status_updated = 1
     AND  stp_departure_status_inserted = 'DNE'
     AND  stp_type_inserted IN ('PUP', 'DRP')
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'Stop updated' activity,
          'BOL/POD ' + COALESCE(stp_podname_deleted , 'null')+' -> ' + COALESCE(stp_podname_inserted , 'null') update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_podname_updated = 1
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'Stop updated' activity,
          'CompanyId ' + COALESCE(cmp_id_deleted, 'null') + '(' + fromcity.cty_name + ',' + fromcity.cty_state + ') -> ' + COALESCE(cmp_id_inserted, 'null') + '(' + tocity.cty_name + ',' + tocity.cty_state + ')' update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
            LEFT OUTER JOIN city fromcity WITH(NOLOCK) ON fromcity.cty_code = stp_city_deleted
            LEFT OUTER JOIN city tocity WITH(NOLOCK) ON tocity.cty_code = stp_city_inserted
   WHERE  cmp_id_updated = 1
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'Stop updated' activity,
          'City' + COALESCE(fromcity.cty_name, 'UNKNOWN') + ',' + COALESCE(fromcity.cty_state, 'UNK') + ' -> ' + tocity.cty_name + ',' + tocity.cty_state update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
            LEFT OUTER JOIN city fromcity WITH(NOLOCK) ON fromcity.cty_code = stp_city_deleted
            LEFT OUTER JOIN city tocity WITH(NOLOCK) ON tocity.cty_code = stp_city_inserted
   WHERE  stp_city_updated = 1 
     AND  cmp_id_updated = 0
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'Stop updated' activity,
          LEFT('Comment ' + COALESCE('"' + stp_comment_deleted + '"', 'null') + ' -> ' + COALESCE('"' + stp_comment_inserted + '"', 'null'), 255)  update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
   WHERE  stp_comment_updated = 1
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'Arrive Status' activity,
          CASE stp_status_inserted
            WHEN 'DNE' THEN 'Arrived ' + stp_event_inserted + '(' + cmp_id_inserted + ' - ' + COALESCE(c.cty_name, 'UNKNOWN') + ',' + COALESCE(c.cty_state, 'UNK') + ') ' + CONVERT(VARCHAR(20), stp_arrivaldate_inserted, 120)
            WHEN 'OPN' THEN 'Arrival retracted ' + stp_event_inserted + '(' + cmp_id_inserted + ' - ' + COALESCE(c.cty_name, 'UNKNOWN') + ',' + COALESCE(c.cty_state, 'UNK') + ') ' + CONVERT(VARCHAR(20), stp_arrivaldate_inserted, 120)
          END update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
            INNER JOIN city c WITH(NOLOCK) ON c.cty_code = stp_city_inserted
   WHERE  stp_status_updated = 1
     AND  @usetripaudit = 'Y'
     AND  stp_status_inserted IN ('OPN', 'DNE')
  UNION
  SELECT  stp_number,
          ord_hdrnumber,
          'Depart Status' activity,
          CASE stp_departure_status_inserted
            WHEN 'DNE' THEN 'Departed ' + stp_event_inserted + '(' + cmp_id_inserted + ' - ' + COALESCE(c.cty_name, 'UNKNOWN') + ',' + COALESCE(c.cty_state, 'UNK') + ') ' + CONVERT(VARCHAR(20), stp_departure_status_inserted, 120)
            WHEN 'OPN' THEN 'Arrival retracted ' + stp_event_inserted + '(' + cmp_id_inserted + ' - ' + COALESCE(c.cty_name, 'UNKNOWN') + ',' + COALESCE(c.cty_state, 'UNK') + ') ' + CONVERT(VARCHAR(20), stp_departure_status_inserted, 120)
          END update_note,
          mov_number,
          lgh_number
    FROM  InsertedDeleted
            INNER JOIN city c WITH(NOLOCK) ON c.cty_code = stp_city_inserted
   WHERE  stp_departure_status_updated = 1
     AND  @usetripaudit = 'Y'
     AND  stp_departure_status_inserted IN ('OPN', 'DNE')
)
INSERT INTO dbo.expedite_audit
  (
    ord_hdrnumber,
    updated_by,
    updated_dt,
    activity,
    update_note,
    mov_number,
    lgh_number,
    join_to_table_name,
    key_value
  )
  OUTPUT inserted.expedite_audit_ident, CAST(inserted.key_value AS INTEGER), inserted.activity INTO @stops
  SELECT  ord_hdrnumber,
          @tmwuser,
          @getdate,
          activity,
          update_note,
          mov_number,
          lgh_number,
          'stops',
          stp_number
    FROM  CTE;

INSERT INTO  expedite_audit_arrival_departure
  (expedite_audit_ident,
   eaad_datetime)
  SELECT  s.expedite_audit_ident,
          CASE s.activity
            WHEN 'Arrive Status' THEN i.stp_arrivaldate
            ELSE i.stp_departuredate
          END
    FROM  @stops s
            INNER JOIN @inserted i ON i.stp_number = s.key_value
   WHERE  s.activity IN ('Arrive Status', 'Depart Status');

WITH InsertedDeleted AS
(
  SELECT  i.stp_number stp_number,
          d.ord_hdrnumber ord_hdrnumber,
          d.lgh_number lgh_number,
          i.stp_custpickupdate stp_custpickupdate_inserted,
          d.stp_custpickupdate stp_custpickupdate_deleted,
          CASE WHEN i.stp_custpickupdate <> d.stp_custpickupdate THEN 1 ELSE 0 END stp_custpickupdate_updated,
          i.stp_custdeliverydate stp_custdeliverydate_inserted,
          d.stp_custdeliverydate stp_custdeliverydate_deleted,
          CASE WHEN i.stp_custdeliverydate <> d.stp_custdeliverydate THEN 1 ELSE 0 END stp_custdeliverydate_updated,
          i.stp_status stp_status_inserted,
          d.stp_status stp_status_deleted,
          CASE WHEN i.stp_status <> d.stp_status THEN 1 ELSE 0 END stp_status_updated,
          i.stp_arrivaldate stp_arrivaldate_inserted,
          d.stp_arrivaldate stp_arrivaldate_deleted,
          CASE WHEN i.stp_arrivaldate <> d.stp_arrivaldate THEN 1 ELSE 0 END stp_arrivaldate_updated,
          i.stp_event stp_event
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
),
CTE AS
(
  SELECT  ord_hdrnumber,
          lgh_number,
          stp_number,
          stp_custpickupdate_deleted old_req_pickup_dt,
          stp_custpickupdate_inserted new_req_pickup_dt,
          NULL old_req_delivery_dt,
          NULL new_req_delivery_dt,
          NULL old_actual_arrival_dt,
          NULL new_actual_arrival_dt,
          stp_event
    FROM  InsertedDeleted
   WHERE  stp_custpickupdate_updated = 1
  UNION
  SELECT  ord_hdrnumber,
          lgh_number,
          stp_number,
          NULL old_req_pickup_dt,
          NULL new_req_pickup_dt,
          stp_custdeliverydate_deleted old_req_delivery_dt,
          stp_custdeliverydate_inserted new_req_delivery_dt,
          NULL old_actual_arrival_dt,
          NULL new_actual_arrival_dt,
          stp_event
    FROM  InsertedDeleted
   WHERE  stp_custdeliverydate_updated = 1
  UNION
  SELECT  ord_hdrnumber,
          lgh_number,
          stp_number,
          NULL old_req_pickup_dt,
          NULL new_req_pickup_dt,
          NULL old_req_delivery_dt,
          NULL new_req_delivery_dt,
          stp_arrivaldate_deleted old_actual_arrival_dt,
          stp_arrivaldate_inserted new_actual_arrival_dt,
          stp_event
    FROM  InsertedDeleted
   WHERE  stp_status_inserted = 'DNE'
     AND  (stp_status_updated = 1
      OR   stp_arrivaldate_updated = 1)
)
INSERT INTO dbo.dispaudit
  (ord_hdrnumber,
   lgh_number,
   updated_by,
   updated_dt,
   stp_number,
   old_req_pickup_dt,
   new_req_pickup_dt,
   old_req_delivery_dt,
   new_req_delivery_dt,
   old_actual_arrival_dt,
   new_actual_arrival_dt,
   stp_event,
   cty_nmstct,
   cmp_name)
  SELECT  CTE.ord_hdrnumber,
          CTE.lgh_number,
          LEFT(@tmwuser,20),
          @getdate,
          CTE.stp_number,
          CTE.old_req_pickup_dt,
          CTE.new_req_pickup_dt,
          CTE.old_req_delivery_dt,
          CTE.new_req_delivery_dt,
          CTE.old_actual_arrival_dt,
          CTE.new_actual_arrival_dt,
          CTE.stp_event,
          ci.cty_nmstct,
          LEFT(co.cmp_name,30)
    FROM  CTE 
            INNER JOIN @inserted i ON i.stp_number = CTE.stp_number
            INNER JOIN company co WITH(NOLOCK) ON co.cmp_id = i.cmp_id
            INNER JOIN city ci WITH(NOLOCK) ON ci.cty_code = i.stp_city
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_FingerprintAudit_sp] TO [public]
GO
