SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[rpt_crst_activity_detail] (
  @s_date datetime,
  @e_date datetime,
  @taskstatuslist varchar(8000),
  @taskactivitytypelist varchar(8000),
  @ASSIGNED_USER varchar(20),
  @displaysub int)

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @status table (tskstatus varchar(20))
declare @activitytype table (actvtytype varchar(6))

SET @e_date = convert(datetime, convert(varchar(11), @e_date, 101) + ' 23:59:59')

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

  
SELECT
  TASK_ID,
  ASSIGNED_USER,
  [STATUS],
  (SELECT name from labelfile where labeldefinition = 'Task Status' and abbr = [STATUS]) as [STATUS_DESC],
  CASE WHEN TASK_LINK_ENTITY_TABLE_ID = 2 THEN TASK_LINK_ENTITY_VALUE ELSE '' END AS [COMPANY ID],
  CASE WHEN TASK_LINK_ENTITY_TABLE_ID = 2 
	THEN (SELECT cmp_name FROM company WHERE cmp_id = TASK_LINK_ENTITY_VALUE) ELSE '' END AS [COMPANY NAME],
  ACTIVITY_TYPE,
  DUE_DATE as [Activity Start Date],
  END_DATE as [Activity End Date],
  ORIGINAL_DUE_DATE as [Original Start Date],
  NAME as [Subject],
  [DESCRIPTION],
  CONTACT_NAME,
  PRIORITY
FROM TASK
   INNER JOIN @status as stat ON TASK.[STATUS] = stat.tskstatus    
   INNER JOIN @activitytype as actv ON TASK.ACTIVITY_TYPE = actv.actvtytype     
WHERE DUE_DATE BETWEEN @s_date AND @e_date
AND TASK_TYPE = 'ACTVTY' 
AND ASSIGNED_USER = @ASSIGNED_USER
AND @displaysub = 1
ORDER BY [STATUS], [Activity Start Date]


GO
GRANT EXECUTE ON  [dbo].[rpt_crst_activity_detail] TO [public]
GO
