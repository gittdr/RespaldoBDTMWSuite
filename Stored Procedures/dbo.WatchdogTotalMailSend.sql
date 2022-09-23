SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogTotalMailSend] (@WatchName varchar(255), @EmailAddress varchar(1000), @TempTableWatchResults varchar(255), @CalledFromDawgProcessing_YN varchar(1), @FormatTotalMailGroupAndLogonMsgsAsTabular_YN varchar(1) )
AS
	SET NOCOUNT ON
	
	-- Must have a link back to PSXact (Dispatch System) server:
	--		master..sp_addlinkedserver @server='TMWSuiteServer'

	/************************************************************/
	/* Loop through and send a message to TotalMail logins. */
	/************************************************************/

	DECLARE @DawgHeader varchar(1000), @ErrMsg varchar(255)

	/* START RTF declares */
	DECLARE @MyTempTableName varchar(255)
	DECLARE @myCols TABLE (sn int IDENTITY, id int, colName varchar(255))
	DECLARE @SQL varchar(4000)
	-- DECLARE #tLengths TABLE (colName varchar(255), maxLength int, twipsCumulative int)
	CREATE TABLE #tLengths (colName varchar(255), maxLength int, twipsCumulative int)
	DECLARE @sn int, @colName varchar(255)
	DECLARE @RowHeader varchar(4000)
	DECLARE @RowID int, @MyOtherSQL varchar(2000), @MyNewSQL varchar(2000), @RowID_Last int
	-- DECLARE #MyRowsTable TABLE (RowID int)
	CREATE TABLE #MyRowsTable (RowID int)
	-- DECLARE #MyRTFTable TABLE (rtf varchar(2000))
	CREATE TABLE #MyRTFTable (rtf varchar(2000))
	DECLARE @TableHeader varchar(2000)
	DECLARE @TWIPS_PER_CHAR int
	SET @TWIPS_PER_CHAR = 200
	/* END RTF declares */


	DECLARE @TotalMailAddresses TABLE (sn int IDENTITY, TMailAddress varchar(256))
	DECLARE @TMAddressType varchar(1), @TMAddressTypeSN int, @Item varchar(100), @tempMsg varchar(4000), @alrt_message varchar(4000)
	DECLARE @msgid int, @msg_seq int, @msd_seq int, @msg_chunk varchar(255), @last_partial varchar(254)
	DECLARE @PSXactSvr varchar(255), @PSXactDB varchar(255)
	DECLARE @GT_Temp int, @GT_Group varchar(100)

	CREATE TABLE #tblSQLMessage (
		[msg_ID] [int] IDENTITY (1, 1) NOT NULL ,
		[msg_date] [datetime] NOT NULL ,
		[msg_FormID] [int] NOT NULL ,
		[msg_To] [varchar] (100)  NOT NULL ,
		[msg_ToType] [int] NOT NULL ,
		[msg_FilterData] [varchar] (254)  NULL ,
		[msg_FilterDataDupWaitSeconds] [int] NULL ,
		[msg_From] [varchar] (100)  NOT NULL ,
		[msg_FromType] [int] NOT NULL ,
		[msg_Subject] [varchar] (254)  NULL 
	) 

	CREATE TABLE #tblSQLMessageData (
		[msd_ID] [int] IDENTITY (1, 1) NOT NULL ,
		[msg_ID] [int] NOT NULL ,
		[msd_Seq] [int] NOT NULL ,
		[msd_FieldName] [varchar] (30)  NOT NULL ,
		[msd_FieldValue] [varchar] (254)  NOT NULL 
	)


	SELECT @PSXactDB = [text] FROM tblRS WHERE keycode = 'PSXactDB'
	SELECT @PSXactSvr = [text] FROM tblRS WHERE keycode = 'PSXactSvr'

	-- @TempTableWatchResults is the NAME of the temp table ON THE TMWSuite or BASE Dawg server.
	-- SET @SQL = 'SELECT * INTO ' + @TempTableWatchResults + '_TM FROM OPENQUERY(DawgInstall, ''SELECT * FROM ' + @TempTableWatchResults + ''')'
	IF ISNULL(@PSXactSvr, '') <> ''
	BEGIN
		SET @SQL = 'SELECT * INTO ' + @TempTableWatchResults + '_TM FROM OPENQUERY([' + @PSXactSvr + '], ''SELECT * FROM ' + @PSXactDB + '.' + @TempTableWatchResults + ''')'

		SET @MyTempTableName = @TempTableWatchResults + '_TM'
	END
	ELSE -- Temp table already exists.  No need to recreate.
	BEGIN
		SET @MyTempTableName = @TempTableWatchResults
	END
	
	EXEC(@SQL)

	SELECT @SQL = ''

	SET @EmailAddress = REPLACE(@EmailAddress, ' ', '')

	IF CHARINDEX(':', @EmailAddress) > 0  -- If at least one TotalMail address exists, then go through this process.
	BEGIN
		SELECT @EmailAddress = REPLACE(@EmailAddress, ',', ';')

		-- Split the configured email address into table for items containing ":".
		INSERT INTO @TotalMailAddresses (TMailAddress)
		SELECT DISTINCT RTRIM(LTRIM(item)) FROM dbo.fnc_TMWRN_SplitList(@EmailAddress, ';') WHERE item LIKE '%:%' AND LEN(RTRIM(item)) > 0
		
		-- Loop through each addressee prefixed with "GT:" (Group Trucks) and explode out into truck addresses.
		SELECT @GT_Group = MIN(TMailAddress) FROM @TotalMailAddresses WHERE TMailAddress LIKE 'GT:%'
		WHILE ISNULL(@GT_Group, '') <> ''
		BEGIN
			SET @GT_Temp = NULL
			SELECT @GT_Temp = SN FROM tblDispatchGroup (NOLOCK) WHERE name = RIGHT(@GT_Group, LEN(@GT_Group) - 3) AND Retired = 0

			IF @GT_Temp IS NOT NULL
			BEGIN
				INSERT INTO @TotalMailAddresses (TMailAddress) 
				SELECT 'T:' + DispSysTruckID FROM tblTrucks WITH (NOLOCK)
				WHERE CurrentDispatcher = @GT_Temp AND CurrentDispatcher IS NOT NULL AND DispSysTruckID NOT LIKE 'TRL:%'
			END
			ELSE
			BEGIN
				SET @ErrMsg = 'Forced error in WatchdogTotalMailSend while running Dawg alert ' + @WatchName + '.  TotalMail dispatch group not found in tblDispatchGroups. Address list=' + @EmailAddress
				RAISERROR(@ErrMsg, 16, 1)
			END
			
			DELETE @TotalMailAddresses WHERE TMailAddress = @GT_Group
			SELECT @GT_Group = MIN(TMailAddress) FROM @TotalMailAddresses WHERE TMailAddress LIKE 'GT:%' AND TMailAddress > @GT_Group
		END

		IF NOT EXISTS(SELECT * 
						FROM tblAddresses t1 (NOLOCK) INNER JOIN @TotalMailAddresses t2 ON t1.AddressName = SUBSTRING(t2.TMailAddress, 3, LEN(t2.TMailAddress))  -- INNER JOIN tblAddressTypes t3 ON t1.AddressType = t3.sn -- CAN'T JOIN HERE BECAUSE DispatchSys Drivers/Trucks
									AND t1.AddressType = CASE WHEN LEFT(t2.TMailAddress, 1) = 'L' THEN 1
																WHEN LEFT(t2.TMailAddress, 1) = 'G' THEN 3
																WHEN LEFT(t2.TMailAddress, 1) = 'T' THEN 4  -- Note: Careful on INSERT because we want these to go in as AddressType = 9 because not TotalMail truck, use DispSys truck.
																WHEN LEFT(t2.TMailAddress, 1) = 'D' THEN 5  -- Note: Careful on INSERT because we want these to go in as AddressType = 9 because not TotalMail driver, use DispSys driver.
															END -- Note t3.AddressType is either L, G, T, D -- but 
						WHERE (t2.TmailAddress LIKE 'G:%' OR t2.TmailAddress LIKE 'L:%' OR t2.TmailAddress LIKE 'T:%' OR t2.TmailAddress LIKE 'D:%')
					)
		BEGIN
			SET @ErrMsg = 'Forced error in WatchdogTotalMailSend while running Dawg alert ' + @WatchName + '.  TotalMail address not found in tblAddresses. Address list=' + @EmailAddress
			RAISERROR(@ErrMsg, 16, 1)
		END

		IF EXISTS(SELECT * FROM @TotalMailAddresses t2 WHERE t2.TmailAddress LIKE 'T:%' AND NOT EXISTS(SELECT sn FROM tblTrucks t3 (NOLOCK) WHERE t3.DispSysTruckId = SUBSTRING(t2.TmailAddress, 3, LEN(t2.TmailAddress)) ))
		BEGIN
			SET @ErrMsg = 'Forced error in WatchdogTotalMailSend while running Dawg alert ' + @WatchName + '.  TotalMail address to trucks must be the "Dispatch System Truck Id" defined in TotalMail. Address list=' + @EmailAddress
			RAISERROR(@ErrMsg, 16, 1)
		END


		IF EXISTS(SELECT * FROM @TotalMailAddresses t2 WHERE t2.TmailAddress LIKE 'D:%' AND NOT EXISTS(SELECT sn FROM tblDrivers t3 (NOLOCK) WHERE t3.DispSysDriverId = SUBSTRING(t2.TmailAddress, 3, LEN(t2.TmailAddress))))
		BEGIN
			SET @ErrMsg = 'Forced error in WatchdogTotalMailSend while running Dawg alert ' + @WatchName + '.  TotalMail address to trucks must be the "Dispatch System Truck Id" defined in TotalMail. Address list=' + @EmailAddress
			RAISERROR(@ErrMsg, 16, 1)
		END




		INSERT INTO @myCols (id, colName) 
		SELECT t2.id, colName = t2.name FROM tempdb..sysobjects t1 INNER JOIN tempDB..syscolumns t2 ON t1.id = t2.id WHERE t1.name = @MyTempTableName ORDER BY t2.colid

		-- Put a RowId into every table & transfer into a new table.
		IF NOT EXISTS(SELECT * FROM @MyCols WHERE colName = 'RowId')
		BEGIN
			SET @SQL = 'SELECT identity(INT,1,1) AS RowID, * INTO ' + @MyTempTableName + '_WithRowId FROM ' + @MyTempTableName 
			EXEC(@SQL)
			SET @MyTempTableName = @MyTempTableName + '_WithRowId'
		END

		/*****************************************************************************************************/
		/** START: For alerts going to TotalMail Trucks or TotalMail Drivers **/
		/*****************************************************************************************************/
		IF EXISTS(SELECT * FROM @TotalMailAddresses WHERE TmailAddress LIKE 'D:%' OR TmailAddress LIKE 'T:%') OR 
			( EXISTS(SELECT * FROM @TotalMailAddresses WHERE TmailAddress LIKE 'L:%' OR TmailAddress LIKE 'G:%') AND ISNULL(@FormatTotalMailGroupAndLogonMsgsAsTabular_YN, 'N') = 'N')
		BEGIN
			INSERT INTO #tblSQLMessage(msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
			SELECT GETDATE(), 0, '@TotalMailAddress', -1, '', 0, 'admin', 1, @WatchName

			SELECT @msd_seq = 1, @msgid = MAX(msg_id) FROM #tblSQLMessage
			SELECT @SQL = '', @TableHeader = '', @colName = ''

			SELECT @sn = MIN(sn) FROM @myCols WHERE colName <> 'RowId'  -- Get the first column.
			WHILE ISNULL(@sn, 0) > 0
			BEGIN
				SELECT @colName = colName FROM @myCols WHERE sn = @sn
				SELECT @SQL = @SQL + '''' + @colName + ':''+' + 'CONVERT(varchar(255),[' + @colName + ']) + CHAR(13)+CHAR(10)+'

				SELECT @sn = MIN(sn) FROM @myCols WHERE sn > @sn AND colName <> 'RowId'
			END
			IF RIGHT(@SQL, 1) = '+' SELECT @SQL = LEFT(@SQL, LEN(@SQL)-1)

			INSERT INTO #MyRowsTable (RowID) EXEC('SELECT MAX(RowId) FROM ' + @MyTempTableName)
			SELECT @RowID_Last = RowID FROM #MyRowsTable
			DELETE #MyRowsTable

			SET @last_partial = ''
			INSERT INTO #MyRowsTable (RowID) EXEC('SELECT MIN(RowId) FROM ' + @MyTempTableName)
			SELECT @RowID = RowID FROM #MyRowsTable 
			WHILE ISNULL(@RowID, 0) > 0 -- OR @last_partial <> ''
			BEGIN
				SELECT @MyNewSQL = 'SELECT ' + @SQL + '+CHAR(13)+CHAR(10) FROM ' + @MyTempTableName + ' WHERE RowID=' + CONVERT(varchar(10), @RowID)
				INSERT INTO #MyRTFTable (RTF) EXEC (@MyNewSQL)

				SELECT @TempMsg = @last_partial + RTF FROM #MyRTFTable

				IF @RowID = 1
				BEGIN
					SET @TempMsg = 'Dawg alert:' + @WatchName + CHAR(13) + CHAR(10) + 'Date:' + CONVERT(varchar(30), GETDATE()) + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + @TempMsg 
				END
				IF @RowID = @RowID_Last
				BEGIN
					SET @last_partial = ''
				END
									/*** START: INSERT each message chunk ***/
									SELECT @alrt_message = REPLACE(@TempMsg, ' ', '~')

									--- Send message to this recipient.
									-- Look through message data.
									SELECT @msg_chunk = LEFT(@alrt_message, 254)

									WHILE LEN(@msg_chunk) > 0
									BEGIN  -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 0', @msg_chunk

										IF LEN(@msg_chunk) < 254  AND @RowId < @RowId_Last -- Then there is some left over, and wait until next loop to write the row.
										BEGIN -- Don't update yet.  -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 1', @msg_chunk
											SELECT @last_partial = @msg_chunk
											SELECT @msg_chunk = '', @alrt_message = ''
										END

										IF LEN(@msg_chunk) = 254 OR (LEN(@msg_chunk) < 254 AND @RowId = @RowId_Last)
										BEGIN  -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 2', @msg_chunk
											SELECT @last_partial = ''

											INSERT INTO #tblSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
											SELECT @msgid, @msd_seq, 'Text', REPLACE(@msg_chunk, '~', ' ')

											SET @msd_seq = @msd_seq + 1
										END

										IF @msg_chunk = @alrt_message
										BEGIN  -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 3', @msg_chunk
											SET @alrt_message = ''   -- It will never really get here unless the last time, right?
										END

										IF LEN(@alrt_message) > 254
										BEGIN  -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 4', @msg_chunk
											SET @alrt_message = RIGHT(@alrt_message, LEN(@alrt_message) - 254)
											SELECT @msg_chunk = LEFT(@alrt_message, 254)
										END
										ELSE
										BEGIN  -- Very important step here... -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 5', @msg_chunk
											SELECT @msg_chunk = @alrt_message
										END
										
										IF @msd_seq = 20000 /********************************************** WAY TOO BIG LIMITER !!!!! ******************************************/
										BEGIN 
											RAISERROR('Appears to be a problem in WatchdogTotalMailSend or recordset is too large.', 16, 1)
											RETURN
										END
									END
									/*** END: INSERT each message chunk ***/

				/********************* START SECTION: RTF LOGIC 2 **************************/
				DELETE #MyRTFTable
				DELETE #MyRowsTable 
				SET @MyOtherSQL = 'SELECT MIN(RowId) FROM ' + @MyTempTableName + ' WHERE RowID > ' + CONVERT(varchar(10), @RowID)
				INSERT INTO #MyRowsTable (RowID) EXEC(@MyOtherSQL)
				SELECT @RowID = RowID FROM #MyRowsTable 
				/********************* END SECTION: RTF LOGIC 2 **************************/
			END

			-- Group the TRUCKs together, and convert TEMPLATE to ONE message.
			IF EXISTS(SELECT TmailAddress FROM @TotalMailAddresses WHERE TmailAddress LIKE 'T:%')
			BEGIN -- Create duplicates of template where addresses are replaced and type is replaced.
-- @@@@@ LOOOOP HERE to create multiple entries for each truck to avoid overloading the msg_To field.....
				SELECT @TMAddressTypeSN = 9, @Item = ''
				-- SELECT @Item = @Item + SUBSTRING(TmailAddress, 3, LEN(TmailAddress)) + ';' FROM @TotalMailAddresses WHERE TmailAddress LIKE 'T:%'
				-- SELECT @Item = LEFT(@Item, LEN(@Item) - 1) -- Take off the last ';'
				SELECT @Item = MIN(TmailAddress) FROM @TotalMailAddresses WHERE TmailAddress LIKE 'T:%'
				WHILE ISNULL(@Item, '') <> ''
				BEGIN
					INSERT INTO #tblSQLMessage(msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
					-- SELECT msg_Date, 0, REPLACE(msg_To, '@TotalMailAddress', @Item), @TMAddressTypeSN, '', 0, 'admin', 1, @WatchName 
					SELECT msg_Date, 0, REPLACE(msg_To, '@TotalMailAddress', SUBSTRING(@Item, 3, LEN(@Item))), @TMAddressTypeSN, '', 0, 'admin', 1, @WatchName 
					FROM #tblSQLMessage WHERE msg_to = '@TotalMailAddress'

					SELECT @msgid = MAX(msg_id) FROM #tblSQLMessage

					INSERT INTO #tblSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
					SELECT @msgid, t2.msd_seq, 'Text', t2.msd_FieldValue FROM #tblSQLMessage t1 INNER JOIN #tblSQLMessageData t2 ON t1.msg_id = t2.msg_id WHERE t1.msg_to = '@TotalMailAddress'
					
					SELECT @Item = MIN(TmailAddress) FROM @TotalMailAddresses WHERE TmailAddress LIKE 'T:%' AND TmailAddress > @Item
				END
			END

			-- Group the DRIVERs together, and convert TEMPLATE to ONE message.
			IF EXISTS(SELECT TmailAddress FROM @TotalMailAddresses WHERE TmailAddress LIKE 'D:%')
			BEGIN -- Create duplicates of template where addresses are replaced and type is replaced.
				SELECT @TMAddressTypeSN = 10, @Item = ''
				SELECT @Item = @Item + SUBSTRING(TmailAddress, 3, LEN(TmailAddress)) + ';' FROM @TotalMailAddresses WHERE TmailAddress LIKE 'D:%'
				SELECT @Item = LEFT(@Item, LEN(@Item) - 1) -- Take off the last ';'

				INSERT INTO #tblSQLMessage(msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
				SELECT msg_Date, 0, REPLACE(msg_To, '@TotalMailAddress', @Item), @TMAddressTypeSN, '', 5, 'admin', 1, @WatchName FROM #tblSQLMessage WHERE msg_to = '@TotalMailAddress'

				SELECT @msgid = MAX(msg_id) FROM #tblSQLMessage

				INSERT INTO #tblSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
				SELECT @msgid, t2.msd_seq, 'Text', t2.msd_FieldValue FROM #tblSQLMessage t1 INNER JOIN #tblSQLMessageData t2 ON t1.msg_id = t2.msg_id WHERE t1.msg_to = '@TotalMailAddress'
			END

			IF ( EXISTS(SELECT * FROM @TotalMailAddresses WHERE TmailAddress LIKE 'L:%' OR TmailAddress LIKE 'G:%') AND ISNULL(@FormatTotalMailGroupAndLogonMsgsAsTabular_YN, 'N') = 'N')
			BEGIN
				-- Group the TMLOGINs together, and convert TEMPLATE to ONE message.
				IF EXISTS(SELECT TmailAddress FROM @TotalMailAddresses WHERE TmailAddress LIKE 'L:%')
				BEGIN -- Create duplicates of template where addresses are replaced and type is replaced.
					SELECT @TMAddressTypeSN = 1, @Item = ''
					SELECT @Item = @Item + SUBSTRING(TmailAddress, 3, LEN(TmailAddress)) + ';' FROM @TotalMailAddresses WHERE TmailAddress LIKE 'L:%'
					SELECT @Item = LEFT(@Item, LEN(@Item) - 1) -- Take off the last ';'

					INSERT INTO #tblSQLMessage(msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
					SELECT msg_Date, 0, REPLACE(msg_To, '@TotalMailAddress', @Item), @TMAddressTypeSN, '', 5, 'admin', 1, @WatchName 
					FROM #tblSQLMessage WHERE msg_to = '@TotalMailAddress'

					SELECT @msgid = MAX(msg_id) FROM #tblSQLMessage

					INSERT INTO #tblSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
					SELECT @msgid, t2.msd_seq, 'Text', t2.msd_FieldValue FROM #tblSQLMessage t1 INNER JOIN #tblSQLMessageData t2 ON t1.msg_id = t2.msg_id WHERE t1.msg_to = '@TotalMailAddress'
				END

				-- Group the DispatchGroups together, and convert TEMPLATE to ONE message.
				IF EXISTS(SELECT TmailAddress FROM @TotalMailAddresses WHERE TmailAddress LIKE 'G:%')
				BEGIN -- Create duplicates of template where addresses are replaced and type is replaced.
					SELECT @TMAddressTypeSN = 3, @Item = ''
					SELECT @Item = @Item + SUBSTRING(TmailAddress, 3, LEN(TmailAddress)) + ';' FROM @TotalMailAddresses WHERE TmailAddress LIKE 'G:%'
					SELECT @Item = LEFT(@Item, LEN(@Item) - 1) -- Take off the last ';'

					INSERT INTO #tblSQLMessage(msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
					SELECT msg_Date, 0, REPLACE(msg_To, '@TotalMailAddress', @Item), @TMAddressTypeSN, '', 5, 'admin', 1, @WatchName FROM #tblSQLMessage WHERE msg_to = '@TotalMailAddress'

					SELECT @msgid = MAX(msg_id) FROM #tblSQLMessage

					INSERT INTO #tblSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
					SELECT @msgid, t2.msd_seq, 'Text', t2.msd_FieldValue FROM #tblSQLMessage t1 INNER JOIN #tblSQLMessageData t2 ON t1.msg_id = t2.msg_id WHERE t1.msg_to = '@TotalMailAddress'
				END
			END

			-- This record is the "TEMPLATE" used.
			SELECT @msgid = MAX(msg_id) FROM #tblSQLMessage WHERE msg_to = '@TotalMailAddress'
			DELETE #tblSQLMessageData WHERE msg_id = @msgid
			DELETE #tblSQLMessage WHERE msg_id = @msgid

			-- Clean up.
			SELECT @msg_chunk ='', @alrt_message = '', @TempMsg = '', @SQL = ''
			SELECT @msgid = MAX(msg_id) FROM #tblSQLMessage WHERE msg_to = '@TotalMailAddress'
			DELETE #tblSQLMessageData WHERE msg_id = @msgid
			DELETE #tblSQLMessage WHERE msg_id = @msgid
		END
		/*****************************************************************************************************/
		/** END: For alerts going to TotalMail Trucks or TotalMail Drivers **/
		/*****************************************************************************************************/

		/*****************************************************************************************************/
		/** START: For alerts going to TotalMail Logins or TotalMail Dispatch Groups **/
		/*****************************************************************************************************/
		IF ISNULL(@FormatTotalMailGroupAndLogonMsgsAsTabular_YN, 'N') = 'Y' AND EXISTS(SELECT * FROM @TotalMailAddresses WHERE TmailAddress LIKE 'L:%' OR TmailAddress LIKE 'G:%')
		BEGIN
			SET @DawgHeader = '\b Dawg alert: \b0 ' + @WatchName + CHAR(13) + CHAR(10) + '\par \b Date: \b0 ' + CONVERT(varchar(30), GETDATE()) + CHAR(13) + CHAR(10) + '\par'

			-- This becomes our 'TEMPLATE' message, and if there are multiple recipient TYPES, then we will duplicate by simple queries at the end.
			INSERT INTO #tblSQLMessage(msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
			SELECT GETDATE(), 0, '@TotalMailAddress', -1, '', 5, 'admin', 1, @WatchName

			SELECT @msd_seq = 1, @msgid = MAX(msg_id) FROM #tblSQLMessage

			/********************* START SECTION: RTF LOGIC 1 **************************/
			/** Colllect column information for this table, and add a RowID if necessary so that we can loop through in the right order. **/
			SELECT @SQL = '', @TableHeader = '', @colName = ''

			SELECT @sn = MIN(sn) FROM @myCols WHERE colName <> 'RowId'
			WHILE ISNULL(@sn, 0) > 0
			BEGIN
				SELECT @colName = colName FROM @myCols WHERE sn = @sn
				SELECT @SQL = @SQL + '''\pard \intbl '' + ' + 'CONVERT(varchar(255),[' + @colName + ']) + ''\cell'' + CHAR(13)+CHAR(10)+'

				INSERT INTO #tLengths(colName, maxLength)
				EXEC('SELECT ''' + @colName + ''', MAX(LEN(ISNULL([' + @colName + '], ''''))) FROM ' + @MyTempTableName)

				SELECT @TableHeader = @TableHeader + '\pard\intbl\b\i ' + @colName + ' \i0\b0\cell' + CHAR(13) + CHAR(10)

				SELECT @sn = MIN(sn) FROM @myCols WHERE sn > @sn AND colName <> 'RowId'
			END
			IF RIGHT(@SQL, 1) = '+' SELECT @SQL = LEFT(@SQL, LEN(@SQL)-1)

			SELECT @TableHeader = @TableHeader + '\pard \intbl \row' + CHAR(13) + CHAR(10)

			UPDATE #tLengths SET maxLength = LEN(colName) WHERE LEN(colName) > maxLength -- Make sure to account for column names.
			UPDATE #tLengths SET maxLength = 4 WHERE maxLength < 4
			UPDATE #tLengths SET twipsCumulative = (SELECT SUM(@TWIPS_PER_CHAR * maxLength) FROM #tLengths t11 INNER JOIN @myCols t22 ON t11.colName = t22.colName WHERE t22.sn <= t2.sn)
			FROM #tLengths t1 INNER JOIN @myCols t2 ON t1.colName = t2.colName

			UPDATE #tLengths SET twipsCumulative = 500 WHERE twipsCumulative < 500

			SELECT @RowHeader = '\trowd\trautofit1 \trqc\trgaph108\trrh280\trleft36' + CHAR(13) + CHAR(10)
			SELECT @RowHeader = @RowHeader + '\clbrdrt\brdrdb\clbrdrl\brdrth\clbrdr\brdrsh\brdrs\clbrdrr\brdrdb\cellx' + CONVERT(varchar(10), twipsCumulative) + CHAR(13) + CHAR(10)
			FROM #tLengths t1 INNER JOIN @myCols t2 ON t1.colName = t2.colName ORDER BY t2.sn

			INSERT INTO #MyRowsTable (RowID) EXEC('SELECT MAX(RowId) FROM ' + @MyTempTableName)
			SELECT @RowID_Last = RowID FROM #MyRowsTable
			DELETE #MyRowsTable

			SET @last_partial = ''

			INSERT INTO #MyRowsTable (RowID) EXEC('SELECT MIN(RowId) FROM ' + @MyTempTableName)
			SELECT @RowID = RowID FROM #MyRowsTable 
			WHILE ISNULL(@RowID, 0) > 0 -- OR @last_partial <> ''
			BEGIN
				SELECT @MyNewSQL = 'SELECT ''' + @RowHeader + ''' + ' + @SQL + ' + ''\pard \intbl \row'' + CHAR(13) + CHAR(10) FROM ' + @MyTempTableName + ' WHERE RowID=' + CONVERT(varchar(10), @RowID)
				INSERT INTO #MyRTFTable (RTF) EXEC (@MyNewSQL)
			/********************* END SECTION: RTF LOGIC 1 **************************/
				SELECT @TempMsg = @last_partial + RTF FROM #MyRTFTable

				IF @RowID = 1
				BEGIN
					SET @TempMsg = '{\rtf1\ansi\deff0 {\fonttbl {\f0 Courier;}}' + CHAR(13) + CHAR(10) + '{\colortbl;\red0\green0\blue0;\red255\green0\blue0;\red0\green0\blue255;}' + @DawgHeader + CHAR(13) + CHAR(10) + '\par' + CHAR(13) + CHAR(10)
						+ REPLACE(@RowHeader, '\clbrdrl', '\clcbpat2\clbrdrl') + @TableHeader + @TempMsg  --clcbpat2\clbrdrl
				END
				IF @RowID = @RowID_Last
				BEGIN
					SET @TempMsg = @TempMsg + ' \pard' + CHAR(13) + CHAR(10) + '}'
					SET @last_partial = ''
				END

									/*** START: INSERT each message chunk ***/
									SELECT @alrt_message = REPLACE(@TempMsg, ' ', '~')

									--- Send message to this recipient.
									-- Look through message data.
									SELECT @msg_chunk = LEFT(@alrt_message, 254)

									WHILE LEN(@msg_chunk) > 0
									BEGIN  -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 0', @msg_chunk
										IF LEN(@msg_chunk) < 254  AND @RowId < @RowId_Last -- Then there is some left over, and wait until next loop to write the row.
										BEGIN -- Don't update yet.  -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 1', @msg_chunk
											SELECT @last_partial = @msg_chunk
											SELECT @msg_chunk = '', @alrt_message = ''
										END

										IF LEN(@msg_chunk) = 254 OR (LEN(@msg_chunk) < 254 AND @RowId = @RowId_Last)
										BEGIN  -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 2', @msg_chunk
											SELECT @last_partial = ''

											INSERT INTO #tblSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
											SELECT @msgid, @msd_seq, 'Text', REPLACE(@msg_chunk, '~', ' ')

											SET @msd_seq = @msd_seq + 1
										END

										IF @msg_chunk = @alrt_message
										BEGIN  -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 3', @msg_chunk
											SET @alrt_message = ''   -- It will never really get here unless the last time, right?
										END

										IF LEN(@alrt_message) > 254
										BEGIN  -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 4', @msg_chunk
											SET @alrt_message = RIGHT(@alrt_message, LEN(@alrt_message) - 254)
											SELECT @msg_chunk = LEFT(@alrt_message, 254)
										END
										ELSE
										BEGIN  -- Very important step here... -- IF @RowId = @RowId_Last INSERT INTO watchdogloginfo ([Event], [MoreInfo]) SELECT 'Step 5', @msg_chunk
											SELECT @msg_chunk = @alrt_message
										END
										
										IF @msd_seq = 20000 /********************************************** WAY TOO BIG LIMITER !!!!! ******************************************/
										BEGIN 
											RAISERROR('Appears to be a problem in WatchdogTotalMailSend or recordset is too large.', 16, 1)
											RETURN
										END
									END
									/*** END: INSERT each message chunk ***/

				/********************* START SECTION: RTF LOGIC 2 **************************/
				DELETE #MyRTFTable
				DELETE #MyRowsTable 
				SET @MyOtherSQL = 'SELECT MIN(RowId) FROM ' + @MyTempTableName + ' WHERE RowID > ' + CONVERT(varchar(10), @RowID)
				INSERT INTO #MyRowsTable (RowID) EXEC(@MyOtherSQL)
				SELECT @RowID = RowID FROM #MyRowsTable 
				/********************* END SECTION: RTF LOGIC 2 **************************/
			END

			-- Group the TMLOGINs together, and convert TEMPLATE to ONE message.
			IF EXISTS(SELECT TmailAddress FROM @TotalMailAddresses WHERE TmailAddress LIKE 'L:%')
			BEGIN -- Create duplicates of template where addresses are replaced and type is replaced.
				SELECT @TMAddressTypeSN = 1, @Item = ''
				SELECT @Item = @Item + SUBSTRING(TmailAddress, 3, LEN(TmailAddress)) + ';' FROM @TotalMailAddresses WHERE TmailAddress LIKE 'L:%'
				SELECT @Item = LEFT(@Item, LEN(@Item) - 1) -- Take off the last ';'

				INSERT INTO #tblSQLMessage(msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
				SELECT msg_Date, 0, REPLACE(msg_To, '@TotalMailAddress', @Item), @TMAddressTypeSN, '', 5, 'admin', 1, @WatchName 
				FROM #tblSQLMessage WHERE msg_to = '@TotalMailAddress'

				SELECT @msgid = MAX(msg_id) FROM #tblSQLMessage

				INSERT INTO #tblSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
				SELECT @msgid, t2.msd_seq, 'Text', t2.msd_FieldValue FROM #tblSQLMessage t1 INNER JOIN #tblSQLMessageData t2 ON t1.msg_id = t2.msg_id WHERE t1.msg_to = '@TotalMailAddress'
			END

			-- Group the DispatchGroups together, and convert TEMPLATE to ONE message.
			IF EXISTS(SELECT TmailAddress FROM @TotalMailAddresses WHERE TmailAddress LIKE 'G:%')
			BEGIN -- Create duplicates of template where addresses are replaced and type is replaced.
				SELECT @TMAddressTypeSN = 3, @Item = ''
				SELECT @Item = @Item + SUBSTRING(TmailAddress, 3, LEN(TmailAddress)) + ';' FROM @TotalMailAddresses WHERE TmailAddress LIKE 'G:%'
				SELECT @Item = LEFT(@Item, LEN(@Item) - 1) -- Take off the last ';'

				INSERT INTO #tblSQLMessage(msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
				SELECT msg_Date, 0, REPLACE(msg_To, '@TotalMailAddress', @Item), @TMAddressTypeSN, '', 5, 'admin', 1, @WatchName FROM #tblSQLMessage WHERE msg_to = '@TotalMailAddress'

				SELECT @msgid = MAX(msg_id) FROM #tblSQLMessage

				INSERT INTO #tblSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
				SELECT @msgid, t2.msd_seq, 'Text', t2.msd_FieldValue FROM #tblSQLMessage t1 INNER JOIN #tblSQLMessageData t2 ON t1.msg_id = t2.msg_id WHERE t1.msg_to = '@TotalMailAddress'
			END

			SELECT @msgid = MAX(msg_id) FROM #tblSQLMessage WHERE msg_to = '@TotalMailAddress'
			DELETE #tblSQLMessageData WHERE msg_id = @msgid
			DELETE #tblSQLMessage WHERE msg_id = @msgid
		END
		/*****************************************************************************************************/
		/** END: For alerts going to TotalMail Logins or TotalMail Dispatch Groups **/
		/*****************************************************************************************************/
	END

	DELETE #tblSQLMessageData FROM #tblSQLMessageData t1 WHERE RTRIM(msd_fieldValue) = CHAR(13) + CHAR(10) AND msd_seq = (SELECT MAX(t2.msd_seq) FROM #tblSQLMessageData t2 WHERE t2.msg_id = t1.msg_id)

	IF ISNULL(@CalledFromDawgProcessing_YN, 'N') = 'Y'
	BEGIN
		BEGIN TRAN
			SELECT @sn = MIN(msg_id) FROM #tblSQLMessage --- NOTE: A little confusing.  @sn becomes the msg_id from the TEMP table.  And @msgid is the msg_id for the newly inserted record in the table read by TotalMail.
			WHILE ISNULL(@sn, -1) > 0
			BEGIN
				INSERT INTO tblSQLMessage (msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
				SELECT msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject FROM #tblSQLMessage WHERE msg_id = @sn

				SELECT @msgid = SCOPE_IDENTITY()

				INSERT INTO tblSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
				SELECT @msgid, msd_seq, msd_FieldName, msd_FieldValue FROM #tblSQLMessageData WHERE msg_id = @sn ORDER BY msd_seq

				SELECT @sn = MIN(msg_id) FROM #tblSQLMessage WHERE msg_id > @sn
			END
		COMMIT
	END
	ELSE
	BEGIN
		SELECT * FROM #tblSQLMessage ORDER BY msg_id
		SELECT * FROM #tblSQLMessageData ORDER BY msg_id, msd_seq
	END

GO
GRANT EXECUTE ON  [dbo].[WatchdogTotalMailSend] TO [public]
GO
