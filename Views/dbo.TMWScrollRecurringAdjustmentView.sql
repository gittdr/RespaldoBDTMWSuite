SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollRecurringAdjustmentView] AS

SELECT  
	RA.RecurringAdjustmentId as 'RecurringAdjustmentId',
	RAH.RecurringAdjustmentHeaderId as 'RecurringAdjustmentHeaderId',
	RAType.Name as 'TypeName',	
	RA.Description as 'Description',
	RAHS.Name as 'HeaderStatus',
	RA.RecurringAdjustmentPriorityId as 'PriorityId',	
	RAP.Name as 'Priority',	
	RAH.AssignmentType as 'AssignmentType',
	RAH.AssignmentId as 'AssignmentId',
	RAH.Rate,
	RAH.MaxAmount,
	RAH.CreatedDate,
	RAH.IssuedDate,
	RA.GarnishmentCapPercent,
	RA.UseGrossPay,
	RAB.Name as 'Basis Name',
	RATerm.Name as 'Term',
	MPP.mpp_type1 as 'mpp_type1',
	MPP.mpp_type2 as 'mpp_type2',
	MPP.mpp_type3 as 'mpp_type3',
	MPP.mpp_type4 as 'mpp_type4',
	MPP.mpp_company as 'mpp_company',
	MPP.mpp_division as 'mpp_division',
	MPP.mpp_fleet as 'mpp_fleet',
	MPP.mpp_terminal as 'mpp_terminal',
	MPP.mpp_teamleader as 'mpp_teamleader',
	MPP.mpp_domicile as 'mpp_domicile',
	TRC.trc_type1 as 'trc_type1',
	TRC.trc_type2 as 'trc_type2',
	TRC.trc_type3 as 'trc_type3',
	TRC.trc_type4 as 'trc_type4',
	TRC.trc_company as 'trc_company',
	TRC.trc_division as 'trc_division',
	TRC.trc_fleet as 'trc_fleet',
	TRC.trc_terminal as 'trc_terminal',
	TRL.trl_type1 as 'trl_type1',
	TRL.trl_type2 as 'trl_type2',
	TRL.trl_type3 as 'trl_type3',
	TRL.trl_type4 as 'trl_type4',
	TRL.trl_company as 'trl_company',
	TRL.trl_division as 'trl_division',
	TRL.trl_fleet as 'trl_fleet',
	TRL.trl_terminal as 'trl_terminal',
	CAR.car_type1 as 'car_type1',
	CAR.car_type2 as 'car_type2',
	CAR.car_type3 as 'car_type3',
	CAR.car_type4 as 'car_type4',
    TPR.tpr_type as 'tpr_type',
    TPR.ThirdPartyType1 as 'ThirdPartyType1',
    TPR.ThirdPartyType2 as 'ThirdPartyType2',
    TPR.ThirdPartyType3 as 'ThirdPartyType3',
    TPR.ThirdPartyType4 as 'ThirdPartyType4',
    PTO.pto_type1 as 'pto_type1',
    PTO.pto_type2 as 'pto_type2',
    PTO.pto_type3 as 'pto_type3',
    PTO.pto_type4 as 'pto_type4'
FROM RecurringAdjustment RA (nolock) 
	left join RecurringAdjustmentHeader RAH (nolock) on (RA.RecurringAdjustmentId = RAH.RecurringAdjustmentId)    
	left join RecurringAdjustmentType RAType (nolock) on (RA.RecurringAdjustmentTypeId = RAType.RecurringAdjustmentTypeId)
	left join RecurringAdjustmentPriority RAP (nolock) on (RA.RecurringAdjustmentPriorityId = RAP.RecurringAdjustmentPriorityId)
	left join RecurringAdjustmentBasis RAB (nolock) on (RA.RecurringAdjustmentBasisId = RAB.RecurringAdjustmentBasisId)
	left join RecurringAdjustmentTerm RATerm (nolock) on (RA.RecurringAdjustmentTermId = RATerm.RecurringAdjustmentTermId)
	left join RecurringAdjustmentHeaderStatus RAHS (nolock) on (RAH.RecurringAdjustmentHeaderStatusId = RAHS.RecurringAdjustmentHeaderStatusId)
	left join manpowerprofile MPP (nolock) on (RAH.AssignmentId = MPP.mpp_id) and RAH.AssignmentType = 'DRV'
	left join tractorprofile TRC (nolock) on (RAH.AssignmentId = TRC.trc_number) and RAH.AssignmentType = 'TRC'
	left join trailerprofile TRL (nolock) on (RAH.AssignmentId = TRL.trl_number) and RAH.AssignmentType = 'TRL'
	left join carrier CAR (nolock) on (RAH.AssignmentId = CAR.car_id) and RAH.AssignmentType = 'CAR'
    left join thirdpartyprofile TPR (nolock) on (RAH.AssignmentId = TPR.tpr_id) AND RAH.AssignmentType = 'TPR'
	left join payto PTO (nolock) on (RAH.AssignmentId = PTO.pto_id) AND RAH.AssignmentType = 'PTO'
GO
GRANT SELECT ON  [dbo].[TMWScrollRecurringAdjustmentView] TO [public]
GO
