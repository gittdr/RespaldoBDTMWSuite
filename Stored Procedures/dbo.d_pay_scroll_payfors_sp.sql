SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [dbo].[d_pay_scroll_payfors_sp]    (@Types varchar(60),
               @Status varchar(6),
               @LoPayDate datetime,
               @HiPayDate datetime,
               @Company char(6),
               @Fleet char(6),
               @Division char(6),
               @Terminal char(6),
               @DrvType1 char(6),
               @DrvType2 char(6),
               @DrvType3 char(6),
               @DrvType4 char(6),
               @TrcType1 char(6),
               @TrcType2 char(6),
               @TrcType3 char(6),
               @TrcType4 char(6),
               @TrlType1 char(6),
               @TrlType2 char(6),
               @TrlType3 char(6),
               @TrlType4 char(6),
               @Driver char(8),
               @Tractor char(8),
               @Trailer char(13),
               @account_type char(1),
               @Carrier char(8),
               @CarType1 char(6),
               @CarType2 char(6),
               @CarType3 char(6),
               @CarType4 char(6),
               @tpr_id char(8),
               @tpr_type char(12),
               @BRN_ID varchar(256),   -- PTS 41389 GAP 74
               @G_USERID varchar(14),   -- PTS 41389 GAP 74
               @sch  int,
               @payto   varchar(12),      --vjh 54402 coowners
               @view_id          varchar(6),
               @tpr_revtype1 varchar(6),
               @tpr_revtype2 varchar(6),
               @tpr_revtype3 varchar(6),
               @tpr_revtype4 varchar(6)
             , @mpp_branch             VARCHAR(12)
             , @trc_branch             VARCHAR(12)
             , @trl_branch             VARCHAR(12)
             , @car_branch             VARCHAR(12)
)  AS

/**
 *
 * NAME:
 * dbo.d_pay_scroll_payfors_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for the settlement queues.
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * Modification history:
 * MRH 31225 2/10/06 3rd party support
 * 04/27/2009.01 PTS46278 - vjh - added grace logic and new setting
 * 11/02/2010    PTS54303 - Additional filtering mechanism based on new GI setting
 * 06/07/2011   PTS54402 - vjh - add coowner logic for tractor
 * LOR   PTS# 58375  views
 * 11/26/2012    PTS64692 - jet - add 3rd party revenue types to restrict Collect queue by 3rd Party revenue types
 * SPN   PTS# 63448  fixing trailer parm issue
 * 11/08/2012 PTS 65645 SPN - Added Restriction @mpp_branch, @trc_branch, @trl_branch, @car_branch
 * 06/24/2012 PTS 70279 SPN - Asset should appear in the queue when headers reopened (PND)
 */

/*WITH RECOMPILE */

-- LOR   PTS# 58375
-- *************
-- *************  PLEASE MAKE CHANGES IN BOTH PROCS IF NECESSARY  *************
-- *************
If @view_id <> ''
   exec d_pay_scroll_payfors_forviews_sp @Status, @LoPayDate , @HiPayDate ,@sch, @view_id
Else
Begin
-- PTS 41389 GAP 74 Start
IF @brn_id = NULL or @brn_id = '' or @brn_id  = 'UNK'
   begin
      SELECT @brn_id = 'UNKNOWN'
   end

SELECT @brn_id = ',' + LTRIM(RTRIM(ISNULL(@brn_id, '')))  + ','
-- PTS 41389 GAP 74 end


declare
   @AcctType1     char(1) ,
   @AcctType2     char(1) ,
   @drivers_yes   int,
   @tractors_yes  int,
   @trailer_yes   int,
   @carrier_yes   int,
   @type       varchar(6),
   @id            char(13),
   @paydate    datetime,
   @tpr_yes    int,
   @daysout    int,
   @process_netpayzero char(1),  -- pts 54303
   @coownerpaytos char(1)

select @coownerpaytos = left(upper(gi_string1),1) from generalinfo where gi_name = 'coownerpaytos'
if @coownerpaytos is null select @coownerpaytos = 'N'

--vjh 46278
SELECT @daysout = -60

-- pts 54303 <<start>>
select @process_netpayzero = 'N'
If exists (select * from generalinfo where gi_name = 'CollectQ_NetPayZero' and gi_string1 = 'Y')
   begin
      select @process_netpayzero = 'Y'
   end
-- pts 54303 <<end>>

If exists (select * from generalinfo where gi_name = 'UseGraceInCollectQueue' and gi_string1 = 'Y')
   if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
      select @daysout = lbp_daysout
         from ListBoxProperty
         where lbp_id=@@spid
   else
      SELECT @daysout = gi_integer1
         FROM  generalinfo
      WHERE gi_name = 'GRACE'

if @daysout is null SELECT @daysout = -60

