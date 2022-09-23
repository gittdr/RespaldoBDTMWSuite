SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[tm_ConfigDriver2] @sNewName varchar(50),
				@sOldName varchar(50),
				@sEmailAltID varchar(50),
				@sPOP3Login varchar(60),				-- pts 84270
				@sNewDispatchSystemID varchar(50),
				@sCurrentDispatchGroup varchar(50),
				@sCurrentTruck varchar(50),
				@iCurrentDriverDefaultLevel int,
				@iRetired int,
				@iUseToResolve int,
				@bIgnoreAddressBy BIT = 0

AS

/* 09/30/11 PTS 57988 DWG - Respect Dispatch ID as the main lookup.
	02/19/2013 PTS 67506 JC 
 */

--//  @sNewName					- Driver to Add or new name for a Driver already existing
--//  @sOldname					- Driver name to update to new name (@NewName)
--//  @sNewDispatchSystemID			- Dispatch System ID for Driver. 
--//						  If NULL for new Driver records, then @sNewName will be used.
--//						  IF NOT NULL it will be used as the primary lookup
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
--//  @iCurrentDriverDefaultLevel 		- 1 Co Driver (Default)
--//						- 2 Slip Seat
--//						- 2 Make Leader Driver
--//
--//  @iRetired					- Is the Driver Retired
--//						  0 or No, 1 for Yes. If a new Driver. NULL is No. 
--//						  If exsiting Driver, NULL means keep current setting
--//
--//  @iUseToResolve				- Should the Driver be used in auto resolution
--//						  0 or No, 1 for Yes. 
--//						  If a new Driver. NULL is based on the Default Addressee type in Configuration.
--//						  If exsiting Driver, NULL means keep current setting
--//
--//  @bIgnoreAddressBy		  if 1, we ignore the addressby settings for dispatch Groups
--//						  else we only set up dispatch groups for driver if are driver based
--//

SET NOCOUNT ON 

DECLARE @iOldSN Int,
        @iNewDriverSN int,
	@iParentSN int,
	@iOutBoxSN int,
	@iInBoxSN int,
	@iDrvMaster int ,
	@TrkMaster int ,
	@iMCMaster int ,
	@iLgnMaster int,
	@iDriverAddressType int,
	@iOldAddressSN int,
	@iUpdateDriverFlag int,
	@iCurrentDispatchGroupSN int,
	@iCurrentTruckSN int,
	@iDefaultDriver int,
	@sParentFolderName varchar(50),
	@iDriverSNToUse int,
	@iAddressBy int,
	@iUseAdminMailBox int,
	@sT_1 varchar(200),
	--Start PTS #40978
	@SndResInfo int, 
	@Flags int,
	@DriverSN int
	--End PTS #40978

	Select @SndResInfo = isnull(Text,0) 
	From TblRS (NOLOCK)
	Where Keycode = 'SndResInfo'--PTS #40978

