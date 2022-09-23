SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [dbo].[d_pay_scroll_payfors_forviews_sp]    (
               @Status varchar(6),
               @LoPayDate datetime,
               @HiPayDate datetime,
               @sch  int,
               @view_id varchar(6)
)  AS

/**
 *
 * NAME:
 * dbo.d_pay_scroll_payfors_forviews_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for the settlement queues.
 *
 * RETURNS:
 *
 * LOR   PTS# 58375  views
 * SPN   PTS# 63448  fixing trailer parm issue
 * 06/24/2012 PTS 70279 SPN - Asset should appear in the queue when headers reopened (PND)
 */

declare @drvyes varchar(3),
   @trcyes varchar(3),
   @caryes varchar(3),
   @trlyes varchar(3),
   @tpryes varchar(3),
   @company varchar(255),
   @fleet varchar(255),
   @division varchar(255), --10
   @terminal varchar(255),
   @DrvType1 varchar(255),
   @DrvType2 varchar(255),
   @DrvType3 varchar(255),
   @DrvType4 varchar(255),    --15
   @trctype1 varchar(255),
   @trctype2 varchar(255),
   @trctype3 varchar(255),
   @trctype4 varchar(255),
   @driver varchar(255),      --20
   @tractor varchar(255),
   @acct_typ char(1),
   @carrier varchar(255),
   @cartype1 varchar(255),
   @cartype2 varchar(255),    --25
   @cartype3 varchar(255),
   @cartype4 varchar(255),
   @trailer varchar(255),
   @trltype1 varchar(255), --30
   @trltype2 varchar(255),
   @trltype3 varchar(255),
   @trltype4 varchar(255),
   @tpr_id varchar(255),
   @tpr_type varchar(255)
-- ,@view_type varchar(6)

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

--BEGIN PTS 63020 SPN - Unused restrictions
DECLARE @p_ivh_billto         VARCHAR(255)
DECLARE @lgh_booked_revtype1  VARCHAR(255)
DECLARE @p_revtype1           VARCHAR(255)
DECLARE @p_revtype2           VARCHAR(255)
DECLARE @p_revtype3           VARCHAR(255)
DECLARE @p_revtype4           VARCHAR(255)
DECLARE @p_lgh_type1          VARCHAR(255)
DECLARE @paperwork_received   INT
DECLARE @inv_status           VARCHAR(255)
DECLARE @bov_ivh_rev_type1    VARCHAR(255)
--END PTS 63020 SPN

--BEGIN PTS 65645 SPN
DECLARE @mpp_branch    VARCHAR(255)
DECLARE @trc_branch    VARCHAR(255)
DECLARE @trl_branch    VARCHAR(255)
DECLARE @car_branch    VARCHAR(255)
--END PTS 65645 SPN

select @coownerpaytos = left(upper(gi_string1),1) from generalinfo where gi_name = 'coownerpaytos'
if @coownerpaytos is null select @coownerpaytos = 'N'

SELECT @daysout = -60

select @process_netpayzero = 'N'
If exists (select * from generalinfo where gi_name = 'CollectQ_NetPayZero' and gi_string1 = 'Y')
   begin
      select @process_netpayzero = 'Y'
   end

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

SELECT @paydate = CONVERT(DATETIME,CONVERT(CHAR(10),@HiPayDate,101))

