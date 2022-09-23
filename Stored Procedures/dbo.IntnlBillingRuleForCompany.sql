SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[IntnlBillingRuleForCompany] @p_cmpid varchar(8)
As  
/*   
Created 8/19/10 SR 51802 DPETE Company eliminates stops ar mile son invoice when trip goes outside country
 
*/ 

Select 
ibr_country,
ibr_direction,
ibr_DistanceRule,
ibr_showstopsrule,
ibr_ident,
cmp_id
From IntnlBillingRule
Where cmp_id = @p_cmpid



GO
GRANT EXECUTE ON  [dbo].[IntnlBillingRuleForCompany] TO [public]
GO
