SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Procedure [dbo].[tm_ConfigTrailer] @sNewName varchar(15),
				@sOldName varchar(15),
				@sNewDispatchSystemID varchar(13),  -- PTS32540 Pass in 13, but make store in 17 when converted to 'TRL:' + @sNewDispatchSystemID
				@sCurrentDispatchGroup varchar(30),  
				@sDefaultCabUnit varchar(50),
				@iRetired INT,                      -- 0 = not retired, 1 = retired
				@bIgnoreAddressBy BIT = 0
AS


--//  @sNewName					- Trailer to Add or new name for a Trailer already existing
--//  @sOldname					- Trailer name to update to new name (@NewName)
--//  @sNewDispatchSystemID			- Dispatch System ID for Trailer. 
--//						  If NULL for new Trailer records, then @sNewName will be used (but may be truncated).
--//						  IF NULL, or '' for existing Trailer records, no update.
--//
--//  ------------------------------------------------------------------------------------------------------------------------------------------------
--//  The following parameters have different functionality for NULL and ''
--//
--//  @sCurrentDispatchGroup
--//	Valid Dispatch Group 			- Changed to Dispatch Group		
--//	NULL, ''				- Not changed
--//	'UNKNOWN'				- Dispatch Group is set to None (no dispatch group)
--//
--//  @sDefaultCabUnit
--//	valid cab unit				- Sets cab unit as default. Will be added if it does not exist
--//						  The cab unit is added to the cab unit list if not already in it
--//	NULL, ''				- No changes are made
--//	'UNKNOWN'				- All cabunits are removed from the Trailer.
--//
--//  ------------------------------------------------------------------------------------------------------------------------------------------------
--//
--//  @iRetired					- Is the Trailer Retired
--//						  0 or No, 1 for Yes. If a new Trailer. NULL is No. 
--//						  If exsiting Trailer, NULL means keep current setting
--//
--//  @bIgnoreAddressBy		  if 1, we ignore the addressby settings for dispatch Groups
--//	

SET NOCOUNT ON

DECLARE @iOldSN Int,
        @iNewTrailerSN int,
	@iParentSN int,
	@iOutBoxSN int,
	@iInBoxSN int,
	@iDrvMaster int ,
	@TrkMaster int ,
	@iMCMaster int ,
	@iLgnMaster int,
	@iTrailerAddressType int,
	@iOldAddressSN int,
	@iUpdateTrailerFlag int,
	@iDefaultCabUnitSN int,
	@iCurrentDispatchGroupSN int,
	@sParentFolderName varchar(50),
	@iAddressBy int,
	@iTrailerSNToUse int,
	@sT_1 Varchar(200),
	@sNewDispatchSystemID_Ext VARCHAR(17),			-- PTS32540 Change to 17 to accomodate the increase in size of @sNewDispatchSystemID from 9 to 13
	@TruckAddressType int,
	--Start PTS #40978
	@SndResInfo int, 
	@Flags int,
	@TrailerSN int
	--End PTS #40978

	Select @SndResInfo = isnull(Text,0) From TblRS Where Keycode = 'SndResInfo'--PTS #40978

------------------ Init @sNewDispatchSystemID_Ext --------------------------
	IF UPPER(LEFT(ISNULL(@sNewDispatchSystemID, '    '), 4)) <> 'TRL:' AND ISNULL(@sNewDispatchSystemID, '') <> ''
		SELECT @sNewDispatchSystemID_Ext = 'TRL:' + @sNewDispatchSystemID
	ELSE
		SELECT @sNewDispatchSystemID_Ext = @sNewDispatchSystemID


