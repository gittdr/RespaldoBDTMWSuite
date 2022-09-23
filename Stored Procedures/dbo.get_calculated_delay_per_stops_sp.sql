SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_calculated_delay_per_stops_sp] (
   @pl_bill_or_stl char(1), -- B from billing or S from settlements
   @pl_tarnum int, -- the tariff number on the rate being used
   @pl_ord_hdrnumber int , -- the current order being settled
   @pl_lgh_number int, -- the current trip segment being settled
   @pl_stp_number int,  -- for Delay per stop - one stop number at a time.
   @out_time DECIMAL(8,4) OUTPUT,
   @ps_returnmsg varchar(255) Output,
   @ps_excluded  int Output
)
AS
/**
 *
 * NAME:
 * dbo.get_calculated_delay_per_stops_sp
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns the quantity of time for tariffs using calcualted delay time per stops
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
 * PTS 51453 - Need to add logic to look at ALL the stops on the trip to support new 'free time' rules.
  * PTS 56258 - Clients experiencing never-ending-query syndrome.  Fix it.
  * PTS 60286 - Fixed never-ending-query and broke split trips & fix null value issue in 51435 code.
  *            (60286 -need to return ZERO instead of -1 for proper (new) rating behavior)
  * PTS 63602 - Consider Driver Accountability for reason late. Label file reasonlate label_extrastring1 = Y or N.
  * PTS67352 DPETE returns no time unless tar_timecalc_use_last_qualevent or tar_timecalc_use_first_qualevent is checked
  * PTS 73326_73325_66270 7-7-2014.start Code2Core effort!
  * -- GOTO...LabelProcedureEnd introduced replacing 7million RETURN statements;
  *           despite being 'frowned on' please do NOT remove/replace the goto's; For correct APP behavior We NEED to control when/how this proc is EXITed!!!.
  *      PTS 66270 - 2/21/2013
         --gi_name = 'TimeCalcDelayApplyAll'
         --gi_string1 (Y/N=default) Y= show/apply DLAYST,DLAYCM Delay Calculations for all stops.
         --gi_string2 (Y/N=default):  Y=Allow on LineItemRates; N=Original setting; Primary/Secondary only.
         --gi_string3 (Y/N=default): Y=EXCLUDE late arrival stops
  *      PTS 73326:  fix stop by stop processing due to changes to PB rating engine
  *      PTS 73325:  tweak proc to circumvent minor PB rating engine issue; paydetails were still created when a -1 {error} returned.
  * PTS 73326_73325_66270 7-7-2014.end
  * 9-2-2014: Adjust proc for QA issues found during test (73325/73326)
  * PTS 93232 SGB The Arrival date is always used in the time calculation even if scheduled Earliest is set in setup
  * PTS 103427 SPN - Bug fixed in the Time Calc Option
**/

-- this proc has a sister: get_calculated_delay_cumulative_sp

set @ps_returnmsg = ''
-- The Basic Sequence:
   -- calc time at stop
   -- subtract free time
   -- apply rounding
   -- return the Calculated delay time.

set nocount on

--PTS 66270; introduce new gi control.
declare @GIStr3_ExcludeLate            char(1)     -- PTS 66270
select @GIStr3_ExcludeLate = Substring(LTrim(RTrim(gi_string3)),1,1) from generalinfo where gi_name = 'TimeCalcDelayApplyAll'
IF ISNULL(@GIStr3_ExcludeLate, 'N') <> 'Y' set  @GIStr3_ExcludeLate = 'N'

declare @TimeCalcDelayApplyAll char(1) -- allows use to apply logic to all stops without @delay eligible requirement
select @TimeCalcDelayApplyAll = isNull((Select gi_string1 from generalinfo where gi_name = 'TimeCalcDelayApplyAll'),'N')

declare @tar_time_calc              varchar(6)
declare @tar_timecalc_rounding         varchar(10)
declare @tar_timecalc_increment        decimal(19,4)
declare @tar_timecalc_free_time        decimal(19,4)
--------------------------------
declare @tar_timecalc_event_list    varchar(200)
declare @tar_timecalc_events_inc_excl  char(1)
declare @tar_timecalc_compid_list      varchar(200)
declare @tar_timecalc_compid_inc_excl  char(1)
declare @STP_stp_event              varchar(12)
declare @STP_cmp_id                 varchar(8),
      @tar_time_calc_method         varchar(8)     -- PTS 46271 - DJM

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
declare @calc_time_at_stop decimal(19,4)
declare @calc_delay_time decimal(19,4)
declare @adjusted_delay_time decimal(19,4)
Declare @free_adjust_time  int

declare @unit_of_measure VARCHAR(6)

Declare @use_firstqualevent   int               -- PTS 51435 - DJM
Declare @use_lastqualevent int               -- PTS 51435 - DJM
Declare @firstevt_freetime decimal(19,4)     -- PTS 51435 - DJM
Declare @lastevent_freetime decimal(19,4)    -- PTS 51435 - DJM
declare @to_legstat varchar(12)               -- PTS 73326
declare @to_ordstat varchar(12)              -- PTS 73326
declare @to_stpstat varchar(12)              -- moved from below

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

