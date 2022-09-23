SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
Create procedure [dbo].[d_refnumbers_bymovconorder]  @ord int
As
/* 

  MODIFCATION LOG

2/13/09  Created by DPETE PTS 44417 allow invoicing by all orders on move delivered to sam consignee
    ASSUMES all orders have only one delivery location

*/

Declare @desc varchar (50), @int int,@mov int,@billto varchar(8),@consignee varchar(8)
declare @ords table (ord_hdrnumber int)
Select @int = 0

select @billto = ord_billto ,@mov = mov_number,@consignee = ord_consignee
from orderheader where ord_hdrnumber = @ord

insert into @ords
select distinct(ord_hdrnumber)
from orderheader 
where mov_number = @mov
and ord_billto = @billto
and ord_consignee = @consignee


SELECT  
seq  = @int,   
referencenumber.ref_type ,         
referencenumber.ref_number ,           
referencenumber.ref_sequence ,           
referencenumber.ref_table ,           
referencenumber.ref_tablekey ,           
referencenumber.ord_hdrnumber,
orderheader.ord_number    
        
FROM @ords ords 
join referencenumber on ords.ord_hdrnumber = referencenumber.ord_hdrnumber
join orderheader on referencenumber.ord_hdrnumber = orderheader.ord_hdrnumber

    
 

GO
GRANT EXECUTE ON  [dbo].[d_refnumbers_bymovconorder] TO [public]
GO
