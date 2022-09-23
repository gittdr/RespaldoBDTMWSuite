SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

 /* Mod log  
    4/3/00 add stp event code and PS resonlate code to call for   
            record_id_3_34 (34 version only at this time)  
    1/17/01 pts9721 change docid for each set of records  
    2/5/01 9926 do not create any EDI output if Jack's new automail field is set for FAX (Y)  
    2/15/01 9885 since we switched departure back to a stop trigger (on stp_departure_status  
          from events we must build back in the possibility of an activity of ARVDEP  
    2/27/01 10071 Getting duplicate 214 output for the ARV activity (because I added  
           an activity for change in estimated arival as ESTARV which gets a hit on  
           the charindex of the activity (meant to catch ARVDEP as both an ARV and  a  
           DEP.  CHange the activity to ESTA  
   3/1/01 10106 dpete found error in the routine to parse a comma delimeted string  
  of status codes.  Resulted in invalid dates on the AG status from a pickup  
         stop because the case statement comparing status codes and levels found no  
         match  
  6/26/01 pts 10311 make v3.4 EDI work in PS V2001,2002  
  dpete 14389 5/21/02 fix bug with one character status codes for version 3.9 call to record #3  
 DPETE 15207 8/15/02 change check for latenoreason flag to join to e214_cmp_id 
  DPETE 9/17/02 15530 Cover AA (pick up appointment) status on pickup  stops (assume its in the pending table)
 DPETE PTS 16151 Use date passed form pending for AA status on depart 
  DPETE 16313 Chrysler requires on set of 214 per drop stop on depart shipper, Alter to pass relative drop stop
 NKRES 16407 AG special handling should use arrival at first subsequent drop instead of strictly first drop
  NKRES 16437 Add handling for relativedrop: use weight for 3 keeping other details; use the DROP for the 2 and 4
 NKRES 16821 Added case to when for statusreasonlate to pickup late code for cancel
 NKRES 17519 Add ESTA with checkcall location switch
BLEVON 16223 -- 5/21/03 -- Allow for 'Company' based notification process
DPETE 22536 Customer had NULL in doc Id field, 214's did not extract
AROSS 28572 --7/11/05-- Add checking for auto 214 transaction based requirements.
AROSS 22898  Added IsNull check to retrieve of wgt,vol and count quantities.
AROSS 29073  Altered auto-214 req check to sum all weight volume and count quantities for each freightdetail attached to the current stop.
AROSS 30182   Added multiple 214 per BOL functionality.
2006.04.07.001 - PTS27630 - A.Rossman - Allow for status reason code when creating an appointment 214.
DMEEK PTS 34134 Modified stop weight retrieval in the case of in-route delivers to pull the weight from the 'PU' stop record
AROSS 10.30.06 -PTS 34468 Additional hold queue logic added.
AROSS 05.25.07 - PTS 37070.  Adjust times for early delivery departure when within the specified threshold .
AROSS 08.30.06 - PTS 34624 - Added custom logic to utilize the previous stops departure date/time for the current status time on arrivals.  Custom For Midwest Express
FMICH 06.25.08 - PTS 43377 - Adjusted PTS 34624 to only use immediate prior stop departure date/time for the current status time on arrivals.
DWILK 10.22.09 - PTS 49554 - When GI setting EDI214UseDestCityForAG is set to 'Y' and is 'AG' status, replace status city of generating stop with city of next drop
oAROSS 02.03.10 - PTS 50792 - Use scheduled date change log reason when setting is enabled('ALL','SPECIFIC')
DWILK 07/15/11   PTS 51916 - stop level ref multiple 214s
DWILK  9/21/11   PTS 58001 - trip dispatched X6 showing last check call location
AROSS 1.14.14	 PTS 74227 - added source of status
DWILK 5/7/15     PTS 83343 - add stop event option to EDI214UseDestCityForAG setting
*/  
  
  
CREATE PROCEDURE [dbo].[auto_214_sp]   
 @ord_number   char(12),  
 @e214_cmp_id  char(8),  
 @e214_level  varchar(3),  
 @e214_ps_status  varchar(3),  
 @stp_number  integer,  
        @e214p_activity         varchar(6),  
        @e214p_arrive_earlyorlate char(1),  
        @e214p_depart_earlyorlate char(1),  
 @e214p_dttm              datetime,  
 @ckc_number  int,  
 @firstlastflags  varchar(20),
 @relativeStop int = 0,
 @relativeMode int = 0,
 @sourceApp nvarchar(128) = '',	--74227
 @sourceUser varchar(255) = ''	--74227
AS  

/*  
 Program: auto_214_sp  
 Descr: Generates a 214 for the order, using status(es)  
  as defined in EDI_214_profile on records matching  
  the billto, level and ps_status provided  
 History: 991019 vjh Created  
              021100 dpete put out #2 after each #3  
                     put out #4 orderheader after #1, #4stop  
                     after #3  
              040300 pts7526 do not bypass auto 214 on EDI214lateAR='Y'   
                     IF there exists a late reasoncode.  
--                     Pass an indication of the activity ARV, DEP ARVDEP, OTH  
--                     and the flag to indicate IF the arrival is early or late  
--              4/3/00 add stp event code and PS resonlate code to call for   
--                     record_id_3_34 (34 version only at this time  
--              5/29/00 COPIED LOGIC FOR 3.4 TO 3.9 (3.4 MODIFIED FOR ONLY CUSTOMER -- USING AUTO 214)  
--              7/7/00 PTS7962 allow mulitple outputs per profile entry V3.9, handle --                      auto214  
--                     on dispatch, ck call and cancel order (bill)  
             9/8/00 populate new col doc_id containing ord_hdrnumber-ddhhmmss and  
                  add an end of trans record type to hold trans sets together and in seq  
  12/29/00 pts 9625 add specification of position of stop type (1=first,2=not first,  
  3 not last,99 last, 0=any)  
  
  2/14/01 dpete pts 9978 at CTX they send an X1 (arrive at consignee) when they arrive  
     at the last drop stop. Unfortunately we changed their dispatch system to  
     depart before they arrive on the last drop stop only.  they set up thier   
     auto 214 to send the X1 on depart from the last drop (when they mean arrive).  
     Add code here so that if you are departing the stop but sending an X1 that   
     the date is set to the arrival date rather than the depart.  
  
 Content of some parms depends on activity  
                DISP             ARV             DEP            CKCALL            APPT    
 stp_number    first PUP      arrive stop     depart stop     next open stop     appt stop  
 est_arrival   Est 1st PUP    Est arrive stp  n/a             Est next open stp  schdt latest   
 Arv early/late  n/a           set '','L','E'  set '','L','E'   n/a                  n/a  
 Dep early/late  n/a           set '','L','E'  set '','L','E'   n/a                  n/a  
  
*/  
DECLARE @EDI214Ver varchar(60),  
 @EDI214lateAR varchar(3), 
 @EDI214lateDP char(1),		--34468
 @EDI214Sequence char(1),		--34468
 @TPNumber varchar(20),  
 @e214_id int,  
 @e214_sequence int,  
 @e214_edi_status varchar(25),  
 @e214_status_table_version varchar(6),  
 @StatusDateTime datetime,  
 @stp_schdtearliest datetime,  
 @stp_arrivaldate datetime,  
 @stp_departuredate datetime,  
 @next_drp_arrivaldate datetime,  
 @next_arrivaldate datetime,
 @next_drp_arrivalcity int,  
 @next_pup_arrivaldate datetime,  
 @stp_schdtlatest datetime,  
 @TimeZone varchar(2),  
 @StatusCity integer,  
 @TractorID varchar(13),  
 @MCUnitNumber int,  
 @TrailerOwner varchar(4),  
 @Trailerid varchar(13),  
 @StatusReason varchar(3),  
 @stp_sequence varchar(3),  
 @stpsequence int,  
 @StopWeight float,  
 @nextstopweight float,
 @StopQuantity float,  
 @StopReferenceNumber varchar(15),  
 @ordhdrnumber integer,  
 @stopcmpid varchar(8),  
 @n101code varchar(2),  
 @fgtnumber int,  
 @stopevent varchar(6),  
 @stopreasonlate varchar(6),  
 @stopreasonlatedepart varchar(6),  
 @e214_activity varchar(6),  
 @next_status varchar(3),  
 @start_pos int,  
 @charindex int,  
 @stp_type varchar(6),  
 @next_stp_arrivaldate datetime,  
 @cancel_flag char(1),  
 @min varchar(50),  
 @getdate datetime,  
 @docid varchar(30),
 @dropnumber int,
 @Statusstpseq int,
 @relativestoptype char(3),
 @relativestopnumber int,
 @UseGPSLocation char(1),
