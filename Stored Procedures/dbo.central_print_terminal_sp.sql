SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROCEDURE [dbo].[central_print_terminal_sp] (@revtype1 varchar(6))
as

DECLARE @proc_name varchar(60),
		@ret int
select @proc_name = (select gi_string1 from generalinfo where gi_name = 'InvCustRevType1Check')
EXEC @ret = @proc_name @revtype1
Return @ret
GO
GRANT EXECUTE ON  [dbo].[central_print_terminal_sp] TO [public]
GO