--BEGIN PTS 63020 SPN
--select @company = case isNull(rtrim(bov_company), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_company + ',')
--                   end,
-- @fleet = case isNull(rtrim(bov_fleet), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_fleet + ',')
--                   end,
-- @division = case isNull(rtrim(bov_division), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_division + ',')
--                   end,
-- @terminal = case isNull(rtrim(bov_terminal), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_terminal + ',')
--                   end,
-- @acct_typ = IsNull(bov_acct_type, 'X'),      -- A/P/X
-- @drvyes = case isNull(bov_driver_incl, 'N')
--                      when 'N' then 'XXX'
--                      else 'DRV'
--                   end,
-- @driver = case isNull(rtrim(bov_driver_id), '')
--                      when '' then '%'
--                      when 'UNKNOWN' then '%'
--                      else (',' + bov_driver_id + ',')
--                   end,
-- @drvtype1 = case isNull(rtrim(bov_mpp_type1), '')
--                      when '' then '%'
--                      else (',' + bov_mpp_type1 + ',')
--                   end ,
-- @drvtype2 = case isNull(rtrim(bov_mpp_type2), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_mpp_type2 + ',')
--                   end ,
-- @drvtype3 = case isNull(rtrim(bov_mpp_type3), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_mpp_type3 + ',')
--                   end ,
-- @drvtype4 = case isNull(rtrim(bov_mpp_type4), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_mpp_type4 + ',')
--                   end ,
-- @trcyes = case isNull(bov_tractor_incl, 'N')
--                      when 'N' then 'XXX'
--                      else 'TRC'
--                   end,
-- @tractor = case isNull(rtrim(bov_tractor_id), '')
--                      when '' then '%'
--                      when 'UNKNOWN' then '%'
--                      else (',' + bov_tractor_id + ',')
--                   end,
-- @trctype1 = case isNull(rtrim(bov_trc_type1), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trc_type1 + ',')
--                   end ,
-- @trctype2 = case isNull(rtrim(bov_trc_type2), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trc_type2 + ',')
--                   end ,
-- @trctype3 = case isNull(rtrim(bov_trc_type3), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trc_type3 + ',')
--                   end ,
-- @trctype4 = case isNull(rtrim(bov_trc_type4), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trc_type4 + ',')
--                   end ,
-- @trlyes = case isNull(bov_trailer_incl, 'N')
--                      when 'N' then 'XXX'
--                      else 'TRL'
--                   end,
-- @trailer = case isNull(rtrim(bov_trailer_id), '')
--                      when '' then '%'
--                      when 'UNKNOWN' then '%'
--                      else (',' + bov_trailer_id + ',')
--                   end,
-- @trltype1 = case isNull(rtrim(bov_trl_type1), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trl_type1 + ',')
--                   end ,
-- @trltype2 = case isNull(rtrim(bov_trl_type2), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trl_type2 + ',')
--                   end ,
-- @trltype3 = case isNull(rtrim(bov_trl_type3), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trl_type3 + ',')
--                   end ,
-- @trltype4 = case isNull(rtrim(bov_trl_type4), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trl_type4 + ',')
--                   end ,
-- @caryes = case isNull(bov_carrier_incl, 'N')
--                      when 'N' then 'XXX'
--                      else 'CAR'
--                   end,
-- @carrier = case isNull(rtrim(bov_carrier_id), '')
--                      when '' then '%'
--                      when 'UNKNOWN' then '%'
--                      else (',' + bov_carrier_id + ',')
--                   end,
-- @cartype1 = case isNull(rtrim(bov_car_type1), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_car_type1 + ',')
--                   end ,
-- @cartype2 = case isNull(rtrim(bov_car_type2), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_car_type2 + ',')
--                   end ,
-- @cartype3 = case isNull(rtrim(bov_car_type3), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_car_type3 + ',')
--                   end ,
-- @cartype4 = case isNull(rtrim(bov_car_type4), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_car_type4 + ',')
--                   end ,
-- @tpryes = case isNull(bov_tpr_incl, 'N')
--                      when 'N' then 'XXX'
--                      else 'TPR'
--                   end,
-- @tpr_id = case isNull(rtrim(bov_tpr_id), '')
--                      when '' then '%'
--                      when 'UNKNOWN' then '%'
--                      else (',' + bov_tpr_id + ',')
--                   end,
-- @tpr_type = case isNull(rtrim(bov_tpr_type), '')
--                      when '' then '%'
--                      when 'UNKNOWN' then '%'
--                      else (',' + bov_tpr_type + ',')
--                   end
-- from backofficeview
-- where bov_id = @view_id and bov_type = 'COS'
   --PTS 65645 SPN - added @mpp_branch, @trc_branch, @trl_branch and @car_branch
   EXEC dbo.backofficeview_get_sp
                         @bov_type               = 'COS'
                       , @bov_id                 = @view_id
                       , @bov_billto             = @p_ivh_billto        OUTPUT
                       , @bov_acct_type          = @acct_typ            OUTPUT
                       , @bov_booked_revtype1    = @lgh_booked_revtype1 OUTPUT
                       , @bov_rev_type1          = @p_revtype1          OUTPUT
                       , @bov_rev_type2          = @p_revtype2          OUTPUT
                       , @bov_rev_type3          = @p_revtype3          OUTPUT
                       , @bov_rev_type4          = @p_revtype4          OUTPUT
                       , @bov_lgh_type1          = @p_lgh_type1         OUTPUT
                       , @bov_company            = @company             OUTPUT
                       , @bov_fleet              = @fleet               OUTPUT
                       , @bov_division           = @division            OUTPUT
                       , @bov_terminal           = @terminal            OUTPUT
                       , @bov_paperwork_received = @paperwork_received  OUTPUT
                       , @bov_driver_incl        = @drvyes              OUTPUT
                       , @bov_driver_id          = @driver              OUTPUT
                       , @bov_mpp_type1          = @drvtype1            OUTPUT
                       , @bov_mpp_type2          = @drvtype2            OUTPUT
                       , @bov_mpp_type3          = @drvtype3            OUTPUT
                       , @bov_mpp_type4          = @drvtype4            OUTPUT
                       , @bov_mpp_branch         = @mpp_branch          OUTPUT
                       , @bov_tractor_incl       = @trcyes              OUTPUT
                       , @bov_tractor_id         = @tractor             OUTPUT
                       , @bov_trc_type1          = @trctype1            OUTPUT
                       , @bov_trc_type2          = @trctype2            OUTPUT
                       , @bov_trc_type3          = @trctype3            OUTPUT
                       , @bov_trc_type4          = @trctype4            OUTPUT
                       , @bov_trc_branch         = @trc_branch          OUTPUT
                       , @bov_trailer_incl       = @trlyes              OUTPUT
                       , @bov_trailer_id         = @trailer             OUTPUT
                       , @bov_trl_type1          = @trltype1            OUTPUT
                       , @bov_trl_type2          = @trltype2            OUTPUT
                       , @bov_trl_type3          = @trltype3            OUTPUT
                       , @bov_trl_type4          = @trltype4            OUTPUT
                       , @bov_trl_branch         = @trl_branch          OUTPUT
                       , @bov_carrier_incl       = @caryes              OUTPUT
                       , @bov_carrier_id         = @carrier             OUTPUT
                       , @bov_car_type1          = @cartype1            OUTPUT
                       , @bov_car_type2          = @cartype2            OUTPUT
                       , @bov_car_type3          = @cartype3            OUTPUT
                       , @bov_car_type4          = @cartype4            OUTPUT
                       , @bov_car_branch         = @car_branch          OUTPUT
                       , @bov_tpr_incl           = @tpryes              OUTPUT
                       , @bov_tpr_id             = @tpr_id              OUTPUT
                       , @bov_tpr_type           = @tpr_type            OUTPUT
                       , @bov_inv_status         = @inv_status          OUTPUT
                       , @bov_ivh_rev_type1      = @bov_ivh_rev_type1   OUTPUT

