SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[d_edit_expression_parms_sp] @p_labeldef varchar (20) 
as

/**
 * 
 * NAME:
 * dbo.getTripSegRateData_s
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure returns data needed to apply multiple charges for a charge unit basis TSTIME 
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * parameters 
 *
 * PARAMETERS:
 * 001 - @p_labeldef Label definition to retrieve
 *
 * REFERENCES: (NONE)

 * 
 * REVISION HISTORY:
 * 09/04/07 EMK - Created
 **/


SELECT name parameter, 
	   0 value
from labelfile
where labeldefinition = @p_labeldef
order by parameter ASC

GO
GRANT EXECUTE ON  [dbo].[d_edit_expression_parms_sp] TO [public]
GO
