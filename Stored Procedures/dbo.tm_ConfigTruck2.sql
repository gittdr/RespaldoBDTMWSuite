SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[tm_ConfigTruck2] @sNewName varchar(50),
				@sOldName varchar(50),
				@sNewDispatchSystemID varchar(50),
				@sCurrentDispatchGroup varchar(50),
				@sDefaultCabUnit varchar(50),
				@sDefaultDriver varchar(50),
				@iRetired int,
				@iUseToResolve int,
				@sFlags varchar(12),
				@bIgnoreAddressBy BIT = 0

AS


--//  @sNewName					- Truck to Add or new name for a truck already existing
--//  @sOldname					- Truck name to update to new name (@NewName)
--//  @sNewDispatchSystemID			- Dispatch System ID for truck. 
--//						  If null for new truck records, then @sNewName will be used.
--//						  NULL or non-existant System ID for existing Truck records. If NULL, no update
--//
--//  ------------------------------------------------------------------------------------------------------------------------------------------------
--//  The following parameters have different functionality for NULL and ''
--//
--//  @sCurrentDispatchGroup
--//	Valid Dispatch Group 			- Changed to Dispatch Group		
--//	NULL 					- Not changed
--//	''					- Dispatch Group is set to None (no dispatch group)
--//
--//  @sDefaultCabUnit
--//	valid cab unit				- Sets cab unit as default. Will be added if it does not exist
--//						  The cab unit is added to the cab unit list if not already in it
--//	NULL, ''			- No changes are made
--//	UNKNOWN				- All cabunits are removed from the truck.
--//
--//  @sDefaultDriver
--//	Valid Driver Disp ID or TotalMail id 	- The Driver is set to default. Will be added if it does not exist
--//						  The driver is added to the assigned driver list if not already in it
--//	NULL, ''			- No changes are made
--//	UNKNOWN				- All drivers are removed from the truck.
--//  ------------------------------------------------------------------------------------------------------------------------------------------------
--//
--//  @iRetired					- Is the Truck Retired
--//						  0 or No, 1 for Yes. If a new truck. NULL is No. 
--//						  If exsiting Truck, NULL means keep current setting
--//
--//  @iUseToResolve				- Should the truck be used in auto resolution
--//						  0 or No, 1 for Yes. 
--//						  If a new truck. NULL is based on the Default Addressee type in Configuration. 
--//						  If exsiting Truck, NULL means keep current setting
--//
--//	 @sFlags		PTS 59916 update group flag in tbltrucks
--//						1 mcomm
--//						2 nonmcomm
--//
--//
--//  @bIgnoreAddressBy		  if 1, we ignore the addressby settings for dispatch Groups
--//						  else we only set up dispatch groups for truck if were truck based
--//
--//  3/156/12 - JC - PTS 59916 enhancement for member group update or creation
--//
--//


SET NOCOUNT ON

DECLARE @iOldSN Int,
    @iNewTruckSN int,
	@iParentSN int,
	@iOutBoxSN int,
	@iInBoxSN int,
	@iDrvMaster int ,
	@TrkMaster int ,
	@iMCMaster int ,
	@iLgnMaster int,
	@iTruckAddressType int,
	@iOldAddressSN int,
	@iUpdateTruckFlag int,
	@iDefaultCabUnitSN int,
	@iCurrentDispatchGroupSN int,
	@iDefaultDriverSN int,
	@sParentFolderName varchar(50),
	@iMobileCommTypeSN int,
	@sMobileCommTypeName varchar(20), 
	@iAddressBy int,
	@iTruckSNToUse int,
	@sT_1 Varchar(200),
	@FLAGS INT,
	@TruckAddressType int,
	--Start PTS #40978
	@SndResInfo int, 
	@TruckSN int,
	--End PTS #40978
	@sSubstr varchar(60), --PTS 40981
	@groupflag  int, -- PTS 59916
	@sUnitType varchar (20),
	@sCurrentTruck varchar (15), 
	@iCurrentMCUnitDefaultLevel int,
	@DEBUG INT,
	@sMCUnitFlags int,
	@iFlags int,
	@sTempMCUnitID varchar(100)
	
	
	SET @DEBUG =  1  -- 1 ON / 0 OFF


