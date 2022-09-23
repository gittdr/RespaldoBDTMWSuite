SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[OverrideApplyHighestRate_sp] (@p_company_id varchar(8), @p_retval char(1) output)					
AS

/**
 * 
 * NAME:
 * dbo.OverrideApplyHighestRate_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Determine if the billto company entered should bypass 
 * the AlwaysApplyHighestRate functionality 
 *
 * RETURNS:
 * N/A
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_company_id, , varchar(8),input, null;
 *       
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 **/

  
SELECT @p_retval = cmp_overrideapplyhighestrate     
  FROM company
 WHERE cmp_id = @p_company_id
GO
GRANT EXECUTE ON  [dbo].[OverrideApplyHighestRate_sp] TO [public]
GO
