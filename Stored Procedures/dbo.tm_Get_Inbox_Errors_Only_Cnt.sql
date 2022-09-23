SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Get_Inbox_Errors_Only_Cnt]
	@iLoginSN int,
	@iLoginInboxSN int

AS

	/*
	
	LAB - PTS 57795 - 07/07/11 - Modified to remove Index Hint, Remedy Join statements, remove the 'KEEP PLAN', and add NOLOCK in order to improve performance
	
	*/

	CREATE TABLE #T ( Inbox int ) 

	-- Get the full folder list into a temp table.
	INSERT INTO #T 
	SELECT InBox 
	FROM tblDispatchGroup (NOLOCK)
		JOIN tblDispatchLogins (NOLOCK) ON tblDispatchLogins.DispatchGroupSN = tblDispatchGroup.SN 
	WHERE tblDispatchLogins.LoginSN = @iLoginSN  

	INSERT INTO #T (InBox) VALUES (@iLoginInboxSN)
 
	SELECT COUNT(*) 
	FROM tblMessages (NOLOCK)
 		INNER JOIN tblMsgProperties (NOLOCK) ON tblMessages.SN = tblMsgProperties.MsgSN  
 		JOIN #T ON tblMessages.Folder = #T.Inbox
 	WHERE tblMessages.DTRead IS NULL 
 		AND tblMsgProperties.PropSN = 6 
	
GO
GRANT EXECUTE ON  [dbo].[tm_Get_Inbox_Errors_Only_Cnt] TO [public]
GO