------------------ Check Parameters --------------------------
	Select @SndResInfo = isnull(Text,0) From TblRS (NOLOCK) Where Keycode = 'SndResInfo'--PTS #40978
	SELECT @sNewName = ISNULL(@sNewName, '')
	SELECT @sOldName = ISNULL(@sOldName, '')
	SELECT @sNewDispatchSystemID = ISNULL(@sNewDispatchSystemID, '')

	SET @groupflag = 0

	SET @iFlags = CONVERT(int, @sFlags)
	
	--Do not allow names to match, blank old name if same
	IF UPPER(@sNewName) = UPPER(@sOldName) 
		SELECT @sOldName = ''

	--make sure we have a sNewName, should always have one
	if ISNULL(@sNewName, '') > ''
		BEGIN
		
		--see if we can find the sOldName if we have one
		if ISNULL(@sOldName, '') > ''
			BEGIN
			SELECT @iOldSN = sN FROM tblTrucks (NOLOCK) WHERE TruckName = @sOldName	
			
			--COuld not find the sOldName, can not update, Goodbye
			IF ISNULL(@iOldSN, 0) = 0
				BEGIN
				SELECT @sT_1 = 'Old name (%s) not found for copy.'
				EXEC dbo.tm_t_sp @sT_1 out, 0, ''
				RAISERROR (@sT_1, 16, 1, @sOldName)
				RETURN
				END

			--make sure the new name does not already exist
			IF EXISTS (SELECT * From tblTrucks (NOLOCK) WHERE TruckName = @sNewName)

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
			IF NOT EXISTS (SELECT * FROM tblTrucks (NOLOCK) WHERE TruckName = @sNewName)
				IF ISNULL(@sNewDispatchSystemID, '') = ''
					SELECT @sNewDispatchSystemID = @sNewName			
		
			--see if the new DispatchID belongs to 
			IF EXISTS (SELECT * FROM tblTrucks (NOLOCK)WHERE DispSysTruckID = @sNewDispatchSystemID)
				IF UPPER((SELECT TruckName FROM tblTrucks (NOLOCK) WHERE DispSysTruckID = @sNewDispatchSystemID)) <> UPPER(@sNewName)
					BEGIN
					SELECT @sT_1 = 'Dispatch ID (%s) already exists.'
					EXEC dbo.tm_t_sp @sT_1 out, 0, ''
					RAISERROR (@sT_1, 16, 1, @sNewDispatchSystemID) 
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
	
	SELECT @iUpdateTruckFlag = 0


