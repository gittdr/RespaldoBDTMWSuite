SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE    View [dbo].[vTTSTMW_SafetySpillByTractor]

As

Select vTTSTMW_SafetySpill.*,
       vTTSTMW_TractorProfile.*

From   vTTSTMW_SafetySpill Left Join vTTSTMW_TractorProfile On vTTSTMW_TractorProfile.[Tractor] = vTTSTMW_SafetySpill.[Rpt Tractor ID]






GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetySpillByTractor] TO [public]
GO
