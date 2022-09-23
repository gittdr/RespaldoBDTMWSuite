SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 40981 @sNewName varchar(50) is changed to varchar(60)
--PTS 40981 @sOldName varchar(50) is changed to varchar(60)
CREATE Procedure [dbo].[tm_ConfigMCUnit2] @sNewName varchar(60),
				@sOldName varchar(60),
				@sUnitType varchar(20),
				@sCurrentDispatchGroup varchar(30),
				@sCurrentTruck varchar(15),
				@iCurrentMCUnitDefaultLevel int,
				@iRetired int,
				@iUseToResolve int,
				@SFLAGS INT,
				@bIgnoreAddressBy BIT = 0

AS


--//  @sNewName					- MC Unit to Add or new name for a MC Unit already existing
--//  @sOldname					- MC Unit ID to update to new name (@NewName)
--//  @sUnitType 				- 
--//
--//  ------------------------------------------------------------------------------------------------------------------------------------------------
--//  The following parameters have different functionality for NULL and ''
--//
--//  @sCurrentDispatchGroup
--//	Valid Dispatch Group 			- Changed to Dispatch Group		
--//	NULL 					- Not changed
--//	''					- Dispatch Group is set to None (no dispatch group)
--//
--//  @sCurrentTruck
--//	Valid Truck	 			- Changed to Truck
--//	NULL 					- Not changed
--//	''					- Truck is set to None (no Current Truck)
--//
--//  ------------------------------------------------------------------------------------------------------------------------------------------------
--//
--//  @iCurrentTruckDefaultLevel 		- 1 Co MCT (Default)
--//						- 2 Slip Seat
--//						- 2 Make Leader MCT
--//
--//  @iRetired					- Is the MC Unit Retired
--//						  0 or No, 1 for Yes. If a new MC UNit. NULL is No. 
--//						  If exsiting MC Unit, NULL means keep current setting
--//
--//  @iUseToResolve				- Should the MC Unit be used in auto resolution
--//						  0 or No, 1 for Yes. 
--//						  If a new MC Unit. NULL is No. 
--//						  If exsiting MC Unit, NULL means keep current setting
--//	
--//  @Sflags		- PTS 59916 - update group flag intblCabUnits
--//						1 set groupflag to 1
--//
--//  @bIgnoreAddressBy		  if 1, we ignore the addressby settings for dispatch Groups
--//						  
--// 3/15/12 - JC - enhancement PTS 59916

SET NOCOUNT ON 

DECLARE @iOldSN Int,
        @iNewMCUnitSN int,
	@iParentSN int,
	@iOutBoxSN int,
	@iInBoxSN int,
	@iDrvMaster int ,
	@TrkMaster int ,
	@iMCMaster int ,
	@iLgnMaster int,
	@iUnitTypeSN int,
	@iMCUnitAddressType int,
	@iOldAddressSN int,
	@iUpdateMCUnitFlag int,
	@iCurrentDispatchGroupSN int,
	@iCurrentTruckSN int,
	@iDefaultMCUnit int,
	@sParentFolderName varchar(50),
	@iMCUnitSNToUse int,
	@iAddressBy int,
	@sT_1 varchar(200),
	@TruckAddressType int,
	--Start PTS #40978
	@SndResInfo int, 
	@Flags int,
	@MCSN int,
	--End PTS #40978
	--Start PTS 59916
	@GroupFlag int,
	@debug int
	--End
	
	Set @debug = 1 -- 1 = on and 0 = off


					-------------------------------------------------------------------
					--DEBUG
					IF @debug > 0 
						SELECT 'Starting Config Unit', @groupflag 
					
					------------------------------------------------------------------
					
					
	Select @SndResInfo = isnull(Text,0)
	From TblRS (NOLOCK)
	Where Keycode = 'SndResInfo'--PTS #40978
