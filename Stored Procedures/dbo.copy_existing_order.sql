SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/*

  MODIFICATION LOG

5/22/01 Written by dpete for PTS 7411 (gudat pts) turned in under PTS 
6/15/01 dpete when there are multiple freight details, it creates one stop per freight detail
    with as many freight detail as on the original order
6/18/01 evt_status for masterorders is alwyas NON while stp_status is OPN,  change copy of evt_status to equal @nextstatus
6/18/01 Add argument at customers request  to copy wgt,vol,count or distance to fgt_quantity field
6/18/01 Customer wants order notes copied
6/19/01 adjustments for ord_rateby
7/18/01 added support for 6 character state

This stored proc will copy an existing order.

It allows the calling code to assign an order number to the copy, but will not complete the copy if that assinged
order number is a duplicate.  If no order number is assinged, the system will assign one.  The order number
of the copy will be returned in one of the arguments.  

It allows for the dates to be reset from a passed argument which becomes the estimated arrival at the first stop
and all other dates are adjusted relative to that date.

It allows for assigning all assets to the trip (no conflict checking is done).

It allows for setting the order status of the created order.  However, If a tractor is assigned and it was
assigned to another trip which is not complete, you cannot set the created order status to STD or CMP, it will
be reset to DSP to avoid conflict.

If a tractor is assigned, you may optionally have a begin empty (BMT) inserted from the last location the tractor was
at. It does not compute the miles from that location to the first stop.

It allows for substituting commodity codes (up to 3) and/or adjusting weigh/volume/count for that commodity.  It cannot
handle setting different weights (vol or count) for the same commodity at multiple drops except as described 
below.  The substitution is straightforward. 
If a commodity code on the copied order (stop or freightdetail) matches one of the three passed as arguments, the
replacement code is substituted (it may be the same code if only wgt/vol/count are to be adjusted.  Then it replaces
the weight, weight unit, count, count unti, volume, volume unit on that stop to the values passed. One might
consider defining dummy commodity codes to be placed on master orders and then substituting as needed.  This gives
the opportunity to handle different delivery wgt/vol/count at different stops for the same commodity by having
a master order with multiple drops with a different dummy commodity code on each. Each is replaced with the same 
'real' commodity, but with different wgt/vol/count.  (A switch could be added to this proc to not create a stop
if the resulting weiht/vol/and count are all zero???)

It allows you to copy all of the reference numbers from the order and/or the stops and/or the freightdetail.

It will assign default loadrequirements.  However it does not check to see if their is a conflice with any of the
assigned assets.

It has a flag to copy all stops on the move of the master order even if they were added by dispatch.  This has not been
tested and is probably dangerous.




*/
/*
Assumes the order to be copied has not been consolidated, split or cross docked!!

RETURN CODES
	1 success
	-1 database error, various order is not copied

  If the validate flag is set to 'Y' you get the following return codes
	-2 order number to copy does not exist on the database copy is stopped
	-3 assign order number is not unique copy is stopped
	-4 invalid tractor or retired (if validate off, this is passed thru)
	-5 invalid trailer1 or retired (if validate off, this is passed thru)
	-6 invalid trailer2 or retired (if validate off, this is passed thru)
	-7 invalid driver1 or terminated (if validate off, this is passed thru)
	-8 invalid driver2 or terminated (if validate off, this is passed thru)
	-9 invalide new commodit code 1 (if validate off, this is passed thru)
	-10 invalid new commodity code 2 (if validate off, this is passed thru)
	-11 invalid new commodity code 3 (if validate off, this is passed thru)
	-12 invalid weight unit 1 (if validate off, this is passed thru)
	-13 invalid weight unit 2 (if validate off, this is passed thru)
	-14 invalid weight unit 3 (if validate off, this is passed thru)
	-15 invalid volume unit 1 (if validate off, this is passed thru)
	-16 invalid volume unit 2 (if validate off, this is passed thru)
	-17 invalid volume unit 3 (if validate off, this is passed thru)
	-18 invalid count unit 1 (if validate off, this is passed thru)
	-19 invalid count unit 2 (if validate off, this is passed thru)
	-20 invalid count unit 3 (if validate off, this is passed thru)
	-21 ord number made up from ord hdrnumber is a duplicate value (This should never happen!) copy is stopped

Arguments

@ordnumber varchar(12) - required - order to be copied

@assignorder varchar(12) - optional may be NULL - if a vlaue is passed try to assing as order number to copied order

@validate char(1) - required - 'Y' turns on validation

@startdate datetime - optional may be NULL - if passed it is the estimated arrival at the first stop on the order to be copied.

@bookedby varchar(8) - optional - value goes in the ord_bookedby field to indicate who entered the order

@beginemptyfrompriortrip char(1) - if 'Y' a begin empty stop is added to the beginning of the copied order from the last stop on the
				 trip that the tractor was last assgned to.  If the prior trip cannot be found the begin empty is not added.

@orderstatus varchar(6) - required (may be 'PLN','DSP','STD','CMP') the status of the copied order.  If an assignment is made and the tractor
was last assigned to a trip whihc is not complete, the order status of the copied order will be 'DSP'

@ordremark varchar(254) - optional, if you want ot place anything in the order remarks field

@copycharges char(1) - optional. If 'Y' will copy the rates and charges on the order (needs to be enhanced to copy any accessorial charges)

@oldcmdcode1 varchar(8), @newcmdcode1 varchar(8), @wgt1 decimal(11,2),@wgtunit1 varchar(6), @vol1 decimal(11,2), @volunit1 varchar(6),
	@count1 int, @countunit1 varchar(6) - allows for commodity and/or wgt/vol/or count substitution. If you want to substitute, place the commodity code
	from the order to be copied followed by the commodity code to replace it (may be the same) followed by the weight, volume and count to
	be placed on that commodity. WARNING - at this time there is no provision for the same commodity sowing up on multiple drops with 
	different wgt/vol/or count on each.  If you want no substitution pass NULL,NULL,0,'UNK',0'UNK',0,'UNK'

@oldcmdcode2 varchar(8), @newcmdcode2 varchar(8), @wgt2 decimal(11,2),@wgtunit2 varchar(6), @vol2 decimal(11,2), @volunit2 varchar(6),
	@count2 int, @countunit2 varchar(6) - see above for commodity 1

@oldcmdcode3 varchar(8), @newcmdcode3 varchar(8), @wgt3 decimal(11,2),@wgtunit3 varchar(6), @vol3 decimal(11,2), @volunit3 varchar(6),
	@count3 int, @countunit3 varchar(6), - see above for old commodity 1

@driver1 varchar(8) - optional - driver to be assigned. NOTE there is no checking on conflicts for the driver.  You better know what you are doing

@driver2 varchar(8) ditto

@tractor varchar(8) - optional - only if BMT is to be added do we look for a prior trip.  No other conflict checking is done at this time

@trailer1 varchar(13) - optional as for driver

@trailer2 varchar(8) as for driver

@carrier varchar(8) as for driver

@copyordrefnums char(1) - optional If 'Y' it will copy all order level reference numbers

 @copystoprefnums char(1) - optional If 'Y' it will copy all stop level reference numbers

 @copyfgtrefnums char(1) - optional If 'Y' it will copy all freightdetail level reference numbers

@copyDispatchStops char(1) - not recommended If 'Y' will copy all dispatch stops on the move that the copied order was on.

@Quantitysource varchar(10) - ('WGT','VOL','CNT',DIS','') if passed indicates quantity comes from weight or volume or count or distance actual

@copyordernotes If 'Y' will copy any order notes

@NewOrderNumber varchar(12) - returns the order number of the copied order if all went well (return code is 1)

*/

CREATE PROCEDURE [dbo].[copy_existing_order] @ordnumber varchar(12), @assignorder varchar(12), @validate char(1), @startdate datetime, 
	@bookedby varchar(8), @beginemptyfrompriortrip char(1),  
	@orderstatus varchar(6), @ordremark varchar(254),@copycharges char(1),
	@oldcmdcode1 varchar(8), @newcmdcode1 varchar(8), @wgt1 decimal(11,2),@wgtunit1 varchar(6), @vol1 decimal(11,2), @volunit1 varchar(6),
	@count1 int, @countunit1 varchar(6),
	@oldcmdcode2 varchar(8), @newcmdcode2 varchar(8), @wgt2 decimal(11,2),@wgtunit2 varchar(6), @vol2 decimal(11,2), @volunit2 varchar(6),
	@count2 int, @countunit2 varchar(6),
	@oldcmdcode3 varchar(8), @newcmdcode3 varchar(8), @wgt3 decimal(11,2),@wgtunit3 varchar(6), @vol3 decimal(11,2), @volunit3 varchar(6),
	@count3 int, @countunit3 varchar(6),
	@driver1 varchar(8), @driver2 varchar(8), @tractor varchar(8), @trailer1 varchar(13), @trailer2 varchar(13), @carrier varchar(8),
	@copyordrefnums char(1), @copystoprefnums char(1), @copyfgtrefnums char(1),
	@copyDispatchStops char(1), @quantitySource varchar(10),@copyordernotes char(1),@NewOrderNumber varchar(12) OUTPUT

