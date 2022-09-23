SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_DbRepair_MasterFolder] @FolderName varchar(25),	-- Login, Driver, Truck, MC Unit Master
											  @Keycode as varchar(10), 	-- tblRS keycode for this master folder
											  @Error varchar(254) OUT,  -- Error string returned from this process
											  @Master int OUT			-- The SN for this master folder

AS


SET NOCOUNT ON 

DECLARE @Kount int,
		@TempSN int

SET @Error = ''
SET @Kount = 0
SET @Master = 0
SET @TempSN = 0

-- Count how many master folder entries we have
SELECT @Kount = COUNT(*) 
FROM tblFolders (NOLOCK)
WHERE ISNULL(Parent, -1) = -1 		-- It's a root level folder
	AND Name = @FolderName

IF (@Kount = 0)
  -- No master folder with specified name, need to create it
  BEGIN
	-- Log that no master folder was found
	SET @Error = 'No ' + @FolderName + ' folder found.  Created one.'

	INSERT INTO tblFolders (Parent, Name, Owner, IsPublic) 
	VALUES (NULL, @FolderName, NULL, 0)

	SELECT @Master = @@IDENTITY	
  END
ELSE IF (@Kount = 1) 
	-- Only one master folder with specified name, so just get the tblFolders SN
	SELECT @Master = SN 
	FROM tblFolders (NOLOCK)
	WHERE ISNULL(Parent, -1) = -1 
		AND Name = @FolderName
ELSE IF (@Kount > 1)
  -- More than one master with specified name, find correct one
  BEGIN
	-- Log number of bad folders
	SET @Error = 'Found ' + CONVERT(varchar(5),@Kount) + ' ' + @FolderName + ' folders. Removed all but one.'

	-- Check if there is an entry in tblRS pointing to a supposedly valid master folder.
	SELECT @TempSN = ISNULL(text, 0) 
	FROM tblRS (NOLOCK)
	WHERE keycode = @Keycode

	IF (@TempSN <> 0) 
		-- We already have a master folder in tblRS
		-- Check if it's valid (exists in tblFolders, is root level and is called @FolderName)
		IF (EXISTS (SELECT SN 
					FROM tblFolders (NOLOCK)
					WHERE SN = @TempSN AND ISNULL(Parent, -1) = -1 AND Name = @FolderName))
			SET @Master = @TempSN	

	IF (@Master = 0)	-- We haven't found one yet, so just grab a valid one with the lowest SN
		SELECT @Master = MIN(SN)
		FROM tblFolders (NOLOCK)
		WHERE ISNULL(Parent, -1) = -1 
			AND Name = @FolderName
  END

-- Now insert/update the record into tblRS
IF EXISTS (SELECT text 
			FROM tblRS (NOLOCK)
			WHERE keycode = @Keycode)
	UPDATE tblRS 
	SET text = @Master
	WHERE keycode = @Keycode
ELSE
	INSERT INTO tblRS (Keycode, Text, Description) 
	VALUES (@Keycode, @Master, @FolderName + ' folder tblFolders SN')
GO
GRANT EXECUTE ON  [dbo].[tm_DbRepair_MasterFolder] TO [public]
GO
