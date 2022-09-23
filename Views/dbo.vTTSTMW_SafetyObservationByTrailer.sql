SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE    View [dbo].[vTTSTMW_SafetyObservationByTrailer]

As

Select vTTSTMW_SafetyObservation.*,
       vTTSTMW_TrailerProfile.*

From   vTTSTMW_SafetyObservation Left Join vTTSTMW_TrailerProfile On vTTSTMW_TrailerProfile.[Trailer ID] = vTTSTMW_SafetyObservation.[Rpt Trailer1 ID]







GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyObservationByTrailer] TO [public]
GO
