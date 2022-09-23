SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_DeliverXactOutboxMsg]	@MessageSN int,	-- Message to Deliver
                                              @HistoryFolder int=-1,	-- tblRS text for 'HISTORY' keycode
                                              @FilterBased int=-1,	-- tblRS text for 'FltInbox' keycode
                                              @XactSink int=-1,	-- tblRS text for 'XactSink' keycode
                                              @XactCount int=-1,	-- tblRS text for 'XactCount' keycode
                                              @HistoryPerfEventSN INT = -1 
AS
/*******************************************************************************************************************  
  Object Description:
   This routine delivers the message to the appropriate destination.  The optional parameters are pure optimization parameters.  If they
	  are set, they simply save the system having to look up this data for every applicable message.  The first specifies the folder that
	  history is stored in.  The second specifies whether the system is setup for Filter Based processing (in which case DeliverTo info
	  is never required, but History can only be bypassed by the Hide Message from history view).  The final specifies whether the
	  Transaction Agent is set to accept all messages (in which case neither DeliverTo nor history information is ever required).

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/09/27   W. Riley Wolfe    PTS101024    Adding in performance monitoring stuff
********************************************************************************************************************/

SET NOCOUNT ON

-- These variables contain data from the message
DECLARE @DeliverTo varchar(50),	-- DeliverTo
	@DeliverToType int,	-- DeliverToType
	@ToTruckSN int,		-- ToTrcSN 
	@ToDriverSN int,	-- ToDrvSN
	@FromName varchar(50),	-- FromName
	@FromType int,		-- FromType
	@FromTruckSN int,	-- FromTrcSN 
	@FromDriverSN int,	-- FromDrvSN
	@BaseSN int,		-- BaseSN
	@DeliveryKey int 

-- These ones are derived from information on the message.
DECLARE	@HistTrk int,		-- History Truck
	@HistDrv int,		-- History Driver
	@HistReq int		-- History Required flag

-- Working variables
DECLARE @DispatchGroup varchar(50),	-- Dispatch Group
	@FromTypeText varchar(20),	-- Text equivalent of FromType For error messages
	@RSValue varchar(100),		-- Holding variable for tblRS reads
	@ErrMessage varchar(200)	-- Error message build var

SELECT	@DeliverTo = isnull(DeliverTo, ''), 
	@DeliverToType = isnull(DeliverToType, 0), 
	@ToTruckSN = ToTrcSN, 
	@ToDriverSN = ToDrvSN, 
	@FromTruckSN = FromTrcSN, 
	@FromDriverSN = FromDrvSN, 
	@FromName = FromName,
	@FromType = FromType,
	@BaseSN = BaseSN,
	@DeliveryKey = DeliveryKey
	FROM tblMessages (NOLOCK)
	WHERE SN = @MessageSN

if @DeliveryKey & 16 = 16
BEGIN
	declare @histMsg int,
			@Admin int
	if @ToTruckSN > 0 or @ToDriverSN > 0
	BEGIN
		exec tm_duplicate_message @MessageSN, 1, @histMsg OUT, 0	-- Make a copy to be delivered
		exec tm_MoveMsgToHistory @histMsg, 1, @FromTruckSN, @FromDriverSN, @HistoryFolder, @BaseSN, @HistTrk, @HistDrv, @HistReq, @FilterBased, @HistoryPerfEventSN	-- Move copy to history.
	END
	select @admin = Inbox from tblServer where ServerCode = 'A'
	update tblMessages set Folder = @Admin, [status] = 5, DeliveryKey = 0 where SN = @MessageSN
	Return 1
END

