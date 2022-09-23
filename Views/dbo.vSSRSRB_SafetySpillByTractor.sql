SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE    View [dbo].[vSSRSRB_SafetySpillByTractor]

As
/**
 *
 * NAME:
 * dbo.[vSSRSRB_SafetySpillByTractor]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 *Safety spills - tractor
 
 *
**************************************************************************

Sample call


select * from vSSRSRB_SafetySpillByTractor


**************************************************************************
 * RETURNS:
 * Type of returned object or value
 *
 * RESULT SETS:
 * Safety spills - tractor
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created example blurb
 **/
Select vSSRSRB_SafetySpill.*,
       vSSRSRB_TractorProfile.*

From   vSSRSRB_SafetySpill Left Join vSSRSRB_TractorProfile On vSSRSRB_TractorProfile.[Tractor] = vSSRSRB_SafetySpill.[Rpt Tractor ID]


GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetySpillByTractor] TO [public]
GO
