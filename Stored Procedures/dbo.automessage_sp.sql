SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/*  MODIFICATION LOG

DPETE 11562 Change getting POD Name from last PUP to current drop (if the activity stop is a drop). If
    current stop is a drop use its info

DPETE 11587 add trailer and depart consignee date to output
*/

CREATE PROCEDURE [dbo].[automessage_sp]
	@ord_hdrnumber 		char(12),
	@stp_number		integer,
        @e214p_activity         varchar(6),
	@e214stp_level          varchar(3),
       	@ckc_number		int,
  	@firstlastflags		varchar(20),
	@contactname            varchar(25),
	@messageout             varchar(5000) output
AS

 
DECLARE @LastDRPSeq  int,
	@FirstPUPSeq  int,
	@drop_stpnum int,
	@shipper  varchar(30),
	@consignee     varchar(30),
	@bol      varchar(30),
	@control  varchar(30),
	@stp_contact varchar(30),
        @weight int,
	@pieces int,
	@volume int,
	@weightunit varchar(6),
	@pieceunit varchar(6),
	@pickuparrival      datetime,
	@pickupdeparture       datetime,
	@delarrival datetime,
	@deldeparture datetime,
	@protect       datetime,
	@fgtdescription     varchar(30),
	@fgtcompany   varchar(30),
	@lastcompany  varchar(30),
	@fgtweight	dec(8,1),
	@fgtweightunit	varchar(6),
	@fgtcount	int,
	@fgtcountunit	varchar(6),
	@fgtvolume	decimal(8,1),
	@fgtvolumeunit	varchar(6),
	@StatusDateTime datetime,
	@stp_schdtearliest datetime,
	@stp_arrivaldate datetime,
        @stp_departuredate datetime,
        @next_drp_arrivaldate datetime,
	@next_pup_arrivaldate datetime,
	@stp_schdtlatest datetime,
	@TimeZone varchar(2),
	@StatusCity integer,
	@TractorID varchar(13),
	@MCUnitNumber int,
	@Trailerid varchar(13),
	@StatusReason varchar(3),
	@stp_sequence varchar(3),
	@stpsequence int,
	@StopWeight integer,
	@StopQuantity integer,
	@StopReferenceNumber varchar(15),
	@ordhdrnumber integer,
	@stopcmpid varchar(8),
	@n101code varchar(2),
	@fgtnumber int,
	@stopevent varchar(6),
	@stopreasonlate varchar(6),
	@stopreasonlatedepart varchar(6),
        @e214_activity varchar(6),
	@next_status char(3),
  	@start_pos int,
	@charindex int,
	@stp_type varchar(6),
	@next_stp_arrivaldate datetime,
	@cancel_flag char(1),
	@min varchar(50),
	@getdate datetime,
	@docid varchar(30),
	@stopposition varchar(10),
	@last_ckcall datetime,
	@driverID varchar(8),
	@countit int,
	@PUPArvLabel   char(12),
	@PUPDepLabel   char(12),
	@DRPArvLabel   char(12),
	@DRPDepLabel   char(12),
	@msg     varchar(1124),
	@ord_number varchar(12),
	@ckc_location varchar(60),
	@systemowner varchar(30),
	@ProNumberPrefix varchar(10),
	@last_pupstp  int,
	@podname    varchar(20),
	@displayPUPArvDate datetime,
	@dispalyPUPDepDate datetime,
	@displayDRPArvDate datetime,
	@displayDRPDepDate datetime,
	@lghnumber int

/* determine system owner for customer specific requirements */

  SELECT @systemowner = UPPER(RTRIM(gi_string1))
  FROM generalinfo
  WHERE gi_name = 'SystemOwner'

/* CTX requires an X820 in front of the order number */
  SELECT  @ProNumberPrefix = ''
  SELECT @systemowner = ISNULL(@systemowner,'TMW')
  IF @systemowner = 'CTX' SELECT @ProNumberPrefix = 'X820 '

/*   get information FROM orderheadr  */
SELECT @shipper = ISNULL(a.cmp_name,' '),
	@consignee  =  ISNULL(b.cmp_name,' '),
	@bol   =  ISNULL((SELECT max(ref_number) FROM referencenumber WHERE ref_table = 'orderheader' and
		  ref_type in ('BOL','BL#') and ref_tablekey = @ord_hdrnumber),''),
	@control  = ISNULL((SELECT max(ref_number) FROM referencenumber WHERE ref_table = 'orderheader' and
		  ref_type = 'AETC' and ref_tablekey = @ord_hdrnumber),''),
	@weightunit = ISNULL(ord_totalweightunits,' '),
	@pieceunit = ISNULL(ord_totalcountunits,' '),
	@ord_number = ord_number
