SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/****** Object:  Stored Procedure dbo.update_ord    Script Date: 8/20/97 1:59:53 PM ******/  
CREATE PROCEDURE [dbo].[update_ord] 
		(@mov  				int
		,@invwhen			varchar(8)		--PTS62555 changed from char to varchar
		,@date_presentation	smallint = 0) 
AS   


/*MF pts 4545 - change order status update logic */  
  
/* update origin, destination, status of orderheader based on stops for move */  
/* LOR update revtype's on orderheader if REVTYPE..MAX in generalinfo table set to Y */  
/* DPETE 14839 add TRIPSTD, PUPSCMP, and TRIPCMP to invoice when values   
 DPETE PTS 15463 Requested to set invoice status to XIN (do not invoice) if order cancelled (helps keep order amount out of a bookingor billing total)  
 DPETE 16402 deterine inv status when currrent status is PND or AVL
  DPETE PTS 16864 If trip is assigned and completed in one step, an INI "When=STD" does not set theinvoice status to Available
  DPETE PTS16479 allow billable empty trips in OE where stp_types are not PUP/DRP

07/17/2003	Vern Jewett		Added parm @date_presentation because we need to prevent 
	PTS 17728	Label=vmj1	updates to ord_startdate if [Order] DatePresentation=4 and 
							the order is started.  That INI setting is passed in the 
							new parm.  This SP is "overloaded" because the new parm has 
							a default value of 0.

01/09/2006 Phil Bidinger PTS 31226 
-- PTS 36019 BDH 5/14/07.  Check that the 3rd party is active when looking at thirdpartyrelationships.
-- PTS 44064 JSwindell 10/27/2008 - don't duplicate 'auto assigned 3rd parties' on a copy (see 36019)
*/  
--  
-- @invwhen defined values:  
--      Blank, NULL, or 'STD': Make ready to invoice if order Started  
--      'CMP': Make ready to invoice if order Completed  
--      'UNK': Do not change invoice status.  
--	PTS 44960 JET 1/27/09, update the origin and destination rail ramps to the header during save process 
--  PTS 47124 SGB 04/21/09 Remove debug line
--  PTS 49236 SGB 11/05/09 Allow Order Status to stay at Dispatched instead of being set to Planned
-- PTS 52591 JSwindell 6/18/2010:  -- Third party default assignments:  Create new proc to be called for TPR assignments
-- PTS 53315 SGB 08/31/2010 trailer2 not being populated on orderheader. Causing issues with nvo_rating
-- PTS 54080 JET 10/6/2010, add support for 2 new order statuses (IMP and SUS).  They follow STD and happen before CMP.  They will
--			 either be set via the operations UI or from TotalMail.  IMP is a review state to put the order on hold until it has been
--			 reviewed.  SUS is another review state, indicating that an error was found by billing or settlements and it needs fixed by operations
-- PTS 59166 SGB Allow override of TTS50 WHEN and enable ord_invoicestatus to be set to AVL when ord_status = 'AVL' 
-- PTS 59846 vjh added DRPSCMP
-- PTS 62555 NLOKE changes from Mindy to change all CHAR type to VARCHAR
-- PTS 73039 JET 11/04/13 add support for CBR - in bond customs order status


DECLARE @minord      int,  
        @opn         smallint,  
        @dne         smallint,  
        @dispstat    varchar(6),	--PTS62555 changed from char to varchar
        @invstat     varchar(6),	--PTS62555 changed from char to varchar
        @code        smallint,  
        @o_cmp       varchar(8),	--PTS62555 changed from char to varchar
        @o_cty       int,  
        @o_state     varchar(6),	--PTS62555 changed from char to varchar
        @o_date      datetime,  
        @o_ddate     datetime,  
        @o_edate     datetime,  
        @o_ldate     datetime,  
        @d_cmp       varchar(8),	--PTS62555 changed from char to varchar
        @d_cty       int,  
        @d_state     varchar(6),	--PTS62555 changed from char to varchar
        @d_date      datetime,  
        @d_ddate     datetime,  
        @d_edate     datetime,  
        @d_ldate     datetime,  
        @stp_count   int,   
        @lghcode     smallint,  
        @revtype1max varchar(12),  
        @revtype2max varchar(12),  
        @revtype3max varchar(12),  
        @revtype4max varchar(12),  
        @revtype1    varchar(6),  
        @revtype2    varchar(6),  
        @revtype3    varchar(6),  
        @revtype4    varchar(6),   
		@driver1     varchar(8),  
		@driver2     varchar(8),  
		@tractor     varchar(8),  
		@trailer     varchar(13),  
		@trailer2     varchar(13), 	--PTS 53315 SGB
        @ivhdelor    int,   
        @lgh         int,  
		@stopstatus  varchar(6),
		@li_started_code	smallint,
		@li_code			smallint,
		@carrier	 VARCHAR(8),
		@completeondeparture	char(1), 
		@originRailRamp varchar(8), 
		@destinationRailRamp varchar(8),
		@ordstat varchar(6), --  PTS 49236 SGB 11/05/09
		@cmpsvcexception	char(1),	-- PTS 45980 - DJM 11/30/2009
		@ord_billto varchar(8),
		@invwhenoverride varchar(6)

