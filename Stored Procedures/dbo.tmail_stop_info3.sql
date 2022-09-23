SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tmail_stop_info3] @stop_nbr varchar(12),
									  @sTargetTZ varchar(3),
									  @sTargetTZDSTCode varchar(2),
									  @sTargetTZMin varchar(2)

AS

/* tmail_stop_info **************************************************************
** Pulls informatiON about a specific stop
** Created:		Matthew Zerefos  05/01/00		

	*** Order for stop determinatiON
	1. Stop number
	2. Move number, stop sequence & tractor
	3. Order number, stop sequence & tractor
	4. Stop sequence and tractor (STD leg first, then oldest PLN or DSP)
	5. First stop not actualized for this tractor (STD leg first, then oldest PLN or DSP)

* REVISIONS *
* 01/19/06 MIZ Added StopState view field (PTS31401).
* 01/23/06 MIZ Added StopStatus and StopDepartStatus view fields (PTS31470)
* 05/31/06 TSA Added UnloadPayType (PTS31505).
* 08/07/06 DWG Added TimezONe informatiON
* 10/23/06 TSA Added HubMiles (PTS31484).
* 07/15/10 LAB Added ISNULL around Pieces and Pieces Unit (PTS53233)
* 04/04/13 HMA replaced conditional logic for StopLatestDate & StopLatestTime with stp_schdtlatest (PTS54512)
* 12/10/13 DWG Added AAD Confirms for Position Server (74047)
* 05/14/15 AB  Updated the size of the Shipper column from 8 to 50. (PTS88991)
*********************************************************************************/

SET NOCOUNT ON
set transaction isolation level read uncommitted 

DECLARE @stop int,
	@success tinyint,
	@move int,
	@order int,
	@sT_1 varchar(200) 		-- TranslatiON String

--DWG {33386} Create TimeZONe variables
DECLARE @sSysTZ varchar(3),
		@iSysTZ int,
		@iSysDSTCode int,
		@iSysTZMin int,
		@iSourceTZ int,
		@iSourceTZMin int,
		@iSourceTZDSTCode int,
		@iTargetTZ int,
		@iTargetTZDSTCode int,
		@iTargetTZMin int,		
		@iStopTZ int,
		@iStopTZMin int,
		@iStopTZDSTCode int,
		@sDSTApplies varchar(1),
		@DestDate datetime,
		@StopEarliestTZDate datetime,
		@StopEarliestTZTime datetime,
		@StopEarliestTZDtTm datetime,
		@StopLatestTZDate datetime,
		@StopLatestTZTime datetime,
		@StopLatestTZDtTm datetime,
		@StopTZDate datetime, 
		@StopTZTime datetime,
		@StopTZDtTm datetime,
		@StopDepartureTZDate datetime,
		@StopDepartureTZTime datetime,
		@StopDepartureTZDtTm datetime

--DWG {33386} Target TimezONe, NULL cONverted to 0 (GMT)
SELECT @iTargetTZ = ISNULL(CONVERT(int, @sTargetTZ), 0), @iTargetTZDSTCode = ISNULL(CONVERT(int, @sTargetTZDSTCode), 0), @iTargetTZMin = ISNULL(CONVERT(int, @sTargetTZMin), 0)

IF NOT ISNULL(@stop_nbr,'') = ''  
	SELECT @stop = CONVERT(int, @stop_nbr)
ELSE 
	SELECT @stop = -1

SELECT @success = 0	-- We haven't gathered enough informatiON yet
SELECT @move = 0
SELECT @order = 0

-- Get Order and move numbers
IF @stop <> -1
  BEGIN
	SELECT @success = 1	-- Flag as having enough informatiON

	-- Need the move number
	SELECT @move = ISNULL(mov_number, -1) 
	FROM stops (NOLOCK)
	WHERE stp_number = @stop	

	-- Try to get the order number
	SELECT @order = ISNULL(ord_hdrnumber, -1) 
	FROM stops (NOLOCK)
	WHERE stp_number = @stop

	IF @order = -1 OR @order = 0	-- Order # wasn't in stops table, so look at the min(ordernumber) for this move
	  BEGIN
		IF @move <> -1
			SELECT @order = MIN(ord_hdrnumber)
			FROM stops (NOLOCK)
			WHERE mov_number = @move
			  AND ord_hdrnumber > 0
	  END
  END

