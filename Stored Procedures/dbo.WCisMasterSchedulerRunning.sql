SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create proc [dbo].[WCisMasterSchedulerRunning]
as 
-------------------------------------------------------------------------------
-- Clean up any stalled services.
-------------------------------------------------------------------------------
declare @BadInstances table
(
	instance varchar(100)
)

--MRH changed to 600 minutes (10 hours).
insert into @BadInstances select distinct Workflow_instance from workflow where datediff(MINUTE, Workflow_ActualStartTime, getdate()) > 600 and Workflow_OutCome not in ('Done', 'Fail')
delete from ActiveWorkCycleInstances where awci_instance in (select instance from @BadInstances)
update workflow set workflow_instance = NULL where Workflow_ActualStartTime is NULL and Workflow_instance in (select instance from @BadInstances)

-------------------------------------------------------------------------------
-- Test for a running instance of the MasterScheduler
-------------------------------------------------------------------------------
declare @ThisWorkflowName Varchar(50) = 'MasterScheduler'
declare @Workflow_Template_ID int
declare @ActiveCount int

select @Workflow_Template_ID =  max(Workflow_Template_ID) from WorkFlow_Template where Workflow_Template_Name = @ThisWorkflowName

--Don't allow any active master scheduler has null instance
UPDATE Workflow set Workflow_OutCome = 'Done' WHERE  
Workflow_Template_ID = @Workflow_Template_ID
AND Workflow_OutCome = 'Active' AND Workflow_instance  IS NULL




select @ActiveCount = isnull(count(0), 0) from workflow 
	where workflow_template_id = @Workflow_Template_ID and Workflow_OutCome = 'Active'

if @ActiveCount > 1 -- We should not have more than one active....
begin

	-- update any null instances.
	update Workflow set Workflow_OutCome = 'Fail', Workflow_End_Time = getdate(), Workflow_ActualStartTime = getdate() where workflow_template_id = @Workflow_Template_ID and Workflow_OutCome = 'Active'  and Workflow_instance is null

	-- Are we down to one running instance now?
	select @ActiveCount = isnull(count(0), 0) from workflow 
		join ActiveWorkCycleInstances on Workflow_instance = awci_instance
		where workflow_template_id = @Workflow_Template_ID and Workflow_OutCome = 'Active'

	-- We still have more than one active. Just fail them all and start over.
	if @ActiveCount > 1 	
		update Workflow set Workflow_OutCome = 'Fail', Workflow_End_Time = getdate(), Workflow_ActualStartTime = getdate() where workflow_template_id = @Workflow_Template_ID and Workflow_OutCome = 'Active'
end

if @ActiveCount = 0 -- This will add the scheduler if needed.
	Exec WCMasterScheduler

GO
GRANT EXECUTE ON  [dbo].[WCisMasterSchedulerRunning] TO [public]
GO