SELECT @minord = 0  
SELECT @invwhen = IsNull(@invwhen,'STD')  
-- JET - 9/21/99 - PTS #6433  
-- variable to track whether the delivery date on invoices should be corrected by this routine  
SELECT @ivhdelor = IsNull(gi_integer1, 0)   
  FROM generalinfo  
 WHERE gi_name = 'IvhDelOverRi'  
  
If @invwhen = ''   
   SELECT @invwhen = 'STD'  
   
--PTS 59166 SGB
Select @ord_billto = ord_billto from orderheader where ord_hdrnumber = (SELECT MIN(ord_hdrnumber) FROM stops WHERE mov_number = @mov and ord_hdrnumber <> 0)
Select @invwhenoverride = isnull(cmp_invoice_when,'UNK') from company where cmp_id = @ord_billto 
IF @invwhenoverride <> 'UNK'
	Select @invwhen = @invwhenoverride

--vmj1+	Get the label code for started..
select	@li_started_code = code
  from	labelfile
  where	labeldefinition = 'DispStatus'
	and	abbr = 'STD'
--vmj1-

--PTS35229 MBR 11/22/06
SELECT @completeondeparture = ISNULL(LEFT(UPPER(gi_string1), 1), 'N')
  FROM generalinfo
 WHERE gi_name = 'CompleteOnDeparture'
   
WHILE (SELECT COUNT(*)    
         FROM stops   
        WHERE ord_hdrnumber+0 > @minord AND   
              mov_number = @mov) > 0  
