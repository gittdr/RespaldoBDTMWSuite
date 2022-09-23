SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE  View [dbo].[vTTSTMW_SafetyLog]

As

Select
	vTTSTMW_SafetyReport.*,
	slog_ID [Log ID],
	slog_Date as [Log Date],
	slog_UpdateBy as [Log Update By],
	slog_action as [Log Action]

From    SafetyLog (NOLOCK), 
        vTTSTMW_SafetyReport

Where   vTTSTMW_SafetyReport.[Rpt Report ID] = SafetyLog.srp_id


GO
GRANT SELECT ON  [dbo].[vTTSTMW_SafetyLog] TO [public]
GO
