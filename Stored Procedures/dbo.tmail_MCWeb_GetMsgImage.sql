SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_MCWeb_GetMsgImage] (@OrigMsgSN int)
AS
	/****** For MCWeb Mobile Comm Interface ******/
    /****** Date: 10/1/2002 DAG *******/ 

SET NOCOUNT ON

DECLARE @ptrval varbinary(16), @datalen int
	SELECT @ptrval = TEXTPTR(MsgImage), @datalen = DATALENGTH(MsgImage)
	   FROM tblMsgShareData (NOLOCK)
	   WHERE OrigMsgsn = @OrigMsgSN
	
	READTEXT tblMsgShareData.MsgImage @ptrval 0 @datalen
GO
GRANT EXECUTE ON  [dbo].[tmail_MCWeb_GetMsgImage] TO [public]
GO
