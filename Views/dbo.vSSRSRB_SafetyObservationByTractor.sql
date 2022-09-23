SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE     View [dbo].[vSSRSRB_SafetyObservationByTractor]

As
/**
 *
 * NAME:
 * dbo.vSSRSRB_SafetyObservationByTractor
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Safety observations by tractor
 
 *
**************************************************************************

Sample call


select * from vSSRSRB_SafetyObservationByTractor


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Safety observation by tractor
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
Select vSSRSRB_SafetyObservation.*,
       vSSRSRB_TractorProfile.*

From   vSSRSRB_SafetyObservation Left Join vSSRSRB_TractorProfile On vSSRSRB_TractorProfile.[Tractor] = vSSRSRB_SafetyObservation.[Rpt Tractor ID]


GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyObservationByTractor] TO [public]
GO
