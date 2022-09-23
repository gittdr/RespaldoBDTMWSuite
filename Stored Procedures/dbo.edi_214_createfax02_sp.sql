SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*  MODIFICATION LOG

BLEVON 16419 -- NEW (new format for EDI_214)  (as requested by Express - 1)

BLEVON -- PTS 16223 -- allow for 'All' option on 'ref_table' and 'ref_type' on EDI_214_profile table
*/

CREATE         PROCEDURE [dbo].[edi_214_createfax02_sp]
 @ord_hdrnumber		char(12),
 @stp_number		integer,
 @e214p_activity	varchar(6),
 @e214stp_level		varchar(3),
 @ckc_number		int,
 @firstlastflags	varchar(20),
 @contactname		varchar(25),
-- PTS 16223 -- BL (start)
 @company_id		varchar(8),
-- PTS 16223 -- BL (end)
 @messageout		varchar(5000) output
AS

 
DECLARE @shipper  varchar(30),
 @consignee     varchar(30),
 @stp_contact varchar(30),
 @weight int,
 @pieces int,
 @volume int,
 @weightunit varchar(6),
 @pieceunit varchar(6),
 @protect       datetime,
 @fgtdescription     varchar(30),
 @fgtweight dec(8,1),
 @fgtweightunit varchar(6),
 @fgtcount int,
 @fgtcountunit varchar(6),
 @fgtvolume decimal(8,1),
 @fgtvolumeunit varchar(6),
 @StatusDateTime datetime,
 @stp_arrivaldate datetime,
 @stp_departuredate datetime,
 @TimeZone varchar(2),
 @StatusCity integer,
 @TractorID varchar(13),
 @Trailerid varchar(13),
 @StatusReason varchar(3),
 @stp_sequence varchar(3),
 @stpsequence int,
 @StopReferenceNumber varchar(15),
 @stopcmpid varchar(8),
 @stopevent varchar(6),
 @stp_type varchar(6),
 @driverID varchar(8),
 @msg     varchar(5000),
 @ord_number varchar(12),
 @podname    varchar(20),
 @lghnumber int,
 @ord_origin_earliestdate datetime,
 @ord_origin_latestdate datetime,
 @ord_dest_earliestdate datetime,
 @ord_dest_latestdate datetime,
 @stop_companyname varchar(100),
 @eventcode_abbr_name varchar(60),
 @stp_city_name varchar(18),
 @stp_state varchar(6),
 @comment varchar(500),
 @ord_billto varchar(8),
 @labelfile_name varchar(20),
 @ref_number varchar(30),
 @ref_number_count int,
 @billto_cmp_name varchar(1000)

/*   get information FROM orderheader  */
SELECT @shipper = ISNULL(a.cmp_name,' '),
 @consignee  =  ISNULL(b.cmp_name,' '),
 @weightunit = ISNULL(ord_totalweightunits,' '),
 @pieceunit = ISNULL(ord_totalcountunits,' '),
 @ord_number = ord_number,
 @ord_origin_earliestdate = ord_origin_earliestdate,
 @ord_origin_latestdate = ord_origin_latestdate,
 @ord_dest_earliestdate = ord_dest_earliestdate,
 @ord_dest_latestdate = ord_dest_latestdate,
 @ord_billto = ord_billto
FROM orderheader,company a,company b
WHERE ord_hdrnumber = @ord_hdrnumber and
      a.cmp_id = orderheader.ord_shipper and
      b.cmp_id = orderheader.ord_consignee 

-- get total weight, count and volumn
SELECT @weight = ISNULL(sum(fgt_weight),0),
 @pieces = ISNULL(sum(fgt_count),0),
 @volume = ISNULL(sum(fgt_volume),0)
FROM   freightdetail,stops
WHERE  stops.ord_hdrnumber = @ord_hdrnumber and
    stops.stp_type = 'DRP' and
    freightdetail.stp_number = stops.stp_number 

-- Get weight units, count units, and volumn units
SELECT @fgtweightunit = ISNULL(min(fgt_weightunit), ''),
 @fgtcountunit = ISNULL(min(fgt_countunit), ''),
 @fgtvolumeunit = ISNULL(min(fgt_volumeunit), '')