-- Now start collecting the informatiON
SELECT  CONVERT(varchar(9),'') CommodityCode,			
	CONVERT(varchar(64),'') CommodityName,
	ISNULL(legheader.lgh_outstatus,'') DispatchStatus,
	ISNULL(legheader.lgh_driver1,'') DriverID,
	ISNULL(stops.stp_event,'') EventCode,			-- 5

	ISNULL(eventcodetable.name, '') EventText,
	stops.stp_schdtearliest LoadingHoursFrom,
	stops.stp_lgh_mileage Mileage,						
	@move MoveNumber,
	CONVERT(varchar(254),'') OrderHeaderComments,	-- 10

	CONVERT(varchar(30), '') OrderNumber,				
	0 Pieces,				
	CONVERT(varchar(6),'') PiecesCountUnit,	
	CONVERT(varchar(254),'') ReferenceNumber,
	CONVERT(varchar(6),'') ReferenceType,		-- 15

	-- 88991 - 05.14.15 AB: Updated the size of the
	-- shipper column from 8 to 50 chars.
	CONVERT(varchar(50),'') Shipper,				
	ISNULL(company.cmp_address1,'') StopAddress1,
	ISNULL(company.cmp_address2,'') StopAddress2,
	ISNULL(city.cty_name,'') StopCity,
	ISNULL(stops.cmd_code,'') StopCommodityCode,	-- 20

	ISNULL(stops.stp_descriptiON,'')  StopCommodityName,
	ISNULL(stops.cmp_id,'') StopCompanyID,
	ISNULL(company.cmp_name,'') StopCompanyName,
	ISNULL(company.cmp_cONtact,'') StopCONtact,
	stops.stp_count StopCount,						-- 25

	ISNULL(stops.stp_countunit,'') StopCountUnit,		
	CONVERT(char,stops.stp_arrivaldate,101) StopDate,
	CONVERT(datetime, CONVERT(char, 
			CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
			THEN stp_schdtearliest
			ELSE ISNULL(stp_arrivaldate, '19500101')
			END,
			101), 101) StopEarliestDate,				
	CONVERT(datetime, CONVERT( char, 
			CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
			THEN stp_schdtearliest
			ELSE ISNULL(stp_arrivaldate, '19500101')
			END,
			108), 108) StopEarliestTime,
	CONVERT(datetime, CONVERT( char, 
		-- PTS 54512 HMA 4/4/13
		--	CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND 
		--	           ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
		--	THEN stp_schdtlatest
		--	ELSE ISNULL(stp_departuredate, '20491231')
		--	END,
		stp_schdtlatest,
			101), 101) StopLatestDate,			-- 30

	CONVERT(datetime, CONVERT( char,
		-- PTS 54512 HMA 4/4/13
		--	CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND 
		--	           ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
		--	THEN stp_schdtlatest
		--	ELSE ISNULL(stp_departuredate, '20491231')
		--	END,
		stp_schdtlatest,
			108), 108) StopLatestTime,


	CONVERT(char,stops.stp_arrivaldate,120) StopTZDate,
	CONVERT(datetime, CONVERT(char, 
			CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
			THEN stp_schdtearliest
			ELSE ISNULL(stp_arrivaldate, '19500101')
			END,
			120), 120) StopEarliestTZDate,				
	CONVERT(datetime, CONVERT( char, 
			CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
			THEN stp_schdtearliest
			ELSE ISNULL(stp_arrivaldate, '19500101')
			END,
			120), 120) StopEarliestTZTime,
	CONVERT(datetime, CONVERT( char, 
			CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
			THEN stp_schdtlatest
			ELSE ISNULL(stp_departuredate, '20491231')
			END,
			120), 120) StopLatestTZDate,			-- 30

	CONVERT(datetime, CONVERT( char,
			CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
			THEN stp_schdtlatest
			ELSE ISNULL(stp_departuredate, '20491231')
			END,
			120), 120) StopLatestTZTime,

	@stop StopNumber,
	ISNULL(company.cmp_primaryphONe,'') StopPhONe,
	stops.stp_dispatched_sequence StopSequence,
	CONVERT(char,stp_arrivaldate,108) StopTime,	-- 35

	CONVERT(char,stp_arrivaldate,120) StopTZTime,

	stops.stp_weight StopWeight,				
	ISNULL(stops.stp_weightunit,'') StopWeightUnit,
	ISNULL(legheader.lgh_tractor,'') Tractor,
	ISNULL(legheader.lgh_primary_trailer,'') Trailer1,
	ISNULL(legheader.lgh_primary_pup,'') Trailer2,	-- 40

	@order OrdHdrNumber, 
	stops.lgh_number,
	CASE event.evt_trailer1
		WHEN 'UNKNOWN' then ''
		ELSE event.evt_trailer1 END evt_trailer1,
	CASE event.evt_trailer2
		WHEN 'UNKNOWN' then ''
		ELSE event.evt_trailer2 END evt_trailer2,
	ISNULL(stops.stp_type, '') StopType,		-- 45

	ISNULL(stops.stp_refType, '') StopReferenceType,
	ISNULL(stops.stp_refNum, '') StopReferenceNumber,
	ISNULL(stops.stp_comment, '') StopComments,
	ISNULL(stops.stp_zipcode, '') StopZip,
	CONVERT(char,stops.stp_arrivaldate,120) StopDtTm,	-- 50

	CONVERT(datetime, CONVERT(char, 
			CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
			THEN stp_schdtearliest
			ELSE ISNULL(stp_arrivaldate, '19500101')
			END,
			120), 120) StopEarliestDtTm,				
	CONVERT(datetime, CONVERT( char, 
			CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
			THEN stp_schdtlatest
			ELSE ISNULL(stp_departuredate, '20491231')
			END,
			120), 120) StopLatestDtTm,
	CONVERT(char,stops.stp_departuredate,101) StopDepartureDate,
	CONVERT(char,stops.stp_departuredate,108) StopDepartureTime,
	CONVERT(char,stops.stp_departuredate,120) StopDepartureDtTm,		-- 55

	CONVERT(char,stops.stp_arrivaldate,120) StopTZDtTm,	

	CONVERT(datetime, CONVERT(char, 
			CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
			THEN stp_schdtearliest
			ELSE ISNULL(stp_arrivaldate, '19500101')
			END,
			120), 120) StopEarliestTZDtTm,				
	CONVERT(datetime, CONVERT( char, 
			CASE WHEN (ABS(DATEDIFF(yy, ISNULL(stp_schdtearliest, '19500101'), GETDATE()))<5 AND ABS(DATEDIFF(yy, ISNULL(stp_schdtlatest, '19500101'), GETDATE()))<5)
			THEN stp_schdtlatest
			ELSE ISNULL(stp_departuredate, '20491231')
			END,
			120), 120) StopLatestTZDtTm,
	CONVERT(char,stops.stp_departuredate,120) StopDepartureTZDate,
	CONVERT(char,stops.stp_departuredate,120) StopDepartureTZTime,
	CONVERT(char,stops.stp_departuredate,120) StopDepartureTZDtTm,	

	ISNULL(city.cty_state,'') StopState,
	stops.stp_status StopStatus,
	stops.stp_departure_status StopDepartStatus,
	stops.stp_unload_paytype UnloadPayType,
	event.evt_hubmiles HubMiles,
	ISNULL(stops.stp_arr_cONfirmed,'N') StopArrivalCONfirmed,
	ISNULL(stops.stp_dep_cONfirmed,'N') StopDepartureCONfirmed,
	ISNULL(stops.stp_aad_arvConfidence,'0') StopAADArrivalConfidence,  --PTS 74047
	ISNULL(stops.stp_aad_depConfidence,'0') StopAADDepartureConfidence --PTS 74047
