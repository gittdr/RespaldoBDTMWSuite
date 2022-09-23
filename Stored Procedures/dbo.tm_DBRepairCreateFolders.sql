SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_DBRepairCreateFolders]   @Parent int,				
												@FolderToCreate varchar(8),	-- Parent, Inbox, Outbox, Deleted, Sent
												@ResourceName varchar (50),
												@ResourceType varchar (7),	-- Truck, Driver, MC Unit, Login, Group (dispatch group)
												@FolderAdded int OUT

AS
SET NOCOUNT ON

DECLARE	@iParentSN int,
		@sT_1 varchar(25),
		@iLoginAddressType int,
		@iOwner int,			-- If it's a login folder, we need the owner (the SN from tblLogin)
		@SQL nvarchar(1000),
		@TableName varchar(25),
		@FieldName varchar(15),
		@FolderName varchar(50)		

SET @FolderAdded = 0
SET @iOwner = 0

-- Only need the Owner in tblFolders for logins
IF (@ResourceType = 'Login')
	SELECT @iOwner = ISNULL(SN, 0)
	FROM tblLogin (NOLOCK)
	WHERE LoginName = @ResourceName	

IF (@FolderToCreate = 'Parent')
  BEGIN
	IF (@ResourceType = 'Truck')
		SET @FolderName = 'Truck: ' + REPLACE(@ResourceName, '''', '''''') + '''' + 's Private Folders' 
	ELSE IF (@ResourceType = 'Driver')
		SET @FolderName = 'Driver: ' + REPLACE(@ResourceName, '''', '''''') + '''' + 's Private Folders' 
	ELSE IF (@ResourceType = 'MC Unit')
		SET @FolderName = 'MC Unit: ' + REPLACE(@ResourceName, '''', '''''') + '''' + 's Private Folders' 
	ELSE IF (@ResourceType = 'Server')
	  BEGIN
		IF (LEFT(@ResourceName, 1) = 'T')
			IF LTRIM(DATALENGTH(@ResourceName)) = 1
				SET @FolderName = 'Transaction Folder' 
			ELSE
				SET @FolderName = 'Transaction Folder' + SUBSTRING(@ResourceName, 2, 7)
		ELSE IF (@ResourceName = 'M')
			SET @FolderName = 'MAPI Folder' 
		ELSE IF (@ResourceName = 'C')
			SET @FolderName = 'Comm Folder' 
		ELSE IF (@ResourceName = 'P')
			SET @FolderName = 'Purge Work' 
        ELSE 
			SET @FolderName = 'Unknown Folder for Server Type (' + @ResourceName + ')'
	  END
	ELSE  -- Login
		SET @FolderName = @ResourceName

	-- Assets parent folder
	INSERT INTO tblFolders (Parent, Name, Owner, IsPublic) 
	VALUES (@Parent, @FolderName, @iOwner, 0)

	SELECT @FolderAdded = @@IDENTITY		-- We'll return this to the calling proc
  END
ELSE
  BEGIN
	SET @ResourceName = REPLACE(@ResourceName, '''', '''''')  --Set single quotes to double for string below
	-- Inbox, Outbox, Deleted, Sent
	IF (@ResourceType = 'Group')	
	  BEGIN
		-- Dispatch group has no parent, just an inbox
		SET @FolderName = 'Group: ' + @ResourceName + '''' + 's Inbox' 

		-- The parent will come in as -1, and we want null
		SET @Parent = null
	  END
	ELSE
		SET @FolderName = @FolderToCreate

	SELECT @sT_1 = @FolderName
	EXEC tm_t_sp @sT_1 OUT, 0, ''

	INSERT INTO tblFolders (Parent, Name, Owner, IsPublic) 
	VALUES (@Parent, @sT_1, @iOwner, 0)

	SELECT @FolderAdded = @@IDENTITY		

	-- Update tblAddresses
	IF (@ResourceType <> 'Server')		-- Server resources aren't in tblAddresses
	  BEGIN
		IF (@FolderToCreate = 'Inbox' OR @FolderToCreate = 'Outbox')
		  BEGIN
			SET @SQL =  'UPDATE tblAddresses' +
		  	 			' SET ' + @FolderToCreate + ' = ' + CONVERT(varchar(10),@FolderAdded) + 
						' FROM tblAddresses, tblAddressTypes' + 
						' WHERE AddressName = ' + '''' + @ResourceName + '''' +
							' AND tblAddressTypes.SN = tblAddresses.AddressType' + 
							' AND tblAddressTypes.Description = ' + '''' + CONVERT(varchar(12),@ResourceType) + ''''
			EXEC sp_executesql @sql
		  END
	  END

	-- Update tblDrivers, tblTrucks, tblCabUnits, tblLogin, tblDispatchGroup, tblServer
	IF (@ResourceType = 'Login')
	  BEGIN
		SET @TableName = 'tblLogin'
		SET @FieldName = 'LoginName'
	  END
	ELSE IF (@ResourceType = 'Driver')
	  BEGIN
		SET @TableName = 'tblDrivers'
		SET @FieldName = 'Name'
	  END
	ELSE IF (@ResourceType = 'Truck')
	  BEGIN
		SET @TableName = 'tblTrucks'
		SET @FieldName = 'TruckName'
	  END
	ELSE IF (@ResourceType = 'MC Unit')
	  BEGIN
		SET @TableName = 'tblCabUnits'
		SET @FieldName = 'UnitID'
	  END
	ELSE IF (@ResourceType = 'Group')
	  BEGIN
		SET @TableName = 'tblDispatchGroup'
		SET @FieldName = 'Name'
	  END
	ELSE IF (@ResourceType = 'Server')
	  BEGIN
		SET @TableName = 'tblServer'
		SET @FieldName = 'ServerCode'
	  END

	SET @SQL =  'UPDATE ' + @TableName + 
				' SET ' + @FolderToCreate + ' = ' + CONVERT(varchar(10),@FolderAdded) + 
				' WHERE ' + @FieldName + ' = ' + '''' + @ResourceName + '''' 
	EXEC sp_executesql @sql

	-- If this is the Admin login, update tblServer as well
	IF (@ResourceType = 'Login' AND @ResourceName = 'Admin')
	  BEGIN
		SET @SQL =  'UPDATE tblServer' +
					' SET ' + @FolderToCreate + ' = ' + CONVERT(varchar(10),@FolderAdded) + 
					' WHERE ServerCode = ''A''' 
		EXEC sp_executesql @sql
	  END
  END
GO
GRANT EXECUTE ON  [dbo].[tm_DBRepairCreateFolders] TO [public]
GO