-- PTS 16223 -- BL
 @EDI_Notification_Process_Type int,
--AROSS 28572
 @e214trlreq char(1),
 @holdreason  varchar(6),
 @trl_id	varchar(13),
 @wgt_req	float,
 @vol_req	float,
 @count_req	float,
 @wgt_oper	char(1),
 @vol_oper	char(1),
 @count_oper char(1),
 @StopVolume	float,
 @v_fgt_vol	float,
 @v_fgt_wgt float,
 @v_fgt_cnt float,
 @SplitbillMilkrun varchar(1),
--DMEEK PTS 34134
@trp_prevent_early_dep	char(1),	--PTS 37070
@trp_prevent_early_min	smallint, --PTS 37070
@schdtEarly_adjusted		datetime, --PTS 37070
@trp_prevent_early_adjustment	smallint,
@lgh_number	int,					--{34624}
@stp_mfh_sequence int,			--{34624}
@prior_stp_depart	datetime,		--{34624}
@EDI214UseDestCityForAG char(1), --49554
@EDI214UseDestCityForAGNextStopEvent varchar(30),
@ScheduledDateChangeLevel varchar(10),	--50792
@apptRsnId					int,		--50792
@next_stp_sequence	INT,		--79824
@next_stp_event		VARCHAR(6)	--79824
-- run company specific code
exec prepare_for_edi_extract_sp

-- PTS 16223 -- BL (start)
CREATE TABLE #profile39 (
  e214_cmp_id varchar(8),  
  e214_level varchar(3),  
  e214_edi_status varchar(25),  
  e214_triggering_activity varchar(6),  
  e214_latenoreason_handling varchar(3),  
  e214_sequence smallint  )
-- PTS 16223 -- BL (end)

-- PTS 16223 -- BL (start)
CREATE TABLE #profile34 (
  e214_cmp_id varchar(8),  
  e214_level varchar(3),  
  e214_edi_status varchar(25),  
  e214_triggering_activity varchar(6),  
  e214_latenoreason_handling varchar(3),  
  e214_sequence smallint  )
-- PTS 16223 -- BL (end)

-- PTS 16223 -- BL (start)
--    Check which 'EDI notification process type' is to be used
--          ((1) 'BillTo' based or (2) 'Company' based) 
SELECT @EDI_Notification_Process_Type = gi_string1
FROM generalinfo
WHERE gi_name = 'EDI_Notification_Process_Type'
-- PTS 16223 -- BL (end)

SELECT @EDI214UseDestCityForAG = gi_string1, @EDI214UseDestCityForAGNextStopEvent = IsNull(gi_string2,'DRP') --49554
FROM generalinfo
WHERE gi_name = 'EDI214UseDestCityForAG'

if @EDI214UseDestCityForAGNextStopEvent = ''
	set @EDI214UseDestCityForAGNextStopEvent = 'DRP'

--PTS 50792 Get scheduled change setting
SELECT @ScheduledDateChangeLevel = UPPER(ISNULL(gi_string1,'NONE'))
FROM  generalinfo
WHERE gi_name = 'ReqSchChangeReason'


/* 9916 is there any edi output for the profile */  
-- PTS 16223 -- BL (start)
IF @EDI_Notification_Process_Type = 1
-- PTS 16223 -- BL (end)

IF Not Exists (SELECT *  
 FROM edi_214_profile  
        WHERE e214_cmp_id=@e214_cmp_id and  
       e214_level = @e214_level and  
  CHARINDEX(e214_triggering_activity,@e214p_activity) > 0 and  
       CHARINDEX(CONVERT(varchar(5),e214_stp_position),@firstlastflags) > 0 AND  
  ISNULL(automail,'N') = 'N')   
   RETURN

-- PTS 16223 -- BL (start)
--       (check if there is any EDI output for 'company' based process)
IF @EDI_Notification_Process_Type = 2 
 
IF Not Exists (SELECT *  
 FROM edi_214_profile  
        WHERE e214_cmp_id=@e214_cmp_id and  
       e214_level = @e214_level and  
  CHARINDEX(e214_triggering_activity,@e214p_activity) > 0 and  
       CHARINDEX(CONVERT(varchar(5),e214_stp_position),@firstlastflags) > 0 AND  
  ISNULL(notify_by_edi_flag,'N') = 'Y')   
   RETURN
-- PTS 16223 -- BL (end)


--Get stops information  
  
SELECT  @ordhdrnumber = stops.ord_hdrnumber,  
 @stopcmpid = stops.cmp_id,   
 @n101code =   
  CASE stp_type  
    WHEN 'PUP' THEN 'SH'  
    WHEN 'DRP' THEN 'CN'  
    ELSE 'XX'  
     END,   
        @stopevent = stp_event,  
 @StatusReason = 'NS',  
        @stopreasonlate =   
           Case @e214p_activity  
		When 'ARV' Then ISNULL(stp_reasonlate,'UNK')  
		When 'DEP' Then ISNULL(stp_reasonlate_depart,'UNK')  
		When 'CAN' Then ISNULL(stp_reasonlate,ISNULL(stp_reasonlate_depart,'UNK'))
		When 'ESTA' Then ISNULL(stp_reasonlate, 'UNK')
             Else '   '  
           End,  
 @TimeZone = 'LT',  
 @StatusCity = stp_city,  
 @TractorID = evt_tractor,  
 @MCUnitNumber = null,  
 @TrailerOwner = '',  
 @Trailerid = Case evt_trailer1
				When Null Then stops.trl_id
				When 'UNKNOWN' Then stops.trl_id
				Else evt_trailer1
			  End,  
 @stp_sequence = convert(varchar(3),stp_sequence),  
 @stpsequence = stp_sequence,  
 @StopWeight = ISNULL(stp_weight,0),				  --AROSS 22898 Added ISNULL to wgt,vol & count
 @StopQuantity = ISNULL(stp_count,0),
 @StopVolume = ISNULL(Stp_volume,0),		--28572  
 @StopReferenceNumber = substring(stp_refnum,1,15),  
 @ordhdrnumber = stops.ord_hdrnumber ,  
        @stp_arrivaldate = stops.stp_arrivaldate,  
        @stp_departuredate = stops.stp_departuredate,  
 @stp_schdtlatest = stops.stp_schdtlatest,  
 @stp_schdtearliest = stops.stp_schdtearliest,  
   @stp_type = stp_type    ,
    @lgh_number = stops.lgh_number,	--34624
     @stp_mfh_sequence = stops.stp_mfh_sequence	--34624
FROM stops , event             
WHERE stops.stp_number = @stp_number and  
 event.stp_number = @stp_number and evt_sequence=1 