INTO #t
FROM ((((stops 
		left outer join company ON stops.cmp_id = company.cmp_id)
		inner join legheader ON legheader.lgh_number = stops.lgh_number)
		left outer join city ON stops.stp_city = city.cty_code)
		inner join eventcodetable  ON stops.stp_event = eventcodetable.abbr)
		left outer join event ON stops.stp_number = event.stp_number and event.evt_sequence = 1
WHERE stops.stp_number = @stop

--DWG {33386} Return TZ times, adjust the times
SELECT 	@sSysTZ = gi_string1 FROM GeneralInfo WHERE gi_name = 'SysTZ'
SELECT 	@iSysDSTCode = CONVERT(int, gi_string1) FROM GeneralInfo WHERE gi_name = 'SysDSTCode'
SELECT 	@iSysTZMin = CONVERT(int, gi_string1) FROM GeneralInfo WHERE gi_name = 'SysTZMin'
SET @iSysTZ = CONVERT(int, @sSysTZ)

IF ISNULL(@sSysTZ, '') = ''
	SET @iSourceTZ = 999
ELSE
	--Set default to System Time ZONe
	SELECT @iSourceTZ = @iSysTZ, @iSourceTZDSTCode = @iSysDSTCode, @iSourceTZMin = @iSysTZMin

