SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_TrailerSpotting_sp]
(
  @inserted UtStopsConsolidated READONLY,
  @deleted  UtStopsConsolidated READONLY
)
AS

SET NOCOUNT ON

DECLARE @stp_number       INTEGER,
        @mov_number       INTEGER,
        @lgh_number       INTEGER,
        @ord_hdrnumber    INTEGER,
        @stp_arrivaldate  DATETIME,
        @ord_billto       VARCHAR(8),
        @trl_id           VARCHAR(13)

DECLARE StopCursor CURSOR FOR
  SELECT  i.stp_number,
          i.mov_number,
          i.lgh_number,
          i.ord_hdrnumber,
          i.stp_arrivaldate,
          oh.ord_billto,
          i.trl_id
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
            LEFT OUTER JOIN dbo.orderheader oh WITH(NOLOCK) ON oh.ord_hdrnumber = i.ord_hdrnumber
   WHERE  i.stp_status = 'DNE'
     AND  d.stp_status = 'OPN'
     AND  i.stp_event = 'DRL';
    
OPEN StopCursor;
    
FETCH NEXT FROM StopCursor INTO @stp_number, @mov_number, @lgh_number, @ord_hdrnumber, @stp_arrivaldate, @ord_billto, @trl_id;

WHILE @@FETCH_STATUS = 0
BEGIN
  EXEC dbo.create_trailerspottingdetail @stp_number, @mov_number, @lgh_number, @ord_hdrnumber, @stp_arrivaldate, @ord_billto, @trl_id;
        
  FETCH NEXT FROM StopCursor INTO @stp_number, @mov_number, @lgh_number, @ord_hdrnumber, @stp_arrivaldate, @ord_billto, @trl_id;
END
    
CLOSE StopCursor;
DEALLOCATE StopCursor;
    
DELETE  dbo.TrailerSpottingDetail
  FROM  @inserted i
          INNER JOIN @deleted d ON d.stp_number = i.stp_number
          INNER JOIN dbo.TrailerSpottingDetail tsd WITH(NOLOCK) ON tsd.stp_number = i.stp_number
 WHERE  i.stp_status = 'OPN'
   AND  d.stp_status = 'DNE'
   AND  i.stp_event = 'DRL'
   AND  tsd.tsd_status IN ('PND', 'HLD')
   AND  tsd.id_num > 0;
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_TrailerSpotting_sp] TO [public]
GO
