SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_carrier411ws_linktoworkflow]
( @batch_id       INT
, @workflow_id    INT
)
AS

/**
 *
 * NAME:
 * dbo.sp_carrier411ws_linktoworkflow
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to link a batch to a workflow in table carrier411ws and return success/failure
 *
 * RETURNS:
 *
 * RESULT (1=Success;0=Failure)
 *
 * PARAMETERS:
 * @batch_id         INT
 * @workflow_id      INT
 *
 * REVISION HISTORY:
 * PTS 59346 SPN Created 11/09/11
 * 
 **/

SET NOCOUNT ON

BEGIN
   DECLARE @count  INT
   DECLARE @retval INT
   
   SELECT @count = Count(1)
     FROM carrier411ws
    WHERE BATCH_ID = @batch_id
      AND workflow_id > 0
   
   IF @count > 0
      BEGIN
         SELECT @retval = 0
      END
   ELSE
      BEGIN
         SELECT @count = Count(1)
           FROM carrier411ws
          WHERE BATCH_ID = @BATCH_ID
         IF @count > 0
            BEGIN
               UPDATE carrier411ws
                  SET workflow_id = @workflow_id
                WHERE BATCH_ID = @batch_id
               SELECT @retval = 1
            END
         ELSE
            BEGIN
               SELECT @retval = 0
            END
      END

   SELECT @retval FROM ONEROW
   
   RETURN
   
END
GO
GRANT EXECUTE ON  [dbo].[sp_carrier411ws_linktoworkflow] TO [public]
GO
