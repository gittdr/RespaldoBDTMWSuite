SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[RemoveActivites] @Workflow_Name varchar(50)

as

DECLARE @Workflow_id int

BEGIN TRANSACTION

select @Workflow_id = Workflow_Template_ID from Workflow_template where Workflow_Template_Name = @Workflow_Name

IF @Workflow_id is not NULL
	BEGIN
		delete from Workflow_ActivityOptions where WorkFlow_Sequence in 
		(select WorkFlow_Sequence_id from WorkFlow_Sequence where WorkFlow_Template_id = @Workflow_id)
		delete from WorkFlow_Sequence where WorkFlow_Template_id = @Workflow_id
	END

COMMIT TRANSACTION

GO
GRANT EXECUTE ON  [dbo].[RemoveActivites] TO [public]
GO
