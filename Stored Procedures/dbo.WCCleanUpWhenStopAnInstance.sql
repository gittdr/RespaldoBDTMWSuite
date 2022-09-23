SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WCCleanUpWhenStopAnInstance]
	@Instance	VARCHAR (100),
	@IP			VARCHAR (100)
AS
BEGIN
	DECLARE @MasterSchedulerWorkflowName Varchar(50) = 'MasterScheduler'
	DECLARE @Workflow_Template_ID int
	DECLARE @ActiveWorkflow_instance varchar(128)


	DELETE FROM ActiveWorkCycleInstances WHERE awci_ip = @IP and awci_instance = @Instance

	SELECT @Workflow_Template_ID =  max(Workflow_Template_ID) from WorkFlow_Template where Workflow_Template_Name = @MasterSchedulerWorkflowName

	UPDATE workflow SET Workflow_instance = NULL where Workflow_instance = @Instance AND ( Workflow_OutCome = 'Active' or Workflow_OutCome = 'InActive' or Workflow_OutCome = 'Wait')
	AND Workflow_instance = @Instance and  workflow_template_id <> @Workflow_Template_ID

	IF (SELECT count(0) FROM ActiveWorkCycleInstances) = 0 	
	  UPDATE workflow SET Workflow_OutCome = 'Done' where workflow_template_id = @Workflow_Template_ID and ( Workflow_OutCome = 'Active' or Workflow_OutCome = 'InActive' or Workflow_OutCome = 'Wait')
	ELSE	   
	BEGIN
	  SELECT top(1) @ActiveWorkflow_instance = awci_instance FROM ActiveWorkCycleInstances
	  UPDATE workflow SET Workflow_instance  = @ActiveWorkflow_instance where workflow_template_id = @Workflow_Template_ID and Workflow_OutCome = 'Active' and Workflow_instance = @Instance
	END
	
END
GO
GRANT EXECUTE ON  [dbo].[WCCleanUpWhenStopAnInstance] TO [public]
GO