--END PTS 63020 SPN

/* SET ACCOUNT TYPES */
-- ((@acct_typ = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_typ = pd.pyd_prorap))
-- ( mpp_actg_type in ( @AcctType1 , @AcctType2 ) )
-- ( (@acct_typ = 'X' AND a.actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
--if @account_type = 'X'
-- SELECT @AcctType1 = 'A'
-- SELECT @AcctType2 = 'P'
-- end
--else if @account_type = 'A'
-- begin
-- SELECT @AcctType1 = 'A'
-- SELECT @AcctType2 = 'A'
-- end
--else if @account_type = 'P'
-- begin
-- SELECT @AcctType1 = 'P'
-- SELECT @AcctType2 = 'P'
-- end
--else
-- begin /* treat 'none' as invalid */
-- SELECT @AcctType1 = '.'
-- SELECT @AcctType2 = '.'
-- end

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

--select @drivers_yes = charindex('DRV', @Types)
--select @tractors_yes = charindex('TRC', @Types)
--select @trailer_yes = charindex('TRL', @Types)
--select @carrier_yes = charindex('CAR', @Types)
--select @tpr_yes = charindex('TPR', @Types)

--IF (@drivers_yes = 0) AND (@tractors_yes = 0) AND (@trailer_yes = 0) AND (@carrier_yes = 0) AND (@tpr_yes = 0)
-- begin
-- SELECT * FROM #temp
-- return
-- end

/* GENERATE ASSET LISTS FOR DRIVER */
--if (@drivers_yes > 0)
IF @drvyes <> 'XXX'
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
      --( @Driver in ( 'UNKNOWN' , mpp_id ) ) AND
      --( @Company in ( 'UNK' , mpp_company ) ) AND
      --( @Fleet in ( 'UNK' , mpp_fleet ) ) AND
      --( @Division in ( 'UNK' , mpp_division ) ) AND
      --( @Terminal in ( 'UNK' , mpp_terminal ) ) AND
      --( @DrvType1 in ( 'UNK' , mpp_type1 ) ) AND
      --( @DrvType2 in ( 'UNK' , mpp_type2 ) ) AND
      --( @DrvType3 in ( 'UNK' , mpp_type3 ) ) AND
      --( @DrvType4 in ( 'UNK' , mpp_type4 ) ) AND
      --( mpp_actg_type in ( @AcctType1 , @AcctType2 ) ) AND
        (@driver = mpp_id OR @driver = 'UNKNOWN' or @driver = '%' or CHARINDEX( ',' + mpp_id + ',',@driver) > 0)
         AND ( (@acct_typ = 'X' AND mpp_actg_type IN('A', 'P')) OR (@acct_typ = mpp_actg_type) )
         AND (@company = 'UNK' or @company = mpp_company or @company = '%' or CHARINDEX( ',' + mpp_company + ',',@company) > 0)
         AND (@fleet = 'UNK' or @fleet = mpp_fleet or @fleet = '%' or CHARINDEX( ',' + mpp_fleet + ',',@fleet) > 0)
         AND (@division = 'UNK' or @division = mpp_division or @division = '%' or CHARINDEX( ',' + mpp_division + ',',@division) > 0)
         AND (@terminal = 'UNK' or @terminal = mpp_terminal or @terminal = '%' or CHARINDEX( ',' + mpp_terminal + ',',@terminal) > 0)
         and ( @DrvType1 = 'UNK' or @DrvType1 =  mpp_type1 or @DrvType1 = '%' or CHARINDEX( ',' + mpp_type1 + ',',@DrvType1) > 0)
         and ( @DrvType2 = 'UNK' or @DrvType2 =  mpp_type2 or @DrvType2 = '%' or CHARINDEX( ',' + mpp_type2 + ',',@DrvType2) > 0)
         and ( @DrvType3 = 'UNK' or @DrvType3 =  mpp_type3 or @DrvType3 = '%' or CHARINDEX( ',' + mpp_type3 + ',',@DrvType3) > 0)
         and ( @DrvType4 = 'UNK' or @DrvType4 =  mpp_type4 or @DrvType4 = '%' or CHARINDEX( ',' + mpp_type4 + ',',@DrvType4) > 0)
      and dbo.RowRestrictByUser ('manpowerprofile', manpowerprofile.rowsec_rsrv_id, '', '', '') = 1
      and ( NOT EXISTS ( SELECT *
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
      AND (@mpp_branch = '%' OR CHARINDEX( ',' + IsNull(manpowerprofile.mpp_branch,'UNKNOWN') + ',', @mpp_branch) > 0)
      --END PTS 65645 SPN
end

--select @driver, @DrvType1
--select * from #temp

/* GENERATE ASSET LISTS FOR TRACTOR */
--if (@tractors_yes > 0)
IF @trcyes <> 'XXX'
begin
   --if @coownerpaytos = 'N'  --vjh 54402 coowners
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
         --( @Company in ( 'UNK' , trc_company ) ) AND
         --( @Fleet in ( 'UNK' , trc_fleet ) ) AND
         --( @Division in ( 'UNK' , trc_division ) ) AND
         --( @Terminal in ( 'UNK' , trc_terminal ) ) AND
         --( @TrcType1 in ( 'UNK' , trc_type1 ) ) AND
         --( @TrcType2 in ( 'UNK' , trc_type2 ) ) AND
         --( @TrcType3 in ( 'UNK' , trc_type3 ) ) AND
         --( @TrcType4 in ( 'UNK' , trc_type4 ) ) AND
         --( trc_actg_type in ( @AcctType1 , @AcctType2 ) )  AND
         (@Tractor = trc_number OR @Tractor = 'UNKNOWN' or @Tractor = '%' or CHARINDEX( ',' + trc_number + ',',@Tractor) > 0)
         AND ( (@acct_typ = 'X' AND trc_actg_type IN('A', 'P')) OR (@acct_typ = trc_actg_type) )
         AND (@company = 'UNK' or @company = trc_company or @company = '%' or CHARINDEX( ',' + trc_company + ',',@company) > 0)
         AND (@fleet = 'UNK' or @fleet = trc_fleet or @fleet = '%' or CHARINDEX( ',' + trc_fleet + ',',@fleet) > 0)
         AND (@division = 'UNK' or @division = trc_division or @division = '%' or CHARINDEX( ',' + trc_division + ',',@division) > 0)
         AND (@terminal = 'UNK' or @terminal = trc_terminal or @terminal = '%' or CHARINDEX( ',' + trc_terminal + ',',@terminal) > 0)
         and ( @TrcType1 = 'UNK' or @TrcType1 =  trc_type1 or @TrcType1 = '%' or CHARINDEX( ',' + trc_type1 + ',',@TrcType1) > 0)
         and ( @TrcType2 = 'UNK' or @TrcType2 =  trc_type2 or @TrcType2 = '%' or CHARINDEX( ',' + trc_type2 + ',',@TrcType2) > 0)
         and ( @TrcType3 = 'UNK' or @TrcType3 =  trc_type3 or @TrcType3 = '%' or CHARINDEX( ',' + trc_type3 + ',',@TrcType3) > 0)
         and ( @TrcType4 = 'UNK' or @TrcType4 =  trc_type4 or @TrcType4 = '%' or CHARINDEX( ',' + trc_type4 + ',',@TrcType4) > 0) and
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
         AND (@trc_branch = '%' OR CHARINDEX( ',' + IsNull(tractorprofile.trc_branch,'UNKNOWN') + ',', @trc_branch) > 0)
         --END PTS 65645 SPN
   --else begin --@coowners = 'Y'
   -- if @payto <> 'UNKNOWN' begin
   --    select @tractor = MIN(trc_number) from tractorprofile where (trc_owner = @payto or trc_owner2 = @payto)
   --    insert into #temp
   --    SELECT   -1,
   --       'TRC',
   --       trc_number,
   --       '-' ,
   --       @HiPayDate,
   --       0.0000,
   --       0.0000,
   --       0.0000,
   --       trc_branch, -- PTS 41389 GAP 74
   --       0.0000, -- pts 54303
   --       0.0000,  -- pts 54303
   --       @payto
   --    FROM tractorprofile
   --    WHERE ( trc_status <> 'OUT' OR trc_retiredate > dateadd ( day, @daysout, @HiPayDate ) or @daysout=999) AND --vjh 46278
   --       --( @Tractor in ( 'UNKNOWN' , trc_number ) ) AND
   --       ( @payto in ( 'UNKNOWN' , trc_owner ) OR @payto in ( 'UNKNOWN' , trc_owner2 ) ) AND
   --       ( @Company in ( 'UNK' , trc_company ) ) AND
   --       ( @Fleet in ( 'UNK' , trc_fleet ) ) AND
   --       ( @Division in ( 'UNK' , trc_division ) ) AND
   --       ( @Terminal in ( 'UNK' , trc_terminal ) ) AND
   --       ( @TrcType1 in ( 'UNK' , trc_type1 ) ) AND
   --       ( @TrcType2 in ( 'UNK' , trc_type2 ) ) AND
   --       ( @TrcType3 in ( 'UNK' , trc_type3 ) ) AND
   --       ( @TrcType4 in ( 'UNK' , trc_type4 ) ) AND
   --       ( trc_actg_type in ( @AcctType1 , @AcctType2 ) )  AND
 --            dbo.RowRestrictByUser ('tractorprofile', tractorprofile.rowsec_rsrv_id, '', '', '') = 1   AND
   --       ( NOT EXISTS ( SELECT *
   --                FROM payheader
   --                WHERE asgn_type = 'TRC' AND
   --                   asgn_id = tractorprofile.trc_number AND
   --                   pyh_payperiod = @paydate AND
   --                   pyh_paystatus <> 'PND'
   --                   AND pyh_payto = @payto ) )
   -- end else begin
   --    --use trc_owner (coowner1)
   --    insert into #temp
   --    SELECT   -1,
   --       'TRC',
   --       trc_number,
   --       '-' ,
   --       @HiPayDate,
   --       0.0000,
   --       0.0000,
   --       0.0000,
   --       trc_branch, -- PTS 41389 GAP 74
   --       0.0000, -- pts 54303
   --       0.0000,  -- pts 54303
   --       trc_owner
   --    FROM tractorprofile
   --    WHERE ( trc_status <> 'OUT' OR trc_retiredate > dateadd ( day, @daysout, @HiPayDate ) or @daysout=999) AND --vjh 46278
   --       --( @Tractor in ( 'UNKNOWN' , trc_number ) ) AND
   --       ( @payto in ( 'UNKNOWN' , trc_owner ) ) AND
   --       ( @Company in ( 'UNK' , trc_company ) ) AND
   --       ( @Fleet in ( 'UNK' , trc_fleet ) ) AND
   --       ( @Division in ( 'UNK' , trc_division ) ) AND
   --       ( @Terminal in ( 'UNK' , trc_terminal ) ) AND
   --       ( @TrcType1 in ( 'UNK' , trc_type1 ) ) AND
   --       ( @TrcType2 in ( 'UNK' , trc_type2 ) ) AND
   --       ( @TrcType3 in ( 'UNK' , trc_type3 ) ) AND
   --       ( @TrcType4 in ( 'UNK' , trc_type4 ) ) AND
   --       ( trc_actg_type in ( @AcctType1 , @AcctType2 ) )  AND
 --            dbo.RowRestrictByUser ('tractorprofile', tractorprofile.rowsec_rsrv_id, '', '', '') = 1   AND
   --       ( NOT EXISTS ( SELECT *
   --                   FROM payheader
   --                   WHERE asgn_type = 'TRC' AND
   --                      asgn_id = tractorprofile.trc_number AND
   --                      pyh_payperiod = @paydate AND
   --                      pyh_paystatus <> 'PND'
   --                      AND pyh_payto = trc_owner ) ) AND ( trc_owner <> 'UNKNOWN' )
   --    --use trc_owner2 (coowner2)
   --    insert into #temp
   --    SELECT   -1,
   --       'TRC',
   --       trc_number,
   --       '-' ,
   --       @HiPayDate,
   --       0.0000,
   --       0.0000,
   --       0.0000,
   --       trc_branch, -- PTS 41389 GAP 74
   --       0.0000, -- pts 54303
   --       0.0000,  -- pts 54303
   --       trc_owner2
   --    FROM tractorprofile
   --    WHERE ( trc_status <> 'OUT' OR trc_retiredate > dateadd ( day, @daysout, @HiPayDate ) or @daysout=999) AND --vjh 46278
   --       --( @Tractor in ( 'UNKNOWN' , trc_number ) ) AND
   --       ( @payto in ( 'UNKNOWN' , trc_owner2 ) ) AND
   --       ( trc_owner2 <> 'UNKNOWN' ) AND  --vjh 54402 do not add duplicates for an UNKNOWN owner2
   --       ( @Company in ( 'UNK' , trc_company ) ) AND
   --       ( @Fleet in ( 'UNK' , trc_fleet ) ) AND
   --       ( @Division in ( 'UNK' , trc_division ) ) AND
   --       ( @Terminal in ( 'UNK' , trc_terminal ) ) AND
   --       ( @TrcType1 in ( 'UNK' , trc_type1 ) ) AND
   --       ( @TrcType2 in ( 'UNK' , trc_type2 ) ) AND
   --       ( @TrcType3 in ( 'UNK' , trc_type3 ) ) AND
   --       ( @TrcType4 in ( 'UNK' , trc_type4 ) ) AND
   --       ( trc_actg_type in ( @AcctType1 , @AcctType2 ) )  AND
   --       dbo.RowRestrictByUser ('tractorprofile', tractorprofile.rowsec_rsrv_id, '', '', '') = 1   AND
 --            ( NOT EXISTS ( SELECT *
   --                   FROM payheader
   --                   WHERE asgn_type = 'TRC' AND
   --                      asgn_id = tractorprofile.trc_number AND
   --                      pyh_payperiod = @paydate AND
   --                      pyh_paystatus <> 'PND'
   --                      AND pyh_payto = trc_owner2 ) )   AND ( trc_owner2 <> 'UNKNOWN' )
   -- end
   --end
end
/* GENERATE ASSET LISTS FOR TRAILER */
--if (@trailer_yes > 0)
IF @trlyes <> 'XXX'
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
      --( @Trailer in ( 'UNKNOWN' , trl_number ) ) AND
      --( @Company in ( 'UNK' , trl_company ) ) AND
      --( @Fleet in ( 'UNK' , trl_fleet ) ) AND
      --( @Division in ( 'UNK' , trl_division ) ) AND
      --( @Terminal in ( 'UNK' , trl_terminal ) ) AND
      --( @TrlType1 in ( 'UNK' , trl_type1 ) ) AND
      --( @TrlType2 in ( 'UNK' , trl_type2 ) ) AND
      --( @TrlType3 in ( 'UNK' , trl_type3 ) ) AND
      --( @TrlType4 in ( 'UNK' , trl_type4 ) ) AND
      --( trl_actg_type in ( @AcctType1 , @AcctType2 ) )   AND
      (@Trailer = trl_number OR @Trailer = 'UNKNOWN' OR @Trailer = (trl_ilt_scac + ',' + trl_number)
            or @Trailer = '%' or CHARINDEX( ',' + trl_number + ',',@Trailer) > 0 or CHARINDEX( ',' + (trl_ilt_scac + ',' + trl_number) + ',',@Trailer) > 0)
         AND ( (@acct_typ = 'X' AND trl_actg_type IN('A', 'P')) OR (@acct_typ = trl_actg_type) )
         AND (@company = 'UNK' or @company = trl_company or @company = '%' or CHARINDEX( ',' + trl_company + ',',@company) > 0)
         AND (@fleet = 'UNK' or @fleet = trl_fleet or @fleet = '%' or CHARINDEX( ',' + trl_fleet + ',',@fleet) > 0)
         AND (@division = 'UNK' or @division = trl_division or @division = '%' or CHARINDEX( ',' + trl_division + ',',@division) > 0)
         AND (@terminal = 'UNK' or @terminal = trl_terminal or @terminal = '%' or CHARINDEX( ',' + trl_terminal + ',',@terminal) > 0)
         and ( @TrlType1 = 'UNK' or @TrlType1 =  trl_type1 or @TrlType1 = '%' or CHARINDEX( ',' + trl_type1 + ',',@TrlType1) > 0)
         and ( @TrlType2 = 'UNK' or @TrlType2 =  trl_type2 or @TrlType2 = '%' or CHARINDEX( ',' + trl_type2 + ',',@TrlType2) > 0)
         and ( @TrlType3 = 'UNK' or @TrlType3 =  trl_type3 or @TrlType3 = '%' or CHARINDEX( ',' + trl_type3 + ',',@TrlType3) > 0)
         and ( @TrlType4 = 'UNK' or @TrlType4 =  trl_type4 or @TrlType4 = '%' or CHARINDEX( ',' + trl_type4 + ',',@TrlType4) > 0) and
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
         AND (@trl_branch = '%' OR CHARINDEX( ',' + IsNull(trailerprofile.trl_branch,'UNKNOWN') + ',', @trl_branch) > 0)
         --END PTS 65645 SPN
end

/* GENERATE ASSET LISTS FOR CARRIER */
--if (@carrier_yes > 0)
IF @caryes <> 'XXX'
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
      --( @Carrier in ('UNKNOWN', car_id ) ) AND
      --( @CarType1 in ( 'UNK' , car_type1 ) ) AND
      --( @CarType2 in ( 'UNK' , car_type2 ) ) AND
      --( @CarType3 in ( 'UNK' , car_type3 ) ) AND
      --( @CarType4 in ( 'UNK' , car_type4 ) ) AND
      --( car_actg_type in ( @AcctType1 , @AcctType2 ) ) AND
      (@Carrier = car_id OR @Carrier = 'UNKNOWN' or @Carrier = '%' or CHARINDEX( ',' + car_id + ',',@Carrier) > 0)
         AND ( (@acct_typ = 'X' AND car_actg_type IN('A', 'P')) OR (@acct_typ = car_actg_type) )
         and ( @carType1 = 'UNK' or @carType1 =  car_type1 or @carType1 = '%' or CHARINDEX( ',' + car_type1 + ',',@carType1) > 0)
         and ( @carType2 = 'UNK' or @carType2 =  car_type2 or @carType2 = '%' or CHARINDEX( ',' + car_type2 + ',',@carType2) > 0)
         and ( @carType3 = 'UNK' or @carType3 =  car_type3 or @carType3 = '%' or CHARINDEX( ',' + car_type3 + ',',@carType3) > 0)
         and ( @carType4 = 'UNK' or @carType4 =  car_type4 or @carType4 = '%' or CHARINDEX( ',' + car_type4 + ',',@carType4) > 0) and
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
         AND (@car_branch = '%' OR CHARINDEX( ',' + IsNull(carrier.car_branch,'UNKNOWN') + ',', @car_branch) > 0)
         --END PTS 65645 SPN
end

--if (@tpr_yes > 0)
IF @tpryes <> 'XXX'
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
      --( @tpr_id in ( 'UNKNOWN' , tpr_id ) ) AND
      --( @tpr_type in ( 'UNKNOWN' , tpr_type ) ) AND
      --( tpr_actg_type in ( @AcctType1 , @AcctType2 ) ) AND
      (@tpr_id = tpr_id OR tpr_id = 'UNKNOWN' or tpr_id = '%' or CHARINDEX( ',' + tpr_id + ',',@tpr_id) > 0)
         AND ( (@acct_typ = 'X' AND tpr_actg_type IN('A', 'P')) OR (@acct_typ = tpr_actg_type) )
         and ( @tpr_type = 'UNKNOWN' or @tpr_type =  tpr_type or @tpr_type = '%' or CHARINDEX( ',' + tpr_type + ',',@tpr_type) > 0) and
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

-- LOR   PTS# 48389  added sch
If @sch = 1
begin
   update a
   SET pyh_totalcomp =  ( SELECT sum ( paydetail.pyd_amount )
            FROM paydetail right outer join #temp
            on paydetail.asgn_type = #temp.asgn_type and
               paydetail.asgn_id = #temp.asgn_id
            WHERE    a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate OR (paydetail.pyh_payperiod >= '2049-12-31' AND paydetail.pyd_status = 'PND')) AND
               ( paydetail.pyd_pretax = 'Y' ) AND
               (paydetail.pyd_status=  @Status )),
      pyh_totaldeduct = ( SELECT sum ( paydetail.pyd_amount )
            FROM paydetail
            right outer join #temp
            on paydetail.asgn_type = #temp.asgn_type and
               paydetail.asgn_id = #temp.asgn_id
            WHERE    a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate OR (paydetail.pyh_payperiod >= '2049-12-31' AND paydetail.pyd_status = 'PND')) AND
               ( paydetail.pyd_pretax = 'N' ) AND
               ( paydetail.pyd_minus = -1 ) AND
               ( paydetail.pyd_status=  @Status )),
      pyh_totalreimbrs = ( SELECT sum ( paydetail.pyd_amount )
            FROM paydetail
            right outer join #temp
            on paydetail.asgn_type = #temp.asgn_type and
               paydetail.asgn_id = #temp.asgn_id
            WHERE a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate OR (paydetail.pyh_payperiod >= '2049-12-31' AND paydetail.pyd_status = 'PND')) AND
               ( paydetail.pyd_pretax = 'N' ) AND
               ( paydetail.pyd_minus = 1 ) AND
               ( paydetail.pyd_status=  @Status )),
      pyh_totalcomp_positive =  ( SELECT sum ( paydetail.pyd_amount )
            FROM paydetail right outer join #temp
            on paydetail.asgn_type = #temp.asgn_type and
               paydetail.asgn_id = #temp.asgn_id
            WHERE    a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate OR (paydetail.pyh_payperiod >= '2049-12-31' AND paydetail.pyd_status = 'PND')) AND
               ( paydetail.pyd_pretax = 'Y' ) AND
               ( paydetail.pyd_minus = 1 ) AND
               (paydetail.pyd_status=  @Status )),
      pyh_totalcomp_negative  =   ( SELECT sum ( paydetail.pyd_amount )
            FROM paydetail right outer join #temp
            on paydetail.asgn_type = #temp.asgn_type and
               paydetail.asgn_id = #temp.asgn_id
            WHERE    a.asgn_type = #temp.asgn_type and a.asgn_id = #temp.asgn_id and (paydetail.pyh_payperiod = @paydate OR (paydetail.pyh_payperiod >= '2049-12-31' AND paydetail.pyd_status = 'PND')) AND
               ( paydetail.pyd_pretax = 'Y' ) AND
               ( paydetail.pyd_minus = -1 ) AND
               (paydetail.pyd_status=  @Status ))
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
   From #temp a
