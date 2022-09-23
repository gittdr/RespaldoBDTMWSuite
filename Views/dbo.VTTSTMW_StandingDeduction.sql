SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE  View [dbo].[VTTSTMW_StandingDeduction] 

As

Select
	[std_number] as [Standing Deduction Number],
	[sdm_itemcode] as [Standing Deduction Type],
	[std_description] as [Standing Deduction Description],
	[std_balance]  as [Balance] ,
	[std_startbalance] as [Start Balance] ,
	[std_endbalance] as [End Balance] ,
	[std_deductionrate] as [Deduction Rate] ,
	[std_reductionrate] as [Reduction Rate] ,
	[std_status] as [Standing Deduction Status]   ,
	[std_issuedate] as [Issue Date]  ,
	[std_closedate] as [Close Date]  ,
	[asgn_type] as [Assignment Type]  ,
	[asgn_id]  as [Assignment ID] ,
	[std_priority] as [Standing Deduction Priority],
	[std_lastdeddate] as [Last Deduction Date]  ,
	[std_lastreddate] as [Last Reduction Date]  ,
	[std_lastcompdate] as [Last Comp Date]  ,
	[std_lastcalcdate]  as [Last Calc Date] ,
	[std_lastdedqty]  as [Last Deduction Qty],
	[std_lastredqty] as [Last Reduction Qty],
	[std_lastcompqty] as [Last Comp Qty]  ,
	[std_lastcalcqty]  as [Last Calc Qty] ,
	[std_priordeddate] as [Prior Deduction Date]  ,
	[std_priorreddate] as [Prior Reduction Date]  ,
	[std_priorcompdate] as [Prior Comp Date],
	[std_priorcalcdate]  as [Prior Calc Date] ,
	[std_priordedqty] as [Prior Deduction Qty]  ,
	[std_priorredqty] as [Prior Reduction Qty]  ,
	[std_priorcompqty] as [Prior Comp Qty]  ,
	[std_priorcalcqty] as [Prior Calc Qty]  ,
	[std_priorbalance]  as [Prior Balance],
	CASE 
    		WHEN asgn_type = 'DRV'  THEN IsNull((Select mpp_terminal from manpowerprofile (NOLOCK) where asgn_id = manpowerprofile.mpp_id),'') 
      	End as [Driver Terminal],
	CASE 
    		WHEN asgn_type = 'TRC'  THEN IsNull((Select trc_terminal from tractorprofile (NOLOCK) where asgn_id = tractorprofile.trc_number),'') 
      	End as [Tractor Terminal],

	CASE 
    		WHEN asgn_type = 'DRV'  THEN IsNull((Select mpp_division from manpowerprofile (NOLOCK) where asgn_id = manpowerprofile.mpp_id),'') 
      	End as [Driver Division],
	CASE 
    		WHEN asgn_type = 'TRC'  THEN IsNull((Select trc_division from tractorprofile (NOLOCK) where asgn_id = tractorprofile.trc_number),'') 
      	End as [Tractor Division]

       --'DrvType1' = IsNull((Select mpp_type1 from manpowerprofile (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
       --'DrvType2' = IsNull((Select mpp_type2 from manpowerprofile (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
       --'DrvType3' = IsNull((Select mpp_type3 from manpowerprofile (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
       --'DrvType4' = IsNull((Select mpp_type4 from manpowerprofile (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
 
	 

From    standingdeduction (NOLOCK)




GO
GRANT SELECT ON  [dbo].[VTTSTMW_StandingDeduction] TO [public]
GO
