SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_DeleteDriver] 	@sDriverName varchar(15) = NULL, 
										@sDriverSN varchar(12) = NULL,
										@sDispatchSystemID varchar(20) = NULL, 
										@sDeleteHistory varchar(1) = NULL,
										@sDeleteCabUnit varchar(1) = NULL

AS

--//  @sDriverName				- TotalMail Driver Name to delete (Optional if SN or Dispatch ID supplied)
--//  @sDriverSN				- Driver SN to delete (Optional if Name or Dispatch ID supplied)
--//  @sDispatchSystemID		- Dispatch System ID for Driver to delete (Optional if Name or SN supplied). 
--//  @sDeleteHistory     - Delete history messages for Driver
--//        0 or No, 1 for Yes. 
--//        NULL means keep history messages
--//
--//  @sDeleteCabUnit     - Delete cab unit for Driver
--//        0 or No, 1 for Yes. 
--//        NULL means keep cab unit
--//

SET NOCOUNT ON

DECLARE @lDriverSN int, 
		@lDeleteHistory int,
		@lDeleteCabUnit int,
		@lFolderSN int,
		@iDriverAddressType int,
		@lAddressesSN int,
		@lCabUnitSN int,
		@sUnitType varchar(20),
		@iDrvMaster int,
		@TrkMaster int,
		@iMCMaster int,
		@iLgnMaster int,
		@SndResInfo	int --PTS #40978
	
SELECT @sDriverName = ISNULL(@sDriverName, '')
SELECT @sDispatchSystemID = ISNULL(@sDispatchSystemID, '')
SELECT @lDriverSN = ISNULL(CONVERT(int, @sDriverSN), 0)

IF @lDriverSN = 0
	BEGIN
		IF @sDriverName > ''
			BEGIN
				SELECT @lDriverSN = SN 
				FROM tblDrivers (NOLOCK)
				WHERE Name = @sDriverName
				
				IF ISNULL(@lDriverSN, 0) = 0
					BEGIN
					RAISERROR('Driver Name (%s) not found in TotalMail', 16, 1, @sDriverName)
					RETURN
					END
		
			END
		else if @sDispatchSystemID > ''
			BEGIN
				SELECT @lDriverSN = SN 
				FROM tblDrivers (NOLOCK)
				WHERE DispSysDriverID = @sDispatchSystemID
				
				IF ISNULL(@lDriverSN, 0) = 0
					BEGIN
					RAISERROR('Driver Name not specified and Dispatch System ID (%s) not found in TotalMail', 16, 1, @sDispatchSystemID)
					RETURN
					END
			END
		else
			BEGIN
			RAISERROR('Driver Name or Dispatch System ID must be specified', 16, 1)
			RETURN
			END
	END
else
	IF NOT EXISTS(SELECT * FROM tblDrivers WHERE SN = @lDriverSN)
		BEGIN
		RAISERROR('Driver SN (%d) not found in TotalMail', 16, 1, @lDriverSN)
		RETURN
		END

--Get basic information
SELECT @sDriverName = Name, 
	   @sDispatchSystemID = DispSysDriverID
	FROM tblDrivers (NOLOCK)
	WHERE SN = @lDriverSN

--Find the SN of the main record for this resource in tblFolders
SELECT @lFolderSN = Parent
	FROM tblFolders (NOLOCK)
    WHERE SN = (SELECT Inbox FROM tblDrivers WHERE SN = @lDriverSN)

IF ISNULL(@lFolderSN, 0) = 0
	BEGIN
	RAISERROR('Error in retrieving main folder for resource SN (%d)', 16, 1, @lDriverSN)
	RETURN
	END

BEGIN TRAN
--Delete all messages & folders for this Driver
EXEC tm_KillFolder @lFolderSN, 0

--get the delete history setting, if null use 0 for No
SELECT @lDeleteHistory = ISNULL(CONVERT(int, @sDeleteHistory), 0)

EXEC tm_DeleteHistoryForResource @lDriverSN, 'Driver', @lDeleteHistory

--Get the Driver Address Type
SELECT @iDriverAddressType = tblAddressTypes.SN 
	FROM tblAddressTypes  (NOLOCK)
	WHERE tblAddressTypes.AddressType = 'D'

SELECT @lAddressesSN = adr.SN
FROM tblAddresses adr(NOLOCK),
	tblDrivers drv(NOLOCK)
WHERE adr.AddressType = @iDriverAddressType
	AND adr.AddressName = @sDriverName
	AND drv.SN = @lDriverSN
	AND adr.InBox = drv.InBox
	AND adr.OutBox = drv.OutBox

IF @lAddressesSN > 0
	BEGIN
        DELETE
        FROM tblAddressbook
        WHERE DefaultAddress = @lAddressesSN

        DELETE
        FROM tblAddresses
        WHERE SN = @lAddressesSN
	END

--Remove Truck as CurrentDriver in tblTrucks
UPDATE tblTrucks
	SET DefaultDriver = Null
	WHERE DefaultDriver = @lDriverSN

--get the delete cab unit setting, if null use 0 for No
SELECT @lDeleteCabUnit = ISNULL(CONVERT(int, @sDeleteCabUnit), 0)

IF @lDeleteCabUnit = 1
	BEGIN
		SELECT @lCabUnitSN = MIN(SN)
			FROM tblCabUnits (NOLOCK)
		    WHERE LinkedObjSN = @lDriverSN AND LinkedAddrType = @iDriverAddressType

		WHILE ISNULL(@lCabUnitSN, 0) > 0
			BEGIN
				SELECT @sUnitType = m.MobileCommType
					FROM tblCabUnits c (NOLOCK)
					INNER JOIN tblMobileCommType m (NOLOCK) ON c.Type = m.SN
					WHERE c.SN =  @lCabUnitSN

				EXEC tm_DeleteMCUnit NULL, @lCabUnitSN, @sUnitType

				SELECT @lCabUnitSN = MIN(SN)
					FROM tblCabUnits (NOLOCK)
				    WHERE LinkedObjSN = @lDriverSN AND LinkedAddrType = @iDriverAddressType AND SN > @lCabUnitSN  --greater than added in case Cab Unit could not be deleted

			END
	END
else
	UPDATE tblCabUnits
    	SET Truck = Null, LinkedObjSN = Null
		WHERE LinkedObjSN = @lDriverSN AND LinkedAddrType = @iDriverAddressType

--get the Driver Master Folder ID
exec dbo.tm_GetMasterFolderIDs 0, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out

--remove the Driver Master if all Drivers are deleted
IF (SELECT COUNT(*) FROM tblDrivers (NOLOCK))= 0 
	DELETE FROM tblFolders WHERE SN = @iDrvMaster

Select @SndResInfo = isnull(Text,0)
From TblRS (NOLOCK)
Where Keycode = 'SndResInfo'

if @SndResInfo = 1 
	Exec tm_TriggerResourceMessage @lDriverSN,'Drv',4,''	--PTS 40978

--Clean up the resource record
DELETE
	FROM tblDrivers
	WHERE SN = @lDriverSN
COMMIT TRAN
GO
GRANT EXECUTE ON  [dbo].[tm_DeleteDriver] TO [public]
GO