end

IF @process_netpayzero = 'N'
begin
   update #temp
set pyh_totalcomp_positive = NULL,
   pyh_totalcomp_negative = NULL
end

---- -- PTS 41389 GAP 74 (start)
--If exists (select * from generalinfo where gi_name = 'TrackBranch' and gi_string1 = 'Y')
--BEGIN
--    -- IF SPECIFIC THEN PULL THAT - IF UNKNOWN THEN PULL THE ONES ALLOWED FOR THE USER.

--    IF @brn_id  = ',UNKNOWN,'
--       begin
--          If exists (select * from generalinfo where gi_name = 'BRANCHUSERSECURITY' and gi_string1 = 'Y')
--          BEGIN
--             -- if branch security is ON then get data, else, DO NOT DELETE.
--             SELECT brn_id
--             INTO #temp_user_branch
--             FROM branch_assignedtype
--             WHERE bat_type = 'USERID'
--             and brn_id <> 'UNKNOWN'
--             AND bat_value  =  @G_USERID

--             DELETE from #temp where branch NOT IN (select brn_id from #temp_user_branch)
--          END
--       end
--     ELSE
--       begin
--          Delete from #temp
--          where branch in (select branch from #temp
--                                 where CHARINDEX(',' + branch + ',', @brn_id) = 0 )
--       end

--END
 -- PTS 41389 GAP 74 (end)
 --original code

/* FINAL SELECT TO RETRIEVE RETUEN SET */
select * from #temp

return

GO
GRANT EXECUTE ON  [dbo].[d_pay_scroll_payfors_forviews_sp] TO [public]
GO