FROM freightdetail fd, stops stp
WHERE stp.ord_hdrnumber = @ord_hdrnumber and
    stp.stp_type = 'DRP' and
    fd.stp_number = stp.stp_number 

--Get stops information
 SELECT  @stopcmpid = stops.cmp_id,
  @stop_companyname = (select cmp_name from company cp where cp.cmp_id =  stops.cmp_id),
  @stopevent = stp_event,
  @StatusReason = 'NS',
  @TimeZone = 'LT',
  @StatusCity = stp_city,
  @stp_sequence = convert(varchar(3),stp_sequence),
  @stpsequence = stp_sequence,
  @StopReferenceNumber = substring(stp_refnum,1,15),
  @stp_arrivaldate = stops.stp_arrivaldate,
  @stp_departuredate = stp_departuredate,
  @stp_type = stp_type,
  @stp_contact = stp_contact,
  @protect = stp_custdeliverydate,
  @podname = ISNULL(stp_podname ,' '),
  @eventcode_abbr_name = (select ev.abbr + ' - ' + ev.name from eventcodetable ev where ev.abbr = stp_event),
  @stp_city_name = (select cty_name from city where cty_code = stp_city),
  @stp_state = stp_state
 FROM  stops          
 WHERE  stops.stp_number = @stp_number 

/*  get equipment assigned */
SELECT  @tractorid = 
   CASE ISNULL(evt_tractor,'UNKNOWN')
    WHEN 'UNKNOWN' Then ''
    Else evt_tractor
   END,
  @Trailerid = 
   CASE ISNULL(evt_trailer1,'UNKNOWN')
    WHEN 'UNKNOWN' Then ''
    When evt_tractor Then ' '
    Else evt_trailer1
   END,
  @driverID = evt_driver1
FROM event
WHERE stp_number = @stp_number and evt_sequence = 1
 
-- Get the Comment for 'Format 2'
SELECT @comment = Comment_text
FROM EDI_214_FaxFormat
WHERE Format_ID = 2;

           
-- ===========================================
/* build the text of the email message */
-- ===========================================

-- Comment Section
-------------------------------------------------------------------------

SELECT @msg = 'Comments: ' + char(10) + char(13)

SELECT @msg =  @msg + isnull(@comment, '')

SELECT @msg =  @msg + char(10) + char(13)

SELECT @msg =  @msg + char(10) + char(13)

SELECT @msg =  @msg + char(10) + char(13)


-- Order Header Section
-------------------------------------------------------------------------

SELECT @msg =  @msg + 'Order Header Information: ' + char(10) + char(13)

-- Line is 80 characters long
SELECT @msg =  @msg + '________________________________________________________________________________' + char(10) + char(13)

SELECT @msg =  @msg + char(10) + char(13)

SELECT @msg =  @msg + 'Order No. / Pro No.    ' +  isnull(@ord_number,'') + char(10) + char(13)

--JLB PTS 27367 add billto to the message
Select @billto_cmp_name = cmp_name
  from company
 where cmp_id = @ord_billto
SELECT @msg =  @msg + 'BillTo:                ' +  isnull(@billto_cmp_name,'UNKNOWN') + char(10) + char(13)
--end 27367

SELECT @msg =  @msg + char(10) + char(13)

SELECT @msg =  @msg + 'Shipper:               ' +  isnull(@shipper,'') + char(10) + char(13)

SELECT @msg =  @msg + 'Pickup Earliest:       ' +  ISNULL(convert(varchar(8), @ord_origin_earliestdate ,1) + space(3) + convert(varchar(5), @ord_origin_earliestdate ,108),'') + char(10) + char(13)

SELECT @msg =  @msg + 'Pickup Latest:         ' +  ISNULL(convert(varchar(8), @ord_origin_latestdate ,1) + space(3) + convert(varchar(5), @ord_origin_latestdate ,108),'') + char(10) + char(13)

SELECT @msg =  @msg + char(10) + char(13)

SELECT @msg =  @msg + 'Congsignee:            ' +  isnull(@consignee,'')    + char(10) + char(13)