------------------ Get Default SNs --------------------------

	--Get AddressBy from RS (0 Driver, 1 Truck)
	SELECT @iAddressBy = Text FROM tblRS (NOLOCK) WHERE keyCode = 'ADDRESSBY'
	SELECT @TruckAddressType = tblAddressTypes.SN FROM tblAddressTypes (NOLOCK) WHERE tblAddressTypes.AddressType = 'T'

	SELECT @iDefaultCabUnitSN = NULL

	--try to find the Default Cab Unit
	IF ISNULL(@sDefaultCabUnit, '') > '' AND UPPER(ISNULL(@sDefaultCabUnit, '')) <> 'UNKNOWN'
	        SELECT @iDefaultCabUnitSN = SN 
			FROM tblCabUnits (NOLOCK)
			WHERE GroupFlag = 0 AND Retired = 0 AND UnitID = @sDefaultCabUnit AND LinkedAddrType = @TruckAddressType

	--we will check the Default cab unit later

	SELECT @iDefaultDriverSN = NULL

	--try to find the Default Driver
	IF ISNULL(@sDefaultDriver, '') > '' AND UPPER(ISNULL(@sDefaultDriver, '')) <> 'UNKNOWN'
		BEGIN

		SELECT @iDefaultDriverSN = SN 
			FROM tblDrivers (NOLOCK)
			WHERE Retired = 0 AND DispSysDriverID = @sDefaultDriver

		IF ISNULL(@iDefaultDriverSN, 0) = 0
			SELECT @iDefaultDriverSN = SN 
				FROM tblDrivers (NOLOCK)
				WHERE Retired = 0 AND Name = @sDefaultDriver
		
		END

	SELECT @iCurrentDispatchGroupSN = NULL

	--try to find the Current Dispatch Group
	--Do not set dispatch group if member group truck
	if (@iFlags & 1 = 0) AND (@iFlags & 2 = 0) 
	BEGIN
		IF ISNULL(@sCurrentDispatchGroup, '') > '' AND (@iAddressBy = 1 OR @bIgnoreAddressBy = 1)
			--Get minimum Dispatch Group if <Default> tag passed in
			IF @sCurrentDispatchGroup = '<Default>'
				SELECT @iCurrentDispatchGroupSN = MIN(SN) FROM tblDispatchGroup 
			ELSE
			--Get passed in Dispatch Group SN
				SELECT @iCurrentDispatchGroupSN = SN 
					FROM tblDispatchGroup (NOLOCK)
					WHERE Name = @sCurrentDispatchGroup
		
		--make sure we have a SN if there was a CurrentDispatchGroup passed in
		IF ISNULL(@sCurrentDispatchGroup, '') > '' AND ISNULL(@iCurrentDispatchGroupSN, 0) = 0 AND (@iAddressBy = 1 OR @bIgnoreAddressBy = 1)
			BEGIN
			SELECT @sT_1 = 'Dispatch Group not found (%s), if <Default> no dispatch groups defined.'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''
			RAISERROR (@sT_1, 16, 1, @sCurrentDispatchGroup)
			RETURN
			END
	END
	
------------------ now that we passed restrictions, Make sure that we have the Cab Unit and Driver --------------------------

