SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE Procedure [dbo].[tm_ConfigLogin] @sNewName varchar(50),
				@sOldName varchar(50),
				@sCopyPermFrom varchar(50),
				@iUseToResolve int

AS

--//  @sNewName					- Login to Add or new name for a Login already existing
--//  @sOldname					- Login name to update to new name (@NewName). 
--//						  All Filters will be copied from oldname to newname
--//  @sCopyPermFrom				- Copies the <ADMIN> filter and DispatchGroups from this login
--//  @iUseToResolve				- Should the login be used in auto resolution
--//						  0 or No, 1 for Yes. If a new login. NULL is No. 
--//						  If exsiting login, NULL means keep current setting

SET NOCOUNT ON 

DECLARE @iOldSN int,
	@iLoginSNToUse int,
        @iNewLoginSN int,
	@iParentSN int,
	@iOutBoxSN int,
	@iInBoxSN int,
	@iSentSN int,
	@iDeletedSN int,
	@iDrvMaster int ,
	@iTrkMaster int ,
	@iMCMaster int ,
	@iLgnMaster int,
	@iLoginAddressType int,
	@iOldAddressSN int,
	@iUpdateLoginFlag int,
	@iFilterSN int,
	@iCopyFromFilterSN int,
	@iCopyFromLoginSN int,
	@sT_1 varchar(200),
	--Start PTS #40978
	@SndResInfo int, 
	@Flags int,
	@LoginSN int
	--End PTS #40978

	Select @SndResInfo = isnull(Text,0) From TblRS Where Keycode = 'SndResInfo'--PTS #40978
------------------ Check Parameters --------------------------

	SELECT @sNewName = ISNULL(@sNewName, '')
	SELECT @sOldName = ISNULL(@sOldName, '')
	SELECT @sCopyPermFrom = ISNULL(@sCopyPermFrom, '')

	--Do not process ADMIN logins
	IF UPPER(@sNewName) = 'ADMIN' OR UPPER(@sOldName) = 'ADMIN' OR UPPER(@sCopyPermFrom) = 'ADMIN'
		BEGIN
		SELECT @sT_1 = 'ADMIN is not allowed in New (%s), old (%s) or CopyPermFrom (%s) names'
		EXEC dbo.tm_t_sp @sT_1 out, 0, ''
		RAISERROR (@sT_1, 16, 1, @sNewName, @sOldName, @sCopyPermFrom)
		RETURN
		END

	--Do not allow names to match
	IF UPPER(@sNewName) = UPPER(@sOldName) 
		SELECT @sOldName = ''

	--Do not allow names to match
	IF UPPER(@sNewName) = UPPER(@sCopyPermFrom) 
		BEGIN
		SELECT @sT_1 = 'New (%s) and Copy Permission From (%s) may not be the same. Leave Copy Permission From name blank to keep admin filter'
		EXEC dbo.tm_t_sp @sT_1 out, 0, ''
		RAISERROR (@sT_1, 16, 1, @sNewName, @sCopyPermFrom)
		RETURN
		END

	--Do not allow names to match **** What if they are both blank.
	IF ISNULL(@sCopyPermFrom, '') <> ''    --Don't really need the ISNULL because we convert at the top of this procedure.
		IF UPPER(@sOldName) = UPPER(@sCopyPermFrom) 
			BEGIN
			SELECT @sT_1 = 'Old (%s) and Copy Permission From (%s) may not be the same. Leave Copy Permission From name blank to copy old admin filter'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''
			RAISERROR (@sT_1, 16, 1, @sOldName, @sCopyPermFrom)
			RETURN
			END

	--make sure we have a NewName, should always have one
	if ISNULL(@sNewName, '') > ''
		BEGIN
		
		--see if we can find the Oldname if we have one
		if ISNULL(@sOldName, '') > ''
			BEGIN
			SELECT @iOldSN = sN 
			FROM tblLogin (NOLOCK) 
			WHERE LoginName = @sOldName
			
			--Could not find the OldName, can not update, Goodbye
			IF ISNULL(@iOldSN, 0) = 0
				BEGIN
				SELECT @sT_1 = 'Old name (%s) not found for copy.'
				EXEC dbo.tm_t_sp @sT_1 out, 0, ''
				RAISERROR (@sT_1, 16, 1, @sOldName)
				RETURN
				END

			--make sure the new name does not already exist
			IF EXISTS (SELECT * From tblLogin (NOLOCK) WHERE LoginName = @sNewName)
				BEGIN
				SELECT @sT_1 = 'Both old name (%s) and new name (%s) already exist.'
				EXEC dbo.tm_t_sp @sT_1 out, 0, ''
				RAISERROR (@sT_1, 16, 1, @sOldName, @sNewName) 
				RETURN
				END
			END
		
		IF ISNULL(@sCopyPermFrom, '') > ''
			BEGIN
			--Make sure that the Copy Permission From login does exist
			IF NOT EXISTS (SELECT * From tblLogin (NOLOCK)WHERE LoginName = @sCopyPermFrom)
				BEGIN
				SELECT @sT_1 = 'Copy Permission From name (%s) does not exist.'
				EXEC dbo.tm_t_sp @sT_1 out, 0, ''
				RAISERROR (@sT_1, 16, 1, @sCopyPermFrom) 
				RETURN
				END
			END

		END

	--No NewName, Goodbye
	ELSE
		BEGIN
		SELECT @sT_1 = 'No new name to create specified.'
		EXEC dbo.tm_t_sp @sT_1 out, 0, ''
		RAISERROR (@sT_1, 16, 1, @sNewName)
		RETURN
		END
	
	SELECT @iUpdateLoginFlag = 0

