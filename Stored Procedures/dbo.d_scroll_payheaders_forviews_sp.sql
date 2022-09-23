SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [dbo].[d_scroll_payheaders_forviews_sp]    (
               @hold_hld   char(3),
               @released_pnd  char(3),
               @collected_col char(3),
               @closed_rel char(3),
               @LoPayDate datetime,
               @HiPayDate datetime,
               @view_id varchar(6)

)  AS

/**
 *
 * NAME@
 * dbo.d_scroll_payheaders_forviews_sp
 *
 * TYPE@
 * StoredProcedure
 *
 * DESCRIPTION@
 * Stored Procedure used as a data source for the settlement queues.
 *
 * RETURNS@
 *
 * LOR   PTS# 58375  views
 * SPN   PTS# 63448  fixing trailer parm issue and changed join to trailerprofile to be trl_id instead of trl_number
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

--BEGIN PTS 63020 SPN - Unused restrictions
DECLARE @p_ivh_billto         VARCHAR(255)
DECLARE @lgh_booked_revtype1  VARCHAR(255)
DECLARE @p_revtype1           VARCHAR(255)
DECLARE @p_revtype2           VARCHAR(255)
DECLARE @p_revtype3           VARCHAR(255)
DECLARE @p_revtype4           VARCHAR(255)
DECLARE @lgh_type1            VARCHAR(255)
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

--BEGIN PTS 63020 SPN
--select @company = case isNull(rtrim(bov_company), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_company + ',')
--                     end,
--   @fleet = case isNull(rtrim(bov_fleet), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_fleet + ',')
--                     end,
--   @division = case isNull(rtrim(bov_division), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_division + ',')
--                     end,
--   @terminal = case isNull(rtrim(bov_terminal), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_terminal + ',')
--                     end,
--   @acct_typ = IsNull(bov_acct_type, 'X'),      -- A/P/X
--   @drvyes = case isNull(bov_driver_incl, 'N')
--                        when 'N' then 'XXX'
--                        else 'DRV'
--                     end,
--   @driver = case isNull(rtrim(bov_driver_id), '')
--                        when '' then '%'
--                        when 'UNKNOWN' then '%'
--                        else (',' + bov_driver_id + ',')
--                     end,
--   @drvtype1 = case isNull(rtrim(bov_mpp_type1), '')
--                        when '' then '%'
--                        else (',' + bov_mpp_type1 + ',')
--                     end ,
--   @drvtype2 = case isNull(rtrim(bov_mpp_type2), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_mpp_type2 + ',')
--                     end ,
--   @drvtype3 = case isNull(rtrim(bov_mpp_type3), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_mpp_type3 + ',')
--                     end ,
--   @drvtype4 = case isNull(rtrim(bov_mpp_type4), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_mpp_type4 + ',')
--                     end ,
--   @trcyes = case isNull(bov_tractor_incl, 'N')
--                        when 'N' then 'XXX'
--                        else 'TRC'
--                     end,
--   @tractor = case isNull(rtrim(bov_tractor_id), '')
--                        when '' then '%'
--                        when 'UNKNOWN' then '%'
--                        else (',' + bov_tractor_id + ',')
--                     end,
--   @trctype1 = case isNull(rtrim(bov_trc_type1), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trc_type1 + ',')
--                     end ,
--   @trctype2 = case isNull(rtrim(bov_trc_type2), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trc_type2 + ',')
--                     end ,
--   @trctype3 = case isNull(rtrim(bov_trc_type3), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trc_type3 + ',')
--                     end ,
--   @trctype4 = case isNull(rtrim(bov_trc_type4), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trc_type4 + ',')
--                     end ,
--   @trlyes = case isNull(bov_trailer_incl, 'N')
--                        when 'N' then 'XXX'
--                        else 'TRL'
--                     end,
--   @trailer = case isNull(rtrim(bov_trailer_id), '')
--                        when '' then '%'
--                        when 'UNKNOWN' then '%'
--                        else (',' + bov_trailer_id + ',')
--                     end,
--   @trltype1 = case isNull(rtrim(bov_trl_type1), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trl_type1 + ',')
--                     end ,
--   @trltype2 = case isNull(rtrim(bov_trl_type2), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trl_type2 + ',')
--                     end ,
--   @trltype3 = case isNull(rtrim(bov_trl_type3), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trl_type3 + ',')
--                     end ,
--   @trltype4 = case isNull(rtrim(bov_trl_type4), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trl_type4 + ',')
--                     end ,
--   @caryes = case isNull(bov_carrier_incl, 'N')
--                        when 'N' then 'XXX'
--                        else 'CAR'
--                     end,
--   @carrier = case isNull(rtrim(bov_carrier_id), '')
--                        when '' then '%'
--                        when 'UNKNOWN' then '%'
--                        else (',' + bov_carrier_id + ',')
--                     end,
--   @cartype1 = case isNull(rtrim(bov_car_type1), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_car_type1 + ',')
--                     end ,
--   @cartype2 = case isNull(rtrim(bov_car_type2), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_car_type2 + ',')
--                     end ,
--   @cartype3 = case isNull(rtrim(bov_car_type3), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_car_type3 + ',')
--                     end ,
--   @cartype4 = case isNull(rtrim(bov_car_type4), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_car_type4 + ',')
--                     end ,
--   @tpryes = case isNull(bov_tpr_incl, 'N')
--                        when 'N' then 'XXX'
--                        else 'TPR'
--                     end,
--   @tpr_id = case isNull(rtrim(bov_tpr_id), '')
--                        when '' then '%'
--                        when 'UNKNOWN' then '%'
--                        else (',' + bov_tpr_id + ',')
--                     end,
--   @tpr_type = case isNull(rtrim(bov_tpr_type), '')
--                        when '' then '%'
--                        when 'UNKNOWN' then '%'
--                        else (',' + bov_tpr_type + ',')
--                     end
--   from backofficeview
--   where bov_id = @view_id and bov_type = 'CLS'
   --PTS 65645 SPN - added @mpp_branch, @trc_branch, @trl_branch and @car_branch
   EXEC dbo.backofficeview_get_sp
                         @bov_type               = 'CLS'
                       , @bov_id                 = @view_id
                       , @bov_billto             = @p_ivh_billto        OUTPUT
                       , @bov_acct_type          = @acct_typ            OUTPUT
                       , @bov_booked_revtype1    = @lgh_booked_revtype1 OUTPUT
                       , @bov_rev_type1          = @p_revtype1          OUTPUT
                       , @bov_rev_type2          = @p_revtype2          OUTPUT
                       , @bov_rev_type3          = @p_revtype3          OUTPUT
                       , @bov_rev_type4          = @p_revtype4          OUTPUT
                       , @bov_lgh_type1          = @lgh_type1           OUTPUT
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
   mpp_type1
FROM payheader JOIN manpowerprofile ON payheader.asgn_id = manpowerprofile.mpp_id
   LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id
WHERE   ( payheader.pyh_payperiod between @LoPayDate and @HiPayDate )
   AND ( payheader.pyh_paystatus in ( @hold_hld, @released_pnd, @collected_col, @closed_rel ) )
   AND ( payheader.asgn_type = 'DRV' )
   and @drvyes <> 'XXX'
   AND ( (@acct_typ = 'X' AND manpowerprofile.mpp_actg_type IN('A', 'P')) OR (@acct_typ = manpowerprofile.mpp_actg_type) )
   AND dbo.RowRestrictByUser ('manpowerprofile', manpowerprofile.rowsec_rsrv_id, '', '', '') = 1
   AND dbo.RowRestrictByAsgn (payheader.asgn_type, payheader.asgn_id) = 1
   and (@driver = payheader.asgn_id OR @driver = 'UNKNOWN' or @driver = '%' or CHARINDEX( ',' + payheader.asgn_id + ',',@driver) > 0)
   AND (@company = 'UNK' or @company = mpp_company or @company = '%' or CHARINDEX( ',' + mpp_company + ',',@company) > 0)
   AND (@fleet = 'UNK' or @fleet = mpp_fleet or @fleet = '%' or CHARINDEX( ',' + mpp_fleet + ',',@fleet) > 0)
   AND (@division = 'UNK' or @division = mpp_division or @division = '%' or CHARINDEX( ',' + mpp_division + ',',@division) > 0)
   AND (@terminal = 'UNK' or @terminal = mpp_terminal or @terminal = '%' or CHARINDEX( ',' + mpp_terminal + ',',@terminal) > 0)
   and ( @DrvType1 = 'UNK' or @DrvType1 =  mpp_type1 or @DrvType1 = '%' or CHARINDEX( ',' + mpp_type1 + ',',@DrvType1) > 0)
   and ( @DrvType2 = 'UNK' or @DrvType2 =  mpp_type2 or @DrvType2 = '%' or CHARINDEX( ',' + mpp_type2 + ',',@DrvType2) > 0)
   and ( @DrvType3 = 'UNK' or @DrvType3 =  mpp_type3 or @DrvType3 = '%' or CHARINDEX( ',' + mpp_type3 + ',',@DrvType3) > 0)
   and ( @DrvType4 = 'UNK' or @DrvType4 =  mpp_type4 or @DrvType4 = '%' or CHARINDEX( ',' + mpp_type4 + ',',@DrvType4) > 0)
   --BEGIN PTS 65645 SPN
   AND (@mpp_branch = '%' OR CHARINDEX( ',' + IsNull(manpowerprofile.mpp_branch,'UNKNOWN') + ',', @mpp_branch) > 0)
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
   trc_type1
FROM payheader join tractorprofile on payheader.asgn_id = tractorprofile.trc_number
   left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE ( payheader.pyh_payperiod between @LoPayDate and @HiPayDate )
   AND ( payheader.pyh_paystatus in ( @hold_hld, @released_pnd, @collected_col, @closed_rel ) )
   AND ( payheader.asgn_type = 'TRC' ) and @trcyes <> 'XXX'
   AND ( (@acct_typ = 'X' AND tractorprofile.trc_actg_type IN('A', 'P')) OR (@acct_typ = tractorprofile.trc_actg_type) )
   AND dbo.RowRestrictByUser ('tractorprofile', tractorprofile.rowsec_rsrv_id, '', '', '') = 1
   AND dbo.RowRestrictByAsgn (payheader.asgn_type, payheader.asgn_id) = 1
   and (@Tractor = payheader.asgn_id OR @Tractor = 'UNKNOWN' or @Tractor = '%' or CHARINDEX( ',' + payheader.asgn_id + ',',@Tractor) > 0)
   AND (@company = 'UNK' or @company = trc_company or @company = '%' or CHARINDEX( ',' + trc_company + ',',@company) > 0)
   AND (@fleet = 'UNK' or @fleet = trc_fleet or @fleet = '%' or CHARINDEX( ',' + trc_fleet + ',',@fleet) > 0)
   AND (@division = 'UNK' or @division = trc_division or @division = '%' or CHARINDEX( ',' + trc_division + ',',@division) > 0)
   AND (@terminal = 'UNK' or @terminal = trc_terminal or @terminal = '%' or CHARINDEX( ',' + trc_terminal + ',',@terminal) > 0)
   and ( @trcType1 = 'UNK' or @trcType1 =  trc_type1 or @trcType1 = '%' or CHARINDEX( ',' + trc_type1 + ',',@trcType1) > 0)
   and ( @trcType2 = 'UNK' or @trcType2 =  trc_type2 or @trcType2 = '%' or CHARINDEX( ',' + trc_type2 + ',',@trcType2) > 0)
   and ( @trcType3 = 'UNK' or @trcType3 =  trc_type3 or @trcType3 = '%' or CHARINDEX( ',' + trc_type3 + ',',@trcType3) > 0)
   and ( @trcType4 = 'UNK' or @trcType4 =  trc_type4 or @trcType4 = '%' or CHARINDEX( ',' + trc_type4 + ',',@trcType4) > 0)
   --AND @coowner in ('UNKNOWN',payheader.pyh_payto)
   --BEGIN PTS 65645 SPN
   AND (@trc_branch = '%' OR CHARINDEX( ',' + IsNull(tractorprofile.trc_branch,'UNKNOWN') + ',', @trc_branch) > 0)
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
   car_type1
FROM payheader join carrier on payheader.asgn_id = carrier.car_id
   left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE ( payheader.pyh_payperiod between @LoPayDate and @HiPayDate )
   AND ( payheader.pyh_paystatus in ( @hold_hld, @released_pnd, @collected_col, @closed_rel ) )
   AND ( payheader.asgn_type = 'CAR' ) and @caryes <> 'XXX'
   and (@Carrier = payheader.asgn_id OR @Carrier = 'UNKNOWN' or @Carrier = '%' or CHARINDEX( ',' + payheader.asgn_id + ',',@Carrier) > 0)
   and ( @CarType1 = 'UNK' or @CarType1 =  Car_type1 or @CarType1 = '%' or CHARINDEX( ',' + Car_type1 + ',',@CarType1) > 0)
   and ( @CarType2 = 'UNK' or @CarType2 =  Car_type2 or @CarType2 = '%' or CHARINDEX( ',' + Car_type2 + ',',@CarType2) > 0)
   and ( @CarType3 = 'UNK' or @CarType3 =  Car_type3 or @CarType3 = '%' or CHARINDEX( ',' + Car_type3 + ',',@CarType3) > 0)
   and ( @CarType4 = 'UNK' or @CarType4 =  Car_type4 or @CarType4 = '%' or CHARINDEX( ',' + Car_type4 + ',',@CarType4) > 0)
   AND ( (@acct_typ = 'X' AND carrier.car_actg_type IN('A', 'P')) OR (@acct_typ = carrier.car_actg_type) )
   --BEGIN PTS 65645 SPN
   AND (@car_branch = '%' OR CHARINDEX( ',' + IsNull(carrier.car_branch,'UNKNOWN') + ',', @car_branch) > 0)
   --END PTS 65645 SPN
   AND dbo.RowRestrictByAsgn (payheader.asgn_type, payheader.asgn_id) = 1

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
   trl_type1
FROM payheader join trailerprofile on payheader.asgn_id = trailerprofile.trl_id
   left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE ( payheader.pyh_payperiod between @LoPayDate and @HiPayDate )
   AND ( payheader.pyh_paystatus in ( @hold_hld, @released_pnd, @collected_col, @closed_rel ) )
   AND ( payheader.asgn_type = 'TRL' )and @trlyes <> 'XXX'
   AND ( (@acct_typ = 'X' AND trailerprofile.trl_actg_type IN('A', 'P')) OR (@acct_typ = trailerprofile.trl_actg_type) )
   AND CASE WHEN COALESCE (trailerprofile.trl_ilt_scac, '') = '' THEN dbo.RowRestrictByUser ('trailerprofile', trailerprofile.rowsec_rsrv_id, '', '', '') ELSE 1 END = 1
   AND dbo.RowRestrictByAsgn (payheader.asgn_type, payheader.asgn_id) = 1
   and (@Trailer = payheader.asgn_id OR @Trailer = 'UNKNOWN' or @Trailer = '%' or CHARINDEX( ',' + payheader.asgn_id + ',',@Trailer) > 0)
   AND (@company = 'UNK' or @company = trl_company or @company = '%' or CHARINDEX( ',' + trl_company + ',',@company) > 0)
   AND (@fleet = 'UNK' or @fleet = trl_fleet or @fleet = '%' or CHARINDEX( ',' + trl_fleet + ',',@fleet) > 0)
   AND (@division = 'UNK' or @division = trl_division or @division = '%' or CHARINDEX( ',' + trl_division + ',',@division) > 0)
   AND (@terminal = 'UNK' or @terminal = trl_terminal or @terminal = '%' or CHARINDEX( ',' + trl_terminal + ',',@terminal) > 0)
   and ( @trlType1 = 'UNK' or @trlType1 =  trl_type1 or @trlType1 = '%' or CHARINDEX( ',' + trl_type1 + ',',@trlType1) > 0)
   and ( @trlType2 = 'UNK' or @trlType2 =  trl_type2 or @trlType2 = '%' or CHARINDEX( ',' + trl_type2 + ',',@trlType2) > 0)
   and ( @trlType3 = 'UNK' or @trlType3 =  trl_type3 or @trlType3 = '%' or CHARINDEX( ',' + trl_type3 + ',',@trlType3) > 0)
   and ( @trlType4 = 'UNK' or @trlType4 =  trl_type4 or @trlType4 = '%' or CHARINDEX( ',' + trl_type4 + ',',@trlType4) > 0)
   --BEGIN PTS 65645 SPN
   AND (@trl_branch = '%' OR CHARINDEX( ',' + IsNull(trailerprofile.trl_branch,'UNKNOWN') + ',', @trl_branch) > 0)
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
   ''
FROM payheader join thirdpartyprofile on payheader.asgn_id = thirdpartyprofile.tpr_id
left outer join payto on payheader.pyh_payto = payto.pto_id
WHERE ( payheader.pyh_payperiod between @LoPayDate and @HiPayDate )
AND ( payheader.pyh_paystatus in ( @hold_hld, @released_pnd, @collected_col, @closed_rel ) )
   AND ( payheader.asgn_type = 'TPR' )and @tpryes <> 'XXX'
   and (@tpr_id = payheader.asgn_id OR @tpr_id = 'UNKNOWN' or @tpr_id = '%' or CHARINDEX( ',' + payheader.asgn_id + ',',@tpr_id) > 0)
   and ( @tpr_type = 'UNKNOWN' or @tpr_type =  tpr_type or @tpr_type = '%' or CHARINDEX( ',' + tpr_type + ',',@tpr_type) > 0)
   AND ( (@acct_typ = 'X' AND thirdpartyprofile.tpr_actg_type IN('A', 'P')) OR (@acct_typ = thirdpartyprofile.tpr_actg_type) )

order by payheader.pyh_payperiod, payheader.pyh_paystatus, payheader.asgn_type, payheader.asgn_id, payheader.pyh_pyhnumber

GO
GRANT EXECUTE ON  [dbo].[d_scroll_payheaders_forviews_sp] TO [public]
GO
