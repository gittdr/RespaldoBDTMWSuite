SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/**
 *
 * NAME:
 * dbo.vSSRSRB_OrderStopDetail
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED created 
 **/

CREATE        View [dbo].[vSSRSRB_OrderStopDetail]
As

select * from vSSRSRB_StopDetail
where [Order Header Number] <> 0

GO
GRANT DELETE ON  [dbo].[vSSRSRB_OrderStopDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_OrderStopDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_OrderStopDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_OrderStopDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_OrderStopDetail] TO [public]
GO