--DMEEK 08/15/06 PTS 34134
SELECT @SplitbillMilkrun = gi_string1 FROM generalinfo WHERE gi_name = 'SplitbillMilkrun'

IF @SplitbillMilkrun = 'Y' 
 BEGIN
     	IF @n101code = 'CN'
	    IF @StopWeight = 0
		select @StopWeight = freightdetail.fgt_weight
		from freightdetail, stops
		where freightdetail.fgt_shipper = freightdetail.fgt_leg_origin
		and freightdetail.fgt_consignee = freightdetail.fgt_leg_dest
		and stops.ord_hdrnumber = @ordhdrnumber
		and freightdetail.fgt_consignee = @stopcmpid
 END
--DMEEK 08/15/06 PTS 34134
 
 
--PTS 50792 Use Stops change log for appt reason
IF @e214p_activity = 'APPT'
begin
IF @ScheduledDateChangeLevel in('ALL','SPECIFIC')
	begin
		SELECT @apptRsnId =  rsn_id
		FROM stop_schchange_log
		WHERE	stp_number = @stp_number
				and ssl_id = (SELECT MAX(ssl_id) FROM stop_schchange_log WHERE stp_number = @stp_number)
		
		Select	@stopreasonlate = LEFT(UPPER(rsn_code),3)
		FROM	edi_reason_codes
		WHERE	rsn_id = @apptRsnId	
		
		SELECT @StatusReason = @stopreasonlate
   end		--END 50792
ELSE
 /* PTS 27630 AROSS - Get the SRC for APPT 214's */
 	SELECT @stopreasonlate =  ISNULL(evt_reason,'UNK')
 	FROM	event 
 	WHERE	stp_number = @stp_number 
 		AND evt_sequence = (select min(evt_sequence) from event where stp_number = @stp_number and evt_eventcode = 'SAP')
end

--PTS  34624 get the prior stops departuredate info.
SELECT @prior_stp_depart = stp_departuredate
FROM	stops
WHERE	lgh_number = @lgh_number
		AND cmp_id = @stopcmpid
		AND stp_mfh_sequence = (@stp_mfh_sequence - 1)  --FMM PTS 43377: formerly AND stp_mfh_sequence < @stp_mfh_sequence   
--END 34624	

--22536
Select @ordhdrnumber = IsNull(@ordhdrnumber,0)  -- E Conrad had NULL doc id in edi_214 table  
  
/* For ckcalls wanting next Drp instead of next stp arrival get next drp est arrival */  
/* For PTS16313 use relative drop stop count for selecting date for AG */
/* For 16407 add where clause for stp_arrivaldate - system asserts there's a drop sometime after every pickup */
If @RelativeMode = 0 or @relativeStop = 0
 BEGIN
 SELECT top 1 @next_drp_arrivaldate = stp_arrivaldate, @next_drp_arrivalcity = stp_city,@next_stp_sequence = stp_sequence,@next_stp_event = stp_event
 FROM stops
 WHERE stops.ord_hdrnumber = @ordhdrnumber
 AND stops.stp_sequence > @stpsequence
 AND stops.stp_type = 'DRP'  
 order by stp_sequence
 
  /* if the trip is complete, pick up arrival date on last stop */  
  IF @next_drp_arrivaldate IS NULL  
 SELECT top 1 @next_drp_arrivaldate = stops.stp_arrivaldate, @next_drp_arrivalcity = stp_city,@next_stp_sequence = stp_sequence,@next_stp_event = stp_event
 FROM stops  
 WHERE stops.ord_hdrnumber = @ordhdrnumber order by stops.stp_arrivaldate desc

 If IsNull(@EDI214UseDestCityForAG,'N') = 'Y' and @EDI214UseDestCityForAGNextStopEvent <> 'DRP' 
	BEGIN
		SELECT top 1 @next_arrivaldate = stp_arrivaldate, @next_drp_arrivalcity = stp_city,@next_stp_sequence = stp_sequence,@next_stp_event = stp_event
		FROM stops
		WHERE stops.ord_hdrnumber = @ordhdrnumber
		AND stops.stp_sequence > @stpsequence
		AND (stops.stp_type = @EDI214UseDestCityForAGNextStopEvent or (@EDI214UseDestCityForAGNextStopEvent = 'ANY' and stops.stp_type in ('DRP','PUP')))
		order by stp_sequence

		/* if the trip is complete, pick up arrival date on last stop */  
		IF @next_arrivaldate IS NULL  
				SELECT top 1 @next_arrivaldate = stops.stp_arrivaldate, @next_drp_arrivalcity = stp_city,@next_stp_sequence = stp_sequence,@next_stp_event = stp_event
				FROM stops  
				WHERE stops.ord_hdrnumber = @ordhdrnumber order by stops.stp_arrivaldate desc
	END

 END
Else
 BEGIN
	Select @dropnumber = 1,	@statusstpseq = 0
	
	if @relativeMode = 2
		select @relativestoptype ='DRP'	 			
	else  
		select @relativestoptype ='PUP'
	 			
   While @dropnumber <= @RelativeStop
     BEGIN
      Select @statusstpseq = Min(stp_sequence) From stops Where ord_hdrnumber = @ordhdrnumber and stp_type = @relativestoptype and stp_sequence > @statusstpseq
      Select @dropnumber = @dropnumber + 1
     END
   Select  @next_drp_arrivaldate = stops.stp_arrivaldate, @stopweight = stp_weight, @stp_sequence = convert(varchar(3),stp_sequence), @next_drp_arrivalcity = stp_city
 	FROM stops  
	 WHERE stops.ord_hdrnumber = @ordhdrnumber  
 	AND  stops.stp_sequence = @statusstpseq
   /* For 16407, assert that this drop is later than this pickup in sequence */
   If @stp_type = 'PUP' and @statusstpseq < @stpsequence
 	Return
   If @stp_type = 'DRP' and @statusstpseq > @stpsequence
  	Return
 END  
 
 --select @stopweight as stopweight, @stp_sequence as sequence, @relativedrop as relativedrop
 
 SELECT @next_drp_arrivaldate  = ISNULL(@next_drp_arrivaldate,'20491231')  
 SELECT @next_drp_arrivalcity = ISNULL(@next_drp_arrivalcity,@StatusCity)  
 
  
  /* Pick up optional edicode equivalent for reasonlate code    
  */  
  /*PTS 27630 AROSS - Allow for SRC for appointment generated 214's 
  	auto214 APPT messages will use the evt_reason from the Reschedule Labelfile*/
  IF @e214p_activity = 'APPT' and @ScheduledDateChangeLevel NOT IN('ALL','SPECIFIC')		--PTS 50792
  	 SELECT @StatusReason  = UPPER(SUBSTRING(ISNULL(edicode,abbr),1,3))  
  	 FROM labelfile  
  	 WHERE labeldefinition = 'Reschedule'  
  	 AND abbr = @stopreasonlate  
  
  IF @e214p_activity <> 'APPT'
   SELECT @StatusReason  = UPPER(SUBSTRING(ISNULL(edicode,abbr),1,3))  
   FROM labelfile  
   WHERE labeldefinition = 'ReasonLate'  
   AND abbr = @stopreasonlate  

  
 SELECT @StatusReason = ISNULL(@StatusReason,'NS')  
 If @StatusReason = '' or @statusreason = 'UNK'  
     SELECT @StatusReason = 'NS'  
  