FROM orderheader,company a,company b
WHERE ord_hdrnumber = @ord_hdrnumber and
      a.cmp_id = orderheader.ord_shipper and
      b.cmp_id = orderheader.ord_consignee	

--get total weight,count and volumn
SELECT @weight = ISNULL(sum(fgt_weight),0),
	@pieces = ISNULL(sum(fgt_count),0),
	@volume = ISNULL(sum(fgt_volume),0)
from   freightdetail,stops
where  stops.ord_hdrnumber = @ord_hdrnumber and
		stops.stp_type = 'DRP' and
	freightdetail.stp_number = stops.stp_number 

/* get information from current stop */

--Get stops information
     /* Note the strange CASE on stp_departure is because of CTX and thie stp_eta, stp_etd fields */
	SELECT  @stopcmpid = stops.cmp_id,	
		@stopevent = stp_event,
		@StatusReason = 'NS',
        	@TimeZone = 'LT',
		@StatusCity = stp_city,
		@stp_sequence = convert(varchar(3),stp_sequence),
		@stpsequence = stp_sequence,
		@StopReferenceNumber = substring(stp_refnum,1,15),
		@stp_arrivaldate = stops.stp_arrivaldate,
      @stp_departuredate = 
			CASE
				WHEN stp_departuredate > stp_arrivaldate Then stp_departuredate
				ELSE stp_arrivaldate
			END,
      @stp_type = stp_type,
		@PUPArvLabel = case when stp_sequence > @FirstPUPSeq then  'P/U In:     ' else
			  case when stp_status = 'DNE' then 'P/U in:     ' else 'P/U ETA:    ' end end,
		@PUPDepLabel = case when stp_sequence > @FirstPUPSeq then  'P/U Out:    ' else
			  case when stp_departure_status = 'DNE' then 'P/U Out:    ' else 'P/U ETD:     ' end end,
		@DRPArvLabel = 
			CASE
				When stp_sequence < @LastDRPSeq Then 'Del ETA:    '
				ELSE
					CASE
					WHEN stp_type = 'PUP' Then 'Del ETA:    '
					WHEN @systemOwner = 'CTX' and stp_departure_status = 'DNE' and CHARINDEX('99',@firstlastflags ) > 0 Then 'Del In:    '
					WHEN @systemowner = 'CTX' Then 'Del ETA:    ' 
					WHEN stp_status = 'DNE' Then 'Del In:    '
					ELSE 'Del ETA:    '
					END
			END,
		@DRPDepLabel = 
			CASE
				When stp_sequence < @LastDRPSeq Then 'Del ETD:    '
				ELSE
					CASE
					WHEN stp_type = 'PUP' Then 'Del ETD:    '
					WHEN @systemOwner = 'CTX' and stp_status = 'DNE' and CHARINDEX('99',@firstlastflags ) > 0  Then 'Del Out:    '
					WHEN @systemowner = 'CTX' Then 'Del ETD:    '
					WHEN stp_departure_status = 'DNE' Then 'Del Out:    '
					ELSE 'Del ETD:    '
					END
			END,
		@stp_contact = stp_contact,
		@protect = stp_custdeliverydate,
		@podname = ISNULL(stp_podname	,' ')	  
	FROM 	stops          
	WHERE	 stops.stp_number = @stp_number 

/*  get equipment assigned */
 SELECT  @tractorid = 
			CASE ISNULL(evt_tractor,'UNKNONW')
				WHEN 'UNKNOWN' Then ''
				Else evt_tractor
			END,
		@Trailerid = 
			CASE ISNULL(evt_trailer1,'UNKNONW')
				WHEN 'UNKNOWN' Then ''
				When evt_tractor Then ' '
				Else evt_trailer1
			END,
		@driverID = evt_driver1
  FROM event
  WHERE stp_number = @stp_number and evt_sequence = 1
	
	
      
--Find First pickup stop
SELECT @FirstPUPSeq =  min(stp_sequence)
FROM   stops
WHERE  ord_hdrnumber = @ord_hdrnumber and
		stp_type = 'PUP'

/* If the current stop is a PUP, use its dates for pick up.  If it is not a PUP, use the first PUP dates */
IF   @stp_type = 'PUP' 
  BEGIN
	SELECT @pickuparrival = @stp_arrivaldate
	SELECT @pickupdeparture = @stp_departuredate
  END
	
