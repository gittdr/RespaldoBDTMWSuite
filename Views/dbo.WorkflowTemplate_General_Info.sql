SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create View [dbo].[WorkflowTemplate_General_Info]

as

select WOrkflow_Template.Workflow_Template_ID, Workflow_Template_Name, Workflow_Template_Type, Workflow_Sequence_id as 'Start_ID'
from (WOrkflow_Template join Workflow_Sequence on WOrkflow_Template.Workflow_Template_ID = Workflow_Sequence.Workflow_Template_ID)
join Workflow_Activity on Workflow_Sequence.Workflow_Activity = Activity_ID
where Activity_Type = 'Start'

GO
