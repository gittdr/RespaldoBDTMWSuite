SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Get_Inbox_Cnt]
	@iLoginSN int,
	@iLoginInboxSN int

AS

	/*
	
	LAB - PTS 57795 - 07/07/11 - Modified to remove Index Hint, Remedy Join statements, and remove the 'KEEP PLAN' in order to improve performance
	LAB - PTS 64980 - 09/18/2012 - Modified for Read Uncommitted and revised select statement

	*/

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT COUNT(*) 
	FROM tblMessages m 
	INNER JOIN
		(
		SELECT InBox 
		FROM tblDispatchGroup 
			INNER JOIN tblDispatchLogins ON tblDispatchLogins.DispatchGroupSN = tblDispatchGroup.SN
		WHERE tblDispatchLogins.LoginSN = @iLoginSN 
		UNION
		SELECT @iLoginInboxSN
		) ib
	ON m.folder = ib.Inbox
	WHERE m.DTRead is null


GO
GRANT EXECUTE ON  [dbo].[tm_Get_Inbox_Cnt] TO [public]
GO
