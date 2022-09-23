SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  View [dbo].[vSSRSRB_SafetyLog]
As

/*************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_SafetyLog]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View bASed on the old [vSSRSRB_SafetyLog]
 
 *
**************************************************************

Sample call

SELECT * FROM [vSSRSRB_SafetyLog]

**************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created view
 ***********************************************************/

SELECT
	vSSRSRB_SafetyReport.*,
	slog_ID [Log ID],
	slog_Date as [Log Date],
	slog_UpdateBy as [Log Update By],
	slog_action as [Log Action]
From SafetyLog (NOLOCK)
JOIN vSSRSRB_SafetyReport
	ON SAFETYLOG.srp_ID = vSSRSRB_SafetyReport.[Rpt Report ID]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyLog] TO [public]
GO