IF @DeliverToType = 3 AND @DeliverTo = CHAR(160)+'UNKNOWN'
	BEGIN
	IF @FromType = 5	--Driver
		BEGIN
		SELECT @DispatchGroup = G.Name 
		FROM tblDispatchGroup G (NOLOCK)
		INNER JOIN tblDrivers D (NOLOCK)ON G.SN = D.CurrentDispatcher 
		WHERE D.SN = @FromDriverSN
		IF ISNULL(@DispatchGroup, '') = ''
			SELECT @DispatchGroup = G.Name 
			FROM tblDispatchGroup G (NOLOCK)
			 INNER JOIN tblTrucks T (NOLOCK) ON G.SN = T.CurrentDispatcher 
			 WHERE T.SN = @FromTruckSN
		IF ISNULL(@DispatchGroup, '') = ''
			SELECT @DispatchGroup = G.Name 
			FROM tblDispatchGroup G (NOLOCK)
			INNER JOIN tblDrivers D (NOLOCK) ON G.SN = D.CurrentDispatcher 
			WHERE D.Name = @FromName
		END
	ELSE
		BEGIN
		SELECT @DispatchGroup = G.Name 
		FROM tblDispatchGroup G (NOLOCK)
		INNER JOIN tblTrucks T (NOLOCK) ON G.SN = T.CurrentDispatcher 
		WHERE T.SN = @FromTruckSN
		IF ISNULL(@DispatchGroup, '') = ''
			SELECT @DispatchGroup = G.Name 
			FROM tblDispatchGroup G (NOLOCK) 
			INNER JOIN tblDrivers D (NOLOCK) ON G.SN = D.CurrentDispatcher 
			WHERE D.SN = @FromDriverSN
		IF ISNULL(@DispatchGroup, '') = ''
			SELECT @DispatchGroup = G.Name 
			FROM tblDispatchGroup G (NOLOCK)
			INNER JOIN tblTrucks T (NOLOCK) ON G.SN = T.CurrentDispatcher 
			WHERE T.TruckName = @FromName
		END
	IF ISNULL(@DispatchGroup, '') <> ''
		BEGIN
		UPDATE tblTo SET ToName = @DispatchGroup 
			FROM tblTo (NOLOCK)
			INNER JOIN tblMessages f (NOLOCK) ON tblTo.Message = f.SN 
			INNER JOIN tblMessages o (NOLOCK) ON f.OrigMsgSN = ISNULL(o.OrigMsgSN, -1) 
			WHERE tblTo.ToType = 3 AND tblTo.ToName = CHAR(160) + 'UNKNOWN' AND o.SN = @MessageSN
		UPDATE tblTo SET ToName = @DispatchGroup FROM tblTo WHERE tblTo.ToType = 3 AND tblTo.ToName = CHAR(160) + 'UNKNOWN' AND tblTo.Message = @MessageSN
		END
	ELSE
		BEGIN
		IF ISNULL(@FilterBased, -1) = -1
			BEGIN
			SELECT @RSValue=null
			EXEC GetRSValue_sp 'FltInbox', @RSValue OUT
			SELECT @FilterBased = CONVERT(int, ISNULL(@RSValue, '0'))
			END
		IF ISNULL(@XactSink, -1) = -1
			BEGIN
			SELECT @RSValue=null
			EXEC GetRSValue_sp 'XactSink', @RSValue OUT
			SELECT @XactSink = CONVERT(int, ISNULL(@RSValue, '0'))
			END
		IF @FilterBased = 0 and @XactSink = 0
			BEGIN
			-- Cannot resolve Dispatch Group is bad if there is no alternate handler defined, so gripe.
			SELECT 	@ErrMessage = 'ResetUnknownDispatchGroup: Could not resolve dispatchgroup for ~1: ~2',
				@FromTypeText = CONVERT(varchar(20), @FromType)
			EXEC tm_t_sp @ErrMessage out, 0, ''
			exec tm_sprint @ErrMessage out, @FromName, @FromType, '', '', '', '', '', '', '', ''
			Exec tm_BounceMessage @MessageSN, 0, @ErrMessage, 'clsDelivery', 1	-- Fail it.
			exec tm_MoveMsgToHistory @MessageSN, 1, @FromTruckSN, @FromDriverSN, @HistoryFolder, @BaseSN, -1, -1, -1, @FilterBased
			RETURN 2
			END
		END
	SELECT @DeliverTo = @DispatchGroup
	END
ELSE 
	UPDATE tblTo SET ToName = @DeliverTo, ToType = @DeliverToType WHERE ToName = CHAR(160)+'UNKNOWN' AND Message = @MessageSN

IF @DeliverTo = 'TMWHistoryOnly' SELECT @DeliverTo = ''

