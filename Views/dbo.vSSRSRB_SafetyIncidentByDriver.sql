SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE   View [dbo].[vSSRSRB_SafetyIncidentByDriver]

As
/**
 *
 * NAME:
 * dbo.vSSRSRB_SafetyIncidentByDriver
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Driver and Incident view combination
 
 *
**************************************************************************

Sample call


select * from vSSRSRB_SafetyIncidentByDriver


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Driver and Incident view combination
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created SSRS version of this view
 **/

Select vSSRSRB_SafetyIncident.*,
       vSSRSRB_DriverProfile.*

From   vSSRSRB_SafetyIncident Left Join vSSRSRB_DriverProfile On vSSRSRB_DriverProfile.[Driver ID] = vSSRSRB_SafetyIncident.[Mpp Or EeID]


GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyIncidentByDriver] TO [public]
GO
