SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  dx_add_neworder_stop inserts or updates stop by DX
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ------------------------------------------------------------------------
  11/15/2016   David Wilks      INT-200078  prevent overwrite of stop event with LLD if previous stop has no trailer
********************************************************************************************************************/


CREATE     PROC [dbo].[dx_add_neworder_stop]
	@validate char(1),
        @move_number int, 
	@stp_sequence int,
	@event varchar(6),   
	@cmp_id varchar(8), @stp_city int,
        @miles_from_prior_stop int, 
	@stp_contact  varchar(30), @stp_phonenumber  varchar(20), 
	@arrivaldate datetime, 	@earlydate datetime, @latedate datetime,
        @cmd_code varchar(8), @cmd_description varchar(60),
	@weight float, @weightunit varchar(6), @count float,
	@countunit varchar(6), @volume float, @volumeunit varchar(6),
	@stp_reftype varchar(6),@stp_refnum varchar(30),
        @fgt_reftype varchar(6), @fgt_refnum varchar(30),
	@stp_delivery_instructions varchar(254),
	@NeverAutoUpdateDates int = 0,
	@@new_move_number int OUTPUT,
        @@stp_number int OUTPUT,
	@@fgt_number int OUTPUT
AS

DECLARE @lgh_number int, @evt_number int, @stp_mfh_sequence int, 
        @pupdrp varchar(8), @cmd_name varchar(60), @cmp_name varchar(30),
	@stp_state varchar(2), @stp_address1 varchar(40), @stp_address2 varchar(40),
	@stp_zip varchar(9), @stplghmiles int, @stpordmiles int, 
	@ord_hdrnumber int, @cmd_gravity float, @retcode int,
	@from_stop varchar(8), @to_stop varchar(8), @stp_loadstatus varchar(3),
	@back_seq int,@midnight datetime, @datediff int		--20081209 AR
DECLARE @updatevalidation int, @UpdatePastDates int, @CopyLegAssetsToNewStop int
set @updatevalidation = 0
set @UpdatePastDates = 0
set @CopyLegAssetsToNewStop = 0

exec @updatevalidation = dx_GetLTSL2Setting 'UpdateValidation'
exec @UpdatePastDates = dx_GetLTSL2Setting 'UpdatePastDates'
exec @CopyLegAssetsToNewStop = dx_GetLTSL2Setting 'CopyLegAssetsToNewStop'

IF EXISTS (SELECT top 1 dx_ident FROM dx_lookup
		WHERE dx_importid = 'dx_204' and dx_lookuptable = 'LtslSettings' 
		and dx_lookuprawdatavalue = 'UpdateValidation' and dx_lookuptranslatedvalue = '1')
		set @updatevalidation = 1
		
