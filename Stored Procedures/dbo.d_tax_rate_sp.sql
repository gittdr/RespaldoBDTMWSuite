SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/****** Object:  Stored Procedure dbo.d_tax_rate_sp    Script Date: 6/1/99 11:54:29 AM ******/  
CREATE PROCEDURE [dbo].[d_tax_rate_sp] (@State varchar(12),@date datetime)  
AS
/**
 * 
 * NAME:
 * dbo.d_tax_rate_sp 
 *
 * TYPE:
 * [StoredProcedure)
 *
 * DESCRIPTION:
 * This procedure retrieves the tax rate for a State or Province
 *
 * RETURNS:
  * none
 *
 * RESULT SETS: 
 * Tax_type smallint
 * tax_rate real
 *
 * PARAMETERS:
 * none 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)

 * 
 * REVISION HISTORY:
 * ????  Createded Promode
 * 5/15/06.02 - PTS 33053 - Donna Petersen - Modified to pass effective date 
 *
 **/
  
 select taxrate.tax_type, taxrate.tax_rate   
 from taxrate  
 where taxrate.tax_state = @State 
 and @date between tax_effectivedate and tax_expirationdate
GO
GRANT EXECUTE ON  [dbo].[d_tax_rate_sp] TO [public]
GO
