SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[UpdateMoveProcessing_HazMatMileageLookups_fn]
  (
    @stops  UpdateMoveProcessingStops READONLY
  )
RETURNS @LegHazCmdClass TABLE(lgh_number  INTEGER NOT NULL PRIMARY KEY, cmd_class  VARCHAR(8) NULL)
AS
BEGIN
  WITH CommoditySequences AS
  (
	SELECT  F.cmd_code,
          LF.code,
          CASE
            WHEN MIN(S.stp_mfh_sequence) = MAX(S.stp_mfh_sequence) THEN 1
            ELSE MIN(S.stp_mfh_sequence)
          END min_mfh_sequence,
          MAX(stp_mfh_sequence) max_mfh_sequence
    FROM  @stops S
            INNER JOIN freightdetail F WITH(NOLOCK) ON F.stp_number = S.stp_number
            INNER JOIN commodity C WITH(NOLOCK) ON C.cmd_code = F.cmd_code
            INNER JOIN commodityclass CC WITH(NOLOCK) ON CC.ccl_code = C.cmd_class
            INNER JOIN labelfile LF WITH(NOLOCK) ON LF.labeldefinition = 'ALKHazLevel' AND (LF.abbr = CC.alk_hazlevel OR (CC.alk_hazlevel IS NULL AND LF.abbr = 'DIS'))
    GROUP BY F.cmd_code, LF.code
  ),
  LegHazCmdClass AS
  (
    SELECT  S.lgh_number,
            MAX(CS.code) code
      FROM  @stops S
              INNER JOIN freightdetail F WITH(NOLOCK) ON F.stp_number = S.stp_number
              INNER JOIN CommoditySequences CS ON CS.cmd_code = F.cmd_code
     WHERE  S.stp_mfh_sequence >= CS.min_mfh_sequence
       AND  S.stp_mfh_sequence <= CS.max_mfh_sequence
    GROUP BY S.lgh_number
  )
  INSERT INTO @LegHazCmdClass
    SELECT  LHCC.lgh_number,
            LF.abbr cmd_class
      FROM  LegHazCmdClass LHCC
              INNER JOIN labelfile LF WITH(NOLOCK) ON LF.labeldefinition = 'ALKHazLevel' AND LF.code = LHCC.code

  RETURN
END
GO
GRANT SELECT ON  [dbo].[UpdateMoveProcessing_HazMatMileageLookups_fn] TO [public]
GO