-- PTS 22990 -- BL (start)
--SELECT @paydate = dateadd ( hour, -23, @HiPayDate )
--SELECT @paydate = dateadd ( minute, -59, @paydate )
SELECT @paydate = CONVERT(DATETIME,CONVERT(CHAR(10),@HiPayDate,101))
-- PTS 22990 -- BL (end)

/* SET ACCOUNT TYPES */
if @account_type = 'X'
   begin /* treat 'Any' as either A or P */
   SELECT @AcctType1 = 'A'
   SELECT @AcctType2 = 'P'
   end
else if @account_type = 'A'
   begin
   SELECT @AcctType1 = 'A'
   SELECT @AcctType2 = 'A'
   end
else if @account_type = 'P'
   begin
   SELECT @AcctType1 = 'P'
   SELECT @AcctType2 = 'P'
   end
else
   begin /* treat 'none' as invalid */
   SELECT @AcctType1 = '.'
   SELECT @AcctType2 = '.'
   end

/* CREATE TEMP TABLE */
SELECT   pyh_pyhnumber,
   asgn_type,
   asgn_id,
   pyh_paystatus ,
   pyh_payperiod ,
   pyh_totalcomp ,
   pyh_totaldeduct ,
   pyh_totalreimbrs,
   CAST('' as Char(12)) 'branch',   -- PTS 41389 GAP 74
   Cast (0 as Money) 'pyh_totalcomp_positive',  -- pts 54303
   Cast (0 as Money) 'pyh_totalcomp_negative',  -- pts 54303
   pyh_payto   --vjh 54402
INTO #temp
FROM payheader
WHERE 1 = 2

select @drivers_yes = charindex('DRV', @Types)
select @tractors_yes = charindex('TRC', @Types)
select @trailer_yes = charindex('TRL', @Types)
select @carrier_yes = charindex('CAR', @Types)
select @tpr_yes = charindex('TPR', @Types)

IF (@drivers_yes = 0) AND (@tractors_yes = 0) AND (@trailer_yes = 0) AND (@carrier_yes = 0) AND (@tpr_yes = 0)
   begin
   SELECT * FROM #temp
   return
   end

/* GENERATE ASSET LISTS FOR DRIVER */
if (@drivers_yes > 0)
begin
   insert into #temp
   SELECT   999,
      'DRV',
      mpp_id,
      '-' ,
      @HiPayDate,
      0.0000,
      0.0000,
      0.0000,
      mpp_branch, -- PTS 41389 GAP 74
      0.0000, -- pts 54303
      0.0000,  -- pts 54303
      mpp_payto
   FROM manpowerprofile
   WHERE ( mpp_status <> 'OUT' OR mpp_terminationdt > dateadd ( day, @daysout, @HiPayDate ) or @daysout=999) AND --vjh 46278
      ( @Driver in ( 'UNKNOWN' , mpp_id ) ) AND
      ( @Company in ( 'UNK' , mpp_company ) ) AND
      ( @Fleet in ( 'UNK' , mpp_fleet ) ) AND
      ( @Division in ( 'UNK' , mpp_division ) ) AND
      ( @Terminal in ( 'UNK' , mpp_terminal ) ) AND
      ( @DrvType1 in ( 'UNK' , mpp_type1 ) ) AND
      ( @DrvType2 in ( 'UNK' , mpp_type2 ) ) AND
      ( @DrvType3 in ( 'UNK' , mpp_type3 ) ) AND
      ( @DrvType4 in ( 'UNK' , mpp_type4 ) ) AND
      ( mpp_actg_type in ( @AcctType1 , @AcctType2 ) ) AND
      --PTS 38816 JJF 20080312 add additional needed parms
      --PTS 51570 JJF 20100510
      --dbo.RowRestrictByUser (mpp_terminal, '', '', '') = 1   AND -- 11/29/2007 MDH PTS 40119: Added
      dbo.RowRestrictByUser ('manpowerprofile', manpowerprofile.rowsec_rsrv_id, '', '', '') = 1 AND
      ( NOT EXISTS ( SELECT *
            FROM payheader
            WHERE asgn_type = 'DRV' AND
               asgn_id = manpowerprofile.mpp_id AND
               pyh_payperiod = @paydate AND
               pyh_paystatus <> 'PND' )
      --BEGIN PTS 70279 SPN
      OR EXISTS ( SELECT 1
                    FROM payheader
                   WHERE asgn_type = 'DRV'
                     AND asgn_id = manpowerprofile.mpp_id
                     AND pyh_payperiod = @paydate
                     AND pyh_paystatus = 'PND'
               )
      --END PTS 70279 SPN
      )
      --BEGIN PTS 65645 SPN
      AND (@mpp_branch = 'UNKNOWN' OR @mpp_branch = manpowerprofile.mpp_branch)
      --END PTS 65645 SPN
end

