SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_workflow_status]
( @workflow_id       INT
, @status            VARCHAR(20) OUTPUT
)
AS

/**
 *
 * NAME:
 * dbo.sp_workflow_status
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to add rows in table workflow and return the identity created
 *
 * RETURNS:
 *
 * VARCHAR(20)
 *
 * PARAMETERS:
 * @workflow_id       INT
 *
 * REVISION HISTORY:
 * PTS 59346 SPN Created 11/03/11
 * 
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @workflow_end_time DATETIME
   DECLARE @workflow_outcome  VARCHAR(20)

   SELECT @workflow_end_time = workflow_end_time
        , @workflow_outcome  = workflow_outcome
     FROM Workflow
    WHERE WorkFlow_ID = @workflow_id
 
   IF @workflow_end_time IS NOT NULL OR @workflow_outcome <> 'Active'
      SELECT @status = @workflow_outcome
   ELSE
      SELECT @status = 'Active'

END
GO
GRANT EXECUTE ON  [dbo].[sp_workflow_status] TO [public]
GO
