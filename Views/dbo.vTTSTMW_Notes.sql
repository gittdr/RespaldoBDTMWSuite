SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE    View [dbo].[vTTSTMW_Notes]

As


SELECT           not_number as [Note Number], 
                 autonote as [Auto Note], 
                 not_text as [Note], 
                 not_type as [Note Type], 
                 not_urgent as [Urgent], 
                 not_senton as [Notes Sent On Date], 
                 not_sentby as [Sent By], 
                 not_expires as [Notes Expiration Date], 
                 not_forwardedfrom as [Forwarded From],
                 ntb_table as [Source Table], 
                 nre_tablekey as [Source Table Key], 
                 not_sequence as [Notes Sequence], 
                 last_updatedby as [Notes Updated By],  
                 last_updatedatetime as [Notes Updated Date]

FROM         dbo.notes (NOLOCK)







GO
GRANT SELECT ON  [dbo].[vTTSTMW_Notes] TO [public]
GO