/* GENERATE ASSET LISTS FOR TRACTOR */
if (@tractors_yes > 0)
begin
   if @coownerpaytos = 'N' --vjh 54402 coowners
      insert into #temp
      SELECT   -1,
         'TRC',
         trc_number,
         '-' ,
         @HiPayDate,
         0.0000,
         0.0000,
         0.0000,
         trc_branch, -- PTS 41389 GAP 74
         0.0000, -- pts 54303
         0.0000,  -- pts 54303
         trc_owner
      FROM tractorprofile
      WHERE ( trc_status <> 'OUT' OR trc_retiredate > dateadd ( day, @daysout, @HiPayDate ) or @daysout=999) AND --vjh 46278
         ( @Tractor in ( 'UNKNOWN' , trc_number ) ) AND
         ( @Company in ( 'UNK' , trc_company ) ) AND
         ( @Fleet in ( 'UNK' , trc_fleet ) ) AND
         ( @Division in ( 'UNK' , trc_division ) ) AND
         ( @Terminal in ( 'UNK' , trc_terminal ) ) AND
         ( @TrcType1 in ( 'UNK' , trc_type1 ) ) AND
         ( @TrcType2 in ( 'UNK' , trc_type2 ) ) AND
         ( @TrcType3 in ( 'UNK' , trc_type3 ) ) AND
         ( @TrcType4 in ( 'UNK' , trc_type4 ) ) AND
         ( trc_actg_type in ( @AcctType1 , @AcctType2 ) )  AND
         --PTS 38816 JJF 20080312 add additional needed parms
         --PTS 51570 JJF 20100510
         --dbo.RowRestrictByUser (trc_terminal, '', '', '') = 1   AND -- 11/29/2007 MDH PTS 40119: Added
         dbo.RowRestrictByUser ('tractorprofile', tractorprofile.rowsec_rsrv_id, '', '', '') = 1   AND
         ( NOT EXISTS ( SELECT *
               FROM payheader
               WHERE asgn_type = 'TRC' AND
                  asgn_id = tractorprofile.trc_number AND
                  pyh_payperiod = @paydate AND
                  pyh_paystatus <> 'PND' )
         --BEGIN PTS 70279 SPN
         OR EXISTS ( SELECT 1
                       FROM payheader
                      WHERE asgn_type = 'TRC'
                        AND asgn_id = tractorprofile.trc_number
                        AND pyh_payperiod = @paydate
                        AND pyh_paystatus = 'PND'
                   )
         --END PTS 70279 SPN
         )
      --BEGIN PTS 65645 SPN
      AND (@trc_branch = 'UNKNOWN' OR @trc_branch = tractorprofile.trc_branch)
      --END PTS 65645 SPN
   else begin --@coowners = 'Y'
      if @payto <> 'UNKNOWN' begin
         select @tractor = MIN(trc_number) from tractorprofile where (trc_owner = @payto or trc_owner2 = @payto)
         insert into #temp
         SELECT   -1,
            'TRC',
            trc_number,
            '-' ,
            @HiPayDate,
            0.0000,
            0.0000,
            0.0000,
            trc_branch, -- PTS 41389 GAP 74
            0.0000, -- pts 54303
            0.0000,  -- pts 54303
            @payto
         FROM tractorprofile
         WHERE ( trc_status <> 'OUT' OR trc_retiredate > dateadd ( day, @daysout, @HiPayDate ) or @daysout=999) AND --vjh 46278
            --( @Tractor in ( 'UNKNOWN' , trc_number ) ) AND
            (
               @payto in ( 'UNKNOWN' , trc_owner )
               OR
               @payto in ( 'UNKNOWN' , trc_owner2 )
            ) AND
            ( @Company in ( 'UNK' , trc_company ) ) AND
            ( @Fleet in ( 'UNK' , trc_fleet ) ) AND
            ( @Division in ( 'UNK' , trc_division ) ) AND
            ( @Terminal in ( 'UNK' , trc_terminal ) ) AND
            ( @TrcType1 in ( 'UNK' , trc_type1 ) ) AND
            ( @TrcType2 in ( 'UNK' , trc_type2 ) ) AND
            ( @TrcType3 in ( 'UNK' , trc_type3 ) ) AND
            ( @TrcType4 in ( 'UNK' , trc_type4 ) ) AND
            ( trc_actg_type in ( @AcctType1 , @AcctType2 ) )  AND
            --PTS 38816 JJF 20080312 add additional needed parms
            --PTS 51570 JJF 20100510
            --dbo.RowRestrictByUser (trc_terminal, '', '', '') = 1   AND -- 11/29/2007 MDH PTS 40119: Added
            dbo.RowRestrictByUser ('tractorprofile', tractorprofile.rowsec_rsrv_id, '', '', '') = 1   AND
            --vjh 54402 need to still allow the tractor if one of the coowners is ready
            ( NOT EXISTS ( SELECT *
                  FROM payheader
                  WHERE asgn_type = 'TRC' AND
                     asgn_id = tractorprofile.trc_number AND
                     pyh_payperiod = @paydate AND
                     pyh_paystatus <> 'PND'
                     AND pyh_payto = @payto )
            --BEGIN PTS 70279 SPN
            OR EXISTS ( SELECT 1
                          FROM payheader
                         WHERE asgn_type = 'TRC'
                           AND asgn_id = tractorprofile.trc_number
                           AND pyh_payperiod = @paydate
                           AND pyh_paystatus = 'PND'
                           AND pyh_payto = @payto
                      )
            --END PTS 70279 SPN
            )
            --BEGIN PTS 65645 SPN
            AND (@trc_branch = 'UNKNOWN' OR @trc_branch = tractorprofile.trc_branch)
            --END PTS 65645 SPN
      end else begin
         --use trc_owner (coowner1)
         insert into #temp
         SELECT   -1,
            'TRC',
            trc_number,
            '-' ,
            @HiPayDate,
            0.0000,
            0.0000,
            0.0000,
            trc_branch, -- PTS 41389 GAP 74
            0.0000, -- pts 54303
            0.0000,  -- pts 54303
            trc_owner
         FROM tractorprofile
         WHERE ( trc_status <> 'OUT' OR trc_retiredate > dateadd ( day, @daysout, @HiPayDate ) or @daysout=999) AND --vjh 46278
            --( @Tractor in ( 'UNKNOWN' , trc_number ) ) AND
            ( @payto in ( 'UNKNOWN' , trc_owner ) ) AND
            ( @Company in ( 'UNK' , trc_company ) ) AND
            ( @Fleet in ( 'UNK' , trc_fleet ) ) AND
            ( @Division in ( 'UNK' , trc_division ) ) AND
            ( @Terminal in ( 'UNK' , trc_terminal ) ) AND
            ( @TrcType1 in ( 'UNK' , trc_type1 ) ) AND
            ( @TrcType2 in ( 'UNK' , trc_type2 ) ) AND
            ( @TrcType3 in ( 'UNK' , trc_type3 ) ) AND
            ( @TrcType4 in ( 'UNK' , trc_type4 ) ) AND
            ( trc_actg_type in ( @AcctType1 , @AcctType2 ) )  AND
            --PTS 38816 JJF 20080312 add additional needed parms
            --PTS 51570 JJF 20100510
            --dbo.RowRestrictByUser (trc_terminal, '', '', '') = 1   AND -- 11/29/2007 MDH PTS 40119: Added
            dbo.RowRestrictByUser ('tractorprofile', tractorprofile.rowsec_rsrv_id, '', '', '') = 1   AND
            --vjh 54402 need to still allow the tractor if one of the coowners is ready
            ( NOT EXISTS ( SELECT *
                  FROM payheader
                  WHERE asgn_type = 'TRC' AND
                     asgn_id = tractorprofile.trc_number AND
                     pyh_payperiod = @paydate AND
                     pyh_paystatus <> 'PND'
                     AND pyh_payto = trc_owner )
            --BEGIN PTS 70279 SPN
            OR EXISTS ( SELECT 1
                          FROM payheader
                         WHERE asgn_type = 'TRC'
                           AND asgn_id = tractorprofile.trc_number
                           AND pyh_payperiod = @paydate
                           AND pyh_paystatus = 'PND'
                           AND pyh_payto = trc_owner
                      )
            --END PTS 70279 SPN
            ) AND
            ( trc_owner <> 'UNKNOWN' )
            --BEGIN PTS 65645 SPN
            AND (@trc_branch = 'UNKNOWN' OR @trc_branch = tractorprofile.trc_branch)
            --END PTS 65645 SPN
         --use trc_owner2 (coowner2)
         insert into #temp
         SELECT   -1,
            'TRC',
            trc_number,
            '-' ,
            @HiPayDate,
            0.0000,
            0.0000,
            0.0000,
            trc_branch, -- PTS 41389 GAP 74
            0.0000, -- pts 54303
            0.0000,  -- pts 54303
            trc_owner2
         FROM tractorprofile
         WHERE ( trc_status <> 'OUT' OR trc_retiredate > dateadd ( day, @daysout, @HiPayDate ) or @daysout=999) AND --vjh 46278
            --( @Tractor in ( 'UNKNOWN' , trc_number ) ) AND
            ( @payto in ( 'UNKNOWN' , trc_owner2 ) ) AND
            ( trc_owner2 <> 'UNKNOWN' ) AND  --vjh 54402 do not add duplicates for an UNKNOWN owner2
            ( @Company in ( 'UNK' , trc_company ) ) AND
            ( @Fleet in ( 'UNK' , trc_fleet ) ) AND
            ( @Division in ( 'UNK' , trc_division ) ) AND
            ( @Terminal in ( 'UNK' , trc_terminal ) ) AND
            ( @TrcType1 in ( 'UNK' , trc_type1 ) ) AND
            ( @TrcType2 in ( 'UNK' , trc_type2 ) ) AND
            ( @TrcType3 in ( 'UNK' , trc_type3 ) ) AND
            ( @TrcType4 in ( 'UNK' , trc_type4 ) ) AND
            ( trc_actg_type in ( @AcctType1 , @AcctType2 ) )  AND
            --PTS 38816 JJF 20080312 add additional needed parms
            --PTS 51570 JJF 20100510
            --dbo.RowRestrictByUser (trc_terminal, '', '', '') = 1   AND -- 11/29/2007 MDH PTS 40119: Added
            dbo.RowRestrictByUser ('tractorprofile', tractorprofile.rowsec_rsrv_id, '', '', '') = 1   AND
            --vjh 54402 need to still allow the tractor if one of the coowners is ready
            ( NOT EXISTS ( SELECT *
                  FROM payheader
                  WHERE asgn_type = 'TRC' AND
                     asgn_id = tractorprofile.trc_number AND
                     pyh_payperiod = @paydate AND
                     pyh_paystatus <> 'PND'
                     AND pyh_payto = trc_owner2 )
            --BEGIN PTS 70279 SPN
            OR EXISTS ( SELECT 1
                          FROM payheader
                          WHERE asgn_type = 'TRC'
                            AND asgn_id = tractorprofile.trc_number
                            AND pyh_payperiod = @paydate
                            AND pyh_paystatus = 'PND'
                            AND pyh_payto = trc_owner2
                      )
            --END PTS 70279 SPN
            )   AND
            ( trc_owner2 <> 'UNKNOWN' )
            --BEGIN PTS 65645 SPN
            AND (@trc_branch = 'UNKNOWN' OR @trc_branch = tractorprofile.trc_branch)
            --END PTS 65645 SPN
      end
   end
