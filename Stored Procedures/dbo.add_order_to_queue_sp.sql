SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.add_order_to_queue_sp    Script Date: 6/1/99 11:54:06 AM ******/
create procedure [dbo].[add_order_to_queue_sp] (@ord_hdrnumber int) as
insert into order_queue (ord_hdrnumber) values (@ord_hdrnumber)


GO
GRANT EXECUTE ON  [dbo].[add_order_to_queue_sp] TO [public]
GO
