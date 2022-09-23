SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CurrentUnreadMsgs]
	@AdminInbox int
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CurrentUnreadMsgs]
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
 * 001 - @AdminInbox int
 *       
 *
 * REVISION HISTORY:
 * 06/12/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_CurrentUnreadMsgs]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT SN, Subject, DeliverTo, DeliverToType, FromName, FromType, Contents, ResubmitOf, DTSent, DTReceived, 
VehicleIgnition, Position, PositionZip, NLCPosition, NLCPositionZip, Latitude, Longitude, 
ISNULL(DTPosition,'1/1/1950') DTPosition, Odometer, Type, SpecialMsgSN, 
CONVERT(VARCHAR(30), GETDATE(), 121) As sGetDate, Priority, ReplyMsgSN, ReplyMsgPage, OrigMsgSN 
FROM tblMessages(NoLock) 
WHERE tblMessages.Folder = @AdminInbox
AND ISNULL (DTRead, '') = '' 
ORDER BY DTSent ASC, SN ASC 

GO
GRANT EXECUTE ON  [dbo].[tm_GET_CurrentUnreadMsgs] TO [public]
GO
