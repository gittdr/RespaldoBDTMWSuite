SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create Procedure [dbo].[Workflow_Delete_Template] (@Workflow_Template_Name varchar(50))

as

Declare @Template_id int

Begin Transaction

Set @Template_id = (select Workflow_Template_ID from Workflow_template where Workflow_Template_Name = @Workflow_Template_Name)

IF @Template_id is not NULL
	BEGIN
		delete from Workflow_Query where WorkFlow_Template_id = @Template_id
		delete from Workflow_ClientSideOptions where WorkFlow_Template_id = @Template_id
		delete from WorkFlow_Schedule where WorkFlow_Template_id = @Template_id
		delete from WorkFlow_FileWatch where WorkFlow_Template_id = @Template_id
		delete from Workflow_ActivityOptions where WorkFlow_Sequence in 
		(select WorkFlow_Sequence_id from WorkFlow_Sequence where WorkFlow_Template_id = @Template_id)
		delete from WorkFlow_Sequence where WorkFlow_Template_id = @Template_id
		delete from Workflow_template where Workflow_Template_ID = @Template_id
	END

COMMIT TRANSACTION

GO
GRANT EXECUTE ON  [dbo].[Workflow_Delete_Template] TO [public]
GO
