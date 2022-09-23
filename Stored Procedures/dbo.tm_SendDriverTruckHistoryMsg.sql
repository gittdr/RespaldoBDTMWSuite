SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_SendDriverTruckHistoryMsg]
( 
@DispSysTruckID varchar(20), -- = 'Q1'
@DispSysDriverID varchar(20), -- = 'Q1'
@Contents Varchar(max),
@Subject Varchar(255)
)
AS

SET NOCOUNT ON

DECLARE @HistFldrSN Int,
		@TrkSN Int,
		@DrvSN Int,
		@MsgSN Int,
		@FromName Varchar(50),
		@FromType Int,
		@DeliverTo Varchar(50),
		@DeliverToType Int
		
BEGIN TRY
	----------------------------------------------------------------------------------------------------------
	--	Get SN for the History Folder:
	----------------------------------------------------------------------------------------------------------
	SELECT @HistFldrSN = text
	FROM tblRS (NOLOCK)
	WHERE keyCode = 'HISTORY'

	IF ISNULL(@HistFldrSN,-1) < 0
		RAISERROR(N'History folder could not be found in tblRS', 16, 1)
	----------------------------------------------------------------------------------------------------------
	--	Get the Truck SN and TruckName:
	----------------------------------------------------------------------------------------------------------
	SELECT	@TrkSN = SN,
			@DeliverTo = TruckName		
	FROM tblTrucks (NOLOCK)
	WHERE DispSysTruckID = @DispSysTruckID

	IF ISNULL(@TrkSN,-1) < 0
		RAISERROR(N'tblTrucks record not found where DispSysTruckID = ''%s''', 16 ,1, @DispSysTruckID)
	----------------------------------------------------------------------------------------------------------
	--	Get the Driver SN:
	----------------------------------------------------------------------------------------------------------
	SELECT @DrvSN = SN
	FROM tblDrivers (NOLOCK) 
	WHERE DispSysDriverID = @DispSysDriverID 
	
	IF ISNULL(@DrvSN,-1) < 0
		RAISERROR(N'tblDrivers record not found where DispSysDriverID = ''%s''', 16 ,1, @DispSysDriverID)
	----------------------------------------------------------------------------------------------------------
	--	Get the Login AddressType SN since we are sending from ADMIN:
	----------------------------------------------------------------------------------------------------------
	SELECT	@FromType = SN,
			@FromName = 'ADMIN'
	FROM tblAddressTypes (NOLOCK) 
	WHERE AddressType = 'L'
	
	IF ISNULL(@FromType,-1) < 0
		RAISERROR(N'tblAddressTypes record not found where AddressType = ''L''', 16, 1)
	----------------------------------------------------------------------------------------------------------
	SELECT	@DeliverToType = SN
	FROM tblAddressTypes (NOLOCK) 
	WHERE AddressType = 'T'
	
	IF ISNULL(@DeliverToType,-1) < 0
		RAISERROR(N'tblAddressTypes record not found where AddressType = ''T''', 16, 1)
	----------------------------------------------------------------------------------------------------------
	BEGIN TRANSACTION
		----------------------------------------------------------------------------------------------------------
		INSERT INTO tblMessages	(Type, Status, Priority, FromType, DeliverToType, DTSent, DTReceived, DTTransferred, Folder, Contents, FromName, Subject, DeliverTo, HistDrv, HistTrk, Receipt, ToDrvSN, ToTrcSN)
		VALUES					(1,		4,		2,		@FromType, @DeliverToType,	GETDATE(),	GETDATE(), GETDATE(), @HistFldrSN, @Contents, @FromName, @Subject, @DeliverTo, @DrvSN, @TrkSN, 0,		@DrvSN,	@TrkSN)
		SELECT @MsgSN = SCOPE_IDENTITY()
		----------------------------------------------------------------------------------------------------------
		UPDATE tblMessages 
		SET OrigMsgSN = @MsgSN, BaseSN = @MsgSN 
		WHERE SN = @MsgSN 
		----------------------------------------------------------------------------------------------------------
		INSERT INTO tblHistory(DriverSN, TruckSN, MsgSN, Chached)
		VALUES(@DrvSN, @TrkSN, @MsgSN, 1)
		----------------------------------------------------------------------------------------------------------
		INSERT INTO tblTo(Message, ToName, ToType, DTTransferred, IsCC)
		VALUES(@MsgSN, @DeliverTo, @DeliverToType, GETDATE(), 0)
	COMMIT TRAN
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
	
END CATCH
GO
GRANT EXECUTE ON  [dbo].[tm_SendDriverTruckHistoryMsg] TO [public]
GO
