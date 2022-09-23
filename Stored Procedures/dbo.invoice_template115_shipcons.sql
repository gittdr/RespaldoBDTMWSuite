SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[invoice_template115_shipcons] (@ordHnbr int)    
AS    
/*  
 *   
 * NAME:dbo.invoice_template115_shipcons  
 *   
 * TYPE:  
 * StoredProcedure  
 *  
 * DESCRIPTION:  
 * Provide a return set of all shippers  and consignees
 * based on the order selected.  
 *  
 * RETURNS:  
 * n/a  
 *  
 * RESULT SETS:   
 * none.  
 *  
 * PARAMETERS:  
 * 001 - @invoice_nbr, int, input, null;  
 *       Invoice number  
 *  
 * REFERENCES: (called by and calling references only, don't   
 *              include table/view/object references)  
 * N/A  
 *   
 * REVISION HISTORY:  
 * 07/03/2007 - PTS 35717 - OS - Created   
 **/  
select stp_type,cmp_name ,city_name = isnull(city.cty_name,''),stp_arrivaldate
from stops 
left outer join city on stp_city = cty_code

where ord_hdrnumber = @ordhnbr and ord_hdrnumber > 0 and stp_type in ( 'PUP','DRP')
order by stp_arrivaldate
GO
GRANT EXECUTE ON  [dbo].[invoice_template115_shipcons] TO [public]
GO
