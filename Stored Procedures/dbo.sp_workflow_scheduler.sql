SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_workflow_scheduler]
( @workflow_template_id       INT
, @workflow_nextprocesstime   DATETIME
, @workflow_startvalue        VARCHAR(100)
, @workflow_id                INT OUTPUT
)
AS

/**
 *
 * NAME:
 * dbo.sp_workflow_scheduler
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to add rows in table workflow and return the identity created
 *
 * RETURNS:
 *
 * INT
 *
 * PARAMETERS:
 * @workflow_template_id       INT
 * @workflow_nextprocesstime   DATETIME
 * @workflow_startvalue        VARCHAR(100)
 *
 * REVISION HISTORY:
 * PTS 59346 SPN Created 11/03/11
 *
 **/

SET NOCOUNT ON

BEGIN
   DECLARE @Start_ID INT

   SELECT @workflow_nextprocesstime = DATEADD(s,-100,@workflow_nextprocesstime)

   IF NOT EXISTS ( SELECT 1 FROM WorkflowTemplate_General_Info WHERE Workflow_Template_ID = @workflow_template_id)
   BEGIN
      RAISERROR('Template Not Found.',16,1)
      RETURN
   END

   BEGIN TRAN sp_workflow_scheduler
      SELECT @Start_ID = Start_ID
        FROM WorkflowTemplate_General_Info
       WHERE Workflow_Template_ID = @workflow_template_id

      INSERT INTO Workflow(Workflow_Template_ID,Workflow_Current_Sequence_ID,Workflow_NextprocessTime, Workflow_OutCome, Workflow_StartValue)
      VALUES(@workflow_template_id, @Start_ID, @workflow_nextprocesstime, 'Active', @workflow_startvalue)

      SELECT @Workflow_ID = SCOPE_IDENTITY()
   COMMIT TRAN sp_workflow_scheduler

END
GO
GRANT EXECUTE ON  [dbo].[sp_workflow_scheduler] TO [public]
GO
