SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






CREATE    View [dbo].[vTTSTMW_SafetyObservationByDriver]

As

Select vTTSTMW_SafetyObservation.*,
       vTTSTMW_DriverProfile.*

From   vTTSTMW_SafetyObservation Left Join vTTSTMW_DriverProfile On vTTSTMW_DriverProfile.[Driver ID] = vTTSTMW_SafetyObservation.[Rpt DriverOrEmployee ID]









GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyObservationByDriver] TO [public]
GO
