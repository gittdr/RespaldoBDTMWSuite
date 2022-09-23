SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--arguments=(("Types", stringlist),("Status", stringlist),("LoPayDate", datetime),("HiPayDate", datetime),("Company", string),
--("Fleet", string),("Division", string),("Terminal", string),("DrvType1", string),("DrvType2", string),("DrvType3", string),
--("DrvType4", string),("TrcType1", string),("TrcType2", string),("TrcType3", string),("TrcType4", string),("Driver", string),
--("Tractor", string),("acct_type", string),("Carrier", string),("CarType1", string),("CarType2", string),("CarType3", string),
--("CarType4", string),("Trailer", string),("TrlType1", string),("TrlType2", string),("TrlType3", string),("TrlType4", string),
--("tpr_id", string),("tpr_type", string),("MissingArgResourcetypeonleg", string),("coowner", string))


create PROC [dbo].[d_scroll_payheaders_branch_sp]    (
               @Types varchar(60),
               @Status varchar(60),
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
               @Driver char(8),
               @Tractor char(8),
               @acct_type char(1),
               @Carrier char(8),    -- 20
               @CarType1 char(6),
               @CarType2 char(6),
               @CarType3 char(6),
               @CarType4 char(6),
               @Trailer char(13),
               @TrlType1 char(6),
               @TrlType2 char(6),
               @TrlType3 char(6),
               @TrlType4 char(6),
               @tpr_id char(8),     -- 30
               @tpr_type char(12),
               @Brn_id  varchar(255),
               @coowner varchar(12),      --vjh 54402 coowners
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
 * NAME@
 * dbo.d_scroll_payheaders_branch_sp
 *
 * TYPE@
 * StoredProcedure
 *
 * DESCRIPTION@
 * Stored Procedure used as a data source for the settlement queues.
 *
 * RETURNS@
 *
 * LOR   PTS# 58375  created proc instead of dw sql to accommodate views
 *      SPN     PTS# 59850      using temp table to read list of branch_ids
 * 11/26/2012    PTS64692 - jet - add 3rd party revenue types to restrict Collect queue by 3rd Party revenue types
 * SPN   PTS# 63448  fixing trailer parm issue and changed join to trailerprofile to be trl_id instead of trl_number
 * 11/08/2012 PTS 65645 SPN - Added Restriction @mpp_branch, @trc_branch, @trl_branch, @car_branch
 */
SET NOCOUNT ON
declare
   @drivers_yes   int,
   @tractors_yes  int,
   @trailer_yes   int,
   @carrier_yes   int,
   @tpr_yes    int,
   @hold_hld   char(3),
   @released_pnd  char(3),
   @collected_col char(3),
   @closed_rel char(3)

select @drivers_yes = charindex('DRV', @Types)
select @tractors_yes = charindex('TRC', @Types)
select @trailer_yes = charindex('TRL', @Types)
select @carrier_yes = charindex('CAR', @Types)
select @tpr_yes = charindex('TPR', @Types)

If charindex('HLD', @Status) > 0
   select @hold_hld = 'HLD'
else
   select @hold_hld = 'XXX'

if charindex('PND', @Status) > 0
   select @released_pnd = 'PND'
else
   select @released_pnd = 'XXX'

if charindex('COL', @Status) > 0
   select @collected_col = 'COL'
else
   select @collected_col = 'XXX'

if charindex('REL', @Status) > 0
   select @closed_rel = 'REL'
else
   select @closed_rel = 'XXX'

-- LOR   PTS# 58375
-- *************
-- *************  PLEASE MAKE CHANGES IN BOTH PROCS IF NECESSARY  *************
-- *************
If @view_id <> ''
   exec d_scroll_payheaders_branch_forviews_sp @hold_hld, @released_pnd, @collected_col, @closed_rel, @LoPayDate , @HiPayDate, @view_id
Else
Begin

IF @brn_id IS NULL
   SELECT @brn_id = 'UNKNOWN'
Else
   SELECT @brn_id = REPLACE(@brn_id,'''', '')

If @brn_id = '' or @brn_id  = 'UNK'
   SELECT @brn_id = 'UNKNOWN'

SELECT @brn_id = ',' + LTRIM(RTRIM(ISNULL(@brn_id, '')))  + ','

SELECT DISTINCT payheader.pyh_pyhnumber,
   payheader.asgn_type,
   payheader.asgn_id,
   payheader.pyh_paystatus,
   payheader.pyh_payperiod,
   payheader.pyh_totalcomp,
   payheader.pyh_totaldeduct,
   payheader.pyh_totalreimbrs,
   payheader.pyh_totalcomp + payheader.pyh_totaldeduct + payheader.pyh_totalreimbrs,
   payheader.pyh_payto,
   mpp_terminal,
   manpowerprofile.mpp_lastfirst driver_id,
   payto.pto_lastfirst,
   (SELECT COUNT(pyd_number)
      FROM paydetail
      WHERE paydetail.pyh_number = payheader.pyh_pyhnumber),
   mpp_type1,
   manpowerprofile.mpp_branch as 'branch'
FROM payheader JOIN manpowerprofile ON payheader.asgn_id = manpowerprofile.mpp_id
   LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id
WHERE   ( payheader.pyh_payperiod between @LoPayDate and @HiPayDate )
   --AND ( payheader.pyh_paystatus in ( @Status ) )
   AND ( payheader.pyh_paystatus in ( @hold_hld, @released_pnd, @collected_col, @closed_rel ) )
   --AND ( payheader.asgn_type in ( @Types ) )
   AND ( payheader.asgn_type = 'DRV' ) and @drivers_yes > 0
   AND @Driver in ('UNKNOWN', payheader.asgn_id )
   AND @DrvType1 in ('UNK', manpowerprofile.mpp_type1 )
   AND @DrvType2 in ('UNK', manpowerprofile.mpp_type2 )
   AND @DrvType3 in ('UNK', manpowerprofile.mpp_type3 )
   AND @DrvType4 in ('UNK', manpowerprofile.mpp_type4 )
   AND @Company in  ('UNK', manpowerprofile.mpp_company )
   AND @Fleet in    ('UNK', manpowerprofile.mpp_fleet )
   AND @Division in ('UNK', manpowerprofile.mpp_division )
   AND ( (@acct_type = 'X' AND manpowerprofile.mpp_actg_type IN('A', 'P')) OR (@acct_type = manpowerprofile.mpp_actg_type) )
   AND @Terminal in ( 'UNK', manpowerprofile.mpp_terminal )
   AND dbo.RowRestrictByUser ('manpowerprofile', manpowerprofile.rowsec_rsrv_id, '', '', '') = 1
   AND dbo.RowRestrictByAsgn (payheader.asgn_type, payheader.asgn_id) = 1
   --AND ( IsNull(manpowerprofile.mpp_branch, 'UNKNOWN') in ( @Brn_id ) )
   --BEGIN PTS 59850 SPN
   --and CHARINDEX( ',' + IsNull(manpowerprofile.mpp_branch, 'UNKNOWN') + ',',@Brn_id) > 0
   AND
   (@Brn_id = ',UNKNOWN,' OR
   IsNull(manpowerprofile.mpp_branch, 'UNKNOWN') IN (select temp_report_argument_value
                                         from temp_report_arguments
                                        where current_session_id = @@SPID
                                          and temp_report_name = 'SCROLL_PAYHEADERS'
                                          and temp_report_argument_name = 'BRANCH_ID'
                                          and temp_report_argument_value IS NOT NULL
                                      )
   )
   --END PTS 59850 SPN
   --BEGIN PTS 65645 SPN
   AND (@mpp_branch = 'UNKNOWN' OR @mpp_branch = manpowerprofile.mpp_branch)
   --END PTS 65645 SPN

UNION
SELECT DISTINCT payheader.pyh_pyhnumber,
   payheader.asgn_type,
   payheader.asgn_id,
   payheader.pyh_paystatus,
   payheader.pyh_payperiod,
   payheader.pyh_totalcomp,
   payheader.pyh_totaldeduct,
   payheader.pyh_totalreimbrs,
   payheader.pyh_totalcomp + payheader.pyh_totaldeduct + payheader.pyh_totalreimbrs,
   payheader.pyh_payto,
   trc_terminal,
   '' driver_id,
   payto.pto_lastfirst,
   (SELECT count(pyd_number)
   from paydetail
   where paydetail.pyh_number = payheader.pyh_pyhnumber),
   trc_type1,
    tractorprofile.trc_branch as 'branch'
FROM payheader join tractorprofile on payheader.asgn_id = tractorprofile.trc_number
   left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE ( payheader.pyh_payperiod between @LoPayDate and @HiPayDate )
   --AND ( payheader.pyh_paystatus in ( @Status ) )
   AND ( payheader.pyh_paystatus in ( @hold_hld, @released_pnd, @collected_col, @closed_rel ) )
   --AND ( payheader.asgn_type in ( @Types ) )
   AND ( payheader.asgn_type = 'TRC' ) and @tractors_yes > 0
   AND @Tractor in ('UNKNOWN', payheader.asgn_id )
   AND @TrcType1 in ('UNK', tractorprofile.trc_type1 )
   AND @TrcType2 in ('UNK', tractorprofile.trc_type2 )
   AND @TrcType3 in ('UNK', tractorprofile.trc_type3 )
   AND @TrcType4 in ('UNK', tractorprofile.trc_type4 )
   AND @Company in ('UNK', tractorprofile.trc_company )
   AND @Fleet in ('UNK', tractorprofile.trc_fleet )
   AND @Division in ('UNK', tractorprofile.trc_division )
   AND ( (@acct_type = 'X' AND tractorprofile.trc_actg_type IN('A', 'P')) OR (@acct_type = tractorprofile.trc_actg_type) )
   AND @Terminal in ('UNK', tractorprofile.trc_terminal )
   AND dbo.RowRestrictByUser ('tractorprofile', tractorprofile.rowsec_rsrv_id, '', '', '') = 1
   AND dbo.RowRestrictByAsgn (payheader.asgn_type, payheader.asgn_id) = 1
   AND @coowner in ('UNKNOWN',payheader.pyh_payto)
   --AND ( IsNull(tractorprofile.trc_branch, 'UNKNOWN') in ( :Brn_id ) )
   --BEGIN PTS 59850 SPN
   --and CHARINDEX( ',' + IsNull(tractorprofile.trc_branch, 'UNKNOWN') + ',',@Brn_id) > 0
   AND
   (@Brn_id = ',UNKNOWN,' OR
   IsNull(tractorprofile.trc_branch, 'UNKNOWN') IN (select temp_report_argument_value
                                         from temp_report_arguments
                                        where current_session_id = @@SPID
                                          and temp_report_name = 'SCROLL_PAYHEADERS'
                                          and temp_report_argument_name = 'BRANCH_ID'
                                          and temp_report_argument_value IS NOT NULL
                                      )
   )
   --END PTS 59850 SPN
   --BEGIN PTS 65645 SPN
   AND (@trc_branch = 'UNKNOWN' OR @trc_branch = tractorprofile.trc_branch)
   --END PTS 65645 SPN

UNION
SELECT DISTINCT payheader.pyh_pyhnumber,
   payheader.asgn_type,
   payheader.asgn_id,
   payheader.pyh_paystatus,
   payheader.pyh_payperiod,
   payheader.pyh_totalcomp,
   payheader.pyh_totaldeduct,
   payheader.pyh_totalreimbrs,
   payheader.pyh_totalcomp + payheader.pyh_totaldeduct + payheader.pyh_totalreimbrs,
   payheader.pyh_payto,
   '',
   '' driver_id,
   payto.pto_lastfirst,
   (SELECT count(pyd_number)
      from paydetail
      where paydetail.pyh_number = payheader.pyh_pyhnumber),
   car_type1,
   carrier.car_branch as 'branch'
FROM payheader join carrier on payheader.asgn_id = carrier.car_id
   left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE ( payheader.pyh_payperiod between @LoPayDate and @HiPayDate )
   --AND ( payheader.pyh_paystatus in ( @Status ) )
   AND ( payheader.pyh_paystatus in ( @hold_hld, @released_pnd, @collected_col, @closed_rel ) )
   --AND ( payheader.asgn_type in ( @Types ) )
   AND ( payheader.asgn_type = 'CAR' ) and @carrier_yes > 0
   AND @Carrier in ('UNKNOWN', payheader.asgn_id )
   AND @CarType1 in ('UNK', carrier.car_type1 )
   AND @CarType2 in ('UNK', carrier.car_type2 )
   AND @CarType3 in ('UNK', carrier.car_type3 )
   AND @CarType4 in ('UNK', carrier.car_type4 )
   AND ( (@acct_type = 'X' AND carrier.car_actg_type IN('A', 'P')) OR (@acct_type = carrier.car_actg_type) )
   AND dbo.RowRestrictByAsgn (payheader.asgn_type, payheader.asgn_id) = 1
   --AND ( IsNull(carrier.car_branch, 'UNKNOWN') in ( :Brn_id ) )
   --BEGIN PTS 59850 SPN
   --and CHARINDEX( ',' + IsNull(carrier.car_branch, 'UNKNOWN') + ',',@Brn_id) > 0
   AND
   (@Brn_id = ',UNKNOWN,' OR
   IsNull(carrier.car_branch, 'UNKNOWN') IN (select temp_report_argument_value
                                      from temp_report_arguments
                                     where current_session_id = @@SPID
                                       and temp_report_name = 'SCROLL_PAYHEADERS'
                                       and temp_report_argument_name = 'BRANCH_ID'
                                       and temp_report_argument_value IS NOT NULL
                                   )
   )
   --END PTS 59850 SPN
   --BEGIN PTS 65645 SPN
   AND (@car_branch = 'UNKNOWN' OR @car_branch = carrier.car_branch)
   --END PTS 65645 SPN

UNION
SELECT DISTINCT payheader.pyh_pyhnumber,
   payheader.asgn_type,
   payheader.asgn_id,
   payheader.pyh_paystatus,
   payheader.pyh_payperiod,
   payheader.pyh_totalcomp,
   payheader.pyh_totaldeduct,
   payheader.pyh_totalreimbrs,
   payheader.pyh_totalcomp + payheader.pyh_totaldeduct + payheader.pyh_totalreimbrs,
   payheader.pyh_payto,
   trl_terminal,
   '' driver_id,
   payto.pto_lastfirst,
   (SELECT count(pyd_number)
      from paydetail
      where paydetail.pyh_number = payheader.pyh_pyhnumber),
   trl_type1,
   trailerprofile.trl_branch as 'branch'
FROM payheader join trailerprofile on payheader.asgn_id = trailerprofile.trl_id
   left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE ( payheader.pyh_payperiod between @LoPayDate and @HiPayDate )
   --AND ( payheader.pyh_paystatus in ( @Status ) )
   AND ( payheader.pyh_paystatus in ( @hold_hld, @released_pnd, @collected_col, @closed_rel ) )
   --AND ( payheader.asgn_type in ( @Types ) )
   AND ( payheader.asgn_type = 'TRL' ) and @trailer_yes > 0
   AND (@Trailer in ('UNKNOWN', payheader.asgn_id ) OR CHARINDEX(',' + payheader.asgn_id + ',', ',' + @Trailer + ',') > 0)
   AND @TrlType1 in ('UNK', trailerprofile.trl_type1 )
   AND @TrlType2 in ('UNK', trailerprofile.trl_type2 )
   AND @TrlType3 in ('UNK', trailerprofile.trl_type3 )
   AND @TrlType4 in ('UNK', trailerprofile.trl_type4 )
   AND @Company in ('UNK', trailerprofile.trl_company )
   AND @Fleet in ('UNK', trailerprofile.trl_fleet )
   AND @Division in ('UNK', trailerprofile.trl_division )
   AND ( (@acct_type = 'X' AND trailerprofile.trl_actg_type IN('A', 'P')) OR (@acct_type = trailerprofile.trl_actg_type) )
   AND @Terminal in ('UNK', trailerprofile.trl_terminal )
   AND CASE WHEN COALESCE (trailerprofile.trl_ilt_scac, '') = '' THEN dbo.RowRestrictByUser ('trailerprofile', trailerprofile.rowsec_rsrv_id, '', '', '') ELSE 1 END = 1
   AND dbo.RowRestrictByAsgn (payheader.asgn_type, payheader.asgn_id) = 1
   --AND ( IsNull(trailerprofile.trl_branch, 'UNKNOWN') in ( :Brn_id ) )
   --BEGIN PTS 59850 SPN
   --and CHARINDEX( ',' + IsNull(trailerprofile.trl_branch, 'UNKNOWN') + ',',@Brn_id) > 0
   AND
   (@Brn_id = ',UNKNOWN,' OR
   IsNull(trailerprofile.trl_branch, 'UNKNOWN') IN (select temp_report_argument_value
                                       from temp_report_arguments
                                      where current_session_id = @@SPID
                                        and temp_report_name = 'SCROLL_PAYHEADERS'
                                        and temp_report_argument_name = 'BRANCH_ID'
                                        and temp_report_argument_value IS NOT NULL
                                    )
   )
   --END PTS 59850 SPN
   --BEGIN PTS 65645 SPN
   AND (@trl_branch = 'UNKNOWN' OR @trl_branch = trailerprofile.trl_branch)
   --END PTS 65645 SPN

UNION
SELECT DISTINCT payheader.pyh_pyhnumber,
   payheader.asgn_type,
   payheader.asgn_id,
   payheader.pyh_paystatus,
   payheader.pyh_payperiod,
   payheader.pyh_totalcomp,
   payheader.pyh_totaldeduct,
   payheader.pyh_totalreimbrs,
   payheader.pyh_totalcomp + payheader.pyh_totaldeduct + payheader.pyh_totalreimbrs,
   payheader.pyh_payto,
   '',
   '' driver_id,
   payto.pto_lastfirst,
   (SELECT count(pyd_number)
   from paydetail
   where paydetail.pyh_number = payheader.pyh_pyhnumber),
   '',
    thirdpartyprofile.tpr_branch as 'branch'
FROM payheader join thirdpartyprofile on payheader.asgn_id = thirdpartyprofile.tpr_id
left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE ( payheader.pyh_payperiod between @LoPayDate and @HiPayDate )
   --AND ( payheader.pyh_paystatus in ( @Status ) )
   AND ( payheader.pyh_paystatus in ( @hold_hld, @released_pnd, @collected_col, @closed_rel ) )
   --AND ( payheader.asgn_type in ( @Types ) )
   AND ( payheader.asgn_type = 'TPR' ) and @tpr_yes > 0
   AND @tpr_id in ('UNKNOWN', payheader.asgn_id )
   AND @tpr_type in ('UNKNOWN', thirdpartyprofile.tpr_type )
   AND ( (@acct_type = 'X' AND thirdpartyprofile.tpr_actg_type IN('A', 'P')) OR (@acct_type = thirdpartyprofile.tpr_actg_type) )
   AND ( @tpr_revtype1 in ('UNK', thirdpartyprofile.tpr_revtype1 ) )
   AND ( @tpr_revtype2 in ('UNK', thirdpartyprofile.tpr_revtype2 ) )
   AND ( @tpr_revtype3 in ('UNK', thirdpartyprofile.tpr_revtype3 ) )
   AND ( @tpr_revtype4 in ('UNK', thirdpartyprofile.tpr_revtype4 ) )
   --AND ( IsNull(thirdpartyprofile.tpr_branch, 'UNKNOWN') in ( :Brn_id ) )
   --BEGIN PTS 59850 SPN
   --and CHARINDEX( ',' + IsNull(thirdpartyprofile.tpr_branch, 'UNKNOWN') + ',',@Brn_id) > 0
   AND
   (@Brn_id = ',UNKNOWN,' OR
   IsNull(thirdpartyprofile.tpr_branch, 'UNKNOWN') IN (select temp_report_argument_value
                                          from temp_report_arguments
                                         where current_session_id = @@SPID
                                           and temp_report_name = 'SCROLL_PAYHEADERS'
                                           and temp_report_argument_name = 'BRANCH_ID'
                                           and temp_report_argument_value IS NOT NULL
                                       )
   )
   --END PTS 59850 SPN

order by payheader.pyh_payperiod, payheader.pyh_paystatus, payheader.asgn_type, payheader.asgn_id, payheader.pyh_pyhnumber
--sort="payheader_pyh_payperiod A payheader_pyh_paystatus A payheader_asgn_type A payheader_asgn_id A payheader_pyh_pyhnumber A " )

end

GO
GRANT EXECUTE ON  [dbo].[d_scroll_payheaders_branch_sp] TO [public]
GO
