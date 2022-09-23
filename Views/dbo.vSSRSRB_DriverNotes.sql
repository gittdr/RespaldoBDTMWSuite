SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  View [dbo].[vSSRSRB_DriverNotes]

As
/**
 *
 * NAME:
 * dbo.[vSSRSRB_DriverNotes]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Combination of the driver and notes views
 *
**************************************************************************

Sample call


select * from vSSRSRB_DriverNotes


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Combination of the driver and notes views
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created SSRS view version of this view
 **/

SELECT           vSSRSRB_DriverProfile.*,
		 vSSRSRB_Notes.*
                 

FROM        vSSRSRB_DriverProfile,
	    vSSRSRB_Notes

Where       [Source Table Key] = [Driver ID]
	    And
	    [Source Table] = 'manpowerprofile'

GO
GRANT SELECT ON  [dbo].[vSSRSRB_DriverNotes] TO [public]
GO
