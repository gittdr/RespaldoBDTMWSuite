SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [dbo].[get_calculated_delay_cumulative_sp] (
   @pl_bill_or_stl char(1), -- B from billing or S from settlements
   @pl_tarnum int, -- the tariff number on the rate being used
   @pl_ord_hdrnumber int , -- the current order being settled
   @pl_lgh_number int, -- the current trip segment being settled
   @pl_stp_number int,  -- for Delay per stop - one stop number at a time.
   @out_time DECIMAL(8,4) OUTPUT,
   @ps_returnmsg varchar(255) Output,
   @pl_excluded   int      OUTPUT)
AS
/**
 *
 * NAME:
 * dbo.get_calculated_delay_cumulative_sp
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns the quantity of time for tariffs using calcualted delay time cumulative
 *
 * RETURNS:
 * @out_time = computed quantity of time
 * @ps_returnmsg = error message if any.
 *
 * REVISION HISTORY:
 * PTS 43583/41569 GAP 47: 7-10-2008  JSwindell : Created.
 * PTS 43805 7-28-2008 JSwindell (Include / Exclude bug)
 * PTS 43806 : apply rounding even if free time is zero: 7-28-2008 JSwindell
 * PTS 46271 - DJM 11/10
 * PTS 56258 - Clients experiencing never-ending-query syndrome.  Fix it.
 * PTS 60286 - Fixed never-ending-query and broke split trips & fix null value issue in 51435 code.
 *          (60286 -need to return ZERO instead of -1 for proper (new) rating behavior)
 * PTS 63602 - Consider Driver Accountability for reason late. Label file reasonlate label_extrastring1 = Y or N.
 * PTS 66044 - vjh implemented hot fix from Glenn
* PTS 66398 if the MIN and MAX settings are entered for DELAYCM they are not applied
*  PTS 89353 - Restoring what was commented out by PTS 66398 - Training issue - user must enter minutes in hours (30 mins = .5 hour)
**/

-- this proc has a sister: get_calculated_delay_per_stops_sp

set @ps_returnmsg = ''
-- The Basic Sequence:
   -- SUM of calc time at each stop
   -- subtract (Sum of free time)
   -- apply rounding
   -- return the Calculated delay time.

set nocount on

declare @tar_time_calc              varchar(6)
declare @tar_timecalc_rounding         varchar(10)
declare @tar_timecalc_increment        DECIMAL(19,4)
declare @tar_timecalc_free_time        DECIMAL(19,4)
declare @multistop_free_time        decimal(19,4)
--------------------------------
declare @tar_timecalc_event_list    varchar(200)
declare @tar_timecalc_events_inc_excl  char(1)
declare @tar_timecalc_compid_list      varchar(200)
declare @tar_timecalc_compid_inc_excl  char(1)
Declare  @tar_time_calc_method         varchar(8)     -- PTS 46271 - DJM
declare @STP_stp_event              varchar(12)
declare @STP_cmp_id                 varchar(12)
--------------------------------
declare @mov_number     int
declare @first_stop     int      -- first & last stop are always n/a for time calcs
declare @last_stop      int      -- first & last stop are always n/a for time calcs
--------------------------------
declare @schdtearliest  datetime
declare @schdtlatest datetime
declare @arrivaldate    datetime
declare @departuredate  datetime
declare @firm_appt_flag char(1)
declare @delay_eligible char(1)  -- if this is not "Y" then we don't calc delay time.
---------------------------------
declare @calc_arrival   datetime
declare @calc_time_at_stop DECIMAL(19,4)
declare @calc_delay_time DECIMAL(19,4)
declare @adjusted_delay_time DECIMAL(19,4)

---------------------------------
declare @first_seq_nbr int
declare @last_seq_nbr int
declare @stop_loop_counter int
---------------------------------
declare @cumulative_free_time DECIMAL(19,4)
declare @cumulative_delay_time DECIMAL(19,4)
Declare @free_adjust_time  int
Declare @total_free_adjust_time  int


Declare @TimeCalcDelayApplyAll   char(1)

declare @unit_of_measure VARCHAR(6)

Declare @use_firstqualevent   int               -- PTS 51435 - DJM
Declare @use_lastqualevent int               -- PTS 51435 - DJM
Declare @firstevt_freetime DECIMAL(19,4)     -- PTS 51435 - DJM
Declare @lastevent_freetime DECIMAL(19,4)    -- PTS 51435 - DJM
Declare  @min_freetime     DECIMAL(19,4)     -- PTS 51435 - DJM
Declare  @max_freetime     DECIMAL(19,4)     -- PTS 51435 - DJM

Declare @stp_freetime      decimal(19,4)     -- PTS 51435 - DJM

-- PTS 63602.start
Declare @ApplyDrvAcctablty char(1)
Set @ApplyDrvAcctablty = 'N'

