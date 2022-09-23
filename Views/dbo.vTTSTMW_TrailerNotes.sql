SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE  View [dbo].[vTTSTMW_TrailerNotes]

As


SELECT           vTTSTMW_TrailerProfile.*,
		 vTTSTMW_Notes.*
                 

FROM        vTTSTMW_TrailerProfile,
	    vTTSTMW_Notes

Where       [Source Table Key] = [Trailer ID]
	    And
	    [Source Table] = 'TrailerProfile'



GO
GRANT SELECT ON  [dbo].[vTTSTMW_TrailerNotes] TO [public]
GO
