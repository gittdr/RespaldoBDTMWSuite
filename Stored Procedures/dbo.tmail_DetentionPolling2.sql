SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_DetentionPolling2] @HrsToCheckDetention int, @MakeNextStopCheck char(1) , @optionalStop varchar(13)='default'

AS
/**
 *
 * NAME:
 * dbo.tmail_DetentionPolling2
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure checks each open stop to see if and actions need to be
 * taken for the detention alerting system.
 *
**************************************************************************
* 01/19/04 MZ: Created
* 08/09/13 HMA: Renamed to tmail_DetentionPolling2
* Stored proc that is to be scheduled to execute every minute.  It will look
*  for stops that have arrived but not departed, and the max detention time
*  stored in stops.stp_alloweddet or company.cmp_maxdetmins has been exceeded,
*  and will create a TotalMail message asynchronously if configured to do so.
* 
* Parameters:
* @HrsToCheckDetention - 0, pull all records that may need a detention alert
*						 > 0 - the number of hours to check for detention alerts.
*
* @MakeNextStopCheck - Y - check if next stop's arrival status is actualized,
*							if it is, don't send an alert for this stop.
*					   N - don't look at next stops arrival status.	
*
* @optionalStop          you can specify a stop_number which  if stop is found, 
*                        a row of 2 ints - detentionNow and detentionMax - will be returned
*       IMPORTANT NOTE on 3rd parameter: NO TMSQLMESSAGE row will be inserted. This 3rd parameter will STOP THAT FROM HAPPENING.
**************************************************************************
 * RETURNS:
 * IF 3rd option is used and stop is found, a row of 2 ints - detentionNow and detentionMax
 * returns NOTHING if 3rd parameter isnt used or is value 'default'
 *
 * RESULT SETS:
 * none
 *
 * PARAMETERS:
 * 001 - @HrsToCheckDetention int - 168 (one week) is a good starting value
 *       This limits how far back to look for open stops
 * 002 - @MakeNextStopCheck char(1) - 'Y' indicates that an arrival at the
 *       next stop indicated a departure at this stop
 * 003 - @optionalStop varchar(13)- new optional parameter. you can specify a stop_number which if stop is found, 
 *       a row of 2 ints - detentionNow and detentionMax - will be returned 
 *       IMPORTANT NOTE: NO TMSQLMESSAGE row will be inserted. This 3rd parameter will STOP THAT FROM HAPPENING.     
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 * 2/12/04 -- LOOK FOR *DM* FOR CHANGES
 * Added concept of @LookNMinutesEarly to see if GPS data indicates stop really occured
 * This calls additional Proc named tmail_DetentionPolling_CheckGPSHistory
 *
 * vjh 26547 changing the flow
 * old flow
 * 0 - Green (no arrival, or arrival and no detnetion, or departure and no detention)
 * 2 - Red (active detention)
 * 1 - Yellow (detention occured but departure actualized)
 *
 * new flow
 * 0 - Gray (no arrival)
 * 1 - Green (Arrival but no departure and no detention)
 * 2 - Yellow (arrival, but past alert minutes)
 * 3 - Red (Active detention (arrival but past det mins)
 * 0 - Gray (departure)
 *
 * 08/29/2005.01 - PTS29527 - Vince Herman
 * 12/21/2005.01 - PTS31028 - Bryan Levon -- Make PROC run more efficiently
 * 07/19/2006.01 - PTS33812 - Vince Herman - fix time zone logic
 * 09/11/2007.01 - PTS33942 - vjh - add logic to send message when changing from green (or gray) to red
 * 03/11/2008.01 - PTS41723 - vjh - add debug code
 * 10/21/2008.01 - PTS44859 - vjh - add more debug code
 * 06/10/2010	 - PTS52781 - vjh - bug fix for sapearliest when no sap events exist
 *
 * 08/08/2013	 - PTS67826 - hma - expanding insertions into tblSQLmessagedata table
 *								- also added in SQL to create @TO field and retrieve cmp_detcontacts from Company
 *								- added in SQL to create @ord_number and retreive it as well
 *								- added in SQL to pull DetminMax value 
 *								- added 3rd parameter to calculate Detention Numbers for a specified stop
 *       IMPORTANT NOTE on 3rd parameter: NO TMSQLMESSAGE row will be inserted. This 3rd parameter will STOP THAT FROM HAPPENING.
 * 08/09/2013    - PTS67826 - HMA this proc renamed to tmail_DetentionPolling2 
 *                           and tmail_DetentionPolling now just calls tmail_DetentionPolling2 WITHOUT 3rd param
 * 12/16/2013.01 - PTS74187 - vjh chicking in HMA 67826/73535
 **/
