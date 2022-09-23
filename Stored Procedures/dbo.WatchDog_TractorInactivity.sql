SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'TractorInactivity' ,1

CREATE PROC [dbo].[WatchDog_TractorInactivity]           
	(
		@MinThreshold FLOAT = 14, --Days Inactive
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalTractorInactivity',
		@WatchName VARCHAR(255)='WatchTractorInactivity',
		@ThresholdFieldName VARCHAR(255) = 'Days Inactive',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@TrcType1 VARCHAR(255)='',
		@TrcType2 VARCHAR(255)='',
		@TrcType3 VARCHAR(255)='',
		@TrcType4 VARCHAR(255)='',
		@TrcFleet VARCHAR(255)='',
		@TrcDivision VARCHAR(255)='',
		@TrcCompany VARCHAR(255)='',
		@TrcTerminal VARCHAR(255)='',
		@TeamLeader VARCHAR(255)='',
		@TractorStatus Varchar(150)='',
	    @ExcludeTractor VARCHAR(255)= '',
		@ExcludeTractorStatus Varchar(150)='',
		@OnlyLocationCompanyIDList VARCHAR(150)='',
		@UseHoursOfInactivityYN VARCHAR(1)='N',
		@InactivitySinceLastLoadedEventYN VARCHAR(1)='N',
		@InactivitySinceLastCompletedExpirationYN VARCHAR(1)='N',
		@ExpirationCodes VARCHAR(255)='OUT'
 	)
						
