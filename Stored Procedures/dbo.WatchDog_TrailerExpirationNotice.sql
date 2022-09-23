SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


--WatchDogProcessing 'TrailerExpirationNotice' ,1


--delete from watchdogcolumn where watchname = 'trailerexpirationnotice'

Create PROC [dbo].[WatchDog_TrailerExpirationNotice] 
	(
		@MinThreshold FLOAT = 14, -- Days
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalTrailerExpirationNotice',
		@WatchName VARCHAR(255)='WatchTrailerExpirationNotice',
		@ThresholdFieldName VARCHAR(255) = 'Days',
		@ColumnNamesOnly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@ExpirationCode VARCHAR(255)='',
		@AssetType VARCHAR(255) = 'TRL',
		@TrlType1 VARCHAR(255) = '',
       	@TrlType2 VARCHAR(255) = '',
       	@TrlType3 VARCHAR(255) = '',
       	@TrlType4 VARCHAR(255) = '',
       	@TrlFleet VARCHAR(255)='',
       	@TrlDivision VARCHAR(255)='',
       	@TrlCompany VARCHAR(255)='',
       	@TrlTerminal VARCHAR(255)='',
       	@ExcludeTrlStatus VARCHAR(255)=''
	)
						

AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_TrailerExpirationNotice
Author/CreateDate: Brent Keeton / 1-10-2004
Purpose: 	   Select Trailer and Expiration data where the expiration is not completed and it is
	within the minimum threshold days.
*/

--Reserved/Mandatory WatchDog Variables
DECLARE @SQL VARCHAR(8000)
DECLARE @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @ExpirationCode= ',' + ISNULL(@ExpirationCode,'') + ','

SET @TrlType1= ',' + ISNULL(@TrlType1,'') + ','
SET @TrlType2= ',' + ISNULL(@TrlType2,'') + ','
SET @TrlType3= ',' + ISNULL(@TrlType3,'') + ','
SET @TrlType4= ',' + ISNULL(@TrlType4,'') + ','

SET @TrlTerminal = ',' + ISNULL(@TrlTerminal,'') + ','
SET @TrlCompany = ',' + ISNULL(@TrlCompany,'') + ','
SET @TrlFleet = ',' + ISNULL(@TrlFleet,'') + ','
SET @TrlDivision = ',' + ISNULL(@TrlDivision,'') + ','
SET @ExcludeTrlStatus = ',' + ISNULL(@ExcludeTrlStatus,'') + ','



