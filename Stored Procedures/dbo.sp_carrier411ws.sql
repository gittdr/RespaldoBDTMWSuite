SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_carrier411ws]
( @method         VARCHAR(50)
, @workflow_id	  INT
)
AS

/**
 *
 * NAME:
 * dbo.sp_carrier411ws
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to add rows in table carrier411ws and return the identity created
 *
 * RETURNS:
 *
 * INT
 *
 * PARAMETERS:
 * @method         VARCHAR(50)
 * @workflow_id	   INT
 *
 * REVISION HISTORY:
 * PTS 59346 SPN Created 11/02/11
 *
 **/

SET NOCOUNT ON

BEGIN
   DECLARE @BATCH_ID INT

   BEGIN TRAN sp_carrier411ws
      INSERT INTO carrier411ws(method,workflow_id) VALUES (@method,@workflow_id)
      SELECT @BATCH_ID = SCOPE_IDENTITY()
    COMMIT TRAN sp_carrier411ws
   SELECT BATCH_ID
     FROM carrier411ws
    WHERE BATCH_ID = @BATCH_ID
END
GO
GRANT EXECUTE ON  [dbo].[sp_carrier411ws] TO [public]
GO