--====== set up Temp Tables
   -- PTS 63602: moved definitions to top
   DECLARE  @temp_hour_incr_table TABLE (
      hit_rownbr int,
      hit_min_compare_value money )

   -- PTS 51436 - DJM - Modified the insertert to be sure it got all the appropriate rows for either an Order (Billing)
   -- or a Leg (Settlements)
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


--====== Get preliminary data and do General Validations.start
   IF @pl_ord_hdrnumber is NULL select @pl_ord_hdrnumber = 0
   IF @pl_lgh_number       is NULL select @pl_lgh_number = 0
   IF @pl_stp_number    is NULL select @pl_stp_number = 0

   --PTS 56258.start
   if @pl_ord_hdrnumber <=0 AND @pl_lgh_number <= 0 and @pl_stp_number <= 0
        BEGIN
          --PTS 60286 ( return ZERO rather than -1 )
          set @out_time = 0
          set @ps_excluded = 1
          set @ps_returnmsg = 'Error - Cannot Calculate Delay by stops when Order, Leg and Stop all = zero.'
          GOTO LabelProcedureEnd
           --RETURN
        END
   --PTS 56258.end

   if @TimeCalcDelayApplyAll = 'N'
      Begin
         -- if the GI is "N" test individual stop# passed in for eligiblity.
         set @delay_eligible = (select stp_delay_eligible from stops where stp_number =   @pl_stp_number)
         IF @delay_eligible is null select @delay_eligible = 'N'
         IF @delay_eligible <> 'Y'
            BEGIN
               -- GI is 'N' AND individual stop is not eligible.
               set @out_time = 0
               set @ps_excluded = 1
               -- set @ps_returnmsg = 'Stop is not Eligible';  don't need this message!
               set @ps_returnmsg = ''
               GOTO LabelProcedureEnd
               --RETURN
            END
      End

   -- PTS 73326.start; re-worked
   -- KEEP THIS SEQUENCE:
      -- If stop# exists, use it.
      -- else test for LEG
      -- else test for ORDER

-- PTS 73326.start
IF @pl_stp_number <> 0
   BEGIN
      select  @to_stpstat = min(stp_status) from stops where stp_number = @last_stop
      set @mov_number = (select min(mov_number) from stops where stp_number = @pl_stp_number)
      If  @to_stpstat <> 'DNE'
            BEGIN
                 set @out_time = 0       -- PTS 73325
                 set @ps_excluded = 1
                 set @ps_returnmsg = 'Stop ' + convert(varchar(10), @pl_stp_number) + ' not Done'
                 GOTO LabelProcedureEnd
            END
      Set @first_stop   = @pl_stp_number
      Set @last_stop = @pl_stp_number
   END
Else
   Begin
      --IF @pl_stp_number > 0 AND @pl_lgh_number > 0
      IF @pl_stp_number = 0 AND @pl_lgh_number > 0
         Begin
            select  @first_stop  =   stp_number_start,
                  @last_stop =   stp_number_end,
                  @to_legstat = lgh_outstatus from legheader where lgh_number =  @pl_lgh_number

            If  @to_legstat <> 'CMP'
            BEGIN
                 --set @out_time = -1    -- PTS 73325
                 set @out_time = 0       -- PTS 73325
                 set @ps_excluded = 1
                 set @ps_returnmsg = 'Leg not CMP'
                 GOTO LabelProcedureEnd
            END
            set @mov_number = (select min(mov_number) from legheader where lgh_number  =  @pl_lgh_number)
            set @pl_stp_number = @last_stop
         End
      Else
         Begin
            IF @pl_stp_number = 0 AND @pl_ord_hdrnumber > 0
            Begin
               select  @to_ordstat = min(ord_status) from orderheader where ord_hdrnumber = @pl_ord_hdrnumber
               If  @to_ordstat <> 'CMP'
                  BEGIN
                      --set @out_time = -1      -- PTS 73325
                       set @out_time = 0        -- PTS 73325
                       set @ps_excluded = 1
                       set @ps_returnmsg = 'Order Not CMP'
                       GOTO LabelProcedureEnd
                  END

               set @mov_number = (select min(mov_number) from orderheader where ord_hdrnumber = @pl_ord_hdrnumber)

               SELECT @first_stop = stp_number
               FROM stops
               WHERE stops.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                                 FROM stops
                                 WHERE mov_number = @mov_number)
               AND mov_number = @mov_number

               SELECT @last_stop = stp_number
               FROM stops
               WHERE stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                                 FROM stops
                                 WHERE mov_number = @mov_number)
               AND mov_number = @mov_number

               set @pl_stp_number = @last_stop
            End
         End
      End
