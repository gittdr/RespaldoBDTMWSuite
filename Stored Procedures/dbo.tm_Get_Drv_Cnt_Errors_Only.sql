SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Get_Drv_Cnt_Errors_Only]
	@iDriver_SN INT

AS

SET NOCOUNT ON

	/*
	
	LAB - PTS 57795 - 07/07/11 - Add NOLOCK in order to improve performance
	
	*/

	SELECT COUNT(DISTINCT tblMessages.SN) 
	FROM tblMessages (NOLOCK)
 		INNER JOIN tblMsgProperties (NOLOCK) ON tblMessages.SN = tblMsgProperties.MsgSN  
 		INNER JOIN tblHistory (NOLOCK) ON tblMessages.SN = tblHistory.MsgSN
 	WHERE tblHistory.DriverSN = @iDriver_SN
 		AND tblMessages.DTRead IS NULL 
 		AND tblMsgProperties.PropSN = 6
GO
GRANT EXECUTE ON  [dbo].[tm_Get_Drv_Cnt_Errors_Only] TO [public]
GO
