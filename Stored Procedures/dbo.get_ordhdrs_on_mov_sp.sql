SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.get_ordhdrs_on_mov_sp    Script Date: 6/1/99 11:55:03 AM ******/
create proc [dbo].[get_ordhdrs_on_mov_sp](@movnumber	int)
as

select distinct ord_hdrnumber from stops where mov_number = @movnumber

GO
GRANT EXECUTE ON  [dbo].[get_ordhdrs_on_mov_sp] TO [public]
GO