BEGIN  
     SELECT @minord = MIN(ord_hdrnumber)   
       FROM stops   
      WHERE ord_hdrnumber+0 > @minord AND   
            mov_number = @mov  
       
     SELECT @stp_count = COUNT(*)   
       FROM stops   
      WHERE ord_hdrnumber = @minord  
       
     /* find origin freight stop */  
     SELECT @o_cmp = cmp_id,   
            @o_cty = stp_city,   
            @o_state = stp_state,   
            @o_edate = stp_schdtearliest,   
            @o_ldate = stp_schdtlatest   
       FROM stops  
      WHERE stops.ord_hdrnumber = @minord AND   
            stops.stp_sequence = (SELECT MIN(stp_sequence)   
                                    FROM stops, eventcodetable   
                                   WHERE ord_hdrnumber = @minord AND   
                                         stops.stp_event = eventcodetable.abbr AND   
                                         stops.stp_type = 'PUP' AND   
                                         eventcodetable.ect_billable = 'Y')  
      
		If @o_cmp Is Null
		SELECT @o_cmp = cmp_id,   
            @o_cty = stp_city,   
            @o_state = stp_state,   
            @o_edate = stp_schdtearliest,   
            @o_ldate = stp_schdtlatest   
       FROM stops  
      WHERE stops.ord_hdrnumber = @minord AND   
            stops.stp_sequence = (SELECT MIN(stp_sequence)   
                                    FROM stops   
                                   WHERE ord_hdrnumber = @minord AND   
                                          stops.stp_event in ('IBMT','IBBT')  )

     --PTS69414 MBR 08/16/13
     IF @o_cmp IS NULL
     BEGIN
        SELECT @o_cmp = cmp_id,   
               @o_cty = stp_city,   
               @o_state = stp_state,   
               @o_edate = stp_schdtearliest,   
               @o_ldate = stp_schdtlatest   
          FROM stops  
         WHERE stops.ord_hdrnumber = @minord AND   
               stops.stp_sequence = (SELECT MIN(stp_sequence)   
                                       FROM stops, eventcodetable   
                                      WHERE ord_hdrnumber = @minord AND   
                                            stops.stp_event = eventcodetable.abbr AND   
                                            eventcodetable.ect_billable = 'Y')
     END
 
     /* PG 2/4/97 set the earliest arrival date of pick-up stops as start date.  
        If no pickup exists then set the start date to the earliest arrival date from all stops */  
     SELECT @o_date = MIN(stp_arrivaldate),  
            @o_ddate = MIN(stp_departuredate)  
       FROM stops   
      WHERE ord_hdrnumber = @minord AND   
            stops.stp_type = 'PUP'  
       
     If @o_date IS Null  
        SELECT @o_date = MIN(stp_arrivaldate),   
               @o_ddate = MIN(stp_departuredate)   
          FROM stops   
         WHERE ord_hdrnumber = @minord  
       
     /* find frieght destination stop */  
     SELECT @d_cmp = cmp_id,   
            @d_cty = stp_city,   
            @d_state = stp_state,   
            @d_edate = stp_schdtearliest,   
            @d_ldate = stp_schdtlatest   
       FROM stops  
      WHERE stops.ord_hdrnumber = @minord AND   
            stops.stp_sequence = (SELECT MAX(stp_sequence)  
                                    FROM stops, eventcodetable   
                                   WHERE ord_hdrnumber = @minord AND   
                                         stops.stp_type = 'DRP' AND   
                                         stops.stp_event = eventcodetable.abbr AND   
                                         eventcodetable.ect_billable = 'Y')  
       
		If @d_cmp Is Null
		SELECT @d_cmp = cmp_id,   
            @d_cty = stp_city,   
            @d_state = stp_state,   
            @d_edate = stp_schdtearliest,   
            @d_ldate = stp_schdtlatest   
       FROM stops  
      WHERE stops.ord_hdrnumber = @minord AND   
            stops.stp_sequence = (SELECT MAX(stp_sequence)  
                                    FROM stops   
                                   WHERE ord_hdrnumber = @minord AND   
                                         stops.stp_event in ('IEMT','IEBT') )

     --PTS69414 MBR 08/16/13
     IF @d_cmp IS NULL
     BEGIN
        SELECT @d_cmp = cmp_id,   
               @d_cty = stp_city,   
               @d_state = stp_state,   
               @d_edate = stp_schdtearliest,   
               @d_ldate = stp_schdtlatest   
          FROM stops  
         WHERE stops.ord_hdrnumber = @minord AND   
               stops.stp_sequence = (SELECT MAX(stp_sequence)  
                                       FROM stops, eventcodetable   
                                      WHERE ord_hdrnumber = @minord AND   
                                            stops.stp_event = eventcodetable.abbr AND   
                                            eventcodetable.ect_billable = 'Y')
     END

     /* LR 05/09/97 set the latest arrival date of drop-off stops as completion date.  
        If no drop-off exists then set the completion date to the latest arrival date from  
        all stops */  
     SELECT @d_date = MAX(stp_arrivaldate),   
            @d_ddate = Max(stp_departuredate)   
       FROM stops   
      WHERE ord_hdrnumber = @minord AND   
            stp_type = 'DRP'  
     If @d_date IS Null  
        SELECT @d_date = MAX(stp_arrivaldate),   
               @d_ddate = Max(stp_departuredate)    
          FROM stops  
         WHERE ord_hdrnumber = @minord   
       
     /* compute order dispatch status */  
     --PTS35229 MBR 11/22/06
     --PTS37012 MBR 04/10/07 Added the ISNULL to below
     IF @completeondeparture = 'Y'
        SELECT @opn = (SELECT COUNT(*)
                         FROM stops
                        WHERE stops.ord_hdrnumber = @minord AND
                              ISNULL(stops.stp_departure_status, 'OPN') = 'OPN')

     ELSE
        SELECT @opn = (SELECT COUNT(*)   
                         FROM stops   
                        WHERE stops.ord_hdrnumber = @minord AND   
                              stops.stp_status = 'OPN')
  
     SELECT @dne = (SELECT COUNT(*)   
                      FROM stops   
                     WHERE stops.ord_hdrnumber = @minord AND   
                           stops.stp_status = 'DNE')  
  
     SELECT @invstat = ISNULL(ord_invoicestatus,'PND'),   
            @dispstat = ord_status,   
            @code = code  
       FROM orderheader, labelfile   
      WHERE ord_hdrnumber = @minord AND   
            labeldefinition = 'DispStatus' AND   
            abbr = ord_status 
            
      SET @ordstat = @dispstat --  PTS 49236 SGB 11/05/09
  
     -- JET - 6/28/99 - PTS 5834, make sure the invoice status is set to a value not a null string  
     IF @invstat = ''  
        SELECT @invstat = 'PND'  
  
     -- JET - 10/28/99 - PTS #6453, need to delete any asset assignments that may exist.  
     IF @dispstat = 'CAN'  
        BEGIN   
             -- find the leg header number that was used for this order  
             SET ROWCOUNT 1  
             SELECT @lgh = lgh_number   
               FROM stops  
              WHERE ord_hdrnumber = @minord  
             SET ROWCOUNT 0  
  
             -- delete any asset assignment records that may have been created for this order  
             DELETE FROM assetassignment   
              WHERE lgh_number = @lgh  
  
             -- reset values on the leg header to represent a cancelled order (VD will delete LH)  
             UPDATE legheader   
                SET lgh_carrier = 'UNKNOWN',   
                    lgh_driver1 = 'UNKNOWN',   
                    lgh_driver2 = 'UNKNOWN',   
                    lgh_primary_trailer = 'UNKNOWN',   
                    lgh_primary_pup = 'UNKNOWN',   
                    lgh_tractor = 'UNKNOWN',    
                    lgh_active = 'N',   
                    lgh_instatus = 'UNP',   
                    lgh_outstatus = 'CAN'   
              WHERE lgh_number = @lgh  
              
            -- make sure any trailer assignments and status values are updated on the stops  
     -- RE - 10/25/00 - PTS #9247 do each stop separately or trigger has problems.  
            WHILE (SELECT COUNT(*)   
                   FROM   STOPS  
                   WHERE  lgh_number = @lgh AND  
                          stp_status <> 'NON') > 0   
            BEGIN  
                UPDATE stops  
                   SET skip_trigger = 1,   
                       trl_id = 'UNKNOWN',   
                       stp_status = 'NON'   
                 WHERE lgh_number = @lgh AND  
                       stp_number = (SELECT MIN(stp_number)   
                            FROM   stops  
                                     WHERE  lgh_number = @lgh AND  
                                            stp_status <> 'NON')  
            END  
  
            -- make sure any asset assignments and status values are updated on the events  
            UPDATE event   
               SET skip_trigger = 1,  
                   evt_carrier = 'UNKNOWN',   
                   evt_driver1 = 'UNKNOWN',   
                   evt_driver2 = 'UNKNOWN',   
                   evt_tractor = 'UNKNOWN',   
                   evt_trailer1 = 'UNKNOWN',   
                   evt_trailer2 = 'UNKNOWN',   
                   evt_status = 'NON'    
              FROM stops   
             WHERE lgh_number = @lgh AND   
                   stops.stp_number = event.stp_number
        END  
     -- JET - 10/28/99 - PTS #6453  
  
     /*MF pts 4545 - change order status update logic */  
     /* Do not do anything unless order is of status greater than 200(pending)*/  
       
     IF @code > 200  
        BEGIN  
             IF @opn = 0 and (@dispstat = 'IMP' or @dispstat = 'SUS')
                -- do nothing, status should not change
                set @dispstat = @dispstat
             ELSE IF @opn = 0
                SELECT @dispstat = 'CMP'  
             ELSE IF (@dne > 0 or @opn >0) and @dispstat = 'CBR'
				-- jet - 11/04/13 - PTS 73039, a trip release to bond can have completed events, but order status shouldn't change.
				set @dispstat = @dispstat
             ELSE IF @dne > 0
                SELECT @dispstat = 'STD'  
