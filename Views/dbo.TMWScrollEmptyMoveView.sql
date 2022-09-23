SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollEmptyMoveView] AS
SELECT
lgh_number,
lgh_startdate,
lgh_enddate,
cmp_id_start,
cmp_id_end,
lgh_startcty_nmstct,
lgh_endcty_nmstct,
lgh_startregion1,
lgh_endregion1,
lgh_outstatus,
lgh_instatus,
lgh_startregion2,
lgh_startregion3,
lgh_startregion4,
lgh_endregion2,
lgh_endregion3,
lgh_endregion4,
lgh_driver1,
lgh_driver2,
lgh_tractor,
lgh_primary_trailer,
trc_type1,
trc_type2,
trc_type3,
trc_type4,
trl_type1,
trl_type2,
trl_type3,
trl_type4,
lgh_carrier,
lgh_endstate,
lgh_startstate,
lgh_originzip,
lgh_destzip

from legheader (nolock) 
where ord_hdrnumber = 0

GO
GRANT DELETE ON  [dbo].[TMWScrollEmptyMoveView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollEmptyMoveView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollEmptyMoveView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollEmptyMoveView] TO [public]
GO