AS


DECLARE @ordhdrnumber int,
	@copyordhdrnumber int,
	@movnumber int,
	@copymovnumber int,
	@retcode smallint,
	@minstpseq int,
	@minevtsequence int,
	@Minfgtseq int,
	@newmovnumber int,
	@newlghnumber int,
	@newstpnumber int,
	@newfgtnumber int,
	@newevtnumber int,
	@newordhdrnumber int,
	@evteventcode varchar(6),
	@minfgtsequence int,
	@diffmins int,
	@diffyr int,
	@nextstatus varchar(6),
	@stpsequence int,
	@stpmfhsequence int,
	@stpordhdrnumber int,
	@cmpid varchar(8),
	@ordmiles  int,
	@stpconatact varchar(30),
	@weight float,
	@weightunit varchar(6),
	@volume float,
	@volunit varchar(6),
	@count int,
	@countunit varchar(6),
	@lastassignstatus varchar(6),
	@lastassignlgh int,
	@lastassignenddate datetime,
	@bmtcmpid varchar(8),
	@bmtcity int,
	@bmtstate varchar(6),
	@bmtcmpname varchar(60),
	@earlydate datetime,
	@latedate datetime,
	@arrivedate datetime,
	@departdate datetime,
	@cmdcode varchar(8),
	@newyear datetime,
	@stpmfhstatus varchar(6),
	@stpordmileage decimal(6,1),
	@stplghmileage decimal(6,1),
	@stploadstatus varchar(6),
	@stpweight float,
	@stpweightunit varchar(6),
	@stpcmdcode varchar(8),
	@stpdescription varchar(30),
	@copystpnumber int,
	@stpcmpid varchar(8),
	@stpregion1 varchar(6),
	@stpregion2 varchar(6),
	@stpregion3 varchar(6),
	@stpcity int,
	@stpstate varchar(6),
	@stpschdtearliest datetime,
	@stporigschdt datetime,
	@stparrivaldate datetime,
	@stpdeparturedate datetime,
	@stpreasonlate varchar(6),
	@stpschdtlatest datetime,
	@stptype varchar(6),
	@stppaylegpt char(1),
	@shphdrnumber int,
	@stpregion4 varchar(6),
	@stplghsequence int,
	@stpevent varchar(6),
	@stplghstatus varchar(6),
	@stpcount float,
	@stpcountunit varchar(6),
	@stpcmpname varchar(60),
	@stpcomment varchar(254),
	@stpreftype varchar(6),
	@stprefnum varchar(30),
	@stpscreenmode varchar(6),
	@stpvolume float,
	@stpvolunit varchar(6),
	@stpredeliver varchar(1),
	@stposd varchar(1),
	@stpphonenumber varchar(20),
	@stpdelayhours float,
	@stpooamileage float,
	@stpzipcode varchar(9),
	@stpooastop int,
	@stpaddress varchar(40),
	@stptransferstp int,
	@stpphonenumber2 varchar(20),
	@stpaddress2 varchar(40),
	@stpcontact varchar(30),
	@cmpsecondaryphoneext varchar(4),
	@stpcustpickupdate datetime,
	@stpcustdeliverydate datetime,
	@stppodname varchar(20),
	@stpcmpclose int,
	@stpactivitystartdt datetime,
	@stpactivityenddt datetime,
	@stpeta datetime,
	@stpetd datetime,
	@stptransfertype char(3),
	@evtstartdate datetime,
	@evtenddate datetime,
	@evtstatus varchar(6),
	@evtearlydate datetime,
	@evtlatedate datetime,
	@evtchassis varchar(13),
	@evtdolly varchar(13),
	@evtweight float,
	@mfhnumber int,
	@stpstatus varchar(6),
	@fgtweight float,
	@fgtvolume float,
	@fgtcount int,
	@ordtotalweight float,
	@ordtotalvolume float,
	@ordtotalcount int,
	@minrefsequence int,
	@copyfgtnumber int,
	@bmtdate datetime,
	@stopordhdrnumber int,
	@MinNotNumber int,
	@newnotnumber int
	


/* There must be an order to copy */
IF (SELECT COUNT(*) FROM orderheader WHERE ord_number = @ordnumber) = 0  
	BEGIN
	IF @validate = 'Y' 
		RETURN -2
	ELSE
		RETURN -1
	END

SELECT @quantitySource = UPPER(ISNULL(@quantitySource,''))
SELECT @copyordernotes = UPPER(ISNULL(@copyordernotes,'N'))

SELECT @copymovnumber = mov_number ,
	 @copyordhdrnumber = ord_hdrnumber
FROM orderheader
WHERE ord_number = @ordnumber

/* If the order number is assigned, it must be unique */
IF @assignorder IS NOT NULL and LEN(RTRIM(@assignorder)) > 0 
  BEGIN
	IF (SELECT COUNT(*) FROM orderheader where ord_number = @assignorder) > 0
	  BEGIN
		IF @validate = 'Y' 
			RETURN -3
		ELSE
			RETURN -1
	  END
  END

IF @startdate IS NULL  SELECT @startdate = GETDATE()
SELECT @minstpseq = 0
SELECT @newmovnumber = NULL

IF @tractor IS NULL OR LEN(RTRIM(@tractor)) = 0 SELECT @tractor = 'UNKNOWN'
IF @driver1 IS NULL OR LEN(RTRIM(@tractor)) = 0 SELECT @driver1 = 'UNKNOWN'
IF @driver2 IS NULL OR LEN(RTRIM(@tractor)) = 0 SELECT @driver2 = 'UNKNOWN'
IF @trailer1 IS NULL OR LEN(RTRIM(@tractor)) = 0 SELECT @trailer1 = 'UNKNOWN'
IF @trailer2 IS NULL OR LEN(RTRIM(@tractor)) = 0 SELECT @trailer2 = 'UNKNOWN'
IF @newcmdcode1 IS NULL OR LEN(RTRIM(@newcmdcode1)) = 0 SELECT @newcmdcode1 = 'UNKNOWN'
IF @newcmdcode2 IS NULL OR LEN(RTRIM(@newcmdcode2)) = 0 SELECT @newcmdcode2 = 'UNKNOWN'
IF @newcmdcode3 IS NULL OR LEN(RTRIM(@newcmdcode3)) = 0 SELECT @newcmdcode3 = 'UNKNOWN'
IF @wgtunit1 IS NULL or LEN(RTRIM(@wgtunit1)) = 0  SELECT @wgtunit1 = 'UNK'
IF @wgtunit2 IS NULL or LEN(RTRIM(@wgtunit2)) = 0 SELECT @wgtunit2 = 'UNK'
IF @wgtunit3 IS NULL or LEN(RTRIM(@wgtunit3)) = 0 SELECT @wgtunit3 = 'UNK'
IF @volunit1 IS NULL or LEN(RTRIM(@volunit1)) = 0 SELECT @volunit1 = 'UNK'
IF @volunit2 IS NULL or LEN(RTRIM(@volunit2)) = 0 SELECT @volunit2 = 'UNK'
IF @volunit3 IS NULL or LEN(RTRIM(@volunit3)) = 0 SELECT @volunit3 = 'UNK'
IF @countunit1 IS NULL or LEN(RTRIM(@countunit1)) = 0 SELECT @countunit1 = 'UNK'
IF @countunit2 IS NULL or LEN(RTRIM(@countunit1)) = 0 SELECT @countunit2 = 'UNK'
IF @countunit3 IS NULL or LEN(RTRIM(@countunit1)) = 0 SELECT @countunit3 = 'UNK'
 