--##  
             ELSE  
                BEGIN  
		    --PTS 36055 2/2/2007, Make this update work for Orders that have been cross docked
                     -- use the max lgh_outstatus   
--                      SELECT @lghcode = max(code)  
--                        FROM legheader, labelfile  
--                       WHERE mov_number = @mov and   
--                             labeldefinition = 'DispStatus' AND  
-- 		           abbr = lgh_outstatus   
		    SELECT @lghcode = max(labelfile.code)  
	            FROM legheader, labelfile , stops 
	            WHERE legheader.lgh_number = stops.lgh_number
		    AND labelfile.abbr = legheader.lgh_outstatus 
		    AND labelfile.labeldefinition = 'DispStatus'
		    AND stops.ord_hdrnumber = @minord
		    AND stops.stp_sequence > 0
		    AND stops.stp_sequence IN (select min (stp_sequence) from stops where stops.ord_hdrnumber = @minord AND stops.stp_sequence > 0)
		   --END PTS 36055

                   /*PTS40873 MBR 01/10/08 Commented out the next section.  Since the order has not been
                                           completed or started from the above IF statements I set the 
                                           ord_status equal to the lgh_outstatus when the lgh_outstatus 
                                           is less than started.  If the lgh_outstatus is >= started I
                                           set the ord_status to planned. */
                    IF @lghcode < 325
                       SELECT @dispstat = abbr
                         FROM labelfile
                        WHERE labeldefinition = 'DispStatus' AND
                              code = @lghcode
                    ELSE IF @lghcode >= 325
												--  BEGIN PTS 49236 SGB 11/05/09
												BEGIN 
													IF @ordStat = 'DSP'
													SET @dispstat = @ordStat
													ELSE
												 SET @dispstat = 'PLN'
                       END
											--  END PTS 49236 SGB 11/05/09	
--                   IF @lghcode > 325 --(STD)   
--                      -- do not set it complete because all the ord stops are not complete  
--                      SELECT @dispstat = 'STD'   
--                   ELSE  
--                      SELECT @dispstat = abbr   
--                        FROM labelfile   
--                       WHERE labeldefinition = 'DispStatus' AND   
--                             code = @lghcode   
                END  
--##  
        END  
       
     /* compute order invoice status Code replaced by PTS 14839 with what follows  
     IF @invwhen = 'STD' AND @dispstat IN ('STD', 'CMP') AND @invstat = 'PND'  
        SELECT @invstat = 'AVL'  
     ELSE IF @invwhen = 'CMP' AND @dispstat = 'CMP' AND @invstat = 'PND'  
        SELECT @invstat = 'AVL'  
     ELSE IF @invwhen IN ('STD', 'CMP') AND @dispstat ='ICO'  
        SELECT @invstat = 'AVL'  
     ELSE IF @invwhen = 'STD' AND @dispstat NOT IN ('STD', 'CMP') AND @invstat = 'AVL'  
        SELECT @invstat = 'PND'  
     ELSE IF @invwhen = 'CMP' AND @dispstat <> 'CMP' AND @invstat = 'AVL'  
        SELECT @invstat = 'PND'  
*/  