end
/* GENERATE ASSET LISTS FOR TRAILER */
if (@trailer_yes > 0)
begin
   insert into #temp
   SELECT   -1,
      'TRL',
      trl_id,
      '-' ,
      @HiPayDate,
      0.0000,
      0.0000,
      0.0000,
      trl_branch,  -- PTS 41389 GAP 74
      0.0000, -- pts 54303
      0.0000,  -- pts 54303
      trl_owner
   FROM trailerprofile
   WHERE ( trl_status <> 'OUT' ) AND
      ( @Trailer in ( 'UNKNOWN' , trl_number, trl_ilt_scac + ',' + trl_number ) ) AND
      ( @Company in ( 'UNK' , trl_company ) ) AND
      ( @Fleet in ( 'UNK' , trl_fleet ) ) AND
      ( @Division in ( 'UNK' , trl_division ) ) AND
      ( @Terminal in ( 'UNK' , trl_terminal ) ) AND
      ( @TrlType1 in ( 'UNK' , trl_type1 ) ) AND
      ( @TrlType2 in ( 'UNK' , trl_type2 ) ) AND
      ( @TrlType3 in ( 'UNK' , trl_type3 ) ) AND
      ( @TrlType4 in ( 'UNK' , trl_type4 ) ) AND
      ( trl_actg_type in ( @AcctType1 , @AcctType2 ) )   AND
      --PTS 38816 JJF 20080312 add additional needed parms
      --PTS 51570 JJF 20100510
      --dbo.RowRestrictByUser (trl_terminal, '', '', '') = 1   AND -- 11/29/2007 MDH PTS 40119: Added
      dbo.RowRestrictByUser ('trailerprofile', trailerprofile.rowsec_rsrv_id, '', '', '') = 1   AND -- 11/29/2007 MDH PTS 40119: Added
      ( NOT EXISTS ( SELECT *
            FROM payheader
            WHERE asgn_type = 'TRL' AND
               asgn_id = trailerprofile.trl_id AND
               pyh_payperiod = @paydate AND
               pyh_paystatus <> 'PND' )
      --BEGIN PTS 70279 SPN
      OR EXISTS ( SELECT 1
                    FROM payheader
                   WHERE asgn_type = 'TRL'
                     AND asgn_id = trailerprofile.trl_id
                     AND pyh_payperiod = @paydate
                     AND pyh_paystatus = 'PND'
                )
      --END PTS 70279 SPN
      )
      --BEGIN PTS 65645 SPN
      AND (@trl_branch = 'UNKNOWN' OR @trl_branch = trailerprofile.trl_branch)
      --END PTS 65645 SPN