------------------ Check Parameters --------------------------

	SELECT @sNewName = ISNULL(@sNewName, '')
	SELECT @sOldName = ISNULL(@sOldName, '')
	SELECT @sNewDispatchSystemID = ISNULL(@sNewDispatchSystemID, '')

	--Do not allow names to match
	IF UPPER(@sNewName) = UPPER(@sOldName) 
		SELECT @sOldName = ''

	if ISNULL(@sNewDispatchSystemID, '') > ''
		BEGIN
			--see if the new DispatchID belongs to 
			IF EXISTS (SELECT * 
			FROM tblDrivers (NOLOCK)
			WHERE DispSysDriverID = @sNewDispatchSystemID)
				BEGIN
					SELECT @iOldSN = SN 
					FROM tblDrivers (NOLOCK)
					WHERE DispSysDriverID = @sNewDispatchSystemID
					IF ISNULL(@sOldName, '') > '' 
						IF @sOldName <> (SELECT Name 
						FROM tblDrivers (NOLOCK)
						WHERE DispSysDriverID = @sNewDispatchSystemID)
							BEGIN
							RAISERROR ('Old name does not match Driver Name in TotalMail (Dispatch ID lookup).', 16, 1, @sOldName)
							RETURN
							END
				END
						
		END

	--If we did not find the Dispatch ID in TotalMail make sure we have a sNewName, should always have one
	IF ISNULL(@iOldSN, 0) = 0
	BEGIN
		if ISNULL(@sNewName, '') > ''
			BEGIN
			
			--see if we can find the sOldName if we have one
			if ISNULL(@sOldName, '') > ''
				BEGIN
				SELECT @iOldSN = SN 
				FROM tblDrivers (NOLOCK)
				WHERE Name = @sOldName
				
				--COuld not find the sOldName, can not update, Goodbye
				IF ISNULL(@iOldSN, 0) = 0
					BEGIN
					RAISERROR ('Old name (%s) not found for copy.', 16, 1, @sOldName)
					RETURN
					END

				--make sure the new name does not already exist
				IF EXISTS (SELECT * 
							From tblDrivers (NOLOCK)
							WHERE Name = @sNewName)
					BEGIN
					RAISERROR ('Both old name (%s) and new name (%s) already exist.', 
						16, 1, @sOldName, @sNewName) 
					RETURN
					END

				END
			ELSE

				BEGIN
				
				--A dispatch ID must be specified or @NewName will be used
				IF NOT EXISTS (SELECT * 
								FROM tblDrivers (NOLOCK)
								WHERE Name = @sNewName)
					IF ISNULL(@sNewDispatchSystemID, '') = ''
						SELECT @sNewDispatchSystemID = @sNewName			

				--see if the new DispatchID belongs to 
				IF EXISTS (SELECT * 
							FROM tblDrivers (NOLOCK)
							WHERE DispSysDriverID = @sNewDispatchSystemID)
					--check to see if the Dispatch System belongs to the Driver Sent in
					IF UPPER((SELECT Name 
								FROM tblDrivers (NOLOCK)
							WHERE DispSysDriverID = @sNewDispatchSystemID)) <> UPPER(@sNewName)

						BEGIN
						RAISERROR ('Dispatch ID (%s) already exists.', 16, 1, @sNewDispatchSystemID) 
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

	END
	
	SELECT @iUpdateDriverFlag = 0

  --rwolfe PTS 101107, make sure the name is unique, append DispID
  IF EXISTS (
		  SELECT *
		  FROM tblDrivers
		  WHERE NAME = @sNewName
        AND DispSysDriverID <> @sNewDispatchSystemID
		  ) AND @sOldName = ''
  BEGIN
	  SET @sNewName = Left(@sNewName + '(' + @sNewDispatchSystemID + ')', 50)
  END
  
------------------ Get Current SNs and addressby --------------------------

	--Get AddressBy from RS (0 Driver, 1 Truck, 2 MC Unit)
	SELECT @iAddressBy = Text 
	FROM tblRS (NOLOCK)
	WHERE keyCode = 'ADDRESSBY'

	SELECT @iCurrentDispatchGroupSN = NULL

	--try to find the Current Dispatch Group
	IF ISNULL(@sCurrentDispatchGroup, '') > '' AND (@iAddressBy = 0 OR @bIgnoreAddressBy = 1)
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
	IF ISNULL(@sCurrentDispatchGroup, '') > '' AND ISNULL(@iCurrentDispatchGroupSN, 0) = 0 AND (@iAddressBy = 0 OR @bIgnoreAddressBy = 1)
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



------------------ now that we passed restrictions, Make sure that we have the Truck --------------------------

BEGIN TRAN

--//  Truck

	--Create Truck if passed in and not already there
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


