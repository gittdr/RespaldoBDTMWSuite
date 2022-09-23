SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_Intermodal_sp]
(
  @inserted       UtStopsConsolidated READONLY,
  @deleted        UtStopsConsolidated READONLY,
  @InService      VARCHAR(12),
  @tmwuser        VARCHAR(255),
  @GETDATE        DATETIME
)
AS

SET NOCOUNT ON

DECLARE @CmpId              VARCHAR(8),
        @TrlId              VARCHAR(13),
        @StpArrivalDate     DATETIME,
        @StpSchdtEarliest   DATETIME,
        @StpStatusInserted  VARCHAR(6),
        @StpStatusDeleted   VARCHAR(6),
        @exp_key            INTEGER 

DECLARE STOPS_CURSOR CURSOR LOCAL FAST_FORWARD FOR
  SELECT  i.cmp_id,
          COALESCE(i.trl_id, 'UNKNOWN'),
          i.stp_arrivaldate,
          i.stp_schdtearliest,
          i.stp_status,
          d.stp_status
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
            INNER JOIN dbo.company c WITH(NOLOCK) ON c.cmp_id = i.cmp_id
   WHERE  i.stp_type = 'PUP'
     AND  c.cmp_port = 'Y'
     AND  (i.stp_status <> d.stp_status
      OR   i.stp_arrivaldate <> d.stp_arrivaldate
      OR   i.stp_schdtearliest <> d.stp_schdtearliest);

OPEN STOPS_CURSOR;
FETCH STOPS_CURSOR INTO @CmpId, @TrlId, @StpArrivalDate, @StpSchdtEarliest, @StpStatusInserted, @StpStatusDeleted;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @TrlId <> 'UNKNOWN' AND @InService IN ('OUTGATE', 'OUT GATE') AND (@StpStatusInserted <> 'DNE' OR @StpStatusDeleted <> 'DNE')
  BEGIN
    SET @exp_key = NULL;

    SELECT  @exp_key = MAX(exp_key)
      FROM  dbo.expiration WITH(NOLOCK)
     WHERE  exp_idtype = 'TRL'
       AND  exp_id = @TrlId
       AND  exp_code = 'INS';

    IF COALESCE(@exp_key, 0) <> 0
    BEGIN
      UPDATE  dbo.expiration
         SET  exp_expirationdate = CASE
                                     WHEN @InService IN ('OUTGATE', 'OUT GATE') AND @StpStatusInserted = 'DNE' AND @StpStatusDeleted = 'OPN' THEN @StpArrivalDate
                                     ELSE @StpSchdtEarliest
                                   END,
              exp_compldate = CASE
                                WHEN @InService IN ('OUTGATE', 'OUT GATE') AND @StpStatusInserted = 'DNE' AND @StpStatusDeleted = 'OPN' THEN @StpArrivalDate
                                ELSE @StpSchdtEarliest
                              END,
              exp_updateby = @tmwuser,
              exp_updateon = @GETDATE
       WHERE  exp_key = @exp_key;
    END
  END
    
  FETCH STOPS_CURSOR INTO @CmpId, @TrlId, @StpArrivalDate, @StpSchdtEarliest, @StpStatusInserted, @StpStatusDeleted;
END

CLOSE STOPS_CURSOR;
DEALLOCATE STOPS_CURSOR;
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_Intermodal_sp] TO [public]
GO