end

/* GENERATE ASSET LISTS FOR CARRIER */
if (@carrier_yes > 0)
begin
   insert into #temp
   SELECT   -1,
      'CAR',
      car_id,
      '-' ,
      @HiPayDate,
      0.0000,
      0.0000,
      0.0000,
      car_branch,  -- PTS 41389 GAP 74
      0.0000, -- pts 54303
      0.0000,  -- pts 54303
      'UNKNOWN'
   FROM carrier
   WHERE ( car_status <> 'OUT' OR car_terminationdt > dateadd ( day, @daysout, @HiPayDate ) or @daysout=999) AND --vjh 46278
      ( @Carrier in ('UNKNOWN', car_id ) ) AND
      ( @CarType1 in ( 'UNK' , car_type1 ) ) AND
      ( @CarType2 in ( 'UNK' , car_type2 ) ) AND
      ( @CarType3 in ( 'UNK' , car_type3 ) ) AND
      ( @CarType4 in ( 'UNK' , car_type4 ) ) AND
      ( car_actg_type in ( @AcctType1 , @AcctType2 ) ) AND
      ( NOT EXISTS ( SELECT *
            FROM payheader
            WHERE asgn_type = 'CAR' AND
               asgn_id = carrier.car_id AND
               pyh_payperiod = @paydate AND
               pyh_paystatus <> 'PND' )
      --BEGIN PTS 70279 SPN
      OR EXISTS ( SELECT 1
                    FROM payheader
                   WHERE asgn_type = 'CAR'
                     AND asgn_id = carrier.car_id
                     AND pyh_payperiod = @paydate
                     AND pyh_paystatus = 'PND'
                )
      --END PTS 70279 SPN
      )
      --BEGIN PTS 65645 SPN
      AND (@car_branch = 'UNKNOWN' OR @car_branch = carrier.car_branch)
      --END PTS 65645 SPN
