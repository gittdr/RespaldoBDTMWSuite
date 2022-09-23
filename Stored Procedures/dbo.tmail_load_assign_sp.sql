SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_load_assign_sp] 
	@order_number varchar(12),
	@move varchar(12),
	@tractor varchar(12) 

AS


EXEC dbo.tmail_load_assign2_sp @order_number, @move, @tractor, NULL, NULL
GO
GRANT EXECUTE ON  [dbo].[tmail_load_assign_sp] TO [public]
GO
