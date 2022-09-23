SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_load_drv_trc_trl_vt]
(
			@order_number 	int,
			@type	varchar(3)
)
AS
/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure.  

*/

BEGIN

    SELECT DISTINCT  assetassignment.asgn_id
    FROM assetassignment
        INNER JOIN event
        ON assetassignment.evt_number = event.evt_number
        INNER JOIN stops
        ON event.stp_number = stops.stp_number
        INNER JOIN orderheader
        ON stops.mov_number = orderheader.mov_number
    WHERE assetassignment.asgn_type = @type
    AND orderheader.ord_hdrnumber = @order_number
    
END
GO
GRANT EXECUTE ON  [dbo].[d_load_drv_trc_trl_vt] TO [public]
GO