DECLARE @ls_stp_weightunit varchar(6), @ls_stp_countunit varchar(6),
		@ls_UseCompanyDefaultEventCodes char(1)

  SELECT @ls_UseCompanyDefaultEventCodes = gi_string1 FROM generalinfo WHERE gi_name = 'UseCompanyDefaultEventCodes'
 

  SELECT @validate = 
     CASE UPPER(ISNULL(@validate,'N'))
       WHEN 'Y' then 'Y'
       WHEN 'I' then 'I'
       ELSE 'N'
     END

  IF @validate = 'I'
  BEGIN
	select @ls_stp_weightunit = ifc_value from interface_constants 
	 where ifc_tablename = 'tempstops' and ifc_columnname = 'stp_weightunit'
	select @ls_stp_countunit  = ifc_value from interface_constants 
	 where ifc_tablename = 'tempstops' and ifc_columnname = 'stp_countunit'
  END

  select @weightunit = case isnull(@weightunit,'') when '' then isnull(@ls_stp_weightunit,'LBS') else @weightunit end
  select @countunit = case isnull(@countunit,'') when '' then isnull(@ls_stp_countunit,'PCS') else @countunit end

  IF @validate = 'Y'
    BEGIN
     IF @arrivaldate IS NULL RETURN -3
     IF @earlydate IS NULL RETURN -3
     IF @latedate IS NULL RETURN -3
     IF @arrivaldate < @earlydate RETURN -4
     IF @arrivaldate > @latedate RETURN -4
    END
  ELSE
    BEGIN
     SELECT @arrivaldate = ISNULL(@arrivaldate,GETDATE())
     SELECT @earlydate = ISNULL(@earlydate,'1-1-50 00:00')
     SELECT @latedate = ISNULL(@latedate,@arrivaldate)
    END

  SELECT @pupdrp = fgt_event, @from_stop = mile_typ_from_stop, @to_stop = mile_typ_to_stop
    FROM eventcodetable 
   WHERE abbr=@event
  IF @validate != 'N'
    BEGIN
      IF @pupdrp IS NULL RETURN -6
    END

  SELECT @stp_loadstatus = NULL
  IF @stp_sequence = 1
	SELECT @stp_loadstatus = CASE @from_stop WHEN 'LD' THEN 'LD' ELSE 'MT' END
  ELSE
  BEGIN
    IF @to_stop IN ('NONE','UND')
    BEGIN
		SELECT @back_seq = @stp_sequence - 1
		WHILE @back_seq > 0
		BEGIN
			SELECT @stp_loadstatus = LEFT(mile_typ_from_stop, 3)
			  FROM eventcodetable
			 WHERE abbr = (SELECT TOP 1 stp_event FROM stops WITH(NOLOCK) WHERE mov_number = @move_number AND stp_sequence = @back_seq ORDER BY stp_number DESC)
			IF @stp_loadstatus NOT IN ('NON','UND') BREAK
			SELECT @back_seq = @back_seq - 1
		END
		IF @back_seq = 0 SELECT @stp_loadstatus = 'LD'
    END
    ELSE
		SELECT @stp_loadstatus = LEFT(@to_stop, 3)
  END
  SELECT @pupdrp = ISNULL(@pupdrp,'DRP')

  IF @validate = 'I' and isnull(@@stp_number, 0) > 0  --EDI UPDATE ROUTINE
  BEGIN
    IF @ls_UseCompanyDefaultEventCodes = 'Y'
	  BEGIN
		  SELECT @cmp_id = cmp_id FROM stops WHERE stp_number = @@stp_number
		  IF @pupdrp = 'PUP'
			  SELECT @event = IsNull(ltsl_default_pickup_event,@event)
			FROM company WHERE cmp_id = @cmp_id and ltsl_default_pickup_event <> ''
		  IF @pupdrp = 'DRP'
			  SELECT @event = IsNull(ltsl_default_delivery_event,@event)
	   		FROM company WHERE cmp_id = @cmp_id and ltsl_default_delivery_event <> ''
	  END

	if @event = 'LLD' -- keep current event value if previous stop is a "no trailer event" so does not support LLD on the current stop
		begin
		  select @event = s.stp_event 
		  from stops s with (nolock) 
		  left join stops s1 with (nolock) on s1.stp_mfh_sequence = s.stp_mfh_sequence - 1 and s1.mov_number = @move_number
		  join eventcodetable ect with (nolock) on s1.stp_event = ect.abbr and ect_bt_start = 'Y'
		  where s.stp_number = @@stp_number
		end
	select @midnight =  CONVERT(smalldatetime,convert(varchar(10),@arrivaldate,101))
	If @updatevalidation = 1 
		UPDATE stops
		   SET stp_arrivaldate = case when @arrivaldate = @midnight and DATEDIFF(dd , stp_arrivaldate, @arrivaldate) > 0 
	   		then DATEADD(dd,DATEDIFF(dd , stp_arrivaldate, @arrivaldate),stp_arrivaldate) when @arrivaldate = @midnight then @arrivaldate else @arrivaldate end
			 , stp_schdtearliest = case when @earlydate = @midnight and DATEDIFF(dd,stp_schdtearliest,@earlydate) > 0
	     		then DATEADD(dd,DATEDIFF(dd,stp_schdtearliest,@earlydate),stp_schdtearliest) when @earlydate = @midnight then stp_schdtearliest else @earlydate end
			 , stp_schdtlatest = case when @latedate = @midnight and DATEDIFF(dd,stp_schdtlatest,@latedate) > 0
	     		then DATEADD(dd,DATEDIFF(dd,stp_schdtlatest,@latedate),stp_schdtlatest) when @latedate = @midnight then stp_schdtlatest else @latedate end
			 , stp_departuredate = case when @arrivaldate = @midnight and DATEDIFF(dd,stp_departuredate,@arrivaldate) > 0
	     		then DATEADD(dd,DATEDIFF(dd,stp_departuredate,@arrivaldate),stp_departuredate) when @arrivaldate = @midnight then stp_departuredate else @arrivaldate end
			 , stp_type = @pupdrp
			 , stp_event = @event
			 , stp_loadstatus = @stp_loadstatus
		 WHERE stp_number = @@stp_number
    ELSE
		IF IsNull(@NeverAutoUpdateDates,0) = 0
			UPDATE stops
			SET stp_arrivaldate = case when @arrivaldate < getdate() and @UpdatePastDates = 0 then stp_arrivaldate when @arrivaldate = @midnight and DATEDIFF(dd , stp_arrivaldate, @arrivaldate) > 0 
	   			then DATEADD(dd,DATEDIFF(dd , stp_arrivaldate, @arrivaldate),stp_arrivaldate)when @arrivaldate = @midnight then @arrivaldate else @arrivaldate end
			 , stp_schdtearliest = case when @earlydate < getdate() and @UpdatePastDates = 0 then stp_schdtearliest when @earlydate = @midnight and DATEDIFF(dd,stp_schdtearliest,@earlydate) > 0
	     		then DATEADD(dd,DATEDIFF(dd,stp_schdtearliest,@earlydate),stp_schdtearliest) when @earlydate = @midnight and @UpdatePastDates = 0 then stp_schdtearliest else @earlydate end
			 , stp_schdtlatest = case when @latedate < getdate() and @UpdatePastDates = 0 then stp_schdtlatest when @latedate = @midnight and DATEDIFF(dd,stp_schdtlatest,@latedate) > 0
	     		then DATEADD(dd,DATEDIFF(dd,stp_schdtlatest,@latedate),stp_schdtlatest) when @latedate = @midnight and @UpdatePastDates = 0 then stp_schdtlatest else @latedate end
			 , stp_departuredate = case when @arrivaldate < getdate() and @UpdatePastDates = 0 then stp_departuredate when @arrivaldate = @midnight and DATEDIFF(dd,stp_departuredate,@arrivaldate) > 0
	     		then DATEADD(dd,DATEDIFF(dd,stp_departuredate,@arrivaldate),stp_departuredate) when @arrivaldate = @midnight and @UpdatePastDates = 0 then stp_departuredate else @arrivaldate end
			 , stp_type = @pupdrp
			 , stp_event = @event
			 , stp_loadstatus = @stp_loadstatus
			WHERE stp_number = @@stp_number
			AND (stp_status <> 'DNE' or @UpdatePastDates = 1)
		ELSE
			UPDATE stops
				SET  stp_type = @pupdrp
			 , stp_event = @event
			 , stp_loadstatus = @stp_loadstatus
		 WHERE stp_number = @@stp_number
		   AND stp_status <> 'DNE'
	
	IF @@ERROR <> 0 RETURN -1
	IF ISNULL(@stp_reftype,'') > '' AND ISNULL(@stp_refnum,'') > ''
		UPDATE stops
		   SET stp_reftype = @stp_reftype
		     , stp_refnum = @stp_refnum
		 WHERE stp_number = @@stp_number
	RETURN 1
  END

  SELECT @cmd_code = CASE ISNULL(@cmd_code,'') WHEN '' THEN 'UNKNOWN' ELSE UPPER(RTRIM(@cmd_code)) END

  IF @validate != 'N' AND @cmd_code <> 'UNKNOWN'
  BEGIN
      SELECT @cmd_gravity = ISNULL(cmd_specificgravity, 0.0) FROM commodity WHERE cmd_code = @cmd_code
      IF @@ROWCOUNT = 0
      BEGIN
      --IF (SELECT COUNT(1)
      --    FROM commodity
      --    WHERE cmd_code = @cmd_code) = 0
         IF @validate = 'I' SELECT @cmd_code = 'UNKNOWN' ELSE RETURN -5
      END
  END

  IF ISNULL(@cmd_description,'') = ''
  BEGIN
      IF @cmd_code <> 'UNKNOWN'
	  SELECT @cmd_name = ISNULL(cmd_name,'UNKNOWN'), @cmd_gravity = ISNULL(cmd_specificgravity, 0.0)
	  FROM commodity 
	  WHERE cmd_code=@cmd_code
  END
  ELSE
  BEGIN
      IF @cmd_code = 'UNKNOWN'
	  SELECT @cmd_code = ISNULL(cmd_code,'UNKNOWN'), @cmd_gravity = ISNULL(cmd_specificgravity, 0.0)
	  FROM commodity
	  WHERE cmd_name = @cmd_description
      SELECT @cmd_name = @cmd_description, @cmd_code = isnull(@cmd_code,'UNKNOWN')
  END

  SELECT @cmd_name = CASE ISNULL(@cmd_name,'') WHEN '' THEN 'UNKNOWN' ELSE @cmd_name END

   /* determine address information from the company if provided    */
  IF @validate != 'N'
    BEGIN
      IF NOT EXISTS(SELECT top 1 cmp_id
          FROM company
          WHERE cmp_id = @cmp_id) 
        RETURN -7
    END
  
 IF @cmp_id = 'UNKNOWN'
   BEGIN
     SELECT @stp_address1 = ''
     SELECT @stp_address2 = ''
     IF @stp_city > 0 
		SELECT @stp_zip =  cty_zip from city WHERE cty_code = @stp_city
	 ELSE 
		SELECT @stp_zip = ''
     SELECT @cmp_name = 'UNKNOWN'
     IF @validate != 'N'
       BEGIN
         IF NOT EXISTS (SELECT top 1 cty_code
             FROM city
             WHERE cty_code = @stp_city)
           RETURN -8
       END
     SELECT @stp_state=ISNULL(cty_state,'') 
     FROM city 
     WHERE cty_code=@stp_city
     
   END
 ELSE
   SELECT @stp_address1 = cmp_address1,
          @stp_address2 = cmp_address2,
          @stp_zip = cmp_zip,
          @cmp_name = cmp_name,
          @stp_city = cmp_city,
          @stp_state = ISNULL(city.cty_state,''),
          @stp_contact = case ISNULL(@stp_contact,'') when '' then ISNULL(cmp_contact,'') else @stp_contact end,
          @stp_phonenumber = case ISNULL(@stp_phonenumber,'') when '' then ISNULL(cmp_primaryphone,'') else @stp_phonenumber end
   FROM company LEFT JOIN city
     ON company.cmp_city = city.cty_code
   WHERE cmp_id = @cmp_id
 
 IF @validate = 'Y'
   BEGIN
     IF LEN(RTRIM(@stp_reftype)) > 0 AND 
        EXISTS (SELECT top 1 abbr
         FROM labelfile
         WHERE labeldefinition = 'ReferenceNumbers'
         AND abbr = @stp_reftype)
        RETURN -9
     IF LEN(RTRIM(@fgt_reftype)) > 0 AND 
        EXISTS (SELECT abbr
         FROM labelfile
         WHERE labeldefinition = 'ReferenceNumbers'
         AND abbr = @fgt_reftype)
        RETURN -10
    END

 SELECT @fgt_reftype = UPPER(ISNULL(@fgt_reftype,''))
 SELECT @fgt_refnum = UPPER(@fgt_refnum)
 SELECT @stp_reftype = UPPER(ISNULL(@stp_reftype,''))
 SELECT @stp_refnum = UPPER(@stp_refnum)

  /* assign control numbers */
 SELECT @stplghmiles = 0, @stpordmiles = 0, @ord_hdrnumber = 0
 
  IF @stp_sequence = 1
     BEGIN
       EXEC @@new_move_number = dbo.getsystemnumber 'MOVNUM',NULL
       EXEC @lgh_number = dbo.getsystemnumber 'LEGHDR',NULL
     END
  ELSE
    BEGIN
       SELECT @@new_move_number = @move_number
       IF @@new_move_number = 0 RETURN -2
       IF exists (SELECT top 1 stp_number FROM stops WITH(NOLOCK)
		    WHERE mov_number = @move_number AND stp_sequence = @stp_sequence - 1 AND cmp_id = @cmp_id AND stp_city = @stp_city)
		   SELECT @stplghmiles = CASE ISNULL(@miles_from_prior_stop,0) WHEN 0 THEN -1 ELSE @miles_from_prior_stop END
				, @stpordmiles = CASE ISNULL(@miles_from_prior_stop,0) WHEN 0 THEN -1 ELSE @miles_from_prior_stop END
       SELECT @lgh_number = MAX(lgh_number), @ord_hdrnumber = MAX(ord_hdrnumber)
           FROM stops WITH(NOLOCK)
           WHERE mov_number = @@new_move_number
       IF @lgh_number IS NULL RETURN -2
       IF @ord_hdrnumber IS NULL SELECT @ord_hdrnumber = 0
    END

  EXEC @@stp_number = dbo.getsystemnumber 'STPNUM',NULL 
  EXEC @@fgt_number = dbo.getsystemnumber 'FGTNUM',NULL
  EXEC @evt_number = dbo.getsystemnumber 'EVTNUM',NULL

  IF @validate = 'I' AND ISNULL(@weightunit,'') = 'LBS' and ISNULL(@weight,0.0) > 0.0 and ISNULL(@volume,0.0) = 0.0 and ISNULL(@cmd_gravity,0.0) > 0.0
       SELECT @volume = CEILING(CEILING(@weight) / CEILING(@cmd_gravity)), @volumeunit = 'GAL'

