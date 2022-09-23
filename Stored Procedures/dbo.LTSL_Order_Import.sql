SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  procedure [dbo].[LTSL_Order_Import] (@user_id varchar(20), @batch_number int)
as
-- Currently defined order types:
--      SET      Treated as Original if the order does not already exist, update otherwise.
--      ORIGINAL Creates the order
--      CANCEL   Cancels a prior order
--      UPDATE   Updates a prior order
--      START    Starts a prior order
-- 12/24/01 TD Structural change to do each order one at a time instead of trying to batch
--      up.  This should simplify everything, but will especially allow multiple versions of
--      one order within a single batch.  Also added a new order type: SET.  SET is like 
--      UPDATE, except that instead of erroring it will switch to NEW if the order is 
--      missing.  Also defined the various error codes as follows:
--       0: No error
--      -1: Problem with Prior version of order.
--      -2: User cancelled
--      -3: Note creation error
--      -4: Cargo creation error
--      -5: Reference number creation error.
--      -6: Empty batch
--      -7: Unknown error (should never happen).
--      -8: Bad Order data.
--
-- 10/9/01 TD Significant changes made to clean up Rating information.
--      NOTE: toh_ord_quantity_type field has NO relation to ord_quantity_type
--      field.  This field is a jam field used to turn on some customer
--      specific processing.  Instead the ord_quantity_type interface constant
--      corresponds to that field (see PTS 6408).  Note that because this field
--      has already been used as a jam flag field, it will be available for other
--      jams in the future.  Currently defined values:
--           0: Normal processing
--           >0: USF Logistics special processing
--           -1: Do not put toh_refnum in order reference #1.
--           -2: Rate by Total override
--           -3: Combines -1 and -2
--           -4: Rate by Detail override
--           -5: Combines -1 and -4
--           -6 & -7: Permanently Undefined: DO NOT USE!
--           -8 and beyond: Reserved.
--      NOTE 2: For Rate by Total Mode, all rating info must be provided on the
--      order header.
--      NOTE 3: Added two new Order Types: SET and IGNORE.  SET is treated as NEW
--      if the order already exists, or UPDATE if not.  IGNORE orders are treated
--      as though they weren't even in the table.
-- 6/20/00 TD Significant changes made to order matching procedure used
--	during updates.  Be careful before shipping this out to clients
--  using this for order import instead of LTSL.
declare 
        @today_date        datetime,    @genesis           datetime,    @trailer          varchar(12),
        @refnum         varchar(20),    @reftype         varchar(6),    @err_message     varchar(254),
        @drv1            varchar(8),    @drv2            varchar(8),    @trc               varchar(8),
	@car		 varchar(8),    @trl            varchar(13),    @trl2           varchar(13),   
	@error_type        varchar(6),  @ord_type        varchar(8),    @ord_status      varchar(3),    
	@upd_ord_stat_parm varchar(3),  @stp_status      varchar(3),    @seq_number             int,
        @max_seq_number         int,    @max_refseq_number      int,    @stp_number               int,
        @max_stp_number         int,    @ord_number             int,    @max_ord_number           int,
        @mov_number             int,    @pws_ordhdrnumber       int,    @ord_cancelnumber         int,
        @ord_hdrnumber          int,    @lgh_hdrnumber          int,    @disp_seq                 int,
        @disp_seq_check         int,    @dest_city              int,    @org_city                 int,
        @dest_state      varchar(2),    @org_state       varchar(2),    @duplicate                int,
        @edictn         varchar(20),    @shipper         varchar(8),    @rCounter                 int,
        @stop_city              int,    @data_validation_flag   int,    @data_validation_count    int,
  @stop_company    varchar(8),    @stop_count             int,    @ord_counter              int,
        @freight_number         int,    @batch                  int,    @vtc_cmdcode      varchar(12),
        @vtc_weight           float,    @vtc_weightunit     char(6),    @vtc_description  varchar(64),
        @vtc_volume           float,    @vtc_volumeunit     char(6),    @vtc_sequence             int,
        @vtc_count              int,    @vtc_countunit      char(6),
        @vtc_rate             money,    @vtc_rateunit       char(6),    @vtc_charge             money,
        @vtc_quantity         float,    @vtc_quantityunit   char(6),    @note_number              int,
        @note_sequence          int,    @note_text        char(255),    @tc_sequence              int,
        @ts_sequence            int,    @ltsl_halt_indicator    int,    @fgtcount                 int,
        @ordnumfromref          int,    @li_returnorder         int,    @ls_edictkey       varchar(8),
        @main_refseq_number     int,    @fgt_refnum     varchar(20),    @fgt_reftype       varchar(6),
        @ord_reftype     varchar(6),    @ord_refnum     varchar(20),    @stp_reftype       varchar(6),
        @stp_refnum     varchar(20),    @fgt_main_refseq        int,    @vtc_chargetype    varchar(6), 
        @lgh_type1       varchar(6),    @jamflag                int,    @ord_rateby              char,
        @last_ord_number        int,    @jamnewfields  varchar(254),

/* Constants to hold trhe constant values from the interface_constants table */
    -- OrderHeader Constants
        @ls_ord_customer        varchar(8), @ls_ord_supplier         varchar(8), @ls_ord_revtype1         varchar(8),
        @ls_ord_revtype2        varchar(8), @ls_ord_revtype3         varchar(8), @ls_ord_revtype4         varchar(8),
        @ls_ord_remark        varchar(254), @ls_ord_lengthunit       varchar(8), @ls_ord_widthunit        varchar(8),
        @ls_ord_heightunit      varchar(8), @ls_ord_totalweightunits varchar(8), @ls_ord_totalvolumeunits varchar(8),
        @ls_ord_totalcountunits varchar(8), @ls_ord_unit             varchar(8), @ls_ord_tempunits        varchar(8),
        @ls_ord_rateunit        varchar(8), @ls_cht_itemcode         varchar(8), @ls_ref_sid                 char(1), 
        @ls_ref_pickup             char(1), @ls_ord_rateby              char(1), @ls_screenmode           varchar(6),
        @ls_ord_billto          varchar(8), @ls_ord_orderby          varchar(8), @ls_ord_terms            varchar(6),
        @ls_ord_priority        varchar(6), @ls_ord_subcompany       varchar(8), @ls_trl_type1            varchar(6),
        @ls_quantity_type              int,

    -- Stop Constants
        @ls_stp_weightunit      varchar(8), @ls_stp_countunit        varchar(8),

    -- Freight Constants

    -- General Constants
        @li_retries                    int, @li_try                         int, @ls_emailsendto        varchar(255),
        @ls_emailcopyto       varchar(255), @ls_revtypesource           char(1)

--- Read the constants from the interface table
select @ls_ord_customer = ifc_value from interface_constants 
where  ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_customer'

select @ls_ord_supplier = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_supplier'

select @ls_ord_revtype1 = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_revtype1'

select @ls_ord_revtype2 = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_revtype2'

select @ls_ord_revtype3 = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_revtype3'

select @ls_ord_revtype4 = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_revtype4'

select @ls_ord_remark 	= ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_remark'

if @batch_number < 0 

        select @ls_ord_remark   = ifc_value from interface_constants 
	where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_remark_elink'

select @ls_ord_lengthunit = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_lengthunit'

select @ls_ord_widthunit  = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_widthunit'

select @ls_ord_heightunit = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_heightunit'

select @ls_ord_totalweightunits = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_totalweightunits'

select @ls_ord_totalvolumeunits = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_totalvolumeunits'

select @ls_ord_totalcountunits  = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_totalcountunits'

select @ls_ord_unit  = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_unit'

select @ls_ord_tempunits  = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_tempunits'

select @ls_ord_rateunit  = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_rateunit'

select @ls_ord_billto = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_billto'

select @ls_ord_orderby = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_orderby'

select @ls_cht_itemcode = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'cht_itemcode'

select @ls_ref_sid = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ref_sid'

select @ls_ref_pickup = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ref_pickup'

select @ls_ord_rateby = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_rateby'

select @ls_ord_terms = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'toh_ord_terms'

select @ls_ord_subcompany = ifc_value from interface_constants 
where ifc_tablename = 'tempordhdr' and ifc_columnname = 'toh_ord_subcompany'

select @ls_stp_weightunit = ifc_value from interface_constants 
where ifc_tablename = 'tempstops' and ifc_columnname = 'stp_weightunit'

select @ls_stp_countunit  = ifc_value from interface_constants 
where ifc_tablename = 'tempstops' and ifc_columnname = 'stp_countunit'

select @li_retries = convert(int,ifc_value) from interface_constants 
where ifc_tablename = 'misc' and ifc_columnname = 'retries'

select @ls_emailsendto = ifc_value from interface_constants 
where ifc_tablename = 'misc' and ifc_columnname = 'emailsendto'

select @ls_emailcopyto = ifc_value from interface_constants 
where ifc_tablename = 'misc' and ifc_columnname = 'emailcopyto'

select @ls_edictkey = ifc_value from interface_constants 
where ifc_tablename = 'misc' and ifc_columnname = 'edictkey'

select @ls_revtypesource = ifc_value from interface_constants 
where ifc_tablename = 'misc' and ifc_columnname = 'revtypesource'

select @ls_revtypesource = ifc_value from interface_constants 
where ifc_tablename = 'misc' and ifc_columnname = 'revtypesource'

--  LTSLOrderHeader Interface Constants for defaults for values that are on
--     P*S tables, but not on any of the Temp tables.

select @ls_ord_priority = ifc_value from interface_constants 
where ifc_tablename = 'ltsl_orderheader' and ifc_columnname = 'ord_priority'

select @ls_trl_type1 = ifc_value from interface_constants 
where ifc_tablename = 'ltsl_orderheader' and ifc_columnname = 'trl_type1'

select @ls_quantity_type = null
select @ls_quantity_type = CONVERT(int, ifc_value) from interface_constants 
where ifc_tablename = 'orderheader' and ifc_columnname = 'ord_quantity_type'

-- Set defaults if any of the read variables are NULL
select @ls_ord_customer = IsNull(@ls_ord_customer,'UNKNOWN')
select @ls_ord_supplier = IsNull(@ls_ord_supplier,'UNKNOWN')
select @ls_ord_revtype1 = IsNull(@ls_ord_revtype1,'UNK')
select @ls_ord_revtype2 = IsNull(@ls_ord_revtype2,'UNK')
select @ls_ord_revtype3 = IsNull(@ls_ord_revtype3,'UNK')
select @ls_ord_revtype4 = IsNull(@ls_ord_revtype4,'UNK')
select @ls_ord_remark   = IsNull(@ls_ord_remark,'Order taken via Electronic Data Interchange')
if @batch_number < 0 
        select @ls_ord_remark   = IsNull(@ls_ord_remark,'Order taken via E*Link')
