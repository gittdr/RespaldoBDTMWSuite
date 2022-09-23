SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE     View [dbo].[vTTSTMW_SafetyAccidentByTractor]

As

Select vTTSTMW_SafetyAccident.*,
       vTTSTMW_TractorProfile.*

From   vTTSTMW_SafetyAccident Left Join vTTSTMW_TractorProfile On vTTSTMW_TractorProfile.[Tractor] = vTTSTMW_SafetyAccident.[Rpt Tractor ID]







GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyAccidentByTractor] TO [public]
GO