SET NOCOUNT ON
--CREATE TABLE #tzwork (WorkDate DateTime)
-- PTS 31028 -- BL (start)
CREATE TABLE #stop_numbers (
	stp_number 		INT			NULL)
-- PTS 31028 -- BL (end)

DECLARE @stp_number int,
		@DetMinsMax int,
		--@tmpdate datetime,
		@dmgpstmpdate datetime,
		@TMFormId int,
		@trc varchar(15),
		@cmp_id varchar (10),
		@arvdate datetime,
		@SysTZ int,
		@SysTZMins int,
		@MakeTZAdjusts char(1),
		@SysDSTCode int,
		@DestTZ int,
		@DestTZMins int,
		@DestDSTFlag char(1),
		@DestDSTCode int, 
		@DetMins int,
		@AlertMins int,
		@mov_number int,
		@stp_mfh_sequence int,
		@CheckDetention char(1),
		@detstart int,
		@detapplyiflate char(1),
		@detapplyifearly char(1),
		@detsendalert char(1),
		@sapearliest datetime,
		@saplatest datetime,
		@stpearliest datetime,
		@stplatest datetime,
		@stparrival datetime,		/* 01/31/2013 MDH PTS 60764: added */
		@stopislate char(1),
		@stopisearly char(1),
		@priordetstatus int,
		@sendmessage char(1),
		@debugstopnumber int,
		@debugstopnumberstring varchar(20),
		@debugsequence int,
		@alertonalertandwarn char(1),
		@errmsg varchar(254),
		@errbatch int, 
		@now	datetime, 
		@detcheck datetime
--Declare @ChangeTZCall varchar(1024)

-- pts 67826
DECLARE @To varchar(1000), 
		@ord_number varchar(20),
		@ord_hdrnumber varchar(20),
		@indentKey int ,
		@Our_Stp_number int
		set @Our_Stp_number=-1
-- end pts 67826






declare @useLatestStopTimeAlways char(1)
select @useLatestStopTimeAlways = ISNULL(gi_string1, 'N')
from generalinfo
where gi_name = 'Det_UseLatestStopTimeAlways'

-- *DM* Start
Declare @LookNMinutesEarly Int
Declare @tmpdate2 DateTime
declare @GPSHistoryIndicatesStopOccuredYN char(1)
declare @return_number_checkGPS int

SELECT @LookNMinutesEarly = ISNULL(gi_integer1,0)
FROM generalinfo
WHERE gi_name = 'TMail_Det_LookNMinutesEarly'
-- END *DM*

SELECT @debugstopnumberstring = gi_string1
FROM generalinfo
WHERE gi_name = 'TMail_Det_debugstopnumber'
if @debugstopnumberstring is null set @debugstopnumberstring = '0'
select @debugstopnumber = cast(@debugstopnumberstring as int)
if @debugstopnumber <> 0 begin
	select @errbatch = max(err_batch) from tts_errorlog
	if @errbatch is null set @errbatch = 0
	select @errbatch = @errbatch + 1
	set @debugsequence = 1
	set @errmsg = 'Detention debug on stop ' + @debugstopnumberstring
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
end


SELECT @alertonalertandwarn = gi_string1
FROM generalinfo
WHERE gi_name = 'TMail_Det_alertonalertandwarn'
if @alertonalertandwarn is null set @alertonalertandwarn = 'N'
set @alertonalertandwarn = upper(left(@alertonalertandwarn,1))

SET @MakeTZAdjusts = 'N'
SET @SysTZ = -15
SET @SysTZMins = 0
SET @SysDSTCode = 0
SET @DestTZ = -15
SET @DestTZMins = 0
SET @DetMins = 0
SET @AlertMins = 0
SET @TMFormId = 0

SELECT @TMFormId = ISNULL(gi_integer1,0)
FROM generalinfo
WHERE gi_name = 'TMail_Det_Form'

