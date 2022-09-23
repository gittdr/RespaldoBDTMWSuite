SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_TmwXmlImportLog]
( @workflow_id          INT
, @activity_name        VARCHAR(50)
, @TmwXmlImportLog_id   INT OUTPUT
)
AS

/**
 *
 * NAME:
 * dbo.sp_TmwXmlImportLog
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to ID an XML Import
 *
 * RETURNS:
 *
 * INT
 *
 * PARAMETERS:
 * @workflow_id         INT
 * @activity_name       VARCHAR(50)
 * @TmwXmlImportLog_id  INT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/05/2013
 *
 **/

SET NOCOUNT ON

BEGIN
   BEGIN TRAN sp_TmwXmlImportLog
      INSERT INTO TmwXmlImportLog(workflow_id,activity_name)
      VALUES(@workflow_id,@activity_name)

      SELECT @TmwXmlImportLog_id = SCOPE_IDENTITY()
   COMMIT TRAN sp_TmwXmlImportLog

END
GO
GRANT EXECUTE ON  [dbo].[sp_TmwXmlImportLog] TO [public]
GO
