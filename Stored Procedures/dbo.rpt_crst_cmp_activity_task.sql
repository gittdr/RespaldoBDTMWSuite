SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[rpt_crst_cmp_activity_task] (
  @userlist varchar(8000),
  @s_date datetime,
  @e_date datetime,
  @activity_only varchar(1),
  @taskactivitytypelist varchar(100))

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @tasktypelist table (tasktype varchar(6))
declare @users table (usrid varchar(20))

SET @e_date = convert(datetime, convert(varchar(11), @e_date, 101) + ' 23:59:59')

IF @activity_only = 'Y'
BEGIN
  insert into @tasktypelist
  select 'ACTVTY'
  END
ELSE
BEGIN
  insert into @tasktypelist
  select distinct task_type from TASK 
	where COMPLETED_DATE BETWEEN @s_date AND @e_date
	and [STATUS] = 'COMPLT'
END

IF @userlist = 'ALL'
BEGIN
  INSERT INTO @users
  SELECT usr_userid FROM ttsusers 
END
ELSE
BEGIN
  INSERT INTO @users
  SELECT value FROM dbo.CSVStringsToTable_fn (@userlist)
END

SELECT 
  TASK_ID,
  ASSIGNED_USER,
  [STATUS],
  TASK_TYPE,
  CASE WHEN TASK_LINK_ENTITY_TABLE_ID = 2 THEN TASK_LINK_ENTITY_VALUE ELSE '' END AS [COMPANY ID],
  CASE WHEN TASK_LINK_ENTITY_TABLE_ID = 2 
	THEN (SELECT cmp_name FROM company WHERE cmp_id = TASK_LINK_ENTITY_VALUE) ELSE '' END AS [COMPANY NAME],
  ACTIVITY_TYPE,
  DUE_DATE as [Activity Start Date],
  END_DATE as [Activity End Date],
  ORIGINAL_DUE_DATE as [Original Start Date],
  ASSIGNED_USER as [TMW User ID],
  NAME as [Subject],
  [DESCRIPTION],
  (SELECT name FROM labelfile WHERE labeldefinition = 'TaskPriority' and abbr = convert(varchar(6), PRIORITY)) as [PRIORITY], 
  (SELECT name FROM labelfile WHERE labeldefinition = 'TaskType1' and abbr = USER_DEFINED_TYPE1) as [Type1],   
  (SELECT name FROM labelfile WHERE labeldefinition = 'TaskType2' and abbr = USER_DEFINED_TYPE2) as [Type2],  
  (SELECT name FROM labelfile WHERE labeldefinition = 'TaskType3' and abbr = USER_DEFINED_TYPE3) as [Type3],  
  (SELECT name FROM labelfile WHERE labeldefinition = 'TaskType4' and abbr = USER_DEFINED_TYPE4) as [Type4],        
  COMPLETED_DATE 
FROM TASK
   INNER JOIN @users as usr ON TASK.ASSIGNED_USER = usr.usrid 
   INNER JOIN @tasktypelist typelist ON TASK.TASK_TYPE = typelist.tasktype 
   INNER JOIN dbo.CSVStringsToTable_fn (@taskactivitytypelist) as actv ON TASK.ACTIVITY_TYPE = actv.value     
WHERE COMPLETED_DATE BETWEEN @s_date AND @e_date
AND [STATUS] = 'COMPLT'
ORDER BY ASSIGNED_USER, COMPLETED_DATE


GO
GRANT EXECUTE ON  [dbo].[rpt_crst_cmp_activity_task] TO [public]
GO
