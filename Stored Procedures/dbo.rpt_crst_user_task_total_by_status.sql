SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[rpt_crst_user_task_total_by_status] (
  @ASSIGNED_USER varchar(20),
  @s_date datetime,
  @e_date datetime,
  @taskstatuslist varchar(8000),
  @taskactivitytypelist varchar(8000))

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
  ASSIGNED_USER,
  [STATUS],
  (SELECT name from labelfile where labeldefinition = 'Task Status' and abbr = [STATUS]) as [STATUS_DESC],
  COUNT(*) AS [ACTIVITY_COUNT]
FROM TASK   
   INNER JOIN @status as stat ON TASK.[STATUS] = stat.tskstatus    
   INNER JOIN @activitytype as actv ON TASK.ACTIVITY_TYPE = actv.actvtytype   
WHERE DUE_DATE BETWEEN @s_date AND @e_date
AND ASSIGNED_USER = @ASSIGNED_USER
AND TASK_TYPE = 'ACTVTY' 
GROUP BY ASSIGNED_USER, [STATUS]

GO
GRANT EXECUTE ON  [dbo].[rpt_crst_user_task_total_by_status] TO [public]
GO
