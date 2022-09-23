SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE       View [dbo].[vTTSTMW_ChargeTypes]

As

--Revision History
--1. Added Euro/Penske specific fields
--   Ver 5.5 LBK

SELECT     ChargeType.cht_number as 'Charge Type Number', 
           ChargeType.cht_itemcode as 'Charge Type', 
           ChargeType.cht_description as 'Charge Type Description', 
           ChargeType.cht_primary as 'Charge Type Primary',  
           ChargeType.cht_basis as 'Basis', 
           ChargeType.cht_basisunit as 'Basis Unit', 
           ChargeType.cht_basisper as 'Basis Per', 
           ChargeType.cht_quantity as 'Quantity', 
           ChargeType.cht_rateunit as 'Rate Unit', 
           ChargeType.cht_unit as 'Unit', 
           ChargeType.cht_rate as 'Rate', 
           ChargeType.cht_editflag as 'Edit Flag', 
           ChargeType.cht_glnum as 'GL Number',
           ChargeType.cht_sign as 'Sign', 
           ChargeType.cht_systemcode as 'System Code', 
           ChargeType.cht_edicode as 'Edi Code', 
           ChargeType.cht_taxtable1 as 'Tax Table1', 
           ChargeType.cht_taxtable2 as 'Tax Table2', 
           ChargeType.cht_taxtable3 as 'Tax Table3', 
           ChargeType.cht_taxtable4 as 'Tax Table4', 
           ChargeType.cht_currunit as 'Current Unit', 
           ChargeType.cht_remark as 'Remark', 
           ChargeType.cht_rollintolh as 'Roll Into Lh', 
           ChargeType.cht_retired as 'Retired', 
           ChargeType.cht_maxrate as 'Max Rate',   
           ChargeType.cht_maxenf as 'Max Enf', 
           ChargeType.cht_minrate as 'Min Rate', 
           ChargeType.cht_minenf as 'Min Enf', 
           ChargeType.cht_zeroenf as 'Zero Enf', 
           ChargeType.cht_crchg as 'Crchg', 
           ChargeType.cht_class as 'Charge Type Class', 
           ChargeType.gp_tax as 'Gp Tax', 
           ChargeType.cht_rateprotect as 'Charge Type Protect',
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [LH Min],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --ChargeType.cht_lh_min as [LH Min],
	   --<TTS!*!TMW><End><FeaturePack=Euro>
 	   
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [LH Prn],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --ChargeType.cht_lh_prn as [LH Prn],
	   --<TTS!*!TMW><End><FeaturePack=Euro>
 
 	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [LH Rev],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --ChargeType.cht_lh_rev as [LH Rev],
	   --<TTS!*!TMW><End><FeaturePack=Euro>
 
 	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [LH Rpt],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --ChargeType.cht_lh_rpt as [LH Rpt],
	   --<TTS!*!TMW><End><FeaturePack=Euro>
 
 	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [LH Stl]
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --ChargeType.cht_lh_stl as [LH Stl]
	   --<TTS!*!TMW><End><FeaturePack=Euro>

from ChargeType (NOLOCK)








GO
GRANT SELECT ON  [dbo].[vTTSTMW_ChargeTypes] TO [public]
GO