--If @invstat = 'PND'  -- don't fiddle with inv status if determined  
-- IF @INVWhen <> UNK added for PTS 31226.
If (@invstat = 'PND' or @invstat = 'AVL') AND @InvWhen <> 'UNK'
Begin
	Select @invstat = 'PND'  --## reset  
	-- When cancelled just move ahead with invoice  
	If @DispStat = 'ICO'  
		Select @invstat = 'AVL'  
	---- if order is cancelled set to do not invoice -------------------  
	Else If @DispStat = 'CAN'  
		Select @invstat = 'XIN'  
	---- Imported or Suspended should have PND invoice status -----------------
	Else If @dispstat = 'IMP' or @dispstat = 'SUS' or @dispstat = 'CBR'
		-- jet - 11/04/13 - PTS 73039, added CBR to the mix for the pending invoice status
		SELECT @invstat = 'PND'
	----- STD look for actualization of the first stop on the order  -----------------
	Else If @InvWhen = 'STD'   
	Begin  
		If @DispStat in ('STD','CMP') Select @invstat = 'AVL'  
	End  
	----- CMP last stop on order is complete-----------------  
	Else If @InvWhen = 'CMP'   
	Begin  
		If @DispStat = 'CMP' Select @invstat = 'AVL'  
	End  
	--PTS 59166 SGB Allow AVL as valid Invoice Status 
	----- AVL last stop on order is complete-----------------  
	Else If @InvWhen = 'AVL'   
	Begin  
		If @DispStat in ('AVL','PLN','DSP','STD','CMP') Select @invstat = 'AVL'  
	End 
	----- TRIPSTD look at the first stop on the leg which contains the first billable stop on the trip -------------------------  
	If @InvWhen = 'TRIPSTD' -- find leg that first order stop is on, get status of first stop on leg  
	Begin  
		Select @lgh = lgh_number
		  From stops 
		 where ord_hdrnumber = @MinOrd and 
		       stp_sequence = 1  
  
		Select @stopstatus = stp_status 
		  From stops 
		 Where lgh_number = @lgh and 
		       stp_mfh_sequence = (Select Min(stp_mfh_sequence) 
									 From stops 
									Where lgh_number = @lgh)  

		If @stopstatus = 'DNE' 
			Select @invstat = 'AVL'  
	End  
	---- PUPSCMP look at the last PUP stop on the order  
	Else If @InvWhen = 'PUPSCMP'   
	Begin  
 		if @completeondeparture = 'Y'	
 			Select @stopstatus = stp_departure_status 
  			  From stops 
  			 where ord_hdrnumber = @MinOrd and 
  				   stp_sequence = (Select MAX(stp_sequence) 
  									 From stops 
  									Where ord_hdrnumber = @MinOrd and 
  										  stp_type = 'PUP')  
		else
 			Select @stopstatus = stp_status 
  			  From stops 
  			 where ord_hdrnumber = @MinOrd and 
  				   stp_sequence = (Select MAX(stp_sequence) 
  									 From stops 
  									Where ord_hdrnumber = @MinOrd and 
  										  stp_type = 'PUP')  

  
		If @stopstatus = 'DNE'   
			Select @invstat = 'AVL'  
	End  
	--vjh PTS 59846
	---- DRPSCMP look at the last DRP stop on the order  
	Else If @InvWhen = 'DRPSCMP'   
	Begin  
		if @completeondeparture = 'Y'	
			Select @stopstatus = stp_departure_status 
			From stops 
			where ord_hdrnumber = @MinOrd and 
			stp_sequence = (Select MAX(stp_sequence) 
							From stops 
							Where ord_hdrnumber = @MinOrd and 
							stp_type = 'DRP')  
		else
			Select @stopstatus = stp_status 
			From stops 
			where ord_hdrnumber = @MinOrd and 
			stp_sequence = (Select MAX(stp_sequence) 
							From stops 
							Where ord_hdrnumber = @MinOrd and 
							stp_type = 'DRP')  


			If @stopstatus = 'DNE'   
				  Select @invstat = 'AVL'  
	 End  	
	---- TRIPCMP look for completion of the last stop on the final leg of the order  
	Else If @InvWhen = 'TRIPCMP' -- find leg that last order stop is on, get status of last stop on leg  
	Begin  
		Select @lgh = lgh_number 
		  From stops 
		 where ord_hdrnumber = @MinOrd and 
		       stp_sequence = (Select max(stp_sequence) 
								 From stops 
								where ord_hdrnumber = @MinOrd)  
  
		if @completeondeparture = 'Y'	
			Select @stopstatus = stp_departure_status 
			  From stops 
			 Where  lgh_number = @lgh and 
					stp_mfh_sequence = (Select Max(stp_mfh_sequence) 
										  From stops 
										 Where lgh_number = @lgh)  
		else
			Select @stopstatus = stp_status
			  From stops 
			 Where  lgh_number = @lgh and 
					stp_mfh_sequence = (Select Max(stp_mfh_sequence) 
										  From stops 
										 Where lgh_number = @lgh)  
   
		If @stopstatus = 'DNE'   
			Select @invstat = 'AVL'  
	End 
	Else If @InvWhen = 'TRIPCMPOLD' -- New option to maintain functionality from before bug looking at CompleteOnDeparture was fixed
	Begin  
	
		Select @lgh = lgh_number 
		  From stops 
		 where ord_hdrnumber = @MinOrd and 
		       stp_sequence = (Select max(stp_sequence) 
								 From stops 
								where ord_hdrnumber = @MinOrd)  
  
		Select @stopstatus = stp_status 
		  From stops 
		 Where  lgh_number = @lgh and 
		        stp_mfh_sequence = (Select Max(stp_mfh_sequence) 
		                              From stops 
		                             Where lgh_number = @lgh)  
   
		If @stopstatus = 'DNE'   
			Select @invstat = 'AVL'  
	End 

	--PTS30295 MBR 10/20/05
	Else If @InvWhen = 'DEPCMP'
	Begin
		Select @stopstatus = ISNULL(stp_departure_status, 'OPN') 
		  from stops 
         where ord_hdrnumber = @MinOrd and
               stp_sequence = (Select MAX(stp_sequence) 
                                 From stops
                                where ord_hdrnumber = @MinOrd)
		If @stopstatus = 'DNE'
			Select @invstat = 'AVL'
	End
 
	--PTS 45980 - DJM - Check for new GI setting to enforce the Service Exception requirements 
	--		before allowing the Order to be invoiced.

	Select @cmpsvcexception = isNull(gi_string1,'N') from generalinfo where gi_name = 'EnableCompanyServiceExceptions'
	if @cmpsvcexception = 'Y'
		Begin
			-- Do not allow the Order to be invoice if there exists a reportable Service Exception on the Order that 
			--		does not have a Exception code AND description entered.  It does not matter if it's an automatically 
			--		generated Exception or a manually entered one.
			if exists (select 1 from serviceexception where sxn_ord_hdrnumber = @minord)
				Begin
					if exists (select 1 from serviceexception where sxn_ord_hdrnumber = @minord and sxn_delete_flag = 'N' and (isNull(sxn_expcode,'UNK') = 'UNK' OR ISNULL(sxn_description,'') = ''))
						Select @invstat = 'PND' 
				End
		
		End