select @ls_ord_lengthunit = IsNull(@ls_ord_lengthunit,'FET')
select @ls_ord_widthunit  = IsNull(@ls_ord_widthunit,'FET')
select @ls_ord_heightunit = IsNull(@ls_ord_heightunit,'FET')
select @ls_ord_totalweightunits = IsNull(@ls_ord_totalweightunits,'LBS')
select @ls_ord_totalvolumeunits = IsNull(@ls_ord_totalvolumeunits,'CUB')
select @ls_ord_totalcountunits  = IsNull(@ls_ord_totalcountunits,'PCS')
select @ls_ord_unit  = IsNull(@ls_ord_unit,'UNK')
select @ls_ord_tempunits  = IsNull(@ls_ord_tempunits,'Frnht')
select @ls_ord_rateunit  = IsNull(@ls_ord_rateunit,'UNK')
select @ls_cht_itemcode = IsNull(@ls_cht_itemcode,'UNK')
select @ls_ord_rateby = IsNull(@ls_ord_rateby,'D')
select @ls_stp_weightunit = IsNull(@ls_stp_weightunit,'LBS')
select @ls_stp_countunit  = IsNull(@ls_stp_countunit,'PCS')
select @li_retries = IsNull(@li_retries,3)
select @ls_emailcopyto = IsNull(@ls_emailcopyto,@ls_emailsendto)
select @ls_edictkey = IsNull(@ls_edictkey,'EDICT#')
select @ls_ord_billto = IsNull(@ls_ord_billto,'UNKNOWN')
select @ls_ord_orderby = IsNull(@ls_ord_orderby,'UNKNOWN')
select @ls_ord_priority = IsNull(@ls_ord_priority, 'UNK')
select @ls_trl_type1 = IsNull(@ls_trl_type1, 'UNK')


If @ls_ord_rateby = 'T' 
   select @ls_screenmode = 'STOPS'
else
   select @ls_screenmode = 'COMMOD'


create table #result_set (LTSL_order int,PS_order char(12),status_code int,status_message char(254))

create table #holdresources (ord_hdrnumber int,stp_number int,driver1 varchar(8) null,
                             driver2 varchar(8) null,tractor varchar(8) null, trailer1 varchar(8) null, 
                             trailer2 varchar(8) null, carrier varchar(8) null)

delete from LTSL_Interface where batch=@batch_number

-- Clear all the temporary (physical tables)
delete ltsl_orderheader 
delete ltsl_stops 
delete ltsl_freightdetail 
delete ltsl_referencenumber 
delete ltsl_notes 

insert LTSL_Interface (batch,progress_percent,halt,progress_message)
        values (@batch_number,0,0,'Starting')

-- Create temp tables that mirror the temporary interface tables
Select * into #tmpordhdr from  tempordhdr where  toh_tstampq = @batch_number
Select * into #tmpstops  from  tempstops  where  toh_tstampq = @batch_number
Select * into #tmpcargos from  tempcargos where  toh_tstampq = @batch_number
Select * into #tmpnotes  from  tempnotes  where  toh_tstampq = @batch_number
Select * into #tmpref    from  tempref    where  toh_tstampq = @batch_number	

UPDATE LTSL_Interface 
        SET progress_percent = 5,
            progress_message = 'Creating Temporary Tables'
        WHERE batch = @batch_number

SELECT @today_date = getdate()
SELECT @genesis = convert(datetime,'19500101')
SELECT @data_validation_flag = 0

SELECT	@ord_number = 0, @ord_counter = 0
select  @max_ord_number = count(*) from #tmpordhdr WHERE toh_tstampq = @batch_number
IF (@max_ord_number = 0)
        BEGIN
        SELECT @data_validation_flag = -6
        SELECT @err_message = 'No Valid Orders for batch number:'+ convert(varchar(20), @batch_number)
        SELECT @error_type = 'NODATA'

        INSERT INTO #result_set (LTSL_order, PS_order, status_code, status_message)
        VALUES (0, '', -6, @err_message)

        goto return_point
        END

WHILE 1=1
        BEGIN

        SELECT @error_type = 'NONE'  -- Start each order clean.
    SELECT @err_message = null
        select @pws_ordhdrnumber = 0
        SELECT @last_ord_number = @ord_number

        UPDATE LTSL_Interface 
        SET    progress_percent =  ((@ord_counter + 0.0) / (@max_ord_number+1.0)) * 90 + 5,
               progress_message = 'Cleaning prior version of Order ' + CONVERT(varchar(10),@ord_counter)
        WHERE  batch = @batch_number

        -- Get the next order.
        SET ROWCOUNT 1
        SELECT @ord_number = toh_ordernumber, 
               @ord_type = toh_ordtype, 
               @refnum = toh_refnum,
               @reftype = toh_refnumtype,
               @ls_ord_orderby = toh_orderedby
        FROM   #tmpordhdr
        WHERE  (toh_tstampq = @batch_number) AND
               (toh_ordernumber > @last_ord_number)
        ORDER BY toh_ordernumber

        SET ROWCOUNT 0

        IF ISNULL(@ord_number, @last_ord_number) = @last_ord_number
                BREAK

        SELECT @ord_counter = @ord_counter + 1

        IF ISNULL(@reftype, '') = ''
                SELECT @reftype = @ls_edictkey

        -- Check for a prior version of the order.
        SELECT @mov_number = null, @mov_number = null, @pws_ordhdrnumber = null

        SELECT @ord_status  = ord_status ,
               @mov_number  = mov_number,
               @pws_ordhdrnumber = orderheader.ord_hdrnumber
        FROM   orderheader, referencenumber
        WHERE  ref_number = @refnum AND
               ref_type = @reftype AND
               ref_table = 'orderheader' AND
               ref_tablekey = orderheader.ord_hdrnumber AND
               ord_status <> 'CAN' AND
               ord_company = @ls_ord_orderby

-- **************************************************
-- ************** CANCELLATION SECTION **************
-- **************************************************
        SELECT @data_validation_flag = -7 -- Should be cleared before used, if not it's an error.
        If @mov_number is null 
                Begin

                IF @ord_type = 'SET' OR @ord_type = 'ORIGINAL'
                        select @err_message = null  -- No prior move is not an error for Set or New.
                ELSE
                        SELECT @err_message = 'The Order ' + convert(varchar(20), @ord_number)+ ' (' + @reftype + '=' + @refnum + ') could not be located.'
		End
        Else   	
                Begin
                IF @ord_type = 'ORIGINAL'
                        SELECT @err_message = 'Duplicate!!! ' + @reftype + ':' +  @refnum
                               + ' Has already been received for this shipper: '
                               + @ls_ord_orderby

                -- Check if we have consolidated this order with another
                ELSE If (select count(*) from orderheader where mov_number = @mov_number) > 1 

                        SELECT  @err_message = 'The Order ' + 
                                convert(varchar(20), @pws_ordhdrnumber) + 
                                ' cannot be changed. It has been consolidated'

	        ELSE
                        BEGIN
                        if @ord_status = 'AVL' OR @ord_status = 'PLN'
                                BEGIN
                                if @ord_type IN ('CANCEL','UPDATE')
                                        BEGIN 	 	
                                        select @stp_number = 0
                                        While 1 = 1				
                                                Begin
                                                select @stp_number = min(stp_number) from stops 
                                                where mov_number = @mov_number and stp_number > @stp_number	
                                                if @stp_number is null
                                                        break	
                                                update stops set stp_status = 'NON',skip_trigger = 1
                                                       where  stp_number = @stp_number
                                                End 
        				
                                        update orderheader set ord_status = 'CAN' where mov_number = @mov_number 	
                                        exec update_move @mov_number
                                        exec update_ord  @mov_number ,'CMP'

                                        if @ord_type = 'CANCEL'
                                                select @err_message = 'Order cancelled'
                                        else
                                                -- We cancelled the original order(for update) without
                                                --     error, but still have to do the update itself.
                                                select @err_message = null

                                        SELECT @data_validation_flag = 0
                                        END	 
        				
                                if @ord_type = 'START'	
                                        begin
                                        update legheader set lgh_outstatus = 'STD' where mov_number = @mov_number
        
                                        update stops set stp_status = 'DNE' where mov_number = @mov_number and
                                                                                  stp_mfh_sequence = 1
        
                                        exec update_move @mov_number
                                        exec update_ord  @mov_number ,'CMP'
                                        select @err_message = 'Order sucessfully started'
                                        SELECT @data_validation_flag = 0
                                        end	
        
                                END
                        ELSE
                                SELECT @err_message = 'The Order ' + convert(varchar(20), @pws_ordhdrnumber)+ 
                                        ' cannot be changed. Its status is not AVL or PLN'
                        END
                END

-- *************************************************
-- ********** END OF CANCELLATION SECTION **********
-- *************************************************

        IF @ord_type <> 'ORIGINAL' AND @ord_type <> 'SET' and @ord_type <> 'UPDATE' and isnull(@err_message, '') = ''  -- Should never happen, but for safety.
                SELECT @err_message = 'Unexpected ' + @ord_type + ' Error, please call TMW'  -- Any other status should have been given an @err_message even if successful.

        If isnull(@err_message, '') <> ''
                BEGIN
                SELECT @error_type = 'BADPRV'
                IF @data_validation_flag = -7
                        SELECT @data_validation_flag = -1  -- Any problems that occur here are problems with the prior version of the order.                                        
                GOTO continue_w_nextorder  -- Since it has errorred skip the rest of this order.
                END
        			   	
        -- before we go on, let's look at the interface table for a cancel command
        select @ltsl_halt_indicator=halt from ltsl_interface where batch=@batch_number
        If @ltsl_halt_indicator=-1
                begin

                INSERT INTO #result_set (LTSL_order, PS_order, status_code, status_message)
                VALUES (0, '', -2, 'User Halt detected')

                goto return_point
                end

        SELECT @data_validation_flag = 0

-- ************************************************
-- *************** PREBUILD SECTION ***************
-- ************************************************

        UPDATE LTSL_Interface 
        SET    progress_percent =  ((@ord_counter + 0.3) / (@max_ord_number+1.0)) * 90 + 5,
               progress_message = 'Prebuilding Order ' + CONVERT(varchar(10),@ord_counter)
WHERE  batch = @batch_number

        -- set this up for result set
        select @pws_ordhdrnumber = -1

        -- get the next order in the batch
        Select @batch = null
        SET ROWCOUNT 1

        SELECT @batch 	    = t.toh_tstampq,  
               @org_city   = origin.cmp_city,
               @dest_city  = dest.cmp_city,
               @edictn     = t.toh_edicontrolid,
               @ord_status = t.toh_status,
               @refnum     = t.toh_refnum,
               @reftype    = t.toh_refnumtype,
               @ls_ord_orderby = t.toh_orderedby,
               @jamflag = isnull(t.toh_ord_quantity_type, 0)
        FROM   #tmpordhdr t, company origin, company dest
        WHERE  (t.toh_tstampq = @batch_number) AND
               (t.toh_ordernumber = @ord_number) AND
               (t.toh_shipper = origin.cmp_id) AND
               (t.toh_consignee = dest.cmp_id)
        ORDER BY t.toh_ordernumber

        SELECT @ord_rateby = @ls_ord_rateby
        IF @jamflag < 0
                BEGIN
                IF ((-@jamflag) & 2) <> 0
                        SELECT @ord_rateby = 'T'
                IF ((-@jamflag) & 4) <> 0
                        SELECT @ord_rateby = 'D'
                IF ((-@jamflag) & 1) = 0
                        SELECT @jamflag = 0
                ELSE
                        SELECT @jamflag = -1
                END

        If @ord_rateby = 'T' 
                select @ls_screenmode = 'STOPS'
        else
                select @ls_screenmode = 'COMMOD'

        SET ROWCOUNT 0
