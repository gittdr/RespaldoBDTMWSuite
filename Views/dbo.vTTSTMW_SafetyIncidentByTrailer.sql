SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE   View [dbo].[vTTSTMW_SafetyIncidentByTrailer]

As

Select vTTSTMW_SafetyIncident.*,
       vTTSTMW_TrailerProfile.*

From   vTTSTMW_SafetyIncident Left Join vTTSTMW_TrailerProfile On vTTSTMW_TrailerProfile.[Trailer ID] = vTTSTMW_SafetyIncident.[Rpt Trailer1 ID]




GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyIncidentByTrailer] TO [public]
GO