/*  
--before we process the 214, first check to see IF the stp_arrivaldate  
--was eraly or late.  IF so, and IF generalinfo EDI214LateAR is YES  
-- just write to the notification table, rather than generating the 214  
*/  
  
 SELECT @EDI214lateAR = MIN(e214_latenoreason_handling)  ,
 	        @EDI214lateDP = MIN(e214_latedeparture_handling),
 	        @EDI214Sequence = MIN(e214_enforce_sequence)
 FROM edi_214_profile  
 WHERE e214_cmp_id = @e214_cmp_id  
 
 --AROSS 28572(start)  Check Qty requirements.
   SELECT	@wgt_req = ISNULL(e214_wgt_qty,-1), @wgt_oper = e214_wgt_oper,
			@vol_req = ISNULL(e214_volume_qty,-1), @vol_oper = e214_volume_oper,
			@count_req = ISNULL(e214_count_qty,-1), @count_oper = e214_count_oper
  FROM		edi_214_profile
  WHERE		e214_cmp_id = @e214_cmp_id
			  And e214_level = @e214_level
			  AND e214_triggering_activity = @e214p_activity	

  --AROSS PTS 29073  Get the total weight,volume and count based on freight details associated with the stop
  SELECT	@v_fgt_wgt = SUM(ISNULL(fgt_weight,0)),@v_fgt_vol = SUM(ISNULL(fgt_volume,0)),@v_fgt_cnt = SUM(ISNULL(fgt_count,0))
  FROM		freightdetail
  WHERE		stp_number = @stp_number
			  
	--weight requirements checking
		If @wgt_oper in ('<','>')  And @wgt_req >  -1
			BEGIN
				If @wgt_oper = '>' AND @wgt_req >= @v_fgt_wgt
					Select @holdreason = 'WGTMIN'
				IF @wgt_oper = '<' AND @v_fgt_wgt >= @wgt_req
					Select @holdreason = 'WGTMAX'
			END		 
	--volume requirements checking	
			If @vol_oper in ('<','>')  And @vol_req >  -1
			BEGIN
				If @vol_oper = '>' AND @vol_req >= @v_fgt_vol
					Select @holdreason = 'VOLMIN'
				IF @vol_oper = '<' AND @v_fgt_vol >= @vol_req
					Select @holdreason = 'VOLMAX'
			END	 		
	--count requirements checking
			If @count_oper in ('<','>')  And @count_req >  -1
			BEGIN
				If @count_oper = '>' AND @count_req >= @v_fgt_cnt
					Select @holdreason = 'CNTMIN'
				IF @count_oper = '<' AND @v_fgt_cnt >= @count_req
					Select @holdreason = 'CNTMAX'
			END		
 
 --AROSS 28572    Check Trailer requirements
 SELECT @e214trlreq = ISNULL(e214_trlreq_flag,'N')
 FROM edi_214_profile
 WHERE e214_cmp_id = @e214_cmp_id
		And e214_level = @e214_level
		AND e214_triggering_activity = @e214p_activity
IF @e214trlreq = 'Y'
	BEGIN
		If (SELECT ISNULL(ord_trailer,'UNKNOWN') from orderheader where ord_hdrnumber = @ordhdrnumber) = 'UNKNOWN'
			SELECT @holdreason = 'TRL'
	END			
--28572 (end)
  
 SELECT @EDI214lateAR=SUBSTRING(isnull(@EDI214lateAR,'N'),1,1)  
  
 IF @EDI214lateAR='Y' and  (@e214p_arrive_earlyorlate = 'L' and @stopreasonlate = 'UNK')
	    and  @e214p_activity = 'ARV'
    SELECT @holdreason = 'NR'
    
 IF @EDI214lateDP = 'Y' and (@e214p_depart_earlyorlate = 'L' and @stopreasonlate = 'UNK')
 	and @e214p_activity = 'DEP'
 	SELECT @holdreason = 'NR'
 	
 IF ((SELECT COUNT(*) FROM edi_214_pending_hold WHERE e214ph_ord_hdrnumber = @ordhdrnumber )> 0 AND @e214p_activity in ('ARV','DEP') AND @EDI214Sequence = 'Y')
 	SELECT @holdreason = 'ORDHLD'
    
    --AROSS 28572(start) 
    IF @holdreason in('TRL','NR','WGTMIN','WGTMAX','VOLMIN','VOLMAX','CNTMIN','CNTMAX','ORDHLD')      
      BEGIN  
	
		INSERT INTO edi_214_pending_hold(
					e214ph_ord_hdrnumber,
					e214ph_billto,
					e214ph_level,
					e214ph_ps_status,
					e214ph_stp_number,
					e214ph_dttm,
					e214ph_activity,
					e214ph_arrive_earlyorlate,
					e214ph_depart_earlyorlate,
					e214ph_stpsequence,
					e214ph_consolidation,
					ckc_number,
					e214ph_firstlastflags,
					e214ph_created,
					e214ph_ReplicateForEachDropFlag,
					e214ph_holdreason,
					e214ph_source,
					e214ph_user)
					
			VALUES( @ordhdrnumber,
					@e214_cmp_id,
					@e214_level,
					@e214_ps_status,
					@stp_number,
					@e214p_dttm,
					@e214p_activity,
					@e214p_arrive_earlyorlate,
					@e214p_depart_earlyorlate,
					@stp_sequence,
					null,
					@ckc_number,
					@firstlastflags,
					Getdate(),
					'N',
					@holdreason,	--28572(end)
					@sourceApp,
					@sourceUser)	--74227 Add source of 214 status
   
 INSERT edi_214_notification   
  (e214n_ord_hdrnumber,  
  e214n_stp_number,  
  e214n_dttm)  
 VALUES (@ordhdrnumber,  
  @stp_number,  
  getdate())  
 RETURN  
     END  
  
-- get version of flat file output
 SELECT @EDI214Ver = ISNULL(gi_string1,'1.0')  
 FROM generalinfo  
 WHERE gi_name='EDI214Ver'  
  
 SELECT @EDI214Ver=ISNULL(@EDI214Ver,'1.0')  
  
-- retrieve Trading Partner number  
 SELECT @TPNumber = trp_id  
 FROM edi_trading_partner   
 WHERE cmp_id=@e214_cmp_id  
                               
 SELECT @TPNumber = ISNULL(@TPNumber,'NOVALUE')  
 

 		    
 
 
 IF @EDI214Ver='3.4'  
   BEGIN  
-- PTS 16223 -- BL (start)
IF @EDI_Notification_Process_Type = 1
-- PTS 16223 -- BL (end)
INSERT #profile34
 SELECT e214_cmp_id,  
  e214_level,  
  e214_edi_status,  
  e214_triggering_activity,  
  e214_latenoreason_handling,  
  e214_sequence = ISNULL(e214_sequence,1)  
-- INTO #profile34  
 FROM edi_214_profile  
        WHERE e214_cmp_id=@e214_cmp_id and  
       e214_level = @e214_level and  
       CHARINDEX(e214_triggering_activity , @e214p_activity) > 0 and  
       CHARINDEX(CONVERT(varchar(5),e214_stp_position),@firstlastflags) > 0 AND  
  ISNULL(automail,'N') = 'N'  
   
-- PTS 16223 -- BL (start)
IF @EDI_Notification_Process_Type = 2
INSERT #profile34
 SELECT e214_cmp_id,  
  e214_level,  
  e214_edi_status,  
  e214_triggering_activity,  
  e214_latenoreason_handling,  
  e214_sequence = ISNULL(e214_sequence,1)  
-- INTO #profile34  
 FROM edi_214_profile  
        WHERE e214_cmp_id=@e214_cmp_id and  
       e214_level = @e214_level and  
       CHARINDEX(e214_triggering_activity , @e214p_activity) > 0 and  
       CHARINDEX(CONVERT(varchar(5),e214_stp_position),@firstlastflags) > 0 AND  
  ISNULL(notify_by_edi_flag,'N') = 'Y'   
