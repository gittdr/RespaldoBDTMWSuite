SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE     View [dbo].[vTTSTMW_SafetyAccidentByDriver]

As

Select vTTSTMW_SafetyAccident.*,
       vTTSTMW_DriverProfile.*

From   vTTSTMW_SafetyAccident Left Join vTTSTMW_DriverProfile On vTTSTMW_DriverProfile.[Driver ID] = vTTSTMW_SafetyAccident.[Rpt Driver1 ID]








GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyAccidentByDriver] TO [public]
GO
