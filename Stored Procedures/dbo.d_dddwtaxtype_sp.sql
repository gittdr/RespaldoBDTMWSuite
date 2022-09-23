SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 
create procedure [dbo].[d_dddwtaxtype_sp]     
as 
/**
 * 
 * NAME:
 * dbo.d_dddwtaxtype_sp 
 *
 * TYPE:
 * [StoredProcedure)
 *
 * DESCRIPTION:
 * This procedure retrieves a drop down list of valid tax types (per labelfile)
 *
 * RETURNS:
  * none
 *
 * RESULT SETS: 
 * Tax_type smallint
 * taxtypename varchar(6) = lbl.abbr  Labelfile abbr for TaxType?
 *
 * PARAMETERS:
 * none 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)

 * 
 * REVISION HISTORY:
 * 5/15/06.02 - PTS 33053 - Donna Petersen - Created
 *
 **/

if (select gi_string1 from generalinfo where gi_name = 'EnhancedTaxes') = 'Y'
	Select tax_type = right(labeldefinition,1)
		,taxtypename = abbr
		from labelfile where labeldefinition like 'TaxType%'
else
	Select tax_type = right(labeldefinition,1)
		,taxtypename = abbr
		from labelfile where labeldefinition in ('TaxType1','TaxType2','TaxType3','TaxType4')

GO
GRANT EXECUTE ON  [dbo].[d_dddwtaxtype_sp] TO [public]
GO
