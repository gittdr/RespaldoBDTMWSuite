SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[monitor_214_sp] AS

	/*
	* 
	* NAME:
	* dbo.monitor_214_sp
	*
	* TYPE:
	* StoredProcedure
	*
	* DESCRIPTION:
	* This procedure deletes note data for the specified
	* registration.
	*
	* RETURNS:
	* NONE
	*
	* RESULT SETS: 
	* none.
	*
	* PARAMETERS:
	* NONE
	*
	*
	* REFERENCES: (called by and calling references only, don't 
	*              include table/view/object references)
	* Calls001    ? Name of Proc / Function Called
	* Calls002    ? Name of Proc / Function Called
	* CalledBy001 ? Name of Proc / Function That Calls Me 
	* CalledBy002 ? Name of Proc / Function That Calls Me 

	* 
	* REVISION HISTORY:
	* 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
	*  dpete 4/3/00 add activity, earlyorlate to parms passed pts 7526
	*	dpete 7/5/00 allow multiple statuses per profile entry
	*  DPETE 7/19/00 Create 214 pending records on a regular basis FROM the 
	*      edi_location_tracking table (orders being tracked and date/time to be reported).
	*  dpete 9571 add qualifications to SELECTing most recent checkcall per M Zerefos
	*        directions
	*   jack 2/5/01 add scripts to create records in cmpemailmsg table
	*        Assumptions
	*            1. Orders for partners wanting ckcall reporting will be placed in the
	*               edi_locaiton_tracking table when the status changes to STD (see ut_ord
	*               trigger).  Orders are removed when the trip is complete (either staus
	*               changes FROM STD to something else in ut_ord or no open stops can be
	*               found for that order in this stored proc.
	*            2. The most current location for a tractor may be determined FROM the
	*               checkcall table (with tractor,ckc date index)
	*  dpete 7/30/01 pts 11600 eliminate dup fax numbers between different companies
	*  DPETE PTS15046 allow a way to not use cmp_faxphone for EDI
	*  DPETE PTS 15838 8/20/02 Do not send out ESTA unless trip is started.  Cod eis here rather than in ut_stops
	*      because uncommitted stops status are not visible in the trigger.  Thus if you complet the 
	*      first pup and change the arrival on a drop in a single update the trigger for the change in datetime
	*      cannot see the completed stop status
	*  DPETE 16313 Chrysler wants one set of 214 per delivery on depart pickup
	*  NKRES 16407 AG special handling should use arrival at first subsequent drop instead of strictly first drop
	*  BLEVON 16419 -- Allow for 2nd Mail format
	*  BLEVON 16223 -- 5/21/03 -- Allow for 'Company' based notification process
	*  09/06/2005.01 PTS29686 -  A. Rossman - Correction to checkcall processing logic.  Error was occurring when there
	*								was an ord_number with an alpha-numeric value.(Ex. From LTSL update logic)
	*  04/03/2006.02 PTS32401 -  A.Rossman - Added call to custom auto 214 preprocess.
	* 06/08/2007.03 PTS37848 - A. Rossman - Added update to next location report record when trips are unassigned to prevent a backlog in location reporting.
	* 08/30/2007.04 PTS34624 - A. Rossman -  Altered ESTA logic for determining trip status.
	* 04/09/2008.05 PTS42315 - A. Rossman - Check legheader status for location reporting.
	* 08/13/2008.06 PTS 43636 - A. Rossman - Verify stop number before continuing auto 214 process.
	* 04/15/2009.07 PTS 45681 - A.Rossman - Carrier based checkcall location reporting
	* 02/26/2010.08 PTS 49961 - A.Rossman - Allow ETA Messages for non-started orders.
	* 02/26.2010.09 PTS 50029 - A.Rossman - Restrict 214 message creation by terms when enabled for TP
	* 03/15/2010.10 PTS 51194 - A.Rossman - Fix for carrier based location reporting. limit checkcalls to current legheader.
	* 04/28/11  PTS 56836 DPETE - Celedon requests sending out the 214 location report even if the truck has not moved for an active trip.
	*           New GI setting EDI214  (extra add NONLOCK s for MIndy)
	* 01/17/2013.12 PTS 66652 - Use current system date/time when reporting location for a resource that is parked.
	* 07/25/2013.13 PTS 71092 - Allow for UNKNOWN drivers on checkcall when allowed by GI setting EDI214RequireDriverMatchOnX6
	* 09/05/2013.14 PTS 71968 - Use legheader from location tracking table when processing X6 data. Corrects issues with sending X6 for consolidated orders.
	* 01/14/2014.13 PTS 74227 - Added source of 214 status updates
	* 10/13/2015.14 PTS 90587 - added fixes for shipper/consignee setting...again
	*/

	DECLARE @e214p_id	integer,
		@ord_hdrnumber   integer,
		@ord_number 	char(12),
		@billto_cmp_id	char(8),
		@e214_level	char(3),
		@e214_ps_status	varchar(25),
		@stp_number	integer,
		@e214p_activity varchar(6),
		@e214p_arrive_earlyorlate char(1),
		@e214p_depart_earlyorlate char(1),
		@e214p_dttm datetime,
		@ckc_number int,
		@next_ord_hdrnumber int,
		@last_ord_hdrnumber int,
		@mins_to_next_report int,
		@current_lgh_number int,
		@min_stp_sequence int,
		@last_ckcall datetime,
		@tractorID varchar(8),
		@driverID varchar(8),
		@ordnumber varchar(12),
		@ord_billto varchar(8),
		@stp_sequence int,
		@eloc_interval int,
		@ckc_date datetime,
		@eloc_nextlocreport datetime,
		@firstlastflags varchar(20),
		@automail    char(1),
		@ord_shipper varchar(8),
		@ord_consig  varchar(8),
		@contact_name   varchar(30),
		@address        varchar(50),
		@type                   char(1),
		@emailshipper      char(1),
		@emailconsignee      char(1),
		@emailbillto     char(1),
		@mov_num  int,
		@message    varchar(5000),
		--@emailorfax     varchar(30),
		@emailorfax     varchar(50),
		@trailertractor varchar(20),
		@cmp_name varchar(30),
		@stp_type varchar(6),
		@nextphone varchar(80),
		@activity varchar(10),
		@delaytime integer,
		@createdtime datetime,
		@ckcupdatedon datetime,
		@usefaxphone char(1),
		@ReplicateForEachDropFlag char(1),
		@relativestopcount int,
		@relativestoptype varchar(3),
		@relativestopseq int,
		@1stPupSeq int,
		@relativeMode int,
		@relativestopseqtemp int,
		@countA int,
		@countB int,
		-- PTS 16419 -- BL
		@EDI_214_FAXFORMAT_ID int,	
		-- PTS 16223 -- BL (start)
		@EDI_Notification_Process_Type int,
		@notify_by_email_flag varchar(1),
		@notify_by_fax_flag varchar(1),
		-- PTS 16223 -- BL (end)
		@auto_preprocess_sp	varchar(255),
		@current_lgh_status varchar(6),		--PTS 42315
		@eloc_lastckcall int,		--PTS#-42315
		@lgh_carrier varchar(8),
		@elocType  varchar(6),	--45681
		@v_GIallowETAonPlanned CHAR(1),	--49961
		@v_GIReportWhenParked varchar(20),  --56836
		@v_GIUseCurrentTimeWhenParked CHAR(1), --66652
		@tmwUser VARCHAR(255),	--74227
		@appName NVARCHAR(128),	--74227
		@e214p_source NVARCHAR(128),
		@e214p_User	  VARCHAR(255),	--74227
		@stp_status VARCHAR(6),	--69642
		@v_GIRequireDriverOnX6 CHAR(1), --71092
		@v_next_order_stop INT,	--71968
		@v_current_lgh_status VARCHAR(6), --71968
		@ico_stp_number_child int --PTS71339 JJF 20131115 - If the next stop is part of an ico order, find the lowest level live stop	
		
	DECLARE @v_RestrictByTerms CHAR(1),@ord_terms VARCHAR(6),@v_restrictTermsLevel CHAR(1)	--50029

	exec gettmwuser @tmwUser OUTPUT
 	SELECT @appName = APP_NAME()
  
	
	Select @usefaxphone = Substring(IsNull(gi_string1,'Y'),1,1) From generalinfo with (NOLOCK)
	Where gi_name = 'EDIUseCompanyFaxForAuto214'

	Select @usefaxphone = IsNull(@usefaxphone,'Y')

	select @v_GIReportWhenParked = (
		case isnull(gi_string1,'N') 
			when 'YES' then 'Y'
			when 'Y' then 'Y'
			else 'N'
		end)
	from generalinfo  with (NOLOCK)
	where gi_name = 'EDI214ReportLocationWhenParked'

	select @v_GIReportWhenParked = ISNULL(@v_GIReportWhenParked,'N')


	--PTS 71092
	SELECT @v_GIRequireDriverOnX6 = ISNULL(UPPER(LEFT(gi_string1,1)),'N') 
	FROM	generalinfo
	WHERE gi_name = 'EDI214RequireDriverMatchOnX6'


	SELECT @v_GIUseCurrentTimeWhenParked = ISNULL(UPPER(LEFT(gi_string1,1)),'N') 
	FROM generalinfo
	WHERE gi_name = 'EDI214UseCurrentTimeWhenParked'

	/************Call to client specific auto 214 preprocess**************
	*PTS 32401  AROSS 
	**/
	SELECT @auto_preprocess_sp = ISNULL(gi_string1,'UNKNOWN') FROM generalinfo  with (NOLOCK) WHERE gi_name = 'EDI_auto214_preprocess'

	IF @auto_preprocess_sp <> 'UNKNOWN'
		exec @auto_preprocess_sp
	/* End PTS 32401   						      */  	


	--PTS 49961 Get GI Value
	Select @v_GIallowETAonPlanned =  IsNull(UPPER(LEFT(gi_string1,1)),'N') FROM generalinfo  with (NOLOCK) WHERE gi_name = 'EDI_GenerateETAOnCreation'
	--PTS49961 END

	--PTS 50029
	Select @v_RestrictByTerms =  IsNull(UPPER(LEFT(gi_string1,1)),'N') FROM generalinfo with (NOLOCK) WHERE gi_name = 'EDI_RestrictByTerms'
	--END 50029

	/* table of all companies to receive email or fax for this 214 */
	CREATE TABLE #tmp_cmps(
		cmp_id varchar(8) ,
		cmp_faxphone varchar(20) NULL,
		cmp_contact varchar(50) NULL )

	/* table of email /  phone numbers from the company table and companyemail fro the companies above */
	CREATE TABLE #tmp_allphone(
		phone varchar(50),
		contact varchar(50) NULL,
		type varchar(1) NULL)

	/* table of unique email or fax + coantact  entries  */

	CREATE TABLE #tmp_distinctphone(
		phone varchar(50),
		contact varchar(30) NULL,
		type varchar(1) NULL,
		nextphone varchar(80) NULL)

	SELECT @next_ord_hdrnumber = MIN(ord_hdrnumber) 
	FROM edi_214_locationtracking  with (NOLOCK)

	SELECT @next_ord_hdrnumber = ISNULL(@next_ord_hdrnumber,0)
 
	WHILE @next_ord_hdrnumber > 0

	BEGIN   --#1
		-- is it time to report another location for this order?
		SELECT @mins_to_next_report = DATEDIFF(mi,getdate(),eloc_nextlocreport),
			@eloc_interval = ISNULL(eloc_interval,60),
			@last_ord_hdrnumber = ord_hdrnumber,
			@eloc_nextlocreport = eloc_nextlocreport,
			@eloc_lastckcall= eloc_lastckcall
		FROM edi_214_locationtracking  with (NOLOCK)
		WHERE ord_hdrnumber = @next_ord_hdrnumber

		IF @mins_to_next_report <= 7
		BEGIN  --#2
	           
			/*PTS 42315 leg based location reporting 
			1-check for any legs that have been started*/
					
			--SELECT @v_next_order_stop = stp_number
			--FROM	stops WITH(NOLOCK) 
			--WHERE  ord_hdrnumber = @next_ord_hdrnumber
			--	AND stp_sequence = (SELECT MIN(stp_sequence) FROM stops WITH(NOLOCK) WHERE ord_hdrnumber = @next_ord_hdrnumber AND stp_status = 'OPN')
			
			--PTS71339 JJF 20131115 - If the next stop is part of an ico order, find the lowest level live stop	
			--SELECT	@current_lgh_number = lgh_number,
			--FROM	stops WITH(NOLOCK)
			--WHERE   stp_number = @v_next_order_stop

			--SELECT	@current_lgh_number = lgh_number,
			--		@ico_stp_number_child = stops.stp_ico_stp_number_child
			--FROM	stops WITH(NOLOCK)
			--WHERE   stp_number = @v_next_order_stop

			/*PTS 88240*/
				SELECT @current_lgh_number = MIN(lgh_number)
            FROM 	legheader  with (NOLOCK) 
            WHERE   ord_hdrnumber  = @next_ord_hdrnumber
            AND lgh_outstatus = 'STD'
			/*PTS 88240*/
			
			IF @ico_stp_number_child > 0 BEGIN
				--Find the lowest level leaf node, as it will be the live stop
				SELECT	@current_lgh_number = lgh_number
				FROM	stops WITH(NOLOCK)
				WHERE   stp_number = dbo.ico_intercompany_stop_leaf_fn(@ico_stp_number_child)
			END
			--END PTS71339 JJF 20131115 
			
			SELECT @v_current_lgh_status = lgh_outstatus
			FROM   legheader WITH(NOLOCK)
			WHERE  lgh_number = @current_lgh_number
					

			--IF @current_lgh_number IS NULL
			IF @v_current_lgh_status <> 'STD'	--71968
			BEGIN
				/*  -- trip must have completed since last report
				INSERT tts_errorlog (err_batch,err_user_id,err_message,err_date)
				VALUES (549,'214autoloc','Order '+convert(varchar(9),@next_ord_hdrnumber) +
				' was in the edi_214_locationtracking with no open stops. Ignored.',
				getdate())
				*/
				--check for any remaining stops on this order.  If there are none, the location reporting should stop and the record is deleted from the table
				IF(SELECT COUNT(*) FROM stops  with (NOLOCK) WHERE ord_hdrnumber =  @next_ord_hdrnumber AND stp_status = 'OPN') = 0           
					DELETE 
					FROM edi_214_locationtracking  
					WHERE ord_hdrnumber = @next_ord_hdrnumber
				ELSE
					--update the location tracking table  PTS#-42315
					UPDATE edi_214_locationtracking
					SET eloc_nextlocreport = DATEADD(mi,@eloc_interval,@eloc_nextlocreport)
					WHERE ord_hdrnumber = @next_ord_hdrnumber
			END
			ELSE
			BEGIN  -- #3
				--gather resource and stop information
				SELECT	 @tractorID = legheader.lgh_tractor,
					@driverID = legheader.lgh_driver1,
					@lgh_carrier = legheader.lgh_carrier
				FROM 	legheader  with (NOLOCK)
				WHERE  lgh_number  = @current_lgh_number
	            
				--PTS#-42315 get stops data from first open stop
				SELECT	@stp_number = stp_number,
					@stp_sequence = stp_mfh_sequence
				FROM 	stops  with (NOLOCK)
				WHERE	lgh_number = @current_lgh_number
					AND stp_mfh_sequence=  (SELECT MIN(stp_mfh_sequence) FROM stops where lgh_number = @current_lgh_number and stp_status = 'OPN')
		    		
				IF (SELECT ISNULL(@lgh_carrier,'UNKNOWN')) <> 'UNKNOWN'		--PTS 45681
					SELECT @elocType = 'CAR'
				ELSE
					SELECT @elocType = 'DRV'

				--PTS 37848 AROSS
				--If there are no resources assigned, update the location tracking interval.
				IF (SELECT ISNULL(@tractorID,'UNKNOWN') )= 'UNKNOWN'  AND @elocType ='TRC'
					--update location tracking with next time to report
					UPDATE edi_214_locationtracking
					SET eloc_nextlocreport = DATEADD(mi,@eloc_interval,@eloc_nextlocreport)
					WHERE ord_hdrnumber = @next_ord_hdrnumber
				--END 37848
		   
				SELECT @ordnumber = RTRIM(ord_number),
					@ord_billto = RTRIM(ord_billto)
				FROM orderheader  with (NOLOCK)
				WHERE ord_hdrnumber = @next_ord_hdrnumber
	 		   
				SELECT @last_ckcall = MAX(ckc_date)
				FROM checkcall  with (NOLOCK)
				WHERE ckc_tractor = @tractorID
					AND ckc_asgnid = CASE @elocType WHEN 'DRV' THEN @driverID		--45681
										WHEN 'CAR' THEN @lgh_carrier
									END		
					AND ckc_asgntype = @elocType	--'DRV'
					AND ckc_event = 'TRP'
					AND ckc_lghnumber = @current_lgh_number          --PTS 51194
						
				IF @v_GIRequireDriverOnX6 = 'N' AND @elocType = 'DRV'	--71092
					SELECT @last_ckcall = MAX(ckc_date)
					FROM checkcall WITH(NOLOCK)
					WHERE ckc_tractor = @tractorID 
						AND ckc_asgntype = @elocType AND ckc_event = 'TRP' AND ckc_lghnumber = @current_lgh_number 
		
				IF @last_ckcall IS NOT NULL  --If it is, do not update next_locreport dttm
				BEGIN  -- #4
					SELECT  @ckc_date = ckc_date,@ckc_number = ckc_number,@ckcupdatedon = ckc_updatedon
					FROM checkcall  with (NOLOCK)
					WHERE ckc_tractor = @tractorID
						AND ckc_asgnid =  CASE @elocType WHEN 'DRV'  THEN  @driverID		--45681
											WHEN 'CAR'  THEN  @lgh_carrier
										END		 
						AND ckc_asgntype = @elocType --'DRV'
						AND ckc_event = 'TRP'
						AND ckc_date = @last_ckcall
						AND ckc_lghnumber = @current_lgh_number          --PTS51194
		           
					IF @v_GIRequireDriverOnX6 = 'N' AND @elocType = 'DRV'	--71092
						SELECT  @ckc_date = ckc_date,@ckc_number = ckc_number,@ckcupdatedon = ckc_updatedon
						FROM checkcall WITH(NOLOCK)
						WHERE ckc_tractor = @tractorID 
							AND ckc_asgntype = @elocType AND ckc_event = 'TRP' AND ckc_lghnumber = @current_lgh_number AND ckc_date = @last_ckcall


					IF @ckc_number <> ISNULL(@eloc_lastckcall,-1)		--PTS#-42315 do not report on same checkcall twice
						or @v_GIReportWhenParked = 'Y'      -- unles GI indicates you do
					 
					BEGIN -- PTS#-42315
						--PTS66652 use current time when parked.
						IF @ckc_number = @eloc_lastckcall AND @v_GIReportWhenParked = 'Y' AND @v_GIUseCurrentTimeWhenParked ='Y'
							SELECT @ckc_date = GETDATE()
					
						INSERT edi_214_pending (
							e214p_ord_hdrnumber,
							e214p_billto,
							e214p_level,
							e214p_ps_status,
							e214p_stp_number,
							e214p_dttm,
							e214p_activity,
							e214p_arrive_earlyorlate,
							e214p_depart_earlyorlate,
							e214p_stpsequence,
							e214p_consolidation,
							ckc_number,
					e214p_created,
					e214p_source,
					e214p_user)
						VALUES (@next_ord_hdrnumber,			--   aross PTS 29686 use ord_hdrnumber instead of ord_number
							@ord_billto,
							'NON',
							' ',
							@stp_number,
							@ckc_date,
							'CKCALL',
							'',
							'',
							@stp_sequence,
							'',
							@ckc_number,
					@ckcupdatedon,
					@appName,
					@tmwUser)
						--update location tracking with next time to report
						UPDATE edi_214_locationtracking
						SET eloc_nextlocreport = DATEADD(mi,@eloc_interval,@eloc_nextlocreport),
						eloc_lastckcall =  @ckc_number
						WHERE ord_hdrnumber = @next_ord_hdrnumber
					END --PTS#-42315
				END --#4        
			END  --#3
		END  --#2 

		SELECT @next_ord_hdrnumber = MIN(ord_hdrnumber) 
		FROM edi_214_locationtracking
		WHERE ord_hdrnumber > @last_ord_hdrnumber

		SELECT  @next_ord_hdrnumber = ISNULL(@next_ord_hdrnumber,0)

	END  --#1

	/* Now Process the pending table which contains all auto 214's ready to be produced */
	select @delaytime = convert(integer,isnull(gi_string1,'0'))
	from generalinfo
	where gi_name = 'EDI214PENDINGDELAY'

	SELECT @e214p_id = 0

	WHILE 0 = 0
	BEGIN  /*  5  loop thru pending table */

		SELECT @e214p_id = MIN(e214p_id)
		FROM edi_214_pending   with (NOLOCK)
		WHERE e214p_id > @e214p_id


		IF @e214p_id IS NULL BREAK

		SELECT @ord_hdrnumber = e214p_ord_hdrnumber,  
			@billto_cmp_id = e214p_billto,
			@e214_level = e214p_level,
			@e214_ps_status = e214p_ps_status,
			@stp_number = e214p_stp_number,
			@e214p_activity = e214p_activity,
			@e214p_arrive_earlyorlate = e214p_arrive_earlyorlate,
			@e214p_depart_earlyorlate = e214p_depart_earlyorlate,
			@e214p_dttm = e214p_dttm,
			@ckc_number = ISNULL(ckc_number,0),
			@firstlastflags = ISNULL(e214p_firstlastflags,'0'),
			@createdtime=isnull(e214p_created,getdate()),
      @ReplicateForEachDropFlag = IsNull(e214p_ReplicateForEachDropFlag,'N'),
	  @e214p_source = isnull(e214p_source,'UNKNOWN'),
	  @e214p_user = isnull(e214p_user,'UNKNOWN')
		FROM edi_214_pending  with (NOLOCK) WHERE e214p_id=@e214p_id

		SELECT @ord_number = ord_number,
			@ord_shipper = ISNULL(ord_shipper,'UNKNOWN'),
			@ord_consig = ISNULL(ord_consignee,'UNKNOWN'),
			@ord_billto = ISNULL(ord_billto,'UNKNOWN'),
			@mov_num = mov_number,
			@trailertractor = 
				CASE ord_trailer
					WHEN 'UNKNOWN' THEN ISNULL(ord_tractor,'UNKNOWN')
					WHEN NULL THEN ISNULL(ord_tractor,'UNKNOWN')
					ELSE ord_trailer
				END
		FROM orderheader  with (NOLOCK)
		WHERE ord_hdrnumber = @ord_hdrnumber
     
		--PTS69642
		SELECT  @stp_status = stp_status
		FROM	 stops WITH(NOLOCK)
		WHERE stp_number = @stp_number
     
		--PTS 69642::do not send appt status messages for completed stops.
		IF (@e214p_activity ='APPT' and @stp_status = 'DNE')
		BEGIN
			DELETE FROM edi_214_pending WHERE  e214p_id=@e214p_id
			CONTINUE
		END 
 
		if @stp_number is null 
		select @stp_number = stp_number from stops  with (NOLOCK) where ord_hdrnumber = @ord_number and stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = @ord_hdrnumber)
  	
		/*PTS 43636 START ***/
  
		IF(SELECT COUNT(*) FROM stops WHERE [stp_number] = @stp_number) < 1  
		BEGIN
			DELETE from edi_214_pending where e214p_stp_number = @stp_number
			CONTINUE
		END
	 
		/*PTS 43636 END ***/ 
	
		/***PTS 50029 Restrict By Terms ***/
		IF @v_RestrictByTerms = 'Y' 
		BEGIN	 --50029  Check Terms
			select @ord_terms  = isnull(ord_terms,'UNK') from orderheader  with (NOLOCK) where ord_hdrnumber = @ord_hdrnumber
		 
			--get terms restriction
			select @v_restrictTermsLevel = isnull(trp_214_restrictTerms,'B') 
			from edi_trading_partner  with (NOLOCK)
			where cmp_id = @billto_cmp_id

			--allow PPD only 
			if (@v_restrictTermsLevel = 'P' and @ord_terms <> 'PPD')
			begin
				DELETE FROM edi_214_pending WHERE  e214p_id=@e214p_id
				CONTINUE
			end	
			--allow COL only
			if (@v_restrictTermsLevel = 'C' and @ord_terms <> 'COL')
			begin
				DELETE FROM edi_214_pending WHERE  e214p_id=@e214p_id
				CONTINUE
			end		
		END	--50029 
 	
  
		if datediff(second,@createdtime,getdate()) <= @delaytime CONTINUE
		/* if trip is not started, throw out any ESTA's */
		If Not (@e214p_activity = 'ESTA'   and Not Exists (select stp_type From stops Where ord_hdrnumber = @ord_hdrnumber
			and stp_status = 'DNE')) or  (@e214_level in ('BMT','EMT') or ( @v_GIallowETAonPlanned= 'Y'))	--{34624}
		Begin  /* 5B Bypass an ESTA on an unstarted trip */

			--DPH PTS 24802
			BEGIN

				DECLARE @donotsend_edi_flag varchar(1),
				@temp_shipper varchar(8),
				@temp_consignee varchar(8)

				If (Select ord_shipper from orderheader where ord_hdrnumber = @ord_hdrnumber) = 'UNKNOWN'
				BEGIN
					SELECT 	@temp_shipper = cmp_id
					FROM 	stops  with (NOLOCK)
					WHERE  	stp_type = 'PUP'
						and stp_sequence = (select min(stp_sequence)
											from stops
											where ord_hdrnumber = @ord_hdrnumber
											and stp_type = 'PUP' and ord_hdrnumber > 0)
						and ord_hdrnumber = @ord_hdrnumber
						and ord_hdrnumber > 0
				END
				ELSE
				BEGIN
					SELECT @temp_shipper = ord_shipper from orderheader  with (NOLOCK) where ord_hdrnumber = @ord_hdrnumber
				END

				SELECT 	@temp_consignee = cmp_id
				FROM 	stops  with (NOLOCK)
				WHERE  	stp_type = 'DRP'
						and stp_sequence = (select max(stp_sequence)
											from stops
											where ord_hdrnumber = @ord_hdrnumber
												and stp_type = 'DRP' and ord_hdrnumber > 0)
						and ord_hdrnumber = @ord_hdrnumber
						and ord_hdrnumber > 0
			END

			If @temp_shipper = @temp_consignee
			BEGIN
				Select 	@donotsend_edi_flag = trp_shp_cn_donotsend_flag
				From	edi_trading_partner  with (NOLOCK)
				Where	cmp_id = @billto_cmp_id		-- @temp_shipper changed for 90587

				select IsNull(@donotsend_edi_flag, 'N')

				If @donotsend_edi_flag = 'Y'
				BEGIN
					DELETE from edi_214_pending where e214p_ord_hdrnumber = @ord_hdrnumber
					CONTINUE
				END
			END
			--DPH PTS 24802


			/* produce the EDI 214 records */
			/* NKRES 16407 changed the @replicateforeach logic so it does all drops in while loop below */
			If  @ReplicateForEachDropFlag <> 'Y'
			BEGIN
				EXEC auto_214_sp
					@ord_number,
					@billto_cmp_id,
					@e214_level,
					@e214_ps_status,
					@stp_number,
					@e214p_activity,
					@e214p_arrive_earlyorlate ,
					@e214p_depart_earlyorlate,
					@e214p_dttm,
					@ckc_number,
					@firstlastflags,
 	0,
 	0,
	@e214p_source,
	@e214p_user
			END
			/* If repeat for each drop stop flag is on, look for more drops */
			Else
			BEGIN /* 5C  Loop thru subsequent drop stops passing the relative drop location  */ 
				select @stp_type = stp_type from stops  with (NOLOCK) where stp_number = @stp_number
				select @countA = count(*) from stops   with (NOLOCK) where ord_hdrnumber = @ord_hdrnumber and stp_type ='PUP'
				select @countB = count(*) from stops  with (NOLOCK) where ord_hdrnumber = @ord_hdrnumber and stp_type ='DRP'
				if 	@countA >= @countB
					select @relativeMode = 1
				else if @countA < @countB
					select @relativeMode = 2
      	
				if @relativeMode = 1 and @stp_type = 'DRP'
					select @relativestoptype ='PUP'
      			
				else if @relativeMode =2 and @stp_type = 'PUP'
					select @relativestoptype ='DRP'
		
				if @relativestoptype is not null
					Select 	@relativestopseq = 1, @relativestopcount = 
					count(*) From stops  with (NOLOCK) where ord_hdrnumber = @ord_hdrnumber and 
					stp_type = isnull(@relativestoptype,@stp_type)
				else 
					select @relativestopseq = 1, @relativestopcount =1 
 
				While @relativestopseq <= @relativestopcount
				BEGIN /* 5D */
					if (@relativemode = 1 and @stp_type = 'PUP') or (@relativemode = 2 and @stp_type = 'DRP')
						select @relativestopseqtemp = 0
					else 
						select @relativestopseqtemp = @relativestopseq
	
	
					EXEC auto_214_sp
						@ord_number,
						@billto_cmp_id,
						@e214_level,
						@e214_ps_status,
						@stp_number,
						@e214p_activity,
						@e214p_arrive_earlyorlate ,
						@e214p_depart_earlyorlate,
						@e214p_dttm,
						@ckc_number,
						@firstlastflags,
						@relativestopseqtemp,
	       @relativeMode,
		   @e214p_source,
		   @e214p_user
					Select @relativestopseq = @relativestopseq + 1
				END /*  5D */
				select @relativestoptype = Null
			END  /* 5C */

			-- PTS 16223 -- BL (start)
			--    Check which 'EDI notification process type' is to be used
			--          ((1) 'BillTo' based or (2) 'Company' based) 
			SELECT @EDI_Notification_Process_Type = gi_string1
			FROM generalinfo  with (NOLOCK)
			WHERE gi_name = 'EDI_Notification_Process_Type';
			-- PTS 16223 -- BL (end)

			-- PTS 16223 -- BL (start)
			IF @EDI_Notification_Process_Type = 1
				-- PTS 16223 -- BL (end)
				/* create email stuff  max below gets around duplicate edi_214_profile entries */
				SELECT @emailshipper = max(shipper),--get mailto info
					@emailconsignee=max(consignee),--get mailto info
					@emailbillto=max(thirdparty),--get mailto info, YES the column was named thirdparty
					@automail=max(automail), --get mailto info
					@activity= max(E214_triggering_activity),
					-- PTS 16223 -- BL (start)
					@notify_by_email_flag = max(notify_by_email_flag),
					@notify_by_fax_flag = max(notify_by_fax_flag)
					-- PTS 16223 -- BL (end)
				FROM   edi_214_profile  with (NOLOCK)
				WHERE  e214_cmp_id=@billto_cmp_id and
					e214_level = @e214_level and
					e214_triggering_activity = @e214p_activity and
					CHARINDEX(CONVERT(varchar(5),e214_stp_position),@firstlastflags) > 0 AND
					ISNULL(automail,'N') = 'Y'

			-- PTS 16223 -- BL (start)
			IF @EDI_Notification_Process_Type = 2
				/* create email stuff  max below gets around duplicate edi_214_profile entries */
				SELECT @emailshipper = max(shipper),--get mailto info
					@emailconsignee=max(consignee),--get mailto info
					@emailbillto=max(thirdparty),--get mailto info, YES the column was named thirdparty
					@automail=max(automail), --get mailto info
					@activity= max(E214_triggering_activity),
					@notify_by_email_flag = max(notify_by_email_flag),
					@notify_by_fax_flag = max(notify_by_fax_flag)
				FROM   edi_214_profile  with (NOLOCK)
				WHERE  e214_cmp_id=@billto_cmp_id and
					e214_level = @e214_level and
					e214_triggering_activity = @e214p_activity and
					CHARINDEX(CONVERT(varchar(5),e214_stp_position),@firstlastflags) > 0 AND
					(ISNULL(notify_by_email_flag,'N') = 'Y' OR ISNULL(notify_by_fax_flag,'N') = 'Y')
				-- PTS 16223 -- BL (end)


			-- PTS 16223 -- BL (start)
			--   (allow for both EDI processing methods)
			IF (@automail = 'Y' and @EDI_Notification_Process_Type = 1) OR 
				((@notify_by_email_flag = 'Y' or @notify_by_fax_flag = 'Y') and @EDI_Notification_Process_Type = 2)
				-- IF @automail = 'Y' 
			-- PTS 16223 -- BL (end)
			BEGIN  /* 6 Profile specifies sending fax or email */

				-- PTS 16419 -- BL (start)
				-- (check to see what format to use)
				SELECT @EDI_214_FAXFORMAT_ID = Format_ID
				FROM EDI_214_FaxFormat  with (NOLOCK)
				WHERE active_flag = 'Y';
				-- PTS 16419 -- BL (end)


				-- PTS 16419 -- BL (start)
				-- ONLY use 'Format 2' with 'Arrival' and 'Departure' events
				IF @EDI_214_FAXFORMAT_ID = 2 AND (@e214p_activity = 'ARV' or @e214p_activity = 'DEP') 
					/* build the text of the email or fax */
					EXEC  edi_214_createfax02_sp
					@ord_hdrnumber 		,
					@stp_number		,
					@e214p_activity         ,
					@e214_level          ,
					@ckc_number		,
					@firstlastflags		,
					@contact_name           ,
					-- PTS 16223 -- BL (start)
					@billto_cmp_id		,
					-- PTS 16223 -- BL (end)
					@message  OUTPUT
				ELSE
					/* build  the text of the email or fax */
					EXEC  automessage_sp
					@ord_hdrnumber 		,
					@stp_number		,
					@e214p_activity         ,
					@e214_level          ,
					@ckc_number		,
					@firstlastflags		,
					@contact_name           ,
					@message  OUTPUT
					-- PTS 16419 -- BL (end)

				/* get stp type amd the name of the company at that stop for the cmpemailmsg table entries */
				SELECT @stp_type = stp_type,@cmp_name = company.cmp_name 
				FROM stops  with (NOLOCK),company
				WHERE stp_number = @stp_number
					AND company.cmp_id = stops.cmp_id
	


				-- PTS 16223 -- BL (start)
				IF @EDI_Notification_Process_Type = 1
				-- PTS 16223 -- BL (end)
					/*  Pick up the unique companies to receive email or fax  */
					INSERT INTO #tmp_cmps
					SELECT distinct cmp_id,Case @usefaxphone When 'Y' Then cmp_faxphone Else '' End ,
						RTRIM(ISNULL(cmp_contact,'')) cmp_contact
					FROM company  with (NOLOCK),orderheader 
					WHERE 
						ord_hdrnumber = @ord_hdrnumber and
						(	cmp_id = 
								Case @emailbillto
									WHEN 'Y' Then ord_billto
									ELSE ''
								END 
							or
							cmp_id = 
								Case @emailshipper
									WHEN 'Y' Then ord_shipper
									ELSE ''
								END
							or
							cmp_id = 
								CASE @emailconsignee
									WHEN 'Y' Then ord_consignee
									ELSE ''
							END
						)

				-- PTS 16223 -- BL (start)
				IF @EDI_Notification_Process_Type = 2
					/*  Pick up the unique companies to receive email or fax  */
					INSERT INTO #tmp_cmps
					SELECT distinct cmp_id,
						Case @usefaxphone When 'Y' Then cmp_faxphone Else '' End ,
						RTRIM(ISNULL(cmp_contact,'')) cmp_contact
					FROM company  with (NOLOCK)
					WHERE cmp_id = @billto_cmp_id
				-- PTS 16223 -- BL (end)

				-- PTS 16223 -- BL (start)
				--   (allow for both EDI processing methods)
				IF @EDI_Notification_Process_Type = 1 OR 
					(@notify_by_fax_flag = 'Y' and @EDI_Notification_Process_Type = 2)
				-- PTS 16223 -- BL (end)
					/* get the distinct fax numbers from these companies */
					INSERT INTO #tmp_allphone
					SELECT '[FAXMAKER:1' + cmp_faxphone + ']', cmp_contact, 'F'
					FROM #tmp_cmps
					WHERE cmp_faxphone IS NOT NULL 
						AND RTRIM(cmp_faxphone) > ''


				/* Add the phones from the companyemail table */

				-- PTS 16223 -- BL (start)
				--   (allow for both EDI processing methods)
				IF @EDI_Notification_Process_Type = 1 OR 
					(@notify_by_email_flag = 'Y' and @EDI_Notification_Process_Type = 2)
				-- PTS 16223 -- BL (end)
					INSERT INTO #tmp_allphone
					SELECT  RTRIM(email_address) phone, RTRIM(ISNULL(contact_name,'')) contact, type
					FROM companyemail  with (NOLOCK)
					WHERE cmp_id in (select cmp_id FROM   #tmp_cmps)
						AND email_address IS NOT NULL
						AND LEN(RTRIM(email_address)) > 0

				/* build a table of distinct email or fax numbers */
				INSERT INTO #tmp_distinctphone
				SELECT DISTINCT phone,contact,type,(phone + contact) nextphone
				FROM #tmp_allphone

				SELECT @nextphone = ''

				WHILE 0 = 0
				BEGIN  /*  7 loop thru  unique  email or fax numbers and create cmpemailmsg */
					SELECT @nextphone = MIN(nextphone) FROM #tmp_distinctphone where nextphone > @nextphone

					IF @nextphone IS NULL BREAK

					SElECT @emailorfax = phone,
					@contact_name = contact,
					@type = type
					FROM   #tmp_distinctphone
					WHERE   nextphone = @nextphone

					IF @emailorfax is not null and LEN(@emailorfax) > 0
					-- PTS 16223 -- BL (start)
					BEGIN  /*  7a  Create 'message' record */
						IF @EDI_Notification_Process_Type = 1  
							-- PTS 16223 -- BL (end)
							INSERT INTO cmpemailmsg
								(cmp_id,mail_type,updateddate,ord_hdrnumber,mov_number,stp_number,
								events,ord_number,email_address,contact_name,type,msgtype,
								message,cmp_name,stp_type,firstlastflags,trailertractor)
							VALUES(    @ord_shipper,
								Case @e214p_activity WHEN 'CKCALL' THEN 'C'
									WHEN 'PLAN'  THEN 'O'
									WHEN 'DISP'  THEN 'O'
									WHEN 'ESTA' THEN 'E'
									WHEN 'CAN' THEN 'X'
									WHEN 'ARV' THEN 'A'
									WHEN 'ARVDEP' THEN 'D'    -- will be replaced by 2 pendings 1 arv, 1 dep
									WHEN 'DEP' THEN 'D'
									ELSE 'T' 
								END,
								GETDATE(),
								@ord_hdrnumber,
								@mov_num,	
								@stp_number,
								@activity,
								@ord_number,
								@emailorfax,
								@contact_name,
								'F' ,
								'',
								@message,
								@cmp_name,
								@stp_type,
								@firstlastflags,
								@trailertractor	)

						-- PTS 16223 -- BL (start)
						IF @EDI_Notification_Process_Type = 2  
							INSERT INTO cmpemailmsg
								(cmp_id,mail_type,updateddate,ord_hdrnumber,mov_number,stp_number,
								events,ord_number,email_address,contact_name,type,msgtype,
								message,cmp_name,stp_type,firstlastflags,trailertractor)
							VALUES(    @billto_cmp_id,
								Case @e214p_activity WHEN 'CKCALL' THEN 'C'
									WHEN 'PLAN'  THEN 'O'
									WHEN 'DISP'  THEN 'O'
									WHEN 'ESTA' THEN 'E'
									WHEN 'CAN' THEN 'X'
									WHEN 'ARV' THEN 'A'
									WHEN 'ARVDEP' THEN 'D'    -- will be replaced by 2 pendings 1 arv, 1 dep
									WHEN 'DEP' THEN 'D'
									ELSE 'T' 
								END,
								GETDATE(),
								@ord_hdrnumber,
								@mov_num,	
								@stp_number,
								@activity,
								@ord_number,
								@emailorfax,
								@contact_name,
								'F' ,
								'',
								@message,
								@cmp_name,
								@stp_type,
								@firstlastflags,
								@trailertractor	)
					END  /*  7a  Create 'message' record */
					-- PTS 16223 -- BL (end)

				END  /*  7 loop thru  unique companies to receive email or fax and process cmp_faxphone values */
	
				DELETE FROM #tmp_allphone  -- clear out
				DELETE FROM #tmp_distinctphone

			END   /* 6 Profile specifies sending fax or email */
		END /* 5B */

		DELETE From #tmp_cmps
	
		DELETE
		FROM edi_214_pending 
		WHERE e214p_id = @e214p_id
 
	END  /* 5 loop thru pending */

	DROP TABLE #tmp_cmps
	DROP TABLE #tmp_distinctphone
	DROP TABLE #tmp_allphone
	RETURN

GO
GRANT EXECUTE ON  [dbo].[monitor_214_sp] TO [public]
GO
