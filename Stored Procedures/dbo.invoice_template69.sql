SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
   


CREATE procedure [dbo].[invoice_template69](@invoice_nbr   int, @copies  int)  
as  
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 * calls invoice_template69_linkedserver
 *
 * REVISION HISTORY:
 * 11/16/2007.01 ? JGUO ? (40360) this is a wrapper to work around the distributed query issue
 *
 **/

SET ANSI_NULLS ON
SET ANSI_WARNINGS ON
execute invoice_template69_linkedserver @invoice_nbr, @copies 

SELECT * FROM ##invtemp_tbl_temp
drop table ##invtemp_tbl_temp
GO
GRANT EXECUTE ON  [dbo].[invoice_template69] TO [public]
GO
