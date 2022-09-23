SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_SplitText_SetChildInfo] @ParentMsgSN INT, @ChildMsgSN INT, @Subject VARCHAR(255), @Body VARCHAR(8000)
/*******************************************************************************************************************  
  Object Description:
  Sets split status on parent if needed, redefines child with Data.
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  06/08/2016   Riley Wolfe      PTS:102943    Initial Release
  07/21/2016   David Lehr       PTS:102460    Clean up tblMsgProperties for PNet forms as text msgs
********************************************************************************************************************/
AS
SET NOCOUNT ON;
DECLARE @changed INT;

UPDATE 
  tblMessages
SET 
  [Status] = 5
  ,[Subject] = LEFT('Message Split: ' + [Subject], 255)
WHERE 
  SN = @ParentMsgSN
    AND
  [Status] <> 5;

UPDATE
  tblMessages
SET 
  [Subject] = @Subject
  ,[Contents] = @Body
WHERE 
  SN = @ChildMsgSN;

DELETE 
FROM 
  [dbo].[tblMsgProperties]
WHERE 
  [MsgSN] = @ChildMsgSN;
GO
GRANT EXECUTE ON  [dbo].[tm_SplitText_SetChildInfo] TO [public]
GO
