SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ida_GetOnTimePercent] 

as

select Crh_Carrier, Crh_OnTime, Crh_Total, Crh_Percent
from CarrierHistory (nolock)

GO
GRANT EXECUTE ON  [dbo].[ida_GetOnTimePercent] TO [public]
GO