-- PTS 73326.end


   IF @pl_stp_number > 0
      Begin

         IF  @pl_lgh_number = 0 AND @pl_ord_hdrnumber = 0
            BEGIN
            set @mov_number = (select min(mov_number) from stops where stp_number = @pl_stp_number and mov_number > 0)
               --PTS 60286.start
               If @mov_number is NULL SET @mov_number = 0
               IF @mov_number = 0
               BEGIN
                  set @out_time = 0
                  set @ps_excluded = 1
                  set @ps_returnmsg = 'Error - Calc delay by stops - Move Number = zero.'
                  GOTO LabelProcedureEnd
                  --RETURN
               END
               --PTS 60286.end

               --PTS 56258 ( outside select needs to be qualified by move# also )
               SELECT @first_stop = stp_number
               FROM stops
               WHERE stops.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                                       FROM stops
                                       WHERE mov_number = @mov_number and mov_number > 0)
               AND mov_number = @mov_number     --PTS 56258
               ANd mov_number > 0

               --PTS 56258 ( outside select needs to be qualified by move# also )
               SELECT @last_stop = stp_number
               FROM stops
               WHERE stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                                       FROM stops
                                       WHERE mov_number = @mov_number and mov_number > 0)
               AND mov_number = @mov_number     --PTS 56258
               AND mov_number > 0
            END

         Else
            begin
               IF  @pl_lgh_number > 0
               Begin
                  select  @first_stop  =   stp_number_start,
                        @last_stop =   stp_number_end,
                        @to_legstat = lgh_outstatus from legheader where lgh_number =  @pl_lgh_number and lgh_number > 0
                  IF @to_legstat is NULL select @to_legstat = ''

                  --PTS 56258.start
                  If  @to_legstat <> 'CMP'
                     BEGIN
                          --set @out_time = -1    -- PTS 73325
                          set @out_time = 0       -- PTS 73325
                          set @ps_excluded = 1
                          set @ps_returnmsg = 'Error - Calc delay by stops - Leg status for chosen Leg is Not CMP.'
                          GOTO LabelProcedureEnd
                     END
                  --PTS 56258.end

                  set @mov_number = (select min(mov_number) from legheader where lgh_number  =  @pl_lgh_number and lgh_number > 0)
                  --PTS 60286.start
                  If @mov_number is NULL SET @mov_number = 0
                  IF @mov_number = 0
                  BEGIN
                     set @out_time = 0
                     set @ps_excluded = 1
                     set @ps_returnmsg = 'Error - Calc delay by stops - Move Number = zero.'
                     GOTO LabelProcedureEnd
                     --RETURN
                  END
   --             --PTS 60286.end
               End
                  Else --IF @pl_ord_hdrnumber > 0
                     Begin
                        --PTS 56258.start
                        select  @to_ordstat = min(ord_status) from orderheader where ord_hdrnumber = @pl_ord_hdrnumber
                        IF @to_ordstat is NULL select @to_ordstat = ''

                        If  @to_ordstat <> 'CMP'
                        BEGIN
                           set @out_time = 0
                           set @ps_excluded = 1
                           set @ps_returnmsg = 'Error - Calc delay by stops - 1 Order status for chosen Order is Not CMP.' --1
                           GOTO LabelProcedureEnd
                           --RETURN
                        END
                        --PTS 56258.end

                        set @mov_number = (select min(mov_number) from orderheader where ord_hdrnumber = @pl_ord_hdrnumber and mov_number > 0)
                        --PTS 60286.start
                        If @mov_number is NULL SET @mov_number = 0
                        IF @mov_number = 0
                        BEGIN
                           set @out_time = 0
                           set @ps_excluded = 1
                           set @ps_returnmsg = 'Error - Calc delay by stops - Move Number = zero.'
                           GOTO LabelProcedureEnd
                           --RETURN
                        END
                        --PTS 60286.end

                        --PTS 56258 ( outside select needs to be qualified by move# also )
                        SELECT @first_stop = stp_number
                        FROM stops
                        WHERE stops.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                                          FROM stops
                                          WHERE mov_number = @mov_number and mov_number > 0)
                        AND mov_number = @mov_number
                        AND mov_number > 0

                        SELECT @last_stop = stp_number
                        FROM stops
                        WHERE stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                                          FROM stops
                                          WHERE mov_number = @mov_number and mov_number > 0)
                        AND mov_number = @mov_number
                        AND mov_number > 0
                     End
               End
      End   -- end of stop# > 0

   Else
      Begin
      --=========  stop# = zero BUT LEG # passed in
         IF  @pl_lgh_number > 0
            Begin
               select  @first_stop    = stp_number_start,
                     @last_stop    =   stp_number_end,
                     @to_legstat   = lgh_outstatus from legheader where lgh_number =   @pl_lgh_number

               If  @to_legstat is null select @to_legstat    = ''
               --PTS 56258.start
               If  @to_legstat <> 'CMP'
                  BEGIN
                       --set @out_time = -1    -- PTS 73325
                       set @out_time = 0       -- PTS 73325
                       set @ps_excluded = 1
                       set @ps_returnmsg = 'Error - Calc delay by stops - Leg status for chosen Leg is Not CMP.'
                       GOTO LabelProcedureEnd
                  END
               --PTS 56258.end

               set @mov_number = (select min(mov_number) from legheader where lgh_number  =  @pl_lgh_number and lgh_number > 0)
               --PTS 60286.start
               If @mov_number is NULL SET @mov_number = 0
               IF @mov_number = 0
               BEGIN
                  set @out_time = 0
                  set @ps_excluded = 1
                  set @ps_returnmsg = 'Error - Calc delay by stops - Move Number = zero.'
                  GOTO LabelProcedureEnd
                  --RETURN
               END
               --PTS 60286.end

               IF @pl_stp_number <= 0 set @pl_stp_number = @last_stop
            End
      Else if @pl_ord_hdrnumber > 0
       Begin
