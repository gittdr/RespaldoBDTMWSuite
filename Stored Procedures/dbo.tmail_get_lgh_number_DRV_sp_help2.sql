SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_DRV_sp_help2] @DriverID varchar(8),
													   @lgh_outstatus varchar (6)

AS

SET NOCOUNT ON 

	DECLARE @TMStatus as varchar(500)
	set @TMStatus = ''

EXEC dbo.tmail_get_lgh_number_DRV_sp_help3 @DriverID, @lgh_outstatus, @TMStatus 

GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_DRV_sp_help2] TO [public]
GO