------------------ Driver record --------------------------

	--if this is not an update, old Name not passed in
	IF ISNULL(@iOldSN, 0) = 0 AND ISNULL(@sNewDispatchSystemID, '') <> ''

		BEGIN

		if ISNULL(@sNewDispatchSystemID, '') = ''
			--see if we already have a record for the Driver Name
			SELECT @iOldSN = sN 
			FROM tblDrivers (NOLOCK)
			WHERE Name = @sNewName 

		--Do not have a record for the Driver, create one
		IF ISNULL(@iOldSN, 0) = 0 
			BEGIN

			--get the retired setting, if null use 0 for No
			SELECT @iRetired  = ISNULL(@iRetired, 0)
			SELECT @sEmailAltID = ISNULL(@sEmailAltID, '')
			SELECT @sPOP3Login = ISNULL(@sPOP3Login, '')

			--get the Driver Master Folder ID
			exec dbo.tm_GetMasterFolderIDs 0, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out
			
			--if there is no Driver Master Folder ID, use root level
			IF ISNULL(@iDrvMaster, 0) = 0
				SELECT @iDrvMaster = NULL

			SELECT @sParentFolderName = 'Driver: ~1''s Private Folders'
			SELECT @sT_1 = @sParentFolderName
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''
			EXEC dbo.tm_sprint @sT_1 out, @sNewName, '', '', '', '', '', '', '', '', ''
			SELECT  @sParentFolderName = @sT_1

			--Insert the new folders, first owner will be null since we do not know the Driver SN yet
			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) 
				VALUES (@iDrvMaster, @sParentFolderName, NULL, 0)

			Select @iParentSN = @@IDENTITY

			SELECT @sT_1 = 'InBox'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''

			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iParentSN, @sT_1, NULL, 0)
			Select @iInBoxSN = @@IDENTITY

			SELECT @sT_1 = 'OutBox'
			EXEC dbo.tm_t_sp @sT_1 out, 0, ''

			INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) VALUES (@iParentSN, @sT_1, NULL, 0)
			Select @iOutBoxSN = @@IDENTITY

			SELECT @iUseAdminMailBox = 0
			
			--if only alternate ID is filled and not POP3 lOgin then it is a ADMIN inbox
			IF @sEmailAltID > '' AND @sPOP3Login = ''
				SELECT @iUseAdminMailBox = 1

			--Insert Driver Profile record
			INSERT INTO tblDrivers 
				(Name, 
				 DispSysDriverId, 
				 Inbox, 
				 OutBox, 
				 MAPIProfile,
				 AlternateID,
				 UseAdminMailBox,
				 InternetMailToDriver, 
				 InternetMailFromDriver, 
				 CurrentTruck, 
				 CurrentDispatcher, 
				 Retired, 
				 KeepHistory) 
		  	 VALUES (@sNewName, 
			  	 @sNewDispatchSystemID,
				 @iInBoxSN,
				 @iOutBoxSN,
				 @sPOP3Login,
				 @sEmailAltID,
				 @iUseAdminMailBox,
				 0, 
				 0, 
				 @iCurrentTruckSN, 
				 @iCurrentDispatchGroupSN, 
				 @iRetired, 
				 1)

			Select @iNewDriverSN = @@IDENTITY
			--Start PTS 40978
			Set @Flags = 1
			Set  @DriverSN =   @iNewDriverSN
			--End PTS 40978

			--update the Parent folder to the Driver folder SN
			UPDATE tblFolders SET Owner = @iNewDriverSN WHERE SN = @iParentSN

			--set general Driver SN variable
			SELECT @iDriverSNToUse = @iNewDriverSN

			--if we were unable to create a Driver Master, this is the first Driver, try it again and update the new record
			if ISNULL(@iDrvMaster, 0) = 0 
				exec dbo.tm_GetMasterFolderIDs 1, @iDrvMaster out, @TrkMaster out, @iMCMaster out, @iLgnMaster out


			END

		ELSE
		--we have a record for the new Driver name, update it
			SELECT @iUpdateDriverFlag = -1

		END

	--Update Driver Name, old name passed in and found or Driver record already existed
	ELSE
		SELECT @iUpdateDriverFlag = -1

	
	--if we are to update the Driver record
	if @iUpdateDriverFlag = -1
		BEGIN

		SELECT @sParentFolderName = 'Driver: ~1''s Private Folders'
		SELECT @sT_1 = @sParentFolderName
		EXEC dbo.tm_t_sp @sT_1 out, 0, ''
		EXEC dbo.tm_sprint @sT_1 out, @sNewName, '', '', '', '', '', '', '', '', ''
		SELECT  @sParentFolderName = @sT_1

		--Get the Inbox SN
	        SELECT @iInBoxSN = Inbox 
	        FROM tblDrivers (NOLOCK)
	        WHERE SN = @iOldSN

		--if a iRetired was not passed in, keep it the same as the old one
		IF ISNULL(@iRetired, -1) = -1
			SELECT @iRetired = Retired 
			FROM tblDrivers (NOLOCK)
			WHERE sn = @iOldSN

		--if a new Dispatch System ID was not passed in, keep it the same as the old one
		IF ISNULL(@sNewDispatchSystemID, '') = '' 
			SELECT @sNewDispatchSystemID = DispSysDriverId 
			FROM tblDrivers (NOLOCK)
			WHERE SN = @iOldSN

		--if a new POP3 Login ID was not passed in, keep it the same as the old one
		IF ISNULL(@sPOP3Login, '-1') = '-1' 
			SELECT @sPOP3Login = MAPIProfile 
			FROM tblDrivers (NOLOCK)
			WHERE SN = @iOldSN

		--if a new Alternamte ID was not passed in, keep it the same as the old one
		IF ISNULL(@sEmailAltID, '-1') = '-1' 
			SELECT @sEmailAltID = AlternateID 
			FROM tblDrivers (NOLOCK)
			WHERE SN = @iOldSN

		--Check to see if we need old UseAdminMailBox
		IF ISNULL(@sEmailAltID, '') > '' AND ISNULL(@sPOP3Login, '') = ''
			SELECT @iUseAdminMailBox = 1
		ELSE
			IF ISNULL(@sPOP3Login, '') > '' AND ISNULL(@sEmailAltID, '') = ''
				SELECT @iUseAdminMailBox = 0
			ELSE
				SELECT @iUseAdminMailBox = UseAdminMailBox 
				FROM tblDrivers (NOLOCK)
				WHERE SN = @iOldSN

		--set the new Driver name and retired setting
		UPDATE tblDrivers 
			SET Name = @sNewName, 
		   	    Retired = @iRetired, 
			    DispSysDriverId = @sNewDispatchSystemID, 
			    MAPIProfile = @sPOP3Login, 
			    AlternateID = @sEmailAltID, 
			    UseAdminMailBox = @iUseAdminMailBox
			WHERE SN = @iOldSN

			--Start PTS 40978
			Set @Flags = 2
			Set  @DriverSN =   @iOldSN
			--End PTS 40978
		
		--if a new Current Dispatch Group was passed in, set it
		IF ISNULL(@iCurrentDispatchGroupSN, 0) > 0 OR @sCurrentDispatchGroup = ''
			IF @sCurrentDispatchGroup = ''
				UPDATE tblDrivers 
					SET CurrentDispatcher = NULL WHERE SN = @iOldSN
			ELSE
				UPDATE tblDrivers 
					SET CurrentDispatcher = @iCurrentDispatchGroupSN WHERE SN = @iOldSN

		--Update tblFolders name with new name
	        UPDATE tblFolders 
			SET Name = @sParentFolderName 
			WHERE SN = (SELECT Parent 
						FROM tblFolders (NOLOCK) WHERE SN = @iInBoxSN)

		--set general Driver SN variable
		SELECT @iDriverSNToUse = @iOldSN

		END

