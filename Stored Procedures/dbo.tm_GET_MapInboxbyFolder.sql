SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_MapInboxbyFolder]
	@MapInbox int
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_MapInboxbyFolder]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls PropSN, FldType and TypeName value base on a EntryType and PropSN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * PropSN, FldType and TypeName fields
 *
 * PARAMETERS:
 * 001 - @MapInbox int
 * 
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_MapInboxbyFolder]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT m.SN, m.OrigMsgSN, [Subject], DeliverTo, DeliverToType, FromName, FromType, Contents, 
DTSent, IsNull(at.Description,'') as [Description]
FROM dbo.tblMessages m
left join tblAddressTypes  at
on m.FromType = at.SN
WHERE Folder = @MapInbox



GO
GRANT EXECUTE ON  [dbo].[tm_GET_MapInboxbyFolder] TO [public]
GO
