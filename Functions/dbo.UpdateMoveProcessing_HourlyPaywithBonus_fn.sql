SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[UpdateMoveProcessing_HourlyPaywithBonus_fn]
  (
    @stops  UpdateMoveProcessingStops READONLY
  )
RETURNS @HourlyPaywithBonus TABLE(lgh_number INTEGER NOT NULL PRIMARY KEY, PlannedHours DECIMAL(6,2) NULL)
AS
BEGIN
  WITH LegStops AS
  (
    SELECT  S.lgh_number,
            S.stp_event,
            LAG(S.stp_event) OVER (PARTITION BY S.lgh_number ORDER BY S.stp_mfh_sequence, S.stp_arrivaldate) previous_event,
            ROW_NUMBER() OVER (PARTITION BY S.lgh_number, S.stp_event ORDER BY  S.stp_mfh_sequence, S.stp_arrivaldate) EventUsageTime,
            COUNT(1) OVER (PARTITION BY S.lgh_number, S.stp_event) EventUsageCount,
            MT.mt_hours
      FROM  @stops S
              LEFT OUTER JOIN mileagetable MT WITH(NOLOCK) ON MT.mt_identity = S.stp_lgh_mileage_mtid
  )
  INSERT INTO @HourlyPaywithBonus
    SELECT  LS.lgh_number,
            ROUND(SUM(CASE
                        WHEN LS.EventUsageTime = 1 THEN COALESCE(ECT.ect_defaulttimefirst, 0)             -- first time event used
                        WHEN LS.stp_event = LS.previous_event THEN COALESCE(ECT.ect_defaulttimesubb2b, 0) -- same event as previous stop
                        ELSE COALESCE(ECT.ect_defaulttimesubnotb2b, 0)                                    -- event used previously but not on previous stop
                      END/60.0 + COALESCE(LS.mt_hours, 0))*4, 0)/4.0 PlannedHours
      FROM  LegStops LS
              INNER JOIN eventcodetable ECT WITH(NOLOCK) ON ECT.abbr = LS.stp_event
    GROUP BY LS.lgh_number

  RETURN
END
GO
GRANT SELECT ON  [dbo].[UpdateMoveProcessing_HourlyPaywithBonus_fn] TO [public]
GO