--	select 'batch',@batch

        IF (@batch IS null)
                BEGIN
                SELECT @data_validation_flag = -8
                SELECT @err_message = 'Bad origin or destination company on order '+ convert(varchar(20), @ord_counter) 
                SELECT @error_type = 'BADDTA'
                goto continue_w_nextorder
                END
	
        IF isnull(@refnum, '') = '' SELECT @refnum = @edictn
        IF isnull(@reftype, '') = '' SELECT @reftype = @ls_edictkey 

        -- Set the stp status to 'NON' if the order status is 'PND'
        select @stp_status = 'OPN'
        select @upd_ord_stat_parm = 'STD'	 		
        If @ord_status = 'PND'
                begin
                select @stp_status = 'NON' 
                select @upd_ord_stat_parm = 'CMP'	 		
                end
	
        SELECT @error_type = 'DBERROR'
        SELECT @data_validation_flag = 0

        SELECT @org_state=cty_state
        FROM city
        WHERE cty_code=@org_city

        SELECT @dest_state=cty_state
        FROM city
        WHERE cty_code=@dest_city

        -- Went to using the order number from the download as the orderheader
        -- number to allow advances to match with the order #08/14/95
        -- MA* Added 4/11 for single value
        -- MA 04/07/97 Changed the column name to the new one 

        -- TD* 6/19/00 Changed to use refnum columns to match for 
        --		consistency with update/cancel code.
        SET ROWCOUNT 1

        SELECT @duplicate = count(*)
        FROM   orderheader, referencenumber
        WHERE  ref_number = @refnum AND
               ref_type = @reftype AND
               ref_table = 'orderheader' AND
               ref_tablekey = orderheader.ord_hdrnumber AND
               ord_status <> 'CAN' AND
               ord_company = @ls_ord_orderby

        -- check for duplicates in powersuite
        IF @duplicate > 0
                BEGIN
                SELECT @data_validation_flag = -1
                SELECT @err_message = 'Duplicate!!! ' + @reftype + ':' +  @refnum
         + ' Has already been received for this shipper: '
                       + @ls_ord_orderby
                goto continue_w_nextorder
                END  
        SET ROWCOUNT 0
	
        IF @jamflag = -1
                IF EXISTS (SELECT * FROM #tmpref r 
                        WHERE   r.toh_ordernumber = @ord_number AND
                                r.toh_tstampq = @batch_number AND
                                r.ts_sequence = 0 AND
                                r.tr_refsequence = 1)
                        SELECT  @refnum = r.tr_refnum,
                                @reftype = r.tr_type
                        FROM    #tmpref r
                        WHERE   r.toh_ordernumber = @ord_number AND
                                r.toh_tstampq = @batch_number AND
                                r.ts_sequence = 0 AND
                                r.tr_refsequence = 1

        -- check for at least one stop with PUP
        SELECT @stop_count=count(*)
        FROM   #tmpstops
        WHERE  toh_ordernumber = @ord_number and 
               ts_type='PUP' AND
               toh_tstampq = @batch_number

        IF (@stop_count < 1)
                BEGIN
                SELECT @data_validation_flag = -8
                SELECT @err_message = 'Less than 1 Stops found with ts_type=PUP for order: toh_ordnumber='
                       + convert(Char(20), @ord_number) 
                       + 'Error creating order'
                SELECT @error_type = 'BADDTA'
                goto continue_w_nextorder                                                
                END

        -- check for at least one stop with DRP
        SELECT @stop_count=count(*)
        FROM   #tmpstops
        WHERE  toh_ordernumber = @ord_number AND
               ts_type='DRP' AND
               toh_tstampq = @batch_number

        IF (@stop_count < 1)
                BEGIN
                SELECT @data_validation_flag = -8
                SELECT @err_message = 'Less than 1 Stops found with ts_type=DRP for order: toh_ordnumber='
                       + convert(Char(20), @ord_number) 
                       + 'Error creating order'
                SELECT @error_type = 'BADDTA'
                goto continue_w_nextorder                                                
                END

        -- JD 2/6/00  get the revtype values based on the interface constant setting
        if @ls_revtypesource is not null
                begin
                if @ls_revtypesource = 'S'

                        select @ls_ord_revtype1 = cmp_revtype1,
                               @ls_ord_revtype2 = cmp_revtype2,
                               @ls_ord_revtype3 = cmp_revtype3,
                               @ls_ord_revtype4 = cmp_revtype4
                        from company
                        where company.cmp_id = (
                                select toh_shipper 
				FROM   #tmpordhdr 
				WHERE  toh_ordernumber = @ord_number AND
                                       toh_tstampq = @batch_number)

                else if @ls_revtypesource = 'C'
                        select @ls_ord_revtype1 = cmp_revtype1,
                               @ls_ord_revtype2 = cmp_revtype2,
                               @ls_ord_revtype3 = cmp_revtype3,
                               @ls_ord_revtype4 = cmp_revtype4
                        from company 
                        where company.cmp_id = (
                                select toh_consignee 
                                FROM   #tmpordhdr 
                                WHERE  toh_ordernumber = @ord_number AND
                                       toh_tstampq = @batch_number)

                else if @ls_revtypesource = 'B'			 	
                        select @ls_ord_revtype1 = cmp_revtype1,
                               @ls_ord_revtype2 = cmp_revtype2,
                               @ls_ord_revtype3 = cmp_revtype3,
               @ls_ord_revtype4 = cmp_revtype4
                        from company 
                        where company.cmp_id = (
                                select toh_billto 
                                FROM   #tmpordhdr 
                                WHERE  toh_ordernumber = @ord_number AND
                                       toh_tstampq = @batch_number)

                end 


        -- count stops for insert into orderheader
        SELECT @stop_count=count(*)
        FROM   #tmpstops
        WHERE  toh_ordernumber = @ord_number AND
               toh_tstampq = @batch_number

        -- Get new mov number for the order
        EXEC @mov_number = getsystemnumber 'MOVNUM', ''     
        -- Get new ordernumber for the order
        EXEC @pws_ordhdrnumber = getsystemnumber 'ORDHDR', ''
        --*MA and VE * moved from below 4/25
        -- Get new legheadernumber for the order
        EXEC @lgh_hdrnumber = getsystemnumber 'LEGHDR', ''

        -- create orderheader record
        INSERT INTO ltsl_orderheader
                (ord_totalmiles,                -- 1
                ord_customer,                   -- 2
                ord_company,                    -- 3
                ord_number,                     -- 4
                ord_contact,                    -- 5
                ord_bookdate,                   -- 6
                ord_bookedby,                   -- 7
                ord_status,                     -- 8
                ord_originpoint,                -- 9
                ord_destpoint,                  -- 10
                ord_invoicestatus,              -- 11
                ord_origincity,                 -- 12
                ord_destcity,                   -- 13
                ord_originstate,                -- 14
                ord_deststate,                  -- 15
                ord_supplier,                   -- 16
                ord_billto,                     -- 17
                ord_startdate,                  -- 18
                ord_completiondate,             -- 19
                ord_revtype1,                   -- 20
                ord_revtype2,                   -- 21
                ord_revtype3,                   -- 22
                ord_revtype4,                   -- 23
                ord_totalweight,                -- 24
                ord_totalpieces,                -- 25
                ord_totalcharge,                -- 26
                ord_currency,                   -- 27
                ord_currencydate,               -- 28
                ord_totalvolume,                -- 29
                ord_hdrnumber,                  -- 30
                ord_shipper,                    -- 31
                ord_consignee,                  -- 32
                ord_pu_at,                      -- 33
                ord_dr_at,                      -- 34
                ord_priority,                   -- 35
                mov_number,                     -- 36
                ord_description,                -- 37
                ord_reftype,                    -- 38
                ord_refnum,                     -- 39
                tar_tariffitem,                 -- 40
                ord_showshipper,                -- 41
                ord_showcons,                   -- 42
                ord_subcompany,                 -- 43
                ord_lowtemp,                    -- 44
                ord_hitemp,                     -- 45
                ord_quantity,                   -- 46
                ord_rate,                       -- 47
                ord_charge,                     -- 48
                ord_rateunit,                   -- 49
                trl_type1,                      -- 50
                ord_driver1,                    -- 51
                ord_driver2,                    -- 52
                ord_tractor,                    -- 53
            ord_trailer,                    -- 54
                ord_length,                     -- 55
                ord_width,                      -- 56
                ord_height,                     -- 57
                ord_lengthunit,                 -- 58
                ord_widthunit,           -- 59
                ord_heightunit,                 -- 60
                cmd_code,                       -- 61
                ord_terms,                      -- 62
                cht_itemcode,                   -- 63
                ord_origin_earliestdate,        -- 64
                ord_origin_latestdate,          -- 65
                ord_odmetermiles,               -- 66
                ord_stopcount,                  -- 67
                ord_dest_earliestdate,          -- 68
                ord_dest_latestdate,            -- 69
                ref_sid,                        -- 70
                ref_pickup,                     -- 71
                ord_cmdvalue,                   -- 72
                ord_accessorial_chrg,           -- 73
                ord_availabledate,              -- 74
                ord_miscqty,                    -- 75
                ord_tempunits,                  -- 76
                ord_datetaken,                  -- 77
                ord_totalweightunits,           -- 78
                ord_totalvolumeunits,           -- 79
                ord_totalcountunits,            -- 80
                ord_unit,                       -- 81
                ord_rateby,                     -- 82
                tar_tarriffnumber,              -- 83
                ord_remark,                     -- 84
                ltsl_ordernumber,               -- 85
                ord_quantity_type,              -- 86
                lgh_type1)                      -- 87
        SELECT  toh_ord_totalmiles,             -- 1
                @ls_ord_customer,               -- 2
                isnull(toh_orderedby,'UNKNOWN'),-- 3
                convert(char(12), @pws_ordhdrnumber),  -- 4
                toh_contact,                    -- 5
                @today_date,                    -- 6
                toh_user,                       -- 7
                toh_status,                     -- 8
                toh_shipper,                    -- 9
                toh_consignee,                  -- 10
                toh_inv_status,                 -- 11
                @org_city,                      -- 12
                @dest_city,                     -- 13
                @org_state,                     -- 14
                @dest_state,                    -- 15
                @ls_ord_supplier,               -- 16
                (CASE toh_billto 
                        WHEN 'UNKNOWN' Then 
                             @ls_ord_billto 
                        ELSE 
                             toh_billto
                        END),                   -- 17
                toh_shipdate,                   -- 18
                toh_deldate,                    -- 19
                @ls_ord_revtype1,               -- 20
                @ls_ord_revtype2,               -- 21
                @ls_ord_revtype3,               -- 22
                @ls_ord_revtype4,               -- 23
                0,                              -- 24
                0,                              -- 25
                toh_charge,                     -- 26
                'US$',                          -- 27
                @today_date,                    -- 28
                0,                              -- 29
                @pws_ordhdrnumber,              -- 30
                toh_shipper,                    -- 31
                toh_consignee,                  -- 32
                'SHP',                          -- 33
                'CNS',                          -- 34
                @ls_ord_priority,               -- 35
                @mov_number,         -- 36
                (SELECT ts_description			
                FROM    #tmpstops
                WHERE   toh_ordernumber= @ord_number AND
                        ts_seq = 2),            -- 37 - MA & VH, to get one commodity name 5/9
                @reftype,               -- 38
                SUBSTRING(@refnum, 1, 12),      -- 39
                'UNKNOWN',                      -- 40
                'UNKNOWN',                      -- 41
                'UNKNOWN',                      -- 42
                (case isnull(toh_ord_subcompany, '')	-- If temptable value is blank or null, use 
                        WHEN '' Then                    -- interface constant if it is not null
                             isnull(@ls_ord_subcompany, toh_ord_subcompany)
                        ELSE
                             toh_ord_subcompany
                        END),                   -- 43
                0,                              -- 44
                0,                              -- 45
                (CASE WHEN @ord_rateby = 'T' THEN ISNULL(toh_quantity, 0) ELSE 0 END), -- 46
                (CASE WHEN @ord_rateby = 'T' THEN ISNULL(toh_rate, 0) ELSE 0 END),     -- 47
                (case WHEN @ord_rateby = 'T' THEN isnull(toh_charge, 0) ELSE 0 END),   -- 48
                (CASE WHEN @ord_rateby = 'T' AND @ls_ord_rateunit = 'UNK' THEN 'FLT' ELSE @ls_ord_rateunit END), -- 49
                (case isnull(toh_trl_type1, '')
                        WHEN '' Then
                             @ls_trl_type1
                        ELSE
                             toh_trl_type1
                        END),                   -- 50
                'UNKNOWN',                      -- 51
                'UNKNOWN',                      -- 52
                'UNKNOWN',                      -- 53
                'UNKNOWN',                      -- 54
                0,                              -- 55
                0,                              -- 56
                0,                              -- 57
                @ls_ord_lengthunit,             -- 58
                @ls_ord_widthunit,              -- 59
                @ls_ord_heightunit,             -- 60
                'UNKNOWN',                      -- 61
                (case isnull(toh_ord_terms, '')
                        WHEN '' Then
                             isnull(@ls_ord_terms, toh_ord_terms)
                        ELSE
                             toh_ord_terms
                        END),                   -- 62
                (CASE WHEN @ord_rateby = 'T' AND @ls_cht_itemcode = 'UNK' THEN 'LHF' ELSE @ls_cht_itemcode END), -- 63
                null,                           -- 64
                null,                           -- 65
                -1,                             -- 66
                @stop_count,                    -- 67
                null,                           -- 68
                null,                           -- 69
                @ls_ref_sid,                    -- 70
                @ls_ref_pickup,                 -- 71
                0,                              -- 72
                0,                              -- 73
                @today_date,                    -- 74
                0,                              -- 75
                @ls_ord_tempunits,              -- 76
                @today_date,                    -- 77
                @ls_ord_totalweightunits,       -- 78
                @ls_ord_totalvolumeunits,       -- 79
                @ls_ord_totalcountunits,        -- 80
                (CASE WHEN @ord_rateby = 'T' THEN ISNULL(toh_quantityunit, @ls_ord_unit) ELSE @ls_ord_unit END), -- 81
                @ord_rateby,                    -- 82
                'UNKNOWN',                      -- 83
                @ls_ord_remark + '  ' + IsNull(toh_comments,' '),-- 84
                toh_ordernumber,        -- 85
 toh_ord_quantity_type,          -- 86
                toh_lgh_type1                   -- 87
        FROM #tmpordhdr
        WHERE	(toh_ordernumber = @ord_number AND
                toh_tstampq = @batch_number)

        IF @@ERROR != 0
                BEGIN
                SELECT @err_message = '@err:' 
                       + convert(varchar(20), @@ERROR)
                       + 'order: toh_ordnumber='
                       + convert(Char(20), @ord_number)
                       + 'Error creating order'
                SELECT @data_validation_flag = -7
                goto continue_w_nextorder
                END

        -- Add the Edi Control number as the 1st reference number on the reference number table
        IF @jamflag = 0
                INSERT INTO ltsl_referencenumber
                        (ref_tablekey,        -- 1
                        ref_type,             -- 2
                        ref_number,           -- 3
                        ref_sequence,         -- 4
                        ref_table,            -- 5
                        ref_sid,              -- 6
                        ref_pickup)           -- 7
                Values  (@pws_ordhdrnumber,   -- 1
                        @reftype,             -- 2
                        @refnum,              -- 3
                        1,                    -- 4
                        'orderheader',        -- 5
                        'Y',                  -- 6
                        Null)                 -- 7



        -- VH and VJ and MA added 03/26/97 Put all reference numbers in referencenumber table
        SELECT @max_seq_number = isnull(max(tr_refsequence),0)
        FROM   #tmpref		
        WHERE  (toh_ordernumber = @ord_number AND
               toh_tstampq = @batch_number AND
               ts_sequence = 0)        -- when the stop number is 0 then the refnum is 

        SELECT @rCounter = 0

        -- LOOP THROUGH EACH SEQUENCE INBSERTING REFERENCE NUMBERS 
        WHILE @rCounter < @max_seq_number
                -- Begin while sequence loop
                BEGIN
                SELECT @rCounter = @rCounter + 1
                SELECT @error_type = 'DBERROR'

                -- Set rowcount to find only one record
                SET ROWCOUNT 1
                INSERT INTO ltsl_referencenumber
                        (ref_tablekey,        -- 1
                        ref_type,             -- 2
                        ref_number,           -- 3
                        ref_sequence,         -- 4
                        ref_table,            -- 5
                        ref_sid,              -- 6
                        ref_pickup)           -- 7
                SELECT @pws_ordhdrnumber,                -- 1
                        r.tr_type,                       -- 2
                        tr_refnum,                       -- 3
                        @rCounter + 1 + @jamflag,        -- 4
                        'orderheader',                   -- 5
                        Null,                            -- 6
                        Null                             -- 7
                FROM   #tmpref r
                WHERE  (r.toh_ordernumber = @ord_number AND
                        r.toh_tstampq = @batch_number AND
                        r.ts_sequence = 0 AND
                        r.tr_refsequence = @rCounter) 

                IF @@ERROR != 0
                        BEGIN
                        SELECT @err_message = '@err:' 
                               + convert(varchar(10), @@ERROR) + 'order: toh_ordnumber='
                               + convert(Char(20), @ord_number) 
                               + 'Error creating reference# for orderheader'
                        SELECT @data_validation_flag = -5
                        GOTO continue_w_nextorder
                        END 
                END

        IF @jamflag = -1
                INSERT INTO ltsl_referencenumber
                        (ref_tablekey,        -- 1
                        ref_type,             -- 2
                        ref_number,           -- 3
                        ref_sequence,         -- 4
                        ref_table,            -- 5
                        ref_sid,              -- 6
                        ref_pickup)           -- 7
                SELECT  @pws_ordhdrnumber,                     -- 1
                        isnull(toh_refnumtype, @ls_edictkey),  -- 2
                        isnull(toh_refnum, toh_edicontrolid),  -- 3
                        @rCounter + 1,                         -- 4
                        'orderheader',                         -- 5
                        Null,                                  -- 6
                        Null                                   -- 7
                FROM    #tmpordhdr 
                WHERE   toh_ordernumber = @ord_number

        IF @refnum <> @edictn OR @reftype <> @ls_edictkey 
                INSERT INTO ltsl_referencenumber
                        (ref_tablekey,        -- 1
                        ref_type,             -- 2
                        ref_number,           -- 3
                        ref_sequence,         -- 4
                        ref_table,            -- 5
                        ref_sid,              -- 6
                        ref_pickup)           -- 7
                VALUES  (@pws_ordhdrnumber,   -- 1
                        @ls_edictkey,         -- 2
                        @edictn,              -- 3
                        @rCounter + 2,        -- 4
                        'orderheader',        -- 5
                        Null,                 -- 6
                        Null)                 -- 7

        -- Create Notes entries from the #tmpnotes table which is 
        -- NOT part of the POWER Suite Database - for orders
        SET ROWCOUNT 0

        DECLARE FDcursor INSENSITIVE CURSOR
        FOR
                SELECT tn_notesequence, 
                       tn_note
                FROM   #tmpnotes
                WHERE  toh_tstampq = @batch_number AND
                       toh_ordernumber = @ord_number AND
                       ts_sequence =  0

        OPEN FDcursor 

        FETCH FDcursor INTO
              @note_sequence,
              @note_text

        WHILE @@FETCH_STATUS = 0
                BEGIN
                EXEC @note_number = getsystemnumber 'NOTES',''
                INSERT INTO ltsl_notes (
                        not_number,                             --1
                        not_text,                               --2
                        not_type,                               --3
                        not_senton,                             --4
                        not_sentby,                             --5
                        ntb_table,                              --6
                        nre_tablekey,                           --7
                        not_sequence)                           --8
		SELECT  @note_number,                           --1
                        @note_text,                             --2
                        'E',                                    --3
                        GETDATE(),                              --4
                        'EDI204',                               --5
                        'orderheader',                          --6
                        convert(char(18), @pws_ordhdrnumber),   --7
                        @note_sequence                          --8

                FETCH FDcursor INTO
                        @note_sequence,
                        @note_text

                if @@FETCH_STATUS = -2 
                        BEGIN

                        SELECT @err_message = '@err:' 
                               + convert(varchar(10), @@ERROR) + 'order: toh_ordnumber='
                             + convert(Char(20), @ord_number) 
                               + 'Error creating notes for stop'
                               + convert(Char(20), @stp_number)

                        SELECT @data_validation_flag = -3
                        goto continue_w_nextorder

                        END 
                END

        CLOSE FDcursor
        DEALLOCATE FDcursor
        SET ROWCOUNT 0
        SELECT @disp_seq_check = -1
        SELECT @seq_number = 0
        SELECT @max_seq_number = null

        SELECT @max_seq_number = max(ts_seq)

        FROM   #tmpstops
        WHERE  toh_ordernumber = @ord_number AND
               toh_tstampq = @batch_number

        IF (@max_seq_number IS null)
                BEGIN
                SELECT @data_validation_flag = -8

                SELECT @err_message = 'No Stops found for order: toh_ordnumber='
                       + convert(Char(20), @ord_number) 
                       + 'Error creating order'

                SELECT @error_type = 'BADDTA'
                goto continue_w_nextorder                                                
                END

        WHILE @seq_number != @max_seq_number
                BEGIN
                EXEC @stp_number = getsystemnumber 'STPNUM', ''

                --  Set rowcount to find only one record
                SET rowcount 1
                SELECT @seq_number = t.ts_seq,
                       @disp_seq   = t.ts_dispatch_seq,
                       @drv1       = t.ts_driver1,
                       @drv2       = t.ts_driver2,
                       @trc        = t.ts_trc_num,
                       @trl        = t.ts_trl_num,
                       @trl2       = t.ts_trl_num2,
		       @car	   = t.ts_carrier,	
                       @stop_company  = isnull(t.ts_location,'UNKNOWN'),
                       @stop_city  = t.ts_city
                FROM   #tmpstops t
                WHERE  t.ts_seq > @seq_number AND
                       t.toh_ordernumber = @ord_number AND
                       t.toh_tstampq = @batch_number
                ORDER BY t.ts_seq, t.ts_dispatch_seq

                insert into #holdresources
                select @pws_ordhdrnumber, @stp_number, @drv1, @drv2, @trc, @trl, @trl2 ,@car 

                -- test for valid stop company
                SELECT @data_validation_count = count(*)
                FROM company
                WHERE cmp_id =@stop_company

                IF @data_validation_count < 1
                        BEGIN
                        SELECT @data_validation_flag = -8

                        SELECT @err_message = 'Invalid Company from #tmpstops, order: toh_ordnumber='
                               + convert(Char(20), @ord_number) + '  '
                               + @stop_company
                               + '    Error creating order'

                        SELECT @error_type = 'BADDTA'
                        goto continue_w_nextorder
                END

                SELECT @stop_city = isnull( @stop_city, (select cmp_city from company
                WHERE  cmp_id = @stop_company))

                -- test for valid stop city
                SELECT @data_validation_count = count(*)
                FROM city
                WHERE cty_code=@stop_city

                IF @data_validation_count < 1
                        BEGIN
                        SELECT @data_validation_flag = -8
                        SELECT @err_message = 'Invalid City from #tmpstops, order: toh_ordnumber='
                               + convert(Char(20), @ord_number) + '  '
                               + convert(Char(20), @stop_city)
                               + 'Error creating order'

                        SELECT @error_type = 'BADDTA'
                        goto continue_w_nextorder
                END

                -- Set defaults
                SELECT @reftype = 'REF#'
                SELECT @refnum = NULL

                -- Select First ref# For stop (Note: RowCount is still 1)
                SELECT @refnum = tr_refnum,
                       @reftype = tr_type,
                       @main_refseq_number = tr_refsequence
                FROM   #tmpref tr
                WHERE  tr.ts_sequence = @seq_number AND
                       tr.toh_tstampq = @batch_number AND
                       tr.tc_sequence = 0 AND
                       tr.tr_refsequence = (
                                SELECT min(r.tr_refsequence)
                                FROM   #tmpref r
                                WHERE  r.ts_sequence = @seq_number AND
                                       r.toh_tstampq = @batch_number AND
                                       r.toh_ordernumber = @ord_number AND
                                       r.tc_sequence = 0 )   
					
                SET rowcount 0
                INSERT INTO ltsl_stops
                        (ord_hdrnumber,	                        --1
                        stp_number,                             --2
                        cmp_id,                                 --3
                        stp_city,                               --4
                        stp_schdtearliest,                      --5
                        stp_origschdt,                          --6
                        stp_arrivaldate,                        --7
                        stp_departuredate,                      --8
                        stp_reasonlate,                         --9
                        stp_schdtlatest,                        --10
                        lgh_number,                             --11
                        stp_type,                               --12
                        stp_paylegpt,                           --13
                        stp_sequence,                           --14
                        stp_mfh_sequence,                       --15
                        stp_event,                              --16
                        stp_weight,                             --17
                        stp_weightunit,                         --18
                        stp_count,                              --19
                        stp_countunit,                          --20
                        stp_status,                             --21
                        cmp_name,                               --22
                        stp_reftype,                            --23
                        stp_refnum,                             --24
                        mov_number,                             --25
                        cmd_code,                               --26
                        mfh_number,                             --27
                        stp_lgh_sequence,                       --28
                        stp_ord_mileage,                        --29
                        stp_lgh_mileage,                        --30
                        stp_loadstatus,                         --31
                        stp_description,                        --32
                        stp_screenmode)                         --33
		select
                        @pws_ordhdrnumber,                      --1
                        @stp_number,                            --2
                        isnull(t.ts_location,'UNKNOWN'),        --3
                        isnull(@stop_city,0),                   --4
                        isnull(t.ts_earliest,@genesis),         --5
                        t.ts_earliest,                          --6
                        isnull(t.ts_arrival,@today_date),       --7
                        isnull(t.ts_departure,@today_date),     --8
                        'UNK',                                  --9
                        isnull(t.ts_latest,@today_date),        --10
                        @lgh_hdrnumber,                         --11
                        t.ts_type,                              --12
                        'Y',                                    --13
                        t.ts_seq,                               --14
                        t.ts_seq,                               --15
                        t.ts_event,                             --16
                        isnull(t.ts_weight,0),                  --17
                        @ls_stp_weightunit,                     --18
            isnull(t.ts_count,0),                   --19
                        @ls_stp_countunit,                      --20
                        @stp_status,                            --21
                        isnull( (SELECT cmp_name
                                FROM company
                                WHERE cmp_id = t.ts_location), 
                                'UNKNOWN'),                     --22
                        @reftype,                               --23
                        @refnum,                                --24
                        @mov_number,                            --25
                        'UNKNOWN',                              --26
                        0,                                      --27
                        0,                                      --28
                        IsNull(t.ts_miles,0),                   --29
                        IsNull(t.ts_miles,0),                   --30
                        'LD',                                   --31
                        isnull(t.ts_description,'UNKNOWN'),     --32
                        @ls_screenmode                          --33
                from    #tmpstops t
                where   t.ts_seq = @seq_number AND
                        t.toh_ordernumber = @ord_number AND
                        t.toh_tstampq = @batch_number

                IF @@ERROR != 0
                        BEGIN

                        SELECT @err_message  = '@err:' + convert(varchar(10), @@ERROR)
                               + 'order: toh_ordnumber='
                               + convert(Char(20), @ord_number) 
                               + 'Error creating stops'

                        SELECT @data_validation_flag = -7
                        goto continue_w_nextorder
                        END

                -- Add a default freightdetail record if we have nothing in #tmpcargos for the stop JD                 -- added 04/14/99
                Select @fgtcount = count(*) 
                FROM   #tmpcargos
                WHERE  toh_tstampq = @batch_number AND
                       toh_ordernumber = @ord_number AND
                       ts_sequence =  @seq_number 		

                --  IF @ls_screenmode = 'COMMOD'
                IF @fgtcount = 0
                        Begin
                        EXEC @freight_number = getsystemnumber 'FGTNUM',''
                        INSERT INTO ltsl_freightdetail (
                                fgt_number,        --1
                                cmd_code,          --2
                                fgt_weight,        --3
                                fgt_weightunit,    --4
                                fgt_description,   --5
                                stp_number,        --6
                                fgt_volume,        --7
                                fgt_volumeunit,    --8
                                fgt_sequence,      --9
                                fgt_reftype,       --10
                                fgt_rate,          --11
                                fgt_rateunit,      --12
                                fgt_charge,        --13
                                fgt_quantity,      --14
                                fgt_unit)          --15
                        SELECT               
            @freight_number,   --1
                                'UNKNOWN',         --2
                                0,                 --3
                                '',                --4
                                'UNKNOWN',         --5
                                @stp_number,       --6
                                0,                 --7
                                '',                --8
                                @vtc_sequence,     --9
                                'REF',             --10
               0,                 --11
                                '',                --12
                                0,                 --13
                                0,                 --14
                                ''                 --15
                        End

                -- Create FreightDetail entries for the Cargo
                DECLARE FDcursor1 INSENSITIVE CURSOR
                FOR
                        SELECT  tc_weight,
                                tc_weightunit,
                                tc_description,
                                tc_volume,
                                tc_volumeunit,
                                tc_sequence,
                                tc_rate,
                                tc_rateunit,
                                tc_charge,
                                tc_quantity,
                                tc_quantityunit,
                                cmd_code,
                                tc_count,
                                tc_countunit,
                                tc_chargetype
                        FROM    #tmpcargos
                        WHERE   toh_tstampq = @batch_number AND
                                toh_ordernumber = @ord_number AND
                                ts_sequence =  @seq_number 

                OPEN FDcursor1 

                FETCH FDcursor1 INTO
                        @vtc_weight,
                        @vtc_weightunit,
                        @vtc_description,
                        @vtc_volume,
                        @vtc_volumeunit,
                        @vtc_sequence,
                        @vtc_rate,
                        @vtc_rateunit,
                        @vtc_charge,
                        @vtc_quantity,
                        @vtc_quantityunit,
                        @vtc_cmdcode,
                        @vtc_count,
                        @vtc_countunit,
                        @vtc_chargetype

                WHILE @@FETCH_STATUS = 0
                        BEGIN
                        EXEC @freight_number = getsystemnumber 'FGTNUM',''

                        If @vtc_description Is Null
                                SELECT @vtc_description = IsNull(cmd_name,'UNKNOWN') 
                                FROM   commodity 
                                WHERE  cmd_code = @vtc_cmdcode

                        If (ISNULL(@vtc_cmdcode, 'UNKNOWN') = 'UNKNOWN' OR ISNULL(@vtc_cmdcode, 'UNKNOWN') = '') AND ISNULL(@vtc_description, 'UNKNOWN') <> 'UNKNOWN'
                                SELECT @vtc_cmdcode = ISNULL(cmd_code, 'UNKNOWN')
                                FROM commodity
                                WHERE cmd_name = @vtc_description

                        SELECT @fgt_reftype = 'REF'
                        SELECT @fgt_refnum = ''
                        SELECT @fgt_main_refseq = 0

                        -- Select First ref# For Cargo
                        SELECT  @fgt_refnum = MIN(tr_refnum),
                                @fgt_reftype = MIN(tr_type),
                                @fgt_main_refseq = MIN(tr_refsequence)
                        FROM    #tmpref tr
                        WHERE   tr.ts_sequence = @seq_number AND
                                tr.toh_tstampq = @batch_number AND
         tr.tc_sequence = @vtc_sequence AND
                  tr.toh_ordernumber = @ord_number AND
                                tr.tr_refsequence = (
                                        SELECT min(r.tr_refsequence)
                                        From   #tmpref r
                                        WHERE  r.ts_sequence = @seq_number AND
                                               r.toh_tstampq = @batch_number AND
                                               r.toh_ordernumber = @ord_number AND
              r.tc_sequence = @vtc_sequence )   

                        INSERT INTO ltsl_freightdetail (
                                fgt_number,                      --1
                                cmd_code,                        --2
                                fgt_weight,                      --3
                                fgt_weightunit,                  --4
                                fgt_description,                 --5
                                stp_number,                      --6
                                fgt_volume,                      --7
                                fgt_volumeunit,                  --8
                                fgt_sequence,                    --9
                                fgt_reftype,                     --10
                                fgt_refnum,                      --11
                                fgt_rate,                        --12
                                fgt_rateunit,                    --13
                                cht_itemcode,                    --14
                                fgt_charge,                      --15
                                fgt_quantity,                    --16
                                fgt_unit,                        --17
                                fgt_count,                       --18
                                fgt_countunit)                   --19
                        SELECT                      
                                @freight_number,                 --1
                                IsNull(@vtc_cmdcode,'UNKNOWN'),  --2
                                @vtc_weight,                     --3
                                @vtc_weightunit,                 --4
                                @vtc_description,                --5
                                @stp_number,                     --6
                                @vtc_volume,                     --7
                                @vtc_volumeunit,                 --8
                                @vtc_sequence,                   --9
                                @fgt_reftype,                    --10
                                @fgt_refnum,                     --11
                                @vtc_rate,                       --12
                                @vtc_rateunit,                   --13
                                @vtc_chargetype,                 --14
                                @vtc_charge,                     --15
                                @vtc_quantity,                   --16
                                @vtc_quantityunit,               --17
                                @vtc_count,                      --18
                                @vtc_countunit                   --19

                        -- Create remaining reference number records the  
                        -- first REF# is handled by a trigger
                        INSERT INTO ltsl_referencenumber
                                (ref_tablekey,
                                ref_type, 
                                ref_number,
                                ref_sequence, 
                                ref_table,
                                ref_sid,
                                ref_pickup)
                        select 
                                @freight_number, 
                   tr.tr_type, 
                                tr.tr_refnum, 
                                tr.tr_refsequence, 
                                'freightdetail',
                                Null,
                                Null
                        from    #tmpref tr
                        where   tr.ts_sequence = @seq_number AND
                                tr.toh_tstampq = @batch_number AND
                                tr.toh_ordernumber = @ord_number AND
                                tr.tc_sequence = @vtc_sequence AND
                                ISNULL(tr.tr_refsequence, 0) <> @fgt_main_refseq

                        -- Create Notes entries from the #tmpnotes table which is 
                        -- NOT part of the POWER Suite Database - for cargos
                        DECLARE FDNotecursor  INSENSITIVE CURSOR
                        FOR
                                SELECT  tn_notesequence, 
                                        tn_note
                                FROM    #tmpnotes
                                WHERE   toh_tstampq = @batch_number AND
                                        toh_ordernumber = @ord_number AND
                                        ts_sequence =  @seq_number AND
                                        tc_sequence = @vtc_sequence

                        OPEN FDNotecursor

                        FETCH FDNotecursor INTO
                                @note_sequence,
                                @note_text
	
                        WHILE @@FETCH_STATUS = 0
                                BEGIN
                                EXEC @note_number = getsystemnumber 'NOTES',''

                                INSERT INTO ltsl_notes (
                                        not_number,                             --1
                                        not_text,                               --2
                                        not_type,                               --3
                                        not_senton,                             --4
                                        not_sentby,                             --5
                                        ntb_table,                              --6
                                        nre_tablekey,                           --7
                                        not_sequence)                           --8
                                SELECT 
                                        @note_number,                           --1
                                        @note_text,                             --2
                                        'E',                                    --3
                                        GETDATE(),                              --4
                                        'EDI204',                               --5
                                        'freightdetail',                        --6
                                        convert(varchar(18), @freight_number),  --7
                                        @note_sequence                          --8
	
                                FETCH FDNotecursor INTO
                                        @note_sequence,
                                        @note_text

                                if @@FETCH_STATUS = -2 
                                        BEGIN

                                        SELECT @err_message = '@err:' 
                                               + convert(varchar(10), @@ERROR) 
                                               + 'order: toh_ordnumber='
                                               + convert(Char(20), @ord_number) 
                                               + 'Error creating notes for stop'
                                               + convert(Char(20), @stp_number)

                                        SELECT @data_validation_flag = -3
                                        goto continue_w_nextorder
                                        END 

                                END
                        CLOSE FDNotecursor
                        DEALLOCATE FDNotecursor

                        FETCH FDcursor1 INTO
                                @vtc_weight,
                                @vtc_weightunit,
                                @vtc_description,
                                @vtc_volume,
                                @vtc_volumeunit,
                                @vtc_sequence,
                                @vtc_rate,
                                @vtc_rateunit,
                                @vtc_charge,
                                @vtc_quantity,
                                @vtc_quantityunit,
                                @vtc_cmdcode,
                                @vtc_count,
                                @vtc_countunit,
                                @vtc_chargetype

                        if @@FETCH_STATUS = -2 
                                BEGIN

                                SELECT @err_message = '@err:' 
                                       + convert(varchar(10), @@ERROR) + 'order: toh_ordnumber='
                                       + convert(Char(20), @ord_number) 
                                       + 'Error creating cargo# for stop'
                                       + convert(Char(20), @stp_number)

                                SELECT @data_validation_flag = -4
                                goto continue_w_nextorder

                                END
                        END
                CLOSE FDcursor1
                DEALLOCATE FDcursor1
                -- Create Notes entries from the #tmpnotes table which is 
                -- NOT part of the POWER Suite Database - for stops
                DECLARE FDcursor  INSENSITIVE CURSOR
                FOR
                        SELECT  tn_notesequence, 
                                tn_note
                        FROM    #tmpnotes
                        WHERE   toh_tstampq = @batch_number AND
                                toh_ordernumber = @ord_number AND
                                ts_sequence =  @seq_number AND
                                tc_sequence =  0

                OPEN FDcursor 
                FETCH FDcursor INTO
                        @note_sequence,
                        @note_text

                WHILE @@FETCH_STATUS = 0
                        BEGIN
                        EXEC @note_number = getsystemnumber 'NOTES',''

                        INSERT INTO ltsl_notes (
                                not_number,
                                not_text,
                                not_type,
                                not_senton,
                                not_sentby,
                                ntb_table,
                                nre_tablekey,
                                not_sequence)
                        SELECT  @note_number,
                                @note_text,
                                'E',
                                GETDATE(),
                                'EDI204',
                                'stops',
                                convert(varchar(18), @stp_number),
                                @note_sequence

                        FETCH FDcursor INTO
                                @note_sequence,
                                @note_text
                        if @@FETCH_STATUS = -2 
                                BEGIN

                                SELECT @err_message = '@err:' 
                                       + convert(varchar(10), @@ERROR) + 'order: toh_ordnumber='
                                       + convert(Char(20), @ord_number) 
                                       + 'Error creating notes for stop'
                              + convert(Char(20), @stp_number)

                 SELECT @data_validation_flag = -3
                                goto continue_w_nextorder
                                END 
                        END
                CLOSE FDcursor
                DEALLOCATE FDcursor

                -- Create remaining reference number records the  
                -- first REF# is handled by a trigger

                INSERT INTO ltsl_referencenumber
                       (ref_tablekey,
                        ref_type, 
                        ref_number,
                        ref_sequence, 
                        ref_table,
                        ref_sid,
                        ref_pickup)
                select 
                        @stp_number, 
                        tr.tr_type, 
                        tr.tr_refnum, 
                        tr.tr_refsequence, 
                        'stops',
                        Null,
                        Null
                from    #tmpref tr
                where   tr.ts_sequence = @seq_number AND
                        tr.toh_tstampq = @batch_number AND
                        tr.toh_ordernumber = @ord_number AND
                        tr.tc_sequence = 0 AND
                        tr.tr_refsequence <> @main_refseq_number

                IF @@ERROR != 0
                        BEGIN

                        SELECT @err_message = '@err:' 
                               + convert(varchar(10), @@ERROR) + 'order: toh_ordnumber='
                               + convert(Char(20), @ord_number) 
                               + 'Error creating reference# for stop'

                        SELECT @data_validation_flag = -5
                        goto continue_w_nextorder
                        END 

                END

        if @ls_screenmode = 'STOPS'
                update  ltsl_orderheader 
                set     cmd_code =  s.cmd_code ,
                        ord_description = s.stp_description				
                from    ltsl_orderheader o , ltsl_stops s
                where   o.ord_hdrnumber = @pws_ordhdrnumber and 
                        o.ord_hdrnumber = s.ord_hdrnumber and 
                        s.stp_event = 'LUL' and 
                        s.cmd_code <> 'UNKNOWN' and
                        s.stp_mfh_sequence in 
                                (select min(stp_mfh_sequence) from ltsl_stops 
                                where   ord_hdrnumber = @pws_ordhdrnumber and 
                                        stp_event = 'LUL')