IF @validate = 'Y' 
  BEGIN	
	IF (SELECT COUNT(*) FROM tractorprofile WHERE trc_number = @tractor AND trc_retiredate >= GETDATE()) = 0 
	  RETURN -4
			
	IF (SELECT COUNT(*) FROM trailerprofile WHERE trl_number = @trailer1 AND trl_retiredate >= GETDATE())= 0 
	  RETURN  -5
			
	IF (SELECT COUNT(*) FROM trailerprofile WHERE trl_number = @trailer2 AND trl_retiredate >= GETDATE())= 0 
	  RETURN  -6
			
	IF (SELECT COUNT(*) FROM manpowerprofile WHERE mpp_id = @driver1 AND mpp_terminationdt >= GETDATE())= 0 
	  RETURN  -7
		
	IF (SELECT COUNT(*) FROM manpowerprofile WHERE mpp_id = @driver2 AND mpp_terminationdt >= GETDATE())= 0 
	  RETURN  -8
		
	IF (SELECT COUNT(*) FROM commodity WHERE cmd_code  = @newcmdcode1 )= 0 
	  RETURN  -9
		
	IF (SELECT COUNT(*) FROM commodity WHERE cmd_code  = @newcmdcode2 )= 0 
	  RETURN  -10
		
	IF (SELECT COUNT(*) FROM commodity WHERE cmd_code  = @newcmdcode3 )= 0 
	  RETURN  -11
		
	IF @wgtunit1 <> 'UNK' AND (SELECT COUNT(*) FROM labelfile WHERE labeldefinition = 'WeightUnits' AND abbr = @wgtunit1) = 0
	  RETURN  -12
			
	IF  @wgtunit2 <> 'UNK' AND (SELECT COUNT(*) FROM labelfile WHERE labeldefinition = 'WeightUnits' AND abbr = @wgtunit2) = 0
	  RETURN  -13
			
	IF  @wgtunit3 <> 'UNK' AND (SELECT COUNT(*) FROM labelfile WHERE labeldefinition = 'WeightUnits' AND abbr = @wgtunit3) = 0
	  RETURN  -14
			
	IF @volunit1 <> 'UNK' AND (SELECT COUNT(*) FROM labelfile WHERE labeldefinition = 'VolumeUnits' AND abbr = @volunit1) = 0
	  RETURN  -15
			
	IF @volunit2 <> 'UNK' AND (SELECT COUNT(*) FROM labelfile WHERE labeldefinition = 'VolumeUnits' AND abbr = @volunit2) = 0
	  RETURN  -16
			
	IF @volunit2 <> 'UNK' AND (SELECT COUNT(*) FROM labelfile WHERE labeldefinition = 'VolumeUnits' AND abbr = @volunit3) = 0
	  RETURN  -17
			
 	IF @countunit1 <> 'UNK' AND (SELECT COUNT(*) FROM labelfile WHERE labeldefinition = 'CountUnits' AND abbr = @countunit1) = 0
	  RETURN  -18
			
	IF @countunit2 <> 'UNK' AND (SELECT COUNT(*) FROM labelfile WHERE labeldefinition = 'CountUnits' AND abbr = @countunit2) = 0
	 RETURN  -19
			
	IF @countunit3 <> 'UNK' AND (SELECT COUNT(*) FROM labelfile WHERE labeldefinition = 'CountUnits' AND abbr = @countunit3) = 0
	  RETURN  -20
			
  END

SELECT @copycharges =
	CASE UPPER(@copycharges)
		WHEN 'Y' THEN 'Y'
		ELSE 'N'
	END
SELECT @copyordrefnums = 
	CASE UPPER(@copyordrefnums)
		WHEN 'Y' THEN 'Y'
		ELSE 'N'
	END
SELECT @copystoprefnums = 
	CASE UPPER(@copystoprefnums)
		WHEN 'Y' THEN 'Y'
		ELSE 'N'
	END
SELECT @copyfgtrefnums = 
	CASE UPPER(@copyfgtrefnums)
		WHEN 'Y' THEN 'Y'
		ELSE 'N'
	END

SELECT @lastassignlgh = NULL
SELECT @nextstatus =    
	CASE @orderstatus
		WHEN 'CMP' THEN 'DNE'
		WHEN 'STD' THEN 'DNE'
		ELSE 'OPN'
	END

IF @tractor <> 'UNKNOWN' 
  BEGIN
	/* Locate the tractor on its prior trip*/
	SELECT @lastassignstatus = asgn_status, 
	@lastassignlgh = lgh_number,
	@lastassignenddate = asgn_enddate
	FROM assetassignment 
	WHERE asgn_type = 'TRC'
	AND asgn_id = @tractor
	AND asgn_status in ('DSP','STD','CMP')
	AND asgn_enddate =  (SELECT MAX(asgn_enddate)
							FROM assetassignment
							WHERE asgn_type = 'TRC'
							AND asgn_id = @tractor
							AND asgn_status in ('DSP','STD','CMP')
							AND asgn_enddate <= '20491231 23:59')
  END
/* found prior trip */
/* if the order status is to be started or complete but the prior trip is not complete, reset to dispatched */
IF @lastassignlgh IS NOT NULL AND @lastassignstatus <> 'CMP' AND @orderstatus IN ('STD','CMP')  SELECT @orderstatus = 'DSP'


SELECT @nextstatus = 
	CASE @orderstatus
		WHEN 'CMP' then 'DNE'
		WHEN 'STD' THEN 'DNE'
		ELSE 'OPN'
	END

/* Get control numbers to start */
EXEC @newmovnumber = dbo.getsystemnumber 'MOVNUM',NULL
EXEC @newlghnumber = dbo.getsystemnumber 'LEGHDR',NULL
EXEC @newordhdrnumber = dbo.getsystemnumber 'ORDHDR',NULL
IF @newmovnumber IS NULL OR @newlghnumber IS NULL OR @newordhdrnumber IS NULL RETURN -1

/* Create an ord number, if one has not been assigned, and check to make sure it is unique*/
IF @assignorder IS NULL or LEN(RTRIM(@assignorder)) = 0 
	SELECT @assignorder = CONVERT(Varchar(12),@newordhdrnumber)

IF (SELECT COUNT(*) FROM orderheader where ord_number = @assignorder) > 0
	BEGIN
		IF @validate = 'Y' 
			RETURN -21
		ELSE
			RETURN -1  
		
	END

/*********   HERE WE GO ***********/
BEGIN TRANSACTION
	