end

if (@tpr_yes > 0)
begin
   insert into #temp
   SELECT   999,
      'TPR',
      tpr_id,
      '-' ,
      @HiPayDate,
      0.0000,
      0.0000,
      0.0000,
      tpr_branch,  -- PTS 41389 GAP 74
      0.0000, -- pts 54303
      0.0000,  -- pts 54303
      tpr_payto
   FROM thirdpartyprofile
   WHERE ( tpr_active = 'Y' ) AND
      ( @tpr_id in ( 'UNKNOWN' , tpr_id ) ) AND
      ( @tpr_type in ( 'UNKNOWN' , tpr_type ) ) AND
      ( tpr_actg_type in ( @AcctType1 , @AcctType2 ) ) AND
      ( @tpr_revtype1 in ('UNK', tpr_revtype1 ) ) AND
      ( @tpr_revtype2 in ('UNK', tpr_revtype2 ) ) AND
      ( @tpr_revtype3 in ('UNK', tpr_revtype3 ) ) AND
      ( @tpr_revtype4 in ('UNK', tpr_revtype4 ) ) AND
      ( NOT EXISTS ( SELECT *
            FROM payheader
            WHERE asgn_type = 'TPR' AND
               asgn_id = thirdpartyprofile.tpr_id AND
               pyh_payperiod = @paydate AND
               pyh_paystatus <> 'PND' )
      --BEGIN PTS 70279 SPN
      OR EXISTS ( SELECT 1
                    FROM payheader
                   WHERE asgn_type = 'TPR'
                     AND asgn_id = thirdpartyprofile.tpr_id
                     AND pyh_payperiod = @paydate
                     AND pyh_paystatus = 'PND'
                )
      --END PTS 70279 SPN
      )
end


