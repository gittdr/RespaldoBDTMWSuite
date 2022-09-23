SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[vTTSTMW_CarrierHistory90DaysBack]

As

Select
	vTTSTMW_CarrierProfile.*,
	Crh_Carrier as [Carrier History ID],
	Crh_Total as [Carrier History Total Trips],
	Crh_OnTime [Carrier History Trips OnTime],
	Crh_percent [Carrier History OnTime Pct],
	Crh_AveFuel as [Carrier History Avg Fuel],
	Crh_AveTotal as [Carrier History Avg Total],
	Crh_AveAcc as [Carrier History Avg Accessorial]

From    CarrierHistory (NOLOCK) Left Join vTTSTMW_CarrierProfile (NOLOCK) On CarrierHistory.Crh_Carrier = vTTSTMW_CarrierProfile.[Carrier ID]
	




GO
GRANT SELECT ON  [dbo].[vTTSTMW_CarrierHistory90DaysBack] TO [public]
GO