INSERT INTO freightdetail 
	( stp_number, fgt_sequence, fgt_number, 		--1	
	cmd_code, fgt_description, fgt_reftype, 		--2
	fgt_refnum,fgt_pallets_in, 				--3
	fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1, --4	
	fgt_carryins2, skip_trigger, fgt_quantity,		--5
	fgt_weight, fgt_weightunit, fgt_count,			--6
	fgt_countunit, fgt_volume, fgt_volumeunit,
	fgt_rate, fgt_rateunit, fgt_charge, fgt_unit, cht_itemcode)		--7
	
VALUES ( @@stp_number, 1, @@fgt_number, 				--1
	@cmd_code, isnull(@cmd_name,'UNKNOWN'), @fgt_reftype,			--2
	@fgt_refnum,0,					--3
	0, 0, 0,						--4
	0, 1, 0,						--5
	@weight, @weightunit, @count,				--6
	@countunit, @volume, @volumeunit,
	0, '', 0, '', 'UNK')			--7 

SELECT @retcode = @@error
  IF @retcode<>0
    BEGIN
	exec dx_log_error 0, 'INSERT INTO freightdetail Failed', @retcode, ''
	IF (@validate != 'N') GOTO ERROR_EXIT    
        ELSE RETURN -1
            
    END

	declare @Driver VARCHAR(8), @Driver2 VARCHAR(8), @Tractor varchar(8), @TrailerID varchar(13), @PupID varchar(13), @Carrier varchar(8), @status varchar(3)
	set @Driver = 'UNKNOWN'
	set @Driver2 = 'UNKNOWN'
	set @Tractor = 'UNKNOWN'
	set @TrailerID = 'UNKNOWN'
	set @PupID = 'UNKNOWN'
	set @Carrier = 'UNKNOWN'
	


  IF @stp_sequence = 1
	SELECT @stp_mfh_sequence = @stp_sequence
  ELSE
  BEGIN
	SELECT @back_seq = @stp_sequence - 1
	SELECT TOP 1 @stp_mfh_sequence = stp_mfh_sequence, @lgh_number = lgh_number, @status = stp_status FROM stops WITH(NOLOCK) WHERE mov_number = @move_number AND stp_sequence = @back_seq ORDER BY stp_mfh_sequence DESC
	SET @stp_mfh_sequence = @stp_mfh_sequence + 1
  END
  if IsNull(@status,'') <> 'NON'
	set @status = 'OPN'
	