------------------ Check Parameters --------------------------

	SELECT @sNewName = ISNULL(@sNewName, '')
	SELECT @sOldName = ISNULL(@sOldName, '')
	SELECT @sNewDispatchSystemID_Ext = ISNULL(@sNewDispatchSystemID_Ext, '')

	--Do not allow names to match, blank old name if same
	IF UPPER(@sNewName) = UPPER(@sOldName) 
		SELECT @sOldName = ''

	--make sure we have a sNewName, should always have one
	if ISNULL(@sNewName, '') > ''
		BEGIN
		
		--see if we can find the sOldName if we have one
		if ISNULL(@sOldName, '') > ''
			BEGIN
			SELECT @iOldSN = sN FROM tblTrucks (NOLOCK) 
			WHERE TruckName = @sOldName
			
			--COuld not find the sOldName, can not update, Goodbye
			IF ISNULL(@iOldSN, 0) = 0
				BEGIN
				SELECT @sT_1 = 'Old name (%s) not found for copy.'
				EXEC dbo.tm_t_sp @sT_1 out, 0, ''
				RAISERROR (@sT_1, 16, 1, @sOldName)
				RETURN
				END

			--make sure the new name does not already exist
			IF EXISTS (SELECT * From tblTrucks WHERE TruckName = @sNewName)
				BEGIN
				SELECT @sT_1 = 'Both old name (%s) and new name (%s) already exist.'
				EXEC dbo.tm_t_sp @sT_1 out, 0, ''
				RAISERROR (@sT_1, 16, 1, @sOldName, @sNewName) 
				RETURN
				END

			END
		ELSE

			BEGIN
			
			--A dispatch ID must be specified or @sNewName will be used
			IF ISNULL(@sNewDispatchSystemID_Ext, '') = ''
				SELECT @sNewDispatchSystemID_Ext = 'TRL:' + LEFT(@sNewName, 13)		-- PTS32540 

			--See if the new DispatchID belongs to (exists as passed in OR with TRL prefix)
			IF EXISTS (SELECT * FROM tblTrucks (NOLOCK) WHERE DispSysTruckID = @sNewDispatchSystemID_Ext)
				IF UPPER((SELECT TruckName FROM tblTrucks (NOLOCK) WHERE DispSysTruckID = @sNewDispatchSystemID_Ext)) <> UPPER(@sNewName)
					BEGIN
					SELECT @sT_1 = 'Dispatch ID (%s) already exists.'
					EXEC dbo.tm_t_sp @sT_1 out, 0, ''
					RAISERROR (@sT_1, 16, 1, @sNewDispatchSystemID_Ext) 
					RETURN
					END
			END

		END

	--No sNewName, Goodbye
	ELSE
		BEGIN
		SELECT @sT_1 = 'No new name (%s) to create specified.'
		EXEC dbo.tm_t_sp @sT_1 out, 0, ''
		RAISERROR (@sT_1, 16, 1, @sNewName)
		RETURN
		END
	
	SELECT @iUpdateTrailerFlag = 0

------------------ Get Default SNs --------------------------

	--Get AddressBy from RS (0 Driver, 1 Truck/Trailer, 2 MC Unit )
	SELECT @iAddressBy = Text FROM tblRS (NOLOCK) WHERE keyCode = 'ADDRESSBY'
	SELECT @TruckAddressType = tblAddressTypes.SN FROM tblAddressTypes (NOLOCK) WHERE tblAddressTypes.AddressType = 'T'


	SELECT @iDefaultCabUnitSN = NULL

	--try to find the Default Cab Unit
	IF ISNULL(@sDefaultCabUnit, '') > '' AND UPPER(ISNULL(@sDefaultCabUnit, '')) <> 'UNKNOWN'
	        SELECT @iDefaultCabUnitSN = SN 
			FROM tblCabUnits (NOLOCK)
			WHERE GroupFlag = 0 AND Retired = 0 AND UnitID = @sDefaultCabUnit AND LinkedAddrType = @TruckAddressType

	--we will check the Default cab unit later

	--try to find the Default Driver
	SELECT @iCurrentDispatchGroupSN = NULL

	--try to find the Current Dispatch Group
	IF ISNULL(@sCurrentDispatchGroup, '') > '' AND (@iAddressBy = 1 OR @bIgnoreAddressBy = 1) AND UPPER(ISNULL(@sCurrentDispatchGroup, '')) <> 'UNKNOWN'
		--Get minimum Dispatch Group if <Default> tag passed in
		IF @sCurrentDispatchGroup = '<Default>'
			SELECT @iCurrentDispatchGroupSN = MIN(SN) FROM tblDispatchGroup (NOLOCK) 
		ELSE
		--Get passed in Dispatch Group SN
			SELECT @iCurrentDispatchGroupSN = SN 
				FROM tblDispatchGroup (NOLOCK) 
				WHERE Name = @sCurrentDispatchGroup
	
	--make sure we have a SN if there was a CurrentDispatchGroup passed in
	IF ISNULL(@sCurrentDispatchGroup, '') > '' AND ISNULL(@iCurrentDispatchGroupSN, 0) = 0 AND (@iAddressBy = 1 OR @bIgnoreAddressBy = 1)  AND UPPER(ISNULL(@sCurrentDispatchGroup, '')) <> 'UNKNOWN'
		BEGIN
		SELECT @sT_1 = 'Dispatch Group not found (%s), if <Default> no dispatch groups defined.'
		EXEC dbo.tm_t_sp @sT_1 out, 0, ''
		RAISERROR (@sT_1, 16, 1, @sCurrentDispatchGroup)
		RETURN
		END

------------------ now that we passed restrictions, Make sure that we have the Cab Unit and Driver --------------------------