/************* If the copied trip is to begin with a BMT, set it up ******************/ 
IF @beginemptyfrompriortrip = 'Y' and @tractor <> 'UNKNOWN' AND @lastassignlgh IS NOT NULL
  BEGIN  /* add BMT records */
	SELECT @bmtcmpid = cmp_id
	FROM stops
	WHERE lgh_number = @lastassignlgh
	AND stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
									FROM stops
									WHERE lgh_number = @lastassignlgh ) 

	SELECT @stpmfhsequence = NULL
	SELECT @stpsequence = NULL

	IF @bmtcmpid IS NOT NULL
	  BEGIN  /* bmt company has been found */
		
		EXEC @newstpnumber = dbo.getsystemnumber 'STPNUM',NULL
		EXEC @newfgtnumber = dbo.getsystemnumber 'FGTNUM',NULL
		INSERT INTO freightdetail 
		( stp_number, fgt_sequence, fgt_number, 		--1	
		fgt_reftype, 	skip_trigger, fgt_quantity,fgt_unit,	--2
		fgt_rate,fgt_charge,cht_itemcode,cmd_code,fgt_weightunit,fgt_description,          				--3
		fgt_count,fgt_countunit,fgt_volume,fgt_volumeunit)				--4
		VALUES ( @newstpnumber, 1, @newfgtnumber, 	--1
		 'REF',	1, 0,	'UNK',										--2	
		0,0,'UNK'	, 'UNKNOWN','LBS','UNKNOWN',												--3
		0,'CAS',0,'GAL')			--4

 	 	IF @@error<>0
        BEGIN  
			EXEC tmw_log_error 0, 'copy_existing_order INSERT INTO freightdetail Failed', @@error, ''
			SELECT @retcode = -1 
			GOTO ERROR_RETURN 
		  END   

   
		SELECT @bmtdate = DATEADD(mi,-1,@startdate)  
		

		EXEC @newevtnumber = dbo.getsystemnumber 'EVTNUM',NULL
		INSERT INTO event 
		( evt_number,ord_hdrnumber,stp_number,evt_eventcode,					--1
		evt_startdate,evt_enddate,evt_status,evt_earlydate,	--2
		evt_latedate,evt_sequence,evt_driver1,evt_driver2,		--3
		evt_tractor,evt_trailer1,evt_trailer2,evt_chassis,evt_dolly,		--4
		evt_carrier,evt_mov_number, skip_trigger) 				--5
		VALUES 
		(@newevtnumber,@newordhdrnumber,@newstpnumber,'BMT',			--1
		@bmtdate,@bmtdate,@nextstatus,'19500101',	--2
		'20491231 23:59',1,@driver1,@driver2,						--3
		@tractor,@trailer1,@trailer2,'UNKNOWN','UNKNOWN',		--4
		@carrier,@newmovnumber,1)										--5

  		IF @@error<>0
    	  BEGIN
			EXEC  tmw_log_error 0, 'copy_existing_order INSERT INTO event Failed', @@error, ''
			SELECT @retcode = -1 
			GOTO ERROR_RETURN 
    	  END
	
		/* name field is shorter on stops as of today 5/16/01 */
		SELECT @bmtcity = cmp_city,@bmtstate = cmp_state,@bmtcmpname = SUBSTRING(cmp_name,1,30)
		FROM company
		WHERE cmp_id = @bmtcmpid

		IF @bmtcity IS NULL SELECT @bmtcity = 0
		IF @bmtstate IS NULL SELECT @bmtstate = 'XX'

		SELECT @stptype=fgt_event,
		@stpordhdrnumber = 
			CASE ect_billable
				WHEN 'Y' then @newordhdrnumber
				ELSE 0
			END,
		@stppaylegpt = drv_pay_event,
		@stpsequence = 
			CASE ect_billable
				WHEN 'Y' then 1
				ELSE 0
			END
		FROM eventcodetable
		WHERE abbr = 'BMT'
		

		IF @stptype IS NULL SELECT @stptype = 'NONE'
		IF @stpordhdrnumber IS NULL SELECT @stpordhdrnumber = 0
		IF @stppaylegpt IS NULL SELECT @stppaylegpt = 'Y'
		IF @stpsequence IS NULL SELECT stp_sequence = 0
		SELECT @stpmfhsequence = 1

		SELECT @stparrivaldate = DATEADD(mi,-1,@startdate)
		INSERT INTO stops
		(ord_hdrnumber,stp_number,cmp_id,stp_city,stp_state,		--1
		stp_schdtearliest,stp_origschdt,stp_arrivaldate,			--2
		stp_departuredate,stp_schdtlatest,lgh_number,stp_type,skip_trigger,	--3
		stp_paylegpt,stp_sequence,stp_mfh_sequence,stp_event,		--4
		mov_number,cmp_name,stp_status,stp_redeliver,stp_ooa_stop,mfh_number,  --5  stp_activitystart_dt,stp_activityend_dt)	
		trl_id,stp_ord_mileage,stp_weight,stp_weightunit,stp_count,stp_countunit,  --6
		stp_volume,stp_volumeunit,stp_delayhours,stp_ooa_mileage,stp_loadstatus,stp_lgh_sequence,stp_reasonlate,stp_reasonlate_depart)		--7
		VALUES 
		(@stpordhdrnumber,@newstpnumber,@bmtcmpid,@bmtcity,@bmtstate,			--1
		'19500101',@stparrivaldate ,@stparrivaldate ,				--2
		@stparrivaldate ,'20491231',@newlghnumber,@stptype,1,		--3
		@stppaylegpt,@stpsequence,@stpmfhsequence,'BMT',			--4
		@newmovnumber,@bmtcmpname,@nextstatus,0,0,0,						--5  '19500101','19500101')	
		@trailer1,0	,0,'UNK'	,0,'UNK'	,								--6
		0,'UNK',	0,0	,'MT',0,'UNK','UNK')								--7				

		IF @@error<>0
    	  BEGIN
			EXEC  tmw_log_error 0, 'copy_existing_order INSERT INTO stops Failed', @@error, ''
			SELECT @retcode = -1 
			GOTO ERROR_RETURN 
    	  END

		IF @nextstatus = 'DNE' and @orderstatus = 'STD' SELECT @nextstatus = 'OPN'

  END  /* bmt company has been found */
END  /* add BMT records */

/************* loop thru all stops then all freight on that  stop from the master order to create new records*************/
SELECT @ordtotalweight = 0
SELECT @ordtotalvolume = 0
SELECT @ordtotalcount = 0

