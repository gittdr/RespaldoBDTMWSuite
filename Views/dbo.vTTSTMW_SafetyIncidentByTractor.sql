SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE   View [dbo].[vTTSTMW_SafetyIncidentByTractor]

As

Select vTTSTMW_SafetyIncident.*,
       vTTSTMW_TractorProfile.*

From   vTTSTMW_SafetyIncident Left Join vTTSTMW_TractorProfile On vTTSTMW_TractorProfile.[Tractor] = vTTSTMW_SafetyIncident.[Rpt Tractor ID]






GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyIncidentByTractor] TO [public]
GO