IF @pl_bill_or_stl = 'S'
   begin
            Select @ApplyDrvAcctablty = IsNull(tar_timecalc_arrivelatexcl, 'N') from tariffheaderstl where tar_number = @pl_tarnum
   end
IF @pl_bill_or_stl = 'B'
   begin
            Select @ApplyDrvAcctablty = IsNull(tar_timecalc_arrivelatexcl, 'N') from tariffheader where tar_number = @pl_tarnum
   end

IF @ApplyDrvAcctablty IS NULL  OR  LTrim(RTrim(@ApplyDrvAcctablty)) = '' Set @ApplyDrvAcctablty = 'N'
-- PTS 63602.end

-- PTS 63602: moved definitions to top
DECLARE  @temp_hour_incr_table TABLE (
   hit_rownbr int,
   hit_min_compare_value money )

---- PTS 51436 - DJM - Modified the insertert to be sure it got all the appropriate rows for either an Order (Billing)
----  or a Leg (Settlements)
CREATE TABLE #temp_stops_table(
               tst_row_nbr             int identity,
               tst_stp_mfh_sequence    INT NULL,
               tst_stp_delay_eligible     CHAR(1) NULL,
               tst_include             CHAR(1) NULL,
               tst_stp_number          INT NULL,
               tst_adjusted_delay_time    decimal(19,4) NULL,
               --tst_stp_event            varchar(6) NULL,
               --tst_cmp_id            varchar(8) NULL,
               tst_stp_event           varchar(12),
               tst_cmp_id              varchar(12),
               tst_calc_time_at_stop      decimal(19,4) NULL,
               tst_stp_firm_appt_flag     CHAR(1) NULL,
               tst_stp_schdtearliest      datetime NULL,
               tst_stp_schdtlatest        datetime NULL,
               tst_stp_arrivaldate        datetime NULL,
               tst_stp_departuredate      datetime NULL,
               tst_calc_arrival        datetime NULL,
               tst_rtn_msg             varchar(255) NULL,
               ord_hdrnumber           INT NULL,
               lgh_number              INT NULL,
               tst_stp_freetime        decimal(19,4),
               tst_stp_reasonlate         varchar(6) null,  ---- PTS 63602
               tst_stp_reasonlate_depart  varchar(6) null,  ---- PTS 63602
               tst_DrvAccountable         varchar(1) null      ---- PTS 63602
               )

-- PTS 63602.start
CREATE TABLE #temp_Reasonlate( tRLate int identity, abbr varchar(6) null, label_extrastring1 varchar(60) null )
IF Left(@ApplyDrvAcctablty, 1) = 'Y'
begin
   Insert into #temp_Reasonlate( abbr, label_extrastring1)
         select abbr, label_extrastring1 from labelfile where labeldefinition = 'Reasonlate' and IsNull(retired, 'N') <> 'Y'
end
-- PTS 63602.end
--====== end of Temp Tables



--PTS 56258.start
if @pl_ord_hdrnumber <=0 AND @pl_lgh_number <= 0 and @pl_stp_number <= 0
      BEGIN
                  --PTS 60286 ( return ZERO rather than -1 )
                  set @out_time = 0
                  set @ps_returnmsg = 'Error - Calc delay by stops - Order, leg and stop numbers passed all = zero.'
                  RETURN
      END
--PTS 56258.end


/*
   PTS 46271 - DJM - Add check for new GI setting.
*/
select @TimeCalcDelayApplyAll = isNull((Select gi_string1 from generalinfo where gi_name = 'TimeCalcDelayApplyAll'),'N')

--PTS 60286 (check for leg & stop = zero before doing this validation )
IF @pl_ord_hdrnumber <> 0 And @pl_lgh_number = 0 and @pl_stp_number = 0
   Begin
      --PTS 56258.start
         declare @to_ordstat varchar(12)
         select  @to_ordstat = min(ord_status) from orderheader where ord_hdrnumber = @pl_ord_hdrnumber
         If  @to_ordstat <> 'CMP'
         BEGIN
                  set @out_time = 0
                  set @ps_returnmsg = 'Error - Calc delay by stops - Leg and stop numbers = zero and Order status passed is Not CMP.'
                  RETURN
         END
      --PTS 56258.end

      --PTS 56258
      --set @mov_number = (select min(mov_number) from stops where ord_hdrnumber =  @pl_ord_hdrnumber)
      set @mov_number = (select min(mov_number) from orderheader where ord_hdrnumber = @pl_ord_hdrnumber)
   End

--PTS 60286 (check for stop = zero before doing this validation )
IF @pl_lgh_number <> 0 and @pl_stp_number = 0
   Begin
      --PTS 56258.start
      declare @to_legstat varchar(12)
         select  @to_legstat = min(lgh_outstatus) from legheader where lgh_number = @pl_lgh_number
         If  @to_legstat <> 'CMP'
         BEGIN
                  set @out_time = 0
                  set @ps_returnmsg = 'Error - Calc delay by stops - Stop number = zero and Leg status passed is Not CMP.'
                  RETURN
         END
      --PTS 56258.end

      --PTS 56258
      --set @mov_number = (select min(mov_number) from stops where lgh_number =  @pl_lgh_number)
      set @mov_number = (select min(mov_number) from legheader where lgh_number  =  @pl_lgh_number)
   END

