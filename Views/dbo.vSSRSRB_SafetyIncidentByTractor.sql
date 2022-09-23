SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE   View [dbo].[vSSRSRB_SafetyIncidentByTractor]

As
/**
 *
 * NAME:
 * dbo.vSSRSRB_SafetyIncidentByTractor
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Tractor and Incident view combination
 
 *
**************************************************************************

Sample call


select * from vSSRSRB_SafetyIncidentByTractor


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Tractor and Incident view combination
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
       vSSRSRB_TractorProfile.*

From   vSSRSRB_SafetyIncident Left Join vSSRSRB_TractorProfile On vSSRSRB_TractorProfile.[Tractor] = vSSRSRB_SafetyIncident.[Rpt Tractor ID]


GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyIncidentByTractor] TO [public]
GO