if @CopyLegAssetsToNewStop = 1 
	select @Driver = IsNull(lgh_driver1, 'UNKNOWN'), @Tractor = IsNull(lgh_tractor, 'UNKNOWN'), @TrailerID = IsNull(lgh_primary_trailer, 'UNKNOWN'), 
		@Driver2 = IsNull(lgh_driver2, 'UNKNOWN'), @PupID = IsNull(lgh_primary_pup, 'UNKNOWN'), @Carrier = IsNull(lgh_carrier, 'UNKNOWN') 
		from legheader_active where lgh_number = @lgh_number

INSERT INTO event 
	( evt_driver1, evt_driver2, evt_tractor, 		--1
	evt_trailer1, evt_trailer2, ord_hdrnumber, 		--2
	stp_number, evt_startdate, evt_earlydate, 		--3
	evt_latedate, evt_enddate, evt_reason, 			--4
	evt_carrier, evt_sequence, fgt_number, 			--5
	evt_number, evt_pu_dr, evt_eventcode, 			--6
	evt_status , skip_trigger, evt_departure_status,--7
	evt_mov_number)									--8		--AR NS#117178
values (@Driver, @Driver2, @Tractor,
	@TrailerID, @PupID, @ord_hdrnumber,	@@stp_number, @arrivaldate, @earlydate,
	@latedate, @arrivaldate, 'UNK',
	@Carrier, 1, @@fgt_number,
	@evt_number, @pupdrp, @event,
	@status , 1, @status,@@new_move_number)

