SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_BounceMessage]	@MessageSN int,
					@VBErrNumber int = 0,
					@FailureMessage varchar(8000),
					@FailureSource varchar(254),
					@Flags int
AS
-- EDITS HISTORY:
-- 11/18/14 PTS83211 HMA - NO more nulls in the dtreceived fields

-- Defined flags:
--	+1: SetStatusFailed (see below)
--	+2: BounceOriginal (see below)
--	+4: FailOnly (see below)
--
-- This routine attaches the specified error to the target message (and its BaseSN).  If SetStatusFailed is true, then it will also set
--	the message(s) to failed status.  Then it will copy the message, and place the copy in a login inbox based on the FromName/FromType
--	as follows (first applicable rule wins): 
--		If the FromName/Type matches the DeliverToName/Type, go to the Admin Inbox
--		If the message is from a Login, go to the inbox of that login.
--		If the message is from a Truck or Driver with a known dispatchgroup, go to the inbox of that dispatchgroup.
--		If the message is from a Truck without a known dispatchgroup, but the FromDriverSN specifies a Driver with a known 
--			dispatchgroup, go to the inbox of that dispatchgroup.
--		If the message is from a Driver without a known dispatchgroup, but the FromTruckSN specifies a Truck with a known 
--			dispatchgroup, go to the inbox of that dispatchgroup.
--		Otherwise go to the Admin Inbox
--	If BounceOriginal is set, then it will not copy at all and instead will just put the original in the appropriate inbox.
--	If FailOnly is set, then it will neither copy nor move anything at all, but will just do the status and error data updates.
--		FailOnly makes BounceOriginal irrelevant.  This is primarily meant for adding warnings to messages in history.
DECLARE @BaseSN int, @SetStatusFailed int, @BounceOriginal int, @FromName varchar(50), @FromType int, @ToInbox int, @BouncedSN int
DECLARE @FromTruckSN int, @FromDriverSN int, @DeliverTo varchar(50), @DeliverToType int

SELECT 	@BaseSN = BaseSN, 
	@FromName = FromName, 
	@FromType = FromType,
	@FromTruckSN = FromTrcSN,
	@FromDriverSN = FromDrvSN,
	@DeliverTo = DeliverTo,
	@DeliverToType = DeliverToType
	FROM tblMessages WHERE SN = @MessageSN

SELECT @flags = isnull(@flags, 0)

EXEC tm_AddErrorToMessage @MessageSN, @VBErrNumber, @FailureMessage, @FailureSource, 0
if isnull(@BaseSN, 0)>0 AND isnull(@BaseSN, @MessageSN) <> @MessageSN
	EXEC tm_AddErrorToMessage @BaseSN, @VBErrNumber, @FailureMessage, @FailureSource, 0

if (@flags & 1) <> 0
	begin
	-- SetStatusFailed
	update tblmessages set status = 5 where sn = @MessageSN and status <> 5
	if isnull(@BaseSN, 0)>0
		update tblmessages set status = 5 where sn = @BaseSN and status <> 5
	end

if (@flags & 4) <> 0 RETURN

if (@flags & 2) <> 0 -- BounceOriginal
	select @BouncedSN = @MessageSN
else
	exec tm_Duplicate_Message @MessageSN, 1, @BouncedSN out, 0

if @FromName <> @DeliverTo or @FromType <> @DeliverToType
	BEGIN
	if @FromType = 1
		select @ToInbox = inbox from tbllogin where loginname = @FromName
	else if @FromType = 2
		begin	-- All others can be delivered directly.  This one requires additional updates, so verify the destination folder
			-- then go ahead and make those updates.
		if exists (select * from tblserver(NOLOCK) inner join tblfolders (NOLOCK) on tblserver.inbox = tblfolders.sn where servercode = 'M')
			begin
			update tblmessages set deliverto = @FromName, delivertotype = @FromType where sn = @BouncedSN
			select @ToInbox = tblServer.inbox from tblserver (NOLOCK) inner join tblfolders (NOLOCK) on tblserver.inbox = tblfolders.sn where servercode = 'M'
			end
		end
	else if @FromType = 4
		begin
		if exists (select * from tbldispatchgroup g (NOLOCK) inner join tbltrucks t (NOLOCK) on g.sn = t.currentdispatcher where t.truckname = @FromName)
			select @ToInbox = g.inbox from tbldispatchgroup g (NOLOCK) inner join tbltrucks t (NOLOCK) on g.sn = t.currentdispatcher where t.truckname = @FromName
		else if exists (select * from tbldispatchgroup g (NOLOCK) inner join tbltrucks t (NOLOCK) on g.sn = t.currentdispatcher where t.sn = @FromTruckSN)
			select @ToInbox = g.inbox from tbldispatchgroup g (NOLOCK) inner join tbltrucks t (NOLOCK) on g.sn = t.currentdispatcher where t.truckname = @FromTruckSN
		else if exists (select * from tbldispatchgroup g (NOLOCK) inner join tbldrivers d (NOLOCK) on g.sn = d.currentdispatcher where d.sn = @FromDriverSN)
			select @ToInbox = g.inbox from tbldispatchgroup g (NOLOCK) inner join tbldrivers d (NOLOCK) on g.sn = d.currentdispatcher where d.sn = @FromDriverSN
		end
	else if @FromType = 5
		begin
		if exists (select * from tbldispatchgroup g(NOLOCK) inner join tbldrivers d (NOLOCK)on g.sn = d.currentdispatcher where d.driverid = @FromName)
			select @ToInbox = g.inbox from tbldispatchgroup g  (NOLOCK) inner join tbldrivers d(NOLOCK) on g.sn = d.currentdispatcher where d.driverid = @FromName
		else if exists (select * from tbldispatchgroup g (NOLOCK) inner join tbldrivers d (NOLOCK) on g.sn = d.currentdispatcher where d.sn = @FromDriverSN)
			select @ToInbox = g.inbox from tbldispatchgroup g (NOLOCK) inner join tbldrivers d (NOLOCK) on g.sn = d.currentdispatcher where d.sn = @FromDriverSN
		else if exists (select * from tbldispatchgroup g (NOLOCK) inner join tbltrucks t (NOLOCK) on g.sn = t.currentdispatcher where t.sn = @FromTruckSN)
			select @ToInbox = g.inbox from tbldispatchgroup g (NOLOCK) inner join tbltrucks t (NOLOCK) on g.sn = t.currentdispatcher where t.truckname = @FromTruckSN
		end
	END
if not exists (select * from tblfolders (NOLOCK) where sn = @ToInbox)
	select @ToInbox = Inbox From tblserver (NOLOCK) where servercode = 'A'

--update tblmessages set folder = @ToInbox where sn = @BouncedSN
-- pts 83211 - NO more nulls in the dtreceived fields ^^old update above - below new update 
update tblmessages set folder = @ToInbox,DTReceived = ISNULL(DTReceived, GETDATE())  where sn = @BouncedSN

-- If the message went to a Login Inbox, mark that login as "Touched"
UPDATE tblLogin SET LastTMDlvry = GetDate() WHERE Inbox = @ToInbox

GO
GRANT EXECUTE ON  [dbo].[tm_BounceMessage] TO [public]
GO
