SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_DeleteGroupDefinition] 	@sGroupDefName varchar(15) = NULL, 
												@sGroupDefSN varchar(12) = NULL,
												@sDeleteHistory varchar(1) = NULL

AS

--//  @sGroupDefName			- TotalMail Group Def Name to delete (Optional if SN supplied)
--//  @sGroupDefSN				- Group Def SN to delete (Optional if Name supplied)
--//  @sDeleteHistory     		- Delete history messages for Group Def
--//        0 or No, 1 for Yes. 
--//        NULL means keep history messages
--//


SET NOCOUNT ON

DECLARE @lGroupDefSN int, 
		@lDeleteHistory int,
		@lFolderSN int,
		@iTruckAddressType int,
		@lCabUnitSN int,
		@sUnitType varchar(20),
		@sUnitID varchar(50),
		@lGroupFlag int,
		@lAddressesSN int,
		@lCabUnitAddressType int,
		@iDrvMaster int,
		@TrkMaster int,
		@iMCMaster int,
		@iLgnMaster int
	
SELECT @sGroupDefName = ISNULL(@sGroupDefName, '')
SELECT @lGroupDefSN = ISNULL(CONVERT(int, @sGroupDefSN), 0)

IF @lGroupDefSN = 0
	BEGIN
		IF @sGroupDefName > ''
			BEGIN
				SELECT @lGroupDefSN = SN 
				FROM tblTrucks (NOLOCK) 
				WHERE TruckName = @sGroupDefName AND GroupFlag <> 0
				
				IF ISNULL(@lGroupDefSN, 0) = 0
					BEGIN
					RAISERROR('Group Definition Name (%s) not found in TotalMail', 16, 1, @sGroupDefName)
					RETURN
					END
		
			END
		else
			BEGIN
			RAISERROR('Group Definition Name or SN must be specified', 16, 1)
			RETURN
			END
	END
else
	IF NOT EXISTS(SELECT * FROM tblTrucks WHERE SN = @lGroupDefSN)
		BEGIN
		RAISERROR('Group Definition SN (%d) not found in TotalMail', 16, 1, @lGroupDefSN)
		RETURN
		END

--Get basic information
SELECT @sGroupDefName = TruckName,
	   @lGroupFlag = GroupFlag
	FROM tblTrucks (NOLOCK)
	WHERE SN = @lGroupDefSN

if ISNULL(@lGroupFlag, -1) <> 2 --Non mobile Comm group
	BEGIN
	RAISERROR('Fleet and Mobile Group Definitions can not be deleted', 16, 1)
	RETURN
	END

--Find the SN of the main record for this resource in tblFolders
SELECT @lFolderSN = Parent
	FROM tblFolders (NOLOCK)
    WHERE SN = (SELECT Inbox FROM tblTrucks WHERE SN = @lGroupDefSN)

IF ISNULL(@lFolderSN, 0) = 0
	BEGIN
	RAISERROR('Error in retrieving main folder for resource SN (%d)', 16, 1, @lGroupDefSN)
	RETURN
	END

BEGIN TRAN
--Delete all messages & folders for this Group Def
EXEC tm_KillFolder @lFolderSN, 0

--get the delete history setting, if null use 0 for No
SELECT @lDeleteHistory = ISNULL(CONVERT(int, @sDeleteHistory), 0)

EXEC tm_DeleteHistoryForResource @lGroupDefSN, 'Truck', @lDeleteHistory

--Get the Group Def (Truck) Address Type
SELECT @iTruckAddressType = tblAddressTypes.SN 
	FROM tblAddressTypes (NOLOCK)
	WHERE tblAddressTypes.AddressType = 'T'

SELECT @lAddressesSN = adr.SN
FROM tblAddresses adr(NOLOCK),
	tblTrucks grp(NOLOCK)
