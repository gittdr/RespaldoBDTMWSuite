SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[rpt_crst_activity_summary_v2] (
  @userlist varchar(8000),
  @s_date datetime,
  @e_date datetime,
  @taskstatuslist varchar(8000),
  @taskactivitytypelist varchar(8000),
  @quoteonly varchar(1))

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @tmptask table (
  ASSIGNED_USER varchar(20),
  ACTIVITY_COUNT int)
  
declare @tmptar table (
  ASSIGNED_USER varchar(20),
  ACTIVITY_COUNT int)  
  
declare @users table (usrid varchar(20))  
declare @status table (tskstatus varchar(20))
declare @activitytype table (actvtytype varchar(6))
  
declare @cur_date datetime
set @cur_date = GETDATE()  

SET @e_date = convert(datetime, convert(varchar(11), @e_date, 101) + ' 23:59:59')

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

IF @taskactivitytypelist = 'ALL'
BEGIN
  INSERT INTO @activitytype
  SELECT DISTINCT abbr FROM labelfile where labeldefinition = 'TaskActivity'  
END
ELSE
BEGIN
  INSERT INTO @activitytype
  SELECT value FROM dbo.CSVStringsToTable_fn (@taskactivitytypelist)
END

IF @taskstatuslist = 'ALL'
BEGIN
  INSERT INTO @status
  SELECT DISTINCT abbr FROM labelfile where labeldefinition = 'Task Status'  
END
ELSE
BEGIN
  INSERT INTO @status
  SELECT value FROM dbo.CSVStringsToTable_fn (@taskstatuslist)
END

INSERT INTO @tmptask  
SELECT
  ASSIGNED_USER,
  COUNT(*) AS [ACTIVITY_COUNT]
FROM TASK
   INNER JOIN @users as usr ON TASK.ASSIGNED_USER = usr.usrid
   INNER JOIN @status as stat ON TASK.[STATUS] = stat.tskstatus    
   INNER JOIN @activitytype as actv ON TASK.ACTIVITY_TYPE = actv.actvtytype   	   
WHERE DUE_DATE BETWEEN @s_date AND @e_date
AND TASK_TYPE = 'ACTVTY' 
GROUP BY ASSIGNED_USER

INSERT INTO @tmptar
SELECT 
  th.tar_updateby,
  COUNT(*) AS [ACTIVITY COUNT]
FROM tariffheader th
  INNER JOIN tariffkey tk ON th.tar_number = tk.tar_number 
  INNER JOIN @users as usr ON th.tar_updateby = usr.usrid
WHERE tar_updateon BETWEEN @s_date AND @e_date  
GROUP BY th.tar_updateby

IF @quoteonly = 'Y'
BEGIN
	SELECT 
		t.usr_userid as ASSIGNED_USER,
		t.usr_lname + ', ' + t.usr_fname as [UserName],
		ISNULL(tsk.[ACTIVITY_COUNT],0) as [TASK_COUNT],
		ISNULL(tar.[ACTIVITY_COUNT],0) as [TAR_COUNT]
	FROM ttsusers t
	  INNER JOIN @users as usr ON t.usr_userid = usr.usrid
	  LEFT JOIN @tmptask tsk ON tsk.ASSIGNED_USER = t.usr_userid 
	  LEFT JOIN @tmptar tar ON tar.ASSIGNED_USER = t.usr_userid   
	WHERE ISNULL(tar.[ACTIVITY_COUNT],0) > 0
END
ELSE
BEGIN
	SELECT 
		t.usr_userid as ASSIGNED_USER,
		t.usr_lname + ', ' + t.usr_fname as [UserName],
		ISNULL(tsk.[ACTIVITY_COUNT],0) as [TASK_COUNT],
		ISNULL(tar.[ACTIVITY_COUNT],0) as [TAR_COUNT]
	FROM ttsusers t
	  INNER JOIN @users as usr ON t.usr_userid = usr.usrid
	  LEFT JOIN @tmptask tsk ON tsk.ASSIGNED_USER = t.usr_userid 
	  LEFT JOIN @tmptar tar ON tar.ASSIGNED_USER = t.usr_userid   
	WHERE (ISNULL(tsk.[ACTIVITY_COUNT],0) > 0 
	  OR   ISNULL(tar.[ACTIVITY_COUNT],0) > 0)
END


GO
GRANT EXECUTE ON  [dbo].[rpt_crst_activity_summary_v2] TO [public]
GO
