SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [dbo].[trailersleg1or2]
as

select lgh_primary_trailer as trl,lgh_number,'trl1' trl1o2 from legheader
where ord_hdrnumber not in (select ord_hdrnumber from orderheader nolock where ord_Status  in ('CAN'))

union

select lgh_primary_pup as trl,lgh_number,'trl2' as trl1o2 from legheader
where lgh_Driver2 <> 'UNKNOWN'
and  ord_hdrnumber not in (select ord_hdrnumber from orderheader nolock where ord_Status  in ('CAN'))

union

select lgh_dolly as trl,lgh_number,'dolly' as trl1o2 from legheader
where lgh_dolly <> 'UNKNOWN'
and  ord_hdrnumber not in (select ord_hdrnumber from orderheader nolock where ord_Status  in ('CAN'))


GO
