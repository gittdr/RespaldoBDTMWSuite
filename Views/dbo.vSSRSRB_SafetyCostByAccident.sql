SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[vSSRSRB_SafetyCostByAccident]
As

/**
 *
 * NAME:
 * dbo.[vSSRSRB_SafetyCostByAccident]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View bASed on the old [vSSRSRB_SafetyCostByAccident]
 
 *
**************************************************************************

Sample call


SELECT * FROM [vSSRSRB_SafetyCostByAccident]

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

Select
	vSSRSRB_SafetyAccident.*,
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
From SafetyCost (NOLOCK)
JOIN vSSRSRB_SafetyAccident WITH(NOLOCK)
	ON SAFETYCOST.srp_ID = vSSRSRB_SafetyAccident.[Report ID]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_SafetyCostByAccident] TO [public]
GO