SELECT @msg =  @msg + 'Drop Earliest:         ' +  ISNULL(convert(varchar(8), @ord_dest_earliestdate ,1) + space(3) + convert(varchar(5), @ord_dest_earliestdate ,108),'') + char(10) + char(13)

SELECT @msg =  @msg + 'Drop Latest:           ' +  ISNULL(convert(varchar(8), @ord_dest_latestdate ,1) + space(3) + convert(varchar(5), @ord_dest_latestdate ,108),'') + char(10) + char(13)

SELECT @msg =  @msg + char(10) + char(13)

-- Get ALL 'orderheader' REF #'s for the given Order if:
--    Order's bill_to matches the EDI bill_to
DECLARE order_refno CURSOR FOR
-- PTS 16223 -- BL (start)
--    SELECT lbl.name, ref_number
--    FROM referencenumber ref, process_requirements pr, labelfile lbl
--    WHERE ref.ref_type = pr.prq_reftype
--      AND ref.ref_table = pr.prq_reftable
--      AND ref.ref_type = lbl.abbr
--      AND pr.prq_reftable = 'orderheader'
--      AND lbl.labeldefinition = 'ReferenceNumbers'
--      AND pr.prq_billto = @ord_billto
--      AND ref.ref_tablekey = @ord_hdrnumber
   SELECT lbl.name, ref_number
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_type = pr.prq_reftype
     AND ref.ref_table = pr.prq_reftable
     AND ref.ref_type = lbl.abbr
     AND pr.prq_reftable = 'orderheader'
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_billto = @company_id
     AND ref.ref_tablekey = @ord_hdrnumber
UNION
   SELECT lbl.name, ref_number
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_type = pr.prq_reftype
     AND ref.ref_type = lbl.abbr
     AND pr.prq_reftable = '^all^'
     AND ref.ref_table = 'orderheader'
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_billto = @company_id
     AND ref.ref_tablekey = @ord_hdrnumber
UNION
   SELECT lbl.name, ref_number
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_table = pr.prq_reftable
     AND ref.ref_type = lbl.abbr
     AND pr.prq_reftype = '^ALL^'
     AND pr.prq_reftable = 'orderheader'
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_billto = @company_id
     AND ref.ref_tablekey = @ord_hdrnumber
UNION
   SELECT lbl.name, ref_number
   FROM referencenumber ref, process_requirements pr, labelfile lbl
   WHERE ref.ref_type = lbl.abbr
     AND pr.prq_reftype = '^ALL^'
     AND pr.prq_reftable = '^all^'
     AND ref.ref_table = 'orderheader'
     AND lbl.labeldefinition = 'ReferenceNumbers'
     AND pr.prq_billto = @company_id
     AND ref.ref_tablekey = @ord_hdrnumber
-- PTS 16223 -- BL (end)

OPEN order_refno
FETCH NEXT FROM order_refno 
   INTO @labelfile_name, @ref_number

SELECT @ref_number_count = 0

-- See if any records exist
IF @@FETCH_STATUS = 0 
   BEGIN
      -- Create Loop to get (specified) Order Header Reference numbers
      WHILE @@FETCH_STATUS = 0
         BEGIN  /* while looping thru cursor */
            SELECT @ref_number_count = @ref_number_count + 1
            IF @ref_number_count = 1
               SELECT @msg = @msg + 'Order Ref Type / #:    ' + left(@labelfile_name + space(20), 20) + @ref_number + char(10) + char(13)
            ELSE
               SELECT @msg = @msg + '                       ' + left(@labelfile_name + space(20), 20) + @ref_number + char(10) + char(13)

            FETCH NEXT FROM order_refno 
               INTO @labelfile_name, @ref_number
         END  /* while looping thru cursor */
   END /* WHILE FETCH STATUS */
CLOSE order_refno
DEALLOCATE order_refno

SELECT @msg =  @msg + char(10) + char(13)

SELECT @msg =  @msg + 'Truck No:              ' +  isnull(@TractorID,'') + char(10) + char(13)

SELECT @msg =  @msg + char(10) + char(13)

