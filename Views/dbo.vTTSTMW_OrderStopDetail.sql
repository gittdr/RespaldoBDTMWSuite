SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE        View [dbo].[vTTSTMW_OrderStopDetail]
As

select * from vTTSTMW_StopDetail
where [Order Header Number] <> 0





















GO
GRANT SELECT ON  [dbo].[vTTSTMW_OrderStopDetail] TO [public]
GO
