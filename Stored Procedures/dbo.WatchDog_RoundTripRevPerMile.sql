SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_RoundTripRevPerMile] 
	(
		@MinThreshold FLOAT = 1.25,@MinsBack INT=-20,
		@TempTableName VARCHAR(255)='##WatchDogGlobalRoundTrip',
		@WatchName VARCHAR(255) = 'RevPerMile',
		@ThresholdFieldName VARCHAR(255) = 'RevenuePerMile',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR (50) ='Selected',
		@FirstTripRevType1 VARCHAR(140)='',
		@FirstTripRevType2 VARCHAR(140)='',
		@FirstTripRevType3 VARCHAR(140)='',
		@FirstTripRevType4 VARCHAR(140)='',
		@NextTripRevType1 VARCHAR(140)='',
		@NextTripRevType2 VARCHAR(140)='',
		@NextTripRevType3 VARCHAR(140)='',
		@NextTripRevType4 VARCHAR(140)='',
		@IncludeChargeTypeListOnly VARCHAR(255)='',
		@ExcludeChargeTypeListOnly VARCHAR(255)='',
		@IncludeBillToIDList VARCHAR(255)='',
		@ExcludeBillToIDList VARCHAR(255)=''
	)

AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_RoundTripRevPerMile
Author/CreateDate: Brent Keeton / 6-15-2004
Purpose: 	   Returns the Revenue for a Driver's total round trip
Revision History:	Lori Brickley / 12-2-2004 / Add Comments
*/

--Reserved/Mandatory WatchDog Variables
DECLARE @SQL VARCHAR(8000)
DECLARE @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Additional Dawg Specific Variables
DECLARE @BeginDate DATETIME

--Standard Parameter Initialization
SET @BeginDate = DATEADD(mi,@MinsBack,GETDATE())

SET @FirstTripRevType1= ',' + RTRIM(ISNULL(@FirstTripRevType1,'')) + ','
SET @FirstTripRevType2= ',' + RTRIM(ISNULL(@FirstTripRevType2,'')) + ','
SET @FirstTripRevType3= ',' + RTRIM(ISNULL(@FirstTripRevType3,'')) + ','
SET @FirstTripRevType4= ',' + RTRIM(ISNULL(@FirstTripRevType4,'')) + ','

SET @NextTripRevType1= ',' + RTRIM(ISNULL(@NextTripRevType1,'')) + ','
SET @NextTripRevType2= ',' + RTRIM(ISNULL(@NextTripRevType2,'')) + ','
SET @NextTripRevType3= ',' + RTRIM(ISNULL(@NextTripRevType3,'')) + ','
SET @NextTripRevType4= ',' + RTRIM(ISNULL(@NextTripRevType4,'')) + ','

Exec WatchDogPopulateSessionIDParamaters 'Revenue',@WatchName 

/**************************************************************************
	Step 1:
	Select orders where the Completion date is within the Minutes Back,
	the order status is completed.  
	
	Note: ColumnNamesOnly Must Be 0 to receive any results from Step 1
	
**************************************************************************/
SELECT 	mov_number,
       	ord_startdate,
       	ord_hdrnumber,
       	(
			SELECT ISNULL(cty_name,'') + ',' + ISNULL(cty_state,'') 
			FROM city (NOLOCK) 
			WHERE cty_code = ord_origincity
		) AS Origin,
       (
			SELECT ISNULL(cty_name,'') + ',' + ISNULL(cty_state,'') 
			FROM city (NOLOCK) 
			WHERE cty_code = ord_destcity
		) AS Destination,
       	ord_number
INTO   	#MoveAndOrderList
FROM   	orderheader (NOLOCK)
WHERE  	ord_completiondate >= @BeginDate
       	AND ord_status = 'CMP'
       	AND (@FirstTripRevType1 =',,' OR CHARINDEX(',' + ord_revtype1 + ',', @FirstTripRevType1) >0)
       	AND (@FirstTripRevType2 =',,' OR CHARINDEX(',' + ord_revtype2 + ',', @FirstTripRevType2) >0)
       	AND (@FirstTripRevType3 =',,' OR CHARINDEX(',' + ord_revtype3 + ',', @FirstTripRevType3) >0)
       	AND (@FirstTripRevType4 =',,' OR CHARINDEX(',' + ord_revtype4 + ',', @FirstTripRevType4) >0)
       	AND
  			(
	 			(@ColumnNamesOnly = 1 AND 1=0)
	 				OR
	 			(@ColumnNamesOnly = 0)
       		)

