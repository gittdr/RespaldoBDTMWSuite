SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_MoveMsgToHistory]  @MessageSN int, 
                                          @BasedOnFromInfo int,	-- 0 To cut history based on To info, <>0 to cut for From info
                                          @TruckSN int=-1,	-- ToTruckSN if history for To info, FromTruckSN for From info
                                          @DriverSN int=-1,	-- ToDriverSN if history for To info, FromDriverSN for From info
                                          @HistoryFolder int =-1, -- tblRS text for 'HISTORY' keycode
                                          @BaseSN int=-1,		-- BaseSN from message.
                                          @HistTrk int=-1,	-- Previously determined History Truck
                                          @HistDrv int=-1,	-- Previously determined History Driver
                                          @HistReq int=-1,	-- Previously determined History Required flag
                                          @FilterBased int=-1,	-- tblRS text for 'FltInbox' keycode
                                          @HistoryPerfEventSN INT = -1 --Hisotry event, 0 means Performance monitoring turned off
AS
/*******************************************************************************************************************  
  Object Description:
   This routine makes any necessary history records and moves the message to the history folder (unless all relevant history entries are
	  disabled, in which case it instead deletes the message).  The optional parameters are all straight optimizations.  If they are
	  present, they will just save the queries to look them up.
   Rules for determining history:
	  First check for the No History flag.  If it is set, then cut that there is no history and exit.
	  Then check BasedOnFromInfo, if it is False then:
		  If necessary, pull TruckSN and DriverSN from the ToTruckSN and ToDriverSN fields.
		  Check if TruckSN and/or DriverSN have history enabled.  If either is true, setup history accordingly and exit.  
			  Otherwise, cut that there is no history and exit.
	  Otherwise if BasedOnFromInfo is not False then:
		  Check if the message is its own Base (BaseSN = SN on tblMessages record).  If not, then cut that there is no 
			  history and exit.
		  If necessary, pull TruckSN and DriverSN from the FromTruckSN and FromDriverSN fields.
		  Check if TruckSN and/or DriverSN have history enabled.  If either is true, setup history accordingly and exit.  
			  Otherwise, check if FilterBased is on.
				  If so, then setup history for both pieces of equipment anyway.
				  If not then cut that there is no history and exit.
   Method for cutting that there is no history:
	  Delete the message from the database.
   Methods for setting up history:
	  Set HistTrk and HistDrv on the message.
	  Create a tblHistory record for the message for the enabled Truck/Driver.
	  Move the message to the History Folder.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/09/27   W. Riley Wolfe    PTS101024    Adding in performance monitoring stuff
********************************************************************************************************************/
SET NOCOUNT ON

DECLARE @RSValue varchar(255)

if @HistReq = -1 OR @HistTrk = -1 OR @HistDrv = -1
	EXEC @HistReq = tm_DetermineHistoryInfo @MessageSN, @BasedOnFromInfo, @HistTrk out, @HistDrv out, @TruckSN, @DriverSN, @BaseSN
IF @HistReq = 0
	BEGIN
	EXEC tm_KillMsg @MessageSN
	RETURN
	END
ELSE
	BEGIN
	IF @HistoryFolder = -1
		BEGIN
		EXEC GetRSValue_sp 'HISTORY', @RSValue OUT
		SELECT @HistoryFolder = CONVERT(int, @RSValue)
		END
	-- Make History index table entry.
	INSERT tblHistory (DriverSN, TruckSN, MsgSN, Chached) VALUES (@HistDrv, @HistTrk, @MessageSN, 0)
	-- Set HistDrv/HistTrk.  Put message in History Folder.  Set DTReceived so that message will show at top of scroll (for Outbounds, 
	--		Processing status will indicate not actually received yet).
	UPDATE tblMessages SET HistDrv = @HistDrv, HistTrk = @HistTrk, Folder = @HistoryFolder, DTReceived = ISNULL(DTReceived, GETDATE()) WHERE SN = @MessageSN
  
  --check PerfMonitoring
  IF @HistoryPerfEventSN = -1
    IF (Select COALESCE([Text], 0) from tblRS where keyCode = 'LiveMsgPer') = 1
      SELECT @HistoryPerfEventSN = COALESCE(PerfEventNum, 0) from tblEventsMsgPerformance WHERE EventCode = 'HITHISTORY'
  
  IF @HistoryPerfEventSN > 0
    EXEC tm_Perf_PostEventNow @HistoryPerfEventSN, @MessageSN
	RETURN
	END
GO
GRANT EXECUTE ON  [dbo].[tm_MoveMsgToHistory] TO [public]
GO