-- Check if we should use multi-timezone processing
SELECT @MakeTZAdjusts = UPPER(ISNULL(gi_string1, 'N'))
FROM generalinfo 
WHERE gi_name = 'MakeTZAdjustments'

IF @MakeTZAdjusts = 'Y'
  BEGIN
	SELECT @SysTZ =	ISNULL(CONVERT(int, gi_string1), -15)
	FROM generalinfo 
	WHERE gi_name = 'SysTZ'

	SELECT @SysTZMins = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to no additional minutes
	FROM generalinfo 
	WHERE gi_name = 'SysTZMins'

	SELECT @SysDSTCode = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to no DST
	FROM generalinfo 
	WHERE gi_name = 'SysDSTCode'
  END

-- Do we have enough valid info to do multi-timezone processing?
IF @MakeTZAdjusts = 'Y' AND (@SysTZ < -12 OR @SysTZ > 8)
	SET @MakeTZAdjusts = 'N'	

--vjh 26457 remove the 'stp_detstatus=0' from where clause
--vjh 29527 optimize where clause
SET @stp_number = 0
--pts 67826 HMA 8/12/13 **********************************************************************
-- neither 'default' nor an empty string will be numeric!
if ISNUMERIC(@optionalStop)=1
	begin
	set @Our_Stp_number= CONVERT(int,@optionalStop)
	set @stp_number= @Our_Stp_number 
	INSERT INTO #stop_numbers
			SELECT @stp_number
	end
	-- we're done - insert one stop number and lets go to that while loop!