/**************************************************************************
	Step 2:
	Select the corresponding legheaders to Step 1's move numbers where
	the outstatus is not cancelled.
	
	Note: Order Header number is the minimum order number with the minimum start
	date.
**************************************************************************/
SELECT  legheader.mov_number,
		lgh_driver1,
		lgh_startdate,
		lgh_enddate,
		lgh_number,
		lgh_outstatus,
		lgh_startcty_nmstct,
		lgh_endcty_nmstct,
		legheader.ord_hdrnumber,
		Origin,Destination,
		ord_number
INTO    #FirstMoveLegheader
FROM    legheader (NOLOCK), #MoveAndOrderList
WHERE   legheader.mov_number = #MoveAndOrderList.mov_number
        AND lgh_outstatus <> 'CAN'
		AND #MoveAndOrderList.ord_hdrnumber = 	(
													SELECT MIN(b.ord_hdrnumber) 
													FROM #MoveAndOrderList b 
													WHERE b.mov_number = #MoveAndOrderList.mov_number 
													AND b.ord_startdate = 	(
																				SELECT MIN(c.ord_startdate) 
																				FROM #MoveAndOrderList c 
																				WHERE c.mov_number = b.mov_number
																			)
												)

/**************************************************************************
	Step 3:
	
	Select the corresponding origin, destination, total miles, revenue, 
	and driver where the leg header is the max legheader
**************************************************************************/
SELECT  [Origin],
		[Destination],
		ord_number AS [Order #],
		mov_number,
		TotalMiles,
    	ISNULL(dbo.fnc_TMWRN_Revenue('Movement',DEFAULT,DEFAULT,mov_number,DEFAULT,DEFAULT,DEFAULT,@IncludeChargeTypeListOnly,@ExcludeChargeTypeListOnly,'','','',@ExcludeBillToIDList,@IncludeBillToIDList,'',''),0) AS Revenue, 
		Driver AS [FirstMoveDriver],
		FirstMoveDriverDisplay = (
									SELECT a.lgh_driver1 
									FROM #FirstMoveLegHeader a 
									WHERE a.lgh_number = 	(
																SELECT min(b.lgh_number) 
																FROM #FirstMoveLegHeader b 
																WHERE b.mov_number = TempMoves.mov_number 
																AND b.lgh_startdate = 	(
																							SELECT MIN(c.lgh_startdate) 
																							FROM #FirstMoveLegHeader c 
																							WHERE c.mov_number = b.mov_number
																						)
															)
								) ,
		EndDate   	
INTO    #TempFirstMove
FROM	
	(
		SELECT 	#FirstMoveLegheader.ord_hdrnumber,
       			CASE 	WHEN #FirstMoveLegheader.ord_hdrnumber = 0 Then --IF dedicated empty move
							lgh_startcty_nmstct
       					ELSE
							Origin
       			End AS Origin,
       			CASE 	WHEN #FirstMoveLegheader.ord_hdrnumber = 0 Then --IF dedicated empty move
							lgh_endcty_nmstct
       					ELSE
							Destination
       			End AS Destination,
       			#FirstMoveLegheader.mov_number,
       			(
					SELECT SUM(stops.stp_lgh_mileage) 
					FROM stops (NOLOCK) 
					WHERE stops.mov_number = #FirstMoveLegheader.mov_number
				) AS TotalMiles,
       			lgh_driver1 AS [Driver],
       			#FirstMoveLegheader.lgh_number,
       			lgh_enddate AS EndDate,
       			ord_number
		FROM   #FirstMoveLegheader (NOLOCK)
		WHERE  #FirstMoveLegheader.lgh_number = (
											SELECT MAX(b.lgh_number) 
											FROM #FirstMoveLegHeader b 
											WHERE b.mov_number = #FirstMoveLegHeader.mov_number 
												AND b.lgh_startdate = 	(
																			SELECT MAX(c.lgh_startdate) 
																			FROM #FirstMoveLegHeader c 
																			WHERE c.mov_number = b.mov_number
																		)
										)
		GROUP BY #FirstMoveLegheader.mov_number,lgh_enddate,#FirstMoveLegheader.lgh_number,Origin,Destination,lgh_endcty_nmstct,lgh_startcty_nmstct,lgh_driver1,#FirstMoveLegheader.ord_hdrnumber,#FirstMoveLegheader.ord_number
	) AS TempMoves

/**************************************************************************
	Step 4:
	
	Select all legheaders where the Start Date is within the minutes back,
	and the status is not Cancelled.
	
**************************************************************************/
SELECT 	legheader.mov_number,
		lgh_driver1,
		lgh_startdate,
		lgh_enddate,
		lgh_number,
		lgh_outstatus,
		ord_hdrnumber,
		lgh_class1,
		lgh_class2,
		lgh_class3,
		lgh_class4,
		lgh_startcty_nmstct,
		lgh_endcty_nmstct
