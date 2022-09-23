SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[tm_DeleteTruck] 	@sTruckName varchar(15) = NULL, 
										@sTruckSN varchar(12) = NULL,
										@sDispatchSystemID varchar(20) = NULL, 
										@sDeleteHistory varchar(1) = NULL,
										@sDeleteCabUnit varchar(1) = NULL

AS

--//  @sTruckName				- TotalMail Truck Name to delete (Optional if SN or Dispatch ID supplied)
--//  @sTruckSN					- Truck SN to delete (Optional if Name or Dispatch ID supplied)
--//  @sDispatchSystemID		- Dispatch System ID for Trailer to delete (Optional if Name or SN supplied). 
--//  @sDeleteHistory     		- Delete history messages for Truck
--//        0 or No, 1 for Yes. 
--//        NULL means keep history messages
--//
--//  @sDeleteCabUnit     - Delete cab unit for Truck
--//        0 or No, 1 for Yes. 
--//        NULL means keep cab unit
--//

SET NOCOUNT ON

DECLARE @lTruckSN int, 
		@lDeleteHistory int,
		@lDeleteCabUnit int,
		@lFolderSN int,
		@iTruckAddressType int,
		@lAddressesSN int,
		@lCabUnitSN int,
		@sUnitType varchar(20),
		@iDrvMaster int,
		@TrkMaster int,
		@iMCMaster int,
		@iLgnMaster int,
		@SndResInfo int --PTS #40978
	
SELECT @sTruckName = ISNULL(@sTruckName, '')
SELECT @sDispatchSystemID = ISNULL(@sDispatchSystemID, '')
SELECT @lTruckSN = ISNULL(CONVERT(int, @sTruckSN), 0)

IF @lTruckSN = 0
	BEGIN
		IF @sTruckName > ''
			BEGIN
				SELECT @lTruckSN = SN 
				FROM tblTrucks (NOLOCK) 
				WHERE TruckName = @sTruckName
				
				IF ISNULL(@lTruckSN, 0) = 0
					BEGIN
					RAISERROR('Truck Name (%s) not found in TotalMail', 16, 1, @sTruckName)
					RETURN
					END
		
			END
		else if @sDispatchSystemID > ''
			BEGIN
				SELECT @lTruckSN = SN 
				FROM tblTrucks (NOLOCK)
				WHERE DispSysTruckID = @sDispatchSystemID
				
				IF ISNULL(@lTruckSN, 0) = 0
					BEGIN
					RAISERROR('Truck Name not specified and Dispatch System ID (%s) not found in TotalMail', 16, 1, @sDispatchSystemID)
					RETURN
					END
			END
		else
			BEGIN
			RAISERROR('Truck Name or Dispatch System ID must be specified', 16, 1)
			RETURN
			END
	END
else
	IF NOT EXISTS(SELECT * 
					FROM tblTrucks (NOLOCK)
					WHERE SN = @lTruckSN)
		BEGIN
		RAISERROR('Truck SN (%d) not found in TotalMail', 16, 1, @lTruckSN)
		RETURN
		END

--Get basic information
SELECT @sTruckName = TruckName, 
	   @sDispatchSystemID = DispSysTruckID
	FROM tblTrucks (NOLOCK)
	WHERE SN = @lTruckSN

--Find the SN of the main record for this resource in tblFolders
SELECT @lFolderSN = Parent
	FROM tblFolders (NOLOCK)
    WHERE SN = (SELECT Inbox FROM tblTrucks WHERE SN = @lTruckSN)

IF ISNULL(@lFolderSN, 0) = 0
	BEGIN
	RAISERROR('Error in retrieving main folder for resource SN (%d)', 16, 1, @lTruckSN)
	RETURN
	END

BEGIN TRAN
--Delete all messages & folders for this Truck/Trailer
EXEC tm_KillFolder @lFolderSN, 0

--get the delete history setting, if null use 0 for No
SELECT @lDeleteHistory = ISNULL(CONVERT(int, @sDeleteHistory), 0)

EXEC tm_DeleteHistoryForResource @lTruckSN, 'Truck', @lDeleteHistory

--Get the Truck Address Type
SELECT @iTruckAddressType = tblAddressTypes.SN 
	FROM tblAddressTypes (NOLOCK)
	WHERE tblAddressTypes.AddressType = 'T'

SELECT @lAddressesSN = adr.SN
FROM tblAddresses adr(NOLOCK),
	tblTrucks trc(NOLOCK)
WHERE AddressType = @iTruckAddressType
	AND AddressName = @sTruckName
	AND trc.SN = @lTruckSN
	AND adr.InBox = trc.InBox
	AND adr.OutBox = trc.OutBox
  
IF @lAddressesSN > 0
	BEGIN
        DELETE
        FROM tblAddressbook
        WHERE DefaultAddress = @lAddressesSN

        DELETE
        FROM tblAddresses
        WHERE SN = @lAddressesSN
	END

--Remove truck as CurrentTruck in tblDrivers
UPDATE tblDrivers
	SET CurrentTruck = Null
	WHERE CurrentTruck = @lTruckSN

--get the delete cab unit setting, if null use 0 for No
SELECT @lDeleteCabUnit = ISNULL(CONVERT(int, @sDeleteCabUnit), 0)

IF @lDeleteCabUnit = 1
	BEGIN
		SELECT @lCabUnitSN = MIN(SN)
			FROM tblCabUnits (nolock)
		    WHERE Truck = @lTruckSN AND LinkedAddrType =  @iTruckAddressType

		WHILE ISNULL(@lCabUnitSN, 0) > 0
			BEGIN
				SELECT @sUnitType = m.MobileCommType
					FROM tblCabUnits c (NOLOCK)
					INNER JOIN tblMobileCommType m (NOLOCK) ON c.Type = m.SN
					WHERE c.SN =  @lCabUnitSN

				EXEC tm_DeleteMCUnit NULL, @lCabUnitSN, @sUnitType

				SELECT @lCabUnitSN = MIN(SN)
					FROM tblCabUnits (NOLOCK)
				    WHERE Truck = @lTruckSN AND LinkedAddrType = @iTruckAddressType AND SN > @lCabUnitSN  --greater than added in case Cab Unit could not be deleted

			END
	END
else
	UPDATE tblCabUnits
    	SET Truck = Null, LinkedObjSN = Null
		WHERE Truck = @lTruckSN AND LinkedAddrType =  @iTruckAddressType

--get the Truck Master Folder ID
exec dbo.tm_GetMasterFolderIDs 0, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out

--remove the Truck Master if all Trucks are deleted
IF (SELECT COUNT(*) FROM tblTrucks (NOLOCK))= 0 
	DELETE FROM tblFolders WHERE SN = @TrkMaster

--Start PTS 40978
Select @SndResInfo = isnull(Text,0) 
From TblRS (NOLOCK)
Where Keycode = 'SndResInfo'

if @SndResInfo = 1 
	Begin
		if SubString(@sDispatchSystemID,1,4) = 'Trl:'
			Exec tm_TriggerResourceMessage @lTruckSN,'Trl',4,''	
		Else
			Exec tm_TriggerResourceMessage @lTruckSN,'Trc',4,''	
End
--End PTS 40978

--Clean up the resource record
DELETE
	FROM tblTrucks
	WHERE SN = @lTruckSN
COMMIT TRAN
GO
GRANT EXECUTE ON  [dbo].[tm_DeleteTruck] TO [public]
GO