-- PTS 16223 -- BL (end)
  
  
 SELECT @min=min(e214_triggering_activity+convert(varchar(6),e214_sequence))  
        FROM  #profile34  
   
 SELECT @min=isnull(@min,'')  
  
 WHILE @min > ''  
   BEGIN  
     SELECT @getdate = getdate()  
 /* doc id is ddhhmmssmssoooooooooo where oooooooooo is a 10 pos ord_hdr, dd is day, hh = hour etc */  
 /* the doc id makes it possible to mapa unique ID on the 214 which can be used  
           to tag as accepted or rejected on incoming 824 - returning this ID */  
     SELECT @docid =   
  replicate('0',2-datalength(convert(varchar(2),datepart(month,@getdate))))  
   + convert(varchar(2),datepart(month,@getdate))  
  + replicate('0',2-datalength(convert(varchar(2),datepart(day,@getdate))))  
   + convert(varchar(2),datepart(day,@getdate))  
  +replicate('0',2-datalength(convert(varchar(2),datepart(hour,@getdate))))  
   + convert(varchar(2),datepart(hour,@getdate))  
  +replicate('0',2-datalength(convert(varchar(2),datepart(minute,@getdate))))  
   + convert(varchar(2),datepart(minute,@getdate))  
  +replicate('0',2-datalength(convert(varchar(2),datepart(second,@getdate))))  
   + convert(varchar(2),datepart(second,@getdate))  
   +replicate('0',3-datalength(convert(varchar(3),datepart(millisecond,@getdate))))  
   + convert(varchar(3),datepart(millisecond,@getdate))  
  + REPLICATE('0',10-DATALENGTH(RIGHT(CONVERT(varchar(20),@ordhdrnumber),10)))  
  + RIGHT(CONVERT(varchar(20),@ordhdrnumber),10)

   If @docid is NULL Select @docid = 'NULL' + isnull(@ordhdrnumber,'ORD')  --PTS 22536  
              
     SELECT   
   @e214_edi_status =  
      CASE   
      WHEN e214_edi_status > ' ' THEN e214_edi_status  
                    ELSE SUBSTRING(e214_triggering_activity,1,2)   
                  END,  
                 @e214_activity = e214_triggering_activity,  
            @StatusDateTime =   
                   CASE e214_triggering_activity  
                    WHEN  'ARV'   THEN @stp_arrivaldate  
                    WHEN  'DEP'   THEN @stp_departuredate  
                    WHEN  'APT'   THEN @stp_schdtlatest  
      WHEN 'DISP'   THEN @e214p_dttm  
      WHEN 'CKCALL' THEN @e214p_dttm  
                    WHEN 'CAN'    THEN @stp_arrivaldate  
                    ELSE @e214p_dttm  
                  END  
   FROM #profile34  
   WHERE e214_triggering_activity+convert(varchar(6),e214_sequence)= @min  

  /* a "-" in front of the edi status code indicates a cancel for the trans  
     kind of hokey today, but know of no one other than CTX will use  
 */  
  If SUBSTRING(@e214_edi_status,1,1) = '-'  
            SELECT @cancel_flag = 'Y'  
  ELSE  
     SELECT @cancel_flag = 'N'  
 /*rec_1 which also does id_4 records and id_2 records */  
         EXEC edi_214_record_id_1_34_sp @ord_number,@cancel_flag ,@docid  
  
 -- create one #3 for each status in the profile entry  


          SELECT @start_pos = 1  
          SELECT @charindex = 1  
          WHILE @charindex > 0  
            BEGIN  
	  
              SELECT @charindex = CHARINDEX(',',@e214_edi_status,@start_pos)  
  
              If @charindex > 0 and @charindex > @start_pos  
   BEGIN  
                  SELECT @next_status = SUBSTRING(@e214_edi_status,@start_pos,@charindex - @start_pos)  
  
                  SELECT @start_pos = @charindex + 1  
   END  
  
              ELSE   
    IF @charindex = 0 and @start_pos < LEN(@e214_edi_status)  
    SELECT @next_status = SUBSTRING(@e214_edi_status,@start_pos,LEN(@e214_edi_status))  
              ELSE  
                  BEGIN  
                   SELECT @charindex =  0  
                   BREAK  
    END  
  
  
              /*  Reset status date under certain circumstances  ###how to indicate cancel  
                  EDI code X1 = arrive at delivery, X2 = estimated arrival at consignee,  
                           X3 = arrive at pickup, AG = estimated deliver, AF = carrier departed pickup  
                           (-X3 our code to indicate a cancel of an X3), CP = completed loading at pickup  
                           X6 = en route to delivery, X9 = delivery appt secured,  
      							XA = pickup appt secured 
									AA = scheduled depart time 
      */  
  
   
              SELECT @StatusDateTime =   
                 Case   
      When @e214_activity = 'ARV' and @next_status = '-X3'  
	 Then @e214p_dttm  -- cancel prior (est) arrive at pup passed  
      When @e214_activity = 'ARV' and @next_status in ('AG','X1','X2') and @e214_level = 'SH'  
   Then @next_drp_arrivaldate   
      When @e214_activity = 'DEP' and @next_status in ('AG','X1','X2') and @e214_level = 'SH'  
   Then @next_drp_arrivaldate   
      When @e214_activity = 'APPT' and @next_status in ('X9','XA')   
   Then getdate() -- Appointment secured on this date/time  
      When @e214_activity = 'DSP' and @next_status in ('AG','X1','X2')   
   Then @next_drp_arrivaldate   
      When @e214_activity = 'CKCALL' and @next_status in ('AG','X1','X2')   
   Then @next_drp_arrivaldate -- est arrive at drp FOR CKCALL  
      When @e214_activity = 'ESTA'    
   Then @stp_arrivaldate  
  When @e214_activity = 'DEP'  
   and @e214_level = 'CN'   
   and CHARINDEX('99',@firstlastflags) > 0    
   and @next_status = 'X1'    
   Then @stp_arrivaldate   /* for CTX 9878 depart before arv*/  
   WHEN @e214_activity = 'ARV' and @next_status = 'PS'			 --PTS 34624
     THEN ISNULL(@prior_stp_depart,@e214p_dttm)
