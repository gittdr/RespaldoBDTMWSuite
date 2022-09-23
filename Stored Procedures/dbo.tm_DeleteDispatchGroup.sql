SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_DeleteDispatchGroup] 	@sDispatchGroupName varchar(30) = NULL, 
												@sDispatchGroupSN varchar(12) = NULL

AS

SET NOCOUNT ON
--//  @sDispatchGroupName			- TotalMail Dispatch Group Name to delete (Optional if SN supplied)
--//  @sDispatchGroupSN				- Dispatch Group SN to delete (Optional if Name supplied)
--//  @sDeleteHistory     			- Delete history messages for Dispatch Group
--//        0 or No, 1 for Yes. 
--//        NULL means keep history messages
--//

DECLARE @lDispatchGroupSN int, 
		@lFolderSN int,
		@iDispGroupAddressType int,
		@lAddressesSN int
	
SELECT @sDispatchGroupName = ISNULL(@sDispatchGroupName, '')
SELECT @lDispatchGroupSN = ISNULL(CONVERT(int, @sDispatchGroupSN), 0)

IF @lDispatchGroupSN = 0
	BEGIN
		IF @sDispatchGroupName > ''
			BEGIN
				SELECT @lDispatchGroupSN = SN FROM tblDispatchGroup WHERE Name = @sDispatchGroupName
				
				IF ISNULL(@lDispatchGroupSN, 0) = 0
					BEGIN
					RAISERROR('Dispatch Group Name (%s) not found in TotalMail', 16, 1, @sDispatchGroupName)
					RETURN
					END
		
			END
		else
			BEGIN
			RAISERROR('Dispatch Group Name or Dispatch Group SN must be specified', 16, 1)
			RETURN
			END
	END
else
	IF NOT EXISTS(SELECT * FROM tblDispatchGroup WHERE SN = @lDispatchGroupSN)
		BEGIN
		RAISERROR('Dispatch Group SN (%d) not found in TotalMail', 16, 1, @lDispatchGroupSN)
		RETURN
		END

--Get basic information and the find the SN of the main record for this resource
SELECT @sDispatchGroupName = Name,
	   @lFolderSN = Inbox
	FROM tblDispatchGroup
	WHERE SN = @lDispatchGroupSN

IF ISNULL(@lFolderSN, 0) = 0
	BEGIN
	RAISERROR('Error in retrieving main folder for resource SN (%d)', 16, 1, @lDispatchGroupSN)
	RETURN
	END

BEGIN TRAN
--Delete all messages & folders for this Dispatch Group
EXEC tm_KillFolder @lFolderSN, 0

--Get the Dispatch Group Address Type
SELECT @iDispGroupAddressType = tblAddressTypes.SN 
	FROM tblAddressTypes  (NOLOCK)
	WHERE tblAddressTypes.AddressType = 'G'

SELECT @lAddressesSN = adr.SN
FROM tblAddresses adr(NOLOCK),
	tblDispatchGroup dip(NOLOCK)
WHERE AddressType = @iDispGroupAddressType
	AND AddressName = @sDispatchGroupName
	AND dip.SN = @lDispatchGroupSN
	AND adr.InBox = dip.InBox
  
IF @lAddressesSN > 0
	BEGIN
        DELETE
        FROM tblAddressbook
        WHERE DefaultAddress = @lAddressesSN

        DELETE
        FROM tblAddresses
        WHERE SN = @lAddressesSN
	END

--Remove Dispatch Group as CurrentDispatcher in tblDrivers
UPDATE tblDrivers
	SET CurrentDispatcher = Null
	WHERE CurrentDispatcher = @lDispatchGroupSN

--Remove Dispatch Group as CurrentDispatcher in tblTrucks
UPDATE tblTrucks
	SET CurrentDispatcher = Null
	WHERE CurrentDispatcher = @lDispatchGroupSN

--Remove Dispatch Group as CurrentDispatcher in tblCabUnits
UPDATE tblCabUnits
	SET CurrentDispatcher = Null
	WHERE CurrentDispatcher = @lDispatchGroupSN

--Remove Logins from Dispatch Group
DELETE
	FROM tblDispatchLogins
	WHERE DispatchGroupSN = @lDispatchGroupSN

--Clean up the resource record
DELETE
	FROM tblDispatchGroup
	WHERE SN = @lDispatchGroupSN
COMMIT TRAN
GO
GRANT EXECUTE ON  [dbo].[tm_DeleteDispatchGroup] TO [public]
GO
