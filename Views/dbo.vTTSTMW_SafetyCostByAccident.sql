SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE     View [dbo].[vTTSTMW_SafetyCostByAccident]

As

Select
	vTTSTMW_SafetyAccident.*,
	sc_ID as [Safety Cost ID],
	sc_Sequence as [Safety Cost Sequence],
	sc_DateEntered as [Date Entered],
	sc_DateOfService as [DateOfService],
	sc_DescOfService [DescOfService],
	sc_PaidByCmp as [Paid By Company],
	sc_PaidByIns as [Paid By Insurance],
	sc_RecoveredCost as [Recovered Cost],
	sc_CostType1 as [Cost Type1],
	sc_CostType2 as [Cost Type2]

From    SafetyCost (NOLOCK), 
	vTTSTMW_SafetyAccident

Where    vTTSTMW_SafetyAccident.[Report ID] =SafetyCost.srp_id
	






GO
