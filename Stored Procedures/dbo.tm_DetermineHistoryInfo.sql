SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_DetermineHistoryInfo]	@MessageSN int, 
					@BasedOnFromInfo int,	-- 0 To cut history based on To info, <>0 to cut for From info
					@HistTrk int out,	-- Result of Truck to cut history for (NULL if no truck history)
					@HistDrv int out,	-- Result of Driver to cut history for (NULL if no driver history)
					@TruckSN int=-1,	-- HistTrk if history for To info, FromTruckSN for From info
					@DriverSN int=-1,	-- HistDrv if history for To info, FromDriverSN for From info
					@BaseSN int=-1		-- BaseSN from message.
AS
-- This routine determines what history records are needed.  The optional parameters are all straight optimizations.  If they are
--	present, they will just save the queries to look them up.  Returns 0 if no history, or 1 if at least one object has history
--	and sets @HistTrk and @HistDrv parameters accordingly.
-- Rules for determining history:
--	First check for the No History flag.  If it is set, then return that there is no history.
--	Then check BasedOnFromInfo, if it is not False then:
--		Check if the message is its own Base (BaseSN = SN on tblMessages record).  If not, then return that there is no history.
--		If necessary, pull TruckSN and DriverSN from the FromTruckSN and FromDriverSN fields.
--		Check if TruckSN and/or DriverSN have history enabled.  Return whichever have history enabled.
--	Otherwise if BasedOnFromInfo is False then:
--		Check if the message is its own Base (BaseSN = SN on tblMessages record).  If not, then return that there is no history.
--		If necessary, pull TruckSN and DriverSN from the HistTrk and HistDrv fields (If history is needed, then "to" information 
--			will have been stamped there when message was put into Comm Inbox).
--		Check if TruckSN and/or DriverSN have history enabled.  Return whichever have history enabled.

SET NOCOUNT ON

declare @HistFlagsText varchar(100), @HistFlags int

SELECT @HistTrk=@TruckSN, @HistDrv=@DriverSN	-- Assume provided history.

IF @BasedOnFromInfo <> 0
	BEGIN
	IF @BaseSN = -1 OR @TruckSN = -1 OR @DriverSN = -1
		SELECT @BaseSN = BaseSN, @HistTrk=FromTrcSN, @HistDrv = FromDrvSN 
		FROM tblMessages (NOLOCK)
		WHERE SN = @MessageSN
	IF @BaseSN <> @MessageSN RETURN 0
	END
ELSE
	BEGIN
	IF @TruckSN = -1 OR @DriverSN = -1
		SELECT @HistTrk = HistTrk, @HistDrv = HistDrv 
		FROM tblMessages (NOLOCK)
		WHERE SN = @MessageSN
	END

-- Check for No history flag.
SELECT @HistFlags = 0
SELECT @HistFlagsText = ISNULL(Value, '0') 
	FROM tblMsgProperties (NOLOCK)
	INNER JOIN tblPropertyTypes (NOLOCK)
	ON tblPropertyTypes.SN = tblMsgProperties.PropSN 
	WHERE tblMsgProperties.MsgSN = @MessageSN AND tblPropertyTypes.PropertyName = 'History Flags'
SELECT @HistFlags = CASE WHEN ISNUMERIC(@HistFlagsText)<>0 THEN convert(int, @HistFlagsText) ELSE 0 END
IF (@HistFlags & 1) = 1 RETURN 0	-- Found the flag, say no history.

IF @HistDrv = 0 SELECT @HistDrv = NULL
IF ISNULL(@HistDrv, 0) <> 0
	BEGIN
	SELECT @HistFlags = KeepHistory 
	FROM tblDrivers (NOLOCK)
	WHERE SN = @HistDrv
	IF ISNULL(@HistFlags, 0) = 0 SELECT @HistDrv = NULL
	END
IF @HistTrk = 0 SELECT @HistTrk = NULL
IF ISNULL(@HistTrk, 0) <> 0
	BEGIN
	SELECT @HistFlags = KeepHistory 
	FROM tblTrucks (NOLOCK)
	WHERE SN = @HistTrk
	IF ISNULL(@HistFlags, 0) = 0 SELECT @HistTrk = NULL
	END
IF ISNULL(@HistTrk, 0)<> 0 OR ISNULL(@HistDrv, 0)<>0
	RETURN 1
ELSE
	RETURN 0
GO
GRANT EXECUTE ON  [dbo].[tm_DetermineHistoryInfo] TO [public]
GO
