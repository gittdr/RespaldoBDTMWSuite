SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_ImagingVendor_sp]
(
  @inserted       UtStopsConsolidated   READONLY,
  @TripPakStatus  TMWTable_char6        READONLY
)
AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF EXISTS(SELECT 1 FROM @inserted WHERE ord_hdrnumber > 0)
BEGIN
  INSERT  dbo.ImageOrderList
    (
      ord_hdrnumber
    )
    SELECT  DISTINCT i.ord_hdrnumber
      FROM  @inserted i
     WHERE  i.ord_hdrnumber > 0
       AND  NOT EXISTS (SELECT  iol.ord_hdrnumber
                          FROM  dbo.ImageOrderList iol WITH(NOLOCK)
                         WHERE  iol.ord_hdrnumber = i.ord_hdrnumber)
       AND  EXISTS(SELECT oh.ord_status
                     FROM dbo.orderheader oh WITH(NOLOCK)
                    WHERE oh.ord_hdrnumber = i.ord_hdrnumber
                      AND oh.ord_status IN (SELECT KeyField FROM @TripPakStatus));
END
ELSE
BEGIN
    INSERT INTO dbo.imagemovelist
      (
        mov_number
      )
      SELECT  DISTINCT i.mov_number
        FROM  @inserted i
                INNER JOIN dbo.legheader lgh WITH(NOLOCK) ON lgh.mov_number = i.mov_number
                LEFT OUTER JOIN dbo.stops s WITH(NOLOCK) ON s.mov_number = lgh.mov_number AND s.ord_hdrnumber <> 0
                LEFT OUTER JOIN ImageMoveList iml WITH(NOLOCK) ON iml.mov_number = i.mov_number
       WHERE  lgh.lgh_outstatus IN (SELECT KeyField FROM @TripPakStatus)
         AND  s.stp_number IS NULL
         AND  iml.mov_number IS NULL;
END
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_ImagingVendor_sp] TO [public]
GO
