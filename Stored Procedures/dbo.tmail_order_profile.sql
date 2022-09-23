SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_order_profile]
	@order_number varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@lgh_Num varchar(12),
	@Flags varchar(1) 

AS

SET NOCOUNT ON 

-- 3/15/06 CH: added TMStatus and leg_outstatus fields

/* For testing 
DECLARE	@order_number varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@lgh_Num varchar(12),
	@Flags varchar(1) 
SET @order_number = ''
SET @move = ''
SET @tractor = ''
SET @lgh_num = ''
SET @flags = '' */

DECLARE @move_number int,
	@ordhdr int,
	@KillRTPTimeFlag varchar(20),
	@sT_1 varchar(200), 		-- Translation String
	@iFlags int

-- Convert the @Flags to an int so we can do math on it
--  This is mainly for SQL Server 6.5 users
SELECT @iFlags = CONVERT(int,ISNULL(@Flags,'0'))

IF ISNULL(@LGH_Num, '0') = '0' OR ISNULL(@LGH_Num, '') = ''
	EXEC dbo.tmail_get_lgh_number_sp @order_number, @move, @tractor, @lgh_Num OUT

IF ISNULL(@LGH_Num, '0') = '0' OR ISNULL(@LGH_Num, '') = ''
  BEGIN
	SELECT @sT_1 = 'TMWERR: {Load Assign2} No LegHeader Found.'
--	EXEC dbo.tm_t_sp @sT_1 out, 1, ''
	RAISERROR (@sT_1,16,-1)
	RETURN 1
  END

-- Check if the stp_dispatched_seq is set and if @iFlags > 3
--  If so, leave @flags alone because we don't want to renumber the stp_dispatched_sequence
--  If not, subtract 4 from @iFlags because we do want to set the stp_dispatched_sequence
IF NOT EXISTS (SELECT stp_number 
				FROM stops (NOLOCK)
				WHERE lgh_number = CONVERT(int,@lgh_num) AND ISNULL(stp_dispatched_sequence,-1) <> -1)
	IF @iFlags > 3
		SELECT @iFlags = @iFlags - 4	
	