WHERE AddressType = @iTruckAddressType
	AND AddressName = @sGroupDefName
	AND grp.SN = @lGroupDefSN
	AND adr.InBox = grp.InBox
	AND adr.OutBox = grp.OutBox
  
IF @lAddressesSN > 0
	BEGIN
        DELETE
        FROM tblAddressbook
        WHERE DefaultAddress = @lAddressesSN

        DELETE
        FROM tblAddresses
        WHERE SN = @lAddressesSN
	END

-- Need to find the SN in tblAddresses, so first find the SN in tblAddressTypes
SELECT @lCabUnitAddressType = tblAddressTypes.SN 
	FROM tblAddressTypes (NOLOCK)
	WHERE tblAddressTypes.AddressType = 'C'

--Walk through each cabunit attached to this Group def and unattach them
SELECT @lCabUnitSN = MIN(SN)
	FROM tblCabUnits (NOLOCK)
	WHERE ISNULL(LinkedObjSN, Truck) = @lGroupDefSN
		AND ISNULL(LinkedAddrType, @iTruckAddressType) = @iTruckAddressType

WHILE ISNULL(@lCabUnitSN, 0) > 0
BEGIN
	SELECT @sUnitID = UnitID
		FROM tblCabUnits (NOLOCK)
		WHERE SN = @lCabUnitSN
	
	DELETE tblCabUnitGroups
		WHERE GroupCabSN = @lCabUnitSN

	DELETE FROM tblCabUnits
		WHERE SN = @lCabUnitSN

	SELECT @lAddressesSN = SN
		FROM tblAddresses (NOLOCK)
		WHERE AddressType = @lCabUnitAddressType AND AddressName = @sUnitID
	
	IF @lAddressesSN > 0
		BEGIN
	        DELETE
	        FROM tblAddressbook 
	        WHERE DefaultAddress = @lAddressesSN
	
	        DELETE
	        FROM tblAddresses
	        WHERE SN = @lAddressesSN
		END

	SELECT @lCabUnitSN = MIN(SN)
		FROM tblCabUnits (NOLOCK)
		WHERE ISNULL(LinkedObjSN, Truck) = @lGroupDefSN
			AND ISNULL(LinkedAddrType, @iTruckAddressType) = @iTruckAddressType 
			AND SN > @lCabUnitSN  --SN > @lCabUnitSN is not needed because we are deleting the records, but we do not want to possibly loop, so...

END

--Delete Group Def Cab Unit
SELECT @lCabUnitSN = MIN(SN)
	FROM tblCabUnits (NOLOCK)
    WHERE Truck = @lGroupDefSN AND LinkedAddrType =  @iTruckAddressType

WHILE ISNULL(@lCabUnitSN, 0) > 0
	BEGIN
		SELECT @sUnitType = m.MobileCommType
			FROM tblCabUnits c (NOLOCK)
			INNER JOIN tblMobileCommType m (NOLOCK) ON c.Type = m.SN
			WHERE c.SN =  @lCabUnitSN

		EXEC tm_DeleteMCUnit NULL, @lCabUnitSN, @sUnitType

		SELECT @lCabUnitSN = MIN(SN)
			FROM tblCabUnits (NOLOCK)
		    WHERE Truck = @lGroupDefSN AND LinkedAddrType = @iTruckAddressType AND SN > @lCabUnitSN  --greater than added in case Cab Unit could not be deleted

	END

--get the Truck Master Folder ID
exec dbo.tm_GetMasterFolderIDs 0, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out

--remove the Truck Master if all Trucks are deleted
IF (SELECT COUNT(*) FROM tblTrucks (NOLOCK))= 0 
	DELETE FROM tblFolders WHERE SN = @TrkMaster

--Clean up the resource record
DELETE
	FROM tblTrucks
	WHERE SN = @lGroupDefSN
COMMIT TRAN
GO
GRANT EXECUTE ON  [dbo].[tm_DeleteGroupDefinition] TO [public]
GO
