SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Get_Trc_Cnt] 
	@iTruck_SN INT

AS

	/*
	
	LAB - PTS 57795 - 07/07/11 - Remedy Join statements in order to improve performance
	
	*/


	SELECT COUNT(DISTINCT tblMessages.SN) 
	FROM tblMessages (NOLOCK)
		JOIN tblHistory (NOLOCK) ON tblMessages.SN = tblHistory.MsgSN
	WHERE tblHistory.TruckSN = @iTruck_SN
		AND tblMessages.DTRead IS NULL

GO
GRANT EXECUTE ON  [dbo].[tm_Get_Trc_Cnt] TO [public]
GO
