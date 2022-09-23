SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[wf_CreateNewTask] (@NewTaskCreated int OUT, @Task_Template_ID int, @Task_Link_Entity_Value varchar(12), @Task_Link_Entity_Table_ID int, @Description varchar(255), @AssignedUser varchar(50)) as return
GO
GRANT EXECUTE ON  [dbo].[wf_CreateNewTask] TO [public]
GO
