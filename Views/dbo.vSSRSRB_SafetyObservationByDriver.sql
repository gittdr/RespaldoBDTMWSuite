SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE    View [dbo].[vSSRSRB_SafetyObservationByDriver]

As
/**
 *
 * NAME:
 * dbo.vSSRSRB_SafetyObservationByDriver
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Safety observations by driver
 
 *
**************************************************************************

Sample call


select * from vSSRSRB_SafetyObservationByDriver


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Safety observation by driver
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
       vSSRSRB_DriverProfile.*

From   vSSRSRB_SafetyObservation Left Join vSSRSRB_DriverProfile On vSSRSRB_DriverProfile.[Driver ID] = vSSRSRB_SafetyObservation.[Rpt DriverOrEmployee ID]


GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyObservationByDriver] TO [public]
GO