------------------ Update Current Truck --------------------------

	--if we have a default Truck SN, set it up
	IF ISNULL(@iCurrentTruckSN, 0) > 0 OR ISNULL(@sCurrentTruck, '') = ''
		BEGIN

	        --Remove selected Current Truck from any other truck it might be default on
			--Begin PTS 67506
	        UPDATE tblTrucks SET DefaultDriver = Null WHERE SN = (select CurrentTruck from tblDrivers where Name = @sNewName)   -- DefaultDriver = @iDriverSNToUse
			--End PTS 67506
			UPDATE tblDrivers SET CurrentTruck = NULL WHERE SN = @iDriverSNToUse
		
		--if we were not told to remove the Default cab unit only
		IF ISNULL(@sCurrentTruck, '') <> ''
			BEGIN

			UPDATE tblDrivers SET CurrentTruck = @iCurrentTruckSN WHERE SN = @iDriverSNToUse

		        --Check if this truck has another driver set as the default
		        SELECT @iDefaultDriver = tblTrucks.DefaultDriver 
			   FROM tblDrivers (NOLOCK)
			   INNER JOIN tblTrucks (NOLOCK) ON tblTrucks.DefaultDriver = tblDrivers.SN 
			   WHERE tblTrucks.SN = @iCurrentTruckSN


			IF ISNULL(@iDefaultDriver, 0) <> 0

				--See if Another driver is currently the default driver for this truck
				IF @iDefaultDriver <> @iDriverSNToUse 

		                    	--Resolve default driver dilemma

					BEGIN

					IF ISNULL(@iCurrentDriverDefaultLevel, 0) = 0
						SELECT @iCurrentDriverDefaultLevel = 1

					--Add as co-driver
					IF @iCurrentDriverDefaultLevel = 1 
						--Don't have to do anything

					-- Slipseat
					IF @iCurrentDriverDefaultLevel = 2

						BEGIN

					        -- Make New driver the default in tblTrucks
				            	UPDATE tblTrucks 
							SET DefaultDriver = @iDriverSNToUse 
							WHERE SN = @iCurrentTruckSN
	
					        --Remove truck from old default driver in tblDriver
				            	UPDATE tblDrivers 
							SET CurrentTruck = NULL 
							WHERE CurrentTruck = @iCurrentTruckSN AND SN <> @iDriverSNToUse

						END

					-- Make lead driver					
					IF @iCurrentDriverDefaultLevel = 3
						BEGIN
										
					        --Make New driver the default in tblTrucks
						UPDATE tblTrucks 
							SET DefaultDriver = @iDriverSNToUse WHERE SN = @iCurrentTruckSN

					        UPDATE tblDrivers 
							SET CurrentTruck = @iCurrentTruckSN WHERE SN = @iDefaultDriver
					
						END
					END

			ELSE

				--No default driver for this truck yet, so make this driver the default
	                	UPDATE tblTrucks SET DefaultDriver = @iDriverSNToUse
		                WHERE SN = @iCurrentTruckSN
				

			END
		
		END

