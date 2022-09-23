SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE   View [dbo].[vTTSTMW_SafetyIncidentByDriver]

As

Select vTTSTMW_SafetyIncident.*,
       vTTSTMW_DriverProfile.*

From   vTTSTMW_SafetyIncident Left Join vTTSTMW_DriverProfile On vTTSTMW_DriverProfile.[Driver ID] = vTTSTMW_SafetyIncident.[Mpp Or EeID]






GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyIncidentByDriver] TO [public]
GO
