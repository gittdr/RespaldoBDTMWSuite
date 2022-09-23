SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_tractorDriver_msgs_sp] (@tractorID varchar(12), 
												@driverID varchar(20), 
												@startDate Datetime, 
												@endDate Datetime)       
AS

/**
 * NAME: get_tractorDriver_msgs_sp
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls all tractor messages for the date range, and all driver messages for the date range that 
 *   aren't a duplicate of a tractor message.
 *
 * NOTE!!: THIS PROC EXISTS IN BOTH TOTALMAIL AND OPERATIONS SOURCE CONTROL. 
 *			Make sure to modify in both places.
 *
 * PARAMETERS:
 * 001 - @TractorId varchar(12)
 * 002 - @driverID varchar(20)
 * 003 - @startDate datetime
 * 004 - @endDate datetime
 *
 * REVISION HISTORY:
 * 03/25/14 - PTS76139 - MIZ - Created Stored Procedure
 * 03/25/14 - PTS76141 - MIZ - Pull error information.
 * 03/27/14 - PTS76140 - MIZ - Return message SN & OrigMsgSN
 * 03/29/14 - PTS76453 - MIZ - Add DtReceived and location columns.
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

CREATE TABLE #trc (MsgTextFull text,
				   ReadByName varchar(50),
				   FromType int,
				   FromName varchar(50),
				   DeliverToType int,
				   DeliverTo varchar(50),
				   DateSent datetime,
				   [Subject] varchar(255),
				   TractorID varchar(20),
				   DriverID varchar(20),
				   SN int,
				   DateReceived datetime,
				   ErrorDesc text,
				   OrigMsgSN int,
				   Position varchar(50),
				   PositionZip varchar(9),
				   NLCPosition varchar(50),
				   NLCPositionZip varchar(9))

CREATE TABLE #drv (MsgTextFull text,
				   ReadByName varchar(50),
				   FromType int,
				   FromName varchar(50),
				   DeliverToType int,
				   DeliverTo varchar(50),
				   DateSent datetime,
				   [Subject] varchar(255),
				   TractorID varchar(20),
				   DriverID varchar(20),
				   SN int,
				   DateReceived datetime,
				   ErrorDesc text,
				   OrigMsgSN int,
				   Position varchar(50),
				   PositionZip varchar(9),
				   NLCPosition varchar(50),
				   NLCPositionZip varchar(9))
				   
-- Tractor messages
INSERT INTO #trc (MsgTextFull, ReadByName, FromType, FromName, DeliverToType, DeliverTo, DateSent, [Subject], TractorID, DriverID, SN, DateReceived, ErrorDesc, OrigMsgSN, Position, PositionZip, NLCPosition, NLCPositionZip)
SELECT msgImage AS MsgTextFull, 
	   readbyname AS ReadByName, 
	   fromtype AS FromType, 
	   fromname AS FromName, 
	   tblmessages.DeliverToType AS DeliverToType,
	   tblmessages.DeliverTo AS DeliverTo,
	   dtsent AS DateSent,
	   tblmessages.Subject AS Subject,
	   tbltrucks.DispSysTruckID as TractorID,
	   '',		-- DriverID
	   tblMessages.SN,
	   tblMessages.DTReceived,
	   ISNULL(tblErrorData.Description, '') ErrorDesc,
	   tblMessages.OrigMsgSN,
	   ISNULL(tblMessages.Position,''),
	   ISNULL(tblMessages.PositionZip,''),
	   ISNULL(tblMessages.NLCPosition,''),
	   ISNULL(tblMessages.NLCPositionZip,'')
FROM tblmsgsharedata (NOLOCK) 
	INNER JOIN tblmessages (NOLOCK) ON tblmessages.origmsgsn = tblmsgsharedata.origmsgsn
	INNER JOIN tblhistory (NOLOCK) ON tblmessages.sn = tblhistory.msgsn
	INNER JOIN tbltrucks (NOLOCK) ON tblhistory.TruckSN = tbltrucks.sn
	INNER JOIN tbladdresstypes (NOLOCK) ON tblmessages.fromtype = tbladdresstypes.sn
	LEFT OUTER JOIN tblMsgProperties (NOLOCK) ON tblMessages.SN = tblMsgProperties.MsgSN AND tblMsgProperties.PropSN = 6
	LEFT OUTER JOIN tblErrorData (NOLOCK) ON tblMsgProperties.Value = tblErrorData.ErrListID
WHERE tbltrucks.DispSysTruckID = @tractorID 
	AND DTSent > @startDate 
	AND DTSent < @endDate

-- Driver messages
INSERT INTO #drv (MsgTextFull, ReadByName, FromType, FromName, DeliverToType, DeliverTo, DateSent, [Subject], TractorID, DriverID, SN, DateReceived, ErrorDesc, OrigMsgSN, Position, PositionZip, NLCPosition, NLCPositionZip)
SELECT msgImage AS MsgTextFull, 
	   readbyname AS ReadByName, 
	   fromtype AS FromType, 
	   fromname AS FromName, 
	   tblmessages.DeliverToType AS DeliverToType,
	   tblmessages.DeliverTo AS DeliverTo,
	   dtsent AS DateSent,
	   tblmessages.Subject AS Subject,
	   '',		-- TractorID
	   tblDrivers.DispSysDriverID as DriverID,
	   tblMessages.SN,
	   tblMessages.DTReceived,
	   ISNULL(tblErrorData.Description, '') ErrorDesc,
	   tblMessages.OrigMsgSN,
	   ISNULL(tblMessages.Position,''),
	   ISNULL(tblMessages.PositionZip,''),
	   ISNULL(tblMessages.NLCPosition,''),
	   ISNULL(tblMessages.NLCPositionZip,'')	   
FROM tblmsgsharedata (NOLOCK) 
	INNER JOIN tblmessages (NOLOCK) ON tblmessages.origmsgsn = tblmsgsharedata.origmsgsn
	INNER JOIN tblhistory (NOLOCK) ON tblmessages.sn = tblhistory.msgsn
	INNER JOIN tbldrivers (NOLOCK) ON tblhistory.driversn = tbldrivers.sn
	INNER JOIN tbladdresstypes (NOLOCK) ON tblmessages.fromtype = tbladdresstypes.sn
	LEFT OUTER JOIN tblMsgProperties (NOLOCK) ON tblMessages.SN = tblMsgProperties.MsgSN AND tblMsgProperties.PropSN = 6
	LEFT OUTER JOIN tblErrorData (NOLOCK) ON tblMsgProperties.Value = tblErrorData.ErrListID
WHERE tblDrivers.DispSysDriverID = @driverID 
	AND DTSent > @startDate 
	AND DTSent < @endDate
ORDER BY DTReceived DESC

-- Update the driver in #trc for any message that exists in both driver and tractor history 
--  (only want one copy of message, with both driver and tractor populated).
UPDATE #trc
SET #trc.DriverID = #drv.DriverID
FROM #trc
INNER JOIN #drv on #trc.SN = #drv.SN
WHERE ISNULL(#drv.DriverID, 'UNKNOWN') <> 'UNKNOWN'

-- Add all driver messages that don't exist in the #trc table into the #trc table.
INSERT INTO #trc (MsgTextFull, ReadByName, FromType, FromName, DeliverToType, DeliverTo, DateSent, [Subject], TractorID, DriverID, SN, DateReceived, ErrorDesc, OrigMsgSN, Position, PositionZip, NLCPosition, NLCPositionZip)
SELECT MsgTextFull, ReadByName, FromType, FromName, DeliverToType, DeliverTo, DateSent, [Subject], TractorID, DriverID, SN, DateReceived, ErrorDesc, OrigMsgSN, Position, PositionZip, NLCPosition, NLCPositionZip
FROM #drv
WHERE #drv.SN NOT IN (SELECT SN FROM #trc)

-- Return results
SELECT MsgTextFull, 
	   ReadByName, 
	   FromType, 
	   FromName, 
	   DeliverToType, 
	   DeliverTo, 
	   DateSent, 
	   [Subject], 
	   TractorID, 
	   DriverID, 
	   ErrorDesc,
	   SN,
	   OrigMsgSN,
	   DateReceived,
	   Position, 
	   PositionZip, 
	   NLCPosition, 
	   NLCPositionZip
FROM #trc
ORDER BY DateReceived
GO
GRANT EXECUTE ON  [dbo].[get_tractorDriver_msgs_sp] TO [public]
GO