End  


-- TD PTS 15063: Note to any programmer modifying invwhen functionality:  
-- If a programmer changes invwhen functionality, you MUST make sure that  
-- @invstat remains UNCHANGED if @invwhen = 'UNK'.  This is the current   
-- behavior of this routine, and various VB routines will RELY on this  
-- behavior in the future.  (Yes: documenting the bug to make it a feature).  
  
/* dpete pts5804 replace the following with an ISNULL on the SELECT above.  
   JD did this because NULL values were coming thru for @invstat    
 ELSE -- JD added 5/12/99 if all else fails set it to pnd  
  SELECT @invstat = 'PND'  
*/  
     /* LOR PTS#5495 update revtype's on orderheader if REVTYPE..MAX in generalinfo table set to Y */  
     SELECT @revtype1max = gi_string1   
       FROM generalinfo  
      WHERE gi_name = 'REVTYPE1MAX'  
       
     SELECT @revtype2max = gi_string1   
       FROM generalinfo   
      WHERE gi_name = 'REVTYPE2MAX'  
       
     SELECT @revtype3max = gi_string1   
       FROM generalinfo   
      WHERE gi_name = 'REVTYPE3MAX'  
       
     SELECT @revtype4max = gi_string1   
       FROM generalinfo   
      WHERE gi_name = 'REVTYPE4MAX'  
       
     SELECT @revtype1 = ord_revtype1,   
            @revtype2 = ord_revtype2,   
            @revtype3 = ord_revtype3,   
            @revtype4 = ord_revtype4   
       FROM orderheader   
      WHERE ord_hdrnumber = @minord  
       
     IF @revtype1max = 'Y'  
        SELECT @revtype1 = l.abbr   
          FROM labelfile l   
         WHERE l.labeldefinition = 'RevType1' AND   
               l.code = (SELECT MAX(l.code)   
                           FROM labelfile l, company c, stops s   
                          WHERE s.ord_hdrnumber = @minord AND   
                                c.cmp_id = s.cmp_id AND   
                                l.abbr = c.cmp_revtype1 AND   
                                l.labeldefinition = 'RevType1')  
       
     IF @revtype2max = 'Y'  
        SELECT @revtype2 = l.abbr   
          FROM labelfile l   
         WHERE l.labeldefinition = 'RevType2' AND   
               l.code = (SELECT MAX(l.code)   
                           FROM labelfile l, company c, stops s   
                          WHERE s.ord_hdrnumber = @minord AND   
                                c.cmp_id = s.cmp_id AND   
                                l.abbr = c.cmp_revtype2 AND   
                                l.labeldefinition = 'RevType2')  
       
     IF @revtype3max = 'Y'  
        SELECT @revtype3 = l.abbr   
          FROM labelfile l   
         WHERE l.labeldefinition = 'RevType3' AND   
               l.code = (SELECT MAX(l.code)   
                           FROM labelfile l, company c, stops s   
                          WHERE s.ord_hdrnumber = @minord AND   
                                c.cmp_id = s.cmp_id AND   
                                l.abbr = c.cmp_revtype3 AND   
                                l.labeldefinition = 'RevType3')  
       
     IF @revtype4max = 'Y'  
        SELECT @revtype4 = l.abbr   
          FROM labelfile l   
         WHERE l.labeldefinition = 'RevType4' AND   
               l.code = (SELECT MAX(l.code)   
                           FROM labelfile l, company c, stops s   
                          WHERE s.ord_hdrnumber = @minord AND   
                                c.cmp_id = s.cmp_id AND   
                                l.abbr = c.cmp_revtype4 AND   
                                l.labeldefinition = 'RevType4')  
  
    --JD 12/16/99 get the asset information from the event
    --PTS31492 MBR 03/21/06 Added carrier
     Set rowcount 1    
     SELECT @driver1 = evt_driver1,  
	    @driver2 = evt_driver2,         
            @tractor = evt_tractor,  
            @trailer = evt_trailer1,
            @trailer2 = evt_trailer2, --PTS 53315 SGB
            @carrier = evt_carrier 
       FROM stops,event  
      WHERE stops.ord_hdrnumber = @minord and
            stops.stp_sequence = (SELECT MIN(stp_sequence)
                                    FROM stops
                                   WHERE stops.ord_hdrnumber = @minord) AND --PTS66826 MBR 04/25/13
	    stops.stp_number = event.stp_number and
            event.evt_sequence = 1  -- RE - PTS #46253
     set rowcount 0   
    
	--vmj1+	If DatePresentation=4 and the order is started, don't change ord_startdate..
	if @date_presentation = 4
	begin
		select	@li_code = code
		  from	labelfile
		  where	labeldefinition = 'DispStatus'
			and	abbr = @dispstat

		if @li_code >= @li_started_code
			select	@o_date = ord_startdate
			  from	orderheader
			  where	ord_hdrnumber = @minord
	end
	--vmj1-
	
	-- JET - 1/27/09 - PTS 44960, figure out the origin and destination rail ramps
	SELECT @originRailRamp = s1.cmp_id 
	  FROM stops s1 
	 WHERE s1.mov_number = @mov 
	   AND s1.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops s2 join company ON (s2.cmp_id = company.cmp_id and company.cmp_railramp = 'Y') WHERE s1.mov_number = s2.mov_number AND s2.stp_event = 'HLT')
	SET @originRailRamp = ISNULL(@originRailRamp, 'UNKNOWN')

	SELECT @destinationRailRamp = s1.cmp_id 
	  FROM stops s1 
	 WHERE s1.mov_number = @mov 
	   AND s1.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) FROM stops s2 join company ON (s2.cmp_id = company.cmp_id and company.cmp_railramp = 'Y') WHERE s1.mov_number = s2.mov_number AND s2.stp_event = 'DLT')
	   AND s1.cmp_id <> @originRailRamp
	SET @destinationRailRamp = ISNULL(@destinationRailRamp, 'UNKNOWN')
	-- PTS 47124 SGB 04/21/09 remove debug line
	-- select @destinationRailRamp

     UPDATE orderheader  
        SET ord_status = @dispstat,   
            ord_invoicestatus = @invstat,   
            ord_originpoint = @o_cmp,   
            ord_shipper = @o_cmp,   
            ord_origincity = @o_cty,   
            ord_originstate = @o_state,   
            ord_startdate = @o_date,   
            ord_consignee = @d_cmp,   
            ord_destpoint = @d_cmp,   
            ord_destcity = @d_cty,   
            ord_deststate = @d_state,   
            ord_completiondate = @d_ddate,   
            ord_origin_earliestdate = @o_edate,   
            ord_origin_latestdate = @o_ldate,   
            ord_dest_earliestdate = @d_edate,   
            ord_dest_latestdate = @d_ldate,   
            ord_stopcount = @stp_count,   
            ord_revtype1 = @revtype1,   
            ord_revtype2 = @revtype2,   
            ord_revtype3 = @revtype3,   
            ord_revtype4 = @revtype4,  
			ord_driver1  = @driver1,  
			ord_driver2  = @driver2,        
			ord_tractor  = @tractor,  
			ord_trailer  = @trailer,
			ord_trailer2 = @Trailer2, -- PTS 53315
			--PTS31492 MBR 03/21/06 Added carrier
			ord_carrier = @carrier, 
			ord_railramporig = @originRailRamp, 
			ord_railrampdest = @destinationRailRamp
      WHERE ord_hdrnumber = @minord  
  
    -- Code added 9/21/99 by JET to make sure invoice delivery dates are updated along with   
    -- order completion dates.  
    IF @ivhdelor = 1  
     UPDATE invoiceheader   
        SET ivh_deliverydate = @d_ddate  
      WHERE ord_hdrnumber = @minord  