-- *************************************************
-- ************ END OF PREBUILD SECTION ************
-- *************************************************

-- **************************************************
-- ********* ACTUAL ORDER INSERTION SECTION *********
-- **************************************************

        UPDATE LTSL_Interface 
        SET    progress_percent =  ((@ord_counter + 0.7) / (@max_ord_number+1.0)) * 90 + 5,
               progress_message = 'Creating Order ' + CONVERT(varchar(10),@ord_counter)
        WHERE  batch = @batch_number

        select  @ord_status       = ord_status,
                @mov_number       = mov_number,
                @ord_number       = ltsl_ordernumber,
                @lgh_type1        = lgh_type1
        from    ltsl_orderheader
        where   ord_hdrnumber = @pws_ordhdrnumber

        If @pws_ordhdrnumber IS Null
                break

        BEGIN TRAN ORDER_CREATE		
	-- Orders

        select @li_try = 0	

        while @li_try  < @li_retries

                -- KM PTS 6408, check for order_quantity_type flag, if it's 1, 
                -- then it's a fixed/mileage rated order

                Begin
                INSERT INTO orderheader
                       (ord_totalmiles,                      -- 1
  ord_customer,                        -- 2
                        ord_company,    -- 3
                        ord_number,                          -- 4
                        ord_contact,                         -- 5
                        ord_bookdate,                        -- 6
                        ord_bookedby,                        -- 7
                        ord_status,                          -- 8
                        ord_originpoint,                     -- 9
                        ord_destpoint,                       -- 10
                        ord_invoicestatus,                   -- 11
                        ord_origincity,                      -- 12
                        ord_destcity,                        -- 13
                        ord_originstate,                     -- 14
                        ord_deststate,                       -- 15
                        ord_supplier,                        -- 16
                        ord_billto,                          -- 17
                        ord_startdate,                       -- 18
                        ord_completiondate,                  -- 19
                        ord_revtype1,                        -- 20
                        ord_revtype2,                        -- 21
                        ord_revtype3,                        -- 22
                        ord_revtype4,                        -- 23
                        ord_totalweight,                     -- 24
                        ord_totalpieces,                     -- 25
                        ord_totalcharge,                     -- 26
                        ord_currency,                        -- 27
                        ord_currencydate,                    -- 28
                        ord_totalvolume,                     -- 29
                        ord_hdrnumber,                       -- 30
                        ord_shipper,                         -- 31
                        ord_consignee,                       -- 32
                        ord_pu_at,                           -- 33
                        ord_dr_at,                           -- 34
                        ord_priority,                        -- 35
                        mov_number,                          -- 36
                        ord_description,                     -- 37
                        ord_reftype,                         -- 38
                        ord_refnum,                          -- 39
                        tar_tariffitem,                      -- 40
                        ord_showshipper,                     -- 41
                        ord_showcons,                        -- 42
                        ord_subcompany,                      -- 43
                        ord_lowtemp,                         -- 44
                        ord_hitemp,                          -- 45
                        ord_quantity,                        -- 46
                        ord_rate,                            -- 47
                        ord_charge,                          -- 48
                        ord_rateunit,                        -- 49
                        trl_type1,                           -- 50
                        ord_driver1,                         -- 51
                        ord_driver2,                         -- 52
                        ord_tractor,                         -- 53
                        ord_trailer,                         -- 54
                        ord_length,                          -- 55
                        ord_width,                           -- 56
                        ord_height,                          -- 57
                        ord_lengthunit,                      -- 58
                        ord_widthunit,                       -- 59
                        ord_heightunit,                      -- 60
      cmd_code,                            -- 61
                        ord_terms,                           -- 62
                     cht_itemcode,                        -- 63
                        ord_origin_earliestdate,             -- 64
                        ord_origin_latestdate,               -- 65
                        ord_odmetermiles,                    -- 66
                        ord_stopcount,                       -- 67
                        ord_dest_earliestdate,               -- 68
                        ord_dest_latestdate,                 -- 69
                        ref_sid,                             -- 70
                        ref_pickup,                          -- 71
                        ord_cmdvalue,                        -- 72
                        ord_accessorial_chrg,                -- 73
                        ord_availabledate,                   -- 74
                        ord_miscqty,                         -- 75
                        ord_tempunits,                       -- 76
                        ord_datetaken,                       -- 77
                        ord_totalweightunits,                -- 78
                        ord_totalvolumeunits,                -- 79
                        ord_totalcountunits,                 -- 80
                        ord_unit,                            -- 81
                        ord_rateby,                          -- 82
                        tar_tarriffnumber,                   -- 83
                        ord_remark,                          -- 84
                        ord_quantity_type)                   -- 85
                SELECT  ord_totalmiles,                      -- 1
                        ord_customer,                        -- 2
                        ord_company,                         -- 3
                        ord_number,                          -- 4
                        ord_contact,                         -- 5
                        ord_bookdate,                        -- 6
                        ord_bookedby,                        -- 7
                        ord_status,                          -- 8
                        ord_originpoint,                     -- 9
                        ord_destpoint,                       -- 10
                        ord_invoicestatus,                   -- 11
                        ord_origincity,                      -- 12
                        ord_destcity,                        -- 13
                        ord_originstate,                     -- 14
                        ord_deststate,                       -- 15
                        ord_supplier,                        -- 16
                        ord_billto,                          -- 17
                        ord_startdate,                       -- 18
                        ord_completiondate,                  -- 19
                        ord_revtype1,                        -- 20
                        ord_revtype2,                        -- 21
                        ord_revtype3,                        -- 22
                        ord_revtype4,                        -- 23
                        ord_totalweight,                     -- 24
                        ord_totalpieces,                     -- 25
                        ord_totalcharge,                     -- 26
                        ord_currency,                        -- 27
                        ord_currencydate,                    -- 28
                        ord_totalvolume,                     -- 29
                        ord_hdrnumber,                       -- 30
                        ord_shipper,                         -- 31
                        ord_consignee,                       -- 32
                        ord_pu_at,                           -- 33
                        ord_dr_at,                           -- 34
         ord_priority,                        -- 35
                        mov_number,                          -- 36
         ord_description,                     -- 37
                        ord_reftype,                         -- 38
                        ord_refnum,                          -- 39
                        tar_tariffitem,                      -- 40
                        ord_showshipper,                     -- 41
                        ord_showcons,                        -- 42
                        ord_subcompany,                      -- 43
                        ord_lowtemp,                         -- 44
                        ord_hitemp,                          -- 45
                        CASE When ord_quantity_type > 0  then ord_totalmiles ELSE ord_quantity END,  -- 46
                        ord_rate,                            -- 47
                        ord_charge,                          -- 48
                        CASE When ord_quantity_type > 0  then 'MIL' ELSE ord_rateunit END,  -- 49
                        trl_type1,                           -- 50
                        ord_driver1,                         -- 51
                        ord_driver2,                         -- 52
                        ord_tractor,                         -- 53
                        ord_trailer,                         -- 54
                        ord_length,                          -- 55
                        ord_width,                           -- 56
                        ord_height,                          -- 57
                        ord_lengthunit,                      -- 58
                        ord_widthunit,                       -- 59
                        ord_heightunit,                      -- 60
                        cmd_code,                            -- 61
                        ord_terms,                           -- 62
                        CASE WHEN ord_quantity_type > 0  then 'LHD' ELSE cht_itemcode END,  --63
                        ord_origin_earliestdate,             -- 64
                        ord_origin_latestdate,               -- 65
                        ord_odmetermiles,                    -- 66
                        ord_stopcount,                       -- 67
                        ord_dest_earliestdate,               -- 68
                        ord_dest_latestdate,                 -- 69
                        ref_sid,                             -- 70
                        ref_pickup,                          -- 71
                        ord_cmdvalue,                        -- 72
                        ord_accessorial_chrg,                -- 73
                        ord_availabledate,                   -- 74
                        ord_miscqty,                         -- 75
                        ord_tempunits,                       -- 76
                        ord_datetaken,                       -- 77
                        ord_totalweightunits,                -- 78
                        ord_totalvolumeunits,                -- 79
                        ord_totalcountunits,                 -- 80
                        ord_unit,                            -- 81
                        ord_rateby,                          -- 82
                        tar_tarriffnumber,                   -- 83
                        ord_remark,                          -- 84
                        ISNULL(@ls_quantity_type, CASE WHEN ord_quantity_type >= 0 THEN ord_quantity_type ELSE 0 END)    -- 85
                FROM    ltsl_orderheader
                WHERE   ltsl_orderheader.ord_hdrnumber = @pws_ordhdrnumber


                If @@error <> 1205
                        break

                select @li_try = @li_try + 1
        
                End

        if exists (select * from syscolumns inner join sysobjects on syscolumns.id = sysobjects.id where syscolumns.name = 'ord_ratingquantity' and sysobjects.name = 'orderheader')
                BEGIN
                SELECT @JamNewFields = 'UPDATE orderheader SET ord_ratingquantity = ord_quantity, ord_ratingunit = ord_unit WHERE ord_hdrnumber = ' + CONVERT(varchar(20),@pws_ordhdrnumber)
                EXEC (@JamNewFields)
                END

        -- Stops
        Select @stp_number = 0
        While 1 = 1  -- we have to insert stops 1 at a time as the stops trigger cannot handle multiple stops
                BEGIN		
                Select @stp_number = min(stp_number) from ltsl_stops where stp_number > @stp_number
                If @stp_number IS NULL
                        BREAK
        
                select @li_try = 0	
                while @li_try  < @li_retries
                        Begin
        	
                        INSERT INTO stops
                                (ord_hdrnumber,         --1
                                stp_number,             --2
                                cmp_id,                 --3
                                stp_city,               --4
                                stp_schdtearliest,      --5
                                stp_origschdt,          --6
                                stp_arrivaldate,        --7
                                stp_departuredate,      --8
                                stp_reasonlate,         --9
                                stp_schdtlatest,        --10
                                lgh_number,             --11
                                stp_type,               --12
                                stp_paylegpt,           --13
                                stp_sequence,           --14
                                stp_mfh_sequence,       --15
                                stp_event,              --16
                                stp_weight,             --17
                                stp_weightunit,         --18
                                stp_count,              --19
                                stp_countunit,          --20
                                stp_status,             --21
                                cmp_name,               --22
                                stp_reftype,            --23
                                stp_refnum,             --24
                                mov_number,             --25
                                cmd_code,               --26
                                mfh_number,             --27
                                stp_lgh_sequence,       --28
                                stp_ord_mileage,        --29
                                stp_lgh_mileage,        --30
                                stp_loadstatus,         --31
                                stp_description,        --32
                                stp_screenmode)         --33
                        Select  ord_hdrnumber,          --1
                                stp_number,             --2
                                cmp_id,                 --3
                                stp_city,               --4
                                stp_schdtearliest,      --5
                                stp_origschdt,          --6
                                stp_arrivaldate,        --7
                                stp_departuredate,      --8
                                stp_reasonlate,         --9
                                stp_schdtlatest,        --10
                                lgh_number,             --11
                                stp_type,               --12
                                stp_paylegpt,           --13
                                stp_sequence,           --14
                                stp_mfh_sequence,       --15
                                stp_event,              --16
                                stp_weight,             --17
                                stp_weightunit,         --18
                                stp_count,              --19
                                stp_countunit,   --20
                                stp_status,             --21
                                cmp_name,               --22
                                stp_reftype,            --23
                                stp_refnum,             --24
                                mov_number,             --25
                                cmd_code,               --26
                                mfh_number,             --27
                                stp_lgh_sequence,       --28
                                stp_ord_mileage,        --29
                                stp_lgh_mileage,        --30
                                stp_loadstatus,         --31
                                stp_description,        --32
                                stp_screenmode          --33
                        from    ltsl_stops
                    Where   ltsl_stops.ord_hdrnumber = @pws_ordhdrnumber and
                                ltsl_stops.stp_number = @stp_number
        
                        If  @@error <> 1205
                                break
        	
                        select @li_try = @li_try + 1
        	
                        End

                select @li_try = 0	
        
                while @li_try  < @li_retries
                        Begin
        
                        UPDATE  event
                        SET     evt_driver1 = driver1,
                                evt_driver2 = driver2,
                                evt_tractor = tractor,
                                evt_trailer1 = trailer1,
                                evt_trailer2 = trailer2,
        			evt_carrier  = carrier
                        FROM    event, #holdresources
                        WHERE   event.stp_number = @stp_number and
                                event.stp_number = #holdresources.stp_number and
                                #holdresources.ord_hdrnumber = @pws_ordhdrnumber 
        
                        If  @@error <> 1205
                                break
        	
                        select @li_try = @li_try + 1
        	
                        End

                END -- End of stops insert Loop		

        select @li_try = 0	

        while @li_try  < @li_retries
                Begin
        
                delete  
                from    freightdetail 
                from    ltsl_freightdetail, freightdetail f
                where   ltsl_freightdetail.stp_number = f.stp_number and
                        ltsl_freightdetail.stp_number in (select stp_number from ltsl_stops where ord_hdrnumber = @pws_ordhdrnumber)
        
        
                If  @@error <> 1205
                        break
        	
                select @li_try = @li_try + 1
                End

        -- FreightDetail
        Select @freight_number = 0
        
        While 1 = 1     -- we also have to insert freightdetails 1 at a time as the freightdetail trigger 
                        -- cannot handle multiple freightdetails
                BEGIN		
                Select @freight_number = min(fgt_number) from ltsl_freightdetail where fgt_number > @freight_number
        
                If @freight_number IS NULL
                        BREAK
        
                select @li_try = 0	
        
                while @li_try  < @li_retries
                        Begin
        	
        	
                        INSERT INTO freightdetail (
                                fgt_number,
                                cmd_code,
                                fgt_weight,
                                fgt_weightunit,
                                fgt_description,
                                stp_number,
                                fgt_volume,
                 fgt_volumeunit,
                                fgt_sequence,
                                fgt_reftype,
        fgt_refnum,
                                fgt_rate,
                                fgt_rateunit,
                                cht_itemcode,
                                fgt_charge,
                                fgt_quantity,
                                fgt_unit,
                                fgt_count,
                                fgt_countunit)
                        select 
                                fgt_number,
                                cmd_code,
                                fgt_weight,
                                fgt_weightunit,
                                fgt_description,
                                stp_number,
                                fgt_volume,
                                fgt_volumeunit,
                                fgt_sequence,
                         fgt_reftype,
                                fgt_refnum,
                                fgt_rate,
                                fgt_rateunit,
                                cht_itemcode,
                                fgt_charge,
                                fgt_quantity,
                                fgt_unit,
                                fgt_count,
                                fgt_countunit
                        FROM    ltsl_freightdetail
                        where   ltsl_freightdetail.fgt_number = @freight_number and
                                stp_number in 
                                        (SELECT ltsl_stops.stp_number 
                                        from    ltsl_stops 
                                        WHERE   ltsl_stops.ord_hdrnumber = @pws_ordhdrnumber)
        	
                        If  @@error <> 1205
                                break
        		
                        select @li_try = @li_try + 1
                        End

                END	-- Freightdetail loop

        -- Reference Numbers for the order
        select @li_try = 0	
        
        while @li_try  < @li_retries
                Begin
        
        
                INSERT INTO referencenumber
                        (ref_tablekey,
                        ref_type,
                        ref_number,
                        ref_sequence,
                        ref_table,
                        ref_sid,
                        ref_pickup)
                Select  ref_tablekey,
                        ref_type,
                        ref_number,
                        ref_sequence,
                        ref_table,
                        ref_sid,
                        ref_pickup
                from    ltsl_referencenumber
                where   ltsl_referencenumber.ref_table    = 'orderheader' and
                        ltsl_referencenumber.ref_tablekey = @pws_ordhdrnumber
        
                If  @@error <> 1205
                        break
        	
                select @li_try = @li_try + 1
                End
        

        -- Reference Numbers for the Stops
        select @li_try = 0	

        while @li_try  < @li_retries
                Begin

                INSERT INTO referencenumber
                      ( ref_tablekey,
                        ref_type,
                        ref_number,
                        ref_sequence,
                        ref_table,
                        ref_sid,
                        ref_pickup)
                Select  ref_tablekey,
                        ref_type,
                        ref_number,
                        ref_sequence,
                        ref_table,
                        ref_sid,
                        ref_pickup
                from    ltsl_referencenumber
                where   ltsl_referencenumber.ref_table    = 'stops' and
                  ltsl_referencenumber.ref_tablekey in 
                                (select stp_number from ltsl_stops 
 where ord_hdrnumber = @pws_ordhdrnumber)

                If  @@error <> 1205
                        break
	
                select @li_try = @li_try + 1
                End


        -- Reference Numbers for the Freightdetails
        select @li_try = 0	

        while @li_try  < @li_retries
                Begin

                INSERT INTO referencenumber
                      ( ref_tablekey,
                        ref_type,
                        ref_number,
                        ref_sequence,
                        ref_table,
                        ref_sid,
                        ref_pickup)
                Select  ref_tablekey,
                        ref_type,
                        ref_number,
                        ref_sequence,
                        ref_table,
                ref_sid,
                        ref_pickup
                from    ltsl_referencenumber
                where   ltsl_referencenumber.ref_table    = 'freightdetail' and
                        ltsl_referencenumber.ref_tablekey in 
                                (select fgt_number from ltsl_freightdetail 
                                where stp_number in 
                                        (select stp_number from ltsl_stops 
                                        where ord_hdrnumber = @pws_ordhdrnumber))

                If  @@error <> 1205
                        break
	
                select @li_try = @li_try + 1
                End


        -- Notes on the order
        select @li_try = 0	

        while @li_try  < @li_retries
                Begin

                INSERT INTO notes (
                        not_number,
                        not_text,
                        not_type,
                        not_senton,
                        not_sentby,
                        ntb_table,
                        nre_tablekey,
                        not_sequence)
                SELECT 	not_number,
                        not_text,
                        not_type,
                        not_senton,
                        not_sentby,
                        ntb_table,
                        nre_tablekey,
                        not_sequence
                FROM    ltsl_notes
                WHERE   ntb_table = 'orderheader' and
                        nre_tablekey = convert(char(18),@pws_ordhdrnumber)

                If  @@error <> 1205
                        break
	
                select @li_try = @li_try + 1
                End


        -- Notes on the stops
        select @li_try = 0	

        while @li_try  < @li_retries
                Begin

                INSERT INTO notes (
                        not_number,
                        not_text,
                        not_type,
                        not_senton,
                        not_sentby,
                        ntb_table,
                        nre_tablekey,
                        not_sequence)
                SELECT 	not_number,
                        not_text,
                        not_type,
                        not_senton,
                        not_sentby,
                        ntb_table,
                        nre_tablekey,
                        not_sequence
                FROM    ltsl_notes
                WHERE   ntb_table = 'stops' and
                        nre_tablekey in 
                                (select convert(varchar(12),stp_number) from ltsl_stops 
                                where ord_hdrnumber = @pws_ordhdrnumber)

                If  @@error <> 1205
                        break
	
                select @li_try = @li_try + 1
                End


        -- Notes on the freightdetail
        select @li_try = 0	

        while @li_try  < @li_retries
                Begin

                INSERT INTO notes (
                        not_number,
                        not_text,
                       not_type,
                        not_senton,
                        not_sentby,
                        ntb_table,
                        nre_tablekey,
                        not_sequence)
                SELECT 	not_number,
                        not_text,
                        not_type,
                        not_senton,
                        not_sentby,
                        ntb_table,
                        nre_tablekey,
                        not_sequence
                FROM    ltsl_notes
                WHERE   ntb_table = 'freightdetail' and
                        nre_tablekey in 
                                (select convert(varchar(12),fgt_number) 
                                from    ltsl_stops,ltsl_freightdetail 
       where   ltsl_stops.ord_hdrnumber = @pws_ordhdrnumber and
                                        ltsl_stops.stp_number = ltsl_freightdetail.stp_number)

                If  @@error <> 1205
                        break
	
                select @li_try = @li_try + 1
                End


        select @li_try = 0	

        while @li_try  < @li_retries
                Begin


                UPDATE 	stops  
                SET     stp_weight = f.fgt_weight,   
                        stp_weightunit = f.fgt_weightunit,   
                        cmd_code = f.cmd_code,   
                        stp_description	= f.fgt_description,
                        stp_count = f.fgt_count,
                        stp_countunit =  f.fgt_countunit,
                        stp_volume = f.fgt_volume,
                        stp_volumeunit = f.fgt_volumeunit
                from    freightdetail f, stops
                where   stops.ord_hdrnumber = @pws_ordhdrnumber and
                        stops.stp_number = f.stp_number and
                        f.fgt_sequence = 1		

                If  @@error <> 1205
                        break
	
                select @li_try = @li_try + 1
                End


        COMMIT TRAN ORDER_CREATE