SELECT @diffmins = -1  /* keeps it from being computed on any but the first stop */
WHILE (0 = 0)
  BEGIN
	IF @copyDispatchStops = 'Y'
	  BEGIN /* LOOP THRU STOPS */
		SELECT @minstpseq = MIN(stp_mfh_sequence)
		FROM stops
		WHERE stops.mov_number = @copymovnumber
		AND stops.ord_hdrnumber in (@copyordhdrnumber,0)  
		AND stops.stp_mfh_sequence > @minstpseq 
	
		IF @minstpseq IS NULL BREAK   /* end of stops loop */

		SELECT @copystpnumber = stp_number,
			@diffmins = 
				CASE @diffmins
					WHEN -1 THEN DATEDIFF(mi,stp_arrivaldate,@startdate)
					ELSE @diffmins
				END
		FROM stops 
		WHERE  stops.mov_number = @copymovnumber
		AND ord_hdrnumber in (@copyordhdrnumber,0)  
		AND stp_mfh_sequence = @minstpseq

	  END
	ELSE
	  BEGIN  /* LOOP THRU ORDER STOPS */
		SELECT @minstpseq = MIN(stp_sequence)
		FROM stops
		WHERE stops.ord_hdrnumber= @copyordhdrnumber
		AND stops.stp_sequence > @minstpseq

		IF @minstpseq IS NULL BREAK  /* end of stops loop */

		SELECT @copystpnumber = stp_number,
			@diffmins = 
				CASE @diffmins
					WHEN -1 THEN DATEDIFF(mi,stp_arrivaldate,@startdate)
					ELSE @diffmins
				END
			FROM stops 
			WHERE  stops.ord_hdrnumber= @copyordhdrnumber
			AND stp_sequence = @minstpseq

	  END
	
	/* Pick up information from next stop to be copied (needed for creating events and freight where cmd_code substitution may take place. */
 
	SELECT
		@stopordhdrnumber = ord_hdrnumber,
		@stpcmpid = cmp_id,
		@stpstatus = stp_status,
		@stpregion1 = stp_region1,
		@stpregion2 = stp_region2,
		@stpregion3 = stp_region3,
		@stpcity = stp_city,
		@stpstate = stp_state,
		@stpschdtearliest = 
		CASE stp_schdtearliest
			WHEN '19500101' THEN '19500101'
			WHEN '20491231 23:59' THEN '20491231 23:59'
			ELSE DATEADD(mi,@diffmins,stp_schdtearliest)
		END,
		@stporigschdt =  
		CASE stp_origschdt
			WHEN '19500101' THEN '19500101'
			WHEN '20491231 23:59' THEN '20491231 23:59'
			ELSE DATEADD(mi,@diffmins,stp_origschdt)
		END,
		@stparrivaldate =  
		CASE stp_arrivaldate
			WHEN '19500101' THEN '19500101'
			WHEN '20491231 23:59' THEN '20491231 23:59'
			ELSE DATEADD(mi,@diffmins,stp_arrivaldate)
		END,
		@stpdeparturedate =  
		CASE stp_departuredate
			WHEN '19500101' THEN '19500101'
			WHEN '20491231 23:59' THEN '20491231 23:59'
			ELSE DATEADD(mi,@diffmins,stp_departuredate)
		END,
		@stpreasonlate = 'UNK',
		@stpschdtlatest = 
		CASE stp_schdtlatest
			WHEN '19500101' THEN '19500101'
			WHEN '20491231 23:59' THEN '20491231 23:59'
			ELSE DATEADD(mi,@diffmins,stp_schdtlatest)
		END,
		@mfhnumber = mfh_number,
		@stpmfhsequence = 
		CASE @beginemptyfrompriortrip  
			WHEN  'Y'  THEN (stp_mfh_sequence + 1)
			ELSE stp_mfh_sequence
		END,
		@stptype = fgt_event,
		@stppaylegpt = stp_paylegpt,
		@stpsequence = 
		CASE 
			WHEN  @beginemptyfrompriortrip  = 'Y' and @stpordhdrnumber > 0  THEN (stp_sequence + 1)
			ELSE stp_sequence
		END,
		@shphdrnumber = shp_hdrnumber,
		@stpregion4 = stp_region4,
		@stplghsequence = stp_lgh_sequence,
		@stpevent = stp_event,
		@stpmfhstatus = stp_mfh_status,
		@stplghstatus = stp_lgh_status,
		@stpordmileage = stp_ord_mileage,
		@stplghmileage = stp_lgh_mileage,
		@stploadstatus = stp_loadstatus,
		@stpweight = 
		CASE cmd_code
			WHEN @oldcmdcode1 THEN @wgt1
			WHEN @oldcmdcode2 THEN @wgt2
			WHEN @oldcmdcode3 THEN @wgt3
			ELSE stp_weight
		END,
		@stpweightunit = 
		CASE cmd_code
			WHEN @oldcmdcode1 THEN @wgtunit1
			WHEN @oldcmdcode2 THEN @wgtunit2
			WHEN @oldcmdcode3 THEN @wgtunit3
			ELSE stp_weightunit
		END,
		@stpcmdcode = 
		CASE cmd_code
			WHEN @oldcmdcode1 THEN @newcmdcode1
			WHEN @oldcmdcode2 THEN @newcmdcode2
			WHEN @oldcmdcode3 THEN @newcmdcode3
			ELSE cmd_code
		END,
		@stpdescription = 
		CASE cmd_code
			WHEN @oldcmdcode1 THEN (SELECT cmd_name FROM commodity WHERE cmd_code = @newcmdcode1)
			WHEN @oldcmdcode2 THEN (SELECT cmd_name FROM commodity WHERE cmd_code = @newcmdcode2)
			WHEN @oldcmdcode3 THEN (SELECT cmd_name FROM commodity WHERE cmd_code = @newcmdcode3)
			ELSE stp_description
		END,
		@stpcount = 
		CASE cmd_code
			WHEN @oldcmdcode1 THEN @count1
			WHEN @oldcmdcode2 THEN @count2
			WHEN @oldcmdcode3 THEN @count3
			ELSE stp_count
		END,
		@stpcountunit = 
		CASE cmd_code
			WHEN @oldcmdcode1 THEN @countunit1
			WHEN @oldcmdcode2 THEN @countunit2
			WHEN @oldcmdcode3 THEN @countunit3
			ELSE stp_countunit
		END,
		@stpcmpname = cmp_name,
		@stpcomment = stp_comment,
		@stpreftype = stp_reftype,
		@stprefnum = stp_refnum,
		@stpscreenmode = stp_screenmode,
		@stpvolume = 
		CASE cmd_code
			WHEN @oldcmdcode1 THEN @vol1
			WHEN @oldcmdcode2 THEN @vol2
			WHEN @oldcmdcode3 THEN @vol3
			ELSE stp_volume
		END,
		@stpvolunit = 
		CASE cmd_code
			WHEN @oldcmdcode1 THEN @volunit1
			WHEN @oldcmdcode2 THEN @volunit2
			WHEN @oldcmdcode3 THEN @volunit3
			ELSE stp_volumeunit
		END,
		@stpredeliver = stp_redeliver,
		@stposd = stp_osd,
		@stpphonenumber = stp_phonenumber,
		@stpdelayhours = stp_delayhours,
		@stpooamileage = stp_ooa_mileage,
		@stpzipcode  = stp_zipcode,
		@stpooastop = stp_ooa_stop,
		@stpaddress = stp_address,
		@stptransferstp = stp_transfer_stp,
		@stpphonenumber2 = stp_phonenumber2,
		@stpaddress2 = stp_address2,
		@stpcontact = stp_contact ,
		@stpcustpickupdate = stp_custpickupdate,
		@stpcustdeliverydate = stp_custdeliverydate,
		@stppodname = stp_podname /*,
	@cmpsecondaryphoneext = cmp_secondaryphoneext,
	@stpcmpclose = stp_cmp_close  ,
	@stpactivitystartdt = 
		CASE stp_activitystart_dt
			WHEN '19500101' THEN '19500101'
			WHEN '20491231 23:59' THEN '20491231 23:59'
			ELSE DATEADD(mi,@diffmins,stp_activitystart_dt)
		END,
	@stpactivityenddt = 
		CASE stp_activityend_dt
			WHEN '19500101' THEN '19500101'
			WHEN '20491231 23:59' THEN '20491231 23:59'
			ELSE DATEADD(mi,@diffmins,stp_activityend_dt)
		END,
	@stpeta = 
		CASE stp_eta
			WHEN '19500101' THEN '19500101'
			WHEN '20491231 23:59' THEN '20491231 23:59'
			WHEN NULL THEN NULL
			ELSE DATEADD(mi,@diffmins,stp_eta)
		END,
	@stpetd = 
		CASE stp_etd
			WHEN '19500101' THEN '19500101'
			WHEN '20491231 23:59' THEN '20491231 23:59'
			WHEN NULL THEN NULL
			ELSE DATEADD(mi,@diffmins,stp_etd)
		END,
	@stptransfertype = stp_transfer_type  */
	FROM stops,eventcodetable
	WHERE stp_number = @copystpnumber
	AND eventcodetable.abbr = stp_event

	EXEC @newstpnumber = dbo.getsystemnumber 'STPNUM',NULL
	IF @newstpnumber IS NULL 
	  BEGIN
		SELECT @retcode =  -1
		GOTO ERROR_RETURN
	  END
 
	/************* loop thru all event records for the stop and create copies ***************/
		SELECT @minevtsequence = 0
		WHILE 0 = 0
	  	  BEGIN  /* loop thru all events for a stop */
			SELECT @minevtsequence = MIN(evt_sequence) 
			FROM event
			WHERE stp_number  = @copystpnumber
			AND evt_sequence >@minevtsequence

			IF @minevtsequence IS NULL BREAK  /* end of event loop */

			EXEC @newevtnumber = dbo.getsystemnumber 'EVTNUM',NULL
			IF @newevtnumber IS NULL 
	 	 	  BEGIN
				SELECT @retcode =  -1
				GOTO ERROR_RETURN
	  	 	END

			INSERT INTO event
			(ord_hdrnumber,stp_number,evt_eventcode,evt_number,												--1
			evt_startdate,evt_enddate,																					--2
			evt_status,evt_earlydate,evt_latedate,evt_weight,evt_weightunit,fgt_number,				--3
			evt_count,evt_countunit,evt_volume,evt_volumeunit,evt_pu_dr,evt_sequence,					--4
			evt_contact,evt_driver1,evt_driver2,evt_tractor,evt_trailer1,evt_trailer2,					--5
			evt_chassis,evt_dolly,evt_refype,evt_refnum,evt_carrier,skip_trigger,evt_mov_number)	--6	
			SELECT ord_hdrnumber = 
			CASE ord_hdrnumber
				WHEN 0 THEN 0
				ELSE @newordhdrnumber
			END,
			@newstpnumber, evt_eventcode,@newevtnumber,							--1	
			evt_startdate = 
		 	CASE evt_startdate
			WHEN '19500101' THEN evt_startdate
			WHEN '20491231 23:59' THEN evt_startdate
			ELSE DATEADD(mi,@diffmins,evt_startdate)
		 	END,
			evt_enddate = 
			CASE evt_enddate
			WHEN '19500101' THEN evt_enddate
			WHEN '20491231 23:59' THEN evt_enddate
			ELSE DATEADD(mi,@diffmins,evt_enddate)
			END,																												--2
			evt_status = 	@nextstatus,
			evt_earlydate = 
			CASE evt_earlydate
			WHEN '19500101' THEN evt_earlydate
			WHEN '20491231 23:59' THEN evt_earlydate
			ELSE DATEADD(mi,@diffmins,evt_earlydate)
			END,																	
			evt_latedate = 
			CASE evt_latedate
			WHEN '19500101' THEN evt_latedate
			WHEN '20491231 23:59' THEN evt_latedate
			ELSE DATEADD(mi,@diffmins,evt_latedate)
			END, 
			@stpweight,@stpweightunit,@newfgtnumber,																--3
			@stpcount,@stpcountunit,@stpvolume,@stpvolunit,evt_pu_dr,evt_sequence,					--4
			evt_contact,@driver1,@driver2,@tractor,@trailer1,@trailer2,										--5
			evt_chassis,evt_dolly,evt_refype,evt_refnum ,@carrier,1,@newmovnumber							--6		
			FROM event
			WHERE stp_number = @copystpnumber
			AND evt_sequence = @minevtsequence

	
			IF @@error<>0
       	 BEGIN  
				EXEC tmw_log_error 0, 'copy_existing_order COPY INTO event Failed  ', @@error, ''
				SELECT @retcode = -1
				GOTO ERROR_RETURN
		  	END

		END  /* end loop thru all events for a stop */	
	
	/*********** loop thru all freighdetail records for a stop  and create copies *************8*/
	SELECT @minfgtsequence = 0	
	WHILE 0 = 0
	  BEGIN  /* loop thru all freightdetail for a stop */
		SELECT @minfgtsequence = MIN(fgt_sequence) 
		FROM freightdetail
		WHERE stp_number  = @copystpnumber
		AND fgt_sequence > @minfgtsequence

		IF @minfgtsequence IS NULL BREAK  /* end of freightdetail loop */

		EXEC @newfgtnumber = dbo.getsystemnumber 'FGTNUM',NULL
		IF @newfgtnumber IS NULL 
	 	 BEGIN
			SELECT @retcode =  -1
			GOTO ERROR_RETURN
	  	 END

		/* need old fgt number for copying ref numbers  */
		SELECT @copyfgtnumber = fgt_number
		FROM freightdetail
		WHERE stp_number = @copystpnumber
		AND fgt_sequence = @minfgtsequence

		INSERT INTO freightdetail
		(fgt_number,cmd_code,fgt_weight,fgt_weightunit,fgt_description,stp_number,					--1
		fgt_count,fgt_countunit,fgt_volume,fgt_volumeunit,fgt_sequence,fgt_length,fgt_lengthunit,   --2
		fgt_height,fgt_heightunit,fgt_width,fgt_widthunit,fgt_reftype,fgt_refnum,					--3
		fgt_quantity,fgt_rate,fgt_charge,fgt_rateunit,cht_itemcode,cht_basisunit,					--4
		fgt_unit,skip_trigger,tare_weight,tare_weightunit,fgt_stackable,fgt_ratingquantity,		--5
		fgt_ratingunit,fgt_quantity_type)  --,fgt_ordered_count,fgt_ordered_weight)
		SELECT
		@newfgtnumber,
		cmd_code =
			CASE cmd_code
				WHEN @oldcmdcode1 THEN @newcmdcode1
				WHEN @oldcmdcode2 THEN @newcmdcode2
				WHEN @oldcmdcode3 THEN @newcmdcode3
				ELSE cmd_code
			END,
		fgt_weight = 
			CASE cmd_code
			WHEN @oldcmdcode1 THEN @wgt1
			WHEN @oldcmdcode2 THEN @wgt2
			WHEN @oldcmdcode3 THEN @wgt3
			ELSE fgt_weight
		END,
		fgt_weightunit = 
			CASE cmd_code
				WHEN @oldcmdcode1 THEN @wgtunit1
				WHEN @oldcmdcode2 THEN @wgtunit2
				WHEN @oldcmdcode3 THEN @wgtunit3
				ELSE fgt_weightunit
			END,
		fgt_description = 
			CASE cmd_code
				WHEN @oldcmdcode1 THEN (SELECT cmd_name FROM commodity WHERE cmd_code = @newcmdcode1)
				WHEN @oldcmdcode2 THEN (SELECT cmd_name FROM commodity WHERE cmd_code = @newcmdcode2)
				WHEN @oldcmdcode3 THEN (SELECT cmd_name FROM commodity WHERE cmd_code = @newcmdcode3)
				ELSE fgt_description
			END,
		@newstpnumber,												--1			
		fgt_count = 
			CASE cmd_code
				WHEN @oldcmdcode1 THEN @count1
				WHEN @oldcmdcode2 THEN @count2
				WHEN @oldcmdcode3 THEN @count3
				ELSE fgt_count
			END,
		fgt_countunit = 
			CASE cmd_code
				WHEN @oldcmdcode1 THEN @countunit1
				WHEN @oldcmdcode2 THEN @countunit2
				WHEN @oldcmdcode3 THEN @countunit3
				ELSE fgt_countunit
			END,	
		fgt_volume = 
			CASE cmd_code
				WHEN @oldcmdcode1 THEN @vol1
				WHEN @oldcmdcode2 THEN @vol2
				WHEN @oldcmdcode3 THEN @vol3
				ELSE fgt_volume
			END,
		fgt_volumeunit = 
			CASE cmd_code
				WHEN @oldcmdcode1 THEN @volunit1
				WHEN @oldcmdcode2 THEN @volunit2
				WHEN @oldcmdcode3 THEN @volunit3
				ELSE fgt_volumeunit
			END,	
		fgt_sequence,fgt_length,fgt_lengthunit,				--2
		fgt_height,fgt_heightunit,fgt_width,fgt_widthunit,
		fgt_reftype = 'REF',
		fgt_refnum ='',															--3
		fgt_quantity = 
			CASE @quantitySource
				WHEN 'WGT' THEN CASE cmd_code
										WHEN @oldcmdcode1 THEN @wgt1
										WHEN @oldcmdcode2 THEN @wgt2
										WHEN @oldcmdcode3 THEN @wgt3
										ELSE fgt_weight
									END
				WHEN 'VOL' THEN CASE cmd_code
										WHEN @oldcmdcode1 THEN @vol1
										WHEN @oldcmdcode2 THEN @vol2
										WHEN @oldcmdcode3 THEN @vol3
										ELSE fgt_volume
									END
				WHEN 'CNT' THEN CASE cmd_code
										WHEN @oldcmdcode1 THEN @count1
										WHEN @oldcmdcode2 THEN @count2
										WHEN @oldcmdcode3 THEN @count3
										ELSE fgt_count
									END
				ELSE 0
			END,0,0,fgt_rateunit,cht_itemcode,cht_basisunit,		--4
		fgt_unit = CASE @quantitySource
				WHEN 'WGT' THEN CASE cmd_code
									WHEN @oldcmdcode1 THEN @wgtunit1
									WHEN @oldcmdcode2 THEN @wgtunit2
									WHEN @oldcmdcode3 THEN @wgtunit3
									ELSE fgt_weightunit
									END
				WHEN 'VOL' THEN CASE cmd_code
									WHEN @oldcmdcode1 THEN @volunit1
									WHEN @oldcmdcode2 THEN @volunit2
									WHEN @oldcmdcode3 THEN @volunit3
									ELSE fgt_volumeunit
									END
				WHEN 'CNT' THEN CASE cmd_code
								WHEN @oldcmdcode1 THEN @countunit1
								WHEN @oldcmdcode2 THEN @countunit2
								WHEN @oldcmdcode3 THEN @countunit3
								ELSE fgt_countunit
								END
				ELSE 'UNK'
			END,1,0,tare_weightunit,fgt_stackable,0,		--5
		fgt_ratingunit,fgt_quantity_type  /*,
		fgt_ordered_count = 
			CASE cmd_code
				WHEN @oldcmdcode1 THEN @count1
				WHEN @oldcmdcode2 THEN @count2
				WHEN @oldcmdcode3 THEN @count3
				ELSE fgt_ordered_count
			END,
		fgt_ordered_weight =
			CASE cmd_code
				WHEN @oldcmdcode1 THEN @wgt1
				WHEN @oldcmdcode2 THEN @wgt2
				WHEN @oldcmdcode3 THEN @wgt3
			ELSE fgt_ordered_weight
		END	*/														--6
		FROM freightdetail 
		WHERE stp_number = @copystpnumber
		AND fgt_sequence = @minfgtsequence

		IF @@error<>0
        BEGIN  
			EXEC tmw_log_error 0, 'copy_existing_order COPY INTO freightdetail Failed ', @@error, ''
			SELECT @retcode = -1
			GOTO ERROR_RETURN
		  END
   	/* accumulate total weight,volume, count */
		IF @stptype = 'DRP'
		  BEGIN
			SELECT @fgtweight = ISNULL(fgt_weight,0),
				@fgtvolume = ISNULL(fgt_volume,0),
				@fgtcount = ISNULL(fgt_count,0)
			FROM freightdetail 
			WHERE fgt_number = @newfgtnumber

			IF @fgtweight IS NOT NULL SELECT @ordtotalweight =(@ordtotalweight + @fgtweight)
			IF @fgtvolume IS NOT NULL SELECT @ordtotalvolume =(@ordtotalvolume + @fgtvolume)
			IF @fgtcount IS NOT NULL SELECT @ordtotalcount =(@ordtotalcount + @fgtcount)
		  END
		
	IF @copyfgtrefnums = 'Y'
 	 BEGIN
		SELECT @minrefsequence = 0
		WHILE 1 = 1
	  	  BEGIN
			SELECT @minrefsequence = MIN(ref_sequence) 
			FROM referencenumber
			WHERE ref_table = 'freightdetail'
			AND ref_tablekey = @copyfgtnumber
			AND ref_sequence > @minrefsequence

			IF @minrefsequence IS NULL BREAK

			SET ROWCOUNT 1
			INSERT INTO referencenumber
			(ref_tablekey,ref_type,ref_number,ref_typedesc,ref_sequence,ord_hdrnumber, ref_table,ref_sid,ref_pickup)
			SELECT @newfgtnumber,ref_type,ref_number,ref_typedesc,ref_sequence,@newordhdrnumber, ref_table,ref_sid,ref_pickup
			FROM referencenumber
			WHERE ref_table = 'freightdetail'
			AND ref_tablekey = @copyfgtnumber
			AND ref_sequence = @minrefsequence

			SET ROWCOUNT 0
	  	  END
  END

	END
		SELECT @stopordhdrnumber = 
			CASE  
				WHEN @stopordhdrnumber > 0 THEN @newordhdrnumber
				ELSE 0
			END

	  INSERT INTO stops
		(ord_hdrnumber,stp_number,cmp_id,stp_region1,stp_region2,stp_region3,			--1
		stp_city,stp_schdtearliest,stp_origschdt,stp_arrivaldate,stp_departuredate,	--2
		stp_reasonlate,stp_schdtlatest,lgh_number,mfh_number,stp_type,stp_paylegpt,	--3
		stp_sequence,stp_region4,stp_lgh_sequence,trl_id,stp_mfh_sequence,stp_event,  --4
		stp_mfh_status,stp_lgh_status,stp_ord_mileage,stp_lgh_mileage,mov_number,		--5
		stp_loadstatus,stp_weight,stp_weightunit,cmd_code,stp_description,stp_count,stp_countunit,  --6
		cmp_name,stp_comment,stp_status,stp_reftype,stp_refnum,stp_reasonlate_depart,stp_screenmode, --7
		skip_trigger,stp_volume,stp_volumeunit,stp_redeliver,stp_osd,stp_phonenumber,stp_delayhours, --8
		stp_ooa_mileage,stp_zipcode,stp_ooa_stop,stp_address,stp_transfer_stp,stp_phonenumber2,  --9
		stp_address2,stp_contact,stp_custpickupdate,stp_custdeliverydate,  --10  cmp_secondaryphoneext,
		stp_podname)			--11 ,stp_cmp_close,stp_activitystart_dt,stp_activityend_dt,stp_departure_status
			--12  ,stp_transfer_type,stp_eta,stp_etd,																--12
		VALUES
		(@stopordhdrnumber,@newstpnumber,@stpcmpid,@stpregion1,@stpregion2,@stpregion3,	--1
		@stpcity,@stpschdtearliest,@stporigschdt,@stparrivaldate,@stpdeparturedate,		--2
		'UNK',@stpschdtlatest,@newlghnumber,@mfhnumber,@stptype,@stppaylegpt,				--3
		@stpsequence,@stpregion4,@stplghsequence,@trailer1,@stpmfhsequence,@stpevent,  --4
		@stpmfhstatus,@stplghstatus,@stpordmileage,@stplghmileage,@newmovnumber,		--5
		@stploadstatus,@stpweight,@stpweightunit,@stpcmdcode,@stpdescription,@stpcount,@stpcountunit,  --6
		@stpcmpname,@stpcomment,@nextstatus,@stpreftype,@stprefnum,'UNK',@stpscreenmode, --7
		1,@stpvolume,@stpvolunit,@stpredeliver,@stposd,@stpphonenumber,@stpdelayhours, --8
		@stpooamileage,@stpzipcode,@stpooastop,@stpaddress,@stptransferstp,@stpphonenumber2,  --9
		@stpaddress2,@stpcontact,@stpcustpickupdate,@stpcustdeliverydate,  --10  ,@cmpsecondaryphoneext
		@stppodname)			--11 ,@stpcmpclose,@stpactivitystartdt,@stpactivityenddt,@nextstatus
		  --12  @stptransfertype,@stpeta,@stpetd,

	IF @@error<>0
        BEGIN  
			EXEC tmw_log_error 0, 'copy_existing_order COPY INTO stop Failed ', @@error, ''
			SELECT @retcode = -1
			GOTO ERROR_RETURN
		  END

	IF @nextstatus = 'DNE' and @orderstatus = 'STD' SELECT @nextstatus = 'OPN'

	

