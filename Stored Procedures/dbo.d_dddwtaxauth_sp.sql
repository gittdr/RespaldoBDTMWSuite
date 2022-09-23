SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 
create procedure [dbo].[d_dddwtaxauth_sp]     
as 
/**
 * 
 * NAME:
 * dbo.d_dddwtaxauth_sp 
 *
 * TYPE:
 * [StoredProcedure)
 *
 * DESCRIPTION:
 * This procedure retrieves a drop down list of valid AR Tax Authority (per labelfile)
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
 * 04/15/07 - PTS 35555 - EMK - Created
 *
 **/


SELECT name,abbr
FROM labelfile 
WHERE labeldefinition = 'ARTaxAuthority'

GO
GRANT EXECUTE ON  [dbo].[d_dddwtaxauth_sp] TO [public]
GO
