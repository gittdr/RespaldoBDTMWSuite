SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[tm_DeleteMCUnit] @sMCUnitID varchar(50) = NULL, 
									 @sMCUnitSN varchar(12) = NULL,
									 @sUnitType varchar(20)
AS

--//  @sMCUnitID				- MC Unit ID to delete (Optional if SN is supplied)
--//  @sMCUnitSN				- MC SN to delete (Optional if ID is supplied)
--//  @sUnitType				- TotalMail Unit Type of MC ID to delete, see MobileCommType in tblMobileCommType

SET NOCOUNT ON

DECLARE @iMCUnitSN int,
		@iUnitTypeSN int,
		@TruckAddressType int,
		@lFolderSN int,
		@iMCUnitAddressType int,
		@lAddressesSN int,
		@iDrvMaster int,
		@TrkMaster int,
		@iMCMaster int,
		@iLgnMaster int,
		@SndResInfo int --PTS #40978

SELECT @sMCUnitID = ISNULL(@sMCUnitID, '')
SELECT @iMCUnitSN = ISNULL(CONVERT(int, @sMCUnitSN), 0)

IF ISNULL(@sUnitType, '') = ''
	BEGIN
	RAISERROR ('Unit Type must be passed in for MC Unit records.', 16, 1)
	RETURN
	END

SELECT @iUnitTypeSN = SN 
FROM tblMobileCommType (NOLOCK)
WHERE MobileCommType = @sUnitType

IF ISNULL(@iUnitTypeSN, 0) = 0
	BEGIN
	RAISERROR ('MC Unit Type (%s) not found.', 16, 1, @sUnitType)
	RETURN
	END

SELECT @TruckAddressType = tblAddressTypes.SN 
FROM tblAddressTypes (NOLOCK)
WHERE tblAddressTypes.AddressType = 'T'

IF @iMCUnitSN = 0
	BEGIN
		IF @sMCUnitID = ''
			BEGIN
			RAISERROR('Mobile Communication Unit ID must be specified', 16, 1)
			RETURN
			END
		
		--find the record for the MC Unit ID
		SELECT @iMCUnitSN = SN 
			FROM tblCabUnits (NOLOCK) 
			WHERE UnitID = @sMCUnitID AND LinkedAddrType = @TruckAddressType AND Type = @iUnitTypeSN
		
		IF ISNULL(@iMCUnitSN, 0) = 0
			BEGIN
			RAISERROR('Mobile Communication Unit ID (%s) not found in TotalMail', 16, 1, @sMCUnitID)
			RETURN
			END

	END
else
	IF NOT EXISTS(SELECT * 
					FROM tblCabUnits (NOLOCK)
					WHERE SN = @iMCUnitSN)
		BEGIN
		RAISERROR('Mobile Communication SN (%d) not found in TotalMail', 16, 1, @iMCUnitSN)
		RETURN
		END

--Get basic information
SELECT @sMCUnitID = UnitID
	FROM tblCabUnits (NOLOCK)
	WHERE SN = @iMCUnitSN

--Find this MCT's inbox
SELECT @lFolderSN = Inbox
	FROM tblCabUnits (NOLOCK)
	WHERE SN = @iMCUnitSN

IF ISNULL(@lFolderSN, 0) = 0
	BEGIN
	RAISERROR('Error in retrieving main folder for Mobile Communication SN. (%d)', 16, 1, @iMCUnitSN)
	RETURN
	END

--Find the SN of the main record for this MCT in tblFolders
SELECT @lFolderSN = SN
	FROM tblFolders (NOLOCK)
	WHERE SN = (SELECT Parent FROM tblFolders WHERE SN = @lFolderSN)

IF ISNULL(@lFolderSN, 0) = 0
	BEGIN
	RAISERROR('Error in retrieving main folder for Mobile Communication SN (2). (%d)', 16, 1, @iMCUnitSN)
	RETURN
	END

BEGIN TRAN
--Delete all messages & folders for this CabUnit
EXEC tm_KillFolder @lFolderSN, 0

--Get the CabUnit Address Type
SELECT @iMCUnitAddressType = tblAddressTypes.SN 
	FROM tblAddressTypes (NOLOCK)
	WHERE tblAddressTypes.AddressType = 'C'

SELECT @lAddressesSN = adr.SN
FROM tblAddresses adr(NOLOCK),
	tblCabUnits unt(NOLOCK)
WHERE AddressType = @iMCUnitAddressType
	AND AddressName = @sMCUnitID
	AND unt.SN = @iMCUnitSN
	AND adr.InBox = unt.InBox
	AND adr.OutBox = unt.OutBox

IF @lAddressesSN > 0
	BEGIN
        DELETE
        FROM tblAddressbook
        WHERE DefaultAddress = @lAddressesSN

        DELETE
        FROM tblAddresses
        WHERE SN = @lAddressesSN
	END

--Remove MCT as DefaultCabUnit in tblTrucks
UPDATE tblTrucks
	SET DefaultCabUnit = Null
	WHERE DefaultCabUnit = @iMCUnitSN

--Delete any entries for this unit in tblLatLongs
DELETE
	FROM tblLatLongs
	WHERE Unit = @iMCUnitSN

--Delete all entries for this CabUnit from tblCabUnit Groups
DELETE 
	FROM tblCabUnitGroups
	WHERE MemberCabSN = @iMCUnitSN

--get the Truck Master Folder ID
exec dbo.tm_GetMasterFolderIDs 0, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out

--remove the Truck Master if all CabUnits are deleted
IF (SELECT COUNT(*) FROM tblCabUnits (NOLOCK))= 0 
	DELETE FROM tblFolders WHERE SN = @iMCMaster

Select @SndResInfo = isnull(Text,0) 
From TblRS (NOLOCK) 
Where Keycode = 'SndResInfo'

if @SndResInfo = 1 
	Exec tm_TriggerResourceMessage @iMCUnitSN,'Mcu',4,''	--PTS 40978

--Clean up the resource record
DELETE
	FROM tblCabUnits
	WHERE SN = @iMCUnitSN
COMMIT TRAN
GO
GRANT EXECUTE ON  [dbo].[tm_DeleteMCUnit] TO [public]
GO