SELECT @msg =  @msg + char(10) + char(13)


-- Stop / Freight Detail Section
-------------------------------------------------------------------------

SELECT @msg =  @msg + 'Stop / Freight Detail Information: ' + char(10) + char(13)

-- Line is 80 characters long
SELECT @msg =  @msg + '________________________________________________________________________________' + char(10) + char(13)

SELECT @msg =  @msg + char(10) + char(13)

SELECT @msg =  @msg + 'Event:           ' +  isnull(@eventcode_abbr_name,'') + char(10) + char(13)

SELECT @msg =  @msg + 'Company Name:    ' +  isnull(@stop_companyname,'') + char(10) + char(13)

SELECT @msg =  @msg + 'City / State:    ' +  isnull(@stp_city_name,'') + ', ' + isnull(@stp_state,'') + char(10) + char(13)

SELECT @msg =  @msg + 'Arrival:         ' +  ISNULL(convert(varchar(8), @stp_arrivaldate ,1) + space(3) + convert(varchar(5), @stp_arrivaldate ,108),'') + '   Actual' + char(10) + char(13)

-- Alter the e-mail contents based upon the event being an ARRIVAL to a stop
--   or a DEPARTURE from a stop
--     (if the email is a 'notification of the arrival at a stop', 
--        then the departure time will be 'estimated')
IF @e214p_activity = 'ARV'
   SELECT @msg =  @msg + 'Departure:       ' +  ISNULL(convert(varchar(8), @stp_departuredate ,1) + space(3) + convert(varchar(5), @stp_departuredate ,108),'') + '   Estimated' + char(10) + char(13)

IF @e214p_activity = 'DEP'
   SELECT @msg =  @msg + 'Departure:       ' +  ISNULL(convert(varchar(8), @stp_departuredate ,1) + space(3) + convert(varchar(5), @stp_departuredate ,108),'') + '   Actual' + char(10) + char(13)

-- Dont show the following lines if the event is a 'Pickup Arrival'
IF @e214p_activity = 'DEP' or @stp_type = 'DRP'
   BEGIN
      IF @pieces IS NOT NULL and @pieces <> 0
         SELECT @msg =  @msg + 'Pieces:          ' +  left(ltrim(str(isnull(@pieces,0))) + space(10), 10) + @fgtcountunit + char(10) + char(13)

      IF @weight IS NOT NULL and @weight <> 0
         SELECT @msg =  @msg + 'Weight:          ' +  left(ltrim(str(isnull(@weight,0))) + space(10), 10) + @fgtweightunit + char(10) + char(13)

      IF @volume IS NOT NULL and @volume <> 0
         SELECT @msg =  @msg + 'Volume:          ' +  left(ltrim(str(isnull(@volume,0))) + space(10), 10) + @fgtvolumeunit + char(10) + char(13)

      SELECT @msg =  @msg + 'POD:             ' +  isnull(@podname,'') + char(10) + char(13)

	-- Get ALL 'freightdetail' REF #'s for the given Order if:
	--    Order's bill_to matches the EDI bill_to
	DECLARE freightdetail_refno CURSOR FOR
