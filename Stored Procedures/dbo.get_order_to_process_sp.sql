SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.get_order_to_process_sp    Script Date: 6/1/99 11:54:32 AM ******/
create procedure [dbo].[get_order_to_process_sp] (@ordhdrnumber int output) as

select 	@ordhdrnumber = ord_hdrnumber 
from 	order_queue 
where 	id = (select min(id) from order_queue)

if @@error <> 0 
   select @ordhdrnumber = -1					

return

GO
GRANT EXECUTE ON  [dbo].[get_order_to_process_sp] TO [public]
GO