-- /* UPDATE RECORDS WITH PAYDETAILS BUT NO PAYHEADER */
-- update #temp
-- SET pyh_totalcomp =  ( SELECT sum ( paydetail.pyd_amount )
--          FROM paydetail
--          WHERE ( paydetail.asgn_type =* #temp.asgn_type ) AND
--             ( paydetail.asgn_id =* #temp.asgn_id ) AND
--             (paydetail.pyh_payperiod = @paydate) AND
--             ( paydetail.pyd_pretax = 'Y' ) AND
--             (paydetail.pyd_status=  @Status )),
--     pyh_totaldeduct = ( SELECT sum ( paydetail.pyd_amount )
--          FROM paydetail
--          WHERE ( paydetail.asgn_type =* #temp.asgn_type ) AND
--             ( paydetail.asgn_id =* #temp.asgn_id ) AND
--             (paydetail.pyh_payperiod = @paydate) AND
--             ( paydetail.pyd_pretax = 'N' ) AND
--             ( paydetail.pyd_minus = -1 ) AND
--             ( paydetail.pyd_status=  @Status )),
--     pyh_totalreimbrs = ( SELECT sum ( paydetail.pyd_amount )
--          FROM paydetail
--          WHERE  ( paydetail.asgn_type =* #temp.asgn_type ) AND
--             ( paydetail.asgn_id =* #temp.asgn_id ) AND
--             (paydetail.pyh_payperiod = @paydate) AND
--             ( paydetail.pyd_pretax = 'N' ) AND
--             ( paydetail.pyd_minus = 1 ) AND
--             ( paydetail.pyd_status=  @Status ))

-- SQL standards

-- LOR   PTS# 48398  added sch
If @sch = 1
begin
   update a
   SET pyh_totalcomp =  ( SELECT sum ( paydetail.pyd_amount )
            FROM paydetail right outer join #temp
            on paydetail.asgn_type = #temp.asgn_type and
               paydetail.asgn_id = #temp.asgn_id
-- 56142 DSK -- need to include paydetail that is release for 12/31/49
--          WHERE a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate) AND
            WHERE    a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate OR (paydetail.pyh_payperiod >= '2049-12-31' AND paydetail.pyd_status = 'PND')) AND
               ( paydetail.pyd_pretax = 'Y' ) AND
               (paydetail.pyd_status=  @Status )),
      pyh_totaldeduct = ( SELECT sum ( paydetail.pyd_amount )
            FROM paydetail
            right outer join #temp
            on paydetail.asgn_type = #temp.asgn_type and
               paydetail.asgn_id = #temp.asgn_id
-- 56142 DSK -- need to include paydetail that is release for 12/31/49
--          WHERE a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate) AND
            WHERE    a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate OR (paydetail.pyh_payperiod >= '2049-12-31' AND paydetail.pyd_status = 'PND')) AND
               ( paydetail.pyd_pretax = 'N' ) AND
               ( paydetail.pyd_minus = -1 ) AND
               ( paydetail.pyd_status=  @Status )),
      pyh_totalreimbrs = ( SELECT sum ( paydetail.pyd_amount )
            FROM paydetail
            right outer join #temp
            on paydetail.asgn_type = #temp.asgn_type and
               paydetail.asgn_id = #temp.asgn_id
-- 56142 DSK -- need to include paydetail that is release for 12/31/49
--          WHERE a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate) AND
            WHERE a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate OR (paydetail.pyh_payperiod >= '2049-12-31' AND paydetail.pyd_status = 'PND')) AND
               ( paydetail.pyd_pretax = 'N' ) AND
               ( paydetail.pyd_minus = 1 ) AND
               ( paydetail.pyd_status=  @Status )),
   -- pts 54303 <<start>>
      pyh_totalcomp_positive =  ( SELECT sum ( paydetail.pyd_amount )
            FROM paydetail right outer join #temp
            on paydetail.asgn_type = #temp.asgn_type and
               paydetail.asgn_id = #temp.asgn_id
-- 56142 DSK -- need to include paydetail that is release for 12/31/49
--          WHERE a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate) AND
            WHERE    a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate OR (paydetail.pyh_payperiod >= '2049-12-31' AND paydetail.pyd_status = 'PND')) AND
               ( paydetail.pyd_pretax = 'Y' ) AND
               ( paydetail.pyd_minus = 1 ) AND
               (paydetail.pyd_status=  @Status )),
      pyh_totalcomp_negative  =   ( SELECT sum ( paydetail.pyd_amount )
            FROM paydetail right outer join #temp
            on paydetail.asgn_type = #temp.asgn_type and
               paydetail.asgn_id = #temp.asgn_id
-- 56142 DSK -- need to include paydetail that is release for 12/31/49
--          WHERE a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate) AND
            WHERE    a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate OR (paydetail.pyh_payperiod >= '2049-12-31' AND paydetail.pyd_status = 'PND')) AND
               ( paydetail.pyd_pretax = 'Y' ) AND
               ( paydetail.pyd_minus = -1 ) AND
               (paydetail.pyd_status=  @Status ))
   -- pts 54303  <<end>>
   From #temp a
end

