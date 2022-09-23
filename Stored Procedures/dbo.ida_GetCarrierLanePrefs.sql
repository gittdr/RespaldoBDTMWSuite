SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ida_GetCarrierLanePrefs] (
	@LaneId int
) as


select
	clc.car_id,
	clc.laneid
from core_carrierlanecommitment as clc (NOLOCK)
where
	clc.laneid = @laneid
	and clc.car_preferred = 'Y'


GO
GRANT EXECUTE ON  [dbo].[ida_GetCarrierLanePrefs] TO [public]
GO