ELSE 
--else do your normal calculations for pulling out the right Stop Number
BEGIN
	IF (@HrsToCheckDetention > 0) 
		BEGIN
		IF (UPPER(@MakeNextStopCheck) = 'Y')
	-- PTS 31028 -- BL (start)
	--		SELECT @stp_number = ISNULL(MIN(stp_number),0)
			INSERT INTO #stop_numbers
			SELECT ISNULL(stp_number, 0)
	-- PTS 31028 -- BL (end)
			FROM stops inner join legheader_active on stops.lgh_number = legheader_active.lgh_number
			WHERE	stp_status = 'DNE' 
				AND ((stp_departure_status = 'OPN') or (stp_departure_status is null))
				AND (stops.ord_hdrnumber IS NOT NULL)
				AND stops.ord_hdrnumber > 0
				AND stp_arrivaldate > DATEADD(hh, -@HrsToCheckDetention, GETDATE())
		ELSE
	-- PTS 31028 -- BL (start)
	--		SELECT @stp_number = ISNULL(MIN(stp_number),0)
			INSERT INTO #stop_numbers
			SELECT ISNULL(stp_number, 0)
	-- PTS 31028 -- BL (end)
			FROM stops
			WHERE	stp_status = 'DNE' 
				AND ((stp_departure_status = 'OPN') or (stp_departure_status is null))
				AND (stops.ord_hdrnumber IS NOT NULL)
				AND stops.ord_hdrnumber > 0
				AND stp_arrivaldate > DATEADD(hh, -@HrsToCheckDetention, GETDATE())
		END
	ELSE
		BEGIN
		IF (UPPER(@MakeNextStopCheck) = 'Y')
	-- PTS 31028 -- BL (start)
	--		SELECT @stp_number = ISNULL(MIN(stp_number),0)
			INSERT INTO #stop_numbers
			SELECT ISNULL(stp_number, 0)
	-- PTS 31028 -- BL (end)
			FROM stops inner join legheader_active on stops.lgh_number = legheader_active.lgh_number
			WHERE	stp_status = 'DNE' 
				AND ((stp_departure_status = 'OPN') or (stp_departure_status is null))
				AND (stops.ord_hdrnumber IS NOT NULL)
				AND stops.ord_hdrnumber > 0
		ELSE
	-- PTS 31028 -- BL (start)
	--		SELECT @stp_number = ISNULL(MIN(stp_number),0)
			INSERT INTO #stop_numbers
			SELECT ISNULL(stp_number, 0)
	-- PTS 31028 -- BL (end)
			FROM stops
			WHERE	stp_status = 'DNE' 
				AND ((stp_departure_status = 'OPN') or (stp_departure_status is null))
				AND (stops.ord_hdrnumber IS NOT NULL)
				AND stops.ord_hdrnumber > 0
		END













	if @debugstopnumber <> 0 begin
		if exists (select 1 from #stop_numbers where stp_number = @debugstopnumber) begin
			set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + ' is in list of stops to process.'
		end else begin
			set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + ' is NOT in list of stops to process.'
		end
		exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
		select @debugsequence = @debugsequence + 1
	end
END -- pts67826 *******************************************************************

-- PTS 31028 -- BL (start)
SELECT @stp_number = ISNULL(MIN(stp_number),0)
FROM #stop_numbers
-- PTS 31028 -- BL (end)

WHILE @stp_number > 0
  BEGIN
	SET @CheckDetention = 'Y'		

	-- Get some info about this stop
	SELECT  @stparrival = stops.stp_arrivaldate,		/* 01/31/2013 MDH PTS 60764: Changed to stop arrival date */
		@cmp_id = stops.cmp_id,
		@DetMins = case stp_type
			when 'PUP' then
			ISNULL(
				ISNULL(
					ISNULL(
						(SELECT MIN(cmp_puptimeallowance) 
							FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
							WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
						(SELECT cmp_puptimeallowance 
							FROM company WHERE company.cmp_id = stops.cmp_id)),
					(select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionPUPMinsAllowance') ),
				-1)
			else
			ISNULL(
			ISNULL(
					ISNULL(
						(SELECT MIN(cmp_drptimeallowance) 
							FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
							WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
						(SELECT cmp_drptimeallowance 
							FROM company WHERE company.cmp_id = stops.cmp_id)),
					(select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionDRPMinsAllowance') ),
				-1)
			end,
		@AlertMins = case stp_type
			when 'PUP' then
			ISNULL(
				ISNULL(
					ISNULL(	
						stops.stp_alloweddet, 
						ISNULL(
							(SELECT MIN(cmp_PUPalert) 
								FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
								WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
							(SELECT cmp_PUPalert 
								FROM company WHERE company.cmp_id = stops.cmp_id))
						),
					(select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionPUPMinsAlert') ),
				-1)
			else
			ISNULL(
				ISNULL(
					ISNULL(
						stops.stp_alloweddet, 
						ISNULL(
							(SELECT MIN(cmp_DRPalert) 
								FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
								WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
							(SELECT cmp_DRPalert 
								FROM company WHERE company.cmp_id = stops.cmp_id))
						),
					(select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionDRPMinsAlert') ),
				-1)
			end,
		@mov_number = mov_number,
		@stp_mfh_sequence = stp_mfh_sequence,
		@detstart = ISNULL(
					(SELECT MIN(cmp_det_start) 
						FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
						WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
					ISNULL(
						(SELECT cmp_det_start 
							FROM company WHERE company.cmp_id = stops.cmp_id),
					ISNULL((select top 1 gi_integer1 from generalinfo where gi_name = 'Det_StartFromValue'),
						0)
					)
				),
		@detapplyiflate = ISNULL(
					(SELECT MIN(cmp_det_apply_if_late) 
						FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
						WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
					ISNULL(
						(SELECT cmp_det_apply_if_late 
							FROM company WHERE company.cmp_id = stops.cmp_id),
						'N'
					)
				),
		@detapplyifearly = ISNULL(
					(SELECT MIN(cmp_det_apply_if_early) 
						FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
						WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
					ISNULL(
						(SELECT cmp_det_apply_if_early 
							FROM company WHERE company.cmp_id = stops.cmp_id),
						'N'
					)
				),
		@detsendalert = ISNULL(
					(SELECT MIN(cmp_senddetalert) 
						FROM company INNER JOIN orderheader ON orderheader.ord_billto = company.cmp_id 
						WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
					ISNULL(
						(SELECT cmp_senddetalert 
							FROM company WHERE company.cmp_id = stops.cmp_id),
						'N'
					)
				),
		@stpearliest = stp_schdtearliest,
		@stplatest = stp_schdtlatest,
		@priordetstatus = stp_detstatus
	FROM stops
	WHERE stp_number = @stp_number
--select ord_hdrnumber,@stp_number 'stop number', @AlertMins 'alert mins', @DetMins 'det mins' from stops where stp_number=@stp_number
	--vjh 25149 get the scheduled appointment times from the event
	--vjh 52781 - clear out value from last leg
	set @sapearliest = null
	select	@sapearliest = evt_earlydate,
		@saplatest =  evt_latedate
	from event 
	where stp_number=@stp_number and
		evt_sequence = (select max(evt_sequence)
					from event
					where stp_number=@stp_number
						and evt_eventcode='SAP')
	If @sapearliest is null begin
		set @sapearliest = @stpearliest
		set @saplatest = @stplatest
	end

if @debugstopnumber = @stp_number begin
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @stparrival=' + cast(@stparrival as varchar(20))
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @cmp_id=' + @cmp_id
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @DetMins=' + cast(@DetMins as varchar(20))
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @AlertMins=' + cast(@AlertMins as varchar(20))
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @detstart=' + cast(@detstart as varchar(20)) + ' (1-Arrival 2-Earliest(stop) 3-Sched Appointment(SAP event))'
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @detapplyiflate=' + cast(@detapplyiflate as varchar(20))
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @detapplyifearly=' + cast(@detapplyifearly as varchar(20))
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @detsendalert=' + cast(@detsendalert as varchar(20))
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @stpearliest=' + cast(@stpearliest as varchar(20))
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @stplatest=' + cast(@stplatest as varchar(20))
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @sapearliest=' + cast(@sapearliest as varchar(20))
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
	set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @stplatest=' + cast(@stplatest as varchar(20))
	exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
	select @debugsequence = @debugsequence + 1
end


	IF (UPPER(@MakeNextStopCheck) = 'Y')
		-- Check if the next stops arrival has already actualized.  If so, then a detention alert does not apply (if configured)
		SET @trc = ''
		SELECT  @trc = ISNULL(legheader.lgh_tractor, '')
		FROM legheader, stops
		WHERE stops.stp_number = @stp_number
			AND stops.lgh_number = legheader.lgh_number				
		IF EXISTS (
			SELECT * FROM stops inner join legheader_active on stops.lgh_number = legheader_active.lgh_number 
			WHERE stp_arrivaldate > @stparrival AND stp_status = 'DNE' and lgh_tractor = @trc and @trc <> 'UNKNOWN') begin
				SET @CheckDetention = 'N'
				if @debugstopnumber = @stp_number begin
					set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. Next stop actualized. Detention not applicable on this stop.'
					exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
					select @debugsequence = @debugsequence + 1
				end
			end
	IF (@CheckDetention = 'Y')	-- Don't bother doing any more processing if @MakeNextStopCheck is on and the next stops arrival is actualized.
	  BEGIN
		IF (@MakeTZAdjusts = 'Y')
		BEGIN
			-- Get the timezone info for this city
			SELECT  @DestTZ = ISNULL(city.cty_GMTDelta, -15),
					@DestDSTFlag = ISNULL(city.cty_DSTApplies, 'N'),
					@DestTZMins = ISNULL(city.cty_TZMins, 0)
			FROM city, company
			WHERE company.cmp_id = @cmp_id
				AND company.cmp_city = city.cty_code

			-- TODD - How do we handle this?
			IF @DestDSTFlag = 'Y'
				SET @DestDSTCode = 0
			ELSE 
				SET @DestDSTCode = -1

			-- Check if we have enough info for this company to use multi-timezone processing
			IF (@DestTZ > -13 AND @DestTZ < 9)
			BEGIN
				/* 01/31/2013 MDH PTS 60764: Commented out this code, DELETE #tzwork -- vjh 33812
				SELECT @ChangeTZCall = 'SELECT dbo.ChangeTZ (CONVERT(datetime, '''+ CONVERT(varchar(50), @tmpdate) + '''), '+ CONVERT(varchar(10), @DestTZ) + ', '+ CONVERT(varchar(10), @DestDSTCode) +', '+ CONVERT(varchar(10), @DestTZMins) +', '+ CONVERT(varchar(10), @SysTZ) +', '+ CONVERT(varchar(10), @SysDSTCode) +', '+ CONVERT(varchar(10), @SysTZMins) +')'
				INSERT INTO #tzWork (WorkDate)
				EXEC (@ChangeTZCall)
				SELECT @tmpdate = ISNULL(MIN(WorkDate), @tmpDate) FROM #tzWork */
				-- Convert local time into destination time. 
				SELECT @now = dbo.changetz (GetDate(), @SysTZ, @SysDSTCode, @SysTZMins, @DestTZ, @DestDSTCode, @DestTZMins)
				if @debugstopnumber = @stp_number begin
					set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. TimeZone calcs shifted current time to ' + cast(@now as varchar(20))
					exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
					select @debugsequence = @debugsequence + 1
				end
			END
			ELSE
				select @now = GETDATE()
		END
		ELSE
			select @now = GETDATE()
		
		set @stopislate = 'N'
		set @stopisearly = 'N'

		--vjh 25149 @destart 1-Arrival 2-Earliest(stop) 3-Sched Appointment(SAP event), 4 = latest
		--use the later of the earliest and actual
		if @detstart = 1 SET @detcheck = @stparrival
		If @detstart = 2 begin
			SET @detcheck = @stpearliest
			If @stparrival < @stpearliest and @detapplyifearly = 'N' set @stopisearly = 'Y'
			If @stparrival > @stpearliest set @detcheck = @stparrival 
			If @stparrival > @stplatest and @detapplyiflate = 'N' set @stopislate = 'Y'
		end
		If @detstart = 3 begin
			set @detcheck = @saplatest
			If @stparrival < @stpearliest and @detapplyifearly = 'N' set @stopisearly = 'Y'
			If @stparrival > @sapearliest set @detcheck = @sapearliest
			If @stparrival > @saplatest and @detapplyiflate = 'N' set @stopislate = 'Y'
		end
		--avane 59743 @detstart 4-Latest(stop) 
		if @detstart = 4 begin
			If @stparrival < @stpearliest and @detapplyifearly = 'N' set @stopisearly = 'Y'
			If @useLatestStopTimeAlways = 'N' begin
				If @stparrival < @stplatest 
					set @detcheck = @stplatest
				ELSE
					set @detcheck = @stparrival 
			end
			If @useLatestStopTimeAlways = 'Y' begin
				set @detcheck = @stplatest
			end
			If @stparrival > @stplatest and @detapplyiflate = 'N' set @stopislate = 'Y'		
		end

		if @debugstopnumber = @stp_number begin
			set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. Early/Late calcs @detcheck=' + cast(@detcheck as varchar(20))
			exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
			select @debugsequence = @debugsequence + 1
			set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. Early/Late calcs @stopisearly=' + @stopisearly
			exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
			select @debugsequence = @debugsequence + 1
			set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. Early/Late calcs @stopislate=' + @stopislate
			exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
			select @debugsequence = @debugsequence + 1
		end

		--SET @arvdate = @tmpdate
		SET @dmgpstmpdate = DATEADD(mi, @DetMins, @detcheck)	-- Add the number of allowable detention minutes to the datetime

		--*DM*
		-- If Look early and not already too late
		Set @GPSHistoryIndicatesStopOccuredYN='N'
		IF ( ( @LookNMinutesEarly>0 ) and NOT (  ( (@now > @dmgpstmpdate) AND (@dmgpstmpdate <> @arvdate) ) ) )
		BEGIN
			SET @tmpdate2 = DATEADD(mi, -@LookNMinutesEarly, @dmgpstmpdate)	-- Subtract them to get new date 
			IF ((@now > @tmpdate2) AND (@tmpdate2 <> @arvdate))
			BEGIN
				EXECUTE @return_number_checkGPS = tmail_DetentionPolling_CheckGPSHistory @stp_number, @cmp_id,0 --Last parm @ShowDetail
				if (@return_number_checkGPS >0 ) Set @GPSHistoryIndicatesStopOccuredYN='Y'
				-- -1 Means no lat/long could be found for the STOP to do the mileage calc
				-- -2 found no checks at all. 
				-- -3 Found arrival, Pinging is on and has been done
				-- > if greater 10 (10 is min air miles raidus) then # of airmiles PAST the destination
			END
		END
		--END *DM*
		select @sendmessage = 'N' --vjh 33942
		IF (@now > DATEADD(mi, @DetMins, @detcheck) AND
			(@DetMins <> -1) AND -- don't alert if -1 minutes allowed
			(@GPSHistoryIndicatesStopOccuredYN='N') AND
			(@stopislate='N') AND
			(@stopisearly='N'))
		  BEGIN -- Active detention - update to 3 (red)
			UPDATE stops
			SET stp_detstatus = 3
			WHERE stp_number = @stp_number and isnull(@priordetstatus,0) <> 3
			if @debugstopnumber = @stp_number begin
				set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. Active detention - update to 3 (red).'
				exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
				select @debugsequence = @debugsequence + 1
			end
			if isnull(@priordetstatus,0) <> 2 and isnull(@priordetstatus,0) <> 3 select @sendmessage = 'Y' --vjh 33942
		  END
		ELSE IF ((@now > DATEADD(mi, @AlertMins, @detcheck)) AND
			(@AlertMins <> -1) AND -- don't alert if -1 minutes allowed
			(@GPSHistoryIndicatesStopOccuredYN='N') AND
			(@stopislate='N') AND
			(@stopisearly='N'))
		  BEGIN -- Alert - update to 2 (yellow)
			UPDATE stops
			SET stp_detstatus = 2
			WHERE stp_number = @stp_number and isnull(@priordetstatus,0) <> 2
			if @debugstopnumber = @stp_number begin
				set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. Alert - update to 2 (yellow).'
				exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
				select @debugsequence = @debugsequence + 1
			end
			if isnull(@priordetstatus,0) <> 2 and isnull(@priordetstatus,0) <> 3 select @sendmessage = 'Y' --vjh 33942
			 --vjh 33942 move the inserts to lower so that it is available for both red and yellow
		  END
		ELSE
		  BEGIN	-- Arrived - update to 1 (green)
			if @priordetstatus is not null and @priordetstatus <> 1
			UPDATE stops
			SET stp_detstatus = 1, skip_trigger=1
			WHERE stp_number = @stp_number 
			if @debugstopnumber = @stp_number begin
				set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. Arrived - update to 1 (green).'
				exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
				select @debugsequence = @debugsequence + 1
			end
		  END

		if @debugstopnumber = @stp_number begin
			set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @sendmessage=' + cast(@sendmessage as varchar(20))
			exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
			select @debugsequence = @debugsequence + 1
			set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @priordetstatus=' + cast(@priordetstatus as varchar(20))
			exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
			select @debugsequence = @debugsequence + 1
			set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @TMFormId=' + cast(@TMFormId as varchar(20))
			exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
			select @debugsequence = @debugsequence + 1
			--set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. @detsendalert=' + cast(@detsendalert as varchar(20))
			--exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
			--select @debugsequence = @debugsequence + 1
		end


	-- HMA 1/16/14 commented this line out:	if @sendmessage = 'Y' begin --vjh 33942
			--IF (@TMFormId > 0) vjh 26457 only send message if feature is on
			-- and only if we are changing it from anything else to 2 (yellow)
			-- or if going to red from green or gray  --vjh 33942
			IF (@TMFormId > 0) and @detsendalert = 'Y'
			  BEGIN
				-- Get the tractor
				SET @trc = ''
				SELECT  @trc = ISNULL(legheader.lgh_tractor, '')
				FROM legheader, stops
				WHERE stops.stp_number = @stp_number
					AND stops.lgh_number = legheader.lgh_number
					
				-- start pts 67826 *******************************************************************************
				-- get the cmp_detcontacts aka @To
				select	@To = 
					ISNULL(
						ISNULL(
							(SELECT MIN(cmp_detcontacts) 
								FROM company (NOLOCK)
								INNER JOIN orderheader (NOLOCK) ON orderheader.ord_billto = company.cmp_id 
								WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
							(SELECT cmp_detcontacts 
								FROM company (NOLOCK)
								WHERE company.cmp_id = stops.cmp_id)
							),
						''
						)
				FROM stops(NOLOCK)
				WHERE stp_number = @stp_number	
				
				-- Get the order number
				SELECT @ord_number = ISNULL(ord_number,0)
				FROM orderheader inner join stops (NOLOCK)  
				on orderheader.ord_hdrnumber = stops.ord_hdrnumber
				WHERE stops.stp_number  = @stp_number 
				
				--Get the ord_HDRnumber too
				SELECT @ord_hdrnumber = ISNULL(MIN(ord_hdrnumber),0)
				FROM orderheader (NOLOCK)  
				WHERE ord_number = @ord_number
					
				-- pull the Minutes Max
				select @DetMinsMax = case stp_type
				when 'PUP' then
				ISNULL(
					ISNULL(
						stops.stp_alloweddet, 
						ISNULL(
							(SELECT MIN(cmp_PUPTimeAllowance) 
								FROM company  (NOLOCK)
								INNER JOIN orderheader (NOLOCK) ON orderheader.ord_billto = company.cmp_id 
								WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
							(SELECT cmp_PUPTimeAllowance 
								FROM company (NOLOCK)
								WHERE company.cmp_id = stops.cmp_id)
							)
						),
					0
					)
				ELSE
					ISNULL(
					ISNULL(
						stops.stp_alloweddet, 
						ISNULL(
							(SELECT MIN(cmp_DRPTimeAllowance) 
								FROM company (NOLOCK)
								INNER JOIN orderheader (NOLOCK) ON orderheader.ord_billto = company.cmp_id 
								WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
							(SELECT cmp_DRPTimeAllowance 
								FROM company (NOLOCK)
								WHERE company.cmp_id = stops.cmp_id)
							)
						),
					0
					)

				end 
				FROM stops(NOLOCK)
					WHERE stp_number = @stp_number

			if @stp_number= @Our_Stp_number 
				BEGIN
						
				SELECT  --@To "To", 
						--@DetMins DetMinsNow, --1/16/14 HMA changed from @detMins to datediff
						DATEDIFF(mi,@detcheck,@now) DetMinsNow,
						@DetMinsMax DetMinsMax 
						--@ord_hdrnumber OrderHdrNumber,
						--@cmp_id CompanyId,
						--@ord_number OrderNumber,
						--@stp_number StopNumber
											
				END
			ELSE
				IF @sendmessage = 'Y' begin -- because earlier I allowed us into this section with a possible 'N'
				-- end pts 67826 *******************************************************

				INSERT TMSQLMessage (msg_date, 
						msg_FormID, 
						msg_To, 
						msg_ToType, 
						msg_FilterData,
						msg_FilterDataDupWaitSeconds, 
						msg_From, 
						msg_FromType, 
						msg_Subject)
				VALUES (GETDATE(), 
						@TMFormId, 
						@trc, 
						9, 				--type 4 tractor
						@trc + convert(varchar(5),@TMFormId) + CONVERT(varchar(15),@stp_number), --filter duplicate rows
						5, 			--wait 5 seconds
						'Admin',
						0, 				--0 who knows
						'Detention Warning for stop (' + CONVERT(varchar(12),@stp_number) + ') at (' + @cmp_id + ')')

				Set @indentKey = @@IDENTITY
				INSERT TMSQLMessageData (msg_ID, 
						msd_Seq, 
						msd_FieldName, 
						msd_FieldValue)
				VALUES (@indentKey, 
						1, 
						'StopNumber', 
						@stp_number)	
						
				INSERT TMSQLMessageData (msg_ID, 
						msd_Seq, 
						msd_FieldName, 
						msd_FieldValue)
				VALUES (@indentKey, 
						2, 
						'companyID', 
						@cmp_id )	
						
				INSERT TMSQLMessageData (msg_ID, 
						msd_Seq, 
						msd_FieldName, 
						msd_FieldValue)
				VALUES (@indentKey, 
						3, 
						'ordernumber', 
						@ord_number)	
						
				end

				if @debugstopnumber = @stp_number begin
					set @errmsg = 'Detention debug. Stop ' + @debugstopnumberstring + '. Message sent.'
					exec tmw_log_error_short_sp @errbatch, @errmsg ,@debugsequence, @debugstopnumberstring
					select @debugsequence = @debugsequence + 1
				end
			  END  -- Is @TMFormID > 0 (create TotalMail message)?
		-- HMA 1/16/14 commented this END out: END
	  END	-- @CheckDetention = 'Y'?

-- PTS 31028 -- BL (start)
		SELECT @stp_number = ISNULL(MIN(stp_number),0)
		FROM #stop_numbers
		WHERE stp_number > @stp_number
-- 	-- Get the next stop to process
  END

-- PTS 31028 -- BL (start)
drop table #stop_numbers
GO
GRANT EXECUTE ON  [dbo].[tmail_DetentionPolling2] TO [public]
GO