--  When (@e214_level = 'SH' and @next_status = 'AA') or (@e214_level = 'CN' and @next_Status = 'AB') then @stp_schdtlatest
  When @e214_activity = 'DEP' and @next_status = 'AA' Then @e214p_dttm
      
      Else   
                       CASE @e214_activity  
                      WHEN  'ARV'   THEN @stp_arrivaldate  
                      WHEN  'DEP'   THEN @stp_departuredate  
                      WHEN  'APT'   THEN @stp_schdtlatest  
        WHEN 'DISP'   THEN @e214p_dttm  
       WHEN 'CKCALL' THEN @e214p_dttm  
                     WHEN 'CAN'    THEN @stp_arrivaldate  
                      ELSE @e214p_dttm  
                   END  
  End  
  
	--49554
	If IsNull(@EDI214UseDestCityForAG,'N') = 'Y' and @next_status = 'AG'
		SELECT @StatusCity = @next_drp_arrivalcity,@stp_sequence = convert(varchar(3),@next_stp_sequence),@stopevent = @next_stp_event

	If IsNull(@EDI214UseDestCityForAG,'N') = 'Y' and @EDI214UseDestCityForAGNextStopEvent <> 'DRP' and @next_status = 'AG'
		SELECT @StatusDateTime = @next_arrivaldate
  
       -- dash in first pos indicates cancel (hokey, but first pass)  
       IF SUBSTRING(@next_status,1,1) = '-'  
  SELECT @next_status = SUBSTRING(@next_status,2,DATALENGTH(@next_status) - 1)  
              IF LEN(@next_status) > 2    -- ensure status fits in flat file field  
  SELECT @next_status = SUBSTRING(@next_status,1,2)  

       IF @e214_activity <> 'CKCALL'   
         EXEC edi_214_record_id_3_34_sp    
  @next_status,  
  @StatusDateTime,  
  @TimeZone,  
  @StatusCity,   
  @TractorID,  
  @MCUnitNumber,  
  @TrailerOwner,  
  @Trailerid,  
  @StatusReason,  
  @stp_sequence,  
  @StopWeight,  
  @StopQuantity,  
  @StopReferenceNumber,  
  @ordhdrnumber,  
  @stopevent,  
  @stopreasonlate,   
  @e214_activity,  
  @docid  
       ELSE  
                EXEC edi_214_record_id_3_34_ckcall_sp  
    @next_status,  
    @ckc_number,  
    @StatusDateTime,  
    @ordhdrnumber,  
    @docid
 END  
  /* add an end of transaction record (never extracted to flat file) */   
     EXEC edi_214_record_id_end_sp @TPNumber,  @docid   
 SELECT @min = MIN(e214_triggering_activity+convert(varchar(6),e214_sequence))   
       FROM #profile34  
 WHERE e214_triggering_activity+convert(varchar(6),e214_sequence) > @min  
  
  
 SELECT @min=isnull(@min,'')  
     CONTINUE  
     END   
      
        
   END   
  
  
ELSE IF @EDI214Ver='3.9'  
  BEGIN  
   
    
/*  
 -- version 3.9  
   
 -- vjh need loop for record 3 for each row that matches the bt, level and status in the 214_profile  
        -- One  trans set per profile entry, Since there may be multiple entries per   
  -- activity, and we may need to control sequence of output, use the sequence  
 -- field to control  
*/  
-- PTS 16223 -- BL (start)
IF @EDI_Notification_Process_Type = 1
-- PTS 16223 -- BL (end)
INSERT #profile39
 SELECT e214_cmp_id,  
  e214_level,  
  e214_edi_status,  
  e214_triggering_activity,  
  e214_latenoreason_handling,  
  e214_sequence = ISNULL(e214_sequence,1)  
-- INTO #profile39  
 FROM edi_214_profile  
        WHERE e214_cmp_id=@e214_cmp_id and  
       e214_level = @e214_level and  
       CHARINDEX(e214_triggering_activity , @e214p_activity) > 0 and  
       CHARINDEX(CONVERT(varchar(5),e214_stp_position),@firstlastflags) > 0 AND  
  ISNULL(automail,'N') = 'N'  
   
-- PTS 16223 -- BL (start)
IF @EDI_Notification_Process_Type = 2
INSERT #profile39
 SELECT e214_cmp_id,  
  e214_level,  
  e214_edi_status,  
  e214_triggering_activity,  
  e214_latenoreason_handling,  
  e214_sequence = ISNULL(e214_sequence,1)  
-- INTO #profile39  
 FROM edi_214_profile  
        WHERE e214_cmp_id=@e214_cmp_id and  
       e214_level = @e214_level and  
       CHARINDEX(e214_triggering_activity , @e214p_activity) > 0 and  
       CHARINDEX(CONVERT(varchar(5),e214_stp_position),@firstlastflags) > 0 AND  
  ISNULL(notify_by_edi_flag,'N') = 'Y'   
-- PTS 16223 -- BL (end)
  
  
 SELECT @min=min(e214_triggering_activity+convert(varchar(6),e214_sequence))  
        FROM  #profile39  
   
 SELECT @min=isnull(@min,'')  
  
 WHILE @min > ''  
   BEGIN  
     SELECT @getdate = getdate()  
 /* doc id is ddhhmmssmssoooooooooo where oooooooooo is a 10 pos ord_hdr, dd is day, hh = hour etc */  
 /* the doc id makes it possible to mapa unique ID on the 214 which can be used  
           to tag as accepted or rejected on incoming 824 - returning this ID */  
     SELECT @docid =   
  replicate('0',2-datalength(convert(varchar(2),datepart(month,@getdate))))  
   + convert(varchar(2),datepart(month,@getdate))  
  + replicate('0',2-datalength(convert(varchar(2),datepart(day,@getdate))))  
   + convert(varchar(2),datepart(day,@getdate))  
  +replicate('0',2-datalength(convert(varchar(2),datepart(hour,@getdate))))  
   + convert(varchar(2),datepart(hour,@getdate))  
  +replicate('0',2-datalength(convert(varchar(2),datepart(minute,@getdate))))  
   + convert(varchar(2),datepart(minute,@getdate))  
  +replicate('0',2-datalength(convert(varchar(2),datepart(second,@getdate))))  
   + convert(varchar(2),datepart(second,@getdate))  
   +replicate('0',3-datalength(convert(varchar(3),datepart(millisecond,@getdate))))  
   + convert(varchar(3),datepart(millisecond,@getdate))  
  + REPLICATE('0',10-DATALENGTH(RIGHT(CONVERT(varchar(20),@ordhdrnumber),10)))  
  + RIGHT(CONVERT(varchar(20),@ordhdrnumber),10)  
              
     SELECT   
   @e214_edi_status =  
      CASE   
      WHEN e214_edi_status > ' ' THEN e214_edi_status  
                    ELSE SUBSTRING(e214_triggering_activity,1,2)   
                  END,  
                 @e214_activity = e214_triggering_activity,  
            @StatusDateTime =   
                   CASE e214_triggering_activity  
                    WHEN  'ARV'   THEN @stp_arrivaldate  
                    WHEN  'DEP'   THEN @stp_departuredate  
                    WHEN  'APT'   THEN @stp_schdtlatest  
      WHEN 'DISP'   THEN @e214p_dttm  
      WHEN 'CKCALL' THEN @e214p_dttm  
                    WHEN 'CAN'    THEN @stp_arrivaldate  
                    ELSE @e214p_dttm  
                  END  
   FROM #profile39  
   WHERE e214_triggering_activity+convert(varchar(6),e214_sequence)= @min  
  
  /* a "-" in front of the edi status code indicates a cancel for the trans  
     kind of hokey today, but know of no one other than CTX will use  
 */  
  If SUBSTRING(@e214_edi_status,1,1) = '-'  
            SELECT @cancel_flag = 'Y'  
  ELSE  
     SELECT @cancel_flag = 'N'  
 /*rec_1 which also does id_4 records and id_2 records */  
-- PTS 16223 -- BL (start)
--         EXEC edi_214_record_id_1_39_sp @ord_number,@cancel_flag ,@docid  

		
         --EXEC edi_214_record_id_1_39_sp @ord_number,@cancel_flag ,@docid,@e214_cmp_id  
		 EXEC edi_214_record_id_1_39_sp @ord_number,@cancel_flag ,@docid,@e214_cmp_id,@sourceApp,@sourceUser	--74227
-- PTS 16223 -- BL (end)
  
 -- create one #3 for each status in the profile entry  
          SELECT @start_pos = 1  
          SELECT @charindex = 1  
          WHILE @charindex > 0  
            BEGIN  
  
              SELECT @charindex = CHARINDEX(',',@e214_edi_status,@start_pos)  