--// MC Unit

	--Create MC Unit if passed in and not already there
	
	IF (ISNULL(@iDefaultCabUnitSN, 0) = 0 AND ISNULL(@sDefaultCabUnit, '') > '' AND UPPER(ISNULL(@sDefaultCabUnit, '')) <> 'UNKNOWN') OR ((@iFlags & 1 = 1) OR (@iFlags & 2 = 2))
		BEGIN

			--PTS 40981_Start_DP
			-- look for the [] and parse out the MobileComm SN if any.
			IF CHARINDEX('[', @sDefaultCabUnit) > 0 AND CHARINDEX(']', @sDefaultCabUnit) = LEN(@sDefaultCabUnit) 
				BEGIN
					SELECT @sSubStr = SUBSTRING(@sDefaultCabUnit, CHARINDEX('[', @sDefaultCabUnit)+ 1, (CHARINDEX(']', @sDefaultCabUnit) - CHARINDEX('[', @sDefaultCabUnit)-1))
					IF ISNUMERIC (@sSubStr) = 1
							SELECT @iMobileCommTypeSN = CAST(@sSubStr AS INT)
				END
			ELSE
				BEGIN
					--See if we have a single mobile comm type
					SELECT  @iMobileCommTypeSN =
						CASE WHEN (SELECT text FROM tblrs where keycode = 'MCMODE') = '1'
						THEN CAST((SELECT text FROM tblRS WHERE keycode = 'SINGLEMC') AS INT)
						ELSE 1 
						END
				END	
			--PTS 40981_End_DP
		
				--Get name for MC Unit Proceedure
		IF ISNULL(@iMobileCommTypeSN , 0) > 0 
			SELECT @sMobileCommTypeName = MobileCommType FROM tblMobileCommType WHERE SN = @iMobileCommTypeSN


		--PTS 59916 create a mobile comm unit for member group
		IF (@iFlags & 1 = 1) OR (@iFlags & 2 = 2)
			BEGIN
				IF @iFlags & 2 = 2
					BEGIN
						SET @sMCUnitFlags = 1 
						SET @groupflag = 2
					END
				ELSE 
					Begin
						SET @sMCUnitFlags = 1
						SET @groupflag = 1 --DWG
					End 
				
				-------------------------------------------------------------------
				--DEBUG
				IF @DEBUG > 0 
					SELECT 'I MADE IT INTO SETTING CAB UNIT', @groupflag 
				------------------------------------------------------------------

				--Should always be here since I just looked it up, but....
				IF ISNULL(@sMobileCommTypeName, '') > ''
					BEGIN
						SET @sTempMCUnitID = 'NONMCN:' + @sNewName
						EXEC tm_ConfigMCUnit2 @sTempMCUnitID, '', @sMobileCommTypeName, NULL, NULL, NULL, NULL, NULL, @sMCUnitFlags
						
						--if the MC Unit was just createad we need to get
						SELECT @iDefaultCabUnitSN = SN 
						FROM tblCabUnits (NOLOCK)
						WHERE GroupFlag = 1 AND Retired = 0 AND UnitID = @sTempMCUnitID AND LinkedAddrType = @TruckAddressType

						SET @sDefaultCabUnit = @sTempMCUnitID
						
					END
			END 
		ELSE
			BEGIN
				--Should always be here since I just looked it up, but....
				IF ISNULL(@sMobileCommTypeName, '') > ''
					EXEC dbo.tm_ConfigMCUnit @sDefaultCabUnit,
						'',
						@sMobileCommTypeName,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL

					--if the MC Unit was just createad we need to get
    				SELECT @iDefaultCabUnitSN = SN 
					FROM tblCabUnits (NOLOCK)
					WHERE Retired = 0 AND UnitID = @sDefaultCabUnit AND LinkedAddrType = @TruckAddressType

			END

--End pts 59916

		END

--//  Driver

	--Create Driver if passed in and not already there
	IF ISNULL(@iDefaultDriverSN, 0) = 0 AND ISNULL(@sDefaultDriver, '') > '' AND UPPER(ISNULL(@sDefaultDriver, '')) <> 'UNKNOWN'

		BEGIN

			EXEC dbo.tm_ConfigDriver @sDefaultDriver,
				'',
				NULL,
				NULL,				
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL

			--if the Driver was just createad we need to get
			SELECT @iDefaultDriverSN = SN 
				FROM tblDrivers (NOLOCK)
				WHERE Retired = 0 AND DispSysDriverID = @sDefaultDriver

		END

