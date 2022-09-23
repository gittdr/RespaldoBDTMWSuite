SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[d_datetimechecks_paydetail_sp]
( @prevnext             CHAR(1)
, @asgn_type            VARCHAR(6)
, @asgn_id              VARCHAR(13)
, @rowseq               INT
, @move                 INT
, @prevnext_date        DATETIME
) AS

/**
 *
 * NAME:
 * dbo.d_datetimechecks_paydetail_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for Finding immediate Next/Previous Trips for a given move or a date
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 *
 * @prevnext             CHAR(1)
 * @asgn_type            VARCHAR(6)
 * @asgn_id              VARCHAR(13)
 * @rowseq               INT
 * @move                 INT
 * @prevnext_date        DATETIME
 *
 * REVISION HISTORY:
 * PTS 55737 SPN Created 05/11/11
 * 
 **/

SET NOCOUNT ON

BEGIN

DECLARE @debug_ind      CHAR(1)
DECLARE @cutoff_date    DATETIME

DECLARE @temp TABLE
( rowseq                INT         NULL
, row_retrieved         CHAR(1)     NULL
, prevnext              CHAR(1)     NULL
, asgn_type             VARCHAR(6)  NULL
, asgn_id               VARCHAR(13) NULL
, mov_number            INT         NULL
, ord_hdrnumber         INT         NULL
, lgh_number            INT         NULL
, stp_number            INT         NULL
, asgn_date             DATETIME    NULL
, asgn_enddate          DATETIME    NULL
, asgn_status           VARCHAR(6)  NULL
, lgh_primary_trailer   VARCHAR(13) NULL
, lgh_primary_pup       VARCHAR(13) NULL
, cmp_id_end            VARCHAR(12) NULL
, lgh_endcty_nmstct     VARCHAR(25) NULL
, stp_number_end        INT         NULL
, lgh_endcity           INT         NULL
, evt_chassis           VARCHAR(13) NULL
, evt_chassis2          VARCHAR(13) NULL
, evt_dolly             VARCHAR(13) NULL
, evt_dolly2            VARCHAR(13) NULL
, evt_trailer3          VARCHAR(13) NULL
, evt_trailer4          VARCHAR(13) NULL
, last_stop_event_code  VARCHAR(6)  NULL
, ord_number            VARCHAR(12) NULL
, error_flag            CHAR(1)     NULL
)


SELECT @debug_ind     = 'N'
SELECT @prevnext_date = IsNull(@prevnext_date,GetDate())

IF @prevnext = 'P'
   BEGIN
      IF @move IS NOT NULL AND @move > 0
      BEGIN
         SELECT @cutoff_date = MAX(asgn_date)
           FROM assetassignment
          WHERE asgn_type   = @asgn_type
            AND asgn_id     = @asgn_id
            AND asgn_date < (SELECT MAX(asgn_date)
                               FROM assetassignment
                              WHERE asgn_type   = @asgn_type
                                AND asgn_id     = @asgn_id
                                AND mov_number  = @move
                            )
      END
      ELSE
      BEGIN
         SELECT @cutoff_date = MAX(asgn_date)
           FROM assetassignment
          WHERE asgn_type   = @asgn_type
            AND asgn_id     = @asgn_id
            AND asgn_date   < @prevnext_date
      END
      If @debug_ind = 'Y'
         Print 'Previous: ' + Convert(varchar,@cutoff_date)
   END
ELSE
   BEGIN
      IF @move IS NOT NULL AND @move > 0
      BEGIN
         SELECT @cutoff_date = MIN(asgn_date)
           FROM assetassignment
          WHERE asgn_type   = @asgn_type
            AND asgn_id     = @asgn_id
            AND asgn_date > (SELECT MIN(asgn_date)
                               FROM assetassignment
                              WHERE asgn_type   = @asgn_type
                                AND asgn_id     = @asgn_id
                                AND mov_number  = @move
                            )
      END
      ELSE
      BEGIN
         SELECT @cutoff_date = MIN(asgn_date)
           FROM assetassignment
          WHERE asgn_type   = @asgn_type
            AND asgn_id     = @asgn_id
            AND asgn_date   > @prevnext_date
      END
      If @debug_ind = 'Y'
         Print 'Next: ' + Convert(varchar,@cutoff_date)
   END

INSERT INTO @temp
( rowseq
, row_retrieved
, prevnext
, asgn_type           
, asgn_id             
, mov_number          
, ord_hdrnumber       
, lgh_number          
, stp_number          
, asgn_date           
, asgn_enddate        
, asgn_status         
, lgh_primary_trailer 
, lgh_primary_pup     
, cmp_id_end          
, lgh_endcty_nmstct   
, stp_number_end      
, lgh_endcity         
, evt_chassis         
, evt_chassis2        
, evt_dolly           
, evt_dolly2          
, evt_trailer3        
, evt_trailer4        
, last_stop_event_code
, ord_number          
, error_flag
)
SELECT @rowseq                                                 AS rowseq
     , 'Y'                                                     AS row_retrieved
     , @prevnext                                               AS prevnext
     , aa.asgn_type                                            AS asgn_type
     , aa.asgn_id                                              AS asgn_id
     , lh.mov_number                                           AS mov_number
     , lh.ord_hdrnumber                                        AS ord_hdrnumber
     , lh.lgh_number                                           AS lgh_number
     , e.stp_number                                            AS stp_number
     , aa.asgn_date                                            AS asgn_date
     , aa.asgn_enddate                                         AS asgn_enddate
     , aa.asgn_status                                          AS asgn_status
     , lh.lgh_primary_trailer                                  AS lgh_primary_trailer
     , lh.lgh_primary_pup                                      AS lgh_primary_pup
     , lh.cmp_id_end                                           AS cmp_id_end
     , lh.lgh_endcty_nmstct                                    AS lgh_endcty_nmstct
     , lh.stp_number_end                                       AS stp_number_end
     , lh.lgh_endcity                                          AS lgh_endcity
     , e.evt_chassis                                           AS evt_chassis
     , e.evt_chassis2                                          AS evt_chassis2
     , e.evt_dolly                                             AS evt_dolly
     , e.evt_dolly2                                            AS evt_dolly2
     , e.evt_trailer3                                          AS evt_trailer3
     , e.evt_trailer4                                          AS evt_trailer4
     , s.stp_event                                             AS last_stop_event_code
     , IsNull(o.ord_number,CONVERT(varchar,lh.ord_hdrnumber))  AS ord_number
     , 'N'                                                     AS error_flag
  FROM legheader lh
  JOIN assetassignment aa ON lh.lgh_number = aa.lgh_number
  LEFT OUTER JOIN event e ON aa.last_evt_number = e.evt_number
  LEFT OUTER JOIN stops s ON e.stp_number = s.stp_number
  LEFT OUTER JOIN orderheader o ON lh.ord_hdrnumber = o.ord_hdrnumber
 WHERE aa.asgn_type   = @asgn_type
   AND aa.asgn_id     = @asgn_id
   AND aa.asgn_date   = @cutoff_date

SELECT *
  FROM @temp

END
GO
GRANT EXECUTE ON  [dbo].[d_datetimechecks_paydetail_sp] TO [public]
GO
