SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE  View [dbo].[vTTSTMW_DriverNotes]

As


SELECT           vTTSTMW_DriverProfile.*,
		 vTTSTMW_Notes.*
                 

FROM        vTTSTMW_DriverProfile,
	    vTTSTMW_Notes

Where       [Source Table Key] = [Driver ID]
	    And
	    [Source Table] = 'manpowerprofile'





GO
GRANT SELECT ON  [dbo].[vTTSTMW_DriverNotes] TO [public]
GO