--find stop Time ZONe informatiON - if any
--See if TimezONe informatiON is ON the city attached to the stop
SELECT 	@iStopTZ = cty_GMTDelta, 
		@iStopTZMin = cty_TZMins, 
		@sDSTApplies = ISNULL(cty_DSTApplies, 'N')
FROM stops (NOLOCK)
	INNER JOIN city (NOLOCK) ON city.cty_code = stops.stp_city
WHERE stops.stp_Number = @stop

if @sDSTApplies = 'Y' 
	SET @iStopTZDSTCode = 0
ELSE
	SET @iStopTZDSTCode = -1

if ISNULL(@iStopTZ, 999) <> 999
	SELECT @iSourceTZ = @iStopTZ, @iSourceTZDSTCode = @iStopTZDSTCode, @iSourceTZMin = @iStopTZMin
ELSE
	--See if TimezONe informatiON is ON the city attached to the company ON the stop
	BEGIN
		SELECT 	@iStopTZ = cty_GMTDelta, 
				@iStopTZMin = cty_TZMins, 
				@sDSTApplies = ISNULL(cty_DSTApplies, 'N')
		FROM Stops (NOLOCK)
			INNER JOIN company (NOLOCK) ON company.cmp_id = stops.cmp_id
			INNER JOIN city (NOLOCK) ON city.cty_code = company.cmp_city
		WHERE stops.stp_Number = @stop

		if @sDSTApplies = 'Y' 
			SET @iStopTZDSTCode = 0
		ELSE
			SET @iStopTZDSTCode = -1

		if ISNULL(@iStopTZ, 999) <> 999
			SELECT @iSourceTZ = @iStopTZ, @iSourceTZDSTCode = @iStopTZDSTCode, @iSourceTZMin = @iStopTZMin
	END

