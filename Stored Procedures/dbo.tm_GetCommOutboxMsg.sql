SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetCommOutboxMsg]	@MessageSN int,
						@XactCount int=-1
AS
-- This routine checks if the message is from a cabunit (should always be true), and if so:
--		Pulls the equipment that the cabunit is in
--		If the message is not already addressed, marks it as addressed to the CHAR(160)+'UNKNOWN' Dispatch Group
--		Restamps the message as from that equipment and puts the message in the appropriate Transaction inbox for processing.
--	XactCount is a pure optimization parm which may be set to avoid having to look it up each time this is called.
--	The routine returns 1 if it successfully handles the message.

SET NOCOUNT ON

DECLARE @FromType int, @FromName varchar(30), @T1SN int, @T1Name varchar(30), @T2SN int, @T2Name varchar(30), @DSN int, @DName varchar(30)
DECLARE @FinalFolder int, @DeliverTo varchar(30),@DeliverToType int, @Subject varchar(255), @EqpSN int,@McuId varchar(50), --PTS34829
@XactCode VARCHAR(4) -- PTS 96833

SELECT @FromType = FromType, @FromName = FromName, @Subject = Subject, @DeliverTo  = DeliverTo, @DeliverToType  = DeliverToType  
FROM tblMessages (NOLOCK) 
WHERE SN= @MessageSN
IF LEFT(@Subject,3) = 'QC:' SELECT @Subject = ''

IF @FromType = 6
	BEGIN
	SET  @McuId= @FromName --PTS34829
	select @T1SN=t1.sn, @T1Name=t1.truckname, @T2SN=t2.sn, @T2Name=t2.truckname, @DSN=d.SN, @DName=D.Name
		FROM tblcabunits c (NOLOCK)
		left outer join tbltrucks t1 (NOLOCK) on c.truck = t1.sn
		left outer join tbltrucks t2 (NOLOCK) on ISNULL(c.linkedaddrtype, 0) = 4 and c.linkedobjsn = t2.sn
		left outer join tbldrivers d (NOLOCK) on ISNULL(c.linkedaddrtype, 0) = 5 AND c.linkedobjsn = d.sn
		where c.unitid = @FromName
	IF ISNULL(@T2SN, 0) > 0 AND ISNULL(@T2Name, '') <> ''
		SELECT @FromName = @T2Name, @FromType = 4, @EqpSN = @T2SN
	ELSE IF ISNULL(@DSN, 0) > 0 AND ISNULL(@DName, '') <> ''
		SELECT @FromName = @DName, @FromType = 5, @EqpSN = @DSN
	ELSE IF ISNULL(@T1SN, 0) > 0 AND ISNULL(@T1Name, '') <> ''
		SELECT @FromName = @T1Name, @FromType = 4, @EqpSN = @T1SN
	END
IF ISNULL(@EqpSN, 0)<>0
	BEGIN
		
		SELECT @FinalFolder = Inbox 
		FROM tblServer (NOLOCK) 
		WHERE ServerCode = 'T'

		--PTS 36731 START
 		IF ISNULL(@DeliverTo, '') <> ''	
 		BEGIN
 			IF NOT EXISTS (SELECT * 
 					FROM tblTo (NOLOCK)
 					WHERE Message = @MessageSN AND TOName = @DeliverTo AND ToType = @DeliverToType)
 			INSERT INTO tblTo (Message, ToName, ToType, DTTransferred, IsCC) 
 				VALUES (@MessageSN, @DeliverTo, @DeliverToType, GETDATE(), 0)
 			UPDATE tblMessages SET FromName = @FromName, FromType = @FromType, Folder = @FinalFolder, BaseSN = @MessageSN, Subject = @Subject, Mcuid= @McuId WHERE SN = @MessageSN--PTS34829 Mcuid value set
 		END
 		ELSE
 		BEGIN
 			SELECT @DeliverTo = CHAR(160) + 'UNKNOWN'
 			IF NOT EXISTS (SELECT * 
 						FROM tblTo (NOLOCK)
 						WHERE Message = @MessageSN AND TOName = @DeliverTo AND ToType = 3)
 			INSERT INTO tblTo (Message, ToName, ToType, DTTransferred, IsCC) 
 				VALUES (@MessageSN, @DeliverTo, 3, GETDATE(), 0)
 			UPDATE tblMessages SET DeliverTo = @DeliverTo, DeliverToType = 3, FromName = @FromName, FromType = @FromType, 
 					Folder = @FinalFolder, BaseSN = @MessageSN, Subject = @Subject, Mcuid= @McuId WHERE SN = @MessageSN --PTS34829 Mcuid value set
 		END
		--PTS 36731 END
 		RETURN 1
	END
RETURN 0

GO
GRANT EXECUTE ON  [dbo].[tm_GetCommOutboxMsg] TO [public]
GO
