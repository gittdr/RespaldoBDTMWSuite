SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE   View [dbo].[vSSRSRB_SafetySpillByTrailer]

As
/**
 *
 * NAME:
 * dbo.[vSSRSRB_SafetySpillByTrailer]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 *Safety spills - trailer
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_SafetySpillByTrailer]


**************************************************************************
 * RETURNS:
 * Type of returned object or value
 *
 * RESULT SETS:
 * Safety spills - trailer
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
       vSSRSRB_TrailerProfile.*

From   vSSRSRB_SafetySpill Left Join vSSRSRB_TrailerProfile On vSSRSRB_TrailerProfile.[Trailer ID] = vSSRSRB_SafetySpill.[Rpt Trailer1 ID]


GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetySpillByTrailer] TO [public]
GO
