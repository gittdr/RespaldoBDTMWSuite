SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROCEDURE [dbo].[dedbilling_validation_shell_sp] (@dbhid int,
						@err varchar(255) output)
as
/*
10/08/12/ PTS 64350 created DPETE modeled on billing_validation_shell_sp
*/

DECLARE @proc_name varchar(60)
select @proc_name = rtrim( gi_string1)
from generalinfo 
where gi_name = 'DedValidationProc'
IF @Proc_name is not null or @proc_name > ''
      EXEC @proc_name @dbhid, @ErrorMessage = @err output
GO
GRANT EXECUTE ON  [dbo].[dedbilling_validation_shell_sp] TO [public]
GO
