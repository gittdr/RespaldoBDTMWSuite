SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[WatchDog_AlertToTractor]
(
	@MinThreshold float = 200,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogAlertToTractor',
	@WatchName varchar(255)='WatchAlertToTractor',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar(50) = 'Selected'

	-- Behavior parameters
	-- @EmailMessageMode possible values are 'None', 'AlertSummary', 'ActiveAlerts'
	--			@EmailMessageMode='None': No email gets sent. Perhaps user only wants to send mobile comm messages to trucks.
	--			@EmailMessageMode='AlertSummary': Show what alerts would get sent to the driver based on current rules.
	--			@EmailMessageMode='ActiveAlerts': Show what alerts are ACTIVE after this procedure runs.
	,@EmailMessageMode varchar(20)	= 'AlertSummary'

	,@SendViaTotalMail_YN varchar(1) = 'Y'
	,@AlertLocatorType varchar(255)=''  --	'InState', 'DistanceToCity' --- Leaving blank includes both.
	,@DaysToKeepAfterExpiration int = 1000   -- This is include simply to purge OLD alert data.  BEWARE. A user could very easily wipe out their data. 
	--			This procedure will NOT do anything with a negative value to prevent removal of current or future alerts.

	-- Test message to driver.
	,@TestTruck varchar(8) = ''		-- If this is populated, then IT IS THE ONLY MESSAGE that gets sent, and no other processing is done.
	,@TestMessage varchar(255) = ''
	
	-- Pre-production ONLY.
	,@DaysBackForCheckcalls int = 3  -- Don't look at any checkcalls older than this.  Might not need in production.
	,@TestMode_YN varchar(1) = 'N'

	-- Filters
	,@AlertMsgTypeList varchar(255)=''  --	'WEATHER ALERT', 'SECURITY ALERT'
	,@TrcType1List varchar(255)=''
	,@TrcType2List varchar(255)=''
	,@TrcType3List varchar(255)=''
	,@TrcType4List varchar(255)=''
	,@TractorList varchar(255)=''
)

