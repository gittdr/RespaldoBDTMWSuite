SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_DetentionTime] 
(
	@MinThreshold float = 1,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalDetentionTime',
	@WatchName varchar(255) = 'DetentionTime',
	@ThresholdFieldName varchar(255) = 'Minutes',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='SELECTed',
    @RevType1 varchar(140)='',
 	@RevType2 varchar(140)='',
  	@RevType3 varchar(140)='',
  	@RevType4 varchar(140)='',
	@Event varchar(50)='',
	@UseDepartureStatusYN char(1) = 'N',
	@LoadedStatus varchar(140)='',
    @OnlyOriginCompanyList varchar(255) = ''  
)

As

	Set NoCount On
	
	
	/*
	Procedure Name:    WatchDog_DetentionTime
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	   return legs that have detention (NOT LEGHEADERS)
			   Two Modes of Detention: Possibile AND Actual
			   WHEN @UseDepartureStatusYN = Y THEN
			   Possible-> means Actualized Arrival AND Open Departure
			     	      Threshold: between Arrival AND GetDate()
			   Actual-> means Actualized Arrival AND Actualized Departure
			     		Threshold: between Departure AND Arrival
			   WHEN @UseDepartureStatusYN = N THEN
			   Possible-> means Open Arrival
			     		Threshold: between Est. Arrival AND GetDate()
			   Actual->   means we are assuming that the Actualized
					Arrival AND Departure happen at the same time
			     		Threshold: between Arrival AND Departure
			   NOTE: In the future another proc or this proc will reflect
			           individual company slack times
	Revision History:
	*/
	
	--Reserved/MANDatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/MANDatory WatchDog Variables
	
	Declare @ResultsTable varchar(255)
	
	
	Set @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
	Set @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
	Set @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
	Set @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
	Set @Event= ',' + RTrim(ISNULL(@Event,'')) + ','
	Set @LoadedStatus= ',' + RTrim(ISNULL(@LoadedStatus,'')) + ','
	Set @OnlyOriginCompanyList= ',' + ISNULL(@OnlyOriginCompanyList,'') + ','  
	
	IF @UseDepartureStatusYN = 'Y'
	BEGIN

		SELECT 	ISNULL((SELECT cty_name FROM city (NOLOCK) WHERE s.stp_city = cty_code),'') AS 'Dest City',
		        ISNULL((SELECT cty_state FROM city (NOLOCK) WHERE s.stp_city = cty_code),'') AS 'Dest State',
			    cmp_id AS [Company ID],
			    [Company Name] =(SELECT s.cmp_name FROM company (NOLOCK) WHERE company.cmp_id = s.cmp_id),
			    CASE WHEN stp_status = 'DNE' AND stp_departure_status = 'OPN' THEN
			    	DATEDIFF(mi,CASE WHEN e.evt_startdate < e.evt_earlydate THEN e.evt_earlydate ELSE e.evt_startdate END,GetDate()) 
			    ELSE
			    	DATEDIFF(mi,CASE WHEN e.evt_startdate < e.evt_earlydate THEN e.evt_earlydate ELSE e.evt_startdate END,e.evt_enddate) 
		 	    END AS [Lapsed Time],
				e.evt_earlydate as [Earliest Scheduled Date],
				e.evt_latedate as [Latest Scheduled Date],
				e.evt_startdate as [Arrival Date],
				e.evt_enddate as [Departure Date],
				mpp_teamleader as [Dispatcher ID],
			    'Dispatcher' = ISNULL((SELECT name FROM labelfile (NOLOCK) WHERE labelfile.abbr = mpp_teamleader AND labeldefinition = 'TeamLeader'),mpp_teamleader),
				lgh_driver1 as  [Driver ID],
				(SELECT ord_number FROM orderheader (NOLOCK) WHERE s.ord_hdrnumber = orderheader.ord_hdrnumber) as [Order Number],
				lgh_outstatus as [Dispatch Status],
				legheader_active.mov_number,
				legheader_active.lgh_number,
				s.stp_mfh_sequence,
				s.stp_number,
				CASE WHEN s.stp_status = 'DNE' AND s.stp_departure_status = 'OPN' THEN
					'Possible'
				ELSE
					'Actual'
				END as Status	
		INTO #TempDestination
		FROM   legheader_active (NOLOCK),stops s (NOLOCK), event e (NOLOCK)
		WHERE  legheader_active.lgh_number = s.lgh_number
			AND s.stp_number = e.stp_number
			AND (@RevType1 =',,' or CHARINDEX(',' + lgh_class1 + ',', @RevType1) >0)
			AND (@RevType2 =',,' or CHARINDEX(',' + lgh_class2 + ',', @RevType2) >0)
			AND (@RevType3 =',,' or CHARINDEX(',' + lgh_class3 + ',', @RevType3) >0)
			AND (@RevType4 =',,' or CHARINDEX(',' + lgh_class4 + ',', @RevType4) >0)
			AND (@LoadedStatus =',,' or CHARINDEX(',' + s.stp_loadstatus + ',', @LoadedStatus) >0)
			AND (@Event =',,' or CHARINDEX(',' + stp_event + ',', @Event) >0)
			AND (e.evt_startdate >= DateAdd(d,-30,getdate()))
			AND (
					lgh_updatedon >= DateAdd(mi,@MinsBack,GetDate()) 
					or 
					(s.stp_status = 'DNE' AND s.stp_departure_status = 'OPN' AND not exists (SELECT * FROM orderheader (NOLOCK) WHERE ord_hdrnumber = legheader_active.ord_hdrnumber AND ord_status ='CAN'))
				)
			AND 
		        (	
					(s.stp_status = 'DNE' AND s.stp_departure_status = 'OPN' AND DATEDIFF(mi,CASE WHEN e.evt_startdate < e.evt_earlydate  THEN e.evt_earlydate ELSE e.evt_startdate END,GetDate()) > @MinThreshold)
					Or
					(s.stp_status = 'DNE' AND s.stp_departure_status = 'DNE' AND DATEDIFF(mi,CASE WHEN e.evt_startdate < e.evt_earlydate  THEN e.evt_earlydate ELSE e.evt_startdate END,e.evt_enddate) > @MinThreshold)
				)
			AND
		        (
			   		(s.lgh_number = (SELECT min(b.lgh_number) FROM legheader b (NOLOCK) WHERE b.mov_number = s.mov_number AND b.lgh_outstatus <> 'CAN') AND s.stp_mfh_sequence > (SELECT min(b.stp_mfh_sequence) FROM stops b (NOLOCK) WHERE b.lgh_number = s.lgh_number))



			    	OR
			   		(s.lgh_number > (SELECT min(b.lgh_number) FROM legheader b (NOLOCK) WHERE b.mov_number = s.mov_number AND b.lgh_outstatus <> 'CAN') AND s.stp_mfh_sequence >= (SELECT min(b.stp_mfh_sequence) FROM stops b (NOLOCK) WHERE b.lgh_number = s.lgh_number))

		        )
			And (@OnlyOriginCompanyList =',,' or CHARINDEX(',' + cmp_id_start + ',', @OnlyOriginCompanyList) >0)     

		SELECT  
			ISNULL((SELECT cty_name FROM city (NOLOCK) WHERE s.stp_city = cty_code),'') as 'Origin City',
			ISNULL((SELECT cty_state FROM city (NOLOCK) WHERE s.stp_city = cty_code),'') as 'Origin State',
			[Dest City],
			[Dest State],
			cast([Status] as char(12)) as [Status],
			[Lapsed Time],
			[Earliest Scheduled Date],
			[Latest Scheduled Date],
			[Arrival Date],
			[Departure Date],
		    [Order Number],
			[Driver ID],
			#TempDestination.mov_number as [Movement]      
		INTO   #TempDepartureResults	
		FROM   stops s (NOLOCK), #TempDestination (NOLOCK)
		WHERE  s.stp_mfh_sequence = (
										SELECT MAX(b.stp_mfh_sequence) 
										FROM stops b (NOLOCK)
										WHERE b.stp_mfh_sequence < #TempDestination.stp_mfh_sequence 
											AND b.mov_number = #TempDestination.mov_number
									)
			AND s.mov_number = #TempDestination.mov_number
		ORDER BY CASE WHEN [Earliest Scheduled Date] > [Arrival Date] THEN [Earliest Scheduled Date] ELSE [Arrival Date] END DESC
		
		SET @ResultsTable = '#TempDepartureResults'
		
	END
	
	ELSE
	BEGIN
		SELECT	ISNULL((SELECT cty_name FROM city (NOLOCK) WHERE s.stp_city = cty_code),'') as 'Dest City',
	         	ISNULL((SELECT cty_state FROM city (NOLOCK) WHERE s.stp_city = cty_code),'') as 'Dest State',
				cmp_id as [Company ID],
				[Company Name] =(SELECT s.cmp_name FROM company (NOLOCK) WHERE company.cmp_id = s.cmp_id),
				CASE WHEN stp_status = 'OPN' THEN
					DATEDIFF(mi,CASE WHEN e.evt_startdate < e.evt_earlydate  THEN e.evt_earlydate ELSE e.evt_startdate END,GetDate()) 
				ELSE
					DATEDIFF(mi,CASE WHEN e.evt_startdate < e.evt_earlydate  THEN e.evt_earlydate ELSE e.evt_startdate END,e.evt_enddate) 
				END as [Lapsed Time],
				e.evt_earlydate as [Earliest Scheduled Date],
				e.evt_latedate as [Latest Scheduled Date],
				e.evt_startdate as [Arrival Date],
				e.evt_enddate as [Departure Date],
				mpp_teamleader as [Dispatcher ID],
				'Dispatcher' = ISNULL((SELECT name FROM labelfile (NOLOCK) WHERE labelfile.abbr = mpp_teamleader AND labeldefinition = 'TeamLeader'),mpp_teamleader),
				lgh_driver1 as  [Driver ID],
				(SELECT ord_number FROM orderheader (NOLOCK) WHERE s.ord_hdrnumber = orderheader.ord_hdrnumber) as [Order Number],
				lgh_outstatus as [Dispatch Status],
				legheader_active.mov_number,
				legheader_active.lgh_number,
				s.stp_mfh_sequence,
				s.stp_number,
				CASE WHEN s.stp_status = 'OPN' THEN
					'Possible'
				ELSE
					'Actual'
				END as Status
		INTO #TempDestinationN
		FROM   legheader_active (NOLOCK), stops s (NOLOCK) , event e (NOLOCK)
		WHERE  legheader_active.lgh_number = s.lgh_number
			AND s.stp_number = e.stp_number
			AND (@RevType1 =',,' or CHARINDEX(',' + lgh_class1 + ',', @RevType1) >0)
			AND (@RevType2 =',,' or CHARINDEX(',' + lgh_class2 + ',', @RevType2) >0)
			AND (@RevType3 =',,' or CHARINDEX(',' + lgh_class3 + ',', @RevType3) >0)
			AND (@RevType4 =',,' or CHARINDEX(',' + lgh_class4 + ',', @RevType4) >0)
			AND (@LoadedStatus =',,' or CHARINDEX(',' + s.stp_loadstatus + ',', @LoadedStatus) >0)
			AND (@Event =',,' or CHARINDEX(',' + stp_event + ',', @Event) >0)
			AND (e.evt_startdate >= DateAdd(d,-30,getdate()))
			AND (lgh_updatedon >= DateAdd(mi,@MinsBack,GetDate()) or s.stp_status = 'OPN')
			AND (
					(s.stp_status = 'OPN' AND DATEDIFF(mi,CASE WHEN e.evt_startdate < e.evt_earlydate  THEN e.evt_earlydate ELSE e.evt_startdate END,GetDate()) > @MinThreshold)
					Or
					(s.stp_status = 'DNE' AND DATEDIFF(mi,CASE WHEN e.evt_startdate < e.evt_earlydate  THEN e.evt_earlydate ELSE e.evt_startdate END,e.evt_enddate) > @MinThreshold)
				)
			AND (
			  		(s.lgh_number = (SELECT min(b.lgh_number) FROM legheader b (NOLOCK) WHERE b.mov_number = s.mov_number AND b.lgh_outstatus <> 'CAN') AND s.stp_mfh_sequence > (SELECT min(b.stp_mfh_sequence) FROM stops b (NOLOCK) WHERE b.lgh_number = s.lgh_number))
			  		OR
			  		(s.lgh_number > (SELECT min(b.lgh_number) FROM legheader b (NOLOCK) WHERE b.mov_number = s.mov_number AND b.lgh_outstatus <> 'CAN') AND s.stp_mfh_sequence >= (SELECT min(b.stp_mfh_sequence) FROM stops b (NOLOCK) WHERE b.lgh_number = s.lgh_number))



		        )
			And (@OnlyOriginCompanyList =',,' or CHARINDEX(',' + cmp_id_start + ',', @OnlyOriginCompanyList) >0)     
		 
		SELECT  ISNULL((SELECT cty_name FROM city (NOLOCK) WHERE s.stp_city = cty_code),'') as 'Origin City',
				ISNULL((SELECT cty_state FROM city (NOLOCK) WHERE s.stp_city = cty_code),'') as 'Origin State',
				[Dest City],
				[Dest State],
				cast([Status] as char(12)) as [Status],
				[Lapsed Time],
				[Earliest Scheduled Date],
				[Latest Scheduled Date],
				[Arrival Date],
				[Departure Date],
			    [Order Number],
			    [Driver ID],
			    #TempDestinationN.mov_number as [Movement]
		INTO   #TempResults	
		FROM   stops s (NOLOCK) , #TempDestinationN (NOLOCK)
		WHERE  s.stp_mfh_sequence =	(
										SELECT MAX(b.stp_mfh_sequence) 
										FROM stops b (NOLOCK)
										WHERE b.stp_mfh_sequence < #TempDestinationN.stp_mfh_sequence 
											AND b.mov_number = #TempDestinationN.mov_number
									)
			AND s.mov_number = #TempDestinationN.mov_number
		ORDER BY CASE WHEN [Earliest Scheduled Date] > [Arrival Date] THEN [Earliest Scheduled Date] ELSE [Arrival Date] END desc
		
		SET @ResultsTable = '#TempResults'
	
	END
	
	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'SELECT * FROM ' + @ResultsTable
	END
	ELSE
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'SELECT identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' FROM ' + @ResultsTable
	END
	
	Exec (@SQL)
	
	
	Set NoCount Off
		


GO