if ISNULL(@iSourceTZ, 999) <> 999 --Make sure the system time zONe is set
	BEGIN

		--Get stop datetimes
		SELECT @StopEarliestTZDate = StopEarliestTZDate, 
			   @StopEarliestTZTime = StopEarliestTZTime, 
			   @StopEarliestTZDtTm = StopEarliestTZDtTm,
			   @StopLatestTZDate = StopLatestTZDate, 
			   @StopLatestTZTime = StopLatestTZTime,
			   @StopLatestTZDtTm = StopLatestTZDtTm,
			   @StopTZDate = StopTZDate, 
			   @StopTZTime = StopTZTime,
			   @StopTZDtTm = StopTZDtTm,
			   @StopDepartureTZDate = StopDepartureTZDate,
			   @StopDepartureTZTime = StopDepartureTZTime,
			   @StopDepartureTZDtTm = StopDepartureTZDtTm
		FROM	#t

		SET @DestDate =  NULL --Stop Earliest
		EXEC ChangeTZ_7 @StopEarliestTZDate, @iSourceTZ, @iSourceTZDSTCode, @iSourceTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
		SELECT @StopEarliestTZDate = @DestDate, @StopEarliestTZTime = @DestDate, @StopEarliestTZDtTm = @DestDate
		SET @DestDate =  NULL --Stop Latest
		EXEC ChangeTZ_7 @StopLatestTZDate, @iSourceTZ, @iSourceTZDSTCode, @iSourceTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
		SELECT @StopLatestTZDate = @DestDate, @StopLatestTZTime = @DestDate, @StopLatestTZDtTm = @DestDate
		SET @DestDate =  NULL --Stop (arrival)
		EXEC ChangeTZ_7 @StopTZDate, @iSourceTZ, @iSourceTZDSTCode, @iSourceTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
		SELECT @StopTZDate = @DestDate, @StopTZTime = @DestDate, @StopTZDtTm = @DestDate
		SET @DestDate =  NULL --Stop Departure
		EXEC ChangeTZ_7 @StopDepartureTZDate, @iSourceTZ, @iSourceTZDSTCode, @iSourceTZMin, @iTargetTZ, @iTargetTZDSTCode, @iTargetTZMin, @DestDate out
		SELECT @StopDepartureTZDate = @DestDate, @StopDepartureTZTime = @DestDate, @StopDepartureTZDtTm = @DestDate

		--UPDATE cONverted dates
		UPDATE #t
		SET	#t.StopEarliestTZDate = cONvert(datetime, CONVERT( char, ISNULL(@StopEarliestTZDate,''), 101), 101),
			#t.StopEarliestTZTime = cONvert(datetime, CONVERT( char, ISNULL(@StopEarliestTZTime,''), 108), 108),
			#t.StopEarliestTZDtTm = cONvert(datetime, CONVERT( char, ISNULL(@StopEarliestTZDtTm,''), 120), 120),
			#t.StopLatestTZDate = cONvert(datetime, CONVERT( char, ISNULL(@StopLatestTZDate,''), 101), 101),
			#t.StopLatestTZTime = cONvert(datetime, CONVERT( char, ISNULL(@StopLatestTZTime,''), 108), 108),
			#t.StopLatestTZDtTm = cONvert(datetime, CONVERT( char, ISNULL(@StopLatestTZDtTm,''), 120), 120),
		    #t.StopTZDate = CONVERT( char, ISNULL(@StopTZDate,''), 101), 
			#t.StopTZTime = CONVERT( char, ISNULL(@StopTZTime,''), 108), 
			#t.StopTZDtTm = CONVERT( char, ISNULL(@StopTZDtTm,''), 120), 
			#t.StopDepartureTZDate = CONVERT( char, ISNULL(@StopDepartureTZDate,''), 101), 
			#t.StopDepartureTZTime = CONVERT( char, ISNULL(@StopDepartureTZTime,''), 108), 
			#t.StopDepartureTZDtTm = CONVERT( char, ISNULL(@StopDepartureTZDtTm,''), 120)

	END

-- PTS34206
UPDATE #t
	SET #t.StopCity = ISNULL(city.cty_name,''),
		#t.StopState =  ISNULL(city.cty_state,''),
		#t.StopPhONe = '',
		#t.StopCONtact = '',
		#t.StopAddress1 = '',
		#t.StopAddress2 = ''
FROM #t INNER JOIN stops ON #t.StopNumber = stops.stp_number  
		  INNER JOIN city ON city.cty_code = stops.stp_city
WHERE #t.StopCompanyID = 'UNKNOWN' 

-- Now fill in the order informatiON
IF @order > 0
	UPDATE #t
	SET 	#t.OrderHeaderComments = ISNULL(ord_remark,''),
		#t.Pieces = ISNULL(ord_totalpieces,0),
		#t.PiecesCountUnit = ISNULL(ord_totalcountunits,''),
		#t.ReferenceNumber = ISNULL(ord_refnum,''),
		#t.ReferenceType = ISNULL(ord_reftype,''),
		#t.Shipper = ISNULL(ord_shipper,''),
		#t.CommodityCode = ISNULL(cmd_code,''),
		#t.CommodityName = ISNULL(ord_descriptiON,''),
		#t.OrderNumber = ISNULL(ord_number, '')
	FROM #t,orderheader
	WHERE ord_hdrnumber = @order

-- Return the data
SELECT * FROM #t
GO
GRANT EXECUTE ON  [dbo].[tmail_stop_info3] TO [public]
GO