SELECT @retcode = @@error
  IF @retcode<>0
    BEGIN
	exec dx_log_error 0, 'INSERT INTO event Failed', @retcode, ''
	IF @validate != 'N'
	    GOTO ERROR_EXIT
        ELSE
            RETURN -1
    END

--increment stp_mfh_sequence of subsequent stops if any before inserting this stp_mfh_sequence value
declare @minstpmfhsequence int
set @minstpmfhsequence = @stp_mfh_sequence - 1
update stops set stp_mfh_sequence = stp_mfh_sequence + 1
	where mov_number = @move_number 
	and stp_mfh_sequence > @minstpmfhsequence 

--increment stp_sequence of subsequent stops if any before inserting this stp_sequence value
declare @minstpsequence int
set @minstpsequence = @stp_mfh_sequence - 1
update stops set stp_sequence = stp_sequence + 1
	where mov_number = @move_number 
	and stp_sequence > @minstpsequence 

INSERT INTO stops 
	( trl_id, ord_hdrnumber, stp_number, 			--1
	stp_city, stp_arrivaldate, stp_schdtearliest, 		--2
	stp_schdtlatest, cmp_id, cmp_name, 			--3
	stp_departuredate, stp_reasonlate, lgh_number, 		--4
	stp_reasonlate_depart, stp_sequence, stp_mfh_sequence, 	--5	
	cmd_code, stp_description, stp_type, 			--6
	stp_event, stp_status, mfh_number, 			--7
	mov_number, stp_origschdt, stp_paylegpt, 		--8
	stp_region1, stp_region2, stp_region3, 			--9
	stp_region4, stp_state, stp_lgh_status, 		--10
	stp_reftype, stp_refnum,stp_loadstatus, 		--11
	stp_phonenumber, stp_delayhours, stp_zipcode, 		--12
	stp_ooa_stop, stp_address, stp_contact,	--13
	 skip_trigger,						--14
	stp_weight, stp_weightunit, stp_count,                  --15 
	stp_countunit, stp_volume, stp_volumeunit, 		--16
        stp_ord_mileage, stp_lgh_mileage ,stp_lgh_sequence,      --17
	stp_comment, stp_departure_status                                               --18
	)