--// MC Unit

	--Create MC Unit if passed in and not already there
	IF ISNULL(@iDefaultCabUnitSN, 0) = 0 AND ISNULL(@sDefaultCabUnit, '') > '' AND UPPER(ISNULL(@sDefaultCabUnit, '')) <> 'UNKNOWN'
	BEGIN
		EXEC dbo.tm_ConfigMCUnit @sDefaultCabUnit,
			'',
			'TTIS',
			NULL,
			NULL,
			NULL,
			NULL,
			NULL


		--if the MC Unit was just createad we need to get
		IF ISNULL(@iDefaultCabUnitSN , 0) = 0 
		        SELECT @iDefaultCabUnitSN = SN 
				FROM tblCabUnits (NOLOCK) 
				WHERE GroupFlag = 0 AND Retired = 0 AND UnitID = @sDefaultCabUnit AND LinkedAddrType = @TruckAddressType
	END

------------------ Trailer record --------------------------

	--if this is not an update, old Name not passed in
	IF ISNULL(@iOldSN, 0) = 0 

		BEGIN

		--see if we already have a record for the Trailer Name
		SELECT @iOldSN = sN FROM tblTrucks (NOLOCK) WHERE TruckName = @sNewName 

		--Do not have a record for the Trailer, create one
		IF ISNULL(@iOldSN, 0) = 0 
			BEGIN

			--get the retired setting, if null use 0 for No
			SELECT @iRetired  = ISNULL(@iRetired, 0)

			--get the Truck Master Folder ID
			exec dbo.tm_GetMasterFolderIDs 0, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out
			
			--if there is no Truck Master Folder ID, use root level
			IF ISNULL(@TrkMaster, 0) = 0
				SELECT @TrkMaster = NULL

			SELECT @sParentFolderName = 'Trailer: ~1''s Private Folders'
			SELECT @sT_1 = @sParentFolderName
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''
			EXEC dbo.tm_sprint @sT_1 out, @sNewName, '', '', '', '', '', '', '', '', ''
			SELECT  @sParentFolderName = @sT_1

			--Insert the new folders, first owner will be null since we do not know the Trailer SN yet
			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@TrkMaster, @sParentFolderName, NULL, 0)
			Select @iParentSN = @@IDENTITY

			SELECT @sT_1 = 'InBox'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''

			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iParentSN, @sT_1, NULL, 0)
			Select @iInBoxSN = @@IDENTITY

			SELECT @sT_1 = 'OutBox'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''

			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iParentSN, @sT_1, NULL, 0)
			Select @iOutBoxSN = @@IDENTITY

			--Insert Trailer Profile record
			INSERT INTO tblTrucks 
				(TruckName, DispSysTruckID, Inbox, OutBox, DefaultCabUnit, CurrentDispatcher, Retired, KeepHistory) 
				VALUES (@sNewName, @sNewDispatchSystemID_Ext, @iInBoxSN, @iOutBoxSN, @iDefaultCabUnitSN, @iCurrentDispatchGroupSN, @iRetired, 1)

			Select @iNewTrailerSN = @@IDENTITY
			--Start PTS #40978
			Set  @Flags  = 1	
			Set @TrailerSN = @iNewTrailerSN
			--End PTS #40978
			--update the Parent folder to the Trailer folder SN
			UPDATE tblFolders SET Owner = @iNewTrailerSN WHERE SN = @iParentSN

			--set general Trailer SN variable
			SELECT @iTrailerSNToUse = @iNewTrailerSN

			--if we were unable to create a Truck Master, this is the first Truck/Trailer, try it again and update the new record
			if ISNULL(@TrkMaster, 0) = 0 
				exec dbo.tm_GetMasterFolderIDs 1, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out


			END

		ELSE
		--we have a record for the new Trailer name, update it
			SELECT @iUpdateTrailerFlag = -1

		END

	--Update Trailer Name, old name passed in and found or Trailer record already existed
	ELSE
		SELECT @iUpdateTrailerFlag = -1

	
	--if we are to update the Trailer record
	if @iUpdateTrailerFlag = -1
		BEGIN

		SELECT @sParentFolderName = 'Trailer: ~1''s Private Folders'
		SELECT @sT_1 = @sParentFolderName
		EXEC dbo.tm_t_sp @sT_1 out, 0, ''
		EXEC dbo.tm_sprint @sT_1 out, @sNewName, '', '', '', '', '', '', '', '', ''
		SELECT  @sParentFolderName = @sT_1

		--Get the Inbox SN
	        SELECT @iInBoxSN = Inbox FROM tblTrucks (NOLOCK) WHERE SN = @iOldSN

		--if a iRetired was not passed in, keep it the same as the old one
		IF ISNULL(@iRetired, -1) = -1
			SELECT @iRetired = Retired FROM tblTrucks (NOLOCK) WHERE sn = @iOldSN

		--if a new Dispatch System ID was not passed in, Keep it the Same as the old one
		IF ISNULL(@sNewDispatchSystemID_Ext, '') = '' 
			SELECT @sNewDispatchSystemID_Ext = DispSysTruckID FROM tblTrucks (NOLOCK) WHERE SN = @iOldSN

		--set the new Trailer name and retired setting
		UPDATE tblTrucks 
			SET TruckName = @sNewName, Retired = @iRetired, DispSysTruckID = @sNewDispatchSystemID_Ext 
			WHERE SN = @iOldSN
		--Start PTS #40978
		Set  @Flags  = 2	
		Set @TrailerSN = @iOldSN
		--End PTS #40978
		--if a new Current Dispatch Group was passed in, set it
		IF ISNULL(@iCurrentDispatchGroupSN, 0) > 0 OR UPPER(ISNULL(@sCurrentDispatchGroup, '')) = 'UNKNOWN' -- OR @sCurrentDispatchGroup = ''
			IF UPPER(ISNULL(@sCurrentDispatchGroup, '')) = 'UNKNOWN'  -- @sCurrentDispatchGroup = ''
				UPDATE tblTrucks SET CurrentDispatcher = NULL WHERE SN = @iOldSN
			ELSE
				UPDATE tblTrucks SET CurrentDispatcher = @iCurrentDispatchGroupSN WHERE SN = @iOldSN

		--Update tblFolders name with new name
	        UPDATE tblFolders 
			SET Name = @sParentFolderName 
			WHERE SN = (SELECT Parent from tblFolders (NOLOCK) WHERE SN = @iInBoxSN)

		--set general Trailer SN variable
		SELECT @iTrailerSNToUse = @iOldSN

		END

