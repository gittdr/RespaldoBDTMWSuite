SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogListProcedures] (@Status varchar(12), @Filter varchar(255) )
AS
	SET NOCOUNT ON

	--*** Possible status: Active, Inactive, Unassigned, or All
	/*
	dbo.WatchdogListProcedures 'Active', '%'
	dbo.WatchdogListProcedures 'InActive', '%'
	dbo.WatchdogListProcedures 'Unassigned', '%'
	dbo.WatchdogListProcedures 'All', '%'
	*/
	DECLARE @tSqlNames TABLE (sn int identity, SQLStatement varchar(2000), crdate datetime, ActiveCount int, InactiveCount int, NewWatchName varchar(75) )
	DECLARE @CopyIdx int, @tempsn int, @NewWatchName varchar(75), @bFound int, @bDone int, @MaxIdx int

	SET @MaxIdx = 10

	IF @Status = 'Active'
	BEGIN
		INSERT INTO @tSqlNames (SQLStatement, crdate, ActiveCount, InactiveCount, NewWatchName)
		SELECT SQLStatement, crdate = (SELECT crdate FROM sysobjects WHERE type = 'p' AND name = t1.SQLStatement),
			ActiveCount = COUNT(Watchname), InactiveCount = 0,
			NewWatchName = SQLStatement
		FROM WatchdogItem t1 
		WHERE activeflag = 1 AND ISNULL(DataSourceSN, 0) = 0
			AND SQLStatement LIKE '%' + @Filter + '%'
		GROUP BY SQLStatement
		-- ORDER BY SQLStatement
	END
	ELSE IF @Status = 'Inactive'
	BEGIN
		INSERT INTO @tSqlNames (SQLStatement, crdate, ActiveCount, InactiveCount, NewWatchName)
		SELECT SQLStatement, crdate = (SELECT crdate FROM sysobjects WHERE type = 'p' AND name = t1.SQLStatement),
			ActiveCount = 0, InactiveCount = COUNT(Watchname),
			NewWatchName = SQLStatement
		FROM WatchdogItem t1 
		WHERE activeflag = 0 AND ISNULL(DataSourceSN, 0) = 0
			AND SQLStatement LIKE '%' + @Filter + '%'
		GROUP BY SQLStatement
		-- ORDER BY SQLStatement
	END

	ELSE IF @Status = 'Unassigned'
	BEGIN
		INSERT INTO @tSqlNames (SQLStatement, crdate, ActiveCount, InactiveCount, NewWatchName)
		SELECT name, crdate, ActiveCount = 0, InactiveCount = 0, name
		FROM sysobjects t1 WHERE type = 'p' AND name LIKE 'Watchdog%' AND SUBSTRING(name, 9, 1) = '_'
			AND NOT EXISTS(SELECT sn FROM watchdogitem WHERE SQLStatement = t1.name AND ISNULL(DataSourceSN, 0) = 0)
			AND name LIKE '%' + @Filter + '%'
		-- ORDER BY name
	END

	ELSE IF @Status = 'All'
	BEGIN
		INSERT INTO @tSqlNames (SQLStatement, crdate, ActiveCount, InactiveCount, NewWatchName)
		SELECT SQLStatement, crdate = (SELECT crdate FROM sysobjects WHERE type = 'p' AND name = t1.SQLStatement),
			ActiveCount = 0, InactiveCount = COUNT(Watchname), 
			NewWatchName = SQLStatement
		FROM WatchdogItem t1 
		WHERE ISNULL(DataSourceSN, 0) = 0
			AND SQLStatement LIKE '%' + @Filter + '%'
		GROUP BY SQLStatement

		INSERT INTO @tSqlNames (SQLStatement, crdate, ActiveCount, InactiveCount, NewWatchName)
		SELECT SQLStatement = name, crdate, ActiveCount = 0, InactiveCount = 0, name 
			FROM sysobjects t2 
			WHERE type = 'p' AND name LIKE 'Watchdog%' AND SUBSTRING(name, 9, 1) = '_'
				AND NOT EXISTS(SELECT sn FROM watchdogitem WHERE SQLStatement = t2.name AND ISNULL(DataSourceSN, 0) = 0)
				AND name LIKE '%' + @Filter + '%'
		ORDER BY SQLStatement

	END

	-- Determine what the copy of the new alert will be called.
	UPDATE @tSqlNames SET NewWatchName = RIGHT(NewWatchName, LEN(NewWatchName) - LEN('Watchdog_'))
	WHERE NewWatchName LIKE 'Watchdog_%'  AND SUBSTRING(NewWatchName, 9, 1) = '_'

	SELECT sn INTO #t1 FROM @tSqlNames t1 WHERE EXISTS(SELECT sn FROM watchdogitem WHERE watchname = t1.NewWatchName)
	ORDER BY SQLStatement

	-- Determine unique watchname for each.
	SELECT @tempsn = MIN(sn) FROM #t1 
	WHILE ISNULL(@tempsn, 0) > 0
	BEGIN
		SELECT @bFound = 0, @bDone = 0, @NewWatchName = NewWatchName FROM @tSqlNames WHERE sn = @tempsn
		SET @CopyIdx = 1
		WHILE @bDone = 0 
		BEGIN
			IF NOT EXISTS(SELECT sn FROM watchdogitem WHERE watchname = @NewWatchName + CONVERT(varchar(2), @CopyIdx))
			BEGIN
				SELECT @bFound = 1
			END
			SET @CopyIdx = @CopyIdx + 1
			IF ((@CopyIdx > @MaxIdx) OR (@bFound = 1) )
				SELECT @bDone = 1
		END
		IF @bFound = 1 
		BEGIN
			SET @NewWatchName = @NewWatchName + CONVERT(varchar(2), @CopyIdx-1)
		END
		ELSE
		BEGIN
			SET @NewWatchName = NEWID()
		END
		UPDATE @tSqlNames SET NewWatchName = @NewWatchName WHERE sn = @tempSN
		SELECT @tempsn = MIN(sn) FROM #t1 WHERE sn > @tempsn
	END
	
	SELECT * FROM @tSqlNames WHERE ISNULL(SQLStatement, '') <> '' ORDER BY SQLStatement
GO
GRANT EXECUTE ON  [dbo].[WatchdogListProcedures] TO [public]
GO