INTO   	#legheader
FROM  	legheader (NOLOCK)
WHERE  	lgh_startdate > @BeginDate
       	AND lgh_outstatus <> 'CAN'

/**************************************************************************
	Step 5:

	Select the next move for the driver where the leg status is not 
	cancelled, and the previous end date is less than the next start date
	
**************************************************************************/
SELECT #TempFirstMove.mov_number,
       NextMoveNumber = 	(
								SELECT MIN(b.mov_number) 
								FROM #legheader b (NOLOCK) 
								WHERE b.lgh_outstatus <> 'CAN' 
									AND #TempFirstMove.FirstMoveDriver = b.lgh_driver1 
									AND b.lgh_startdate = 	(
																SELECT MIN(c.lgh_startdate) 
																FROM #legheader c (NOLOCK) 
																WHERE b.lgh_driver1 = c.lgh_driver1 
																	AND c.lgh_startdate > #TempFirstMove.EndDate 
																	AND c.lgh_outstatus <> 'CAN'
															)
							)
INTO  #TempFirstMoveAndNextMoveList
FROM  #TempFirstMove
 
/**************************************************************************
	Step 6:
	
	Select all possible future movements tied to the driver 
	on the first moves
**************************************************************************/
SELECT 	orderheader.mov_number,
       	ord_completiondate,
       	ord_hdrnumber,
       	(
			SELECT ISNULL(cty_name,'') + ',' + ISNULL(cty_state,'') 
			FROM city (NOLOCK) 
			WHERE cty_code = ord_origincity
		) AS Origin,
       	(
			SELECT ISNULL(cty_name,'') + ',' + ISNULL(cty_state,'') 
			FROM city (NOLOCK) 
			WHERE cty_code = ord_destcity
		) AS Destination,
       	ord_number
INTO   	#NextMoveAndOrderList
FROM   	orderheader (NOLOCK), #TempFirstMoveAndNextMoveList
WHERE  	#TempFirstMoveAndNextMoveList.NextMoveNumber = orderheader.mov_number
       	AND (@NextTripRevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @NextTripRevType1) >0)
      	AND (@NextTripRevType2 =',,' or CHARINDEX(',' + ord_revtype2 + ',', @NextTripRevType2) >0)
       	AND (@NextTripRevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @NextTripRevType3) >0)
       	AND (@NextTripRevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @NextTripRevType4) >0)
UNION
SELECT 	#legheader.mov_number,
       	lgh_enddate AS ord_completiondate,
       	ord_hdrnumber,
       	lgh_startcty_nmstct AS Origin,
       	lgh_endcty_nmstct AS Destination,
       	'0' AS ord_number
FROM   	#legheader (NOLOCK), #TempFirstMoveAndNextMoveList
WHERE  	#TempFirstMoveAndNextMoveList.NextMoveNumber = #legheader.mov_number
       	AND #legheader.ord_hdrnumber = 0
       	AND lgh_outstatus <> 'CAN'
       	AND (@NextTripRevType1 =',,' or CHARINDEX(',' + lgh_class1 + ',', @NextTripRevType1) >0)
       	AND (@NextTripRevType2 =',,' or CHARINDEX(',' + lgh_class2 + ',', @NextTripRevType2) >0)
       	AND (@NextTripRevType3 =',,' or CHARINDEX(',' + lgh_class3 + ',', @NextTripRevType3) >0)
       	AND (@NextTripRevType4 =',,' or CHARINDEX(',' + lgh_class4 + ',',@NextTripRevType3) >0)

/**************************************************************************
	Step 7:
	
	Select the corresponding legheader for the next move where the status
	is not cancelled, and the order is the minimum order with the minimum
	completion date
	
**************************************************************************/
SELECT  legheader.mov_number,
		lgh_driver1,
		lgh_startdate,
		lgh_enddate,
		lgh_number,
		lgh_outstatus,
		lgh_startcty_nmstct,
		lgh_endcty_nmstct,
		legheader.ord_hdrnumber,
		Origin,Destination,
		ord_number,
		ord_completiondate
INTO    #NextMoveLegheader
FROM    legheader (NOLOCK), #NextMoveAndOrderList
WHERE   legheader.mov_number = #NextMoveAndOrderList.mov_number
        AND lgh_outstatus <> 'CAN'
		AND #NextMoveANDOrderList.ord_hdrnumber = 	(
														SELECT MIN(b.ord_hdrnumber) 
														FROM #NextMoveAndOrderList b 
														WHERE b.mov_number = #NextMoveAndOrderList.mov_number 
																AND b.ord_completiondate = 	(
																								SELECT MIN(c.ord_completiondate) 
																								FROM #NextMoveAndOrderList c 
																								WHERE c.mov_number = b.mov_number
																							)
													)
       
