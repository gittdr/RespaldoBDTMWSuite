SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROCEDURE [dbo].[billing_validation_shell_sp] (@ivh_invoicenumber varchar(12),
						@err varchar(255) output)
as

DECLARE @proc_name varchar(60)
select @proc_name = (select gi_string1 from generalinfo where gi_name = 'InvValidationProc')
EXEC @proc_name @ivh_invoicenumber, @ErrorMessage = @err output
GO
GRANT EXECUTE ON  [dbo].[billing_validation_shell_sp] TO [public]
GO