------------------ Check Parameters --------------------------

	SELECT @sNewName = ISNULL(@sNewName, '')
	SELECT @sOldName = ISNULL(@sOldName, '')
	SELECT @TruckAddressType = tblAddressTypes.SN 
	FROM tblAddressTypes (NOLOCK) 
	WHERE tblAddressTypes.AddressType = 'T'

	--Do not allow names to match
	IF UPPER(@sNewName) = UPPER(@sOldName) 
		SELECT @sOldName = ''

	--make sure we have a sNewName, should always have one
	if ISNULL(@sNewName, '') > ''
		BEGIN
		
		--see if we can find the sOldName if we have one
		if ISNULL(@sOldName, '') > ''
			BEGIN
			SELECT @iOldSN = sN 
			FROM tblCabUnits (NOLOCK) 
			WHERE UnitID = @sOldName AND LinkedAddrType = @TruckAddressType
			
			--COuld not find the sOldName, can not update, Goodbye
			IF ISNULL(@iOldSN, 0) = 0
				BEGIN
				RAISERROR ('Old name (%s) not found for copy.', 16, 1, @sOldName)
				RETURN
				END

			--make sure the new name does not already exist
			IF EXISTS (SELECT * 
			From tblCabUnits (NOLOCK) 
			WHERE UnitID = @sNewName AND LinkedAddrType = @TruckAddressType)
				BEGIN
				RAISERROR ('Both old name (%s) and new name (%s) already exist.'
					, 16, 1, @sOldName, @sNewName) 
				RETURN
				END

		END
		
		
		END

	--No sNewName, Goodbye
	ELSE
		BEGIN
		RAISERROR ('No new name (%s) to create specified.', 16, 1, @sNewName)
		RETURN
		END
	
	SELECT @iUpdateMCUnitFlag = 0


------------------ now that we passed restrictions, Make sure that we have the Truck --------------------------

--//  Truck

	SELECT @iCurrentTruckSN = SN FROM tblTrucks (NOLOCK) WHERE TruckName = @sCurrentTruck

	--Create Driver if passed in and not already there
	IF ISNULL(@iCurrentTruckSN, 0) = 0 AND ISNULL(@sCurrentTruck, '') > ''

		BEGIN

		EXEC dbo.tm_ConfigTruck @sCurrentTruck ,
			NULL,
			NULL,
			NULL,
			NULL,

			NULL,
			NULL,
			NULL

		SELECT @iCurrentTruckSN = SN 
		FROM tblTrucks (NOLOCK) 
		WHERE TruckName = @sCurrentTruck

		END

------------------ Get Current SNs and addressby --------------------------

	--Get AddressBy from RS (0 Driver, 1 Truck, 2 MC Unit)
	SELECT @iAddressBy = Text 
	FROM tblRS (NOLOCK) 
	WHERE keyCode = 'ADDRESSBY'

	SELECT @iCurrentDispatchGroupSN = NULL

	--try to find the Current Dispatch Group
	IF ISNULL(@sCurrentDispatchGroup, '') > '' AND (@iAddressBy = 2 OR @bIgnoreAddressBy = 1)
		--Get minimum Dispatch Group if <Default> tag passed in
		IF @sCurrentDispatchGroup = '<Default>'
			SELECT @iCurrentDispatchGroupSN = MIN(SN) 
			 FROM tblDispatchGroup (NOLOCK) 
		ELSE
		--Get passed in Dispatch Group SN
			SELECT @iCurrentDispatchGroupSN = SN 
				FROM tblDispatchGroup (NOLOCK)
				WHERE Name = @sCurrentDispatchGroup
	
	--make sure we have a SN if there was a CurrentDispatchGroup passed in
	IF ISNULL(@sCurrentDispatchGroup, '') > '' AND 
		ISNULL(@iCurrentDispatchGroupSN, 0) = 0 AND (@iAddressBy = 2 OR @bIgnoreAddressBy = 1)
		
		BEGIN

		SELECT @sT_1 = 'Dispatch Group not found (%s), if <Default> no dispatch groups defined.'
		EXEC dbo.tm_t_sp @sT_1 out, 0, ''
		RAISERROR (@sT_1, 16, 1, @sCurrentDispatchGroup)
		RETURN

		END

	SELECT @iCurrentTruckSN = NULL

	--try to find the Current Truck
	IF ISNULL(@sCurrentTruck, '') > ''
		SELECT @iCurrentTruckSN = SN 
		FROM tblTrucks (NOLOCK)
		WHERE TruckName = @sCurrentTruck

	--make sure we have a SN if there was a CurrentTruck passed in
	IF ISNULL(@sCurrentTruck, '') > '' AND ISNULL(@iCurrentTruckSN, 0) = 0
		BEGIN
		RAISERROR ('Truck (%s) not found.', 16, 1, @sCurrentTruck)
		RETURN
		END

	IF ISNULL(@sUnitType, '') > ''
		BEGIN

		SELECT @iUnitTypeSN = SN 
		FROM tblMobileCommType (NOLOCK)
		WHERE MobileCommType = @sUnitType
		IF ISNULL(@iUnitTypeSN, 0) = 0
			BEGIN
			RAISERROR ('MC Unit Type (%s) not found.', 16, 1, @sUnitType)
			RETURN
			END

		END
	