If @charindex > 0 and @charindex > @start_pos  
                BEGIN  
                  SELECT @next_status = SUBSTRING(@e214_edi_status,@start_pos,@charindex - @start_pos)  
                  SELECT @start_pos = @charindex + 1  
                END  
              ELSE   
                IF @charindex = 0 and @start_pos <= LEN(@e214_edi_status)  
                  SELECT @next_status = SUBSTRING(@e214_edi_status,@start_pos,LEN(@e214_edi_status))  
                ELSE  
                  BEGIN  
                   SELECT @charindex =  0  
                   BREAK  
                  END  
  
  
              /*  Reset status date under certain circumstances  ###how to indicate cancel  
                  EDI code X1 = arrive at delivery, X2 = estimated arrival at consignee,  
                           X3 = arrive at pickup, AG = estimated deliver, AF = carrier departed pickup  
                           (-X3 our code to indicate a cancel of an X3), CP = completed loading at pickup  
                           X6 = en route to delivery, X9 = delivery appt secured,  
     			 XA = pickup appt secured 
			 AA = Pick up appointment date/time 
      */  
  
   
              SELECT @StatusDateTime =   
                 Case   
      When @e214_activity = 'ARV' and @next_status = '-X3'  
   Then @e214p_dttm  -- cancel prior (est) arrive at pup passed  
      When @e214_activity = 'ARV' and @next_status in ('AG','X1','X2') and @e214_level = 'SH'  
   Then @next_drp_arrivaldate   
      When @e214_activity = 'DEP' and @next_status in ('AG','X1','X2') and @e214_level = 'SH'  
   Then @next_drp_arrivaldate   
                  When @e214_activity = 'APPT' and @next_status in ('X9','XA')   
   Then getdate() -- Appointment secured on this date/time  
      When @e214_activity = 'DSP' and @next_status in ('AG','X1','X2')   
   Then @next_drp_arrivaldate   
      When @e214_activity = 'CKCALL' and @next_status in ('AG','X1','X2')   
   Then @next_drp_arrivaldate -- est arrive at drp FOR CKCALL  
      When @e214_activity = 'ESTA'    
   Then @stp_arrivaldate  
  When @e214_activity = 'DEP'  
   and @e214_level = 'CN'   
   and CHARINDEX('99',@firstlastflags) > 0    
   and @next_status = 'X1'    
   Then @stp_arrivaldate   /* for CTX 9878 depart before arv*/ 
   WHEN @e214_activity = 'ARV' and @next_status = 'PS'			 --PTS 34624
      THEN  ISNULL(@prior_stp_depart,@e214p_dttm)
   When @e214_activity = 'DEP' and @e214_level = 'SH' and @next_status = 'AA' Then @stp_schdtlatest 
    When (@e214_level = 'SH' and @next_status = 'AA') or (@e214_level = 'CN' and @next_status = 'AB') Then @stp_schdtlatest 
      Else   
                       CASE @e214_activity  
                      WHEN  'ARV'   THEN @stp_arrivaldate  
                      WHEN  'DEP'   THEN @stp_departuredate  
                      WHEN  'APT'   THEN @stp_schdtlatest  
        WHEN 'DISP'   THEN @e214p_dttm  
       WHEN 'CKCALL' THEN @e214p_dttm  
                     WHEN 'CAN'    THEN @stp_arrivaldate  
                      ELSE @e214p_dttm  
                   END  
  End  
  
/* PTS 37070 Aross - Additional Conditioning for StatusDateTime */

 SELECT  @trp_prevent_early_dep =  UPPER(ISNULL(trp_214_prevent_early_pup,'N')),
 		    @trp_prevent_early_min =  ISNULL(trp_214_prevent_early_pup_min,0),
 		    @trp_prevent_early_adjustment = ISNULL(trp_214_prevent_early_pup_adj,10)
 FROM		edi_trading_partner
 WHERE	trp_id = @TPNumber
 
 SELECT @schdtEarly_adjusted =  DATEADD(mi, (@trp_prevent_early_min * (-1)),@stp_schdtearliest )
 
IF @trp_prevent_early_dep = 'Y'
BEGIN
	SELECT @StatusDateTime =  CASE
									WHEN @e214_activity = 'DEP' and @e214_level = 'CN' and( @StatusDateTime < @stp_schdtearliest) and (@StatusDateTime > @schdtEarly_adjusted )THEN DATEADD(mi,@trp_prevent_early_adjustment,@stp_schdtearliest)
									ELSE @statusDateTime
									END
END


/*END 37070 */
	

	--49554
	If IsNull(@EDI214UseDestCityForAG,'N') = 'Y' and @next_status = 'AG'
		SELECT @StatusCity = @next_drp_arrivalcity,@stp_sequence = convert(varchar(3),@next_stp_sequence),@stopevent = @next_stp_event

	If IsNull(@EDI214UseDestCityForAG,'N') = 'Y' and @EDI214UseDestCityForAGNextStopEvent <> 'DRP' and @next_status = 'AG'
		SELECT @StatusDateTime = @next_arrivaldate


       -- dash in first pos indicates cancel (hokey, but first pass)  
       IF SUBSTRING(@next_status,1,1) = '-'  
  SELECT @next_status = SUBSTRING(@next_status,2,DATALENGTH(@next_status) - 1)  
              IF LEN(@next_status) > 2    -- ensure status fits in flat file field  
  SELECT @next_status = SUBSTRING(@next_status,1,2)  
  
    
    -- 17519 
  IF @e214_activity ='ESTA'
    BEGIN
     SELECT @UseGPSLocation = isnull(left(gi_string1,1), 'N')
     FROM generalinfo
     WHERE gi_name = 'EDI214GPSLocationForESTA'
    END
    ELSE 
      SELECT @UseGPSLocation = 'N'
  
Declare @DoDispatchCheckCall char(1)
set @DoDispatchCheckCall = 'N'
Declare @Driver varchar(8)
Declare @Carrier varchar(8)
Declare @Tractor varchar(8)
Declare @ckc_date datetime
Declare @ckcAgeHours int
Declare @Testckcnumber int
IF (@e214_activity = 'DISP' and @next_status = 'X6')
BEGIN
	   SELECT @Carrier = ISNULL(lgh_carrier,'UNKNOWN'), @Driver = ISNULL(lgh_driver1,'UNKNOWN'), @Tractor = ISNULL(lgh_tractor,'UNKNOWN') FROM legheader where ord_hdrnumber = @ordhdrnumber 
	   IF @Carrier = 'UNKNOWN' AND @Tractor <> 'UNKNOWN' and @Driver <> 'UNKNOWN'
       BEGIN
		SELECT  TOP 1 @ckc_number = ckc_number, @DoDispatchCheckCall = 'Y'
        FROM checkcall  with (NOLOCK)
		WHERE ckc_asgnid =  @Driver 
		AND ckc_asgntype = 'DRV'
		AND ckc_tractor = @Tractor
		AND ckc_date < DateAdd(hh,1,@StatusDateTime)
		AND ckc_date > DateAdd(DD,-7,@StatusDateTime)
		ORDER BY ckc_date desc
	   END
 END
 
  IF (@e214_activity not in ('CKCALL' ,'ETAX6')) AND (@DoDispatchCheckCall = 'N')
-- PTS 16223 -- BL (start)
--   	EXEC edi_214_record_id_3_39_sp    
--   @next_status,  
--   @StatusDateTime,  
--   @TimeZone,  
--   @StatusCity,   
--   @TractorID,  
--   @MCUnitNumber,  
--   @TrailerOwner,  
--   @Trailerid,  
--   @StatusReason,  
--   @stp_sequence,  
--   @StopWeight,  
--   @StopQuantity,  
--   @StopReferenceNumber,  
--   @ordhdrnumber,  
--   @stopevent,  
--   @stopreasonlate,   
--   @e214_activity,  
--   @docid,
--   @relativemode,
--   @stp_number,
--   @UseGPSLocation
  	EXEC edi_214_record_id_3_39_sp    
  @next_status,  
  @StatusDateTime,  
  @TimeZone,  
  @StatusCity,   
  @TractorID,  
  @MCUnitNumber,  
  @TrailerOwner,  
  @Trailerid,  
  @StatusReason,  
  @stp_sequence,  
  @StopWeight,  
  @StopQuantity,  
  @StopReferenceNumber,  
  @ordhdrnumber,  
  @stopevent,  
  @stopreasonlate,   
  @e214_activity,  
  @docid,
  @relativemode,
  @stp_number,
  @UseGPSLocation,
  @e214_cmp_id
