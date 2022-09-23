SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_TmwXmlImportLogError]
( @TmwXmlImportLog_id   INT
, @ErrorInfo            VARCHAR(MAX)
)
AS

/**
 *
 * NAME:
 * dbo.sp_TmwXmlImportLogError
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to Log Errors for XML Import
 *
 * RETURNS:
 *
 * INT
 *
 * PARAMETERS:
 * @TmwXmlImportLog_id  INT
 * @ErrorInfo           VARCHAR(1000)
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/05/2013
 *
 **/

SET NOCOUNT ON

BEGIN
   INSERT INTO TmwXmlImportLogError(TmwXmlImportLog_id,ErrorInfo)
   VALUES(@TmwXmlImportLog_id,@ErrorInfo)
END
GO
GRANT EXECUTE ON  [dbo].[sp_TmwXmlImportLogError] TO [public]
GO
