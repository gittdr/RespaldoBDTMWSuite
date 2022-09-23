SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vSSRSRB_SafetySpillByDriver]
AS

/*****************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_SafetySpillByDriver]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vTTSTMW_SafetySpillByDriver
 *
******************************************************************

Sample call
	
select * from [vSSRSRB_SafetySpill]

******************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created new view
 *****************************************************************/

SELECT vSSRSRB_SafetySpill.*,
       vSSRSRB_DriverProfile.*
FROM    vSSRSRB_SafetySpill 
LEFT JOIN vSSRSRB_DriverProfile 
	On vSSRSRB_DriverProfile.[Driver ID] = vSSRSRB_SafetySpill.[Rpt Driver1 ID]

GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetySpillByDriver] TO [public]
GO
