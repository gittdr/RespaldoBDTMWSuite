SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[Start_Workflow](@Workflow_Template_Name varchar(50), @StartValue varchar(100))
as 

Declare @Template_id int
Declare @Sequence_id int

Set @Template_id = (select Workflow_Template_ID from Workflow_template where Workflow_Template_Name = @Workflow_Template_Name)

Set @Sequence_id = (select Workflow_Sequence_ID from workflow_sequence where workflow_Activity = 1 and workflow_Template_ID = @Template_id)

insert into workflow (Workflow_Template_ID, Workflow_Start_Time, Workflow_Current_Sequence_ID, 
Workflow_NextProcessTime,Workflow_Outcome, Workflow_StartValue) values 
(@Template_id, GETDATE(), @Sequence_id, GETdate(), 'Active', @StartValue)

GO
GRANT EXECUTE ON  [dbo].[Start_Workflow] TO [public]
GO