------------------ Truck record --------------------------

	--if this is not an update, old Name not passed in
	IF ISNULL(@iOldSN, 0) = 0 

		BEGIN

		--see if we already have a record for the Truck Name
		SELECT @iOldSN = sN FROM tblTrucks (NOLOCK) WHERE TruckName = @sNewName 

		--Do not have a record for the truck, create one
		IF ISNULL(@iOldSN, 0) = 0 
			BEGIN

			--get the retired setting, if null use 0 for No
			SELECT @iRetired  = ISNULL(@iRetired, 0)

			--get the truck Master Folder ID
			exec dbo.tm_GetMasterFolderIDs 0, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out
			
			--if there is no Truck Master Folder ID, use root level
			IF ISNULL(@TrkMaster, 0) = 0
				SELECT @TrkMaster = NULL

			SELECT @sParentFolderName = 'Truck: ~1''s Private Folders'
			SELECT @sT_1 = @sParentFolderName
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''
			EXEC dbo.tm_sprint @sT_1 out, @sNewName, '', '', '', '', '', '', '', '', ''
			SELECT  @sParentFolderName = @sT_1

			--Insert the new folders, first owner will be null since we do not know the truck SN yet
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

			--Insert truck Profile record
			INSERT INTO tblTrucks 
				(TruckName, DispSysTruckID, Inbox, OutBox, DefaultCabUnit, DefaultDriver, CurrentDispatcher, Retired, KeepHistory, GroupFlag) 
				VALUES (@sNewName, @sNewDispatchSystemID, @iInBoxSN, @iOutBoxSN, @iDefaultCabUnitSN, @iDefaultDriverSN, @iCurrentDispatchGroupSN, 
				@iRetired, 1, @groupflag)

			Select @iNewTruckSN = @@IDENTITY
			
			--Start PTS 40978
			Set @Flags = 1
			Set  @TruckSN =   @iNewTruckSN
			--End PTS 40978
			--update the Parent folder to the Truck folder SN
			UPDATE tblFolders SET Owner = @iNewTruckSN WHERE SN = @iParentSN

			--set general Truck SN variable
			SELECT @iTruckSNToUse = @iNewTruckSN	

			--if we were unable to create a truck Master, this is the first truck, try it again and update the new record
			if ISNULL(@TrkMaster, 0) = 0 
				exec dbo.tm_GetMasterFolderIDs 1, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out


			END

		ELSE
		--we have a record for the new truck name, update it
			SELECT @iUpdateTruckFlag = -1

		END

	--Update Truck Name, old name passed in and found or Truck record already existed
	ELSE
		SELECT @iUpdateTruckFlag = -1


	--if we are to update the Truck record
	if @iUpdateTruckFlag = -1
		BEGIN

		SELECT @sParentFolderName = 'Truck: ~1''s Private Folders'
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
		IF ISNULL(@sNewDispatchSystemID, '') = '' 
			SELECT @sNewDispatchSystemID = DispSysTruckID FROM tblTrucks (NOLOCK) WHERE SN = @iOldSN

		--set the new truck name and retired setting
		UPDATE tblTrucks 
			SET TruckName = @sNewName, Retired = @iRetired, DispSysTruckID = @sNewDispatchSystemID 
			WHERE SN = @iOldSN
		
		--Start PTS #40978
		Set  @Flags  = 2	
		Set  @TruckSN =   @iOldSN
		--End PTS #40978
		
		--if a new Current Dispatch Group was passed in, set it
		IF ISNULL(@iCurrentDispatchGroupSN, 0) > 0 OR @sCurrentDispatchGroup = ''
			IF @sCurrentDispatchGroup = ''
				UPDATE tblTrucks SET CurrentDispatcher = NULL WHERE SN = @iOldSN
			ELSE
				UPDATE tblTrucks SET CurrentDispatcher = @iCurrentDispatchGroupSN WHERE SN = @iOldSN

		--Update tblFolders name with new name
	        UPDATE tblFolders 
			SET Name = @sParentFolderName 
			WHERE SN = (SELECT Parent from tblFolders WHERE SN = @iInBoxSN)

		--set general Truck SN variable
		SELECT @iTruckSNToUse = @iOldSN

		END

