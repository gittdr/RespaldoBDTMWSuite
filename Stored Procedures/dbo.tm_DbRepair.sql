SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_DbRepair] @TMWSuiteSvr varchar(30) = NULL,
								 @TMWSuiteDB varchar(30) = NULL

AS

/***********************************************************
1) Find valid master folders and write to tblRS
2) Assign all assets to master folders in tblRS
3) Delete any invalid master folders
4) Check for assets of the same kind with the same name (exit app if occurs)
5) Detect/repair missing asset folders
6) List duplicate folders with the same name
7) Update Driver/Tractor relationships from TMWSuite tractorprofile
8) List Trucks in TotalMail, not in TMWSuite
9) List Trucks in TMWSuite, not in TotalMail
10) List Drivers in TotalMail, not in TMWSuite
11) List Drivers in TMWSuite, not in TotalMail
12) List Trucks in TotalMail with no DispSysId
13) List Drivers in TotalMail with no DispSysId
14) List MCTS that are not assigned to a tractor
15) List tractors/drivers not assigned to a dispatch group (depends on TotalMail AddressBy setting)
***********************************************************/
SET NOCOUNT ON

DECLARE @DrvMaster int,
		@TrcMaster int,
		@MCTMaster int,
		@LoginMaster int,
		@Error varchar(254),
		@Temp int,
		@Temp1 int,
		@Inbox int,
		@Outbox int,
		@Deleted int,
		@Sent int,
		@Working int,
		@Parent int,
		@Asset varchar(50),
		@AssetType varchar(10),
		@Master int,
		@NewFolder int,
		@TableName varchar(20),
		@FieldName varchar(20),
		@SQL nvarchar(1000),
		@Dup int,
		@Kount int,
		@Name varchar(50),
		@ParentSN int,
		@ParentName varchar(255),
		@SN int,
		@FolderName varchar(50),
		@Err int,
		@TMWDBErr varchar(255),
		@RealTMWSuiteSvr varchar(30),
		@RealTMWSuiteDB varchar(30)

CREATE TABLE #Results  (SN int IDENTITY, 	
						Section varchar(50),
						Description varchar(254),
						Status varchar(25))

CREATE TABLE #MissingFolders (mfSN int IDENTITY,
							  AssetName varchar(50),
							  AssetType varchar(10),	
							  SN int,
							  Inbox int,
							  Outbox int,
							  Deleted int,
							  Sent int,
							  Working int,
							  Parent int)

CREATE TABLE #Dups (SN int IDENTITY,
					Kount int,
					AssetName varchar(50),
					Processed smallint)

CREATE TABLE #DupFolders   (SN int IDENTITY,
							Kount int,
							FolderName varchar(50),
							ParentSN int)

CREATE TABLE #OrphanedMsgs (SN int IDENTITY,
							MsgSN int)

CREATE TABLE #Count (RecordCount int)

SET NOCOUNT ON 

SET @DrvMaster = 0
SET @TrcMaster = 0
SET @MCTMaster = 0
SET @LoginMaster = 0
SET @Error = ''

--remove brackets around server and db name for later lookup 
IF LEFT(LTRIM(@TMWSuiteSvr), 1) = '[' AND RIGHT(RTRIM(@TMWSuiteSvr), 1) = ']'
	BEGIN
		SET @RealTMWSuiteSvr = SUBSTRING(RTRIM(LTRIM(@TMWSuiteSvr)), 2, 30)
		SET @RealTMWSuiteSvr = LEFT(@RealTMWSuiteSvr, DATALENGTH(@RealTMWSuiteSvr)-1)
	END
IF LEFT(LTRIM(@TMWSuiteDB), 1) = '[' AND RIGHT(RTRIM(@TMWSuiteDB), 1) = ']'
	BEGIN
		SET @RealTMWSuiteDB = SUBSTRING(RTRIM(LTRIM(@TMWSuiteDB)), 2, 30)
		SET @RealTMWSuiteDB = LEFT(@RealTMWSuiteDB, DATALENGTH(@RealTMWSuiteDB)-1)
	END


/********************************************************/
/********** Write Master folder SN's to tblRS ***********/
/********************************************************/
/***** Login master *****/
EXEC dbo.tm_DbRepair_MasterFolder 'Login Master', 'MastrLgnSN', @Error OUT, @LoginMaster OUT
IF (@Error <> '') 
  BEGIN
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Master folder check', @Error, 'Repaired')	

	SET @Error = ''
  END

/***** Driver master *****/
EXEC dbo.tm_DbRepair_MasterFolder 'Driver Master', 'MastrDrvSN', @Error OUT, @DrvMaster OUT
IF (@Error <> '') 
  BEGIN
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Master folder check', @Error, 'Repaired')	

	SET @Error = ''
  END

/***** Truck master *****/
EXEC dbo.tm_DbRepair_MasterFolder 'Truck Master', 'MastrTrcSN', @Error OUT, @TrcMaster OUT
IF (@Error <> '') 
  BEGIN
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Master folder check', @Error, 'Repaired')	

	SET @Error = ''
  END

/***** MC Unit master *****/
EXEC dbo.tm_DbRepair_MasterFolder 'MC Unit Master', 'MastrMCTSN', @Error OUT, @MCTMaster OUT
IF (@Error <> '') 
  BEGIN
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Master folder check', @Error, 'Repaired')	

	SET @Error = ''
  END