------------------ MC Unit record --------------------------

	--if this is not an update, old Name not passed in
	IF ISNULL(@iOldSN, 0) = 0 

		BEGIN

		--see if we already have a record for the MC Unit ID
		SELECT @iOldSN = sN 
		FROM tblCabUnits (NOLOCK)
		WHERE UnitID = @sNewName AND LinkedAddrType = @TruckAddressType

		--Do not have a record for the MC Unit, create one
		IF ISNULL(@iOldSN, 0) = 0 
			BEGIN

			IF ISNULL(@sUnitType, '') = ''
				BEGIN
				RAISERROR ('Unit Type must be passed in for new MC Unit records.', 16, 1)
				RETURN
				END
			
			--PTS 59916 set the groupflag for non comm member group units
			if @SFLAGS & 1 = 1   
				Begin
					set @GroupFlag = 1
					--set @sNewName = 'NONMCNew' 
					----------------------------------------------------------------------------------------
					if @debug > 0 
						select 'setting member group values'
					----------------------------------------------------------------------------------------
				End

				
			--get the retired setting, if null use 0 for No
			SELECT @iRetired  = ISNULL(@iRetired, 0)

			--get the MC Unit Master Folder ID
			exec dbo.tm_GetMasterFolderIDs 0, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out

			--if there is no MC Unit Master Folder ID, use root level
			IF ISNULL(@iMCMaster, 0) = 0
				SELECT @iMCMaster = NULL

			SELECT @sParentFolderName = 'MC Unit: ~1''s Private Folders'
			SELECT @sT_1 = @sParentFolderName
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''
			EXEC dbo.tm_sprint @sT_1 out, @sNewName, '', '', '', '', '', '', '', '', ''
			SELECT  @sParentFolderName = @sT_1

			--Insert the new folders, first owner will be null since we do not know the MC Unit SN yet
			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iMCMaster, @sParentFolderName, NULL, 0)
			Select @iParentSN = @@IDENTITY

			SELECT @sT_1 = 'InBox'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''

			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iParentSN, @sT_1, NULL, 0)
			Select @iInBoxSN = @@IDENTITY

			SELECT @sT_1 = 'OutBox'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''

			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iParentSN, @sT_1, NULL, 0)
			Select @iOutBoxSN = @@IDENTITY

			--Insert MC Unit Profile record
			INSERT INTO tblCabUnits 
				(UnitId, Inbox, OutBox, Type, Truck, CurrentDispatcher, Retired, GroupFlag, LinkedAddrType, LinkedObjSN) 
				VALUES 
				(@sNewName, @iInBoxSN, @iOutBoxSN, @iUnitTypeSN, @iCurrentTruckSN, @iCurrentDispatchGroupSN, @iRetired, @GroupFlag ,@TruckAddressType, @iUnitTypeSN)

			Select @iNewMCUnitSN = @@IDENTITY
			--Start PTS 40978
			Set @Flags = 1
			Set  @MCSN =   @iNewMCUnitSN
			--End PTS 40978

			--PTS 59916 update MCU Name 
			--UPDATE tblCabUnits SET UnitID = 'NONMC' + convert(varchar (12), @iNewMCUnitSN, 1) WHERE SN = @iNewMCUnitSN 
			--END
			
			--update the Parent folder to the MC Unit folder SN
			UPDATE tblFolders SET Owner = @iNewMCUnitSN WHERE SN = @iParentSN

			--set general MC Unit SN variable
			SELECT @iMCUnitSNToUse = @iNewMCUnitSN

			--if we were unable to create a MC Unit Master, this is the first MC Unit, try it again and update the new record
			if ISNULL(@iMCMaster, 0) = 0 
				exec dbo.tm_GetMasterFolderIDs 1, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out


			END

		ELSE
		--we have a record for the new MC Unit ID, update it
			SELECT @iUpdateMCUnitFlag = -1

		END

	--Update MC UNIT ID, old name passed in and found or MC Unit record already existed
	ELSE
		SELECT @iUpdateMCUnitFlag = -1

	
	--if we are to update the MC Unit record
	if @iUpdateMCUnitFlag = -1
		BEGIN

		SELECT @sParentFolderName = 'MC Unit: ~1''s Private Folders'
		SELECT @sT_1 = @sParentFolderName
		EXEC dbo.tm_t_sp @sT_1 out, 0, ''
		EXEC dbo.tm_sprint @sT_1 out, @sNewName, '', '', '', '', '', '', '', '', ''
		SELECT  @sParentFolderName = @sT_1

		--Get the Inbox SN
	        SELECT @iInBoxSN = Inbox 
	        FROM tblCabUnits (NOLOCK) 
	        WHERE SN = @iOldSN

		--if a iRetired was not passed in, keep it the same as the old one
		IF ISNULL(@iRetired, -1) = -1
			SELECT @iRetired = Retired 
			FROM tblCabUnits (NOLOCK) 
			WHERE sn = @iOldSN

		--set the new MC Unit ID and retired setting
		UPDATE tblCabUnits SET UnitID = @sNewName, Retired = @iRetired, Type = CASE WHEN ISNULL(@iUnitTypeSN, 0) > 0 THEN @iUnitTypeSN ELSE Type END
                WHERE SN = @iOldSN
		--Start PTS #40978
		Set  @Flags  = 2	
		Set  @MCSN =   @iOldSN
		--End PTS #40978

		--if a new Current Dispatch Group was passed in, set it
		IF ISNULL(@iCurrentDispatchGroupSN, 0) > 0 OR @sCurrentDispatchGroup = ''
			IF @sCurrentDispatchGroup = ''
				UPDATE tblCabUnits SET CurrentDispatcher = NULL WHERE SN = @iOldSN
			ELSE
				UPDATE tblCabUnits SET CurrentDispatcher = @iCurrentDispatchGroupSN WHERE SN = @iOldSN

		--Update tblFolders name with new name
	        UPDATE tblFolders 
			SET Name = @sParentFolderName 
			WHERE SN = (SELECT Parent from tblFolders (NOLOCK) WHERE SN = @iInBoxSN)

		--set general MC Unit SN variable
		SELECT @iMCUnitSNToUse = @iOldSN

		END

