SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[driversleg1or2]
as

select lgh_driver1 as drv,lgh_number,'drv1' drv1o2 from legheader
where ord_hdrnumber not in (select ord_hdrnumber from orderheader nolock where ord_Status  in ('CAN'))

union

select lgh_driver2 as drv,lgh_number,'drv2' as drv1o2 from legheader
where lgh_Driver2 <> 'UNKNOWN'
and  ord_hdrnumber not in (select ord_hdrnumber from orderheader nolock where ord_Status  in ('CAN'))

GO