-- 	   select 'here commit tran'
        EXEC update_move @mov_number	
        EXEC update_ord @mov_number,@upd_ord_stat_parm

        UPDATE LTSL_Interface 
        SET    progress_percent =  ((@ord_counter + 0.9) / (@max_ord_number+1.0)) * 90 + 5,
               progress_message = 'Finishing Order ' + CONVERT(varchar(10),@ord_counter)
        WHERE  batch = @batch_number

        if ISNULL(@lgh_type1, 'UNK') <> 'UNK'
                update legheader set lgh_type1 = @lgh_type1 WHERE mov_number = @mov_number

        if @ord_status = 'DSP' 
                update legheader set lgh_outstatus = 'DSP' 
                where mov_number = @mov_number

        if      (select ord_status
                FROM    ltsl_orderheader
                WHERE   ltsl_orderheader.ord_hdrnumber = @pws_ordhdrnumber) = 'CMP' 

                begin
                Select @stp_number = 0

                While 1 = 1  -- we have to update one at a time
                        BEGIN		
                        Select @stp_number = min(stp_number) from ltsl_stops 
                        where stp_number > @stp_number

                        If @stp_number IS NULL
                                BREAK
				
                        update stops
                        set    stp_status = 'DNE'
                        where  stp_number = @stp_number
                        end 

                EXEC update_move @mov_number	
                EXEC update_ord @mov_number, @upd_ord_stat_parm

                end 

