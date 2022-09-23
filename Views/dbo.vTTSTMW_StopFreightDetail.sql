SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE View [dbo].[vTTSTMW_StopFreightDetail]

As

Select *

From   vTTSTMW_StopDetail,vTTSTMW_FreightDetail

Where  vTTSTMW_StopDetail.[Stop Number] = vTTSTMW_FreightDetail.[Freight Detail Stop Number]


GO
GRANT SELECT ON  [dbo].[vTTSTMW_StopFreightDetail] TO [public]
GO