IF @copystoprefnums = 'Y'
  BEGIN
	SELECT @minrefsequence = 0
	WHILE 1 = 1
	  BEGIN
		SELECT @minrefsequence = MIN(ref_sequence) 
		FROM referencenumber
		WHERE ref_table = 'stops'
		AND ref_tablekey = @copystpnumber
		AND ref_sequence > @minrefsequence
		
		IF @minrefsequence IS NULL BREAK

		SET ROWCOUNT 1
		INSERT INTO referencenumber
		(ref_tablekey,ref_type,ref_number,ref_typedesc,ref_sequence,ord_hdrnumber, ref_table,ref_sid,ref_pickup)
		SELECT @newstpnumber,ref_type,ref_number,ref_typedesc,ref_sequence,@newordhdrnumber, ref_table,ref_sid,ref_pickup
		FROM referencenumber
		WHERE ref_table = 'stops'
		AND ref_tablekey = @copystpnumber
		AND ref_sequence = @minrefsequence

		SET ROWCOUNT 0
	  END
  END
END
/********************** Finally copy the order ****************************/



	INSERT INTO orderheader
	(ord_company,ord_number,ord_bookdate,ord_bookedby,ord_status,ord_originpoint,ord_destpoint,		--1
	ord_invoicestatus,ord_origincity,ord_destcity,ord_originstate,ord_deststate,ord_originregion1,ord_destregion1,  --2
	ord_billto,ord_startdate,ord_completiondate,ord_revtype1,ord_revtype2,ord_revtype3,ord_revtype4,		--3
	ord_totalweight,ord_totalpieces,ord_totalmiles,ord_totalcharge,ord_currency,ord_currencydate,		--4
	ord_totalvolume,ord_hdrnumber,ord_refnum,ord_remark,ord_shipper,ord_consignee,ord_pu_at,ord_dr_at,  --5
	ord_originregion2,ord_originregion3,ord_originregion4,ord_destregion2,ord_destregion3,ord_destregion4, --6
	mfh_hdrnumber,ord_priority,mov_number ,ord_contact,tar_tarriffnumber,tar_number,tar_tariffitem,ord_showshipper,ord_showcons,   --7
	ord_subcompany,ord_quantity,ord_rate,ord_charge,ord_rateunit,ord_unit,ord_driver1,ord_driver2,ord_tractor,    --8
	ord_trailer,ord_length,ord_width,ord_height,ord_lengthunit,ord_widthunit,ord_heightunit,ord_reftype,			--9
	cmd_code,ord_description,ord_terms,cht_itemcode,ord_origin_earliestdate,ord_origin_latestdate,ord_odmetermiles,   --10
	ord_stopcount,ord_dest_earliestdate,ord_dest_latestdate,ref_sid,ref_pickup,ord_cmdvalue,ord_accessorial_chrg,  --11
	ord_availabledate,ord_miscqty,ord_tempunits,ord_datetaken,ord_totalweightunits,ord_totalvolumeunits,   --12
	ord_totalcountunits,ord_rateby,ord_quantity_type,ord_thirdpartytype1,ord_thirdpartytype2,ord_charge_type,  --13
	ord_fromorder,ord_mintemp,ord_maxtemp,ord_distributor,opt_trc_type4,opt_trl_type4,ord_cod_amount,  --14 opt_suggested_trc,opt_suggested_trl,
	appt_init,appt_contact,ord_ratingquantity,ord_ratingunit,  --15 ord_booked_revtype1,ord_hideshipperaddr,ord_hideconsignaddr,
	trl_type1,ord_customer,ord_supplier) --16  ,ord_trl_type2,ord_trl_type3,ord_trl_type4,ord_tareweight,ord_grossweight)
	SELECT
	ord_company,@assignorder,GETDATE(),'AUTOCOPY',@orderstatus,ord_originpoint,ord_destpoint,			--1
	'PND',ord_origincity,ord_destcity,ord_originstate,ord_deststate,ord_originregion1,ord_destregion1,  --2
	ord_billto,
	ord_startdate = DATEADD(mi,@diffmins,ord_startdate),ord_completiondate = DATEADD(mi,@diffmins,ord_completiondate),ord_revtype1,ord_revtype2,ord_revtype3,ord_revtype4,		--3
	@ordtotalweight, @ordtotalcount,ord_totalmiles,
	ord_totalcharge = 
		CASE @copycharges
			WHEN 'Y' THEN ord_totalcharge
			ELSE 0
		END,ord_currency,ord_currencydate,		--4
	@ordtotalvolume,@newordhdrnumber,
	ord_refnum = 
		CASE @copyordrefnums
			WHEN 'Y' THEN ord_refnum
			ELSE ''
		END,
	@ordremark,ord_shipper,ord_consignee,ord_pu_at,ord_dr_at,  --5
	ord_originregion2,ord_originregion3,ord_originregion4,ord_destregion2,ord_destregion3,ord_destregion4, --6
	mfh_hdrnumber,ord_priority,@newmovnumber ,ord_contact,
	tar_tarriffnumber = 
		CASE @copycharges
			WHEN 'Y' then tar_tarriffnumber
			ELSE 'UNKNOWN'
		END,
	tar_number  = 
		CASE @copycharges
			WHEN 'Y' then tar_number
			ELSE NULL
		END,
	tar_tariffitem = 
		CASE @copycharges
			WHEN 'Y' then tar_tariffitem
			ELSE 'UNKNOWN'
		END,
	ord_showshipper,ord_showcons,   --7
	ord_subcompany,
	ord_quantity = 
		CASE @copycharges
			WHEN 'Y' THEN ord_quantity
			ELSE CASE @quantitySource
					WHEN 'WGT' THEN @ordtotalweight
					WHEN 'VOL' THEN @ordtotalvolume
					WHEN 'CNT' THEN @ordtotalCOUNT
					WHEN 'DIS' THEN ord_totalmiles
					ELSE 0
				END
		END,
	ord_rate= 
		CASE @copycharges
			WHEN 'Y' THEN ord_rate
			ELSE 0
		END,
	ord_charge = 
		CASE @copycharges
			WHEN 'Y' THEN ord_charge
			ELSE 0
		END,
	ord_rateunit,
	ord_unit = 
		CASE @copycharges
			WHEN 'Y' THEN ord_rateunit
			ELSE CASE @quantitySource
					WHEN 'WGT' THEN ord_totalweightunits
					WHEN 'VOL' THEN ord_totalvolumeunits
					WHEN 'CNT' THEN ord_totalcountunits
					WHEN 'DIS'  THEN 'MIL'
					ELSE 'UNK'
				END
		END,
