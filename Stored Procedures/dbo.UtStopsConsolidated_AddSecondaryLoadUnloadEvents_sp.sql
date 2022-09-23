SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_AddSecondaryLoadUnloadEvents_sp]
(
  @inserted                     UtStopsConsolidated READONLY,
  @deleted                      UtStopsConsolidated READONLY,
  @AddSecondaryLoadUnloadEvents VARCHAR(60)
)
AS

DECLARE @EventCount INTEGER,
        @recnum     INTEGER

SELECT  @EventCount = COUNT(1)
  FROM  @inserted i 
          INNER JOIN @deleted d ON d.stp_number = i.stp_number 
 WHERE  ((d.stp_event <> 'HPL' AND i.stp_event = 'HPL' AND @AddSecondaryLoadUnloadEvents IN ('PUP', 'PUPDRP'))
    OR   (d.stp_event <> 'DRL' AND i.stp_event = 'DRL' AND @AddSecondaryLoadUnloadEvents IN ('DRP', 'PUPDRP')))
   AND  i.ord_hdrnumber <> 0;

IF @EventCount = 0
  RETURN;

EXECUTE @recnum = dbo.getsystemnumberblock 'EVTNUM', '', @EventCount;

INSERT INTO dbo.event
  (
    ord_hdrnumber,
    stp_number,
    evt_eventcode,
    evt_startdate,
    evt_enddate,
    evt_earlydate,
    evt_latedate,
    evt_pu_dr,
    evt_driver1,
    evt_driver2,
    evt_tractor,
    evt_trailer1,
    evt_trailer2,
    evt_chassis,
    evt_dolly,
    evt_carrier,
    evt_number,
    evt_sequence,
    evt_status
  )
  SELECT  i.ord_hdrnumber,
          i.stp_number,
          CASE i.stp_event
            WHEN 'HPL' THEN 'PLD'
            ELSE 'PUL'
          END,
          i.stp_arrivaldate,
          i.stp_departuredate,
          i.stp_schdtearliest,
          i.stp_schdtlatest,
          i.stp_type,
          'UNKNOWN',
          'UNKNOWN',
          'UNKNOWN',
          'UNKNOWN',
          'UNKNOWN',
          'UNKNOWN',
          'UNKNOWN',
          'UNKNOWN',
          ROW_NUMBER() OVER (ORDER BY i.stp_number) + @recnum - 1,
          2,
          i.stp_status
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  ((d.stp_event <> 'HPL' AND i.stp_event = 'HPL' AND @AddSecondaryLoadUnloadEvents IN ('PUP', 'PUPDRP'))
      OR   (d.stp_event <> 'DRL' AND i.stp_event = 'DRL' AND @AddSecondaryLoadUnloadEvents IN ('DRP', 'PUPDRP')))
     AND  i.ord_hdrnumber <> 0;
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_AddSecondaryLoadUnloadEvents_sp] TO [public]
GO
