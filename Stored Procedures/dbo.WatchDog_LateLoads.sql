SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[WatchDog_LateLoads]           
	(
		@MinThreshold FLOAT = 14,
		@MinsBack INT = -44640, -- 31 days
		@TempTableName VARCHAR(255) = '##WatchDogGlobalLateLoads',
		@WatchName VARCHAR(255)='WatchLateLoads',
		@ThresholdFieldName VARCHAR(255) = null,
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@AirMilesAdjustmentPct FLOAT = .10,
		@MaxAvgMilesPerHour INT = 45,
		@RevType1 VARCHAR(255)='',
		@RevType2 VARCHAR(255)='',
		@RevType3 VARCHAR(255)='',
		@RevType4 VARCHAR(255)='',
		@TeamLeader VARCHAR(255)='',
		@OnlyStopEventList VARCHAR(255)='',
		@ExcludeLastStopYN CHAR(1)='N',
		@ExcludeFirstStopYN CHAR(1) = 'N',
		@IncludeOnlyLegheaderType1 VARCHAR(255) = '',
		@IncludeOnlyLghCreateApp VARCHAR(255) = '',
		@ExcludeLghCreateApp VARCHAR(255) = '',
		@BillToID varchar(255) = '',
		@Priority varchar(255) = '',
		@OnlyIncludeLegOutStatusList varchar(255) = 'STD,DSP',  --AVL
		@ExcludeLegOutStatusList varchar(255) = '', -- ''
		@UnknownLocationDataMode varchar(12) = 'ALL', -- ONLY, EXCLUDE
		@TooManyMilesThreshold int = 3500,
		@ParameterToUseForDynamicEmail varchar(140)=''
 	)
						
AS

	SET NOCOUNT ON
	
	/***************************************************************
	Procedure Name:    WatchDog_StopEvent
	Author/CreateDate: Lori Brickley / 1-13-2005
	Purpose: Provides a list of user defined stop events which occured within the last x minutes
			Driver is IS started...

	What can be done:
		InRouteAndLate
				1) Find out if driver hasn't sent macros.
				2) Alert the customer.
		
		Late (assigned), but not started
				1) Find out if driver hasn't sent macros.
				2) Is the resource on a previous trip and not finished?
				3) Assign other resources.

		Resources not on legheader - see OldAvailableOrders
							

		In the future, we may want option to include ALL future stops.

	Revision History:	
	****************************************************************/
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL VARCHAR(8000)
	Declare @COLSQL VARCHAR(4000)
	--Reserved/Mandatory WatchDog Variables
	
	--Standard Parameter Initialization
	SET @RevType1= ',' + ISNULL(@RevType1,'') + ','
	SET @RevType2= ',' + ISNULL(@RevType2,'') + ','
	SET @RevType3= ',' + ISNULL(@RevType3,'') + ','
	SET @RevType4= ',' + ISNULL(@RevType4,'') + ','
	SET @TeamLeader = ',' + ISNULL(@TeamLeader,'') + ','
	SET @OnlyStopEventList = ',' + ISNULL(@OnlyStopEventList,'') + ','
	SET @IncludeOnlyLegheaderType1 = ',' + ISNULL(@IncludeOnlyLegheaderType1,'') + ','
	SET @IncludeOnlyLghCreateApp = ',' + ISNULL(@IncludeOnlyLghCreateApp,'') + ','
	SET @ExcludeLghCreateApp = ',' + ISNULL(@ExcludeLghCreateApp,'') + ','
	SET @BillToID = ',' + ISNULL(@BillToID,'') + ','
	SET @Priority = ',' + ISNULL(@Priority,'') + ','
	SET @OnlyIncludeLegOutStatusList = ',' + ISNULL(@OnlyIncludeLegOutStatusList, '') + ','
	SET @ExcludeLegOutStatusList = ',' + ISNULL(@ExcludeLegOutStatusList, '') + ','
	
	
	/****************************************************************************
		Create temp table #TempResultsStep1 where the following conditions are met:
		
		The load is already late (not arrived, past latest scheduled arrival)
		The load is going to be late (based on shortest distance at average miles per hour
				will still be late)
		The load might be late (based on shortest distance at average miles per hour
				might be late)
	
	*****************************************************************************/
	
	SELECT 	trc_gps_date as GPSDateTime, 
			trc_gps_desc as LastGps, 
			cty_nmstct as Destination,
			Convert(int ,ISNULL(	
						-- Convert values from degrees to radians 
				(
				Select 
				Acos(
					cos(	(
							Convert(decimal(6,2),(convert(float,trc_gps_latitude)/3600.0))
							* 3.14159265358979 / 180.0)  )  *
					cos(	((convert(float,t4.cmp_latseconds)/3600.0) * 3.14159265358979 / 180.0)  )  *
			                cos (  
						(
							Convert(decimal(6,2),(convert(float,trc_gps_longitude)/3600.0))
						* 3.14159265358979 / 180.0) - 
						((convert(float,t4.cmp_longseconds)/3600.0) * 3.14159265358979 / 180.0)
					    )	+
					Sin (	(
							Convert(decimal(6,2),(convert(float, trc_gps_latitude)/3600.0))
						* 3.14159265358979 / 180.0) ) *
					Sin (	((convert(float,t4.cmp_latseconds)/3600.0) * 3.14159265358979 / 180.0) ) 	
				    ) * 3956.5
				)
			,9999) -- ISNULL
			) AS AirMilesToGo ,