------------------ Login record --------------------------

	--if this is a new record, old Name not passed in
	IF ISNULL(@iOldSN, 0) = 0 

		BEGIN

		--see if we already have a record for the login Name
		SELECT @iOldSN = sN FROM tblLogin  (NOLOCK) WHERE LoginName = @sNewName 

		--Do not have a record for the login, create one
		IF ISNULL(@iOldSN, 0) = 0 
			BEGIN

			--get the Login Master Folder ID
			exec dbo.tm_GetMasterFolderIDs 0, @iDrvMaster out, @iTrkMaster out, @iMCMaster out, @iLgnMaster out
			
			--if there is no Login Master Folder ID, use root level
			IF ISNULL(@iLgnMaster, 0) = 0
				SELECT @iLgnMaster = NULL

			--Insert the new folders, first owner will be null since we do not know the Login SN yet
			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iLgnMaster, @sNewName, NULL, 0)
			Select @iParentSN = @@IDENTITY

			SELECT @sT_1 = 'InBox'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''

			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iParentSN, @sT_1, NULL, 0)
			Select @iInBoxSN = @@IDENTITY

			SELECT @sT_1 = 'OutBox'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''

			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iParentSN, @sT_1, NULL, 0)
			Select @iOutBoxSN = @@IDENTITY

			SELECT @sT_1 = 'Sent'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''

			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iParentSN, @sT_1, NULL, 0)
			Select @iSentSN = @@IDENTITY

			SELECT @sT_1 = 'Deleted'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''

			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iParentSN, @sT_1, NULL, 0)
			Select @iDeletedSN = @@IDENTITY

			--Insert Login Profile record
			INSERT INTO tblLogin 
				(LoginName, Inbox, OutBox, Sent, Deleted, TMPassword) 
				VALUES (@sNewName, @iInBoxSN, @iOutBoxSN, @iSentSN, @iDeletedSN, '')

			Select @iNewLoginSN = @@IDENTITY
			--Start PTS 40978
			Set @Flags = 1
			Set  @LoginSN =   @iNewLoginSN
			--End PTS 40978

			--update the Parent folder to the Login folder SN
			UPDATE tblFolders SET Owner = @iNewLoginSN WHERE SN = @iParentSN

			--if we were unable to create a Login Master, this is the first login, try it again and update the new record
			if ISNULL(@iLgnMaster, 0) = 0 
				exec dbo.tm_GetMasterFolderIDs 1, @iDrvMaster out, @iTrkMaster out, @iMCMaster out, @iLgnMaster out

			--update general Login SN
			SELECT @iLoginSNToUse = @iNewLoginSN

			END

		ELSE
		--we have a record for the new login name, update it
			SELECT @iUpdateLoginFlag = -1

		END

	--Update Login Name, old name passed in and found or Login record already existed
	ELSE
		SELECT @iUpdateLoginFlag = -1

	
	--if we are to update the login record
	if @iUpdateLoginFlag = -1
		BEGIN

		UPDATE tblLogin SET LoginName = @sNewName WHERE SN = @iOldSN
		--Start PTS 40978
		Set @Flags = 2
		Set  @LoginSN =  @iOldSN
		--End PTS 40978

		--get the Login Master Folder ID
		exec dbo.tm_GetMasterFolderIDs 0, @iDrvMaster out, @iTrkMaster out, @iMCMaster out, @iLgnMaster out

		--if there is no Login Master Folder ID, only use root level
		IF ISNULL(@iLgnMaster, 0) = 0
			SELECT @iLgnMaster = -1
			
		--Update tblFolders name with new name
	        UPDATE tblFolders SET Name = @sNewName WHERE (Parent IS Null or Parent = @iLgnMaster) AND Owner = @iOldSN

		--update general Login SN
		SELECT @iLoginSNToUse = @iOldSN

		END

