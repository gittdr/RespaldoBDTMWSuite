SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE   View [dbo].[vSSRSRB_SafetyIncidentByTrailer]

As
/**
 *
 * NAME:
 * dbo.vSSRSRB_SafetyIncidentBytrailer
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * trailer and Incident view combination
 
 *
**************************************************************************

Sample call


select * from vSSRSRB_SafetyIncidentBytrailer


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * trailer and Incident view combination
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
       vSSRSRB_TrailerProfile.*

From   vSSRSRB_SafetyIncident 
Left Join vSSRSRB_TrailerProfile On vSSRSRB_TrailerProfile.[Trailer ID] = vSSRSRB_SafetyIncident.[Rpt Trailer1 ID]

GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyIncidentByTrailer] TO [public]
GO