-- PTS 16223 -- BL (end)
ELSE  
                EXEC edi_214_record_id_3_39_ckcall_sp  
    @next_status,  
    @ckc_number,  
    @StatusDateTime,  
    @ordhdrnumber,  
    @docid  ,
    @TPNumber		--PTS# 42315
 END  

  /* add an end of transaction record (never extracted to flat file) */   
     EXEC edi_214_record_id_end_sp @TPNumber,  @docid   

declare @stopedicode varchar(6)
declare @multistoprefflag char(1)

select @multistoprefflag = trp_214_multiStopRefFlag, @stopedicode = ISNULL(edicode,abbr) 
from edi_trading_partner
join labelfile on labeldefinition = 'ReferenceNumbers' and abbr = trp_214_multiStopRefType
where cmp_id=@e214_cmp_id  

-- PTS51916 stop level multiple 214s DWilk
if @multistoprefflag = 'Y'
	exec edi_214_multiplestopref_sp @docid, @stopedicode  
else
     	--add cal to multiple BOL function	   PTS 30182  AROSS
	exec edi_214_multiplebols_sp @ordhdrnumber,@docid  
	
	
 SELECT @min = MIN(e214_triggering_activity+convert(varchar(6),e214_sequence))   
       FROM #profile39  
 WHERE e214_triggering_activity+convert(varchar(6),e214_sequence) > @min  
  
  
 SELECT @min=isnull(@min,'')  
     CONTINUE  
     END   

        
   END   
   
--        VERSION 1.0   
ELSE  
  BEGIN  
 -- either not specified, or version 1.0  
 EXEC edi_214_record_id_1_10_sp @ord_number --which also does id_2 records  
 /* vjh need loop for record 3 for each row that matches the bt, level and status          in the 214_profile  
 */  
 SELECT @e214_id=MIN(e214_id)   
 FROM   edi_214_profile  
 WHERE e214_cmp_id=@e214_cmp_id and  
  e214_level=@e214_level and  
  e214_triggering_activity=@e214p_activity  
  --e214_ps_status=@e214_ps_status  
  
 SELECT @e214_id=isnull(@e214_id,0)  
  
 WHILE @e214_id > 0  
 BEGIN  
  SELECT @e214_edi_status=e214_edi_status,  
   @e214_status_table_version=e214_status_table_version  
  FROM edi_214_profile  
  WHERE e214_id=@e214_id  
   
  if @e214p_activity in ('ARV','ARVDEP')  
  begin  
   -- use arrival time  
   SELECT  
   @StatusDateTime = stp_arrivaldate,  
   @TimeZone = 'LT',  
   @StatusCity = stp_city,  
   @TractorID = evt_tractor,  
   @MCUnitNumber = null,  
   @TrailerOwner = '',  
   @Trailerid =  Case evt_trailer1
					When Null Then stops.trl_id
					When 'UNKNOWN' Then stops.trl_id
					Else evt_trailer1
			     End ,  
   @StatusReason = substring(stp_reasonlate,1,3),  
   @stp_sequence = convert(varchar(3),stp_sequence),  
   @StopWeight = stp_weight,  
   @StopQuantity = stp_count,  
   @StopReferenceNumber = substring(stp_refnum,1,15),  
   @ordhdrnumber = stops.ord_hdrnumber  
   FROM stops,event  
   WHERE stops.stp_number=@stp_number and  
   event.stp_number=@stp_number and evt_sequence=1  
  
   exec edi_214_record_id_3_10_sp   
   @e214_edi_status,  
   @StatusDateTime,  
   @TimeZone,  
   @StatusCity,   
   @TractorID,  
   @MCUnitNumber,  
   @TrailerOwner,  
   @Trailerid,  
   @StatusReason,  
   @stp_sequence,  
   @StopWeight,  
   @StopQuantity,  
   @StopReferenceNumber,  
   @ordhdrnumber  --,  
   --@stopevent,  
   --@stopreasonlate   
  
  end  
  
  IF @e214p_activity in ('DEP','ARVDEP')  
                begin  
   -- use departure time  
   SELECT  
   @StatusDateTime = stp_departuredate,  
   @TimeZone = 'LT',  
   @StatusCity = stp_city,  
   @TractorID = evt_tractor,  
   @MCUnitNumber = null,  
   @TrailerOwner = '',  
   @Trailerid =  Case evt_trailer1
					When Null Then stops.trl_id
					When 'UNKNOWN' Then stops.trl_id
					Else evt_trailer1
			      End,  
   @StatusReason = substring(stp_reasonlate,1,3),  
   @stp_sequence = convert(varchar(3),stp_sequence),  
   @StopWeight = stp_weight,  
   @StopQuantity = stp_count,  
   @StopReferenceNumber = substring(stp_refnum,1,15),  
   @ordhdrnumber = stops.ord_hdrnumber  
   FROM stops,event  
   WHERE stops.stp_number=@stp_number and  
   event.stp_number=@stp_number and evt_sequence=1  
  
   exec edi_214_record_id_3_10_sp   
   @e214_edi_status,  
   @StatusDateTime,  
   @TimeZone,  
   @StatusCity,   
   @TractorID,  
   @MCUnitNumber,  
   @TrailerOwner,  
   @Trailerid,  
   @StatusReason,  
   @stp_sequence,  
   @StopWeight,  
   @StopQuantity,  
   @StopReferenceNumber,  
   @ordhdrnumber  --,  
   --@stopevent,  
   --@stopreasonlate   
  
  end  
  
    
  
-- PTS 16223 -- BL (start)
IF @EDI_Notification_Process_Type = 1
-- PTS 16223 -- BL (end)
  SELECT @e214_id=min(e214_id)   
  FROM edi_214_profile  
  WHERE e214_cmp_id=@e214_cmp_id and  
       e214_level = @e214_level and  
       e214_triggering_activity = @e214p_activity and  
       CHARINDEX(CONVERT(varchar(5),e214_stp_position),@firstlastflags) > 0 AND  
  ISNULL(automail,'N') = 'N'  
   --e214_ps_status=@e214_ps_status and  
   --@e214_id<e214_id  
  
-- PTS 16223 -- BL (start)
IF @EDI_Notification_Process_Type = 2
  SELECT @e214_id=min(e214_id)   
  FROM edi_214_profile  
  WHERE e214_cmp_id=@e214_cmp_id and  
       e214_level = @e214_level and  
       e214_triggering_activity = @e214p_activity and  
       CHARINDEX(CONVERT(varchar(5),e214_stp_position),@firstlastflags) > 0 AND  
  ISNULL(notify_by_edi_flag,'N') = 'Y'   
-- PTS 16223 -- BL (end)

  SELECT @e214_id=isnull(@e214_id,0)  
  continue  
 end -- while loop  
  
   
 --exec edi_214_record_id_5_10_sp 'dummy',@TPNumber  
 --exec edi_214_record_id_6_10_sp 'dummy',@TPNumber  
end  
  
-- PTS 16223 -- BL (start)
Drop table #profile39
Drop table #profile34
-- PTS 16223 -- BL (end)


GO
GRANT EXECUTE ON  [dbo].[auto_214_sp] TO [public]
GO