SELECT	event.evt_tractor Tractor,
	'            ' OrderNumber,
	stops.mov_number MoveNumber,
	CONVERT(float, 0.0) Revenue,
	CONVERT(float, 0.0) LineHaul,
	'        ' Shipper,
	'        ' Consignee,
	'          ' ScheduledPickupEarliestDate,
	'        ' ScheduledPickupEarliestTime,
	'          ' ScheduledPickupLatestDate,
	'        ' ScheduledPickupLatestTime,
	'          ' ScheduledDeliveryEarliestDate,
	'        ' ScheduledDeliveryEarliestTime,
	'          ' ScheduledDeliveryLatestDate,
	'        ' ScheduledDeliveryLatestTime,
	'        ' CommodityCode,
	0 Pieces,
	'      ' PiecesCountUnit,
	0 Weight,
	'      ' WeightUnit,
	0 Volume,
	'      ' VolumeUnit,
	'      ' ReferenceType, 
	SPACE (254) ReferenceNumber,
	CONVERT( varchar(254), '' ) OrderHeaderComments,
	evt_trailer1 Trailer1,
	evt_trailer2 Trailer2,
	lgh_outstatus DispatchStatus,
	stops.cmp_id StopCompanyID,
	stops.stp_event EventCode,
	stops.cmd_code StopCommodityCode,
	stops.stp_refnum StopReferenceNumber,
	stops.stp_reftype StopReferenceType,
	stops.stp_comment StopComment,
	CONVERT( char, stp_schdtearliest, 101) StopEarliestDate,
	CONVERT( char, stp_schdtearliest, 108) StopEarliestTime,
	CONVERT( char, stp_schdtlatest, 101) StopLatestDate,
	CONVERT( char, stp_schdtlatest, 108) StopLatestTime,
	stp_lgh_mileage Mileage,
	stp_lgh_mileage StopMileage,
	stp_loadstatus StopMileType,
	stp_lgh_mileage LoadedMiles,
	stp_lgh_mileage EmptyMiles,
	stops.stp_number StopNumber,
	0 StopSequence ,
	stp_weight StopWeight,
	stp_weightunit StopWeightUnit,
	stp_count StopCount, 
	stp_countunit StopCountUnit,
	stp_volume StopVolume,
	stp_volumeunit StopVolumeUnit,
	stpcomp.cmp_name StopCompanyName,
	case when isnull(stops.stp_address, '') = '' then
		stpcomp.cmp_address1
	else 
		stops.stp_address
	end StopAddress1,
	case when isnull(stops.stp_address2, '') = '' then
		stpcomp.cmp_address2
	else 
		stops.stp_address2 
	end StopAddress2,
	stpcity.cty_nmstct StopCity,
	case when isnull(stops.stp_phonenumber, '') = '' then
		stpcomp.cmp_primaryphone
	else
		stops.stp_phonenumber
	end StopPhone,
	stpcomp.cmp_contact StopContact,
	stops.stp_description StopCommodityName,
	CONVERT( char, stops.stp_arrivaldate, 101) StopDate,
	CONVERT( char, stops.stp_arrivaldate, 108) StopTime,
	stops.stp_mfh_sequence StopMoveSeq,
	stops.ord_hdrnumber OrdHdrNumber,
	stops.stp_status StopStatus,
	orderheader.ord_number StopOrderNumber,
	CONVERT(smallint, 0) MinTemp,
	CONVERT(smallint, 0) MaxTemp,
	orderheader.ord_revtype1 RevenueType1,
	orderheader.ord_revtype2 RevenueType2,
	orderheader.ord_revtype3 RevenueType3,
	orderheader.ord_revtype4 RevenueType4,
	orderheader.ord_subcompany SubCompany,
	orderheader.ord_description Description,
	orderheader.ord_cod_amount AS CODAmount,
	orderheader.ord_company AS OrderBy,
	@lgh_num lgh_number,
	orderheader.ord_hdrnumber OrderHdrNumber,
	stops.stp_phonenumber2 StopPhone2,
  legheader.lgh_tm_status AS lgh_TMStatus,
  legheader.lgh_outstatus AS lgh_OutStatus
INTO #tmp
FROM	stops (NOLOCK)
LEFT JOIN orderheader (NOLOCK)
ON stops.ord_hdrnumber = orderheader.ord_hdrnumber,
	event,
	eventcodetable, 
	company stpcomp, 
	legheader, 
	city stpcity

WHERE 	stops.lgh_Number = CONVERT(int,@lgh_num)
  AND 	stops.stp_number = event.stp_number  
  AND   event.evt_sequence = 1
  AND   stops.stp_event = eventcodetable.abbr
  AND	stops.cmp_id = stpcomp.cmp_id 
  AND	stops.lgh_number = legheader.lgh_number 
  AND	stops.stp_city = stpcity.cty_code 


-- Now reset Mileage Totals
UPDATE #tmp 
SET StopMileage = 0 
WHERE ISNULL(StopMileage, -1) = -1