------------------ Update Default Information --------------------------

	--if we have a Default Cab Unit SN, set it up
	IF ISNULL(@iDefaultCabUnitSN, 0) > 0 OR ISNULL(@sDefaultCabUnit, '') > '' 
		BEGIN

        --Remove selected default MCT from any other truck it might be default on
        UPDATE tblTrucks SET DefaultCabUnit = Null WHERE sn = @iTruckSNToUse 

	        --Remove all MCT's from this truck
		IF UPPER(ISNULL(@sDefaultCabUnit, '')) = 'UNKNOWN'
	        	UPDATE tblCabUnits SET Truck = Null, LinkedObjSN = NULL WHERE LinkedObjSN = @iTruckSNToUse
		
		--if we were not told to remove the Default cab unit only
		IF ISNULL(@sDefaultCabUnit, '') <> '' AND UPPER(ISNULL(@sDefaultCabUnit, '')) <> 'UNKNOWN'
			BEGIN

	        --Add driver as default on this truck
			UPDATE tblTrucks SET DefaultCabUnit  = @iDefaultCabUnitSN WHERE SN = @iTruckSNToUse
		
	        --Add Default MCT's to this truck
   		   	UPDATE tblCabUnits SET Truck = @iTruckSNToUse, LinkedObjSN = @iTruckSNToUse WHERE SN = @iDefaultCabUnitSN
	
			END
		
		END

			
	--if we have a default Driver, set it up
	IF ISNULL(@iDefaultDriverSN, 0) > 0 OR ISNULL(@sDefaultDriver, '') > ''
		BEGIN
	
		--Remove selected default driver from any other truck he might be default on
       		UPDATE tblTrucks SET DefaultDriver = Null WHERE DefaultDriver = @iDefaultDriverSN

	        --Remove all drivers from this truck
		IF UPPER(ISNULL(@sDefaultDriver, '')) = 'UNKNOWN'
	        	UPDATE tblDrivers SET CurrentTruck = Null WHERE CurrentTruck = @iTruckSNToUse
		
		--if we were not told to remove the Default driver only
		IF ISNULL(@sDefaultDriver, '') <> ''
			BEGIN

		        --Add driver as default on this truck
		        UPDATE tblTrucks SET DefaultDriver =  @iDefaultDriverSN WHERE SN = @iTruckSNToUse

		        --Add Default driver to this truck
        	    	UPDATE tblDrivers SET CurrentTruck = @iTruckSNToUse WHERE SN = @iDefaultDriverSN
			
			END

		END

------------------ Addresses record --------------------------

	--tblAddresses Record Insert
	IF ISNULL(@iOldSN, 0) = 0
		BEGIN

		--find the tblAddresses SN for Truck type 
		SELECT @iTruckAddressType = SN FROM tblAddressTypes WHERE AddressType = 'T'
		
		--get the Resolve setting, if null use 1 if resolve by Truck, 0 if anything else
		IF ISNULL(@iUseToResolve, -1) = -1
			IF @iAddressBy = 1			
				SELECT @iUseToResolve = 1
			ELSE
				SELECT @iUseToResolve = 0

		--Insert the Address record
		INSERT INTO tblAddresses 
			(AddressBookSN, AddressType, Inbox, Outbox, AddressName, UseInResolve) 
			VALUES (NULL, @iTruckAddressType, @iInBoxSN, @iOutBoxSN, @sNewName, @iUseToResolve)
		
		END

	--tblAddresses Record Update
	ELSE
		BEGIN
	
		--Get the Inbox SN
	        SELECT @iInBoxSN = Inbox FROM tblTrucks (NOLOCK) WHERE SN = @iTruckSNToUse

		--find the old tblAddresses record
		SELECT @iOldAddressSN = SN FROM tblAddresses (NOLOCK) WHERE Inbox = @iInBoxSN

		--if a iUseToResolve was not passed in keep it the same as the old one
		IF ISNULL(@iUseToResolve, -1) = -1
			SELECT @iUseToResolve = UseInResolve FROM tblAddresses (NOLOCK) WHERE Inbox = @iInBoxSN

		--update the tblAddress record
		UPDATE tblAddresses 
			SET AddressName = @sNewName, UseInResolve = @iUseToResolve 
			WHERE SN = @iOldAddressSN

		END

		--Start PTS #40978
		if @SndResInfo = 1 
			Exec tm_TriggerResourceMessage @iNewTruckSN,'Trc',@Flags,@sOldName
		--End PTS #40978
	  
GO
GRANT EXECUTE ON  [dbo].[tm_ConfigTruck2] TO [public]
GO
