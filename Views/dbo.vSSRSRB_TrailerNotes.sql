SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



Create  View [dbo].[vSSRSRB_TrailerNotes]
As

/**
 *
 * NAME:
 * dbo.vSSRSRB_TrailerNotes
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data for TrailerNotes
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Created 
 **/
 

SELECT  vSSRSRB_TrailerProfile.*,vSSRSRB_Notes.*
FROM    vSSRSRB_TrailerProfile,
	    vSSRSRB_Notes

Where   [Source Table Key] = [Trailer ID]
	    And [Source Table] = 'TrailerProfile'

GO
GRANT SELECT ON  [dbo].[vSSRSRB_TrailerNotes] TO [public]
GO
