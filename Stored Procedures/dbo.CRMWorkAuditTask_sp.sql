SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[CRMWorkAuditTask_sp] (@billTo varchar(8), @title as varchar(255), @description as varchar(255)) as
begin
	declare @linkTableId int, 
            @brnId varchar(12), 
            @tmwuser varchar(255), 
	        @logDate datetime, 
	        @templateId int, 
            @openCreditReview int, 
            @workFlowName varchar(255), 
            @creditReviewMakeTaskProc varchar(255) 
	
	set @logDate = GetDate()
	set @templateId = NULL
	
	exec gettmwuser @tmwuser output
	
	select @linkTableId = TASK_LINK_ENTITY_TABLE_ID 
      from TASK_LINK_ENTITY_TABLE 
     where TABLE_NAME = 'COMPANYCRMWORK'
	
	select @brnId = cmp_bookingterminal
      from companycrmwork 
     where cmp_id = @billTo 
    
    select top 1
           @creditReviewMakeTaskProc = isnull(gi_string2, 'wf_CreateNewTask'), 
           @workFlowName = isnull(gi_string1, 'Customer On Board') 
      from generalinfo 
     where gi_name = 'CreditReviewTask' 

	if @title = 'CREDIT REVIEW' 
		select @templateId = TASK_TEMPLATE_ID 
          from TASK_TEMPLATE 
         where NAME = @workFlowName 

	if @title <> 'CREDIT REVIEW'
	insert into TASK (TASK_LINK_ENTITY_TABLE_ID, TASK_LINK_ENTITY_VALUE, BRN_ID, ACTIVITY_TYPE, TASK_TYPE, NAME, 
                      DESCRIPTION, ASSIGNED_USER, PRIORITY, ORIGINAL_DUE_DATE, DUE_DATE, END_DATE, LEAD_TIME, 
                      COMPLETED_DATE, ACTIVE_FLAG, STATUS, CREATED_DATE, CREATED_USER, MODIFIED_DATE, MODIFIED_USER, 
                      USER_DEFINED_TYPE1, USER_DEFINED_TYPE2, USER_DEFINED_TYPE3, USER_DEFINED_TYPE4, TASK_TEMPLATE_ID) 
              values (@linkTableId, @billto, @brnId, 'AUDIT', 'ACTVTY', @title, 
                      @description, @tmwuser, 200, @logDate, @logDate, @logDate, 0, 
                      @logDate, 'N', 'COMPLT', @logDate, @tmwuser, @logDate, @tmwuser, 
                      'UNK', 'UNK', 'UNK', 'UNK', @templateId) 

	if @templateId > 0 
	begin
		select @openCreditReview = COUNT(TASK_ID) 
          from TASK 
         where NAME = 'CREDIT REVIEW' 
           and TASK_LINK_ENTITY_TABLE_ID = @linkTableId 
           and TASK_LINK_ENTITY_VALUE = @billto 
           and STATUS = 'OPEN'
		
		if @openCreditReview is NULL
			set @openCreditReview = 0
		
		declare @statementToCreateNewWorkFlow nvarchar(4000), 
                @taskDescription varchar(255) 
		if @openCreditReview < 1 and len(@creditReviewMakeTaskProc) > 0
        begin
			select @taskDescription = case when isnull(cmp_name, '') <> '' then rtrim(cmp_name) else '' end 
                                      + case when isnull(cmp_address1, '') <> '' then rtrim('; ' + cmp_address1) else '' end + '; ' 
                                      + case when isnull(cty_name, '') <> '' then rtrim(cty_name) else '' end 
                                      + case when isnull(cmp_state, '') <> '' and cmp_state <> 'UN' and cmp_state <> 'XX' then rtrim(', ' + cmp_state) else '' end 
                                      + case when isnull(cmp_zip, '') <> '' then rtrim(' ' + cmp_zip) else '' end 
                                      + case when isnull(cmp_contact, '') <> '' then  '; ' + cmp_contact else '' end 
                                      + case when isnull(cmp_primaryphone, '') <> '' then ' - ' + cmp_primaryphone else '' end 
                                      + case when isnull(cmp_primaryphoneext, '') <> '' then ' ext ' + cmp_primaryphoneext else '' end 
                                      + case when isnull(cmp_misc1, '') <> '' then '; ' + cmp_misc1 else '' end 
              from companycrmwork join city on cty_code = cmp_city 
             where cmp_id = @billto
            
            set @taskDescription = left(@taskDescription, 255)

			set @statementToCreateNewWorkFlow = 'declare @newTaskOut int; exec ' + @creditReviewMakeTaskProc + ' @NewTaskCreated=@newTaskOut, @Task_Template_ID='  + convert(varchar(9), @templateId) + ', @Task_Link_Entity_Value=''' + @billto + ''','
            set @statementToCreateNewWorkFlow = @statementToCreateNewWorkFlow + '@Task_Link_Entity_Table_ID=' + convert(varchar(12), @linkTableId) + ', @Description=''' + @taskDescription + ''', @AssignedUser=''FINANCE'''
			exec sp_executesql @statementToCreateNewWorkFlow
