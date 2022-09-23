SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE     View [dbo].[vTTSTMW_SafetyAccidentByTrailer]

As

Select vTTSTMW_SafetyAccident.*,
       vTTSTMW_TrailerProfile.*

From   vTTSTMW_SafetyAccident Left Join vTTSTMW_TrailerProfile On vTTSTMW_TrailerProfile.[Trailer ID] = vTTSTMW_SafetyAccident.[Rpt Trailer1 ID]








GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyAccidentByTrailer] TO [public]
GO
