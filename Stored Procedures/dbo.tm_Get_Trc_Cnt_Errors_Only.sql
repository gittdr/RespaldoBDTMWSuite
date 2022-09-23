SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Get_Trc_Cnt_Errors_Only]
	@iTruck_SN INT

AS

	/*
	
	LAB - PTS 57795 - 07/07/11 - Remedy the Joins and where clause which had duplicate restrictions adn the add NOLOCK in order to improve performance
	
	*/


	SELECT COUNT(DISTINCT tblMessages.SN) 
	FROM tblMessages (NOLOCK)
 		JOIN tblMsgProperties (NOLOCK) ON tblMessages.SN = tblMsgProperties.MsgSN  
 		JOIN tblHistory (NOLOCK) ON tblMessages.SN = tblHistory.MsgSN
	WHERE tblHistory.TruckSN = @iTruck_SN
		AND tblMessages.DTRead IS NULL 
		AND tblMsgProperties.PropSN = 6

GO
GRANT EXECUTE ON  [dbo].[tm_Get_Trc_Cnt_Errors_Only] TO [public]
GO
