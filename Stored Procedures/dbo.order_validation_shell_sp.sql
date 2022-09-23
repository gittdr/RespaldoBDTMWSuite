SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[order_validation_shell_sp] (@p_ord_hdrnumber int, @p_msg varchar(255) out) as select @p_msg = ''
GO
GRANT EXECUTE ON  [dbo].[order_validation_shell_sp] TO [public]
GO