ELSE
  SELECT  	@pickuparrival = stp_arrivaldate,
       		@pickupdeparture = stp_departuredate
	FROM  stops
	WHERE ord_hdrnumber = @ord_hdrnumber and
	stp_sequence = @FirstPUPSeq


--Find the last drop stops
SELECT @LastDRPSeq =  max(stp_sequence)
FROM stops
WHERE ord_hdrnumber = @ord_hdrnumber and
	 stp_type = 'DRP'

/* use current stop if it is a drop for dellivery dates, pod , if it is not, use the last drop stop */
IF @stp_type  = 'DRP'
  BEGIN
	SELECT @delarrival = @stp_arrivaldate
	SELECT @deldeparture = @stp_departuredate
  END
ELSE
  SELECT @delarrival = stp_arrivaldate,
	 	 	@deldeparture = stp_departuredate,
			@protect = stp_custdeliverydate,
			@podname = ISNULL(stp_podname	,' '),
			@stp_contact = stp_contact
	FROM stops
	Where ord_hdrnumber = @ord_hdrnumber and
		stp_sequence = @LastDRPSeq

	
/* If this is not a location report get last location report info */
	IF @e214p_activity <> 'CKCALL'
	  BEGIN
	     SELECT @last_ckcall = MAX(ckc_date)
             FROM   checkcall
             WHERE  ckc_tractor = @tractorID
			AND ckc_asgnid = @driverID
			AND ckc_updatedby = 'TMAIL'
	        AND ckc_asgntype = 'DRV'
			AND ckc_event = 'TRP'

	    	IF @last_ckcall IS NOT NULL
				SELECT @ckc_number = ckc_number,
	  			@ckc_location = ISNULL(ckc_commentlarge,'')
				FROM checkcall
            WHERE  ckc_tractor = @tractorID
				AND ckc_asgnid = @driverID
				AND ckc_updatedby = 'TMAIL'
	        AND ckc_asgntype = 'DRV'
				AND ckc_event = 'TRP'
				AND ckc_date = @last_ckcall
	   	ELSE
				SELECT @ckc_location = ' '
	  END

	IF @e214p_activity = 'CKCALL'
	    SELECT @ckc_location = ISNULL(ckc_commentlarge,''),
		@last_ckcall =ckc_date
	    FROM checkcall
            WHERE  ckc_number = @ckc_number
	
          
/* build the text of the email message */


SELECT @msg =  'Shipper:    ' +  isnull(@shipper,'') + char(10) + char(13)

SELECT @msg = @msg + 'Congsignee: ' +  isnull(@consignee,'')    + char(10) + char(13)

SELECT @msg = @msg + 'Truck No:   ' +  isnull(@TractorID,'') + char(10) + char(13)

If @trailerid > '' SELECT @msg = @msg + 'Trailer:    ' +  isnull(@trailerid,'') + char(10) + char(13)

SELECT @msg = @msg + 'Pro No:     ' +  @ProNumberPrefix + isnull(@ord_number,'') + char(10) + char(13)

SELECT @msg = @msg + 'B.O.L.No:   ' +  isnull(@bol,'') + char(10) + char(13)

SELECT @msg = @msg + 'POD Name:   ' +  isnull(@podname,'') + char(10) + char(13)

IF @pieces IS NOT NULL and @pieces <> 0
	SELECT @msg = @msg + 'Total Count:     ' +  str(isnull(@pieces,0)) + char(10) + char(13)

IF @weight IS NOT NULL and @weight <> 0
	SELECT @msg = @msg + 'Total Weight:     ' +  str(isnull(@weight,0)) + char(10) + char(13)

IF @volume IS NOT NULL and @volume <> 0
	SELECT @msg = @msg + 'Total Volume:     ' +  str(isnull(@volume,0)) + char(10) + char(13)


SELECT @msg = @msg + @PUPArvLabel + ISNULL(convert(varchar(8),@pickuparrival,1) + space(3) + convert(varchar(5),@pickuparrival,108),'') + char(10) + char(13)

SELECT @msg = @msg + @PUPDepLabel +  ISNULL(convert(varchar(8),@pickupdeparture,1) + space(3) + convert(varchar(5),@pickupdeparture,108),'') + char(10) + char(13)

SELECT @msg = @msg + @DRPArvLabel +  ISNULL(convert(varchar(8),@delarrival,1) + space(3) + convert(varchar(5),@delarrival,108),'') + char(10) + char(13)

SELECT @msg = @msg + @DRPDepLabel +  ISNULL(convert(varchar(8),@deldeparture,1) + space(3) + convert(varchar(5),@deldeparture,108),'') + char(10) + char(13)

