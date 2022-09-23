SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetStateMiles]
( @TariffInputXml  XML
)
AS

BEGIN

    -- Determine current options and change for XQuery to work in any environment
    DECLARE @options INT
    DECLARE @QUOTED_IDENTIFIER          CHAR(1)
    DECLARE @CONCAT_NULL_YIELDS_NULL    CHAR(1)
    DECLARE @ANSI_WARNINGS              CHAR(1)
    DECLARE @ANSI_PADDING               CHAR(1)
    DECLARE @ANSI_NULLS                 CHAR(1)

    SELECT @options = @@OPTIONS

    SELECT @QUOTED_IDENTIFIER = 'N'
    IF ( (256 & @options) = 256 )
          SELECT @QUOTED_IDENTIFIER = 'Y'

    SELECT @CONCAT_NULL_YIELDS_NULL = 'N'
    IF ( (4096 & @options) = 4096 )
          SELECT @CONCAT_NULL_YIELDS_NULL = 'Y'

    SELECT @ANSI_WARNINGS = 'N'
    IF ( (8 & @options) = 8 )
          SELECT @ANSI_WARNINGS = 'Y'

    SELECT @ANSI_PADDING = 'N'
    IF ( (16 & @options) = 16 )
          SELECT @ANSI_PADDING = 'Y'

    SELECT @ANSI_NULLS = 'N'
    IF ( (32 & @options) = 32 )
          SELECT @ANSI_NULLS = 'Y'

    SET QUOTED_IDENTIFIER ON
    SET ANSI_WARNINGS ON
    SET ANSI_PADDING ON
    SET ANSI_NULLS ON
    SET CONCAT_NULL_YIELDS_NULL ON

   -------------------------------------------------
   DECLARE @maxid                      INT
   DECLARE @id                         INT
   DECLARE @StopNumber                 INT
   DECLARE @TripMileageTableId         INT
   DECLARE @stp_LoadStatus             VARCHAR(10)

   DECLARE @StateMilesByStop TABLE
   ( id                 INT IDENTITY
   , StopNumber         INT
   , TripMileageTableId INT
   )

   DECLARE @StateMilesTemp TABLE
   ( StateCode             CHAR(2)
   , LoadedMiles           FLOAT          DEFAULT 0
   , EmptyMiles            FLOAT          DEFAULT 0
   , TotalMiles            FLOAT          DEFAULT 0
   , LoadedTollMiles       FLOAT          DEFAULT 0
   , EmptyTollMiles        FLOAT          DEFAULT 0
   , TotalTollMiles        FLOAT          DEFAULT 0
   )

   BEGIN
      INSERT INTO @StateMilesByStop
      ( StopNumber
      , TripMileageTableId
      )
      SELECT col.query('./StopNumber').value('.', 'INT')
           , col.query('./TripMileageTableId').value('.', 'INT')
       FROM @TariffInputXml.nodes('/Stop') AS ref(col)
   END

   SELECT @maxid = MAX(id) FROM @StateMilesByStop
   SELECT @id = 0
   WHILE @id < @maxid
   BEGIN
      SELECT @id = @id + 1
      SELECT @StopNumber = StopNumber
           , @TripMileageTableId = TripMileageTableId
        FROM @StateMilesByStop
       WHERE id = @id

      IF IsNull(@TripMileageTableId,0) = 0 CONTINUE

      SELECT @stp_LoadStatus = stp_LoadStatus
        FROM stops
       WHERE stp_Number = @StopNumber

      INSERT INTO @StateMilesTemp
      ( StateCode
      , LoadedMiles
      , EmptyMiles
      , TotalMiles
      , LoadedTollMiles
      , EmptyTollMiles
      , TotalTollMiles
      )
      SELECT sm.sm_state
           , SUM(IsNull((CASE WHEN @stp_LoadStatus = 'LD' THEN sm.sm_miles ELSE 0 END),0))
           , SUM(IsNull((CASE WHEN @stp_LoadStatus <> 'LD' THEN sm.sm_miles ELSE 0 END),0))
           , SUM(IsNull(sm.sm_miles,0))
           , SUM(IsNull((CASE WHEN @stp_LoadStatus = 'LD' THEN sm.sm_tollmiles ELSE 0 END),0))
           , SUM(IsNull((CASE WHEN @stp_LoadStatus <> 'LD' THEN sm.sm_tollmiles ELSE 0 END),0))
           , SUM(IsNull(sm.sm_tollmiles,0))
        FROM statemiles sm
       WHERE sm.mt_Identity = @TripMileageTableId
      GROUP BY sm.sm_state
   END

    -- Restore options to avoid disturbing the environment
    IF @QUOTED_IDENTIFIER = 'N'
          SET QUOTED_IDENTIFIER OFF

    IF @ANSI_WARNINGS = 'N'
          SET ANSI_WARNINGS OFF

    IF @ANSI_PADDING = 'N'
          SET ANSI_PADDING OFF

    IF @ANSI_NULLS = 'N'
          SET ANSI_NULLS OFF

    IF @CONCAT_NULL_YIELDS_NULL = 'N'
          SET CONCAT_NULL_YIELDS_NULL OFF

   --Return
   SELECT StateCode              AS StateCode
        , SUM(LoadedMiles)       AS LoadedMiles
        , SUM(EmptyMiles)        AS EmptyMiles
        , SUM(TotalMiles)        AS TotalMiles
        , SUM(LoadedTollMiles)   AS LoadedTollMiles
        , SUM(EmptyTollMiles)    AS EmptyTollMiles
        , SUM(TotalTollMiles)    AS TotalTollMiles
     FROM @StateMilesTemp
   GROUP BY StateCode

    RETURN
END
GO
GRANT EXECUTE ON  [dbo].[sp_GetStateMiles] TO [public]
GO
