SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[StopsForDirectRoute] (@p_lghnbr int, @p_dcid varchar(8))
AS
/* used for interface to Direct Route where we pass all stops form all legs to be routed
   ignoring the stop at the dc (whihc is passed as the cmp_id)

Pull back all pickup an delivery stops that are not the DC company that the route is for

MODIFICATION LOG
8/25/11 CREATED PTS 58289 DPETE


*/

select stp_number,ord_hdrnumber
from stops
where lgh_number = @p_lghnbr
and stp_type in ('PUP','DRP')
and cmp_id <> @p_dcid
and ord_hdrnumber > 0


GO
GRANT EXECUTE ON  [dbo].[StopsForDirectRoute] TO [public]
GO