/*******************************************************************************************
	Select Driver and Expiration data where the expiration is not completed and it is
	within the minimum threshold days.
*******************************************************************************************/


	
	select 	trl_id,
			trl_division as [Monthly Charge],
	        trl_status,
			trl_type1 ,
			trl_type2 ,
			trl_type3 ,
			trl_type4 ,
			trl_terminal ,
			trl_fleet ,
			trl_company ,
			trl_division ,
			'last_dne_evt_number' = (SELECT TOP 1 a1.last_dne_evt_number FROM assetassignment a1 (NOLOCK)
									WHERE a1.asgn_type = 'TRL' AND a1.asgn_id = TrailerProfile.trl_id AND ISNULL(a1.last_dne_evt_number, 0) <> 0 ORDER BY a1.asgn_enddate DESC
									),
			'MaxAsgnNumber'=	(	select Max(asgn_number) 
									from assetassignment a (NOLOCK)
									where TrailerProfile.trl_id=a.asgn_id
										AND a.asgn_type = 'TRL'
										and a.asgn_enddate = 	(	select max(b.asgn_enddate) 
																from assetassignment b (NOLOCK)
																where (b.asgn_type = 'TRL'
																	and a.asgn_id = b.asgn_id)
															)
								),
			[Destination Company] = CAST(' ' as varchar(30)),
			[Last City State] = CAST(' ' as varchar(30)),
			[Load Status] = CAST(' ' as varchar(6))
	into #temp
	From TrailerProfile (NOLOCK)
	WHERE trl_id<>'UNKNOWN'
		AND (@TrlType1 =',,' OR CHARINDEX(',' + trl_type1 + ',', @TrlType1) >0)
  		AND (@TrlType2 =',,' OR CHARINDEX(',' + trl_type2 + ',', @TrlType2) >0)
  		AND (@TrlType3 =',,' OR CHARINDEX(',' + trl_type3 + ',', @TrlType3) >0)
  		AND (@TrlType4 =',,' OR CHARINDEX(',' + trl_type4 + ',', @TrlType4) >0)
  		AND (@TrlTerminal =',,' OR CHARINDEX(',' + trl_terminal + ',', @TrlTerminal) >0)
  		AND (@TrlFleet =',,' OR CHARINDEX(',' + trl_fleet + ',', @TrlFleet) >0)
  		AND (@TrlCompany =',,' OR CHARINDEX(',' + trl_company + ',', @TrlCompany) >0)
  		AND (@TrlDivision =',,' OR CHARINDEX(',' + trl_division + ',', @TrlDivision) >0)
  		AND (trl_retiredate > GetDate() OR trl_retiredate IS NULL)
  		AND (@ExcludeTrlStatus =',,' OR CHARINDEX(',' + trl_status + ',', @ExcludeTrlStatus) =0)

	-- Added: DAG 20100723: Problem with Last City State logic.
	Update #Temp
	SET	[Last City State] =	c.cty_name + ', ' + c.cty_state
	From Event E (NOLOCK) LEFT JOIN Stops S (NOLOCK) ON E.stp_number = S.stp_number 
		LEFT JOIN city c (NOLOCK) ON s.stp_city = c.cty_code
	WHERE #temp.last_dne_evt_number = e.evt_number

      		
	Update #Temp
	SET	[Destination Company] =	(	SELECT stops.cmp_name
									FROM event (NOLOCK) 
										JOIN stops (NOLOCK) ON event.stp_number = stops.stp_number
										JOIN city (NOLOCK) ON stops.stp_city = city.cty_code
									WHERE evt_number = E.evt_number
										And event.stp_number = stops.stp_number
										AND stops.stp_city = city.cty_code		
								),
		[Load Status] = S.stp_loadstatus 
	From Assetassignment (NOLOCK) 
		LEFT Join Event E (NOLOCK) ON Assetassignment.evt_number = E.evt_number 
		LEFT Join Stops S (NOLOCK) ON E.stp_number = S.stp_number
	WHERE #temp.MaxAsgnNumber =Assetassignment.Asgn_number
		
          	     

	SELECT 	trl_id AS [Trailer ID],
	       	exp_code AS [Expiration Code],
	       	[Expiration] = 	(
								SELECT labelfile.name 
								FROM labelfile (NOLOCK) 
								WHERE labelfile.abbr = exp_code 
									AND labeldefinition = exp_idtype + 'Exp'
							),
	       	DATEDIFF(DAY,GETDATE(),exp_expirationdate) AS [Days Out],
	       	exp_expirationdate AS [Expiration Date],
			exp_description as [Description],
			[Last City State],
			[Load Status],
			[Destination Company],
			trl_type1 as [Type1],
			trl_type2 as [Type2],
			trl_type3 as [Type3],
			trl_type4 as [Type4],
			trl_terminal as Terminal,
			trl_fleet as Fleet,
			trl_company as Company,
			trl_division as Division
	INTO   	#TempResults 
	FROM   	Expiration (NOLOCK) 
		INNER JOIN #Temp (NOLOCK) ON trl_id = exp_id AND exp_idtype = 'TRL'
	WHERE  	(@ExpirationCode =',,' OR CHARINDEX(',' + exp_code + ',', @ExpirationCode) >0)
		AND ((exp_completed = 'N' AND DateDiff(day,GetDate(),exp_expirationdate) <= @MinThreshold))
	ORDER BY exp_expirationdate ASC

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
GRANT EXECUTE ON  [dbo].[WatchDog_TrailerExpirationNotice] TO [public]
GO