--	select 'finished processing orders'
        SELECT @err_message = 'Order successfully imported', @data_validation_flag = 0


-- The following checks to see if triggers have automatically created primary reference number entries.
-- If not, they will explicitly create them.

-- insert orderheader referencenumbers if they only added one on the orderheader itself and not on the actual reference number table
--	select * from #result_set
	select @ord_reftype = ord_reftype, @ord_refnum = ord_refnum from orderheader where ord_hdrnumber = @pws_ordhdrnumber
	if @ord_refnum is not null
                if not exists (select * from referencenumber	where ref_table = 'orderheader' and ref_tablekey = @pws_ordhdrnumber and ref_type=@ord_reftype and ref_number = @ord_refnum)
                        begin
        		update referencenumber set ref_sequence = ref_sequence + 1  where ref_table = 'orderheader' and ref_tablekey = @pws_ordhdrnumber

                        INSERT INTO referencenumber
                              ( ref_tablekey,
                                ref_type,
                                ref_number,
          ref_sequence,
                                ref_table,
                                ref_sid,
                                ref_pickup)
        		( Select @pws_ordhdrnumber,
        			 ord_reftype,
        			 ord_refnum,
        			 1,
        			 'orderheader',
        			 null,
        			 null 
                        from   orderheader where ord_hdrnumber = @pws_ordhdrnumber)
                        end	