-- PTS 52591  Replace this Third party assignments code ( called from THREE procs ) with a exec proc call 
execute Assign_Third_Party_Defaults_sp @mov		-- pts 52591

---- MRH 30923
---- Third party default assignments
--Declare
--@ord_number char(12),
--@ord_billto char(8), @tpr_id varchar(8)
--Select @lgh = min(lgh_number) from stops where ord_hdrnumber = (SELECT MIN(ord_hdrnumber) FROM stops WHERE mov_number = @mov and ord_hdrnumber <> 0)
--select @ord_number = ord_number, @ord_billto = ord_billto from orderheader where ord_hdrnumber = (SELECT MIN(ord_hdrnumber) FROM stops WHERE mov_number = @mov and ord_hdrnumber <> 0)

---- 36019 BDH:  If the existing auto assigned 3rd party is not the current billto, mark them deleted.
----select tpr_id from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto
----if @tpr_id is null set @tpr_id = ''	
---- PTS 44064 JSwindell 10/27/2008 - don't duplicate 'auto assigned 3rd parties' on a copy
--if (select count(0) from thirdpartyassignment where ord_number = @ord_number and tpa_status = 'AUTO' and tpr_id not in (select tpr_id from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto)) > 0
--begin				
--	update thirdpartyassignment set tpa_status = 'DEL'
--	where ord_number = @ord_number and tpa_status = 'AUTO' and tpr_id not in (select tpr_id from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto)
--end