-- PTS 16223 -- BL (start)
-- 	   SELECT lbl.name, ref_number
-- 	   FROM referencenumber ref, process_requirements pr, labelfile lbl,
-- 	      freightdetail fd, stops stp
-- 	   WHERE ref.ref_type = pr.prq_reftype
-- 	     AND ref.ref_table = pr.prq_reftable
-- 	     AND ref.ref_type = lbl.abbr
-- 	     AND fd.stp_number = stp.stp_number
-- 	     AND ref.ref_tablekey = fd.fgt_number
-- 	     AND pr.prq_reftable = 'freightdetail'
--              AND lbl.labeldefinition = 'ReferenceNumbers'
-- 	     AND stp.stp_number = @stp_number
-- 	     AND pr.prq_billto = @ord_billto
	   SELECT lbl.name, ref_number
	   FROM referencenumber ref, process_requirements pr, labelfile lbl,
	      freightdetail fd, stops stp
	   WHERE ref.ref_type = pr.prq_reftype
	     AND ref.ref_table = pr.prq_reftable
	     AND ref.ref_type = lbl.abbr
	     AND fd.stp_number = stp.stp_number
	     AND ref.ref_tablekey = fd.fgt_number
	     AND pr.prq_reftable = 'freightdetail'
             AND lbl.labeldefinition = 'ReferenceNumbers'
	     AND stp.stp_number = @stp_number
	     AND pr.prq_billto = @company_id
	UNION
	   SELECT lbl.name, ref_number
	   FROM referencenumber ref, process_requirements pr, labelfile lbl,
	      freightdetail fd, stops stp
	   WHERE ref.ref_type = pr.prq_reftype
	     AND ref.ref_type = lbl.abbr
	     AND fd.stp_number = stp.stp_number
	     AND ref.ref_tablekey = fd.fgt_number
	     AND pr.prq_reftable = '^all^'
	     AND ref.ref_table = 'freightdetail'
             AND lbl.labeldefinition = 'ReferenceNumbers'
	     AND stp.stp_number = @stp_number
	     AND pr.prq_billto = @company_id
	UNION
	   SELECT lbl.name, ref_number
	   FROM referencenumber ref, process_requirements pr, labelfile lbl,
	      freightdetail fd, stops stp
	   WHERE ref.ref_table = pr.prq_reftable
	     AND ref.ref_type = lbl.abbr
	     AND fd.stp_number = stp.stp_number
	     AND ref.ref_tablekey = fd.fgt_number
	     AND pr.prq_reftype = '^ALL^'
	     AND pr.prq_reftable = 'freightdetail'
             AND lbl.labeldefinition = 'ReferenceNumbers'
	     AND stp.stp_number = @stp_number
	     AND pr.prq_billto = @company_id
	UNION
	   SELECT lbl.name, ref_number
	   FROM referencenumber ref, process_requirements pr, labelfile lbl,
	      freightdetail fd, stops stp
	   WHERE ref.ref_type = lbl.abbr
	     AND fd.stp_number = stp.stp_number
	     AND ref.ref_tablekey = fd.fgt_number
	     AND pr.prq_reftype = '^ALL^'
	     AND pr.prq_reftable = '^all^'
	     AND ref.ref_table = 'freightdetail'
             AND lbl.labeldefinition = 'ReferenceNumbers'
	     AND stp.stp_number = @stp_number
	     AND pr.prq_billto = @company_id
-- PTS 16223 -- BL (end)
	
	OPEN freightdetail_refno
	FETCH NEXT FROM freightdetail_refno 
	   INTO @labelfile_name, @ref_number
	
        SELECT @ref_number_count = 0

	-- See if any records exist
	IF @@FETCH_STATUS = 0 
	   BEGIN
	      -- Create Loop to get (specified) Freight Detail Reference numbers
	      WHILE @@FETCH_STATUS = 0
	         BEGIN  /* while looping thru cursor */
	            SELECT @ref_number_count = @ref_number_count + 1
	            IF @ref_number_count = 1
	               SELECT @msg = @msg + 'Ref Type / #:    ' + left(@labelfile_name + space(20), 20) + @ref_number + char(10) + char(13)
	            ELSE
	               SELECT @msg = @msg + '                 ' + left(@labelfile_name + space(20), 20) + @ref_number + char(10) + char(13)
	
	            FETCH NEXT FROM freightdetail_refno 
	               INTO @labelfile_name, @ref_number
	         END  /* while looping thru cursor */
	   END /* WHILE FETCH STATUS */
	CLOSE freightdetail_refno
	DEALLOCATE freightdetail_refno

	-- Get ALL 'stops' REF #'s for the given Order if:
	--    Order's bill_to matches the EDI bill_to
	DECLARE stops_refno CURSOR FOR