-- insert stop referencenumbers if they only added one on the stop itself and not on the actual reference number table
	select @stp_number = 0
	while 1 = 1
		begin
		select @stp_number = min(stp_number) from stops where ord_hdrnumber = @pws_ordhdrnumber and stp_number > @stp_number
		if @stp_number is null
			break
	
--  	        select 'here stp number',@stp_number	
		select @stp_reftype = stp_reftype,@stp_refnum = stp_refnum from stops where ord_hdrnumber = @pws_ordhdrnumber and stp_number =@stp_number
		if @stp_refnum is not null
			if not exists (select * from referencenumber where ref_table = 'stops' and ref_tablekey = @stp_number and ref_type =@stp_reftype and ref_number= @stp_refnum)
				begin 
				update referencenumber set ref_sequence = ref_sequence + 1  where ref_table = 'stops' and ref_tablekey = @stp_number
		 	
				INSERT INTO referencenumber
					( ref_tablekey,
					ref_type,
					ref_number,
					ref_sequence,
					ref_table,
					ref_sid,
					ref_pickup)
				( Select @stp_number,
					stp_reftype,
					stp_refnum,
					1,
					'stops',
					null,
					null 
				from   stops where ord_hdrnumber = @pws_ordhdrnumber and stp_number = @stp_number)
				end	
		end	


