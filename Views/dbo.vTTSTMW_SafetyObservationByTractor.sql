SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE     View [dbo].[vTTSTMW_SafetyObservationByTractor]

As

Select vTTSTMW_SafetyObservation.*,
       vTTSTMW_TractorProfile.*

From   vTTSTMW_SafetyObservation Left Join vTTSTMW_TractorProfile On vTTSTMW_TractorProfile.[Tractor] = vTTSTMW_SafetyObservation.[Rpt Tractor ID]







GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyObservationByTractor] TO [public]
GO