/* CONVERT(varchar(16), CONVERT(datetime, PSDateTime), 121), LastGps, Destination, AirMilesToGo, EstimatedMilesToGo,
	CONVERT(varchar(16), Now, 121), CONVERT(varchar(16), CONVERT(datetime, ScheduledLatest), 121), ETA */

			0 EstimatedMilesToGo, 
			GETDATE() AS Now, 
			t2.stp_schdtlatest AS ScheduledLatest, 
			GETDATE() AS ETA,
			'**********' AS OrderStatus,
			t1.ord_hdrnumber AS OrderNumber,
			CONVERT(decimal(20, 5), 0) AS PlusMinus,
			lgh_startdate as StartDate, 
			t1.lgh_number as LegHeaderNumber, 
			t5.mpp_lastfirst as DriverName,
			t5.mpp_teamleader AS TeamLeader,
			--ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, default,default, default,default,t1.mpp_type1,t1.mpp_type2,t1.mpp_type3, t1.mpp_type4,default,t1.lgh_class1,t1.lgh_class2,t1.lgh_class3,t1.lgh_class4, t5.mpp_teamleader, default,default, t3.trc_type1, t3.trc_type2,t3.trc_type3,t3.trc_type4, default,default,default,default,default,default),'') AS EmailSend, --TeamLeaderEmail
			ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, default,default, default,default,t1.mpp_type1,t1.mpp_type2,t1.mpp_type3, t1.mpp_type4,(SELECT ord_originregion1 FROM orderheader (NOLOCK) WHERE ord_hdrnumber = t1.ord_hdrnumber),t1.lgh_class1,t1.lgh_class2,t1.lgh_class3,t1.lgh_class4, t5.mpp_teamleader, default,default, t3.trc_type1, t3.trc_type2,t3.trc_type3,t3.trc_type4, default,default,default,default,default,default),'') AS EmailSend, --TeamLeaderEmail
			ISNULL(dbo.fnc_TMWRN_AssignTaskGroupID(@ParameterToUseForDynamicEmail, default,default, default,default,t1.mpp_type1,t1.mpp_type2,t1.mpp_type3, t1.mpp_type4,(SELECT ord_originregion1 FROM orderheader (NOLOCK) WHERE ord_hdrnumber = t1.ord_hdrnumber),t1.lgh_class1,t1.lgh_class2,t1.lgh_class3,t1.lgh_class4, t5.mpp_teamleader, default,default, t3.trc_type1, t3.trc_type2,t3.trc_type3,t3.trc_type4, default,default,default,default,default,default),'') AS AssignTaskGroupID, 
			t1.lgh_tractor as Tractor, 
			lgh_outstatus as OutStatus, 
			stp_event AS 'Event',
			t2.cmp_id as Company, 
			t2.stp_city as StopCity,
			t1.ref_number as RefNumber,
			t1.lgh_type1 as LegheaderType1,
			trc_gps_latitude,
			trc_gps_longitude,
			Priority = CONVERT(varchar(200), (SELECT ord_priority FROM orderheader (NOLOCK) WHERE ord_hdrnumber = t1.ord_hdrnumber)),
			BookedBy = (SELECT ord_bookedby FROM orderheader (NOLOCK) WHERE ord_hdrnumber = t1.ord_hdrnumber),
			Origin = (SELECT cty_name + ', ' + cty_state FROM city (NOLOCK)
					where cty_code = (SELECT ord_origincity FROM orderheader (NOLOCK)
								WHERE ord_hdrnumber = t1.ord_hdrnumber)
				)

		INTO #TempResultsStep1
		FROM legheader_active t1 (NOLOCK), stops t2 (NOLOCK), tractorprofile t3 (NOLOCK), company t4 (NOLOCK), manpowerprofile t5 (NOLOCK)
		WHERE t1.lgh_number = t2.lgh_number
			AND t1.lgh_tractor = t3.trc_number
			AND t2.cmp_id = t4.cmp_id
			AND t5.mpp_id = t1.lgh_driver1
			AND stp_status = 'OPN' 
			AND lgh_outstatus <> 'CMP'
	        AND (@OnlyIncludeLegOutStatusList =',,' OR CHARINDEX(',' + lgh_outstatus + ',', @OnlyIncludeLegOutStatusList) >0)
	        AND (@ExcludeLegOutStatusList =',,' OR CHARINDEX(',' + lgh_outstatus + ',', @ExcludeLegOutStatusList) =0)
			AND ISNULL(t1.lgh_tractor, 'UNKNOWN') <> 'UNKNOWN'
			AND (
					(@ExcludeFirstStopYN ='Y' 
						AND stp_mfh_sequence = (									
												SELECT MIN(stops.stp_mfh_sequence) 
												FROM legheader (NOLOCK), stops (NOLOCK)
												WHERE legheader.lgh_number = stops.lgh_number
													AND legheader.lgh_number = t2.lgh_number
													AND lgh_startdate > DATEADD(mi,@MinsBack,GETDATE())
													AND stp_status = 'OPN' 
													AND ISNULL(legheader.lgh_tractor, 'UNKNOWN') <> 'UNKNOWN'
													AND (@OnlyStopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @OnlyStopEventList) >0)
													AND stops.stp_mfh_sequence >1
					 							)
					)
				OR
					(@ExcludeFirstStopYN ='N' 
						AND stp_mfh_sequence = (									
													SELECT MIN(stops.stp_mfh_sequence) 
													FROM legheader (NOLOCK), stops (NOLOCK)
													WHERE legheader.lgh_number = stops.lgh_number
														AND legheader.lgh_number = t2.lgh_number
														AND lgh_startdate > DATEADD(mi,@MinsBack,GETDATE())
														AND stp_status = 'OPN' 
														AND (@OnlyStopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @OnlyStopEventList) >0)
														AND ISNULL(legheader.lgh_tractor, 'UNKNOWN') <> 'UNKNOWN'																
						 						)
					)
				)
			
			AND (
					(@ExcludeLastStopYN = 'Y' AND stp_mfh_sequence <> (
																		SELECT MAX(stops.stp_mfh_sequence) 
																		FROM legheader (NOLOCK), stops (NOLOCK)
																		WHERE legheader.lgh_number = stops.lgh_number
																			AND legheader.lgh_number = t2.lgh_number
																			AND lgh_startdate > DATEADD(mi,@MinsBack,GETDATE())
																			AND stp_status = 'OPN' 
																			AND ISNULL(legheader.lgh_tractor, 'UNKNOWN') <> 'UNKNOWN'
																			AND (@OnlyStopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @OnlyStopEventList) >0)
																			AND stops.stp_mfh_sequence >1
											 						)
					)
				 OR @ExcludeLastStopYN <> 'Y'
				)
			AND (@RevType1 =',,' OR CHARINDEX(',' + lgh_class1 + ',', @RevType1) >0)
	        AND (@RevType2 =',,' OR CHARINDEX(',' + lgh_class2 + ',', @RevType2) >0)
	        AND (@RevType3 =',,' OR CHARINDEX(',' + lgh_class3 + ',', @RevType3) >0)
	        AND (@RevType4 =',,' OR CHARINDEX(',' + lgh_class4 + ',', @RevType4) >0)
	        AND (@TeamLeader =',,' OR CHARINDEX(',' + t5.mpp_teamleader + ',', @TeamLeader) >0) 
		 	AND (@IncludeOnlyLegheaderType1 =',,' OR CHARINDEX(',' + lgh_type1 + ',', @IncludeOnlyLegheaderType1) >0)
			AND (@IncludeOnlyLghCreateApp =',,' OR CHARINDEX(',' + ltrim(lgh_createapp) + ',', @IncludeOnlyLghCreateApp) >0)
			AND (@ExcludeLghCreateApp =',,' OR CHARINDEX(',' + ltrim(lgh_createapp) + ',', @ExcludeLghCreateApp) =0)
			AND (@BillToID =',,' OR CHARINDEX(',' + ord_billto + ',', @BillToID) >0)
			AND (@Priority =',,' OR CHARINDEX(',' + ISNULL((SELECT ord_priority FROM orderheader (NOLOCK) WHERE ord_hdrnumber = t1.ord_hdrnumber), '') + ',', @Priority) >0)
	
	UPDATE #TempResultsStep1
	SET Priority = name
	FROM labelfile (NOLOCK) WHERE abbr = Priority

	UPDATE #TempResultsStep1
	SET AirMilesToGo = 
		Convert(float, ISNULL(	
					-- Convert values from degrees to radians 
			(
			Select 
			Acos(
				cos(	(
						Convert(decimal(6,2),(convert(float,trc_gps_latitude)/3600.0))
						* 3.14159265358979 / 180.0)  )  *
				cos(	(city.cty_latitude * 3.14159265358979 / 180.0)  )  *
		                cos (  
					(
						Convert(decimal(6,2),(convert(float,trc_gps_longitude)/3600.0))
					* 3.14159265358979 / 180.0) - 
					(city.cty_longitude * 3.14159265358979 / 180.0)
				    )	+
				Sin (	(
						Convert(decimal(6,2),(convert(float, trc_gps_latitude)/3600.0))
					* 3.14159265358979 / 180.0) ) *
				Sin (	(city.cty_latitude * 3.14159265358979 / 180.0) ) 	
			    ) * 3956.5
			)
		,9999) )
	FROM city (NOLOCK)
	WHERE #TempResultsStep1.StopCity = city.cty_code AND #TempResultsStep1.AirMilesToGo > 9998

	UPDATE #TempResultsStep1 SET OrderStatus = 'UNKNOWN' WHERE AirmilesToGo > @TooManyMilesThreshold  -- 9998

	UPDATE #TempResultsStep1 SET  EstimatedMilesToGo = AirMilesToGo * (1 + @AirMilesAdjustmentPct), 
		ETA = DATEADD(mi, ((AirMilesToGo * (1 + @AirMilesAdjustmentPct))/ @MaxAvgMilesPerHour) * 60, GPSDateTime) 
		WHERE OrderStatus <> 'UNKNOWN' 

	DELETE #TempResultsStep1 where estimatedmilestogo < @MinThreshold
		AND OrderStatus <> 'UNKNOWN' 

	IF @UnknownLocationDataMode = 'EXCLUDE' 
		DELETE #TempResultsStep1 
			WHERE AirMilesToGo > @TooManyMilesThreshold AND ISNULL(tractor, 'UNKNOWN') <> 'UNKNOWN'
				AND ScheduledLatest > GETDATE()

	IF @UnknownLocationDataMode = 'ONLY' 
		DELETE #TempResultsStep1 WHERE AirMilesToGo < @TooManyMilesThreshold + 1
				AND ScheduledLatest > GETDATE()

	UPDATE #TempResultsStep1 SET OrderStatus = CASE WHEN ETA > ScheduledLatest THEN 'LATE' ELSE 'On-Time' END,
		PlusMinus = DATEDIFF(minute, ScheduledLatest, ETA) / 60.0
		WHERE OrderStatus <> 'UNKNOWN'

	DELETE from #TempResultsStep1 where orderstatus <> 'LATE'

	SELECT * INTO #tempResults FROM #TempResultsStep1 ORDER BY ScheduledLatest DESC

	--Commits the results to be used in the wrapper
	IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
	BEGIN
		SET @SQL = 'SELECT * FROM #TempResults'
	END
	ELSE
	BEGIN
		SET @COLSQL = ''
		EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
	END
	
	EXEC (@SQL)
	
	SET NOCOUNT OFF
GO