-- insert freight referencenumbers if they only added it on the freight record itself and not on the actual reference number table
	select @stp_number = 0
	while 1 = 1
		begin
		select @stp_number = min(stp_number) from stops where ord_hdrnumber = @pws_ordhdrnumber and stp_number > @stp_number
		if @stp_number is null
			break

		select @freight_number = 0
		while 2 = 2 
			begin
--			select 'here fgt number',@freight_number	
			select @freight_number = min(fgt_number) from freightdetail where 
				stp_number = @stp_number and fgt_number > @freight_number
			if @freight_number is null 
				break
			else	
				begin		
				select @fgt_reftype=fgt_reftype, @fgt_refnum=fgt_refnum from freightdetail where stp_number = @stp_number and fgt_number = @freight_number
				if @fgt_refnum is not null
					if not exists (select * from referencenumber where ref_table = 'freightdetail' and ref_tablekey = @freight_number and ref_type = @fgt_reftype and ref_number = @fgt_refnum)
						begin
						update referencenumber set ref_sequence = ref_sequence + 1  where ref_table = 'freightdetail' and ref_tablekey = @freight_number
		
						INSERT INTO referencenumber
							( ref_tablekey,
							ref_type,
							ref_number,
							ref_sequence,
							ref_table,
							ref_sid,
							ref_pickup)
						( Select @freight_number,
							fgt_reftype,
							fgt_refnum,
							1,
							'freightdetail',
							null,
							null 
						from   freightdetail where stp_number = @stp_number and fgt_number = @freight_number)
						end 	
				end
			end	
		end








        delete tempordhdr where toh_ordernumber = @ord_number and toh_tstampq = @batch_number
        delete tempstops  where toh_ordernumber = @ord_number and toh_tstampq = @batch_number
        delete tempref    where toh_ordernumber = @ord_number and toh_tstampq = @batch_number
        delete tempcargos where toh_ordernumber = @ord_number and toh_tstampq = @batch_number
        delete tempnotes  where toh_ordernumber = @ord_number and toh_tstampq = @batch_number
        select @li_returnorder = @pws_ordhdrnumber

-- *************************************************
-- ***** END OF ACTUAL ORDER INSERTION SECTION *****
-- *************************************************

continue_w_nextorder: 

        INSERT INTO #result_set (LTSL_order, PS_order, status_code, status_message)
        VALUES (@ord_number, isnull(Convert(varchar(12), @pws_ordhdrnumber),''), @data_validation_flag, @err_message)

        IF (@data_validation_flag = 0)
                BEGIN
                delete #tmpordhdr where toh_ordernumber = @ord_number
                delete #tmpstops  where toh_ordernumber = @ord_number
                delete #tmpref    where toh_ordernumber = @ord_number
                delete #tmpcargos where toh_ordernumber = @ord_number
                delete #tmpnotes  where toh_ordernumber = @ord_number
                END 

        -- End while orders loop
        END 

return_point:

UPDATE LTSL_Interface 
SET    progress_percent =  97,
       progress_message = 'Cleaning up'
WHERE  batch = @batch_number

select LTSL_order, PS_order, status_code, status_message from #result_set
		
if @ls_emailsendto is not null 
        BEGIN
        create table ##result_text ( email_msg text)

        insert into ##result_text
        select 'LTSL_ORDER#:' + convert(char(20),LTSL_order) +
                        'PS ORDER#:' + convert(char(20),PS_order) + 
                        'Status Code:' + convert(char(10),status_code) + 
                        'Message:'+status_message 
        from #result_set

	
        execute master..xp_sendmail  
                @recipients      = @ls_emailsendto, 
                @copy_recipients = @ls_emailcopyto, 
                @query           = 'SELECT * from ##result_text',
                @subject         = 'Message From the Order Import',
                @message         = 'Results of the import:',
                @attach_results  = 'FALSE', 
                @width           = 500

        drop table ##result_text

        END

insert into interface_results 
       (ltsl_order, ps_order, status_code, status_message, created_date, batch_code)
select LTSL_order, PS_order, status_code, status_message, getdate(), @batch_number 
from   #result_set

delete from ltsl_interface where batch=@batch_number

return  isnull(@li_returnorder,0)
GO
GRANT EXECUTE ON  [dbo].[LTSL_Order_Import] TO [public]
GO