/****************************************************************/
/********** Assign all assets to tblRS master folders ***********/
/****************************************************************/
-- Logins (Admin should be at root level, so don't reset, 
--  but will reset any login named Admin that's inbox is not in tblServer (should never happen))
SET @Temp = 0
SELECT @Temp = COUNT(*) 
FROM tblLogin (NOLOCK), tblFolders f1 (NOLOCK), tblFolders f2 (NOLOCK)
WHERE tblLogin.Inbox = f1.SN
	AND f1.Parent = f2.SN
	AND f2.Parent <> @LoginMaster
	AND tblLogin.Inbox NOT IN (SELECT Inbox FROM tblServer WHERE ServerCode = 'A')
IF (@Temp > 0)
  BEGIN
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Login master folder reset', CONVERT(varchar(6),@Temp) + ' login(s) linked to wrong login master.', 'Repaired')	

	UPDATE f2
	SET f2.Parent = @LoginMaster
	FROM tblFolders f1 (NOLOCK), tblFolders f2 (NOLOCK), tblLogin(NOLOCK), tblServer(NOLOCK)
	WHERE tblLogin.Inbox = f1.SN
		AND f1.Parent = f2.SN
		AND tblLogin.Inbox NOT IN (SELECT Inbox FROM tblServer WHERE ServerCode = 'A')
  END

-- Make sure the real Admin logins parent is the root
UPDATE f2
SET f2.Parent = null
FROM tblFolders f1 (NOLOCK), tblFolders f2 (NOLOCK), tblLogin (NOLOCK), tblServer (NOLOCK)
WHERE tblLogin.Inbox = f1.SN
	AND f1.Parent = f2.SN
	AND tblLogin.Inbox IN (SELECT Inbox FROM tblServer WHERE ServerCode = 'A')

-- Drivers
SET @Temp = 0
SELECT @Temp = COUNT(*) 
FROM tblDrivers (NOLOCK), tblFolders f1 (NOLOCK), tblFolders f2 (NOLOCK)
WHERE tblDrivers.Inbox = f1.SN
	AND f1.Parent = f2.SN
	AND f2.Parent <> @DrvMaster
IF (@Temp > 0)
  BEGIN
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Driver master folder reset', CONVERT(varchar(6),@Temp) + ' driver(s) linked to wrong driver master.', 'Repaired')	

	UPDATE f2
	SET f2.Parent = @DrvMaster
	FROM tblFolders f1 (NOLOCK), tblFolders f2 (NOLOCK), tblDrivers (NOLOCK)
	WHERE tblDrivers.Inbox = f1.SN
		AND f1.Parent = f2.SN
		AND f2.Parent <> @DrvMaster
  END

-- Trucks
SET @Temp = 0
SELECT @Temp = COUNT(*) 
FROM tblTrucks (NOLOCK), tblFolders f1 (NOLOCK), tblFolders f2 (NOLOCK)
WHERE tblTrucks.Inbox = f1.SN
	AND f1.Parent = f2.SN
	AND f2.Parent <> @TrcMaster
IF (@Temp > 0)
  BEGIN
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Truck master folder reset', CONVERT(varchar(6),@Temp) + ' truck(s) linked to wrong truck master.', 'Repaired')	

	UPDATE f2
	SET f2.Parent = @TrcMaster
	FROM tblFolders f1 (NOLOCK), tblFolders f2 (NOLOCK), tblTrucks (NOLOCK)
	WHERE tblTrucks.Inbox = f1.SN
		AND f1.Parent = f2.SN
		AND f2.Parent <> @TrcMaster
  END

-- MC Units
SET @Temp = 0
SELECT @Temp = COUNT(*) 
FROM tblCabUnits (NOLOCK), tblFolders f1 (NOLOCK), tblFolders f2 (NOLOCK)
WHERE tblCabUnits.Inbox = f1.SN
	AND f1.Parent = f2.SN
	AND f2.Parent <> @MCTMaster
IF (@Temp > 0)
  BEGIN
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('MC Unit master folder reset', CONVERT(varchar(6),@Temp) + ' MCT(s) linked to wrong MC Unit master.', 'Repaired')	
		
	UPDATE f2
	SET f2.Parent = @MCTMaster
	FROM tblFolders f1 (NOLOCK), tblFolders f2 (NOLOCK), tblCabUnits (NOLOCK)
	WHERE tblCabUnits.Inbox = f1.SN
		AND f1.Parent = f2.SN
		AND f2.Parent <> @MCTMaster
  END

/****************************************************/
/********** Delete invalid master folders ***********/
/****************************************************/
DELETE tblFolders
WHERE Name IN ('Login Master', 'Driver Master', 'Truck Master', 'MC Unit Master')
	AND ISNULL(Parent, -1) = -1
	AND SN NOT IN (@LoginMaster, @DrvMaster, @TrcMaster, @MCTMaster)

/********************************************************/
/********** Check if there are any assets of ************/
/**********  the same kind with the same name ***********/
/**********  If there are, exit the routine **************/
/********************************************************/
-- Logins
INSERT INTO #Dups (Kount, AssetName, Processed)
SELECT COUNT(LoginName) Kount, LoginName, 0 FROM tblLogin GROUP BY LoginName ORDER BY Kount DESC

DELETE #Dups WHERE Kount = 1

SET @Temp = 0
SELECT @Temp = ISNULL(MIN(SN), 0)
FROM #Dups
WHILE @Temp > 0
  BEGIN
	SELECT  @Asset = REPLACE(AssetName, '''', ''''''),
			@Kount = Kount
	FROM #Dups
	WHERE SN = @Temp

	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Duplicate Asset Names', CONVERT(varchar(5), @Kount) + ' logins with name: ' + @Asset, 'CRITICAL: Manually Repair')	

	SELECT @Temp = ISNULL(MIN(SN), 0)
	FROM #Dups
	WHERE SN > @Temp
  END
UPDATE #Dups
SET Processed = 1

-- Trucks
INSERT INTO #Dups (Kount, AssetName, Processed)
SELECT COUNT(TruckName) Kount, TruckName, 0 FROM tblTrucks (NOLOCK) GROUP BY TruckName ORDER BY Kount DESC

DELETE #Dups WHERE Kount = 1

SET @Temp = 0
SELECT @Temp = ISNULL(MIN(SN), 0)
FROM #Dups
WHERE Processed = 0
WHILE @Temp > 0
  BEGIN
	SELECT  @Asset = REPLACE(AssetName, '''', ''''''),
			@Kount = Kount
	FROM #Dups
	WHERE SN = @Temp

	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Duplicate Asset Names', CONVERT(varchar(5), @Kount) + ' trucks with ID: ' + @Asset, 'CRITICAL: Manually Repair')	

	SELECT @Temp = ISNULL(MIN(SN), 0)
	FROM #Dups
	WHERE SN > @Temp
		AND Processed = 0
  END
UPDATE #Dups
SET Processed = 1

-- Drivers
INSERT INTO #Dups (Kount, AssetName, Processed)
SELECT COUNT(Name) Kount, Name, 0 FROM tblDrivers GROUP BY Name ORDER BY Kount DESC

DELETE #Dups WHERE Kount = 1

SET @Temp = 0
SELECT @Temp = ISNULL(MIN(SN), 0)
FROM #Dups
WHERE Processed = 0
WHILE @Temp > 0
  BEGIN
	SELECT  @Asset = REPLACE(AssetName, '''', ''''''),
			@Kount = Kount
	FROM #Dups
	WHERE SN = @Temp

	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Duplicate Asset Names', CONVERT(varchar(5), @Kount) + ' drivers with name: ' + @Asset, 'CRITICAL: Manually Repair')	

	SELECT @Temp = ISNULL(MIN(SN), 0)
	FROM #Dups
	WHERE SN > @Temp
		AND Processed = 0
  END
UPDATE #Dups
SET Processed = 1

-- MCTs
IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
		WHERE a.name = 'LinkedAddrType'
			AND a.id = b.id 
			AND b.name = 'tblCabUnits')
				--if we have the new fields, we need to add the Addr Type (Driver, Trailer, or Truck) to the grouping
				--  but the field may not exist, we need to protect against an error by doing dynamic SQL
				EXEC ('INSERT INTO #Dups (Kount, AssetName, Processed)
				SELECT COUNT(UnitID) Kount, UnitID, 0 FROM tblCabUnits GROUP BY UnitID, LinkedAddrType ORDER BY Kount DESC')
else
				INSERT INTO #Dups (Kount, AssetName, Processed)
				SELECT COUNT(UnitID) Kount, UnitID, 0 FROM tblCabUnits (NOLOCK) GROUP BY UnitID ORDER BY Kount DESC

DELETE #Dups WHERE Kount = 1

SET @Temp = 0
SELECT @Temp = ISNULL(MIN(SN), 0)
FROM #Dups
WHERE Processed = 0
WHILE @Temp > 0
  BEGIN
	SELECT  @Asset = REPLACE(AssetName, '''', ''''''),
			@Kount = Kount
	FROM #Dups
	WHERE SN = @Temp

	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Duplicate Asset Names', CONVERT(varchar(5), @Kount) + ' MCTs with ID: ' + @Asset, 'CRITICAL: Manually Repair')	

	SELECT @Temp = ISNULL(MIN(SN), 0)
	FROM #Dups
	WHERE SN > @Temp
		AND Processed = 0
  END
UPDATE #Dups
SET Processed = 1

-- Dispatch Groups
INSERT INTO #Dups (Kount, AssetName)
SELECT COUNT(Name) Kount, Name FROM tblDispatchGroup (NOLOCK) GROUP BY Name ORDER BY Kount DESC

DELETE #Dups WHERE Kount = 1

SET @Temp = 0
SELECT @Temp = ISNULL(MIN(SN), 0)
FROM #Dups
WHERE Processed = 0
WHILE @Temp > 0
  BEGIN
	SELECT  @Asset = REPLACE(AssetName, '''', ''''''),
			@Kount = Kount
	FROM #Dups
	WHERE SN = @Temp

	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Duplicate Asset Names', CONVERT(varchar(5), @Kount) + ' dispatch groups with name: ' + @Asset, 'CRITICAL: Manually Repair')	

	SELECT @Temp = ISNULL(MIN(SN), 0)
	FROM #Dups
	WHERE SN > @Temp
		AND Processed = 0
  END

IF EXISTS (SELECT SN FROM #Dups) 
  BEGIN
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Duplicate Asset Names', 'Repair process prematurely terminated because of critial error. Manually repair the duplicates, then rerun the repair tool.', 'CRITICAL')		

	SELECT * From #Results order by SN
	RETURN 1	
  END

/****************************************************/
/********** Detect/Repair missing folders ***********/
/****************************************************/
-- NOTE: If all of an assets folders have been deleted except for the parent, we won't find the
--		  parent, but will create another parent with the same name, leaving the original parent
--		  orphaned (should not cause problems).

-- Get info from all assets into a temp table
-- We'll delete records that have no folder problems
INSERT INTO #MissingFolders (AssetName, AssetType, SN, Inbox, Outbox, Deleted, Sent, Working, Parent)
SELECT LoginName, 'Login', SN, Inbox, Outbox, Deleted, Sent, -1, -1
FROM tblLogin (NOLOCK)

INSERT INTO #MissingFolders (AssetName, AssetType, SN, Inbox, Outbox, Deleted, Sent, Working, Parent)
SELECT Name, 'Driver', SN, Inbox, Outbox, -1, -1, -1, -1
FROM tblDrivers (NOLOCK)

INSERT INTO #MissingFolders (AssetName, AssetType, SN, Inbox, Outbox, Deleted, Sent, Working, Parent)
SELECT TruckName, 'Truck', SN, Inbox, Outbox, -1, -1, -1, -1
FROM tblTrucks (NOLOCK)

INSERT INTO #MissingFolders (AssetName, AssetType, SN, Inbox, Outbox, Deleted, Sent, Working, Parent)
SELECT UnitID, 'MC Unit', SN, Inbox, Outbox, -1, -1, -1, -1
FROM tblCabUnits (NOLOCK)

INSERT INTO #MissingFolders (AssetName, AssetType, SN, Inbox, Outbox, Deleted, Sent, Working, Parent)
SELECT Name, 'Group', SN, Inbox, -1, -1, -1, -1, -1
FROM tblDispatchGroup (NOLOCK)

INSERT INTO #MissingFolders (AssetName, AssetType, SN, Inbox, Outbox, Deleted, Sent, Working, Parent)
SELECT ServerCode, 'Server', SN, Inbox, Outbox, -1, -1, ISNULL(Working,0), -1
FROM tblServer (NOLOCK)
WHERE (ServerCode <> 'A'		-- Don't need to process admin here, it's handled with the logins
  AND NOT ServerCode like 'T%' --Don't check dynamic Msg Balancing Codes
  AND NOT ServerCode like 'DT%')
  OR ServerCode = 'T'

-- Update working folder for server records to -1, except the Transaction agent
UPDATE #MissingFolders
SET Working = -1
WHERE AssetType = 'Server'
	AND AssetName <> 'T'

-- Try to find the Parent record from inbox, outbox, deleted, sent & working matches
UPDATE #MissingFolders
SET Parent = f2.SN
FROM #MissingFolders, tblFolders f1, tblFolders f2
WHERE #MissingFolders.Inbox = f1.SN
	AND f1.Parent = f2.SN

UPDATE #MissingFolders
SET Parent = f2.SN
FROM #MissingFolders, tblFolders f1, tblFolders f2
WHERE #MissingFolders.Outbox = f1.SN
	AND f1.Parent = f2.SN
	AND #MissingFolders.Parent = -1

UPDATE #MissingFolders
SET Parent = f2.SN
FROM #MissingFolders, tblFolders f1, tblFolders f2 
WHERE #MissingFolders.Deleted = f1.SN
	AND f1.Parent = f2.SN
	AND #MissingFolders.Parent = -1

UPDATE #MissingFolders
SET Parent = f2.SN
FROM #MissingFolders, tblFolders f1, tblFolders f2 
WHERE #MissingFolders.Sent = f1.SN
	AND f1.Parent = f2.SN
	AND #MissingFolders.Parent = -1

UPDATE #MissingFolders
SET Parent = f2.SN
FROM #MissingFolders, tblFolders f1 , tblFolders f2 
WHERE #MissingFolders.Working = f1.SN
	AND f1.Parent = f2.SN
	AND #MissingFolders.Parent = -1

-- Now start marking records that we have valid data for
UPDATE #MissingFolders
SET Inbox = -1
FROM #MissingFolders, tblFolders 
WHERE #MissingFolders.Inbox = tblFolders.SN

UPDATE #MissingFolders
SET Outbox = -1
FROM #MissingFolders, tblFolders 
WHERE #MissingFolders.Outbox = tblFolders.SN

UPDATE #MissingFolders
SET Deleted = -1
FROM #MissingFolders, tblFolders 
WHERE #MissingFolders.Deleted = tblFolders.SN

UPDATE #MissingFolders
SET Sent = -1
FROM #MissingFolders, tblFolders 
WHERE #MissingFolders.Sent = tblFolders.SN

UPDATE #MissingFolders
SET Working = -1
FROM #MissingFolders, tblFolders 
WHERE #MissingFolders.Working = tblFolders.SN

-- Now delete all records that don't have folder problems (won't catch dispatch group records)
DELETE #MissingFolders
WHERE Inbox = -1
	AND Outbox = -1
	AND Deleted = -1
	AND Sent = -1
	AND Working = -1
	AND Parent <> -1

-- Delete valid dispatch groups (they only have an inbox)
DELETE #MissingFolders
WHERE Inbox = -1
	AND AssetType = 'Group'

-- Now start fixing the folders
-- -1 for the parent indicates that the parent is missing
-- -1 for other boxes indicates that it is OK
SET @Temp = 0
SELECT @Temp = ISNULL(MIN(mfSN), 0)
FROM #MissingFolders
WHILE @Temp > 0
  BEGIN
	SELECT  @Asset = REPLACE(AssetName, '''', ''''''),
			@AssetType = AssetType,
			@Inbox = Inbox,
			@Outbox = Outbox,
			@Deleted = Deleted,
			@Sent = Sent,
			@Working = Working,
			@Parent = Parent
	FROM #MissingFolders
	WHERE mfSN = @Temp

	-- Insert problems into log
	IF (@Parent = -1 AND @AssetType <> 'Group')	-- Dispatch Groups don't have a parent folder, just an inbox, which is handled in the inbox section
	  BEGIN
		INSERT INTO #Results (Section, Description, Status) 
		VALUES ('Detect/Repair missing folders', @AssetType + ' ' + @Asset + ' parent folder not found', 'Repaired')	

		IF (@AssetType = 'Login') 
		  BEGIN
			SET @Master = @LoginMaster
			SET @TableName = 'tblLogin'
			SET @FieldName = 'LoginName'
		  END
		ELSE IF (@AssetType = 'Truck') 
		  BEGIN
			SET @Master = @TrcMaster
			SET @TableName = 'tblTrucks'
			SET @FieldName = 'TruckName'
		  END
		ELSE IF (@AssetType = 'Driver') 
		  BEGIN
			SET @Master = @DrvMaster
			SET @TableName = 'tblDrivers'
			SET @FieldName = 'Name'
		  END
		ELSE IF (@AssetType = 'MC Unit') 
		  BEGIN
			SET @Master = @MCTMaster		
			SET @TableName = 'tblCabUnits'
			SET @FieldName = 'UnitID'
		  END
		ELSE IF (@AssetType = 'Server') 
		  BEGIN
			SET @Master = null		
			SET @TableName = 'tblServer'
			SET @FieldName = 'ServerCode'
		  END

		EXEC dbo.tm_DBRepairCreateFolders @Master, 'Parent', @Asset, @AssetType, @Parent OUT

		-- We have a parent now, see if there are any children that need associated with it in tblFolders
		IF (@Inbox = -1)
		  BEGIN
			SET @SQL =  'UPDATE tblFolders' + 
						' SET Parent = ' + CONVERT(varchar(20),@Parent) + 
						' WHERE SN = (SELECT Inbox FROM ' + @TableName + ' WHERE ' + @FieldName + ' = ' + '''' + @Asset + '''' + ')'
			EXEC sp_executesql @SQL
		  END

		IF (@Outbox = -1)
		  BEGIN
			SET @SQL =  'UPDATE tblFolders' + 
						' SET Parent = ' + CONVERT(varchar(20),@Parent) + 
						' WHERE SN = (SELECT Outbox FROM ' + @TableName + ' WHERE ' + @FieldName + ' = ' + '''' + @Asset + '''' + ')'
			EXEC sp_executesql @SQL
		  END

		-- Logins & Servers are the only assets that have deleted & sent boxes
		IF (@AssetType = 'Login' OR @AssetType = 'Server') 				
		  BEGIN
			IF (@Deleted = -1 AND (@AssetType = 'Login' OR (@AssetType = 'Server' AND @Asset = 'A')))	-- Only do for Admin login and other logins
			  BEGIN
				SET @SQL =  'UPDATE tblFolders' + 
							' SET Parent = ' + CONVERT(varchar(25),@Parent) + 
							' WHERE SN = (SELECT Deleted FROM ' + @TableName + ' WHERE ' + @FieldName + ' = ' + '''' + @Asset + '''' + ')'
				EXEC sp_executesql @SQL
			  END

			IF (@Sent = -1 AND (@AssetType = 'Login' OR (@AssetType = 'Server' AND @Asset = 'A')))    -- Only do for Admin login and other logins
			  BEGIN
				SET @SQL =  'UPDATE tblFolders' + 
							' SET Parent = ' + CONVERT(varchar(25),@Parent) + 
							' WHERE SN = (SELECT Sent FROM ' + @TableName + ' WHERE ' + @FieldName + ' = ' + '''' + @Asset + '''' + ')'
				EXEC sp_executesql @SQL
			  END

			IF (@Working = -1 AND @AssetType = 'Server' AND @Asset = 'T')  -- Only do for Transaction agent
			  BEGIN
				SET @SQL =  'UPDATE tblFolders' + 
							' SET Parent = ' + CONVERT(varchar(20),@Parent) + 
							' WHERE SN = (SELECT Working FROM tblServer WHERE ServerCode = ' + '''' + 'T' + '''' + ')'
				EXEC sp_executesql @SQL
			  END
		  END  
	  END

	IF (@Inbox <> -1)
	  BEGIN
		INSERT INTO #Results (Section, Description, Status) 
		VALUES ('Detect/Repair missing folders', @AssetType + ' ' + @Asset + ' inbox folder not found', 'Repaired')	

		EXEC dbo.tm_DBRepairCreateFolders @Parent, 'Inbox', @Asset, @AssetType, @NewFolder OUT
	  END


	IF (@Outbox <> -1)
	  BEGIN
		INSERT INTO #Results (Section, Description, Status) 
		VALUES ('Detect/Repair missing folders', @AssetType + ' ' + @Asset + ' outbox folder not found', 'Repaired')	

		EXEC dbo.tm_DBRepairCreateFolders @Parent, 'Outbox', @Asset, @AssetType, @NewFolder OUT
	  END

	IF (@Deleted <> -1)
	  BEGIN
		INSERT INTO #Results (Section, Description, Status) 
		VALUES ('Detect/Repair missing folders', @AssetType + ' ' + @Asset + ' deleted folder not found', 'Repaired')	

		EXEC dbo.tm_DBRepairCreateFolders @Parent, 'Deleted', @Asset, @AssetType, @NewFolder OUT
	  END

	IF (@Sent <> -1)
	  BEGIN
		INSERT INTO #Results (Section, Description, Status) 
		VALUES ('Detect/Repair missing folders', @AssetType + ' ' + @Asset + ' sent folder not found', 'Repaired')	

		EXEC dbo.tm_DBRepairCreateFolders @Parent, 'Sent', @Asset, @AssetType, @NewFolder OUT
	  END

	IF (@Working <> -1)	-- drivers, trucks, logins will be -1, servers will be 0 except for Transaction agent
	  BEGIN
		INSERT INTO #Results (Section, Description, Status) 
		VALUES ('Detect/Repair missing folders', @AssetType + ' ' + @Asset + ' working folder not found', 'Repaired')	

		EXEC dbo.tm_DBRepairCreateFolders @Parent, 'Working', @Asset, @AssetType, @NewFolder OUT
	  END

	SELECT @Temp = ISNULL(MIN(mfSN), 0)
	FROM #MissingFolders
	WHERE mfSN > @Temp
  END

/**************************************************/
/********** Check for duplicate folders ***********/
/********** with the same name ********************/
/**************************************************/
/** If you are told to manually repair folders in this section.
 	it means that there were either no valid folders with this name,
	or more than one.  

	To be valid, a folder must either have a child, be a Group folder which
	has no children, or have messages assigned to it.  The parent must not 
    be the same.
**/

INSERT INTO #DupFolders (Kount, FolderName, ParentSN)
SELECT COUNT(a.Name) kount, a.Name, a.Parent
	FROM tblFolders a (NOLOCK)
	WHERE a.Name NOT IN ('Inbox', 'Outbox', 'Sent', 'Deleted', 'Working') 
	GROUP BY a.Name, a.Parent
	ORDER BY Kount

-- Delete all entries that don't have duplicates
DELETE #DupFolders 
WHERE Kount = 1

IF EXISTS (SELECT * FROM #DupFolders) 
  BEGIN
	SET @Temp = 0
	SELECT @Temp = ISNULL(MIN(SN), 0)
	FROM #DupFolders
	WHILE @Temp > 0
	  BEGIN	
		SELECT  @Kount = Kount,
				@Name = REPLACE(FolderName, '''', ''''''),
				@ParentSN = ParentSN
		FROM #DupFolders
		WHERE SN = @Temp

		SET @ParentName = ''
		WHILE ISNULL(@ParentSN, 0) > 0 
		BEGIN
			SELECT @FolderName = Name FROM tblFolders WHERE SN = @ParentSN
		
			IF @ParentName = ''
				SET @ParentName = @FolderName
			ELSE
				SET @ParentName = @FolderName + '/' + @ParentName 
		
			SELECT @ParentSN = Parent FROM tblFolders WHERE SN = @ParentSN
		END
		IF @ParentName > ''
			SET @ParentName = ' ' + @ParentName
		SET @ParentName = REPLACE(@ParentName, '''', '''''')

		INSERT INTO #Results (Section, Description, Status) 
		VALUES ('Check for duplicate folders.',CONVERT(varchar(5),@Kount) + @ParentName + ' folders named: ' + @Name + '. ' , 'CRITICAL: Manually repair')	

		SELECT @Temp = ISNULL(MIN(SN), 0)
		FROM #DupFolders
		WHERE SN > @Temp	
	  END
  END

/**************************************************/
/********** Check for missing linked parents ******/
/**************************************************/
/** If you are told to manually repair folders in this section.
 	it means that there were child folders linked to parent folders,
	that did not exist.  

	To be valid, a folder must either have a child, be a Group folder which
	has no children, or have messages assigned to it.
**/

DELETE #DupFolders
INSERT INTO #DupFolders (Kount, FolderName, ParentSN)
SELECT 1, NAME, 0 FROM tblFolders a 
	WHERE NOT EXISTS (SELECT Name FROM tblFolders b WHERE a.parent = b.sn) AND NOT a.parent IS NULL

IF EXISTS (SELECT * FROM #DupFolders) 
  BEGIN
	SET @Temp = 0
	SELECT @Temp = ISNULL(MIN(SN), 0)
	FROM #DupFolders
	WHILE @Temp > 0
	  BEGIN	
		SELECT @Name = REPLACE(FolderName, '''', '''''')
		FROM #DupFolders
		WHERE SN = @Temp

		INSERT INTO #Results (Section, Description, Status) 
		VALUES ('Check for child folders with missing parents.','A folder named: ' + @Name + ' is linked to a missing parent folder. ' , 'CRITICAL: Manually repair')	

		SELECT @Temp = ISNULL(MIN(SN), 0)
		FROM #DupFolders
		WHERE SN > @Temp	
	  END
  END


/**************************************************/
/********** Check for orphaned history messages****/
/**************************************************/
/** Messages that have no History Driver to Truck SN
 	will be deleted from the datbase since the user
	can not see them anyway.

**/

INSERT INTO #OrphanedMsgs (MsgSN)
SELECT MsgSN FROM tblHistory h WHERE 
	NOT EXISTS (SELECT * FROM tblTrucks t (NOLOCK) WHERE h.TruckSN = t.SN)
	AND NOT EXISTS (SELECT * FROM tblDrivers d (NOLOCK) WHERE h.DriverSN = d.SN)

SET @Kount = 0
IF EXISTS (SELECT * FROM #OrphanedMsgs) 
  BEGIN
	SET @Temp = 0
	SELECT @Temp = ISNULL(MIN(SN), 0)
	FROM #OrphanedMsgs
	WHILE @Temp > 0
	  BEGIN	
		SELECT @SN = MsgSN
		FROM #OrphanedMsgs
		WHERE SN = @Temp
		
		EXEC dbo.tm_KillMsg @SN

		SELECT @Temp = ISNULL(MIN(SN), 0)
		FROM #OrphanedMsgs
		WHERE SN > @Temp	

		SET @Kount = @Kount + 1 --Just to make sure we are accurate
	  END

	  INSERT INTO #Results (Section, Description, Status) 
 	  VALUES ('Orphaned messages deleted.', convert(varchar(3), @Kount) + ' orphaned messages have been removed from history. ' , 'Repaired')	

  END

/**********************************************************/
/********** Update Driver/Tractor relationships ***********/
/**********************************************************/
SET @TMWDBErr = ''
IF (ISNULL(@TMWSuiteSvr,'') = '' OR ISNULL(@TMWSuiteDB,'') = '')
  BEGIN
	SET @TMWDBErr = 'No TMWSuite server or db passed to repair stored proc'
	
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Update Driver/Tractor relationships.', @TMWDBErr + ', bypassing relationship update', 'Info')	
  END
ELSE
  BEGIN	
	CREATE TABLE tempztest (Value int, ZDate datetime)
	SET @SQL = 'IF NOT EXISTS (SELECT * FROM master.dbo.sysservers WHERE srvname = ''' + @RealTMWSuiteSvr + ''') 
			INSERT INTO tempztest (Value) VALUES (1)'
	EXEC (@SQL)
	IF EXISTS (SELECT Value FROM tempztest)
	  BEGIN
		SET @TMWDBErr = 'Invalid TMWSuite server passed to repair stored proc (link server then try again).'

		INSERT INTO #Results (Section, Description, Status) 
		VALUES ('Update Driver/Tractor relationships.', @TMWDBErr + ', bypassing relationship update', 'Info')	
	  END
	ELSE
	  BEGIN	
		SET @SQL = 'IF NOT EXISTS (SELECT * FROM [' + @TMWSuiteSvr + '].master.dbo.sysdatabases WHERE name = ''' + @RealTMWSuiteDb + ''') 
				INSERT INTO tempztest (Value) VALUES (1)'
		EXEC (@SQL)
		IF EXISTS (SELECT Value FROM tempztest)
		  BEGIN
			SET @TMWDBErr = 'Invalid TMWSuite database passed to repair stored proc (db doesn''t exist).'
	
			INSERT INTO #Results (Section, Description, Status) 
			VALUES ('Update Driver/Tractor relationships.', @TMWDBErr + ', bypassing relationship update', 'Info')	
		  END
		ELSE
		  BEGIN		
			-- Database exists, now check if stop table exists
			SET @SQL = 'IF NOT EXISTS (SELECT * FROM [' + @TMWSuiteSvr + '].' + @TMWSuiteDb + '.dbo.sysobjects WHERE name = ''stops'') 
					INSERT INTO tempztest (Value) VALUES (1)'
			EXEC (@SQL)
			IF EXISTS (SELECT Value FROM tempztest)
			  BEGIN
				SET @TMWDBErr = 'Invalid TMWSuite database passed to repair stored proc (no stops table).'
		
				INSERT INTO #Results (Section, Description, Status) 
				VALUES ('Update Driver/Tractor relationships.', @TMWDBErr + ', bypassing relationship update', 'Info')	
			  END
			ELSE
			  BEGIN
				-- Stops table exists, now check if it's currently in use			
				SET @SQL = 'INSERT INTO tempztest (ZDate) SELECT MAX(stp_arrivaldate) FROM [' + @TMWSuiteSvr + '].' + @TMWSuiteDb + '.dbo.stops WHERE stp_arrivaldate <= DATEADD(dd,1,GETDATE())'
				EXEC (@SQL)
				IF (SELECT MAX(ZDate) FROM tempztest(NOLOCK)) < DATEADD(dd, -3, GETDATE())
				  BEGIN
					SET @TMWDBErr = 'Invalid TMWSuite database passed to repair stored proc (old stops table).'
			
					INSERT INTO #Results (Section, Description, Status) 
					VALUES ('Update Driver/Tractor relationships.', @TMWDBErr + ', bypassing relationship update', 'Info')	
				  END
				ELSE
				  BEGIN
					-- Server and database are valid		
					EXEC ('DECLARE  @DriverSN int,
									@SN int,
									@DispSysTruckID varchar(20),
									@DispSysDriverID varchar(20)
			
					-- Find drivers for tractors
					SELECT SN, DispSysTruckID
					INTO #t
					FROM tblTrucks (NOLOCK)
					WHERE GroupFlag = 0
			
					SET @SN = 0
					SELECT @SN = ISNULL(MIN(SN),0)
					FROM #t
					WHILE @SN > 0
					  BEGIN
						SELECT @DispSysTruckID = DispSysTruckID
						FROM #t
						WHERE SN = @SN
						
						IF EXISTS (SELECT trc_number FROM [' + @TMWSuiteSvr + '].' + @TMWSuiteDB + '.dbo.tractorprofile WHERE trc_number = @DispSysTruckID) AND ISNULL(@DispSysTruckID,'''') <> ''''
						  BEGIN
							-- Find the current driver for this truck in tractorprofile
							SELECT @DispSysDriverID = ISNULL(trc_driver,'''')
							FROM [' + @TMWSuiteSvr + '].' + @TMWSuiteDB + '.dbo.tractorprofile
							WHERE trc_number = @DispSysTruckID
				
							-- Update the driver in tblTrucks		
							IF (@DispSysDriverID <> '''' AND @DispSysDriverID <> ''UNKNOWN'')
							  BEGIN
								SELECT @DriverSN = SN 
								FROM tblDrivers  (NOLOCK)
								WHERE DispSysDriverID = @DispSysDriverID
			
								UPDATE tblTrucks
								SET DefaultDriver = NULL
								WHERE DefaultDriver = @DriverSN
				
								UPDATE tblTrucks
								SET DefaultDriver = @DriverSN
								WHERE SN = @SN
						
								-- Update the tractor in tblDrivers
								UPDATE tblDrivers
								SET CurrentTruck = NULL
								WHERE CurrentTruck = @SN
				
								UPDATE tblDrivers
								SET CurrentTruck = @SN
								WHERE DispSysDriverID = @DispSysDriverID
							  END
							ELSE IF @DispSysDriverID <> ''UNKNOWN''
								-- Tractor isn''t assigned a driver in TMWSuite, so null driver in TotalMail
								UPDATE tblTrucks
								SET DefaultDriver = NULL
								WHERE SN = @SN
						  END	-- IF EXISTS
				
						SELECT @SN = ISNULL(MIN(SN),0)
						FROM #t
						WHERE SN > @SN
					  END	-- While')
				  END
			  END
		  END
	  END
  END

/****************************************************************/
/********** List Trucks in TotalMail, not in TMWSuite ***********/
/****************************************************************/
IF ISNULL(@TMWDBErr,'') <> ''
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Tractors in TotalMail, not in TMWSuite.', @TMWDBErr + ', bypassing TotalMail tractor report', 'Info')	
ELSE
  BEGIN
	PRINT '********************************************************************************************'
	PRINT ' Checking for tractors in TotalMail but not TMWSuite'
	PRINT '********************************************************************************************'

	EXEC ('SELECT TruckName Trucks_In_TotalMail_but_not_in_TMWSuite
		FROM tblTrucks (NOLOCK)
		WHERE ISNULL(DispSysTruckID,'''') NOT IN (SELECT trc_number FROM [' + @TMWSuiteSvr + '].' + @TMWSuiteDB + '.dbo.tractorprofile)
			AND ISNULL(DispSysTruckID,'''') <> ''''
			AND GroupFlag = 0
		ORDER BY TruckName')
  END

/****************************************************************/
/********** List Trucks in TMWSuite, not in TotalMail ***********/
/****************************************************************/
IF ISNULL(@TMWDBErr,'') <> ''
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Tractors in TMWSuite, not in TotalMail.', @TMWDBErr + ', bypassing TMWSuite tractor report', 'Info')	
ELSE
  BEGIN
	PRINT '********************************************************************************************'
	PRINT ' Checking for tractors in TMWSuite but not TotalMail'
	PRINT '********************************************************************************************'

	EXEC ('SELECT trc_number Trucks_In_TMWSuite_but_not_in_TotalMail
			FROM [' + @TMWSuiteSvr + '].' + @TMWSuiteDB + '.dbo.tractorprofile
			WHERE trc_number NOT IN (SELECT ISNULL(DispSysTruckID,'''') FROM tblTrucks (NOLOCK) WHERE GroupFlag = 0)
			ORDER BY trc_number')
  END

/****************************************************************/
/********** List Drivers in TotalMail, not in TMWSuite **********/
/****************************************************************/
IF ISNULL(@TMWDBErr,'') <> ''
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Drivers in TotalMail, not in TMWSuite.', @TMWDBErr + ', bypassing TotalMail driver report', 'Info')	
ELSE
  BEGIN
	PRINT '********************************************************************************************'
	PRINT ' Checking for drivers in TotalMail but not TMWSuite'
	PRINT '********************************************************************************************'

	EXEC ('SELECT Name Drivers_In_TotalMail_but_not_in_TMWSuite
			FROM tblDrivers (NOLOCK)
			WHERE ISNULL(DispSysDriverID,'''') NOT IN (SELECT mpp_id FROM [' + @TMWSuiteSvr + '].' + @TMWSuiteDB + '.dbo.manpowerprofile)
			AND ISNULL(DispSysDriverID,'''') <> ''''
			ORDER BY Name')
  END

/****************************************************************/
/********** List Drivers in TMWSuite, not in TotalMail ***********/
/****************************************************************/
IF ISNULL(@TMWDBErr,'') <> ''
	INSERT INTO #Results (Section, Description, Status) 
	VALUES ('Drivers in TMWSuite, not in TotalMail.', @TMWDBErr + ', bypassing TMWSuite driver report', 'Info')	
ELSE
  BEGIN
	PRINT '********************************************************************************************'
	PRINT ' Checking for drivers in TMWSuite but not TotalMail'
	PRINT '********************************************************************************************'

	EXEC ('SELECT mpp_id Drivers_In_TMWSuite_but_not_in_TotalMail
			FROM [' + @TMWSuiteSvr + '].' + @TMWSuiteDB + '.dbo.manpowerprofile
			WHERE mpp_id NOT IN (SELECT ISNULL(DispSysDriverID,'''') FROM tblDrivers)
			ORDER BY mpp_id')
  END

/****************************************************************/
/********** List Drivers/Trucks in with no DispSysId ************/
/****************************************************************/
if (SELECT COUNT(*)
		FROM tblTrucks (NOLOCK)
		WHERE ISNULL(DispSysTruckId,'') = ''
			AND GroupFlag = 0) > 0
	BEGIN
		PRINT '********************************************************************************************'
		PRINT ' Tractors in TotalMail with no DispSysTruckId set'
		PRINT '********************************************************************************************'

		SELECT TruckName Trucks_With_Missing_DispSysTruckId
		FROM tblTrucks (NOLOCK)
		WHERE ISNULL(DispSysTruckId,'') = ''
			AND GroupFlag = 0
		ORDER BY TruckName
	END

if (SELECT COUNT(*)
	FROM tblDrivers (NOLOCK)
	WHERE ISNULL(DispSysDriverId,'') = '') > 0
	BEGIN
		PRINT '********************************************************************************************'
		PRINT ' Drivers in TotalMail with no DispSysDriverId set'
		PRINT '********************************************************************************************'

		SELECT Name Drivers_With_Missing_DispSysDriverId
		FROM tblDrivers (NOLOCK)
		WHERE ISNULL(DispSysDriverId,'') = ''
		ORDER BY Name
	END

/*******************************************************************/
/********** List Truck MCTS that are not assigned to a tractor *****/
/*******************************************************************/
DELETE #Count
IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
		WHERE a.name = 'LinkedAddrType'
			AND a.id = b.id 
			AND b.name = 'tblCabUnits')
	INSERT INTO #Count (RecordCount)
		EXEC ('SELECT COUNT(*)
			FROM tblCabUnits
			WHERE GroupFlag = 0
				AND ISNULL(Truck,0) = 0 AND LinkedAddrType = 4')
else
	INSERT INTO #Count (RecordCount)
		SELECT COUNT(*)
		FROM tblCabUnits (NOLOCK)
		WHERE GroupFlag = 0
			AND ISNULL(Truck,0) = 0

if (select RecordCount from #Count) > 0
	BEGIN
		PRINT '********************************************************************************************'
		PRINT ' Truck MCT''s that are not assigned to a tractor'
		PRINT '********************************************************************************************'
		IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
				WHERE a.name = 'LinkedAddrType'
					AND a.id = b.id 
					AND b.name = 'tblCabUnits')
			EXEC ('SELECT UnitId MCTS_Not_Assigned_to_a_Tractor
				FROM tblCabUnits
				WHERE GroupFlag = 0
					AND ISNULL(Truck,0) = 0 AND LinkedAddrType = 4
				ORDER BY UnitId')
		else	
			SELECT UnitId MCTS_Not_Assigned_to_a_Tractor
			FROM tblCabUnits (NOLOCK)
			WHERE GroupFlag = 0
				AND ISNULL(Truck,0) = 0
			ORDER BY UnitId
	END

/*******************************************************************/
/********** List Driver MCTS that are not assigned to a driver *****/
/*******************************************************************/
DELETE #Count
IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
		WHERE a.name = 'LinkedAddrType'
			AND a.id = b.id 
			AND b.name = 'tblCabUnits')
	INSERT INTO #Count (RecordCount)
		EXEC ('SELECT COUNT(*)
			FROM tblCabUnits
			WHERE GroupFlag = 0
				AND ISNULL(Truck,0) = 0 AND LinkedAddrType = 5')
else
	INSERT INTO #Count (RecordCount)
		SELECT COUNT(*)
		FROM tblCabUnits (NOLOCK)
		WHERE GroupFlag = 0
			AND ISNULL(Truck,0) = 0

if (select RecordCount from #Count) > 0
	BEGIN
		PRINT '********************************************************************************************'
		PRINT ' Driver MCT''s that are not assigned to a driver'
		PRINT '********************************************************************************************'
		IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
				WHERE a.name = 'LinkedAddrType'
					AND a.id = b.id 
					AND b.name = 'tblCabUnits')
			EXEC ('SELECT UnitId MCTS_Not_Assigned_to_a_Tractor
				FROM tblCabUnits
				WHERE GroupFlag = 0
					AND ISNULL(Truck,0) = 0 AND LinkedAddrType = 5
				ORDER BY UnitId')
		else	
			SELECT UnitId MCTS_Not_Assigned_to_a_Tractor
			FROM tblCabUnits (NOLOCK)
			WHERE GroupFlag = 0
				AND ISNULL(Truck,0) = 0
			ORDER BY UnitId
	END

/*******************************************************************/
/********** List Trailer MCTS that are not assigned to a trailer ***/
/*******************************************************************/
DELETE #Count
IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
		WHERE a.name = 'LinkedAddrType'
			AND a.id = b.id 
			AND b.name = 'tblCabUnits')
	INSERT INTO #Count (RecordCount)
		EXEC ('SELECT COUNT(*)
			FROM tblCabUnits
			WHERE GroupFlag = 0
				AND ISNULL(Truck,0) = 0 AND LinkedAddrType = 9')
else
	INSERT INTO #Count (RecordCount)
		SELECT COUNT(*)
		FROM tblCabUnits (NOLOCK)
		WHERE GroupFlag = 0
			AND ISNULL(Truck,0) = 0

if (select RecordCount from #Count) > 0
	BEGIN
		PRINT '********************************************************************************************'
		PRINT ' Trailer MCT''s that are not assigned to a trailer'
		PRINT '********************************************************************************************'
		IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
				WHERE a.name = 'LinkedAddrType'
					AND a.id = b.id 
					AND b.name = 'tblCabUnits')
			EXEC ('SELECT UnitId MCTS_Not_Assigned_to_a_Tractor
				FROM tblCabUnits
				WHERE GroupFlag = 0
					AND ISNULL(Truck,0) = 0 AND LinkedAddrType = 9
				ORDER BY UnitId')
		else	
			SELECT UnitId MCTS_Not_Assigned_to_a_Tractor
			FROM tblCabUnits (NOLOCK)
			WHERE GroupFlag = 0
				AND ISNULL(Truck,0) = 0
			ORDER BY UnitId
	END

/*****************************************************************************/
/********** List tractors/drivers not assigned to a dispatch group ***********/
/*****************************************************************************/
IF (SELECT CONVERT(int, text) FROM tblRS WHERE KeyCode = 'ADDRESSBY') = 0
  BEGIN
	PRINT '********************************************************************************************'
	PRINT ' Drivers not assigned to a dispatch group'
	PRINT '********************************************************************************************'
	SELECT Name Drivers_With_No_Dispatch_Group
	FROM tblDrivers
	WHERE ISNULL(CurrentDispatcher,0) = 0
	ORDER BY Name
  END
ELSE
  BEGIN
	PRINT '********************************************************************************************'
	PRINT ' Checking for tractors not assigned to a dispatch group'
	PRINT '********************************************************************************************'
	SELECT TruckName Tractors_With_No_Dispatch_Group
	FROM tblTrucks
	WHERE GroupFlag = 0
		AND ISNULL(CurrentDispatcher,0) = 0
	ORDER BY TruckName
  END

if exists (select * from tbltrucks where isnull(defaultcabunit , 0) = 0 and isnull(groupflag, 0) <> -1)
	BEGIN
	PRINT '********************************************************************************************'
	print 'Trucks with no DefaultCabUnit (Warning: no problem as long as no message is sent out to the truck)'
	PRINT '********************************************************************************************'
	select tbltrucks.truckname, * from tbltrucks (NOLOCK) where isnull(defaultcabunit , 0) = 0 and isnull(groupflag, 0) <> -1 order by tbltrucks.truckname
	END
if exists (select * from tbltrucks (NOLOCK) where isnull(defaultcabunit, 0) <> 0 and not exists (select * from tblcabunits a where a.sn = defaultcabunit) and isnull(tbltrucks.groupflag, 0) <> -1) 
	BEGIN
	PRINT '********************************************************************************************'
	print 'Trucks that have DefaultCabUnits that do not exist (Error: Any outbound messages to these trucks will fail)'
	PRINT '********************************************************************************************'
	select tbltrucks.truckname, * from tbltrucks (NOLOCK) where isnull(defaultcabunit, 0) <> 0 and not exists (select * from tblcabunits a where a.sn = defaultcabunit) and isnull(tbltrucks.groupflag, 0) <> -1 order by tbltrucks.truckname
	END
if exists (select * from tblcabunits b (NOLOCK) inner join tbltrucks (NOLOCK) on b.truck = tbltrucks.sn where
	isnull(defaultcabunit, 0) <> 0 and not exists (select * from tblcabunits a where a.sn = defaultcabunit) and isnull(tbltrucks.groupflag, 0) <> -1)
	BEGIN
	PRINT '********************************************************************************************'
	print 'Cabunits that ARE in those trucks: (The default for the truck should probably be set to one of these)'
	PRINT '********************************************************************************************'
	select tbltrucks.truckname, b.unitid, * from tblcabunits b (NOLOCK) inner join tbltrucks (NOLOCK) on b.truck = tbltrucks.sn where
		isnull(defaultcabunit, 0) <> 0 and not exists (select * from tblcabunits a (NOLOCK) where a.sn = defaultcabunit) and isnull(tbltrucks.groupflag, 0) <> -1 order by tbltrucks.truckname, b.unitid
	END
if exists (select * from tbltrucks (NOLOCK) inner join tblcabunits a  (NOLOCK) on tbltrucks.defaultcabunit = a.sn left outer join tbltrucks b on isnull(a.truck, 0) = b.sn where isnull(a.truck, 0) <> tbltrucks.sn)
	BEGIN
	PRINT '********************************************************************************************'
	print 'Trucks with DefaultCabUnits that exist but that are not in the truck: (Error: Outbound messages will go to that unit, but inbounds will look like they came from a different truck!)'
	PRINT '********************************************************************************************'
	select tbltrucks.truckname, a.unitid DefaultCabUnitID, b.truckname TruckCabUnitIsIn, * 
	from tbltrucks (NOLOCK) 
	inner join tblcabunits a (NOLOCK) on tbltrucks.defaultcabunit = a.sn 
	left outer join tbltrucks b (NOLOCK) on isnull(a.truck, 0) = b.sn 
	where isnull(a.truck, 0) <> tbltrucks.sn 
	order by tbltrucks.truckname
	END
if exists (select * from tblcabunits b (NOLOCK) inner join tbltrucks (NOLOCK) on b.truck = tbltrucks.sn inner join tblcabunits a (NOLOCK) on tbltrucks.defaultcabunit = a.sn where
	isnull(a.truck, 0) <> tbltrucks.sn)
	BEGIN
	PRINT '********************************************************************************************'
	print 'Cabunits that ARE in those trucks: (Either the DefaultCabUnit should be corrected to be in the truck, or one of these should be the DefaultCabUnit instead)'
	PRINT '********************************************************************************************'
	select tbltrucks.truckname, b.unitid, * from tblcabunits b (NOLOCK) inner join tbltrucks (NOLOCK) on b.truck = tbltrucks.sn inner join tblcabunits a (NOLOCK) on tbltrucks.defaultcabunit = a.sn where
		isnull(a.truck, 0) <> tbltrucks.sn order by tbltrucks.truckname, b.unitid
	END

-- '********************************************************************************************'
-- 'Truck Cabunits that are not in Trucks: (Warning: No problem as long as no messages are received from these units)'
-- '********************************************************************************************'
DELETE #Count
IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
		WHERE a.name = 'LinkedAddrType'
			AND a.id = b.id 
			AND b.name = 'tblCabUnits')
	INSERT INTO #Count (RecordCount)
		EXEC ('select COUNT(*) from tblcabunits a (NOLOCK) where isnull(truck, 0) = 0 AND LinkedAddrType = 4') 
else
	INSERT INTO #Count (RecordCount)
		SELECT COUNT(*) FROM tblcabunits a (NOLOCK) WHERE isnull(truck, 0) = 0

if (select RecordCount from #Count) > 0
	BEGIN
	PRINT '********************************************************************************************'
	print 'Truck Cabunits that are not in Trucks: (Warning: No problem as long as no messages are received from these units)'
	PRINT '********************************************************************************************'
	IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
			WHERE a.name = 'LinkedAddrType'
				AND a.id = b.id 
				AND b.name = 'tblCabUnits')
		--if we have the new fields, we need to add the Addr Type (Driver, Trailer, or Truck) to the grouping
		--  but the field may not exist, we need to protect against an error by doing dynamic SQL
		EXEC ('select unitid, * from tblcabunits a where isnull(truck, 0) = 0 AND LinkedAddrType = 4 ORDER BY a.unitid') 
	else
		select unitid, * from tblcabunits a where isnull(truck, 0) = 0 order by a.unitid

	END

-- '********************************************************************************************'
-- 'Driver Cabunits that are not in Drivers: (Warning: No problem as long as no messages are received from these units)'
-- '********************************************************************************************'
DELETE #Count
IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
		WHERE a.name = 'LinkedAddrType'
			AND a.id = b.id 
			AND b.name = 'tblCabUnits')
	INSERT INTO #Count (RecordCount)
		EXEC ('select COUNT(*) from tblcabunits a (NOLOCK) where isnull(truck, 0) = 0 AND LinkedAddrType = 5') 

if (select RecordCount from #Count) > 0
	BEGIN
	PRINT '********************************************************************************************'
	print 'Driver Cabunits that are not in Drivers: (Warning: No problem as long as no messages are received from these units)'
	PRINT '********************************************************************************************'

	EXEC ('select unitid, * from tblcabunits a (NOLOCK) where isnull(truck, 0) = 0 AND LinkedAddrType = 5 ORDER BY a.unitid') 

	END

-- '********************************************************************************************'
-- 'Trailer Cabunits that are not in Trailers: (Warning: No problem as long as no messages are received from these units)'
-- '********************************************************************************************'
DELETE #Count
IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
		WHERE a.name = 'LinkedAddrType'
			AND a.id = b.id 
			AND b.name = 'tblCabUnits')
	INSERT INTO #Count (RecordCount)
		EXEC ('select COUNT(*) from tblcabunits a where isnull(truck, 0) = 0 AND LinkedAddrType = 9') 

if (select RecordCount from #Count) > 0
	BEGIN
	PRINT '********************************************************************************************'
	print 'Trailer Cabunits that are not in Trailers: (Warning: No problem as long as no messages are received from these units)'
	PRINT '********************************************************************************************'

	EXEC ('select unitid, * from tblcabunits a (NOLOCK) where isnull(truck, 0) = 0 AND LinkedAddrType = 9 ORDER BY a.unitid') 

	END

-- '********************************************************************************************'
-- 'CabUnits that are in Trucks that do not exist: (Error: Any inbound messages from these cabunits will fail)'
-- '********************************************************************************************'
DELETE #Count
IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
		WHERE a.name = 'LinkedAddrType'
			AND a.id = b.id 
			AND b.name = 'tblCabUnits')
	INSERT INTO #Count (RecordCount)
		EXEC ('SELECT COUNT(*) FROM tblcabunits a (NOLOCK) WHERE ISNULL(truck, 0) <> 0 AND NOT EXISTS (SELECT * FROM tbltrucks  (NOLOCK)WHERE a.truck = tbltrucks.sn) AND LinkedAddrType = 4') 
else
	INSERT INTO #Count (RecordCount)
		SELECT COUNT(*) FROM tblcabunits a (NOLOCK) WHERE ISNULL(truck, 0) <> 0 AND NOT EXISTS (SELECT * FROM tbltrucks WHERE a.truck = tbltrucks.sn)

if (select RecordCount from #Count) > 0
	BEGIN
		PRINT '********************************************************************************************'
		print 'CabUnits that are in Trucks that do not exist: (Error: Any inbound messages from these cabunits will fail)'
		PRINT '********************************************************************************************'
		IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
				WHERE a.name = 'LinkedAddrType'
					AND a.id = b.id 
					AND b.name = 'tblCabUnits')
			EXEC ('SELECT unitid, * FROM tblcabunits a (NOLOCK) WHERE ISNULL(truck, 0) <> 0 AND NOT EXISTS (SELECT * FROM tbltrucks (NOLOCK) WHERE a.truck = tbltrucks.sn) AND LinkedAddrType = 4 ORDER BY a.unitid')
		else
			SELECT unitid, * FROM tblcabunits a WHERE ISNULL(truck, 0) <> 0 AND NOT EXISTS (SELECT * FROM tbltrucks WHERE a.truck = tbltrucks.sn)
	END

-- '********************************************************************************************'
-- 'CabUnits that are for Drivers that do not exist: (Error: Any inbound messages from these cabunits will fail)'
-- '********************************************************************************************'
DELETE #Count
IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
		WHERE a.name = 'LinkedAddrType'
			AND a.id = b.id 
			AND b.name = 'tblCabUnits')
	INSERT INTO #Count (RecordCount)
		EXEC ('SELECT COUNT(*) FROM tblcabunits a (NOLOCK) WHERE ISNULL(LinkedObjSN, 0) <> 0 AND NOT EXISTS (SELECT * FROM tbldrivers (NOLOCK) WHERE a.LinkedObjSN = tbldrivers.sn) AND LinkedAddrType = 5') 

if (select RecordCount from #Count) > 0
	BEGIN
		PRINT '********************************************************************************************'
		print 'CabUnits that are for Drivers that do not exist: (Error: Any inbound messages from these cabunits will fail)'
		PRINT '********************************************************************************************'

		EXEC ('SELECT unitid, * FROM tblcabunits a (NOLOCK) WHERE ISNULL(LinkedObjSN, 0) <> 0 AND NOT EXISTS (SELECT * FROM tbldrivers (NOLOCK) WHERE a.LinkedObjSN = tbldrivers.sn) AND LinkedAddrType = 5')
	END

-- '********************************************************************************************'
-- 'CabUnits that are in Trailers that do not exist: (Error: Any inbound messages from these cabunits will fail)'
-- '********************************************************************************************'
DELETE #Count
IF EXISTS (SELECT a.* FROM syscolumns a, sysobjects b
		WHERE a.name = 'LinkedAddrType'
			AND a.id = b.id 
			AND b.name = 'tblCabUnits')
	INSERT INTO #Count (RecordCount)
		EXEC ('SELECT COUNT(*) FROM tblcabunits a (NOLOCK) WHERE ISNULL(truck, 0) <> 0 AND NOT EXISTS (SELECT * FROM tbltrucks (NOLOCK) WHERE a.truck = tbltrucks.sn) AND LinkedAddrType = 9') 

if (select RecordCount from #Count) > 0
	BEGIN
		PRINT '********************************************************************************************'
		print 'CabUnits that are in Trailers that do not exist: (Error: Any inbound messages from these cabunits will fail)'
		PRINT '********************************************************************************************'

		EXEC ('SELECT unitid, * FROM tblcabunits a (NOLOCK) WHERE ISNULL(truck, 0) <> 0 AND NOT EXISTS (SELECT * FROM tbltrucks (NOLOCK) WHERE a.truck = tbltrucks.sn) AND LinkedAddrType = 9 ORDER BY a.unitid')
	END

-- Show repair results
IF ((SELECT COUNT(*) FROM #Results) = 0)
	SELECT 'TotalMail database needed no repairs.' as RepairStatus
ELSE
	SELECT Section, Description, Status From #Results order by SN

if object_id ('tempztest') is not null
	DROP TABLE tempztest


SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[tm_DbRepair] TO [public]
GO
