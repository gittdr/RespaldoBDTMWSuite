SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_tractor_msgs_sp] (@tractorID varchar(12), @startDate Datetime, @endDate Datetime)       
AS

/**
 * NAME: get_tractor_msgs_sp
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls all tractor messages for the date range
 *
 * NOTE!!: THIS PROC EXISTS IN BOTH TOTALMAIL AND OPERATIONS SOURCE CONTROL. 
 *			Make sure to modify in both places.
 *
 * PARAMETERS:
 * 001 - @TractorId varchar(12)
 * 002 - @startDate datetime
 * 003 - @endDate datetime
 *
 * REVISION HISTORY:
 * 03/25/14 - PTS76139 - MIZ - Added header with note to modify in both sources.
 * 03/25/14 - PTS76141 - MIZ - Pull error information.
 * 03/27/14 - PTS76140 - MIZ - Return message SN & OrigMsgSN
 * 03/29/14 - PTS76453 - MIZ - Add DtReceived and location columns.
 **/

Set nocount on
set transaction isolation level read uncommitted

SELECT 
msgImage AS MsgTextFull, 
readbyname AS ReadByName, 
fromtype AS FromType, 
fromname AS FromName, 
tblmessages.DeliverToType AS DeliverToType,
tblmessages.DeliverTo AS DeliverTo,
dtsent AS DateSent,
tblmessages.Subject AS Subject,
tbltrucks.DispSysTruckID as TractorID,
ISNULL(tblErrorData.Description, '') ErrorDesc,
tblMessages.SN AS SN,
tblMessages.OrigMsgSN AS OrigMsgSN,
ISNULL(DTReceived,'1/1/1950') as DateReceived,
ISNULL(Position,'') AS Position,
ISNULL(PositionZip,'') AS PositionZip,
ISNULL(NLCPosition,'') AS NLCPosition,
ISNULL(NLCPositionZip,'') AS NLCPositionZip

FROM tblmsgsharedata (NOLOCK) 
INNER JOIN tblmessages (NOLOCK) ON tblmessages.origmsgsn = tblmsgsharedata.origmsgsn
INNER JOIN tblhistory (NOLOCK) ON tblmessages.sn = tblhistory.msgsn
INNER JOIN tbltrucks (NOLOCK) ON tblhistory.TruckSN = tbltrucks.sn
INNER JOIN tbladdresstypes (NOLOCK) ON tblmessages.fromtype = tbladdresstypes.sn
LEFT OUTER JOIN tblMsgProperties (NOLOCK) ON tblMessages.SN = tblMsgProperties.MsgSN AND tblMsgProperties.PropSN = 6
LEFT OUTER JOIN tblErrorData (NOLOCK) ON tblMsgProperties.Value = tblErrorData.ErrListID

WHERE tbltrucks.DispSysTruckID = @tractorID AND DTSent > @startDate AND DTSent < @endDate
ORDER BY DTReceived DESC








GO
GRANT EXECUTE ON  [dbo].[get_tractor_msgs_sp] TO [public]
GO