AS
	Set NoCount On

	/*
	EXEC WatchDog_AlertToTractor @ExecuteDirectly = 1
			,@DaysBackForCheckcalls = 90
			,@TestMode_YN = 'N'
			,@EmailMessageMode = 'AlertSummary'

	EXEC WatchDog_AlertToTractor @ExecuteDirectly = 1
			,@DaysBackForCheckcalls = 90
			,@TestMode_YN = 'N'
			,@EmailMessageMode = 'ActiveAlerts'
	*/
		
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	DECLARE @msgid int

	--Reserved/Mandatory WatchDog Variables

	CREATE TABLE #tTractors (trc_number varchar(8), ckc_number int, trc_state varchar(6), ckc_date datetime, ckc_latseconds int, ckc_longseconds int)

	DECLARE @WithinAlertZone TABLE (
		sn int IDENTITY,
		AlreadyActive_YN varchar(1) DEFAULT('N'),
		trc_number varchar(8),
		alrt_recid int,
		alrt_state varchar(6) not null,
		alrt_ctycode int not null,
		alrt_proximity int,
		alrt_incabalert varchar(1),
		alrt_begindate smalldatetime not null,
		alrt_enddate smalldatetime not null,
		alrt_msgtype varchar(50),
		alrt_message varchar(4000),
		ckc_number int,
		trc_state varchar(6),
		ckc_date datetime,
		ckc_latseconds int,
		ckc_longseconds int,
		distance float
	)

	IF NOT EXISTS(SELECT * FROM tmw_custom_alerts_master) AND NOT EXISTS(SELECT * FROM tmw_custom_alerts_active)
		RETURN

	DECLARE @GETDATE datetime
	IF @TestMode_YN = 'Y'
	BEGIN
		-- COMMENT the following line for production deployment.
		SET @GETDATE = '20091123 18:40'
	END
	ELSE
	BEGIN
		-- UNcomment the following line for production deployment.
		SET @GETDATE = GETDATE()
	END

	-- Initialize LIST parameters.
	Set @AlertMsgTypeList= ',' + ISNULL(@AlertMsgTypeList, '') + ','
	Set @TrcType1List= ',' + ISNULL(@TrcType1List,'') + ','
	Set @TrcType2List= ',' + ISNULL(@TrcType2List,'') + ','
	Set @TrcType3List= ',' + ISNULL(@TrcType3List,'') + ','
	Set @TrcType4List= ',' + ISNULL(@TrcType4List,'') + ','
	Set @TractorList= ',' + ISNULL(@TractorList,'') + ','

	-- Get active tractors and their most recent position information.
	BEGIN
		-- Step 1: Basic filter
		INSERT INTO #tTractors (trc_number, ckc_number, trc_state)
		SELECT trc_number ,-1, ''
		FROM tractorprofile 
		WHERE 
			@GETDATE >= trc_startdate 
				AND @GETDATE < trc_retiredate
				AND (@TrcType1List =',,' or CHARINDEX(',' + trc_type1 + ',', @TrcType1List) >0)
       			AND (@TrcType2List =',,' or CHARINDEX(',' + trc_type2 + ',', @TrcType2List) >0)
				AND (@TrcType3List =',,' or CHARINDEX(',' + trc_type3 + ',', @TrcType3List) >0)
				AND (@TrcType4List =',,' or CHARINDEX(',' + trc_type4 + ',', @TrcType4List) >0)
				AND (@TractorList =',,' or CHARINDEX(',' + trc_number + ',', @TractorList) >0)
				AND ISNULL(trc_number, 'UNKNOWN') <> 'UNKNOWN'

		-- Step 2: Get tractors last checkcall so that we can get its state.
		UPDATE #tTractors 
		SET ckc_number = (SELECT MAX(ckc_number) FROM checkcall WHERE ckc_tractor = #tTractors.trc_number)

		-- Step 3: Find a recent lat/long that is non-NULL if necessary.
		UPDATE #tTractors 
		SET ckc_number = (SELECT MAX(ckc_number) FROM checkcall WHERE ckc_tractor = #tTractors.trc_number
								AND ckc_latseconds IS NOT NULL 
								AND ckc_longseconds IS NOT NULL	)
		WHERE ckc_latseconds IS NULL OR ckc_longseconds IS NULL
		
		-- Step 4: Get state, date, latitude, and longitude.
		UPDATE #tTractors SET 
			trc_state = t2.ckc_state,
			ckc_date = t2.ckc_date,
			ckc_latseconds = t2.ckc_latseconds,
			ckc_longseconds = t2.ckc_longseconds
		FROM #tTractors t1 INNER JOIN checkcall t2 ON t1.ckc_number = t2.ckc_number 

	END

	-- **********************************
	-- **** Alerts by state ONLY.
	-- **********************************
	IF @AlertLocatorType = '' OR @AlertLocatorType = 'InState'
	BEGIN
		INSERT INTO @WithinAlertZone (trc_number, alrt_recid, alrt_state, alrt_ctycode, alrt_proximity, alrt_incabalert, alrt_begindate, alrt_enddate, alrt_msgtype, alrt_message, ckc_number, trc_state, ckc_date, ckc_latseconds, ckc_longseconds)
		SELECT t1.trc_number, t2.alrt_recid, t2.alrt_state, t2.alrt_ctycode, t2.alrt_proximity, t2.alrt_incabalert, t2.alrt_begindate, t2.alrt_enddate, t2.alrt_msgtype, t2.alrt_message, 
				t1.ckc_number, t1.trc_state, t1.ckc_date, t1.ckc_latseconds, t1.ckc_longseconds
		FROM #tTractors t1 INNER JOIN tmw_custom_alerts_master t2 ON t1.trc_state = alrt_state
		WHERE @GETDATE >= alrt_begindate AND @GETDATE < alrt_enddate
			AND t2.alrt_ctycode = 0
			AND (@AlertMsgTypeList =',,' or CHARINDEX(',' + alrt_msgtype + ',', @AlertMsgTypeList) >0)
			AND ISNULL(t2.alrt_incabalert, 'N') = 'Y'
		-- ORDER BY mpp_state, trc_number
	END

	-- **********************************
	-- **** Alerts by Proximity to City.
	-- **********************************
	IF @AlertLocatorType = '' OR @AlertLocatorType = 'DistanceToCity'
	BEGIN
		INSERT INTO @WithinAlertZone (trc_number, alrt_recid, alrt_state, alrt_ctycode, alrt_proximity, alrt_incabalert, alrt_begindate, alrt_enddate, alrt_msgtype, alrt_message, ckc_number, trc_state, ckc_date, ckc_latseconds, ckc_longseconds, distance)
		SELECT t1.trc_number, t2.alrt_recid, t2.alrt_state, t2.alrt_ctycode, t2.alrt_proximity, t2.alrt_incabalert, t2.alrt_begindate, t2.alrt_enddate, t2.alrt_msgtype, t2.alrt_message, 
				t1.ckc_number, t1.trc_state, t1.ckc_date, t1.ckc_latseconds, t1.ckc_longseconds, dbo.fnc_AirMilesBetweenLatLongSeconds(cty_latitude * 3600, ckc_latseconds, cty_longitude * 3600, ckc_longseconds)
		FROM (tmw_custom_alerts_master t2 INNER JOIN city t3 ON t2.alrt_ctycode = t3.cty_code), #tTractors t1
		WHERE @GETDATE >= alrt_begindate AND @GETDATE < alrt_enddate
			AND t2.alrt_ctycode <> 0
			AND (@AlertMsgTypeList =',,' or CHARINDEX(',' + alrt_msgtype + ',', @AlertMsgTypeList) >0)
			AND t1.ckc_latseconds IS NOT NULL 
			AND t1.ckc_longseconds IS NOT NULL
			-- @lat1, @long1 ==> from city table. cty_latitude, cty_longitude
			-- @lat2, @long2 ==> from manpowerprofile table.  -- mpp_gps_latitude, mpp_gps_longitude
			AND dbo.fnc_AirMilesBetweenLatLongSeconds(cty_latitude * 3600, ckc_latseconds, cty_longitude * 3600, ckc_longseconds) < t2.alrt_proximity
			AND ISNULL(t2.alrt_incabalert, 'N') = 'Y'
		ORDER BY trc_state, trc_number
	END	

	--*** Set Active_YN = 'Y' if a record in @WithinAlertZone is also in tmw_custom_alerts_active (because we don't want to resend to the driver).
	UPDATE @WithinAlertZone SET AlreadyActive_YN = 'Y' 
	FROM @WithinAlertZone t1
	WHERE EXISTS(SELECT * FROM tmw_custom_alerts_active WHERE t1.alrt_recid = alrt_recid AND t1.trc_number = trc_number)

	--(AddAndSendAlert) *** If Active_YN = 'N', then 1) send an alert to tractor, and 2) insert the alert into tmw_custom_alerts_active.
	BEGIN
		INSERT INTO dbo.tmw_custom_alerts_active (alrt_recid, trc_number, dtCreated, dtLastMetCriteria)
		SELECT alrt_recid, trc_number, @GETDATE, @GETDATE
		FROM @WithinAlertZone WHERE AlreadyActive_YN = 'N'

	DECLARE @sn int, @trc_number varchar(8), @alrt_msgtype varchar(50), @alrt_state varchar(6), @alrt_begindate datetime, @alrt_enddate datetime, @alrt_message varchar(4000)
	DECLARE @msg_chunk varchar(255), @msd_seq int

		IF @SendViaTotalMail_YN = 'Y'
		BEGIN
			-- set @msgid = 1
			SELECT @sn = MIN(sn) FROM @WithinAlertZone WHERE AlreadyActive_YN = 'N'
			WHILE ISNULL(@sn, 0) > 0
			BEGIN
				SELECT @trc_number = trc_number, @alrt_msgtype = alrt_msgtype, @alrt_state = alrt_state, @alrt_begindate = alrt_begindate, @alrt_enddate = alrt_enddate, @alrt_message = alrt_message 
				FROM @WithinAlertZone WHERE sn = @sn

				BEGIN TRANSACTION
					--- Loop through alerts to send.
					INSERT INTO TMSQLMessage(msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
					SELECT GETDATE(), 0, @trc_number, 4, '', 5, 'Admin', 0, @alrt_msgtype
					SELECT @msgid = SCOPE_IDENTITY()

					-- Look through message data.
					SET @msd_seq = 1
					SELECT @msg_chunk = LEFT(@alrt_message, 254)
					WHILE LEN(@msg_chunk) > 0
					BEGIN
						INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
						VALUES (@msgid, @msd_seq, 'Text01', @msg_chunk)

						IF @msg_chunk = @alrt_message
							SET @alrt_message = ''

						IF LEN(@alrt_message) > 254
						BEGIN
							SET @alrt_message = RIGHT(@alrt_message, LEN(@alrt_message) - 254)
							SELECT @msg_chunk = LEFT(@alrt_message, 254)
						END
						ELSE
						BEGIN
							SELECT @msg_chunk = @alrt_message
						END
						
						SET @msd_seq = @msd_seq + 1
						if @msd_seq = 20 return
					END
				COMMIT TRANSACTION

				SELECT @sn = MIN(sn) FROM @WithinAlertZone WHERE AlreadyActive_YN = 'N' AND sn > @sn
			END

		END
	END

	--*** If Active_YN = 'Y', then 1) update dtLastMetCriteria.
	UPDATE dbo.tmw_custom_alerts_active SET dtLastMetCriteria = @GETDATE
	FROM dbo.tmw_custom_alerts_active t1 INNER JOIN @WithinAlertZone t2 ON t1.alrt_recid = t2.alrt_recid AND t1.trc_number = t2.trc_number

	--(RemoveItemsFromActiveAlerts) *** Remove items from tmw_custom_alerts_active that are NOT IN @WithinAlertZone.
	DELETE tmw_custom_alerts_active 
	FROM tmw_custom_alerts_active t1
	WHERE NOT EXISTS(SELECT * FROM @WithinAlertZone t2 WHERE t1.alrt_recid = t2.alrt_recid AND t1.trc_number = t2.trc_number)

	-- Purge OLD data from tmw_custom_alerts_master if the alert no longer applies.
	IF @DaysToKeepAfterExpiration > 0  -- This is to prevent user from specifying a negative number and removing all data.
	BEGIN
		DELETE tmw_custom_alerts_master WHERE DATEADD(day, @DaysToKeepAfterExpiration, alrt_enddate) < @GETDATE
	END

	DECLARE @TableSuffix varchar(20)
	IF @EmailMessageMode = 'AlertSummary'  -- Do this if you want to notify someone every time alerts get sent to the driver.
	BEGIN
		SELECT [GETDATE] = @GETDATE, * INTO #TempResultsAlertSummary
		FROM @WithinAlertZone
		WHERE AlreadyActive_YN = 'N'

		SET @TableSuffix = 'AlertSummary'
	END
	ELSE IF @EmailMessageMode = 'ActiveAlerts'
	BEGIN
		SELECT [GETDATE] = @GETDATE, t1.*, t2.alrt_state, t2.alrt_ctycode, t2.alrt_proximity, t2.alrt_incabalert, t2.alrt_begindate, t2.alrt_enddate, t2.alrt_msgtype, t2.alrt_message 
		INTO #TempResultsActiveAlerts
		FROM tmw_custom_alerts_active t1 INNER JOIN tmw_custom_alerts_master t2 ON t1.alrt_recid = t2.alrt_recid

		SET @TableSuffix = 'ActiveAlerts'
	END
	ELSE
	BEGIN
		SELECT '' AS 'No data to send' INTO #tempResults WHERE 1=2
		SET @TableSuffix = ''
	END


	--Commits the results to be used in the wrapper
	IF @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	BEGIN
		SET @SQL = 'Select * from #TempResults' + @TableSuffix
	END
	ELSE
	BEGIN
		SET @COLSQL = ''
		EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		SET @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults' + @TableSuffix
	END
	
	EXEC (@SQL)
	
	SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[WatchDog_AlertToTractor] TO [public]
GO