/**************************************************************************
	Step 8:

	Select the corresponding move data for the next legheader
	
	
**************************************************************************/
SELECT  [Origin],
		[Destination],
		ord_number AS [Order #],
		TempMoves.mov_number,
		TotalMiles,
		ISNULL(dbo.fnc_TMWRN_Revenue('Movement',DEFAULT,DEFAULT,mov_number,DEFAULT,DEFAULT,DEFAULT,@IncludeChargeTypeListOnly,DEFAULT,DEFAULT,DEFAULT,DEFAULT,@ExcludeBillToIDList,DEFAULT,DEFAULT,DEFAULT),0) AS Revenue,
        Driver AS [NextMoveDriver],
		EndDate  	
INTO    #TempNextMove
FROM	
   (
		SELECT 	#NextMoveLegheader.ord_hdrnumber,
       			CASE 	WHEN #NextMoveLegheader.ord_hdrnumber = 0 Then --IF dedicated empty move
							lgh_startcty_nmstct
       					ELSE
							Origin
       			End AS Origin,
       			CASE 	WHEN #NextMoveLegheader.ord_hdrnumber = 0 Then --IF dedicated empty move
							lgh_endcty_nmstct
       					ELSE
							Destination
       			End AS Destination,
       			#NextMoveLegheader.mov_number,
       			(
					SELECT Sum(stops.stp_lgh_mileage) 
					FROM stops (NOLOCK) 
					WHERE stops.mov_number = #NextMoveLegheader.mov_number
				) AS TotalMiles,
       			lgh_driver1 AS [Driver],
       			#NextMoveLegheader.lgh_number,
       			CASE 	WHEN #NextMoveLegheader.ord_hdrnumber = 0 Then --IF dedicated empty move
							lgh_enddate
       					ELSE
							ord_completiondate
       			End AS EndDate,
       			ord_number
		FROM   #NextMoveLegheader (NOLOCK)
		WHERE  #NextMoveLegheader.lgh_number = 	(
											SELECT MAX(b.lgh_number) 
											FROM #NextMoveLegHeader b 
											WHERE b.mov_number = #NextMoveLegheader.mov_number 
													AND b.lgh_enddate = 	(
																				SELECT MAX(c.lgh_enddate) 
																				FROM #NextMoveLegheader c 
																				WHERE c.mov_number = b.mov_number
																			)
										) 
		GROUP BY #NextMoveLegheader.mov_number,lgh_enddate,#NextMoveLegheader.lgh_number,Origin,Destination,lgh_endcty_nmstct,lgh_startcty_nmstct,lgh_driver1,#NextMoveLegheader.ord_hdrnumber,#NextMoveLegheader.ord_number,#NextMoveLegheader.ord_completiondate
	) AS TempMoves


/**************************************************************************
	Step 9:
	
	Select the total round trip data with Revenue and Miles
	
**************************************************************************/
SELECT TempRoundTrip2.*
INTO #TempResults
FROM
	(
		SELECT  CASE 	WHEN Miles = 0 then
	    					CAST(Revenue AS MONEY)
        				ELSE
            				CAST((Revenue/Miles) AS MONEY)
        				END 
				AS RevPerMile,
				TempRoundTrip.*
	    FROM  
			(
				SELECT 	FirstMoveDriverDisplay AS FirstDriver,
   						NextMoveDriver AS NextDriver,
   						CAST((#TempFirstMove.Revenue + #TempNextMove.Revenue) AS decimal(10,2)) AS Revenue,
  						(#TempFirstMove.TotalMiles + #TempNextMove.TotalMiles) AS Miles,
   						#TempFirstMove.Origin AS Origin,
   						#TempNextMove.Destination AS Destination,
   						#TempFirstMove.mov_number AS FirstMove,
   						#TempNextMove.mov_number AS NextMove
				FROM   #TempFirstMove, #TempNextMove, #TempFirstMoveAndNextMoveList
				WHERE  #TempFirstMoveAndNextMoveList.mov_number = #TempFirstMove.mov_number
   						AND #TempFirstMoveAndNextMoveList.NextMoveNumber = #TempNextMove.mov_number
   
			) AS TempRoundTrip
	) AS TempRoundTrip2
WHERE  RevPerMile < @MinThreshold
       AND Revenue > 0
ORDER BY RevPerMile ASC

--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
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
