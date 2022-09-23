SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE    View [dbo].[vSSRSRB_Notes]

As
/**
 *
 * NAME:
 * dbo.[vSSRSRB_Notes]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Notes table view
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_Notes]


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Notes table view
 *
 * PARAMETERS:
 * n/a
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created SSRS view version of this view
 **/

SELECT           not_number as [Note Number], 
                 autonote as [Auto Note], 
                 not_text as [Note], 
                 not_type as [Note Type], 
                 not_urgent as [Urgent], 
                 not_senton as [Notes Sent On Date], 
                 (Cast(Floor(Cast(not_senton  as float))as smalldatetime)) AS [Notes Sent On Date Only],
                 not_sentby as [Sent By], 
                 not_expires as [Notes Expiration Date], 
                 (Cast(Floor(Cast(not_expires  as float))as smalldatetime)) AS [Notes Expiration Date Only],
                 not_forwardedfrom as [Forwarded From],
                 ntb_table as [Source Table], 
                 nre_tablekey as [Source Table Key], 
                 not_sequence as [Notes Sequence], 
                 last_updatedby as [Notes Updated By],  
                 last_updatedatetime as [Notes Updated Date],
                 (Cast(Floor(Cast(last_updatedatetime as float))as smalldatetime)) AS [Notes Updated Date Only]

FROM         dbo.notes WITH (NOLOCK)

GO
GRANT SELECT ON  [dbo].[vSSRSRB_Notes] TO [public]
GO
