SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[d_taxchargetype_sp] 
as
/**
 * 
 * NAME:
 * dbo.d_taxchargetype_sp 
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return chargetype table information for tax types. Used to create tax records.
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * See SELECT statement.
 *
 * PARAMETERS:

 *
 * REFERENCES:
 * NONE
 * 
 * REVISION HISTORY:
 * 072806.01 - PTS 33614 DPETE - Created stored proc for new tax nvo 
 *
 **/

select
 cht_itemcode,   
 cht_description,    
 cht_primary,   
 cht_basis,   
 cht_basisunit,   
 cht_basisper,   
 cht_quantity,   
 cht_rateunit,   
 cht_unit,   
 cht_rate,   
 cht_editflag,   
 cht_glnum,   
 cht_sign,   
 cht_currunit,   
 cht_remark,   
 cht_class,
 cht_rateprotect ,
 cht_rollintolh =	IsNULL(chargetype.cht_rollintolh,0) ,
 cht_lh_min,
 cht_lh_rev,
 cht_lh_stl,
 cht_lh_rpt ,
 cht_lh_prn,
 gp_tax = isnull (chargetype.gp_tax, 0),
 cht_taxtable1,
 cht_taxtable2,
 cht_taxtable3,
 cht_taxtable4,
 cht_allocation_method,
 cht_allocation_criteria,
 cht_allocation_groupby,
 cht_allocation_group_nbr 	
FROM chargetype
WHERE cht_basis = 'TAX' 	 


GO
GRANT EXECUTE ON  [dbo].[d_taxchargetype_sp] TO [public]
GO
