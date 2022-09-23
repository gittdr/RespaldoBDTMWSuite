SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_sp_help2] @tractor varchar(12),
													@lgh_outstatus varchar (6)

AS

SET NOCOUNT ON 

	DECLARE @TMStatus as varchar(500)
	SELECT @TMStatus = ''

	exec dbo.tmail_get_lgh_number_sp_help3 @tractor, @lgh_outstatus, @TMStatus
GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_sp_help2] TO [public]
GO