VALUES 	( @TrailerID, @ord_hdrnumber, @@stp_number, 		--1
	@stp_city, @arrivaldate, @earlydate,			--2 
	@latedate, @cmp_id, isnull(@cmp_name,'UNKNOWN'),				--3 
	@arrivaldate, 'UNK', @lgh_number, 			--4
	'UNK', @stp_sequence, @stp_mfh_sequence, 		--5
	@cmd_code, @cmd_name, @pupdrp, 				--6
	@event, @status, 0, 					--7
	@@new_move_number, @arrivaldate, 'Y', 			--8
	'UNK', 'UNK', 'UNK', 					--9
	'UNK', @stp_state, 'AVL', 				--10
	@stp_reftype,@stp_refnum, @stp_loadstatus, 			--11
	@stp_phonenumber, 0, @stp_zip,				--12 
	0, @stp_address1, @stp_contact, 			--13
	 1, 					                --14
	isnull(@weight,0), @weightunit, isnull(@count,0),				--15
	@countunit, @volume, @volumeunit,			--16
        @stpordmiles,@stplghmiles,0 ,        --17
	@stp_delivery_instructions, @status                             --18
	)

SELECT @retcode = @@error
  IF @retcode<>0
    BEGIN
	exec dx_log_error 0, 'INSERT INTO stop Failed', @retcode, ''
        IF @validate != 'N'
	    GOTO ERROR_EXIT
        ELSE
            RETURN -1
    END

  /* add stop and freight ref numbers */
  IF ISNULL(@stp_reftype,'') <> '' AND ISNULL(@stp_refnum,'') <> ''
    BEGIN 

      INSERT INTO referencenumber(
	ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ref_table,
	ref_sid,
	ref_pickup)
     VALUES  (@@stp_number,
	@stp_reftype,
	@stp_refnum,
	1,
	'stops',
	'Y',
	Null)
   END

  IF ISNULL(@fgt_reftype,'') <> '' AND ISNULL(@fgt_refnum,'') <> ''
    BEGIN 
      
      INSERT INTO referencenumber(
	ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ref_table,
	ref_sid,
	ref_pickup)
      VALUES  (@@fgt_number,
	@fgt_reftype,
	@fgt_refnum,
	1,
	'freightdetail',
	'Y',
	Null)
    END

  RETURN 1



ERROR_EXIT:
   IF @@new_move_number > 0
     EXEC purge_delete @@new_move_number,0
   SELECT 'ERROR :imported stop:',@@new_move_number
   RETURN -1

GO
GRANT EXECUTE ON  [dbo].[dx_add_neworder_stop] TO [public]
GO