------------------ Update Current Truck --------------------------

	--if we have a Default Cab Unit SN, set it up
	IF ISNULL(@iCurrentTruckSN, 0) > 0 OR @sCurrentTruck = ''
		BEGIN

		--Remove this MCT as default - will put correct default in later
        	UPDATE tblTrucks SET DefaultCabUnit = Null WHERE DefaultCabUnit = @iMCUnitSNToUse
	        UPDATE tblCabUnits SET Truck = null, LinkedObjSN = NULL WHERE SN = @iMCUNitSNToUse
		
		--if we were not told to remove the Default cab unit only
		IF @sCurrentTruck <> ''
			BEGIN

	                UPDATE tblCabUnits SET Truck = @iCurrentTruckSN WHERE SN = @iMCUnitSNToUse
            
		        --Check if this truck has another MCT set as the default
		        SELECT @iDefaultMCUnit = tblTrucks.DefaultCabUnit
		            	FROM tblCabUnits (NOLOCK)
            			INNER JOIN tblTrucks (NOLOCK)
            			ON tblTrucks.DefaultCabUnit = tblCabUnits.SN
            			WHERE tblTrucks.SN = @iCurrentTruckSN
			
			IF ISNULL(@iDefaultMCUnit, 0) <> 0

				--Another MCT is currently the default MCT for this truck				
				IF @iDefaultMCUnit <> @iMCUNitSNToUse 

		                        --Resolve default MC Unit dilemma

					BEGIN

					IF ISNULL(@iCurrentMCUnitDefaultLevel, 0) = 0
						SELECT @iCurrentMCUnitDefaultLevel = 1

					--Add as co-MC Unit
					IF @iCurrentMCUnitDefaultLevel = 1 
						--Don't have to do anything

					-- Slipseat
					IF @iCurrentMCUnitDefaultLevel = 2

						BEGIN

					        --Make New MCT the default in tblTrucks
						UPDATE tblTrucks
        	    					SET DefaultCabUnit = @iMCUnitSNToUse
            						WHERE SN = @iCurrentTruckSN
	
						--Remove MCT from old default MCT in tblCabUnits
            					UPDATE tblCabUnits
							SET Truck = NULL, LinkedObjSN = NULL
							WHERE Truck = @iCurrentTruckSN AND SN <> @iMCUnitSNToUse

						END

					-- Make lead MC Unit					
					IF @iCurrentMCUnitDefaultLevel = 3
						BEGIN
										
					        --Make New MCT the default in tblTrucks
						UPDATE tblTrucks
							SET DefaultCabUnit = @iMCUnitSNToUse
							WHERE SN = @iCurrentTruckSN

					        --Make sure that the old default MCT still has truck as the Truck in tblCabUnit
						UPDATE tblCabUnits
							SET Truck = @iCurrentTruckSN, LinkedObjSN = @iCurrentTruckSN
							WHERE SN = @iMCUnitSNToUse
					
						END
					END

			ELSE

				--No default MCT for this truck yet, so make this MCT the default

				UPDATE tblTrucks
				SET DefaultCabUnit = @iMCUnitSNToUse
				WHERE SN = @iCurrentTruckSN
				

			END
		
		END

