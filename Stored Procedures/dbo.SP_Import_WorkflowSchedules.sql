SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SP_Import_WorkflowSchedules]
@WorkflowName varchar(50), @SCHUNIT INT, @SCHUNITTYPE VARCHAR(10),@SCHNEXTRUN DATETIME, @SCHSTARTTIME DATETIME,@SCHENDTIME DATETIME,
@SUNDAY CHAR(1),@MONDAY CHAR(1),@TUESDAY CHAR(1),@WEDNESDAY CHAR(1),@THURSDAY CHAR(1),@FRIDAY CHAR(1),@SATURDAY CHAR(1),@ACTIVE CHAR(1)
AS
BEGIN
DECLARE @SQL VARCHAR(1000) 
DECLARE @WORKFLOW_TEMPLATEID INT 
DECLARE @SQLCMD NVARCHAR(1000)

SELECT @WORKFLOW_TEMPLATEID = WORKFLOW_TEMPLATE_ID FROM [WorkFlow_Template] WHERE Workflow_Template_Name = @WorkflowName
SET @SQLCMD = 'INSERT INTO WORKFLOW_SCHEDULE (WorkFlow_Template_id,SchUnit,SchUnitType,SchNextRun,SchStartTime,SchEndTime,Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Active)
 VALUES('+convert(varchar, @WORKFLOW_TEMPLATEID)+','+convert(varchar, @SCHUNIT)+','''+@SCHUNITTYPE+''',''' + convert(varchar, @SCHNEXTRUN) + ''',''' + convert(varchar, @SCHSTARTTIME) + ''',''' 
 + convert(varchar, @SCHENDTIME) + ''','''+@SUNDAY+''','''+@MONDAY+''','''+@TUESDAY+''','''+@WEDNESDAY+''','''+@THURSDAY+''','''
 +@FRIDAY+''','''+@SATURDAY+''','''+@ACTIVE+''')'

exec(@SQLCMD) 

	
END

GO
GRANT EXECUTE ON  [dbo].[SP_Import_WorkflowSchedules] TO [public]
GO