---- BDH 36019 5/14/07 - Check that the 3rd party is active and if he's auto assigned on the tpassignment count and insert.
---- If he's already in there with a status of DEL, do not auto assign him again.
----if (select count(0) from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto) > 0
--if (select count(tprel_number) from thirdpartyrelationship, thirdpartyprofile
--where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto
--	and thirdpartyprofile.tpr_id = thirdpartyrelationship.tpr_id and isnull(tpr_active, 'Y') = 'Y') > 0
--begin
--	-- if (select count(0) from thirdpartyassignment where ord_number = @ord_number and tpa_status = 'AUTO' and tpa_status <> 'DEL') = 0 and   --44064
--	if (select count(0) from thirdpartyassignment where ord_number = @ord_number and (tpa_status = 'AUTO' or tpa_status = 'AUTOCC') and tpa_status <> 'DEL') = 0 and
--	   (select count(0) from thirdpartyassignment where ord_number = @ord_number and tpa_status = 'DEL' and tpr_id in (select tpr_id from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto)) = 0

--	begin
		
--		-- 36019 BDH.  Inserting pyd_status = 'NPD' instead of null.
--		insert into thirdpartyassignment
--		(tpr_id, lgh_number, mov_number, tpa_status, pyd_status, tpr_type, ord_number)
--		select tpr_id, @lgh, @mov, 'AUTO', 'NPD', tpr_type, @ord_number from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto;
--	end 
--	else -- Check to see if it should be updated
--	begin
--		if (select count(0) from thirdpartyassignment where ord_number = @ord_number and tpa_status <> 'DEL' and tpr_id in (select tpr_id from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto)) = 0 and
--		   (select count(0) from thirdpartyassignment where ord_number = @ord_number and tpa_status = 'DEL' and tpr_id in (select tpr_id from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto)) = 0
--		begin
--			-- No matches found the billto probably changed.
--			-- Delete the existing that were not manually added and add the default
--			update thirdpartyassignment set tpa_status = 'DEL' where ord_number = @ord_number and tpa_status <> 'DEL' and tpa_status = 'AUTO'
--			--delete from thirdpartyassignment where ord_number = @ord_number and tpa_status <> 'DEL' and tpa_status = 'AUTO'
--			insert into thirdpartyassignment
--			(tpr_id, lgh_number, mov_number, tpa_status, pyd_status, tpr_type, ord_number)
--			select tpr_id, @lgh, @mov, 'AUTO', 'NPD', tpr_type, @ord_number from thirdpartyrelationship where tprel_table = 'company.billto' and tprel_tablekey = @ord_billto;
--		end
--	end
--end



END  

GO
GRANT EXECUTE ON  [dbo].[update_ord] TO [public]
GO
