SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[update_trlstatus] @mov INTEGER
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @Trailers TABLE 
        (
		      trl_id          VARCHAR(13) NOT NULL,
		      evt_eventcode   VARCHAR(6)  NULL,
          trl_wash_status CHAR(1)     NULL,
          new_status      CHAR(1)     NULL
        )

DECLARE @trlid          VARCHAR(13),
        @eventcode      VARCHAR(6),
        @trlwashstatus  CHAR(1),
        @newstatus      CHAR(1)

DECLARE @TrailerCursor AS CURSOR

INSERT INTO @Trailers
  SELECT  TP.trl_id,
          NULL,
          TP.trl_wash_status,
          NULL
    FROM  (SELECT evt_eventcode,
                  evt_trailer1,
                  evt_trailer2,
                  evt_trailer3,
                  evt_trailer4,
                  evt_chassis,
                  evt_chassis2,
                  evt_dolly,
                  evt_dolly2
             FROM stops s
                    INNER JOIN event e ON e.stp_number = s.stp_number AND e.evt_sequence = 1
            WHERE s.mov_number = @mov) AS StopTrailers
          UNPIVOT (trl_id FOR trl_ids IN (evt_trailer1, evt_trailer2, evt_trailer3, evt_trailer4, evt_chassis, evt_chassis2, evt_dolly, evt_dolly2)) Trailers
            INNER JOIN trailerprofile TP ON TP.trl_id = Trailers.trl_id
   WHERE  TP.trl_id <> 'UNKNOWN';

UPDATE  Trailers
   SET  @eventcode = (SELECT TOP 1
                              E.evt_eventcode
                        FROM  stops S
                                INNER JOIN event E ON E.stp_number = S.stp_number
                       WHERE  S.mov_number = @mov
                         AND  E.evt_status = 'DNE'
                         AND  E.evt_eventcode IN ('LLD','DLD','PLD','DRL','WSH','DTW','PRP','STM')
                         AND  (E.evt_trailer1 = Trailers.trl_id
                          OR   E.evt_trailer1 = Trailers.trl_id
                          OR   E.evt_trailer1 = Trailers.trl_id
                          OR   E.evt_trailer1 = Trailers.trl_id
                          OR   E.evt_trailer1 = Trailers.trl_id
                          OR   E.evt_trailer1 = Trailers.trl_id
                          OR   E.evt_trailer1 = Trailers.trl_id
                          OR   E.evt_trailer1 = Trailers.trl_id)
                      ORDER BY S.stp_mfh_sequence DESC)
  FROM  @Trailers Trailers;

UPDATE  Trailers
   SET  Trailers.new_status = CASE
                                WHEN COALESCE(ECT.ect_event_like_abbr, Trailers.evt_eventcode) IN ('DTW', 'WSH') THEN 'Y'
                                WHEN COALESCE(ECT.ect_event_like_abbr, Trailers.evt_eventcode) IN ('LLD', 'DLD', 'PLD', 'DRL', 'PRP','STM') THEN 'N'
                                ELSE Trailers.trl_wash_status
                              END
  FROM  @Trailers Trailers
          INNER JOIN eventcodetable ECT ON ECT.abbr = Trailers.evt_eventcode

SET @TrailerCursor = CURSOR FAST_FORWARD FOR
  SELECT trl_id, COALESCE(evt_eventcode, 'XXX'), COALESCE(trl_wash_status, 'Z'), COALESCE(new_status, 'Z') FROM @Trailers;
      
OPEN @TrailerCursor;

FETCH NEXT FROM @TrailerCursor INTO @trlid, @eventcode, @trlwashstatus, @newstatus;

WHILE @@FETCH_STATUS = 0
BEGIN
  EXECUTE trl_expstatus @trlid;

  IF @eventcode <> 'XXX' AND @trlwashstatus <> @newstatus 
  BEGIN
    UPDATE  trailerprofile
       SET  trl_wash_status = @newstatus
     WHERE  trl_id = @trlid
  END

  FETCH NEXT FROM @TrailerCursor INTO @trlid, @eventcode, @trlwashstatus, @newstatus;
END

CLOSE @TrailerCursor;
DEALLOCATE @TrailerCursor;

GO
GRANT EXECUTE ON  [dbo].[update_trlstatus] TO [public]
GO