--			insert into TASK (TASK_TEMPLATE_ID, NAME, DESCRIPTION, ASSIGNED_USER, PRIORITY, LEAD_TIME, ACTIVE_FLAG, CREATED_DATE, 
--	                          CREATED_USER, MODIFIED_DATE, MODIFIED_USER, USER_DEFINED_TYPE1, USER_DEFINED_TYPE2, USER_DEFINED_TYPE3, USER_DEFINED_TYPE4, 
--	                          NAME_F, DESCRIPTION_F, ASSIGNED_USER_F, DUE_DATE_F, LEAD_TIME_F, PRIORITY_F, ACTIVE_FLAG_F, STATUS_F, 
--	                          USER_DEFINED_TYPE1_F, USER_DEFINED_TYPE2_F, USER_DEFINED_TYPE3_F, USER_DEFINED_TYPE4_F, 
--	                          PENDING_CHANGES_FLAG, GENERATION_RULE_FLAG, PROMPT_ADD_FLAG, PROMPT_EDIT_FLAG, PROMPT_DELETE_FLAG, 
--	                          PROMPT_HOLD_FLAG, TASK_LINK_ENTITY_TABLE_ID, TASK_LINK_ENTITY_VALUE, BRN_ID, 
--	                          ORIGINAL_DUE_DATE, DUE_DATE, END_DATE, COMPLETED_DATE, STATUS, TASK_TYPE, ACTIVITY_TYPE, 
--	                          Task_Link_Entity_Sys_Value)
--		              select TASK_TEMPLATE_ID, @title, @description, ASSIGNED_USER, PRIORITY, LEAD_TIME, ACTIVE_FLAG, @logDate, 
--	                         'LOGPROC', @logDate, 'LOGPROC', USER_DEFINED_TYPE1, USER_DEFINED_TYPE2, USER_DEFINED_TYPE3, USER_DEFINED_TYPE4, 
--	                         NAME_F, DESCRIPTION_F, ASSIGNED_USER_F, DUE_DATE_F, LEAD_TIME_F, PRIORITY_F, ACTIVE_FLAG_F, STATUS_F, 
--	                         USER_DEFINED_TYPE1_F, USER_DEFINED_TYPE2_F, USER_DEFINED_TYPE3_F, USER_DEFINED_TYPE4_F, 
--	                         PENDING_CHANGES_FLAG, GENERATION_RULE_FLAG, PROMPT_ADD_FLAG, PROMPT_EDIT_FLAG, PROMPT_DELETE_FLAG, 
--	                         PROMPT_HOLD_FLAG, @linkTableId, @billto, @brnId, 
--	                         @logDate, @logDate, @logDate, '20491231 23:59', 'OPEN', 'ACTVTY', 'TASK',
--	                         0
--	                    from TASK_TEMPLATE 
--	                   where TASK_TEMPLATE_ID = @templateId 
        end
	end
end

GO
GRANT EXECUTE ON  [dbo].[CRMWorkAuditTask_sp] TO [public]
GO
