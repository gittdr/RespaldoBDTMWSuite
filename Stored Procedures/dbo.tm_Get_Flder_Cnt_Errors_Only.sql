SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Get_Flder_Cnt_Errors_Only]
	@iFolder_SN INT

AS

	SELECT COUNT(*) 
	FROM tblMessages (NOLOCK)
	 	INNER JOIN tblMsgProperties (NOLOCK) ON tblMessages.SN = tblMsgProperties.MsgSN  
        	WHERE tblMessages.Folder = @iFolder_SN
		AND tblMessages.DTRead IS NULL AND tblMsgProperties.PropSN = 6

GO
GRANT EXECUTE ON  [dbo].[tm_Get_Flder_Cnt_Errors_Only] TO [public]
GO