-- PTS 16223 -- BL (start)
-- 	   SELECT lbl.name, ref_number
-- 	   FROM referencenumber ref, process_requirements pr, labelfile lbl,
-- 	      stops stp
-- 	   WHERE ref.ref_type = pr.prq_reftype
-- 	     AND ref.ref_table = pr.prq_reftable
-- 	     AND ref.ref_type = lbl.abbr
-- 	     AND ref.ref_tablekey = stp.stp_number
-- 	     AND pr.prq_reftable = 'stops'
--              AND lbl.labeldefinition = 'ReferenceNumbers'
-- 	     AND stp.stp_number = @stp_number
-- 	     AND pr.prq_billto = @ord_billto
	   SELECT lbl.name, ref_number
	   FROM referencenumber ref, process_requirements pr, labelfile lbl,
	      stops stp
	   WHERE ref.ref_type = pr.prq_reftype
	     AND ref.ref_table = pr.prq_reftable
	     AND ref.ref_type = lbl.abbr
	     AND ref.ref_tablekey = stp.stp_number
	     AND pr.prq_reftable = 'stops'
             AND lbl.labeldefinition = 'ReferenceNumbers'
	     AND stp.stp_number = @stp_number
	     AND pr.prq_billto = @company_id
	UNION	
	   SELECT lbl.name, ref_number
	   FROM referencenumber ref, process_requirements pr, labelfile lbl,
	      stops stp
	   WHERE ref.ref_type = pr.prq_reftype
	     AND ref.ref_type = lbl.abbr
	     AND ref.ref_tablekey = stp.stp_number
	     AND pr.prq_reftable = '^all^'
	     AND ref.ref_table = 'stops'
             AND lbl.labeldefinition = 'ReferenceNumbers'
	     AND stp.stp_number = @stp_number
	     AND pr.prq_billto = @company_id
	UNION	
	   SELECT lbl.name, ref_number
	   FROM referencenumber ref, process_requirements pr, labelfile lbl,
	      stops stp
	   WHERE ref.ref_table = pr.prq_reftable
	     AND ref.ref_type = lbl.abbr
	     AND ref.ref_tablekey = stp.stp_number
	     AND pr.prq_reftype = '^ALL^'
	     AND pr.prq_reftable = 'stops'
             AND lbl.labeldefinition = 'ReferenceNumbers'
	     AND stp.stp_number = @stp_number
	     AND pr.prq_billto = @company_id
	UNION	
	   SELECT lbl.name, ref_number
	   FROM referencenumber ref, process_requirements pr, labelfile lbl,
	      stops stp
	   WHERE ref.ref_type = lbl.abbr
	     AND ref.ref_tablekey = stp.stp_number
	     AND pr.prq_reftype = '^ALL^'
	     AND pr.prq_reftable = '^all^'
	     AND ref.ref_table = 'stops'
             AND lbl.labeldefinition = 'ReferenceNumbers'
	     AND stp.stp_number = @stp_number
	     AND pr.prq_billto = @company_id
-- PTS 16223 -- BL (end)
	
	OPEN stops_refno
	FETCH NEXT FROM stops_refno 
	   INTO @labelfile_name, @ref_number
	
	-- See if any records exist
	IF @@FETCH_STATUS = 0 
	   BEGIN
	      -- Create Loop to get (specified) Stops Detail Reference numbers
	      WHILE @@FETCH_STATUS = 0
	         BEGIN  /* while looping thru cursor */
	            SELECT @ref_number_count = @ref_number_count + 1
	            IF @ref_number_count = 1
	               SELECT @msg = @msg + 'Ref Type / #:    ' + left(@labelfile_name + space(20), 20) + @ref_number + char(10) + char(13)
	            ELSE
	               SELECT @msg = @msg + '                 ' + left(@labelfile_name + space(20), 20) + @ref_number + char(10) + char(13)
	
	            FETCH NEXT FROM stops_refno 
	               INTO @labelfile_name, @ref_number
	         END  /* while looping thru cursor */
	   END /* WHILE FETCH STATUS */
	CLOSE stops_refno
	DEALLOCATE stops_refno
   END

SELECT @msg =  @msg + char(10) + char(13)

SELECT @msg =  @msg + char(10) + char(13)

SELECT @msg =  @msg + 'End of Update.' + char(10) + char(13)


-- Return the full message
SELECT @messageout = @msg


GO
GRANT EXECUTE ON  [dbo].[edi_214_createfax02_sp] TO [public]
GO
