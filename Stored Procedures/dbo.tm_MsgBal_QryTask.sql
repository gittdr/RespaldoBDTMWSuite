SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_QryTask] @AgentID UNIQUEIDENTIFIER, 
                                           @GotTask int OUTPUT
/*******************************************************************************************************************  
  Object Description:
    gets a Task for an Agent to process
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/03/03   W. Riley Wolfe    PTS98345     init 
  2016/06/28   W. Riley Wolfe    PTS101538    minor cleanup of locking and format
********************************************************************************************************************/
AS
SET NOCOUNT ON;
Declare @SN int, @Task varchar(10), @Data varchar(250);

DELETE tblTranTaskList
WHERE Agent = @AgentID;

BEGIN TRAN
UPDATE tblTranTaskList
SET StartTime = GETDATE(),
	Agent = @AgentID
WHERE SN = (
		SELECT TOP (1) SN
		FROM tblTranTaskList WITH (TABLOCKX, HOLDLOCK) /*  <--MsgBal Querrys CANNOT run at the same time */
		WHERE Agent IS NULL
    ORDER BY SN
		);
COMMIT TRAN

SELECT @SN = SN,
	@Task = Task,
	@Data = Data
FROM tblTranTaskList(NOLOCK)
WHERE Agent = @AgentID;

IF (COALESCE(@SN, 0) > 0)
BEGIN
	SELECT @SN AS SN,
		@Task AS Task,
		@Data AS Data;

	SET @GotTask = 1;
END
ELSE
BEGIN
	SET @GotTask = 0;
END
GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_QryTask] TO [public]
GO