IF @BaseSN = @MessageSN
	BEGIN
	EXEC @HistReq = tm_DetermineHistoryInfo @MessageSN, 1, @HistTrk out, @HistDrv out, @FromTruckSN, @FromDriverSN,	@BaseSN
	IF @DeliverTo <> '' AND @HistReq <> 0	-- Ready for history, and a deliverto is present...
		BEGIN
		exec tm_duplicate_message @BaseSN, 1, @MessageSN OUT, 0	-- Make a copy to be delivered
		exec tm_DeliverOneMessage @MessageSN, 0, @DeliverTo, @DeliverToType, @ToTruckSN, @ToDriverSN, @XactCount, @BaseSN	-- Deliver it.
		exec tm_MoveMsgToHistory @BaseSN, 1, @FromTruckSN, @FromDriverSN, @HistoryFolder, @BaseSN, @HistTrk, @HistDrv, @HistReq, @FilterBased, @HistoryPerfEventSN 	-- Move original to history.
		END
	ELSE IF @DeliverTo <> '' -- AND @HistReq = 0 (Not required because implied by earlier if clause)
		BEGIN	-- Somebody to deliver to, but no history required yet.
		exec tm_DeliverOneMessage @MessageSN, 0, @DeliverTo, @DeliverToType, @ToTruckSN, @ToDriverSN, @XactCount, @BaseSN	-- Just deliver the original.
		END
	ELSE IF @HistReq <> 0	-- AND @DeliverTo = '' (Not required because implied by earlier ifs)
		BEGIN	-- On Direct to history (ie: hide if no errors), update historical copy to Sent status.
		UPDATE tblMessages SET Status = 4, DTReceived = GETDATE() WHERE SN = @MessageSN	-- Update original
		IF ISNULL(@BaseSN, 0) <> 0 AND ISNULL(@BaseSN, 0) <> @MessageSN
			UPDATE tblMessages SET Status = 4, DTReceived = ISNULL(DTReceived, GETDATE()) WHERE SN = @BaseSN AND Status < 4	-- And base
		exec tm_MoveMsgToHistory @BaseSN, 1, @FromTruckSN, @FromDriverSN, @HistoryFolder, @BaseSN, @HistTrk, @HistDrv, @HistReq, @FilterBased, @HistoryPerfEventSN	-- And put this in history.
		END
	ELSE	-- No history AND no destination.  Bye bye.
		BEGIN
		IF @XactSink = 0
			-- No history, no destination, no forward to another system.  Probably something wrong....
			-- First check if no history is by a specific request (ie: a view).
			IF NOT EXISTS (SELECT 1
							FROM tblMsgProperties (NOLOCK)
							INNER JOIN tblPropertyTypes (NOLOCK) ON tblPropertyTypes.SN = tblMsgProperties.PropSN 
							WHERE tblMsgProperties.MsgSN = @MessageSN AND tblPropertyTypes.PropertyName = 'History Flags')
				-- Units must not be configured for history.  Bitch.
				BEGIN
				SELECT 	@ErrMessage = 'Nowhere to deliver message to: Dispatch group not set or history off?'
				EXEC tm_t_sp @ErrMessage out, 0, ''
				exec tm_sprint @ErrMessage out, @FromName, @FromType, '', '', '', '', '', '', '', ''
				Exec tm_BounceMessage @MessageSN, 0, @ErrMessage, 'clsDelivery', 3	-- Fail it.
				RETURN 2
				END
			ELSE
				-- He specifically asked for it, so on their own head be it.
				exec tm_MoveMsgToHistory @BaseSN, 1, @FromTruckSN, @FromDriverSN, @HistoryFolder, @BaseSN, @HistTrk, @HistDrv, @HistReq, @FilterBased, @HistoryPerfEventSN
		ELSE
			-- Has been forwarded, so just delete.
			exec tm_MoveMsgToHistory @BaseSN, 1, @FromTruckSN, @FromDriverSN, @HistoryFolder, @BaseSN, @HistTrk, @HistDrv, @HistReq, @FilterBased, @HistoryPerfEventSN
		END
	END
ELSE IF @DeliverTo <> ''
	exec tm_DeliverOneMessage @MessageSN, 0, @DeliverTo, @DeliverToType, @ToTruckSN, @ToDriverSN, @XactCount, @BaseSN
ELSE
	exec tm_KillMsg @MessageSN
RETURN 1
GO
GRANT EXECUTE ON  [dbo].[tm_DeliverXactOutboxMsg] TO [public]
GO
