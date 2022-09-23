SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.plat_date_sp    Script Date: 6/1/99 11:54:04 AM ******/
create procedure [dbo].[plat_date_sp]
as

Declare 
	@current_date datetime

select @current_date = getdate()

select @current_date



GO
GRANT EXECUTE ON  [dbo].[plat_date_sp] TO [public]
GO