@driver1,@driver2,@tractor,    --8
	@trailer1,ord_length,ord_width,ord_height,ord_lengthunit,ord_widthunit,ord_heightunit,ord_reftype,			--9
	cmd_code = 
		CASE cmd_code
			WHEN @oldcmdcode1 THEN @newcmdcode1
			WHEN @oldcmdcode2 THEN @newcmdcode2
			WHEN @oldcmdcode3 THEN @newcmdcode3
			ELSE cmd_code
		END,
	ord_description = 
		CASE cmd_code
			WHEN @oldcmdcode1 THEN (SELECT cmd_name FROM commodity WHERE cmd_code = @newcmdcode1)
			WHEN @oldcmdcode2 THEN (SELECT cmd_name FROM commodity WHERE cmd_code = @newcmdcode2)
			WHEN @oldcmdcode3 THEN (SELECT cmd_name FROM commodity WHERE cmd_code = @newcmdcode3)
			ELSE ord_description
		END,
	ord_terms,
	cht_itemcode ,
		ord_origin_earliestdate = 
			CASE ord_origin_earliestdate
				WHEN '19500101' THEN '19500101'
				WHEN '20491231 23:59' THEN '20491231 23:59'
				ELSE DATEADD(mi,@diffmins,ord_origin_earliestdate)
			END,
	ord_origin_latestdate =
		CASE ord_origin_latestdate
				WHEN '19500101' THEN '19500101'
				WHEN '20491231 23:59' THEN '20491231 23:59'
				ELSE DATEADD(mi,@diffmins,ord_origin_latestdate)
			END,
	ord_odmetermiles,   --10
	ord_stopcount = 
		CASE
			WHEN @beginemptyfrompriortrip = 'Y' THEN (ord_stopcount + 1)
			ELSE ord_stopcount
		END,ord_dest_earliestdate= DATEADD(mi,@diffmins,ord_dest_earliestdate),ord_dest_latestdate = DATEADD(mi,@diffmins,ord_dest_latestdate),ref_sid,ref_pickup,ord_cmdvalue,
	ord_accessorial_chrg = 
		CASE @copycharges
			WHEN 'Y' THEN ord_accessorial_chrg
			ELSE 0
		END,			  --11
	ord_availabledate = 
		CASE ord_availabledate
				WHEN '19500101' THEN '19500101'
				WHEN '20491231 23:59' THEN '20491231 23:59'
				ELSE DATEADD(mi,@diffmins,ord_availabledate)
			END,
	ord_miscqty,ord_tempunits,ord_datetaken = GETDATE(),
	ord_totalweightunits,ord_totalvolumeunits,   --12
	ord_totalcountunits,ord_rateby,
	ord_quantity_type = 
		CASE @copycharges
			WHEN 'Y' THEN ord_quantity_type
			ELSE 0
		END,ord_thirdpartytype1,ord_thirdpartytype2,
	ord_charge_type= 
		CASE @copycharges
			WHEN 'Y' THEN ord_charge_type
			ELSE 0
		END,  --13
	@ordnumber,ord_mintemp,ord_maxtemp,ord_distributor,opt_trc_type4,opt_trl_type4,ord_cod_amount,  --14 opt_suggested_trc,opt_suggested_trl,
	appt_init,appt_contact,
	ord_ratingquantity = 
	CASE @copycharges
		WHEN 'Y' THEN ord_ratingquantity
		ELSE 0
	END,
	ord_ratingunit = 
	CASE @copycharges
		WHEN 'Y' THEN ord_ratingunit
		ELSE 'UNK'
	END, --15  ord_booked_revtype1,ord_hideshipperaddr,ord_hideconsignaddr, 
	trl_type1 = 
		CASE @copycharges   /* per MF these are related to rating not equipment sassigned */
			WHEN 'Y' then trl_type1
			ELSE 'UNK'
		END ,
	ord_customer,
	ord_supplier /*,
	ord_trl_type2 = 
		CASE @copycharges  
			WHEN 'Y' then ord_trl_type2
			ELSE NULL
		END,
	ord_trl_type3 = 
		CASE @copycharges   
			WHEN 'Y' then ord_trl_type3
			ELSE NULL
		END,
	ord_trl_type4 = 
		CASE @copycharges  
			WHEN 'Y' then ord_trl_type4
			ELSE NULL
		END, NULL,NULL  */
	FROM orderheader where ord_number = @ordnumber

	IF @@error<>0
        BEGIN  
			EXEC tmw_log_error 0, 'copy_existing_order COPY INTO orderheader Failed ', @@error, ''
			SELECT @retcode = -1
			GOTO ERROR_RETURN
		  END
