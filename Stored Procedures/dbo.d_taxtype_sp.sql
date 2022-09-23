SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

 
create procedure [dbo].[d_taxtype_sp]     
as 
/**
 * 
 * NAME:
 * dbo.d_taxtype_sp 
 *
 * TYPE:
 * [StoredProcedure)
 *
 * DESCRIPTION:
 * This procedure retrieves all tax rates for all Provinces / States
 *
 * RETURNS:
  * none
 *
 * RESULT SETS: 
 * Tax_type smallint
 * tax_state char(3)
 * tax_effectivedate datetime
 * tax_expirationdate datetime
 * tax_rate real
 * tax_glnum varchar(32)
 * tax_id int (identity)
 * tax description varchar(60)
 * tax_appliesto char(1)
 *
 * PARAMETERS:
 * none 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)

 * 
 * REVISION HISTORY:
 * 4/5/99.01 ? PTSnnnnn - Pramod  ? Created
 * 5/15/06.02 - PTS 33053 - Donna Petersen - re written
 * 4/15/07.03 - PTS 35555 EMK Added tax_ARTaxAuthority
 **/


Select tax_type
,tax_state
,tax_effectivedate
,tax_expirationdate
,tax_rate
,tax_glnum
,tax_id
,tax_description
,tax_appliesto = isnull(tax_appliesto,'N')
,tax_ARTaxAuth --PTS 35555
from taxrate



GO
GRANT EXECUTE ON  [dbo].[d_taxtype_sp] TO [public]
GO