IF @systemowner = 'CTX' and @protect is not null and @protect > ' '
	  SELECT @msg = @msg + 'Protect:    ' + ISNULL( convert(varchar(8),@protect,1) + space(3) + convert(varchar(5),@protect,108),'') + char(10) + char(13)
 
IF @systemowner = 'CTX'
	SELECT @msg = @msg  + 'Control #:  ' + ISNULL( @control + isnull(@stp_contact,''),'') + char(10) + char(13)




IF @last_ckcall is not null 
	BEGIN
	  SELECT @msg = @msg  + 'Last location report: '  +  ISNULL(convert(varchar(8),@last_ckcall,1),REPLICATE(' ',8)) + space(3) + ISNULL(convert(varchar(5),@last_ckcall,108),REPLICATE(' ',8)) +' - '+ ISNULL(@ckc_location ,'') + char(10) + char(13)

	END


SELECT @lastcompany = ' '
DECLARE frgt_cursor CURSOR FOR 
	SELECT  ISNULL(company.cmp_name,'(not specified)'),ISNULL(fgt_description,'UNKNOWN'),ISNULL(fgt_count,0),ISNULL(fgt_countunit,'UNK'),ISNULL(fgt_weight,0),ISNULL(fgt_weightunit,'UNK'),ISNULL(fgt_volume,0),ISNULL(fgt_volumeunit,'UNK')
	FROM freightdetail,stops,company
	WHERE stops.ord_hdrnumber = @ord_hdrnumber
			and stp_type = 'DRP'
			and freightdetail.stp_number = stops.stp_number
			AND company.cmp_id = stops.cmp_id
	ORDER BY stp_sequence, fgt_sequence

  	OPEN frgt_cursor
	FETCH NEXT FROM frgt_cursor 
	INTO @fgtcompany,@fgtdescription ,@fgtcount,@fgtcountunit,@fgtweight,@fgtweightunit,@fgtvolume,@fgtvolumeunit

	IF @@FETCH_STATUS = 0 
	  BEGIN /* WHILE FETCH STATUS */
					
		WHILE @@FETCH_STATUS = 0
		  BEGIN  /* while looping thru cursor */		
		       IF @fgtdescription  <> 'UNKNOWN'
			 BEGIN  /* if fgt description is provided */
			    IF LEN(RTRIM(@lastcompany)) = 0
				BEGIN
				SELECT @msg = @msg + char(13) + char(10)
				SELECT @msg = @msg + 'Freight delivery detail:' + char(13) + char(10)
				END
			    IF @fgtcompany = @lastcompany SELECT @fgtCompany = ' '

			    IF @fgtcount > 0
				BEGIN
			        SELECT @msg = @msg + ISNULL(REPLICATE (' ',8)+SUBSTRING(@fgtcompany,1,25) + REPLICATE (' ',25 - LEN(SUBSTRING(@fgtcompany,1,25)))
					+'  '+CONVERT(varchar(8),@fgtcount)+' '+@fgtcountunit
					+ ' - ' + SUBSTRING(@fgtdescription,1,30),'')

				END
			    ELSE
				IF @fgtweight > 0

			        SELECT @msg = @msg + ISNULL(REPLICATE (' ',8)+SUBSTRING(@fgtcompany,1,25) + REPLICATE (' ',25 - LEN(SUBSTRING(@fgtcompany,1,25)))
					+'  '+CONVERT(varchar(8),@fgtweight)+' '+@fgtweightunit
					+ ' - ' + SUBSTRING(@fgtdescription,1,30),'')

				ELSE
					IF @fgtvolume > 0

			        	SELECT @msg = @msg + ISNULL(REPLICATE (' ',8)+SUBSTRING(@fgtcompany,1,25) + REPLICATE (' ',25 - LEN(SUBSTRING(@fgtcompany,1,25)))
					+'  '+CONVERT(varchar(8),@fgtvolume)+' '+@fgtvolumeunit
					+ ' - ' + SUBSTRING(@fgtdescription,1,30),'')

			   SELECT @msg = @msg + char(13) + char(10)
			 END   /* if fgt description is provided */
		     	FETCH NEXT FROM frgt_cursor 
			INTO @fgtcompany,@fgtdescription ,@fgtcount,@fgtcountunit,@fgtweight,@fgtweightunit,@fgtvolume,@fgtvolumeunit

		  END  /* while looping thru cursor */
		END /* WHILE FETCH STATUS */
		CLOSE frgt_cursor
	        DEALLOCATE frgt_cursor

SELECT @messageout = @msg




GO
GRANT EXECUTE ON  [dbo].[automessage_sp] TO [public]
GO
