SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_carrier411_write_log]
( @BATCH_ID             VARCHAR(30)
, @FaultCode            VARCHAR(10)
, @FaultMessage         VARCHAR(250)
) AS
/**
 *
 * NAME:
 * dbo.sp_carrier411_write_log
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for writing rows in table carrier411_activity_log
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 BATCH_ID             VARCHAR(30)
 * 002 FaultCode            VARCHAR(10)
 * 003 FaultMessage         VARCHAR(250)
 *
 * REVISION HISTORY:
 * PTS 59346 SPN 11/10/11 - Initial Version Created
 *
 **/

SET NOCOUNT ON

BEGIN

   If @BATCH_ID IS NULL
      RETURN

   INSERT INTO carrier411wslog(BATCH_ID, FaultCode, FaultMessage)
   VALUES(@BATCH_ID,@FaultCode,@FaultMessage)

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_carrier411_write_log] TO [public]
GO
