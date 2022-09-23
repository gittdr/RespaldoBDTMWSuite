SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[tm_DeleteLogin] 	@sLoginName varchar(50) = NULL, 
										@sLoginSN varchar(12) = NULL
AS

--//  @sLoginName				- TotalMail Login Name to delete (Optional if SN supplied)
--//  @sLoginSN					- Login SN to delete (Optional if Name supplied)

SET NOCOUNT ON 

DECLARE @lLoginSN int, 
		@lFolderSN int,
		@iLoginAddressType int,
		@lAddressesSN int,
		@iDrvMaster int,
		@TrkMaster int,
		@iMCMaster int,
		@iLgnMaster int,
		@SndResInfo int --PTS #40978
	
SELECT @sLoginName = ISNULL(@sLoginName, '')
SELECT @lLoginSN = ISNULL(CONVERT(int, @sLoginSN), 0)

IF @lLoginSN = 0
	BEGIN
		IF @sLoginName > ''
			BEGIN
				SELECT @lLoginSN = SN 
				FROM tblLogin (NOLOCK)
				WHERE LoginName = @sLoginName
				
				IF ISNULL(@lLoginSN, 0) = 0
					BEGIN
					RAISERROR('Login Name (%s) not found in TotalMail', 16, 1, @sLoginName)
					RETURN
					END
		
			END
		else
			BEGIN
			RAISERROR('Login Name or SN must be specified', 16, 1)
			RETURN
			END
	END
else
	IF NOT EXISTS(SELECT * 
					FROM tblLogin (NOLOCK)
					WHERE SN = @lLoginSN)
		BEGIN
		RAISERROR('Login SN (%d) not found in TotalMail', 16, 1, @lLoginSN)
		RETURN
		END

--Get basic information
SELECT @sLoginName = LoginName
	FROM tblLogin (NOLOCK)
	WHERE SN = @lLoginSN

--Find the SN of the main record for this resource in tblFolders
SELECT @lFolderSN = Parent
	FROM tblFolders (NOLOCK)
    WHERE SN = (SELECT Inbox FROM tblLogin (NOLOCK)  WHERE SN = @lLoginSN)

IF ISNULL(@lFolderSN, 0) = 0
	BEGIN
	RAISERROR('Error in retrieving main folder for resource SN (%d)', 16, 1, @lLoginSN)
	RETURN
	END

BEGIN TRAN
--Delete all messages & folders for this Login
EXEC tm_KillFolder @lFolderSN, 0

--Get the Login Address Type
SELECT @iLoginAddressType = tblAddressTypes.SN 
	FROM tblAddressTypes (NOLOCK)
	WHERE tblAddressTypes.AddressType = 'L'

SELECT @lAddressesSN = adr.SN
FROM tblAddresses adr(NOLOCK),
	tbllogin lng(NOLOCK)
WHERE AddressType = @iLoginAddressType
	AND AddressName = @sLoginName
	AND lng.SN = @lLoginSN
	AND adr.InBox = lng.InBox
	AND adr.OutBox = lng.OutBox


IF @lAddressesSN > 0
	BEGIN
        DELETE
        FROM tblAddressbook
        WHERE DefaultAddress = @lAddressesSN

        DELETE
        FROM tblAddresses
        WHERE SN = @lAddressesSN
	END

--Clean up Filters
DELETE tblFilterElement 
	FROM tblFilterElement
	JOIN tblFilters ON tblFilterElement.flt_SN = tblFilters.flt_SN
	WHERE tblFilters.flt_LoginID = @sLoginName

--get the Login Master Folder ID
exec dbo.tm_GetMasterFolderIDs 0, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out

--remove the Login Master if all Logins are deleted
IF (SELECT COUNT(*) FROM tblLogin (NOLOCK))= 0 
	DELETE FROM tblFolders WHERE SN = @iLgnMaster

--Clean up tblDispatchLogins
DELETE
	FROM tblDispatchLogins
	WHERE LoginSN = @lLoginSN

--Start PTS 40978
Select @SndResInfo = isnull(Text,0) 
From TblRS (NOLOCK)
Where Keycode = 'SndResInfo'

if @SndResInfo = 1 
	Exec tm_TriggerResourceMessage @lLoginSN,'Lgn',4,''	
--End PTS 40978
--Clean up the resource record
DELETE
	FROM tblLogin 
	WHERE SN = @lLoginSN
COMMIT TRAN
GO
GRANT EXECUTE ON  [dbo].[tm_DeleteLogin] TO [public]
GO