AS

	SET NOCOUNT ON

	/***************************************************************
	Procedure Name:    WatchDog_InactiveTractors
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	   	Provides a list of tractors and last assignments
					where the tractor's last assignment end date is
					greater than the threshold days.
	Revision History:	Lori Brickley / 12-2-2004 / Add Comments
	****************************************************************/

	/*
	if not exists (select WatchName from WatchDogItem where WatchName = 'TractorInactivity')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	VALUES ('TractorInactivity','12/30/1899','12/30/1899','WatchDog_TractorInactivity','','',0,0,'','','','','',1,0,'','','')
	*/



	--Reserved/Mandatory WatchDog Variables
	Declare @SQL VARCHAR(8000)
	Declare @COLSQL VARCHAR(4000)
	--Reserved/Mandatory WatchDog Variables

	--Standard Parameter Initialization
	SET @TrcType1= ',' + ISNULL(@TrcType1,'') + ','
	SET @TrcType2= ',' + ISNULL(@TrcType2,'') + ','
	SET @TrcType3= ',' + ISNULL(@TrcType3,'') + ','
	SET @TrcType4= ',' + ISNULL(@TrcType4,'') + ','

	SET @TrcTerminal = ',' + ISNULL(@TrcTerminal,'') + ','
	SET @TrcCompany = ',' + ISNULL(@TrcCompany,'') + ','
	SET @TrcFleet = ',' + ISNULL(@TrcFleet,'') + ','
	SET @TrcDivision = ',' + ISNULL(@TrcDivision,'') + ','
	SET @TeamLeader = ',' + ISNULL(@TeamLeader,'') + ','

	SET @TractorStatus = ',' + ISNULL(@TractorStatus,'') + ','
	SET @ExcludeTractorStatus = ',' + ISNULL(@ExcludeTractorStatus,'') + ','
	SET @ExcludeTractor = ',' + ISNULL(@ExcludeTractor,'') + ','

	SET @OnlyLocationCompanyIDList = ',' + ISNULL(@OnlyLocationCompanyIDList,'') + ','
	SET @ExpirationCodes = ',' + ISNULL(@ExpirationCodes,'') + ','

	/****************************************************************************
		Create temp table #TempResults where the following conditions are met:
		
		Select tractor data where the tractor's last assignment end date is
		greater than the minThreshold days indicated.
		The last assignment is the assignment of type 'TRC' with the maximum
		end date.

	*****************************************************************************/

	IF @InactivitySinceLastLoadedEventYN = 'N'
	BEGIN
		SELECT  
			trc_number AS [Tractor ID],
			trc_status AS [Tractor Status],
			IsNull(trc_gps_desc, 'UNKNOWN') AS [Tractor Location],
			LegHeader.mov_number AS Movement,
			lgh_driver1 AS [Driver ID],
			(SELECT Top 1 IsNull(mpp_firstname, '') + ' ' + IsNull(mpp_lastname, '') from manpowerprofile (nolock) where mpp_id = lgh_driver1) as [Driver Name] ,
			mpp_teamleader as [Team Leader],
			lgh_primary_trailer AS [Trailer ID],
			'Origin Company' = 	(
									SELECT TOP 1 Company.cmp_name 
									FROM Company (NOLOCK)
									WHERE legheader.cmp_id_start = Company.cmp_id
								), 
			'Origin City State' =	(
										SELECT City.cty_name + ', '+ City.cty_state 
										FROM City (NOLOCK)
										WHERE legheader.lgh_startcity = City.cty_code
									),
			lgh_startdate AS 'Segment Start Date',
			lgh_enddate AS 'Segment End Date',
			'Destination Company' =	(
										SELECT TOP 1 Company.cmp_name 
										FROM Company (NOLOCK)
										WHERE legheader.cmp_id_end = Company.cmp_id
									),
			'Destination Company ID' =	(
										SELECT TOP 1 Company.cmp_id 
										FROM Company (NOLOCK)
										WHERE legheader.cmp_id_end = Company.cmp_id
									),
			'Destination City State' = 	(
											SELECT City.cty_name + ', '+ City.cty_state 
											FROM City (NOLOCK)
											WHERE legheader.lgh_endcity = City.cty_code
										),
			Asgn_enddate AS 'Assignment End Date',
			ISNULL(DATEDIFF(DAY,Asgn_enddate,GETDATE()),0) AS DaysInactive,
			ISNULL(DATEDIFF(hour,Asgn_enddate,GETDATE()),0) AS HoursInactive,
			trc_type1 as [Trc Type 1],
			trc_type2 as [Trc Type 2],
			trc_type3 as [Trc Type 3],
			trc_type4 as [Trc Type 4]
		INTO #TempResults
		FROM 
			(
			SELECT 
				trc_number, 
				trc_status,
				trc_gps_desc,
	      		'MaxAsgnNumber'= (
										SELECT MAX(Isnull(asgn_number,0)) 
										FROM assetassignment a (NOLOCK)
										WHERE trc_number=asgn_id
											AND asgn_type = 'TRC'
											AND asgn_enddate = (
																	SELECT MAX(Isnull(b.asgn_enddate,'20491231')) 
																	FROM assetassignment b (NOLOCK) 
																	WHERE (b.asgn_type = 'TRC'
																			AND a.asgn_id = b.asgn_id
																			AND b.asgn_status = 'CMP')
																)
			
									)
			FROM TractorProfile (NOLOCK)
			WHERE Isnull(trc_number,'UNKNOWN')<>'UNKNOWN'	
				AND Isnull(trc_retiredate,'20491231') > GETDATE() 
				AND (@TrcType1 =',,' OR CHARINDEX(',' + trc_type1 + ',', @TrcType1) >0)
				AND (@TrcType2 =',,' OR CHARINDEX(',' + trc_type2 + ',', @TrcType2) >0)
				AND (@TrcType3 =',,' OR CHARINDEX(',' + trc_type3 + ',', @TrcType3) >0)
				AND (@TrcType4 =',,' OR CHARINDEX(',' + trc_type4 + ',', @TrcType4) >0)
				AND (@TrcTerminal =',,' OR CHARINDEX(',' + trc_terminal + ',', @TrcTerminal) >0)
				AND (@TrcFleet =',,' OR CHARINDEX(',' + trc_fleet + ',', @TrcFleet) >0)
				AND (@TrcCompany =',,' OR CHARINDEX(',' + trc_company + ',', @TrcCompany) >0)
				AND (@TrcDivision =',,' OR CHARINDEX(',' + trc_division + ',', @TrcDivision) >0) 
				AND (@ExcludeTractorStatus = ',,' OR CHARINDEX(',' + trc_status + ',', @ExcludeTractorStatus) = 0) 
				AND (@ExcludeTractor = ',,' OR CHARINDEX(',' + trc_number + ',', @ExcludeTractor) = 0) 
				AND (@TractorStatus =',,' OR CHARINDEX(',' + trc_status + ',', @TractorStatus) >0)
			) AS TempInactivity 
			Left JOIN Assetassignment (NOLOCK) ON  TempInactivity.MaxAsgnNumber= Assetassignment.Asgn_number
			Left JOIN LegHeader (NOLOCK) ON  Assetassignment.lgh_number = LegHeader.lgh_number 
		WHERE	(	
					(	@UseHoursOfInactivityYN='N'  
						AND (DATEDIFF(mi,ISnull(Asgn_enddate,'20491231'),GETDATE()) >= (@MinThreshold * 24 * 60)  OR Asgn_enddate IS NULL)
					)
					OR	
					(	@UseHoursOfInactivityYN='Y'  
						AND (DATEDIFF(mi,ISnull(Asgn_enddate,'20491231'),GETDATE()) >= (@MinThreshold * 60)  OR Asgn_enddate IS NULL)
					)
				)
				AND (@TeamLeader =',,' OR CHARINDEX(',' + mpp_teamleader + ',', @TeamLeader) >0)
		ORDER BY HoursInactive DESC

		IF @OnlyLocationCompanyIDList <> ',,'
			DELETE FROM #TempResults 
			Where (CHARINDEX(',' + [Destination Company ID] + ',', @OnlyLocationCompanyIDList) =0)

	END
	ELSE
	BEGIN
		SELECT  
			trc_number AS [Tractor ID],
			trc_status AS [Tractor Status],
			trc_gps_desc AS [Tractor Location],
			LegHeader.mov_number AS Movement,
			lgh_driver1 AS [Driver ID],
			(SELECT Top 1 IsNull(mpp_firstname, '') + ' ' + IsNull(mpp_lastname, '') from manpowerprofile (nolock) where mpp_id = lgh_driver1) as [Driver Name] ,
			mpp_teamleader as [Team Leader],
			lgh_primary_trailer AS [Trailer ID],
			'Origin Company' = 	(
									SELECT TOP 1 Company.cmp_name 
									FROM Company (NOLOCK)
									WHERE legheader.cmp_id_start = Company.cmp_id
								), 
			'Origin City State' =	(
										SELECT City.cty_name + ', '+ City.cty_state 
										FROM City (NOLOCK)
										WHERE legheader.lgh_startcity = City.cty_code
									),
			lgh_startdate AS 'Segment Start Date',
			lgh_enddate AS 'Segment End Date',
			'Destination Company' =	(
										SELECT TOP 1 Company.cmp_name 
										FROM Company (NOLOCK)
										WHERE legheader.cmp_id_end = Company.cmp_id
									),
			'Destination Company ID' =	(
										SELECT TOP 1 Company.cmp_id 
										FROM Company (NOLOCK)
										WHERE legheader.cmp_id_end = Company.cmp_id
									),
			'Destination City State' = 	(
											SELECT City.cty_name + ', '+ City.cty_state 
											FROM City (NOLOCK)
											WHERE legheader.lgh_endcity = City.cty_code
										),
			Asgn_enddate AS 'Assignment End Date',
			ISNULL(DATEDIFF(DAY,Asgn_enddate,GETDATE()),0) AS DaysInactive,
			ISNULL(DATEDIFF(hour,Asgn_enddate,GETDATE()),0) AS HoursInactive
		INTO #TempResults2a
		FROM 
			(
			SELECT 
				trc_number, 
				trc_status,
				trc_gps_desc,
	      		'MaxAsgnNumber'= (
										SELECT MAX(Isnull(asgn_number,0)) 
										FROM assetassignment a (NOLOCK)
										WHERE trc_number=asgn_id
											AND asgn_type = 'TRC'
											AND asgn_enddate = (
																	SELECT MAX(Isnull(b.asgn_enddate,'20491231')) 
																	FROM assetassignment b (NOLOCK) 
																		JOIN event e (NOLOCK) ON b.evt_number = e.evt_number 
																		JOIN eventcodetable ect (NOLOCK) ON evt_eventcode = abbr 
																	WHERE (b.asgn_type = 'TRC'
																			AND a.asgn_id = b.asgn_id
																			AND b.asgn_status = 'CMP'
																			AND ect.mile_typ_from_stop <> 'LD')
																)
			
									)
			FROM TractorProfile (NOLOCK)
			WHERE Isnull(trc_number,'UNKNOWN')<>'UNKNOWN'	
				AND Isnull(trc_retiredate,'20491231') > GETDATE() 
				AND (@TrcType1 =',,' OR CHARINDEX(',' + trc_type1 + ',', @TrcType1) >0)
				AND (@TrcType2 =',,' OR CHARINDEX(',' + trc_type2 + ',', @TrcType2) >0)
				AND (@TrcType3 =',,' OR CHARINDEX(',' + trc_type3 + ',', @TrcType3) >0)
				AND (@TrcType4 =',,' OR CHARINDEX(',' + trc_type4 + ',', @TrcType4) >0)
				AND (@TrcTerminal =',,' OR CHARINDEX(',' + trc_terminal + ',', @TrcTerminal) >0)
				AND (@TrcFleet =',,' OR CHARINDEX(',' + trc_fleet + ',', @TrcFleet) >0)
				AND (@TrcCompany =',,' OR CHARINDEX(',' + trc_company + ',', @TrcCompany) >0)
				AND (@TrcDivision =',,' OR CHARINDEX(',' + trc_division + ',', @TrcDivision) >0) 
				AND (@ExcludeTractorStatus = ',,' OR CHARINDEX(',' + trc_status + ',', @ExcludeTractorStatus) = 0) 
				AND (@ExcludeTractor = ',,' OR CHARINDEX(',' + trc_number + ',', @ExcludeTractor) = 0) 
				AND (@TractorStatus =',,' OR CHARINDEX(',' + trc_status + ',', @TractorStatus) >0)
			) AS TempInactivity 
			Left JOIN Assetassignment (NOLOCK) ON  TempInactivity.MaxAsgnNumber= Assetassignment.Asgn_number
			Left JOIN LegHeader (NOLOCK) ON  Assetassignment.lgh_number = LegHeader.lgh_number 
		WHERE	(	
					(	@UseHoursOfInactivityYN='N'  
						AND (DATEDIFF(mi,ISnull(Asgn_enddate,'20491231'),GETDATE()) >= (@MinThreshold * 24 * 60)  OR Asgn_enddate IS NULL)
					)
					OR	
					(	@UseHoursOfInactivityYN='Y'  
						AND (DATEDIFF(mi,ISnull(Asgn_enddate,'20491231'),GETDATE()) >= (@MinThreshold * 60)  OR Asgn_enddate IS NULL)
					)
				)
				AND (@TeamLeader =',,' OR CHARINDEX(',' + mpp_teamleader + ',', @TeamLeader) >0)
		ORDER BY HoursInactive DESC

		IF @InactivitySinceLastCompletedExpirationYN = 'Y'
		BEGIN
			SELECT	[Tractor ID],
					[Tractor Status],
					[Tractor Location],
					Movement,
					[Driver ID],
					[Driver Name] ,
					[Team Leader],
					[Trailer ID],
					[Origin Company] ,
					[Origin City State] ,
					[Segment Start Date],
					[Segment End Date],
					[Destination Company] ,
					[Destination Company ID] ,
					[Destination City State] ,
					[Assignment End Date],
					DaysInactive,
					HoursInactive,
					(	SELECT max(exp_compldate) 
						from expiration (nolock)
						where exp_idtype = 'TRC'
							AND (@ExpirationCodes =',,' OR CHARINDEX(',' + exp_code + ',', @ExpirationCodes) >0)
							AND exp_id = [Tractor ID]
					) as [Last Expiration]
					--dbo.fnc_TMWRN_TotalTractorExpirations([Assignment End Date],GETDATE(),[Tractor ID], @ExpirationCodes) as [Days of Expiration]
				INTO #TempResults2b
				FROM #TempResults2a

			SELECT	[Tractor ID],
					[Tractor Status],
					[Tractor Location],
					Movement,
					[Driver ID],
					[Driver Name] ,
					[Team Leader],
					[Trailer ID],
					[Origin Company] ,
					[Origin City State] ,
					[Segment Start Date],
					[Segment End Date],
					[Destination Company] ,
					[Destination Company ID] ,
					[Destination City State] ,
					[Assignment End Date],
					DaysInactive = CASE  WHEN  [Assignment End Date] > [Last Expiration] THEN ISNULL(DATEDIFF(DAY,[Assignment End Date],GETDATE()),0) ELSE ISNULL(DATEDIFF(DAY,[Last Expiration],GETDATE()),0) END,
					HoursInactive = CASE  WHEN [Assignment End Date] > [Last Expiration] THEN ISNULL(DATEDIFF(hour,[Assignment End Date],GETDATE()),0) ELSE ISNULL(DATEDIFF(hour,[Last Expiration],GETDATE()),0) END,
					[Last Expiration]
				INTO #TempResults2c
				FROM #TempResults2b
				
			
			ORDER BY HoursInactive DESC

			SELECT	[Tractor ID],
					[Tractor Status],
					[Tractor Location],
					Movement,
					[Driver ID],
					[Driver Name] ,
					[Team Leader],
					[Trailer ID],
					[Origin Company] ,
					[Origin City State] ,
					[Segment Start Date],
					[Segment End Date],
					[Destination Company] ,
					[Destination Company ID] ,
					[Destination City State] ,
					[Assignment End Date],
					DaysInactive ,
					HoursInactive ,
					[Last Expiration]
				INTO #TempResults2
				FROM #TempResults2c
				WHERE 	(	
							(	@UseHoursOfInactivityYN='N'  
								AND DaysInactive >= (@MinThreshold)
							)
							OR	
							(	@UseHoursOfInactivityYN='Y'  
								AND HoursInactive >= (@MinThreshold)
							)
						)
			
			ORDER BY HoursInactive DESC
		END
		ELSE
		BEGIN
		SELECT	[Tractor ID],
					[Tractor Status],
					[Tractor Location],
					Movement,
					[Driver ID],
					[Driver Name] ,
					[Team Leader],
					[Trailer ID],
					[Origin Company] ,
					[Origin City State] ,
					[Segment Start Date],
					[Segment End Date],
					[Destination Company] ,
					[Destination Company ID] ,
					[Destination City State] ,
					[Assignment End Date],
					DaysInactive,
					HoursInactive
				INTO #TempResults3
				FROM #TempResults2a
				WHERE 	(	
							(	@UseHoursOfInactivityYN='N'  
								AND DaysInactive >= (@MinThreshold)
							)
							OR	
							(	@UseHoursOfInactivityYN='Y'  
								AND HoursInactive >= (@MinThreshold)
							)
						)
			
			ORDER BY HoursInactive DESC
		END
		
		IF @OnlyLocationCompanyIDList <> ',,'
			DELETE FROM #TempResults2 
			Where (CHARINDEX(',' + [Destination Company ID] + ',', @OnlyLocationCompanyIDList) =0)
	END



	--Commits the results to be used in the wrapper
	IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
	BEGIN
		IF @InactivitySinceLastLoadedEventYN = 'N'
			SET @SQL = 'SELECT * FROM #TempResults ORDER BY HoursInactive DESC'
		ELSE
			IF @InactivitySinceLastCompletedExpirationYN = 'Y'
				SET @SQL = 'SELECT * FROM #TempResults2'
			ELSE
				SET @SQL = 'SELECT * FROM #TempResults3'
	END
	ELSE
	BEGIN
		SET @COLSQL = ''
		EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		IF @InactivitySinceLastLoadedEventYN = 'N'
			SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
		ELSE
			IF @InactivitySinceLastCompletedExpirationYN = 'Y'
				SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults2'
			ELSE
				SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults3'
	END

	EXEC (@SQL)

	SET NOCOUNT OFF

GO