------------------ Addresses record --------------------------

	--tblAddresses Record Insert
	IF ISNULL(@iOldSN, 0) = 0
		BEGIN

		--find the tblAddresses SN for Login type 
		SELECT @iLoginAddressType = SN FROM tblAddressTypes (NOLOCK) WHERE AddressType = 'L'
		
		--get the Resolve setting, if null use 0 for No
		SELECT @iUseToResolve = ISNULL(@iUseToResolve, 1)

		--Insert the Address record
		INSERT INTO tblAddresses 
			(AddressBookSN, AddressType, Inbox, Outbox, AddressName, UseInResolve) 
			VALUES (NULL, @iLoginAddressType, @iInBoxSN, @iOutBoxSN, @sNewName, @iUseToResolve)

		END

	--tblAddresses Record Update
	ELSE
		BEGIN
	
		--Get the Inbox SN
	        SELECT @iInBoxSN = Inbox FROM tblLogin (NOLOCK) WHERE SN = @iOldSN

		--find the old tblAddresses record
		SELECT @iOldAddressSN = SN FROM tblAddresses (NOLOCK) WHERE Inbox = @iInBoxSN

		--if a UseToResolve was not passed in keep it the same as the old one
		IF ISNULL(@iUseToResolve, -1) = -1
			SELECT @iUseToResolve = UseInResolve FROM tblAddresses (NOLOCK) WHERE Inbox = @iInBoxSN

		--update the tblAddress record
		UPDATE tblAddresses SET AddressName = @sNewName, UseInResolve = @iUseToResolve WHERE SN = @iOldAddressSN

		END


------------------ Copy From Login: Filter Based Inbox and Dispatch Group Records --------------------------



	IF ISNULL(@sOldName, '') > ''
		UPDATE tblFilters SET flt_LoginID = @sNewName WHERE flt_LoginID = @sOldName

	--if copy permissions from another login
	IF ISNULL(@sCopyPermFrom, '') > '' 
		BEGIN

		--make sure we already have a record for the copy from login 
		SELECT @iCopyFromLoginSN = sN FROM tblLogin (NOLOCK) WHERE LoginName = @sCopyPermFrom 

		IF ISNULL(@iCopyFromLoginSN, 0) = 0
			BEGIN
			SELECT @sT_1 = 'Copy Permission login (%s) does not exist.'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''
			RAISERROR (@sT_1, 16, 1, @sCopyPermFrom) 
			RETURN
			END
		
		--get the CopyFromFiterSN
		SELECT @iCopyFromFilterSN = flt_SN FROM tblFilters (NOLOCK) WHERE flt_LoginID = @sCopyPermFrom AND flt_name IS NULL
		
		--if we can not find an ADMIN Filter for the Copy From then, GoodBye
		IF ISNULL(@iCopyFromFilterSN, 0) = 0
			BEGIN
			SELECT @sT_1 = 'Copy Permission From name (%s) does not have an ADMIN filter.'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''
			RAISERROR (@sT_1, 16, 1, @sCopyPermFrom) 
			RETURN
			END

		--see if we already have an ADMIN Filter for the new name
		SELECT @iFilterSN = flt_SN FROM tblFilters (NOLOCK) WHERE flt_LoginID = @sNewName AND flt_name IS NULL
		
		--delete the <ADMIN> filter for the new name if there is one
		IF ISNULL(@iFilterSN, 0) > 0
			BEGIN
			DELETE FROM tblFilterElement WHERE flt_SN = @iFilterSN
			DELETE FROM tblFilters WHERE flt_SN = @iFilterSN
			END

		--create a new <ADMIN> filter for the new login
		INSERT INTO tblFilters (flt_LoginID, flt_Name, flt_CreatedBy) VALUES (@sNewName, NULL, '-PROC-')

		--get the new filters SN
		SELECT @iFilterSN = @@IDENTITY

		--copy all the filters from the copy from login
		INSERT INTO tblFilterElement (flt_SN, fel_Seq, fel_Type, fel_Value, fel_NoView, fel_NoRead, fel_NoSend, fel_PosOnly)
			SELECT @iFilterSN, fel_Seq, fel_Type, fel_Value, fel_NoView, fel_NoRead, fel_NoSend, fel_PosOnly 
			FROM tblFilterElement (NOLOCK)
			WHERE flt_SN = @iCopyFromFilterSN 

		--Delete all dispatch groups for this login
		DELETE FROM tblDispatchLogins WHERE LoginSN = @iLoginSNToUse
        
	        --Add a dispatch group for each of the copied login dispatch groups
		INSERT INTO tblDispatchLogins (LoginSN, DispatchGroupSN )
			SELECT @iLoginSNToUse, DispatchGroupSN
			FROM tblDispatchLogins (NOLOCK)
			WHERE LoginSN = @iCopyFromLoginSN
				
		END

		--Start PTS #40978
		if @SndResInfo = 1 
			Exec tm_TriggerResourceMessage @LoginSN,'Lgn',@Flags,@sOldName
		--End PTS #40978
GO
GRANT EXECUTE ON  [dbo].[tm_ConfigLogin] TO [public]
GO