IF @pl_stp_number <> 0 --and @pl_ord_hdrnumber = 0 and @pl_lgh_number = 0
   Begin
      set @mov_number = (select min(mov_number) from stops where stp_number = @pl_stp_number)
   End

--PTS 60286.start
If @mov_number is NULL SET @mov_number = 0
IF @mov_number = 0
BEGIN
      set @out_time = 0
      set @ps_returnmsg = 'Error - Calc delay by stops - Move Number = zero.'
      RETURN
END
--PTS 60286.end

--vjh 66044
IF @pl_bill_or_stl <> 'S' BEGIN
   --PTS 56258 ( outside select needs to be qualified by move# also )
   SELECT @first_stop = stp_number
   FROM stops
   WHERE stops.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                        FROM stops
                        WHERE mov_number = @mov_number)
   AND mov_number = @mov_number     --PTS 56258

   --PTS 56258 ( outside select needs to be qualified by move# also )
   SELECT @last_stop = stp_number
   FROM stops
   WHERE stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                        FROM stops
                        WHERE mov_number = @mov_number)
   AND mov_number = @mov_number     --PTS 56258
END ELSE BEGIN
   --PTS 56258 ( outside select needs to be qualified by move# also )
   SELECT @first_stop = stp_number
   FROM stops
   WHERE stops.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                        FROM stops
                        WHERE mov_number = @mov_number
                        and lgh_number = @pl_lgh_number)
   AND mov_number = @mov_number     --PTS 56258
   and lgh_number = @pl_lgh_number
   --PTS 56258 ( outside select needs to be qualified by move# also )
   SELECT @last_stop = stp_number
   FROM stops
   WHERE stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                        FROM stops
                        WHERE mov_number = @mov_number
                        and lgh_number = @pl_lgh_number)
   AND mov_number = @mov_number     --PTS 56258
   and lgh_number = @pl_lgh_number
END

--PTS 56258.start
if  @last_stop > 0
Begin
declare @to_stpstat varchar(12)
   select  @to_stpstat = min(stp_status) from stops where stp_number = @last_stop
   If  @to_stpstat <> 'DNE'
   BEGIN
          set @out_time = 0
          set @ps_returnmsg = 'Error - Calc delay by stops - Stop Status is not DNE'
          RETURN
   END
End
--PTS 56258.end

