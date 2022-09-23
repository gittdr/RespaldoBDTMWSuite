SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[create_trailerspottingdetail] (@stp_number	INT,
                                               @mov_number	INT,
                                               @lgh_number	INt,
                                               @ord_hdrnumber	INT,
                                               @stp_arrivaldate	DATETIME,
                                               @ord_billto	VARCHAR(8),
                                               @trl_id		VARCHAR(13)) 
AS

INSERT INTO trailerspottingdetail (ord_hdrnumber, mov_number, lgh_number, stp_number, 
                                   tsd_status, tsd_begin_date, tsd_stillspotted, tsd_billto, trl_id)
                           VALUES (@ord_hdrnumber, @mov_number, @lgh_number, @stp_number, 'PND',
                                   @stp_arrivaldate, 'Y', 'UNKNOWN', @trl_id)

GO
GRANT EXECUTE ON  [dbo].[create_trailerspottingdetail] TO [public]
GO