------------------ Addresses record --------------------------

	--tblAddresses Record Insert
	IF ISNULL(@iOldSN, 0) = 0
		BEGIN
		
		--find the tblAddresses SN for MC Unit type 
		SELECT @iMCUnitAddressType = SN 
		FROM tblAddressTypes (NOLOCK) 
		WHERE AddressType = 'C'
		
		--get the Resolve setting, if null use 1 if resolve by MC Unit, 0 if anything else
		IF ISNULL(@iUseToResolve, -1) = -1
			IF @iAddressBy = 2
				SELECT @iUseToResolve = 1
			ELSE
				SELECT @iUseToResolve = 0
		print @sNewName
		--Insert the Address record
		INSERT INTO tblAddresses 
			(AddressBookSN, AddressType, Inbox, Outbox, AddressName, UseInResolve) 
			VALUES (NULL, @iMCUnitAddressType, @iInBoxSN, @iOutBoxSN, @sNewName, @iUseToResolve)
		END
	--tblAddresses Record Update
	ELSE
		BEGIN
			--Get the Inbox SN
	        SELECT @iInBoxSN = Inbox 
	        FROM tblCabUnits (NOLOCK) 
	        WHERE SN = @iMCUnitSNToUse

		--find the old tblAddresses record
		SELECT @iOldAddressSN = SN 
		FROM tblAddresses (NOLOCK) 
		WHERE Inbox = @iInBoxSN

		--if a iUseToResolve was not passed in keep it the same as the old one
		IF ISNULL(@iUseToResolve, -1) = -1
			SELECT @iUseToResolve = UseInResolve 
			FROM tblAddresses (NOLOCK) 
			WHERE Inbox = @iInBoxSN

		--update the tblAddress record
		UPDATE tblAddresses SET AddressName = @sNewName, UseInResolve = @iUseToResolve WHERE SN = @iOldAddressSN

		END

	--Start PTS #40978
	if @SndResInfo = 1 
		Exec tm_TriggerResourceMessage @MCSN,'Mcu',@Flags,@sOldName
	--End PTS #40978
	
---Return Truck SN and Cab SN PTS 59916
	If @SFLAGS & 1 = 1
		Begin
			---------------------------------------------------------
			if @debug > 0 
				select 'tm_configMCu2 conmpleted', @iNewMCUnitSN
			--------------------------------------------------------
		End 
--End

GO
GRANT EXECUTE ON  [dbo].[tm_ConfigMCUnit2] TO [public]
GO