--          --=========  stop# = zero BUT ORDER # passed in
         IF @pl_ord_hdrnumber > 0
               Begin
                  --PTS 56258.start
                  select  @to_ordstat = min(ord_status) from orderheader where ord_hdrnumber = @pl_ord_hdrnumber
                  if @to_ordstat is null select @to_ordstat = ''
                  If  @to_ordstat <> 'CMP'
                  BEGIN
                     set @out_time = 0
                     set @ps_excluded = 1
                     set @ps_returnmsg = 'Error - Calc delay by stops - 2 Order status for chosen Order is Not CMP.'  --2
                     GOTO LabelProcedureEnd
                     --RETURN
                  END
                  --PTS 56258.end

                  set @mov_number = (select min(mov_number) from orderheader where ord_hdrnumber = @pl_ord_hdrnumber and mov_number > 0)
                  --PTS 60286.start
                  If @mov_number is NULL SET @mov_number = 0
                  IF @mov_number = 0
                  BEGIN
                     set @out_time = 0
                     set @ps_excluded = 1
                     set @ps_returnmsg = 'Error - Calc delay by stops - Move Number = zero.'
                     GOTO LabelProcedureEnd
                     --RETURN
                  END
                  --PTS 60286.end

                  --PTS 56258 ( outside select needs to be qualified by move# also )
                  SELECT @first_stop = stp_number
                  FROM stops
                  WHERE stops.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                                    FROM stops
                                    WHERE mov_number = @mov_number and mov_number > 0 )
                  AND mov_number = @mov_number
                  AND mov_number > 0

                  SELECT @last_stop = stp_number
                  FROM stops
                  WHERE stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                                    FROM stops
                                    WHERE mov_number = @mov_number and mov_number > 0)
                  AND mov_number = @mov_number
                  AND mov_number > 0

                  IF @pl_stp_number <= 0 set @pl_stp_number = @last_stop
               End
            End
         End
    --PTS 73326.end

   --PTS 60286.start
   if @first_stop is null select @first_stop = 0
   if @last_stop is null select @last_stop = 0
   If @mov_number is NULL SET @mov_number = 0

   IF @mov_number = 0
   BEGIN
      set @out_time = 0
      set @ps_excluded = 1
      set @ps_returnmsg = 'Error - Calc delay by stops - Move Number = zero.'
      GOTO LabelProcedureEnd
      --RETURN
   END

   IF @first_stop = 0  OR @last_stop = 0
   BEGIN
      set @out_time = 0
      set @ps_excluded = 1
      set @ps_returnmsg = 'Error - Calc delay by stops - First or Last stop Number = zero.'
      GOTO LabelProcedureEnd
      --RETURN
   END
   --PTS 60286.end

   --PTS 56258.start
   if  @last_stop > 0
   Begin
      select  @to_stpstat = min(stp_status) from stops where stp_number = @last_stop
      If  @to_stpstat <> 'DNE'
      BEGIN
         set @out_time = 0
         set @ps_excluded = 1    -- PTS 73325
         set @ps_returnmsg = 'Error - Calc delay by stops - Status for Last Stop is not DNE'
         GOTO LabelProcedureEnd
         --RETURN
      END
   End
   --PTS 56258.end
--====== General Validations.end