------------------ Update Default Information --------------------------

	--if we have a Default Cab Unit SN, set it up
	IF ISNULL(@iDefaultCabUnitSN, 0) > 0 OR IsNull(@sDefaultCabUnit, '') > ''
		BEGIN

	        --Remove selected default MCT from any other Trailer it might be default on
	        UPDATE tblTrucks SET DefaultCabUnit = Null WHERE SN = @iTrailerSNToUse  --DefaultCabUnit =  @iDefaultCabUnitSN 

	        --Remove all MCT's from this Trailer
		IF UPPER(ISNULL(@sDefaultCabUnit, '')) = 'UNKNOWN'
	        	UPDATE tblCabUnits SET Truck = Null, LinkedObjSN = NULL WHERE LinkedObjSN = @iTrailerSNToUse
		
		--if we were not told to remove the Default cab unit only
		IF @sDefaultCabUnit <> '' AND UPPER(ISNULL(@sDefaultCabUnit, '')) <> 'UNKNOWN'
			BEGIN

		        --Add driver as default on this Trailer
			UPDATE tblTrucks SET DefaultCabUnit  = @iDefaultCabUnitSN WHERE SN = @iTrailerSNToUse
		
		        --Add Default MCT's to this Trailer
       		   	UPDATE tblCabUnits SET Truck = @iTrailerSNToUse, LinkedObjSN = @iTrailerSNToUse WHERE SN = @iDefaultCabUnitSN
	
			END
		
		END


------------------ Addresses record --------------------------

	--tblAddresses Record Insert
	IF ISNULL(@iOldSN, 0) = 0
		BEGIN

		--find the tblAddresses SN for Truck type 
		SELECT @iTrailerAddressType = SN FROM tblAddressTypes (NOLOCK) WHERE AddressType = 'T'

		--Insert the Address record
		INSERT INTO tblAddresses 
			(AddressBookSN, AddressType, Inbox, Outbox, AddressName, UseInResolve) 
			VALUES (NULL, @iTrailerAddressType, @iInBoxSN, @iOutBoxSN, @sNewName, 0)

		END

	--tblAddresses Record Update
	ELSE
		BEGIN
	
		--Get the Inbox SN
	        SELECT @iInBoxSN = Inbox FROM tblTrucks (NOLOCK) WHERE SN = @iTrailerSNToUse

		--find the old tblAddresses record
		SELECT @iOldAddressSN = SN FROM tblAddresses (NOLOCK) WHERE Inbox = @iInBoxSN

		--update the tblAddress record
		UPDATE tblAddresses 
			SET AddressName = @sNewName
			WHERE SN = @iOldAddressSN

		END

	--Start PTS #40978
	if @SndResInfo = 1 
		Exec tm_TriggerResourceMessage @TrailerSN,'Trl',@Flags,@sOldName
	--End PTS #40978
GO
GRANT EXECUTE ON  [dbo].[tm_ConfigTrailer] TO [public]
GO