--**************************************************************
if @pl_bill_or_stl = 'B'
    begin
      SET @unit_of_measure          = (select cht_unit from tariffheader where tar_number = @pl_tarnum )
      SET @tar_time_calc               = (select tar_time_calc from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_rounding       = (select tar_timecalc_rounding from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_increment         = (select isnull(tar_timecalc_increment,0) from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_free_time         = (select isnull(tar_timecalc_free_time,0) from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_event_list     = (select tar_timecalc_event_list from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_events_inc_excl   = (select isNull(tar_timecalc_events_inc_excl,'Y') from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_compid_list    = (select tar_timecalc_compid_list from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_compid_inc_excl   = (select isNull(tar_timecalc_compid_inc_excl,'Y') from tariffheader where tar_number = @pl_tarnum )
      Select @tar_time_calc_method     = isNull(tar_timecalc_method,'1') from tariffheader where tar_number = @pl_tarnum
      set @multistop_free_time         = (select isNull(tar_timecalc_free_time_multistop,0) from tariffheader where tar_number = @pl_tarnum)

      -- PTS 51435 - DJM - If Necessary, build a list of the Stops applicable to this rate.
      select @use_firstqualevent = isNull(tar_timecalc_use_first_qualevent,0) from tariffheader where tar_number = @pl_tarnum
      select @use_lastqualevent = isNull(tar_timecalc_use_last_qualevent,0) from tariffheader where tar_number = @pl_tarnum
      select @firstevt_freetime = isnull(tar_timecalc_first_qualevent_freetime,0) from tariffheader where tar_number = @pl_tarnum
      select @lastevent_freetime = isNull(tar_timecalc_last_qualevent_freetime,0) from tariffheader where tar_number = @pl_tarnum
      select @min_freetime = isNull(tar_timecalc_min_freetime,0) from tariffheader where tar_number = @pl_tarnum
      select @max_freetime = isNull(tar_timecalc_max_freetime,0) from tariffheader where tar_number = @pl_tarnum


    end

if @pl_bill_or_stl = 'S'
    begin
      SET @unit_of_measure          = (select cht_unit from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_time_calc               = (select tar_time_calc from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_rounding       = (select tar_timecalc_rounding from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_increment         = (select isnull(tar_timecalc_increment,0) from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_free_time         = (select isNull(tar_timecalc_free_time,0) from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_event_list     = (select tar_timecalc_event_list from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_events_inc_excl   = (select isNull(tar_timecalc_events_inc_excl,'Y') from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_compid_list    = (select tar_timecalc_compid_list from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_compid_inc_excl   = (select isNull(tar_timecalc_compid_inc_excl,'Y') from tariffheaderstl where tar_number = @pl_tarnum )
      Select @tar_time_calc_method     = isNull(tar_timecalc_method,'1') from tariffheaderstl where tar_number = @pl_tarnum
      set @multistop_free_time         = (select isNull(tar_timecalc_free_time_multistop,0) from tariffheaderstl where tar_number = @pl_tarnum)

      -- PTS 51435 - DJM - If Necessary, build a list of the Stops applicable to this rate.
      select @use_firstqualevent = isnull(tar_timecalc_use_first_qualevent,0) from tariffheaderstl where tar_number = @pl_tarnum
      select @use_lastqualevent = isnull(tar_timecalc_use_last_qualevent,0) from tariffheaderstl where tar_number = @pl_tarnum
      select @firstevt_freetime = isNull(tar_timecalc_first_qualevent_freetime,0) from tariffheaderstl where tar_number = @pl_tarnum
      select @lastevent_freetime = isNull(tar_timecalc_last_qualevent_freetime,0) from tariffheaderstl where tar_number = @pl_tarnum
      select @min_freetime = isNull(tar_timecalc_min_freetime,0) from tariffheaderstl where tar_number = @pl_tarnum
      select @max_freetime = isNull(tar_timecalc_max_freetime,0) from tariffheaderstl where tar_number = @pl_tarnum

    end

--**************************************************************


-- PTS 51436 - DJM - Modified the insertert to be sure it got all the appropriate rows for either an Order (Billing)
-- or a Leg (Settlements)
-- Moved to TOP
--CREATE TABLE  #temp_stops_table (tst_row_nbr int identity,
-- tst_stp_mfh_sequence int,
-- tst_stp_delay_eligible char(1),
-- tst_include char(1),
-- tst_stp_number int,
-- tst_adjusted_delay_time DECIMAL(19,4),
-- tst_stp_event  varchar(12),
-- tst_cmp_id     varchar(12),
-- tst_calc_time_at_stop DECIMAL(19,4),
-- tst_stp_firm_appt_flag char(1),
-- tst_stp_schdtearliest datetime,
-- tst_stp_schdtlatest datetime,
-- tst_stp_arrivaldate  datetime,
-- tst_stp_departuredate datetime,
-- tst_calc_arrival datetime,
-- tst_rtn_msg varchar(255),
-- ord_hdrnumber  int,
-- lgh_number     int,
-- tst_stp_freetime  decimal(19,4)
--)


   INSERT INTO #temp_stops_table(
      tst_stp_mfh_sequence,
      tst_stp_delay_eligible,
      tst_include,
      tst_stp_number,
      tst_adjusted_delay_time,
      tst_stp_event,
      tst_cmp_id,
      tst_calc_time_at_stop,
      tst_stp_firm_appt_flag,
      tst_stp_schdtearliest,
      tst_stp_schdtlatest,
      tst_stp_arrivaldate,
      tst_stp_departuredate,
      tst_calc_arrival,
      tst_rtn_msg,
      ord_hdrnumber,
      lgh_number,
      tst_stp_reasonlate,                 -- PTS 63602
      tst_stp_reasonlate_depart,          -- PTS 63602
      tst_DrvAccountable                  -- PTS 63602
      )
   SELECT stp_mfh_sequence,
      stp_delay_eligible,
      'Y', -- tst_include
      stp_number, 0.00,
      ( select ',' + LTRIM(RTRIM(ISNULL(stp_event, '')))  + ',') 'stp_event',
      ( select ',' + LTRIM(RTRIM(ISNULL(cmp_id, '')))  + ',') 'cmp_id',
      0.00,
      stp_firm_appt_flag,
      stp_schdtearliest,
      stp_schdtlatest,
      stp_arrivaldate,
      stp_departuredate,
      null,
      '',
      ord_hdrnumber,
      lgh_number,
      stp_reasonlate,                  -- PTS 63602
      stp_reasonlate_depart,           -- PTS 63602
      'N'                           -- PTS 63602
   FROM stops
   WHERE ord_hdrnumber = @pl_ord_hdrnumber
      AND ord_hdrnumber > 0
      AND (stp_delay_eligible = 'Y' OR @TimeCalcDelayApplyAll = 'Y')
   Union
   SELECT stp_mfh_sequence,
      stp_delay_eligible,
      'Y', -- tst_include
      stp_number, 0.00,
      ( select ',' + LTRIM(RTRIM(ISNULL(stp_event, '')))  + ',') 'stp_event',
      ( select ',' + LTRIM(RTRIM(ISNULL(cmp_id, '')))  + ',') 'cmp_id',
      0.00,
      stp_firm_appt_flag,
      stp_schdtearliest,
      stp_schdtlatest,
      stp_arrivaldate,
      stp_departuredate,
      null,
      '',
      ord_hdrnumber,
      lgh_number,
      stp_reasonlate,               -- PTS 63602
      stp_reasonlate_depart,        -- PTS 63602
      'N'                        -- PTS 63602
   FROM stops
   WHERE lgh_number = @pl_lgh_number
      AND lgh_number > 0
      AND (stp_delay_eligible = 'Y' OR @TimeCalcDelayApplyAll = 'Y')
   order by stops.stp_mfh_sequence


   -- PTS 51435- remove any unnecessary rows based on the function of the proc
   if @pl_bill_or_stl = 'B'
      delete from #temp_stops_table where ord_hdrnumber <> @pl_ord_hdrnumber
   if @pl_bill_or_stl = 'S'
      delete from #temp_stops_table where lgh_number <> @pl_lgh_number

      -- Remove Stops whos events don't meet the requirements
   if @tar_timecalc_events_inc_excl = 'Y' AND @tar_timecalc_event_list is not null AND @tar_timecalc_event_list <> 'UNKNOWN' and @tar_timecalc_event_list <> ''
      delete from #temp_stops_table
      where charindex(tst_stp_event, ','+ @tar_timecalc_event_list + ',') = 0

   else if @tar_timecalc_events_inc_excl = 'N' AND @tar_timecalc_event_list is not null AND @tar_timecalc_event_list <> 'UNKNOWN' and @tar_timecalc_event_list <> ''
      delete from #temp_stops_table
      where charindex(tst_stp_event, ','+ @tar_timecalc_event_list + ',') > 0

   -- Remove Stops whose Companies don't meet the requirements
   if @tar_timecalc_compid_inc_excl = 'Y' AND @tar_timecalc_compid_list is not null AND @tar_timecalc_compid_list <> 'UNKNOWN' AND @tar_timecalc_compid_list <> ''
      delete from #temp_stops_table
      where charindex(tst_cmp_id, ','+ @tar_timecalc_compid_list + ',') = 0

   else if @tar_timecalc_compid_inc_excl = 'N' AND @tar_timecalc_compid_list is not null AND @tar_timecalc_compid_list <> 'UNKNOWN' AND @tar_timecalc_compid_list <> ''
      delete from #temp_stops_table
      where charindex(tst_cmp_id, ','+ @tar_timecalc_compid_list + ',') > 0

-- PTS 63602.start  --Populate tst_DrvAccountable/ remove Driver At Fault rows

if ( select count(*) from #temp_Reasonlate ) > 0  And  @pl_bill_or_stl = 'S'
begin
   if ( select count(tst_stp_reasonlate) from #temp_stops_table where tst_stp_reasonlate <> 'UNK' ) > 0
   begin
      update #temp_stops_table
      set tst_DrvAccountable = IsNull(#temp_Reasonlate.label_extrastring1, 'N' )
      from #temp_stops_table , #temp_Reasonlate where
      #temp_stops_table.tst_stp_reasonlate = #temp_Reasonlate.abbr
   end

   Delete from #temp_stops_table where tst_DrvAccountable = 'Y'

end
-- PTS 63602.end  --Populate tst_DrvAccountable

set @first_seq_nbr = (select min(tst_row_nbr) from #temp_stops_table )
set @last_seq_nbr = (select max(tst_row_nbr) from #temp_stops_table )

--**************************************************************

IF @tar_timecalc_event_list = 'UNKNOWN'
   BEGIN
      SET @tar_timecalc_event_list = NULL
   END

IF @tar_timecalc_compid_list = 'UNKNOWN'
   BEGIN
      SET @tar_timecalc_compid_list = NULL
   END
--**************************************************************

--**************************************************************
--**************** Unit of measure conversion.  ****************
--**************************************************************

IF @unit_of_measure = 'HRS'
   BEGIN
      set @tar_timecalc_increment = @tar_timecalc_increment * 60
      set @tar_timecalc_free_time = @tar_timecalc_free_time * 60
      set @multistop_free_time = @multistop_free_time * 60
      set @firstevt_freetime = @firstevt_freetime * 60
      set @lastevent_freetime = @lastevent_freetime * 60
      set @min_freetime = @min_freetime * 60
      set @max_freetime = @max_freetime * 60
   END

IF @unit_of_measure = 'DAY'
   BEGIN
      set @tar_timecalc_increment = @tar_timecalc_increment * 1440
      set @tar_timecalc_free_time = @tar_timecalc_free_time * 1440
      set @multistop_free_time = @multistop_free_time * 1440
      set @firstevt_freetime = @firstevt_freetime * 1440
      set @lastevent_freetime = @lastevent_freetime * 1440
      set @min_freetime = @min_freetime * 1440
      set @max_freetime = @max_freetime * 1440
   END
--**************************************************************


--*********************************************** Calc Loop (stops) ****************

-- Init stuff.
IF ISNULL(@tar_timecalc_event_list, '') <> '' and ISNULL(@tar_timecalc_event_list, '') <> 'UNKNOWN'
   BEGIN
      -- for event processing
         SET @tar_timecalc_event_list = ',' + LTRIM(RTRIM(ISNULL(@tar_timecalc_event_list, '')))  + ','
         set @tar_timecalc_event_list = REPLACE(@tar_timecalc_event_list,' ','')
   END

IF ISNULL(@tar_timecalc_compid_list, '') <> ''and ISNULL(@tar_timecalc_compid_list, '') <> 'UNKNOWN'
   BEGIN
      -- for COMPANY processing
         SET @tar_timecalc_compid_list= ',' + LTRIM(RTRIM(ISNULL(@tar_timecalc_compid_list, '')))  + ','
         set @tar_timecalc_compid_list = REPLACE(@tar_timecalc_compid_list,' ','')
   END
-- PTS 46271 - DJM - if there is more than one stop that applies and they've defined a separate per stop free time when there are multiple stops,
--              then replace the usual free time variable with the multi-stop value.
if @last_seq_nbr > 1 AND @multistop_free_time > 0
   Set @tar_timecalc_free_time = @multistop_free_time

set @total_free_adjust_time = 0
Select @stop_loop_counter = MIN(tst_row_nbr) from #temp_stops_table


WHILE @stop_loop_counter <= @last_seq_nbr
   BEGIN
      set @pl_stp_number = (select tst_stp_number from #temp_stops_table where tst_row_nbr = @stop_loop_counter)

      set @STP_stp_event = (select tst_stp_event from #temp_stops_table where tst_row_nbr = @stop_loop_counter)
--    PTS 43805 - issue: MISSING the code to set the company - oops.
      set   @STP_cmp_id = (select tst_cmp_id from #temp_stops_table where tst_row_nbr = @stop_loop_counter)
      set @stp_freetime = @tar_timecalc_free_time


--    IF ISNULL(@tar_timecalc_event_list, '') <> ''
--       BEGIN
--          --          PTS 43805 - issue: event exclude bug:  change the condition.
----           IF  (  ( CHARINDEX(@STP_stp_event, @tar_timecalc_event_list) > 0 ) AND ( @tar_timecalc_events_inc_excl = 'N' )    )  OR
----                 CHARINDEX(@STP_stp_event, @tar_timecalc_event_list) = 0

--          IF  (  ( CHARINDEX(@STP_stp_event, @tar_timecalc_event_list) > 0 ) AND ( @tar_timecalc_events_inc_excl = 'N' )    )
--                BEGIN
--                   update #temp_stops_table
--                   set tst_rtn_msg = 'Exclude this event: ' + @STP_stp_event,
--                      tst_adjusted_delay_time = 0,
--                      tst_include = 'N'
--                   where tst_row_nbr = @stop_loop_counter

--                   set @stop_loop_counter = @stop_loop_counter + 1
--                   set @pl_excluded = 1
--                   CONTINUE
--                END

----           PTS 43805 - issue Event Include bug:  ADD condition.
--          IF  (  ( CHARINDEX(@STP_stp_event, @tar_timecalc_event_list) = 0 ) AND ( @tar_timecalc_events_inc_excl = 'Y' )    )
--                BEGIN
--                   update #temp_stops_table
--                   set tst_rtn_msg = 'EVENT not in INCLUDE list: ' + @STP_stp_event,
--                      tst_adjusted_delay_time = 0,
--                      tst_include = 'N'
--                   where tst_row_nbr = @stop_loop_counter

--                   set @stop_loop_counter = @stop_loop_counter + 1
--                   set @pl_excluded = 1
--                   CONTINUE
--                END
--       END


--    IF ISNULL(@tar_timecalc_compid_list, '') <> ''
--       BEGIN
--       --          PTS 43805 - issue:  company exclude bug:  change the condition.
----        IF ( ( CHARINDEX(@STP_cmp_id, @tar_timecalc_compid_list) > 0 ) AND  ( @tar_timecalc_compid_inc_excl = 'N' ) ) OR
----                 CHARINDEX(@STP_cmp_id, @tar_timecalc_compid_list) = 0

--       IF ( ( CHARINDEX(@STP_cmp_id, @tar_timecalc_compid_list) > 0 ) AND  ( @tar_timecalc_compid_inc_excl = 'N' ) )
--             BEGIN
--                update #temp_stops_table
--                set tst_rtn_msg = 'Exclude this COMPANY: ' + @STP_cmp_id,
--                   tst_adjusted_delay_time = 0,
--                   tst_include = 'N'
--                where tst_row_nbr = @stop_loop_counter

--                set @stop_loop_counter = @stop_loop_counter + 1
--                set @pl_excluded = 1
--                CONTINUE
--             END

----           PTS 43805 - issue #3 company INCLUDE bug:  ADD condition.
--       IF ( ( CHARINDEX(@STP_cmp_id, @tar_timecalc_compid_list) = 0 ) AND  ( @tar_timecalc_compid_inc_excl = 'Y' ) )
--             BEGIN
--                update #temp_stops_table
--                set tst_rtn_msg = 'COMPANY not in INCLUDE list: ' + @STP_cmp_id,
--                   tst_adjusted_delay_time = 0,
--                   tst_include = 'N'
--                where tst_row_nbr = @stop_loop_counter

--                set @stop_loop_counter = @stop_loop_counter + 1
--                set @pl_excluded = 1
--                CONTINUE
--             END

--       END

      -- calc date / time at stop
      set @schdtearliest   = (select tst_stp_schdtearliest from #temp_stops_table where tst_row_nbr = @stop_loop_counter)
      set @arrivaldate  = (select tst_stp_arrivaldate from #temp_stops_table where tst_row_nbr = @stop_loop_counter)
      set @departuredate   = (select tst_stp_departuredate from #temp_stops_table where tst_row_nbr = @stop_loop_counter)
      set @firm_appt_flag = (select tst_stp_firm_appt_flag  from #temp_stops_table where tst_row_nbr = @stop_loop_counter)
      set @schdtlatest  = (select tst_stp_schdtlatest from #temp_stops_table where tst_row_nbr = @stop_loop_counter)

      set @calc_arrival = @arrivaldate

      -- PTS 46271 - DJM - Use the TimeCalc_method to determine how to compute the time
      -- If firm appt set for the stop - choose the latest of scheduled_arrival or arrival
      IF (@tar_time_calc_method = '1' AND @firm_appt_flag = 'Y') OR @tar_time_calc_method = '2'
         BEGIN
            IF @schdtearliest  > @arrivaldate
               BEGIN
                  set @calc_arrival = @schdtearliest
               END
         END
      else if @tar_time_calc_method = '3'
         -- Add the time the Arrival date was 'outside' the Earliest/Latest' window to any free time
         Begin
            Set @free_adjust_time = 0

            -- Add the time the load arrived 'early' to the free time
            Begin
               IF @schdtearliest  > @arrivaldate
                  set @free_adjust_time = datediff(mi, @arrivaldate, @schdtearliest)
               if @arrivaldate > @schdtlatest
                  set @free_adjust_time = datediff(mi, @schdtlatest, @arrivaldate)

            End

            Set @stp_freetime = @stp_freetime + isNull(@free_adjust_time,0)
            set @calc_time_at_stop = datediff(mi, @arrivaldate, @departuredate)
         End
      else
         set @calc_time_at_stop = datediff(mi, @arrivaldate, @departuredate)


      --PTS 51436 - DJM - If the first or Last event has a separate Free Time defined, add the difference for that
      --    stop to the adjusted time.
      --if @use_firstqualevent = 1 AND @stop_loop_counter = @first_seq_nbr AND @firstevt_freetime > @tar_timecalc_free_time
      if @use_firstqualevent = 1 AND @stop_loop_counter = @first_seq_nbr
         --Select @total_free_adjust_time = @total_free_adjust_time + (@firstevt_freetime - @tar_timecalc_free_time)
         Select @stp_freetime = @firstevt_freetime + isNull(@free_adjust_time,0)

      --if @lastevent_freetime = 1 AND @stop_loop_counter = @last_seq_nbr AND @lastevent_freetime > @tar_timecalc_free_time
      if @use_lastqualevent = 1 AND @stop_loop_counter = @last_seq_nbr
         --Select @total_free_adjust_time = @total_free_adjust_time + (@lastevent_freetime - @tar_timecalc_free_time)
         Select @stp_freetime = @lastevent_freetime + isNull(@free_adjust_time,0)


      update #temp_stops_table
      set tst_calc_arrival = @calc_arrival,
           tst_calc_time_at_stop = datediff(mi, @calc_arrival, @departuredate),
         tst_include = 'Y',
         tst_stp_freetime = @stp_freetime
      where tst_row_nbr = @stop_loop_counter


      set @calc_time_at_stop = datediff(mi, @calc_arrival, @departuredate)
      -- end of calc date / time at stop


      --set @stop_loop_counter = @stop_loop_counter + 1
      Select @stop_loop_counter = MIN(tst_row_nbr) from #temp_stops_table where tst_row_nbr > @stop_loop_counter

   END

--***************************************** end of Calc Loop (stops) ****************

--set @cumulative_free_time = @tar_timecalc_free_time * (select count(*) from #temp_stops_table where tst_include = 'Y' ) + @total_free_adjust_time
set @cumulative_free_time = (select sum(tst_stp_freetime) from #temp_stops_table where tst_include = 'Y' )
set @cumulative_delay_time = (select sum(tst_calc_time_at_stop) from #temp_stops_table where tst_include = 'Y' )

--PTS 51436 - DJM
if @cumulative_free_time < @min_freetime AND @min_freetime > 0
   select @cumulative_free_time = @min_freetime
if @cumulative_free_time > @max_freetime AND @max_freetime > 0
   select @cumulative_free_time = @max_freetime

-- if total delay <= free time - no delay timeto be billed/paid, so get out.
IF @cumulative_delay_time <= @cumulative_free_time
      BEGIN
         SET @out_time = 0
         SET @ps_returnmsg = 'cumulative_delay_time <= cumulative_free_time'
         RETURN
      END

----**************************************************************************************   Apply Free Time, if any
-- Per Ken R. - Now apply the free time & then round.
   set @cumulative_delay_time = ( @cumulative_delay_time - isnull(@cumulative_free_time, 0) )

----************************************************************************************ Calculate / Apply Rounding

--  7-21-2008 change for 43583 defaulting no rounding to zero.
--if  ( ISNULL(@tar_timecalc_increment, 0))  <= 0
-- BEGIN
--    set @out_time = -1
--    set @ps_returnmsg = 'Increment is ZERO - Process Halted.'
--    RETURN
-- END

if    ( ISNULL(@tar_timecalc_increment, 0))  <= 0
   BEGIN
      if UPPER(@tar_timecalc_rounding) <> 'NONE'
         BEGIN
            set @out_time = 0
            set @ps_returnmsg = 'Increment is ZERO - Process Halted.'
            RETURN
         END
      if UPPER(@tar_timecalc_rounding) = 'NONE'
         BEGIN
            Set @tar_timecalc_increment = 60
         END
   END


declare @next_least_value money
declare @next_greater_value money
declare @incr_dividend int
declare @incr_quotient money
declare @loop_counter int

IF @cumulative_delay_time <= 60
   BEGIN
      set @incr_dividend = 60
   END
IF @cumulative_delay_time > 60
   BEGIN
      set @incr_dividend = ( ceiling(cast(@cumulative_delay_time as int) / 60) + 1 ) * 60
   END

-- Moved to top
--DECLARE   @temp_hour_incr_table TABLE (
-- hit_rownbr int,
-- hit_min_compare_value money )

if @tar_timecalc_increment = 0 set @tar_timecalc_increment = 1       -- PTS 63602   division by zero error.
set @incr_quotient =   ( @incr_dividend / @tar_timecalc_increment )

set @loop_counter = 0

-- populate the table with the time rounding values  (thing-a-ma-bob that does the job)
WHILE @loop_counter < ( @incr_quotient + 1 )
   BEGIN
      INSERT INTO @temp_hour_incr_table(hit_rownbr, hit_min_compare_value)
         Select @loop_counter,  round( @tar_timecalc_increment * @loop_counter, 0 )

         SET @loop_counter = @loop_counter + 1
      END      -- end of loop


----*****************************************************************************************************
      set @next_least_value = (select   max(hit_min_compare_value) from @temp_hour_incr_table
                                     where  hit_min_compare_value <= @cumulative_delay_time )

      set @next_greater_value = (select   min(hit_min_compare_value) from @temp_hour_incr_table
                                     where  hit_min_compare_value >= @cumulative_delay_time )
----*****************************************************************************************************
--

--select * from #temp_stops_table

---- @tar_timecalc_rounding = none = use the actual value. Init @ actual value.
SET @adjusted_delay_time = @cumulative_delay_time

      -- PTS 43806 : apply rounding even if free time is zero.
--    IF @cumulative_delay_time > 0  AND  ( ISNULL(@tar_timecalc_free_time, 0) ) > 0

      IF @cumulative_delay_time > 0
         Begin
            if UPPER(@tar_timecalc_rounding) = 'UP'
               BEGIN
                  --select 'Round UP'
                  set   @adjusted_delay_time = @next_greater_value
               END

            if UPPER(@tar_timecalc_rounding) = 'DOWN'
               BEGIN
                  --select 'Round DOWN'
                  set   @adjusted_delay_time = @next_least_value
               END

            if UPPER(@tar_timecalc_rounding) = 'NEAREST'
               BEGIN
                  --select 'Round Nearest'
                  IF ( @cumulative_delay_time   - @next_least_value )  < ( @next_greater_value - @cumulative_delay_time )
                        BEGIN
                           set   @adjusted_delay_time = @next_least_value
                        END
                  IF ( @cumulative_delay_time   - @next_least_value )  >= ( @next_greater_value - @cumulative_delay_time )
                        BEGIN
                           set   @adjusted_delay_time = @next_greater_value
                        END
               END
         End

IF @unit_of_measure = 'HRS'
   BEGIN
      set @adjusted_delay_time = @adjusted_delay_time / 60
   END

IF @unit_of_measure = 'DAY'
   BEGIN
      set @adjusted_delay_time = @adjusted_delay_time / 1440
   END


---- Return the final values
   SET @out_time = @adjusted_delay_time
   SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))


GO
GRANT EXECUTE ON  [dbo].[get_calculated_delay_cumulative_sp] TO [public]
GO
