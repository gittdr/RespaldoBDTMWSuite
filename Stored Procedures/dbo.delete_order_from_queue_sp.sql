SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.delete_order_from_queue_sp    Script Date: 6/1/99 11:54:30 AM ******/
create procedure [dbo].[delete_order_from_queue_sp](@ord_hdrnumber int)
as
delete from order_queue where ord_hdrnumber = @ord_hdrnumber


GO
GRANT EXECUTE ON  [dbo].[delete_order_from_queue_sp] TO [public]
GO
