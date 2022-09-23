SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE   View [dbo].[vTTSTMW_SafetySpillByTrailer]

As

Select vTTSTMW_SafetySpill.*,
       vTTSTMW_TrailerProfile.*

From   vTTSTMW_SafetySpill Left Join vTTSTMW_TrailerProfile On vTTSTMW_TrailerProfile.[Trailer ID] = vTTSTMW_SafetySpill.[Rpt Trailer1 ID]



GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetySpillByTrailer] TO [public]
GO
