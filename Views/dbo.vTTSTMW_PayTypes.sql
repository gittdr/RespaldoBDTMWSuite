SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE       View [dbo].[vTTSTMW_PayTypes]

As

SELECT     pyt_number AS 'PayType Number', 
           pyt_itemcode as 'Pay Type', 
           pyt_description as 'Pay Type Description', 
           pyt_basis as 'Basis', 
           pyt_basisunit as 'Base Unit', 
           pyt_quantity as 'Quantity', 
           pyt_rateunit as 'Rate Unit', 
           pyt_unit as 'Unit', 
           pyt_rate as 'Rate', 
           pyt_pretax as 'PreTax', 
           pyt_minus as 'Minus', 
           pyt_editflag as 'Edit Flag', 
           pyt_pr_glnum as 'Pr Gl Number', 
           pyt_ap_glnum as 'Ap Gl Number',
           pyt_status as 'Status',  
           pyt_agedays as 'Age Days', 
           pyt_fee1 as 'Fee1', 
           pyt_fee2 as 'Fee2', 
           pyt_accept_negatives as 'Accept Negatives', 
           pyt_fservprocess as 'FServe Process', 
           pyt_expchk as 'Express Check', 
           pyt_systemcode as 'System Code', 
           pyt_maxrate as 'Max Rate', 
           pyt_maxenf as 'Max Enf', 
           pyt_minrate as 'Min Rate', 
           pyt_minenf as 'Min Enf', 
           pyt_zeroenf as 'Zero Enf', 
           pyt_incexcoth as 'Inc Excoth', 
           pyt_retired as 'Retired', 
           pyt_paying_to as 'Paying To', 
           pyt_offset_percent as 'Offset Percent', 
           pyt_offset_for as 'Offset For', 
           pyt_editindispatch as 'Edit In Dispatch', 
           pyt_class as 'Class', 
           pyt_classflag as 'Class Flag', 
           pyt_group as 'Group',
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [Authcode Required]
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --pyt_authcode_required as [Authcode Required]
	   --<TTS!*!TMW><End><FeaturePack=Euro>
 

from PayType (NOLOCK)








GO
GRANT SELECT ON  [dbo].[vTTSTMW_PayTypes] TO [public]
GO
