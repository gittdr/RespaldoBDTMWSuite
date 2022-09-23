SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE    View [dbo].[vTTSTMW_SafetySpillByDriver]

As

Select vTTSTMW_SafetySpill.*,
       vTTSTMW_DriverProfile.*

From   vTTSTMW_SafetySpill Left Join vTTSTMW_DriverProfile On vTTSTMW_DriverProfile.[Driver ID] = vTTSTMW_SafetySpill.[Rpt Driver1 ID]







GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetySpillByDriver] TO [public]
GO
