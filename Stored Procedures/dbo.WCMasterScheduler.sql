SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-------------------------------------------------------------------------------
-- Workflow MasterScheduler
-------------------------------------------------------------------------------

Create proc [dbo].[WCMasterScheduler]
as 
declare @ThisWorkflowName Varchar(50) = 'MasterScheduler'

declare @Workflow_id int
declare @workflow_instance varchar(100)
declare @ServiceDedicatedToScheduler int
declare @Scheduler_id int
declare @last_count int
declare @current_instance_id int
declare @ActiveInstances table
(
	[awci_id] int,
	[awci_instance] [varchar](100) NULL,
	[awci_dedicated_workflow] [int] NULL,
	[ScheduledCount] int null
)

if (select count(0) from ActiveWorkCycleInstances) = 0 return --Just in case this is running as the service shuts down.

---- Find out what is currently scheduled ---
select count(0) as SCount, Workflow_instance into #Instancecount from workflow where Workflow_OutCome = 'Active' and Workflow_instance is not null group by Workflow_instance

insert into @ActiveInstances ([awci_id], [awci_instance],[awci_dedicated_workflow], [ScheduledCount]) select [awci_id], [awci_instance],[awci_dedicated_workflow], coalesce(#Instancecount.SCount, 0)
		from ActiveWorkCycleInstances left outer join #Instancecount on awci_instance = #Instancecount.Workflow_instance

drop table #Instancecount

update @ActiveInstances set ScheduledCount = 0 where coalesce(ScheduledCount, 0) = 0

-------------- Schedule this workflow to run ---------------
select @Scheduler_id = WorkFlow_Template_id from WorkFlow_Template where Workflow_Template_Name = @ThisWorkflowName
if (select count(0) from workflow with (NOLOCK) where Workflow_Template_ID = @Scheduler_id AND WorkFlow_NextProcessTime <= GETDATE() and Workflow_OutCome = 'Active' and Workflow_instance is null) = 0
	exec start_workflow @ThisWorkflowName, ''

--Handle dedicated workflow templates
if (select count(0) from @ActiveInstances where coalesce(awci_dedicated_workflow, 0) > 0) > 0
	update workflow set Workflow_instance = awci_instance from workflow join @ActiveInstances on Workflow_Template_ID = awci_dedicated_workflow where Workflow_OutCome <> 'Done' and Workflow_OutCome <> 'Fail' and Workflow_instance is null

-----------------------------------------
-- Services which are dedicated to a service have been scheduled, delete the serivces from the list.
delete from @ActiveInstances where coalesce(awci_dedicated_workflow, 0) > 0

-- List now contains non dedicated services that are available to assign to workflows
select @Workflow_id = min(WorkFlow_id) from workflow where workflow_instance is NULL AND WorkFlow_NextProcessTime <= GETDATE() and ( Workflow_OutCome = 'Active' or Workflow_OutCome = 'InActive' or Workflow_OutCome = 'Wait')
while (@Workflow_id is not null)
Begin

	select @current_instance_id = (select top 1 awci_id from @ActiveInstances order by ScheduledCount)
	select @workflow_instance = awci_instance from ActiveWorkCycleInstances where awci_id = @current_instance_id
	
	update workflow set Workflow_instance = @workflow_instance where workflow_id = @Workflow_id
	update @ActiveInstances set ScheduledCount = ScheduledCount + 1 where awci_id = @current_instance_id

	select @Workflow_id = min(WorkFlow_id) from workflow where workflow_instance is NULL AND WorkFlow_NextProcessTime <= GETDATE() and ( Workflow_OutCome = 'Active' or Workflow_OutCome = 'InActive' or Workflow_OutCome = 'Wait') and workflow_id > @Workflow_id
End

GO
GRANT EXECUTE ON  [dbo].[WCMasterScheduler] TO [public]
GO
