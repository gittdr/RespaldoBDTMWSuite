SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[tm_GetMasterFolderIDs] @UpdateFlag int,
					@DrvMaster int output,
					@TrkMaster int output,
					@MCMaster int output,
					@LgnMaster int output
AS

--  ***** Add Master Truck, Master Driver, Master MCT Unit to tblfolders

SET NOCOUNT ON

DECLARE @BadFolder int
IF @UpdateFlag <> 0
	BEGIN
	SELECT @BadFolder = MIN(SN) FROM tblFolders WHERE SN = Parent
	IF ISNULL(@BadFolder, 0) > 0
		BEGIN
		RAISERROR ('The system has detected a Folder loop.  Folder %d is it''s own parent.  This will cause infinite loops and crashes.  Please contact TMW Support.', 16, 1, @BadFolder)
		RETURN
		END
	END

-- Driver Master
SELECT @DrvMaster = 0
SELECT @DrvMaster = MIN(b.Parent)
FROM tblFolders a (NOLOCK), tblFolders b (NOLOCK), tblDrivers (NOLOCK) 
WHERE a.Parent = b.SN 
  AND a.SN = tblDrivers.Inbox 
  AND ISNULL(b.Parent, 0) > 0

IF ISNULL(@DrvMaster,0) = 0 AND EXISTS (SELECT * FROM tblDrivers)
  BEGIN
	SELECT @DrvMaster = MIN(SN) 
		FROM tblFolders (NOLOCK)
		WHERE Name = 'Driver Master' 
		AND Parent IS NULL 
		AND NOT EXISTS (SELECT * 
						FROM tblFolders C (nolock)
						WHERE C.Parent = tblFolders.SN)
	IF ISNULL(@DrvMaster,0) = 0 AND @UpdateFlag <> 0
		BEGIN
		INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) Values (NULL, 'Driver Master', NULL, 0)
		SELECT @DrvMaster = @@IDENTITY
		END
  END

-- Truck Master
SELECT @TrkMaster = 0
SELECT @TrkMaster = MIN(b.Parent)
FROM tblFolders a (NOLOCK), tblFolders b (NOLOCK), tblTrucks(NOLOCK)
WHERE a.Parent = b.SN 
  AND a.SN = tblTrucks.Inbox 
  AND ISNULL(b.Parent, 0) > 0
IF ISNULL(@TrkMaster,0) = 0 AND EXISTS (SELECT * FROM tblTrucks)
  BEGIN
	SELECT @TrkMaster = MIN(SN) 
		FROM tblFolders (NOLOCK)
		WHERE Name = 'Truck Master' 
		AND Parent IS NULL 
		AND NOT EXISTS (SELECT * FROM tblFolders C WHERE C.Parent = tblFolders.SN)
	IF ISNULL(@TrkMaster,0) = 0 AND @UpdateFlag <> 0
	  BEGIN
		INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) Values (NULL, 'Truck Master', NULL, 0)
		SELECT @TrkMaster = @@IDENTITY
	  END
  END

-- MCT Master
SELECT @MCMaster = 0
SELECT @MCMaster = MIN(b.Parent)
FROM tblFolders a (NOLOCK), tblFolders b (NOLOCK), tblCabUnits (NOLOCK)
WHERE a.Parent = b.SN 
  AND a.SN = tblCabUnits.Inbox 
  AND ISNULL(b.Parent, 0) > 0
IF NOT ISNULL(@MCMaster,0) > 0 AND EXISTS (SELECT * FROM tblCabUnits (NOLOCK) )
  BEGIN
	SELECT @MCMaster = MIN(SN) 
		FROM tblFolders (NOLOCK)
		WHERE Name = 'MC Unit Master' 
		AND Parent IS NULL 
		AND NOT EXISTS (SELECT * FROM tblFolders C WHERE C.Parent = tblFolders.SN)
	IF ISNULL(@MCMaster,0) = 0 AND @UpdateFlag <> 0
	  BEGIN
		INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) Values (NULL, 'MC Unit Master', NULL, 0)
		SELECT @MCMaster = @@IDENTITY
	  END
  END

-- Login Master
SELECT @LgnMaster = 0
SELECT @LgnMaster = MIN(b.Parent)
FROM tblFolders a (NOLOCK), tblFolders b (NOLOCK), tblLogin (NOLOCK) 
WHERE a.Parent = b.SN 
  AND a.SN = tblLogin.Inbox 
  AND ISNULL(b.Parent, 0) > 0
IF NOT ISNULL(@LgnMaster,0) > 0 AND EXISTS (SELECT * FROM tblLogin WHERE LoginName <> 'Admin')
  BEGIN
	SELECT @LgnMaster = MIN(SN) 
		FROM tblFolders (NOLOCK)
		WHERE Name = 'Login Master' 
		AND Parent IS NULL 
		AND NOT EXISTS (SELECT * FROM tblFolders C WHERE C.Parent = tblFolders.SN)
	IF ISNULL(@LgnMaster,0) = 0 AND @UpdateFlag <> 0
	  BEGIN
		INSERT INTO tblfolders (Parent, Name, Owner, IsPublic) Values (NULL, 'Login Master', NULL, 0)
		SELECT @LgnMaster = @@IDENTITY
	  END
  END

if @UpdateFlag = 1 
begin
	-- Now point all driver, tractor, MCT folders to their respective parent (eg Truck Master)
	UPDATE tblFolders SET Parent = @DrvMaster WHERE SN IN (SELECT Parent FROM tblFolders F, tblDrivers E WHERE F.SN = E.Inbox)
	UPDATE tblFolders SET Parent = @TrkMaster WHERE SN IN (SELECT Parent FROM tblFolders F, tblTrucks E WHERE F.SN = E.Inbox)
	UPDATE tblFolders SET Parent = @MCMaster WHERE SN IN (SELECT Parent FROM tblFolders F, tblCabUnits E WHERE F.SN = E.Inbox)
	-- If Admin is put into Login Master, things get very confusing.  All other users can be put in, but not admin.
	UPDATE tblFolders SET Parent = @LgnMaster WHERE SN IN (SELECT Parent FROM tblFolders F, tblLogin E WHERE F.SN = E.Inbox and E.LoginName <> 'Admin')
	UPDATE tblFolders SET Parent = NULL WHERE SN IN (SELECT Parent FROM tblFolders F, tblLogin E WHERE F.SN = E.Inbox and E.LoginName = 'Admin')
end

GO
GRANT EXECUTE ON  [dbo].[tm_GetMasterFolderIDs] TO [public]
GO
