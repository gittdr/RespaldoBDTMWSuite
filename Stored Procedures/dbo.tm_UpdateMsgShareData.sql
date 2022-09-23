SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_UpdateMsgShareData]  @lTMMessageSN int,  @sDispSysKey1 Varchar(20),  @sDispSysKey2 Varchar(20), @sDispSysKeyType Varchar(10)

AS

SET NOCOUNT ON

DECLARE @lOrigMsgSN int

IF ISNULL(@lTMMessageSN, 0) > 0
	SELECT @lOrigMsgSN = OrigMsgSN 
	FROM tblMessages (NOLOCK) 
	WHERE SN = @lTMMessageSN
	IF ISNULL(@lOrigMsgSN, 0) > 0 
		UPDATE tblMsgShareData SET DispSysKey1 = @sDispSysKey1, DispSysKey2 = @sDispSysKey2, DispSysKeyType = @sDispSysKeyType  WHERE OrigMsgSN = @lOrigMsgSN


GO
GRANT EXECUTE ON  [dbo].[tm_UpdateMsgShareData] TO [public]
GO