--====== Acquire data for calculations.start
if @pl_bill_or_stl = 'B'
    begin
      SET @unit_of_measure          = (select cht_unit from tariffheader where tar_number = @pl_tarnum )
      SET @tar_time_calc               = (select tar_time_calc from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_rounding       = (select tar_timecalc_rounding from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_increment         = (select tar_timecalc_increment from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_free_time         = (select isNull(tar_timecalc_free_time,0) from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_event_list     = (select tar_timecalc_event_list from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_events_inc_excl   = (select isNull(tar_timecalc_events_inc_excl,'Y') from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_compid_list    = (select tar_timecalc_compid_list from tariffheader where tar_number = @pl_tarnum )
      SET @tar_timecalc_compid_inc_excl   = (select isNull(tar_timecalc_compid_inc_excl,'Y') from tariffheader where tar_number = @pl_tarnum )
      Select @tar_time_calc_method = isNull(tar_timecalc_method,'1') from tariffheader where tar_number = @pl_tarnum

      -- PTS 51435 - DJM - If Necessary, build a list of the Stops applicable to this rate.
      select @use_firstqualevent = isNull(tar_timecalc_use_first_qualevent, 0) from tariffheader where tar_number = @pl_tarnum
      select @use_lastqualevent = isNull(tar_timecalc_use_last_qualevent,0) from tariffheader where tar_number = @pl_tarnum
      select @firstevt_freetime = isnull(tar_timecalc_first_qualevent_freetime,0) from tariffheader where tar_number = @pl_tarnum
      select @lastevent_freetime = isNull(tar_timecalc_last_qualevent_freetime,0) from tariffheader where tar_number = @pl_tarnum
    end

if @pl_bill_or_stl = 'S'
    begin
      SET @unit_of_measure          = (select cht_unit from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_time_calc               = (select tar_time_calc from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_rounding       = (select tar_timecalc_rounding from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_increment         = (select isNull(tar_timecalc_increment,0) from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_free_time         = (select isNull(tar_timecalc_free_time,0) from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_event_list     = (select tar_timecalc_event_list from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_events_inc_excl   = (select isNull(tar_timecalc_events_inc_excl,'Y') from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_compid_list    = (select tar_timecalc_compid_list from tariffheaderstl where tar_number = @pl_tarnum )
      SET @tar_timecalc_compid_inc_excl   = (select isNull(tar_timecalc_compid_inc_excl,'Y') from tariffheaderstl where tar_number = @pl_tarnum )

      Select @tar_time_calc_method = isNull(tar_timecalc_method,'1') from tariffheaderstl where tar_number = @pl_tarnum

      -- PTS 51435 - DJM - If Necessary, build a list of the Stops applicable to this rate.
      select @use_firstqualevent = isNull(tar_timecalc_use_first_qualevent,0) from tariffheaderstl where tar_number = @pl_tarnum
      select @use_lastqualevent = isNull(tar_timecalc_use_last_qualevent,0)from tariffheaderstl where tar_number = @pl_tarnum
      select @firstevt_freetime = isNull(tar_timecalc_first_qualevent_freetime,0) from tariffheaderstl where tar_number = @pl_tarnum
      select @lastevent_freetime = isNull(tar_timecalc_last_qualevent_freetime,0) from tariffheaderstl where tar_number = @pl_tarnum
    end

      -- PTS 51435 - DJM
      --67352 FIX for: no time being returned unless one of these flags is on
      --if @use_firstqualevent > 0 OR @use_lastqualevent > 0
      --BEGIN
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
         stp_reasonlate,                  -- PTS 63602
         stp_reasonlate_depart,           -- PTS 63602
         'N'                           -- PTS 63602
      FROM stops
      WHERE lgh_number = @pl_lgh_number
         AND lgh_number > 0
         AND (stp_delay_eligible = 'Y' OR @TimeCalcDelayApplyAll = 'Y')
      order by stops.stp_mfh_sequence

      -- remove any unnecessary rows
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

      -- Remove Stops whos Companies don't meet the requirements
      if @tar_timecalc_compid_inc_excl = 'Y' AND @tar_timecalc_compid_list is not null AND @tar_timecalc_compid_list <> 'UNKNOWN'  and @tar_timecalc_compid_list <> ''
         delete from #temp_stops_table
         where charindex(tst_cmp_id, ','+ @tar_timecalc_compid_list + ',') = 0

      else if @tar_timecalc_compid_inc_excl = 'N' AND @tar_timecalc_compid_list is not null AND @tar_timecalc_compid_list <> 'UNKNOWN'  and @tar_timecalc_compid_list <> ''
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


   --====== Unit of measure conversion.-------------------------------------------
      IF @unit_of_measure = 'HRS'
         BEGIN
            set @tar_timecalc_increment = @tar_timecalc_increment * 60
            set @tar_timecalc_free_time = @tar_timecalc_free_time * 60
            set @firstevt_freetime = @firstevt_freetime * 60
            set @lastevent_freetime = @lastevent_freetime * 60
         END

      IF @unit_of_measure = 'DAY'
         BEGIN
            set @tar_timecalc_increment = @tar_timecalc_increment * 1440
            set @tar_timecalc_free_time = @tar_timecalc_free_time * 1440
            set @firstevt_freetime = @firstevt_freetime * 1440
            set @lastevent_freetime = @lastevent_freetime * 1440
         END

      --====== ADJUST FREE TIME as needed:
      -- PTS 51435.start - DJM
      if @use_firstqualevent = 1
         Begin
            if @pl_stp_number  = (  select tst_stp_number
                              from #temp_stops_table ts1
                              where ts1.tst_stp_mfh_sequence = (  select min(tst2.tst_stp_mfh_sequence)
                                                         from #temp_stops_table tst2))
               select @tar_timecalc_free_time = @firstevt_freetime
         end

      if @use_lastqualevent = 1
         Begin
            if @pl_stp_number  = (  select tst_stp_number
                              from #temp_stops_table ts1
                              where ts1.tst_stp_mfh_sequence = (  select max(tst2.tst_stp_mfh_sequence)
                                                         from #temp_stops_table tst2))
               select @tar_timecalc_free_time = @lastevent_freetime
         end
      -- PTS 51435.end - DJM


      --====== Include_Exclude methods.start
         -- PTS 73326:  Tests that were needed were move UP to validation section;  Removed blocks of "old" commented out code

      --====== Include/Exclude Events
      IF @tar_timecalc_event_list = 'UNKNOWN' SELECT @tar_timecalc_event_list = NULL

      IF ISNULL(@tar_timecalc_event_list, '') <> ''
         BEGIN
            SET      @STP_stp_event = (select stp_event from stops where stp_number =  @pl_stp_number)
            IF    ISNULL(@STP_stp_event, '') <> ''
                  BEGIN
                     SET @tar_timecalc_event_list = ',' + LTRIM(RTRIM(ISNULL(@tar_timecalc_event_list, '')))  + ','
                     set @tar_timecalc_event_list = REPLACE(@tar_timecalc_event_list,' ','')
                     SET @STP_stp_event = ',' + LTRIM(RTRIM(ISNULL(@STP_stp_event, '')))  + ','
                  END

            IF   ( CHARINDEX(@STP_stp_event, @tar_timecalc_event_list) > 0  AND   @tar_timecalc_events_inc_excl = 'N'  )
               BEGIN
                  set @out_time = 0
                  set @ps_excluded = 1
                  set @ps_returnmsg = 'Exlcude this event: ' + @STP_stp_event
                  GOTO LabelProcedureEnd
                  --RETURN
               END

            -- PTS 43805 - issue Event INCLUDE bug:  ADD condition.
            IF   ( CHARINDEX(@STP_stp_event, @tar_timecalc_event_list) = 0  AND   @tar_timecalc_events_inc_excl = 'Y'  )
               BEGIN
                  set @out_time = 0
                  set @ps_excluded = 1
                  set @ps_returnmsg = 'EVENT not in INCLUDE list: ' + @STP_stp_event
                  GOTO LabelProcedureEnd
                  --RETURN
               END
         END   -- end of event processing

      --====== Include/Exclude Companies
      IF @tar_timecalc_compid_list = 'UNKNOWN'  Select @tar_timecalc_compid_list = NULL

      IF ISNULL(@tar_timecalc_compid_list, '') <> ''
         BEGIN
            SET      @STP_cmp_id    = (select cmp_id     from stops where stp_number = @pl_stp_number)
            IF    ISNULL(@STP_cmp_id, '') <> ''
                  BEGIN
                     SET @tar_timecalc_compid_list= ',' + LTRIM(RTRIM(ISNULL(@tar_timecalc_compid_list, '')))  + ','
                     set @tar_timecalc_compid_list = REPLACE(@tar_timecalc_compid_list,' ','')
                     SET @STP_cmp_id = ',' + LTRIM(RTRIM(ISNULL(@STP_cmp_id, '')))  + ','
                  END

            IF ( CHARINDEX(@STP_cmp_id, @tar_timecalc_compid_list) > 0  AND  @tar_timecalc_compid_inc_excl = 'N' )
            BEGIN
               set @out_time = 0
               set @ps_excluded = 1
               set @ps_returnmsg = 'Exlcude this company: ' + @STP_cmp_id
               GOTO LabelProcedureEnd
               --RETURN
            END

   --          PTS 43805 - issue #3 company INCLUDE bug:  ADD condition.
            IF ( CHARINDEX(@STP_cmp_id, @tar_timecalc_compid_list) = 0  AND  @tar_timecalc_compid_inc_excl = 'Y' )
            BEGIN
               set @out_time = 0
               set @ps_excluded = 1
               set @ps_returnmsg = 'COMPANY not in INCLUDE list: ' + @STP_cmp_id
               GOTO LabelProcedureEnd
               --RETURN
            END
         END   -- end of company processing
         --====== Include_Exclude methods.end
--====== Acquire data for calculations.end


--====== Calculations.start
   --====== Do work ===================================================================================================
   -- test for the various time_calc_methods (currently there are 4; 7-7-2014); take action based on these values.

   -- pts 63602 someone broke this - should be the temp table NOT stops table!
   set @schdtearliest   = (select tst_stp_schdtearliest from #temp_stops_table where tst_stp_number = @pl_stp_number)
   set @arrivaldate  = (select tst_stp_arrivaldate from #temp_stops_table where tst_stp_number =      @pl_stp_number)
   set @departuredate   = (select tst_stp_departuredate from #temp_stops_table where tst_stp_number = @pl_stp_number)
   set @firm_appt_flag = (select isnull(tst_stp_firm_appt_flag,'N')  from #temp_stops_table where tst_stp_number =   @pl_stp_number)
   set @schdtlatest  = (select tst_stp_schdtlatest from #temp_stops_table where tst_stp_number =      @pl_stp_number)

   set @calc_arrival = @arrivaldate
   set @free_adjust_time = 0  -- PTS 66270

   -- PTS 66270; contain this set of conditions:
   IF @tar_time_calc_method = '1'  OR @tar_time_calc_method = '2' OR @tar_time_calc_method = '3'  OR @tar_time_calc_method = '4'
   BEGIN

      -- PTS 46271 - DJM - Use the TimeCalc_method to determine how to compute the time
      -- If firm appt set for the stop - choose the latest of scheduled_arrival or arrival
      --BEGIN NSUITE-103427 SPN (Restored 46271 originally coded by DJM and commented out Judy's code)
      IF (@tar_time_calc_method = '1' AND @firm_appt_flag = 'Y') OR @tar_time_calc_method = '2'
      --IF @tar_time_calc_method = '1'  OR @tar_time_calc_method = '2'
      --END NSUITE-103427 SPN (Restored 46271 originally coded by DJM and commented out Judy's code)
         BEGIN
            set @calc_arrival = @arrivaldate

            IF @schdtearliest  > @arrivaldate
               BEGIN
                  set @calc_arrival = @schdtearliest
               END

            set @calc_time_at_stop = datediff(mi, @calc_arrival, @departuredate)
         END
      -------  end of 'if = '1' or '2' condition

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

            Set @tar_timecalc_free_time = @tar_timecalc_free_time + @free_adjust_time
            set @calc_time_at_stop = datediff(mi, @arrivaldate, @departuredate)
         End
      -------  end of 'if = '3' condition

      --BEGIN NSUITE-103427 SPN (just "else" is misleading)
      --else
      ELSE if @tar_time_calc_method = '4'
      --BEGIN NSUITE-103427 SPN (else is misleading)
         Begin
               --  ELSE @tar_time_calc_method = '4'
               --  PTS 66270.start; introduce tar_timecalc_method = '4'
               --  SCHEDULED LATEST; if arrival outside of scheduled window; apply to free time
               --  If arrival is BETWEEN scheduled-early & scheduled-late; use the greatest of either the arrival or the scheduled-late
               --  If arrival is PRIOR to scheduled-early then apply time to free time
               --  If arrival is AFTER scheduled-late; then they arrived late & no delay time is calculated {would have already exited the proc}.

            Set @free_adjust_time = 0
            IF ( @arrivaldate >= @schdtearliest AND @arrivaldate <= @schdtlatest )
               BEGIN
                  -- BETWEEN scheduled-early/late     -- arrival date becomes ==> Scheduled LATEST <==
                  set @calc_arrival = @schdtlatest
               END
            Else
               BEGIN
                  -- Load arrived 'early'; add to the free time
                  IF @schdtearliest  > @arrivaldate
                     Begin
                        set @calc_arrival = @arrivaldate    -- arrival date remains as arrival date
                        set @free_adjust_time = datediff(mi, @arrivaldate, @schdtearliest)
                     End
                  -- Load arrived 'late'; not eligible for delay
                  IF @arrivaldate  > @schdtlatest
                     Begin
                        set @calc_arrival = @arrivaldate    -- arrival date remains as arrival date
                        set @free_adjust_time = 0
                        IF @GIStr3_ExcludeLate = 'Y'
                        BEGIN
                           set @out_time = 0
                           set @ps_returnmsg = 'Exclude Stop due to Late Arrival: ' + cast(@pl_stp_number as varchar(8))                                                                        set @ps_excluded = 1
                           GOTO LabelProcedureEnd
                        END
                     End
               END

            Set @tar_timecalc_free_time = IsNull(@tar_timecalc_free_time,0) + IsNull(@free_adjust_time, 0 )
            -- calc_arrival at this point is ==> Scheduled LATEST <==
            Set @calc_time_at_stop = datediff(mi, @calc_arrival, @departuredate)

            set @calc_delay_time = @calc_time_at_stop - ( ISNULL(@tar_timecalc_free_time, 0) )     -- Apply Free Time, if any
         End
      -------  end of 'if = '4' condition
   END
   -- end


------- Calculate the Delay Time, if any
   --BEGIN PTS 93232 SGB use the caclualted date @cals_arrival and not the arrival date
    set @calc_time_at_stop = datediff(mi, @calc_arrival, @departuredate)
    --set @calc_time_at_stop = datediff(mi, @arrivaldate, @departuredate)
   --END PTS 93232 SGB use the caclualted date @cals_arrival and not the arrival date
   set @calc_delay_time = @calc_time_at_stop - ( ISNULL(@tar_timecalc_free_time, 0) )     -- Apply Free Time, if any

   IF @calc_delay_time <= 0
      BEGIN
         set @out_time = 0
         set @ps_excluded = 1
         set @ps_returnmsg = 'Free time exceeds stop time'
         --RETURN
         GOTO LabelProcedureEnd
      END
--  PTS 66270.end


   --====== Apply Rounding.start;      {DO For ALL @tar_time_calc_methods }
      -- validate
      if    ( ISNULL(@tar_timecalc_increment, 0))  <= 0
         BEGIN
            if UPPER(@tar_timecalc_rounding) <> 'NONE'
               BEGIN
                  set @out_time = 0
                  set @ps_excluded = 1
                  set @ps_returnmsg = 'Increment is ZERO - Process Halted.'
                   --RETURN
                    GOTO LabelProcedureEnd
               END
            if UPPER(@tar_timecalc_rounding) = 'NONE'
               BEGIN
                  Set @tar_timecalc_increment = 60
               END
         END
               -- --Calculate Rounding
                  --  7-21-2008 change for 43583 defaulting no rounding to zero.
                  --if  ( ISNULL(@tar_timecalc_increment, 0))  <= 0
                  -- BEGIN
                  --    --set @out_time = -1
                  --    set @out_time = 0
                  --    set @ps_excluded = 1
                  --    set @ps_returnmsg = 'Increment is ZERO - Process Halted.'
                  --    GOTO LabelProcedureEnd
                  --    --RETURN
                  -- END


   --======  Next Step: Do the math.
   declare @next_least_value money
   declare @next_greater_value money
   declare @incr_dividend int
   declare @incr_quotient money
   declare @loop_counter int

   IF @calc_delay_time <= 60
      BEGIN
         set @incr_dividend = 60
      END
   IF @calc_delay_time > 60
      BEGIN
         set @incr_dividend = ( ceiling(cast(@calc_delay_time as int) / 60) + 1 ) * 60
      END
                  -- moved to top
                  --DECLARE   @temp_hour_incr_table TABLE (
                  -- hit_rownbr int,
                  -- hit_min_compare_value money )

   if @tar_timecalc_increment = 0 set @tar_timecalc_increment = 1       -- PTS 63602   division by zero error.
   set @incr_quotient =   ( @incr_dividend / @tar_timecalc_increment )

      -------  populate temp table
      set @loop_counter = 0
      -- populate the table with the time rounding values  (thing-a-ma-bob that does the job)
      WHILE @loop_counter < ( @incr_quotient + 1 )
         BEGIN
            INSERT INTO @temp_hour_incr_table(hit_rownbr, hit_min_compare_value)
               Select @loop_counter, round( @tar_timecalc_increment * @loop_counter , 0 )

               SET @loop_counter = @loop_counter + 1
         END
      -- end of loop


      set @next_least_value = (select   max(hit_min_compare_value) from @temp_hour_incr_table
                                     where  hit_min_compare_value <= @calc_delay_time )
      set @next_greater_value = (select   min(hit_min_compare_value) from @temp_hour_incr_table
                                     where  hit_min_compare_value >= @calc_delay_time )

      --====== if @tar_timecalc_rounding = none => use the actual value. Init @ actual value.
      SET @adjusted_delay_time = @calc_delay_time
      if @calc_delay_time is null select @calc_delay_time = 0

            -- PTS 43806 : apply rounding even if free time is zero.
            --    IF @cumulative_delay_time > 0  AND  ( ISNULL(@tar_timecalc_free_time, 0) ) > 0
            IF @calc_delay_time > 0
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
                        IF ( @calc_delay_time   - @next_least_value )  < ( @next_greater_value - @calc_delay_time )
                              BEGIN
                                 set   @adjusted_delay_time = @next_least_value
                              END
                        IF ( @calc_delay_time   - @next_least_value )  >= ( @next_greater_value - @calc_delay_time )
                              BEGIN
                                 set   @adjusted_delay_time = @next_greater_value
                              END
                     END
               End
   --====== Apply Rounding.end

      --JD 63570 Start
      if UPPER(@pl_bill_or_stl) = 'S'
      begin
         declare @maxPerDay decimal, @timeFrame varchar(6), @startTime datetime,@days int,@newadjtime decimal,@finalday decimal
         select   @maxPerDay = Case @unit_of_measure When 'HRS' then tar_timecalc_max_qty *60 When 'DAYS' then tar_timecalc_max_qty * 1440 else tar_timecalc_max_qty end,
               @timeFrame = IsNull(tar_timecalc_max_qty_timeframe,'UNK')
         from  tariffheaderstl
         where tar_number = @pl_tarnum

         if @timeFrame ='24'
         begin
            select @starttime = DATEADD(mi,ISNULL(@tar_timecalc_free_time, 0),@calc_arrival)
            select @days = CEILING(@adjusted_delay_time/1440.0)
            select @newadjtime = Case  when @maxPerDay < 1440 then (@days - 1) * @maxPerDay else (@days - 1) * 1440.0 end
            select @finalday = Case  when @maxPerDay < (1440.0 - ((@days * 1440.0) - @adjusted_delay_time )) then @maxPerDay
                              else (1440.0 - ((@days * 1440.0) - @adjusted_delay_time )) end
            select @newadjtime = @newadjtime + @finalday
            select @adjusted_delay_time = @newadjtime
         end
      end
      -- JD end 63570

   --======  Before return the value - convert it BACK to the UOM sent in.
   IF @unit_of_measure = 'HRS'
      BEGIN
         set @adjusted_delay_time = @adjusted_delay_time / 60
      END

   IF @unit_of_measure = 'DAY'
      BEGIN
         set @adjusted_delay_time = @adjusted_delay_time / 1440
      END
--====== Calculations.end
--====== Return the final values

--  PTS 66270; added label; CONTROL when/how proc is exited!!!
LabelProcedureEnd:
 --Return the final values
if @ps_excluded = 1 Set @adjusted_delay_time = @out_time
   SET @out_time = IsNull(@adjusted_delay_time,0)  -- PTS 63602
   SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))

GO
GRANT EXECUTE ON  [dbo].[get_calculated_delay_per_stops_sp] TO [public]
GO