UPDATE MainTmp
SET Mileage = 
	(SELECT SUM(NestTmp.StopMileage)
	 FROM #tmp NestTmp)
FROM #tmp MainTmp

UPDATE MainTmp
SET LoadedMiles = 
	(SELECT SUM(NestTmp.StopMileage) 
 	 FROM #tmp NestTmp
	 WHERE NestTmp.StopMileType = 'LD')
FROM #tmp MainTmp

UPDATE MainTmp
SET EmptyMiles = 
	(SELECT SUM(NestTmp.StopMileage) 
	 FROM #tmp NestTmp
	 WHERE ISNULL(NestTmp.StopMileType,'') != 'LD')
FROM #tmp MainTmp

--Fix mileages around stops that will be removed.
update hookloadedstop
SET hookloadedstop.StopMileage = hookloadedstop.StopMileage + dropmtstop.StopMileage
FROM #tmp dropmtstop, #tmp hookloadedstop
WHERE dropmtstop.StopMoveSeq + 1 = hookloadedstop.StopMoveSeq 
AND dropmtstop.EventCode IN ('EMT', 'DMT', 'EBT' )

--Now remove the MT stops.
delete dropmtstop
FROM #tmp dropmtstop, #tmp hookloadedstop
WHERE dropmtstop.StopMoveSeq + 1 = hookloadedstop.StopMoveSeq
AND dropmtstop.EventCode IN ('EMT', 'DMT', 'EBT' )

-- Update the StopMileType to MT if it is not LD
UPDATE #tmp
SET StopMileType = 'MT'
WHERE ISNULL(StopMileType,'') <> 'LD'

IF @iFlags < 4
  BEGIN
	-- If DontSendDH Flag is set and Not KeepSeqWithDontSendDH, remove all begining BMT or BBT Records
	IF @iFlags = 1
		  DELETE FROM #tmp
		  WHERE ( EventCode IN ('BMT', 'BBT') 
	  	    AND StopMoveSeq = 1)

	/* Now Calculate the stop sequence numbers so always starts with (1) */
	UPDATE MainTmp
	SET MainTmp.StopSequence =
		(SELECT COUNT(*) 
	 	 FROM #tmp NestTmp
		 WHERE NestTmp.StopMoveSeq <= MainTmp.StopMoveSeq )
	FROM #tmp MainTmp

	-- If DontSendDH Flag is set and KeepSeqWithDontSendDH, remove all begining BMT or BBT Records
	IF @iFlags = 2
		  DELETE FROM #tmp
		  WHERE (EventCode IN ('BMT', 'BBT') 
		    AND StopMoveSeq = 1)
  END

/* Now fill in the order information */
IF ISNULL(@order_number, '0') > '0'
  BEGIN
	SELECT @ordhdr = null

	SELECT @ordhdr = ord_hdrnumber 
	FROM orderheader (NOLOCK)
	WHERE ord_number = @order_number

	IF ISNULL(@ordhdr, 0) = 0
	  BEGIN
		SELECT @sT_1 = 'Unknown order number %s'
--		EXEC dbo.tm_t_sp @sT_1, 1, ''
		RAISERROR (@sT_1, 16, -1, @order_number)
		RETURN 1
	  END
  END
ELSE
	SELECT @ordhdr = ISNULL(orderheader.ord_hdrnumber,0), @order_number = ISNULL(orderheader.ord_number, '')
	FROM #tmp, orderheader (NOLOCK)
	WHERE ord_hdrnumber = ( 
		SELECT Min(OrdHdrNumber) 
		FROM #tmp 
		WHERE OrdHdrNumber > 0 )

IF ISNULL(@ordhdr, 0) = 0
	SELECT @ordhdr = MIN(ord_hdrnumber) 
	FROM stops (NOLOCK)
	WHERE mov_number = CONVERT(int,@move_number)
	  AND ord_hdrnumber > 0

IF ISNULL(@ordhdr, 0) <> 0
	-- Only update records that are on the Order
	UPDATE #tmp
	SET 	#tmp.OrderNumber = ISNULL(orderheader.ord_number,''),  
		#tmp.Revenue = ISNULL(orderheader.ord_totalcharge, CONVERT(float, 0.0)),
		#tmp.LineHaul = ISNULL(orderheader.ord_charge, CONVERT(float, 0.0)),
		#tmp.Shipper = ISNULL(orderheader.ord_originpoint,''),  
		#tmp.Consignee = ISNULL(orderheader.ord_destpoint,''),  
		#tmp.ScheduledPickupEarliestDate = CONVERT( char, ISNULL(orderheader.ord_origin_earliestdate,''), 101),
		#tmp.ScheduledPickupEarliestTime = CONVERT( char, ISNULL(orderheader.ord_origin_earliestdate,''), 108),
		#tmp.ScheduledPickupLatestDate = CONVERT( char, ISNULL(orderheader.ord_origin_latestdate,''), 101),
		#tmp.ScheduledPickupLatestTime = CONVERT( char, ISNULL(orderheader.ord_origin_latestdate,''), 108),
		#tmp.ScheduledDeliveryEarliestDate = CONVERT( char, ISNULL(orderheader.ord_dest_earliestdate,''), 101),
		#tmp.ScheduledDeliveryEarliestTime = CONVERT( char, ISNULL(orderheader.ord_dest_earliestdate,''), 108),
		#tmp.ScheduledDeliveryLatestDate = CONVERT( char, ISNULL(orderheader.ord_dest_latestdate,''), 101),
		#tmp.ScheduledDeliveryLatestTime = CONVERT( char, ISNULL(orderheader.ord_dest_latestdate,''), 108),
		#tmp.CommodityCode = ISNULL(orderheader.cmd_code,''),  
		#tmp.Pieces = ISNULL(orderheader.ord_totalpieces,0),
		#tmp.PiecesCountUnit = ISNULL(orderheader.ord_totalcountunits,''),  
		#tmp.Weight = ISNULL(orderheader.ord_totalweight,0),
		#tmp.WeightUnit = ISNULL(orderheader.ord_totalweightunits,''),  
		#tmp.Volume = ISNULL(orderheader.ord_totalvolume, 0),
		#tmp.VolumeUnit = ISNULL(orderheader.ord_totalvolumeunits, ''),
		#tmp.ReferenceType = ISNULL(orderheader.ord_reftype,''),  
		#tmp.ReferenceNumber = ISNULL(orderheader.ord_refnum,''),  
		#tmp.OrderHeaderComments = ISNULL(orderheader.ord_remark,''),
		#tmp.MinTemp = ISNULL(orderheader.ord_mintemp, 0),
		#tmp.MaxTemp = ISNULL(orderheader.ord_maxtemp, 0),
		#tmp.CODAmount = ISNULL(orderheader.ord_cod_amount, 0),
		#tmp.OrderBy = ISNULL(orderheader.ord_company, ''),
		#tmp.OrderHdrNumber = @ordhdr
	FROM orderheader, stops
	WHERE #tmp.StopNumber = stops.stp_number
	  AND stops.ord_hdrnumber = orderheader.ord_hdrnumber

-- Delete any rows that are not on the order
DELETE #tmp
WHERE ISNULL(OrderNumber,'') <> @order_number

IF @iFlags < 4
--  BEGIN
	/* Now Calculate the stop sequence numbers so always starts with (1) */
	UPDATE MainTmp
	SET MainTmp.StopSequence =
		(SELECT COUNT(*) 
	 	 FROM #tmp NestTmp
		 WHERE NestTmp.StopMoveSeq <= MainTmp.StopMoveSeq )
	FROM #tmp MainTmp

	/* Now save the sequence numbers the driver will be told for each stop. */
--	MZ commented out 6/7/01  Don't want to update the sequence on the stops table
--		for the Order Profile view.  May change in future.
/*	UPDATE stops 
	SET stops.stp_dispatched_sequence = #tmp.StopSequence 
	FROM stops, #tmp 
	WHERE stops.stp_number = #tmp.StopNumber 
  END */

SELECT @KillRTPTimeFlag = ISNULL(gi_string1, '') 
FROM generalinfo (NOLOCK)
WHERE gi_name = 'tm_AsnNoRPTm'

IF ISNULL(@KillRTPTimeFlag, '') = 'Y'
	UPDATE #tmp 
	SET 	StopDate = '', 
		StopTime = '',
	 	StopEarliestDate = '', 
		StopEarliestTime = '',
	 	StopLatestDate = '', 
		StopLatestTime = ''
	WHERE EventCode IN ('RTP', 'NBS')

SELECT #tmp.*, commodity.cmd_name CommodityName
FROM #tmp
LEFT JOIN commodity (NOLOCK)
ON CommodityCode = commodity.cmd_code
ORDER BY StopSequence

DROP TABLE #tmp
GO
GRANT EXECUTE ON  [dbo].[tmail_order_profile] TO [public]
GO
