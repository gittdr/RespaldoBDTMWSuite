SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[UpdateMoveProcessing_PreviousSegmentStatus_fn]
  (
    @stops  UpdateMoveProcessingStops READONLY,
    @legs   UpdateMoveProcessingLegs  READONLY
  )
RETURNS @PreviousSegmentStatus TABLE(lgh_number INTEGER NOT NULL PRIMARY KEY, PreviousSegmentStatus VARCHAR(6) NULL)
AS
BEGIN
  WITH Legs AS
  (
    SELECT  LGH.lgh_number,
            LGH.sequence,
            LAG(LGH.stp_number_start) OVER (ORDER BY LGH.sequence) PreviousFirstStop,
            LAG(LGH.stp_number_end) OVER (ORDER BY LGH.sequence) PreviousLastStop
      FROM  @legs LGH
  )
  INSERT INTO @PreviousSegmentStatus
    SELECT  L.lgh_number,
            CASE 
              WHEN L.sequence = 1 THEN 'NON'                                                 -- Status = NON this is the first leg on move                            
              WHEN PLS.stp_departure_status = 'DNE' THEN 'CMP'                               -- Status = CMP departed prior legs last stop
              WHEN PLS.stp_status = 'DNE' THEN 'ARR'                                         -- Status = ARR arrived at prior legs last stop
              WHEN PFS.stp_departure_status = 'DNE' THEN 'DPT'                               -- Status = DPT departed prior legs first stop
              WHEN PFS.stp_status = 'DNE' THEN 'STD'                                         -- Status = STD arrived at prior legs first stop
              WHEN PFS.evt_tractor <> 'UNKNOWN' OR PFS.evt_carrier <> 'UNKNOWN' THEN 'PLN'   -- Status = PLN prior leg has a tractor or carrier assigned
              ELSE 'AVL'                                                                     -- Status = AVL prior leg has not been planned
            END PreviousSegmentStatus
      FROM  Legs L
              LEFT OUTER JOIN @stops PFS ON PFS.stp_number = L.PreviousFirstStop
              LEFT OUTER JOIN @stops PLS ON PLS.stp_number = L.PreviousLastStop

  RETURN
END
GO
GRANT SELECT ON  [dbo].[UpdateMoveProcessing_PreviousSegmentStatus_fn] TO [public]
GO
