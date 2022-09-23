SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE    View [dbo].[vSSRSRB_SafetyObservationByTrailer]

As
/**
 *
 * NAME:
 * dbo.vSSRSRB_SafetyObservationByTrailer
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Safety observations by trailer
 
 *
**************************************************************************

Sample call


select * from vSSRSRB_SafetyObservationByTrailer


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Safety observation by trailer
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
       vSSRSRB_TrailerProfile.*

From   vSSRSRB_SafetyObservation Left Join vSSRSRB_TrailerProfile On vSSRSRB_TrailerProfile.[Trailer ID] = vSSRSRB_SafetyObservation.[Rpt Trailer1 ID]


GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyObservationByTrailer] TO [public]
GO