/*********************** If any ref numbers were copied, create referencenumber table entries  ***************************/



IF @copyordrefnums = 'Y'
  BEGIN
	SELECT @minrefsequence = 0
	WHILE 1 = 1
	  BEGIN
		SELECT @minrefsequence = MIN(ref_sequence) 
		FROM referencenumber
		WHERE ref_table = 'orderheader'
		AND ref_tablekey = @copyordhdrnumber
		AND ref_sequence > @minrefsequence
		
		IF @minrefsequence IS NULL BREAK

		SET ROWCOUNT 1
		INSERT INTO referencenumber
		(ref_tablekey,ref_type,ref_number,ref_typedesc,ref_sequence,ord_hdrnumber, ref_table,ref_sid,ref_pickup)
		SELECT @newordhdrnumber,ref_type,ref_number,ref_typedesc,ref_sequence,@newordhdrnumber, ref_table,ref_sid,ref_pickup
		FROM referencenumber
		WHERE ref_table = 'orderheader'
		AND ref_tablekey = @copyordhdrnumber
		AND ref_sequence = @minrefsequence

		SET ROWCOUNT 0
	  END
  END
		
/***********************  lets hold it all together with update move **************************/
EXEC reset_loadrequirements_sp @newmovnumber
EXEC dbo.update_move @newmovnumber
IF @tractor IS NOT NULL AND LEN(RTRIM(@tractor)) > 0 EXEC update_assetassignment @newmovnumber

IF @CopyOrderNotes = 'Y' 
  BEGIN
	SELECT @minNotNumber = 0
	WHILE (0=0)
	  BEGIN	
			SELECT @minNotNumber = MIN(not_number)
			FROM notes
			WHERE ntb_table = 'orderheader'
			AND nre_tablekey = CONVERT(varchar(12),@copyordhdrnumber)
			AND not_number > @minNotNumber

			IF @minNotNumber IS NULL BREAK

			EXEC @newnotnumber = dbo.getsystemnumber 'NOTES',NULL
			IF @newnotnumber IS NULL RETURN -1

			INSERT INTO notes (not_number,not_text,not_type,not_urgent,not_senton,not_sentby,not_expires,not_forwardedfrom,
			ntb_table,nre_tablekey,not_sequence,last_updatedby,last_updatedatetime)
			SELECT @newnotnumber,not_text,not_type,not_urgent,not_senton,not_sentby,not_expires,not_forwardedfrom,
			ntb_table,CONVERT(varchar(12),@newordhdrnumber),not_sequence,'AUTOCOPY',getdate()
			FROM notes
			WHERE  not_number = @minNotnumber 

	  END
  END

	SELECT @NewOrderNumber = @assignorder 

COMMIT TRANSACTION
RETURN 1


ERROR_RETURN:
	ROLLBACK TRANSACTION
	RETURN @retcode


GO
GRANT EXECUTE ON  [dbo].[copy_existing_order] TO [public]
GO