------------------ Addresses record --------------------------

	--tblAddresses Record Insert
	IF ISNULL(@iOldSN, 0) = 0
		BEGIN

		--find the tblAddresses SN for Driver type 
		SELECT @iDriverAddressType = SN 
		FROM tblAddressTypes (NOLOCK)
		WHERE AddressType = 'D'

		--get the Resolve setting, if null use 1 if resolve by Driver, 0 if anything else
		IF ISNULL(@iUseToResolve, -1) = -1
			IF @iAddressBy = 0			
				SELECT @iUseToResolve = 1
			ELSE
				SELECT @iUseToResolve = 0

		--Insert the Address record
		INSERT INTO tblAddresses 
			(AddressBookSN, AddressType, Inbox, Outbox, AddressName, UseInResolve) 
			VALUES (NULL, @iDriverAddressType, @iInBoxSN, @iOutBoxSN, @sNewName, @iUseToResolve)

		END

	--tblAddresses Record Update
	ELSE
		BEGIN
	
		--Get the Inbox SN
	        SELECT @iInBoxSN = Inbox 
	        FROM tblDrivers (NOLOCK)
	        WHERE SN = @iDriverSNToUse

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
		UPDATE tblAddresses 
			SET AddressName = @sNewName, UseInResolve = @iUseToResolve 
			WHERE SN = @iOldAddressSN

		END

	--Start PTS #40978
	if @SndResInfo = 1 
		Exec tm_TriggerResourceMessage @DriverSN,'Drv',@Flags,@sOldName
	--End PTS #40978

COMMIT TRAN
GO
GRANT EXECUTE ON  [dbo].[tm_ConfigDriver2] TO [public]
GO