Else
begin
   update a
   SET pyh_totalcomp =  ( SELECT sum ( paydetail.pyd_amount )
                     FROM paydetail
                        right outer join #temp on paydetail.asgn_type = #temp.asgn_type and
                        paydetail.asgn_id = #temp.asgn_id
                     WHERE a.asgn_type = #temp.asgn_type and
                           a.asgn_id = #temp.asgn_id and
                           (paydetail.pyh_payperiod = @paydate or
                              paydetail.pyh_payperiod = CONVERT(DATETIME,CONVERT(CHAR(10),'12/31/49',101)) or
                              paydetail.pyh_payperiod = dateadd(minute, 59, dateadd ( hour, 23, '12/31/49' ))) AND
                           ( paydetail.pyd_pretax = 'Y' ) AND
                           (paydetail.pyd_status=  @Status )),
      pyh_totaldeduct = ( SELECT sum ( paydetail.pyd_amount )
                     FROM paydetail
                        right outer join #temp on paydetail.asgn_type = #temp.asgn_type and
                        paydetail.asgn_id = #temp.asgn_id
                     WHERE    a.asgn_type = #temp.asgn_type and
                        a.asgn_id = #temp.asgn_id and
                        (paydetail.pyh_payperiod = @paydate or
                              paydetail.pyh_payperiod = CONVERT(DATETIME,CONVERT(CHAR(10),'12/31/49',101)) or
                              paydetail.pyh_payperiod = dateadd(minute, 59, dateadd ( hour, 23, '12/31/49' ))) AND
                        ( paydetail.pyd_pretax = 'N' ) AND
                        ( paydetail.pyd_minus = -1 ) AND
                        ( paydetail.pyd_status=  @Status )),
      pyh_totalreimbrs = ( SELECT sum ( paydetail.pyd_amount )
                     FROM paydetail
                        right outer join #temp on paydetail.asgn_type = #temp.asgn_type and
                        paydetail.asgn_id = #temp.asgn_id
                     WHERE a.asgn_type = #temp.asgn_type and
                        a.asgn_id = #temp.asgn_id and
                        (paydetail.pyh_payperiod = @paydate or
                              paydetail.pyh_payperiod = CONVERT(DATETIME,CONVERT(CHAR(10),'12/31/49',101)) or
                              paydetail.pyh_payperiod = dateadd(minute, 59, dateadd ( hour, 23, '12/31/49' ))) AND
                        ( paydetail.pyd_pretax = 'N' ) AND
                        ( paydetail.pyd_minus = 1 ) AND
                        ( paydetail.pyd_status=  @Status )),
   -- pts 54303 <<start>>
      pyh_totalcomp_positive =   ( SELECT sum ( paydetail.pyd_amount )
                     FROM paydetail
                        right outer join #temp on paydetail.asgn_type = #temp.asgn_type and
                        paydetail.asgn_id = #temp.asgn_id
                     WHERE a.asgn_type = #temp.asgn_type and
                           a.asgn_id = #temp.asgn_id and
                           (paydetail.pyh_payperiod = @paydate or
                              paydetail.pyh_payperiod = CONVERT(DATETIME,CONVERT(CHAR(10),'12/31/49',101)) or
                              paydetail.pyh_payperiod = dateadd(minute, 59, dateadd ( hour, 23, '12/31/49' ))) AND
                           ( paydetail.pyd_pretax = 'Y' ) AND
                           ( paydetail.pyd_minus = 1 ) AND
                           (paydetail.pyd_status=  @Status )),

      pyh_totalcomp_negative  =  ( SELECT sum ( paydetail.pyd_amount )
                     FROM paydetail
                        right outer join #temp on paydetail.asgn_type = #temp.asgn_type and
                        paydetail.asgn_id = #temp.asgn_id
                     WHERE a.asgn_type = #temp.asgn_type and
                           a.asgn_id = #temp.asgn_id and
                           (paydetail.pyh_payperiod = @paydate or
                              paydetail.pyh_payperiod = CONVERT(DATETIME,CONVERT(CHAR(10),'12/31/49',101)) or
                              paydetail.pyh_payperiod = dateadd(minute, 59, dateadd ( hour, 23, '12/31/49' ))) AND
                           ( paydetail.pyd_pretax = 'Y' ) AND
                           ( paydetail.pyd_minus = -1 ) AND
                           (paydetail.pyd_status=  @Status ))
   -- pts 54303 <<end>>
   From #temp a
end

-- PTS 54303 <<start>>
IF @process_netpayzero = 'N'
begin
   update #temp
set pyh_totalcomp_positive = NULL,
   pyh_totalcomp_negative = NULL
end
-- PTS 54303 <<end>>

-- -- PTS 41389 GAP 74 (start)
If exists (select * from generalinfo where gi_name = 'TrackBranch' and gi_string1 = 'Y')
BEGIN
      -- IF SPECIFIC THEN PULL THAT - IF UNKNOWN THEN PULL THE ONES ALLOWED FOR THE USER.

      IF @brn_id  = ',UNKNOWN,'
         begin
            If exists (select * from generalinfo where gi_name = 'BRANCHUSERSECURITY' and gi_string1 = 'Y')
            BEGIN
               -- if branch security is ON then get data, else, DO NOT DELETE.
               SELECT brn_id
               INTO #temp_user_branch
               FROM branch_assignedtype
               WHERE bat_type = 'USERID'
               and brn_id <> 'UNKNOWN'
               AND bat_value  =  @G_USERID

               DELETE from #temp where branch NOT IN (select brn_id from #temp_user_branch)
            END
         end
       ELSE
         begin
            Delete from #temp
            where branch in (select branch from #temp
                                   where CHARINDEX(',' + branch + ',', @brn_id) = 0 )
         end

END
 -- PTS 41389 GAP 74 (end)
 --original code



/* FINAL SELECT TO RETRIEVE RETUEN SET */
select * from #temp

end

return



GO
GRANT EXECUTE ON  [dbo].[d_pay_scroll_payfors_sp] TO [public]
GO
