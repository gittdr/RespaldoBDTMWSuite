SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vSSRSRB_CarrierHistory90DaysBack]
AS

/**
 *
 * NAME:
 * dbo.vSSRSRB_CarrierHistory90DaysBack
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_CarrierHistory90DaysBack
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_CarrierHistory90DaysBack]

**************************************************************************
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
 * 3/19/2014 DW created new view
 **/

SELECT
	cp.*,
	Crh_Carrier AS [Carrier History ID],
	Crh_Total AS [Carrier History Total Trips],
	Crh_OnTime [Carrier History Trips OnTime],
	Crh_percent [Carrier History OnTime Pct],
	Crh_AveFuel AS [Carrier History Avg Fuel],
	Crh_AveTotal AS [Carrier History Avg Total],
	Crh_AveAcc AS [Carrier History Avg Accessorial]

FROM  CarrierHistory ch  with(NOLOCK) 
LEFT JOIN vSSRSRB_CarrierProfile cp with(NOLOCK) 
	On ch.Crh_Carrier = cp.[Carrier ID]
GO
GRANT DELETE ON  [dbo].[vSSRSRB_CarrierHistory90DaysBack] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_CarrierHistory90DaysBack] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_CarrierHistory90DaysBack] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_CarrierHistory90DaysBack] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_CarrierHistory90DaysBack] TO [public]
GO
