SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_scroll_assignments_sp] (
   @drvyes                 VARCHAR(3)
 , @trcyes                 VARCHAR(3)
 , @caryes                 VARCHAR(3)
 , @loenddate              DATETIME
 , @hienddate              DATETIME
 , @lostartdate            DATETIME
 , @histartdate            DATETIME
 , @company                VARCHAR(8)
 , @fleet                  VARCHAR(8)
 , @division               VARCHAR(8)
 , @terminal               VARCHAR(8)
 , @drvtyp1                VARCHAR(6)
 , @drvtyp2                VARCHAR(6)
 , @drvtyp3                VARCHAR(6)
 , @drvtyp4                VARCHAR(6)
 , @trctyp1                VARCHAR(6)
 , @trctyp2                VARCHAR(6)
 , @trctyp3                VARCHAR(6)
 , @trctyp4                VARCHAR(6)
 , @driver                 VARCHAR(8)
 , @tractor                VARCHAR(8)
 , @acct_typ               CHAR(1)
 , @carrier                VARCHAR(8)
 , @cartyp1                VARCHAR(6)
 , @cartyp2                VARCHAR(6)
 , @cartyp3                VARCHAR(6)
 , @cartyp4                VARCHAR(6)
 , @trlyes                 VARCHAR(3)
 , @trailer                VARCHAR(13)
 , @trltyp1                VARCHAR(6)
 , @trltyp2                VARCHAR(6)
 , @trltyp3                VARCHAR(6)
 , @trltyp4                VARCHAR(6)
 , @lgh_type1              VARCHAR(6)
 , @beg_invoice_bill_date  DATETIME
 , @end_invoice_bill_date  DATETIME
 , @lgh_booked_revtype1    VARCHAR(256)
 , @sch_date1              DATETIME
 , @sch_date2              DATETIME
 , @tpryes                 VARCHAR(3)
 , @tpr_id                 VARCHAR(8)
 , @tpr_type               VARCHAR(12)
 , @p_revtype1             VARCHAR(6)
 , @p_revtype2             VARCHAR(6)
 , @p_revtype3             VARCHAR(6)
 , @p_revtype4             VARCHAR(6)
 , @inv_status             VARCHAR(100)
 , @tprtype1               CHAR(1)
 , @tprtype2               CHAR(1)
 , @tprtype3               CHAR(1)
 , @tprtype4               CHAR(1)
 , @tprtype5               CHAR(1)
 , @tprtype6               CHAR(1)
 , @p_ivh_revtype1         VARCHAR(6)
 , @p_ivh_billto           VARCHAR(8)
 , @G_USERID               VARCHAR(14)
 , @shiftdate              DATETIME    = '1/1/1950'
 , @shiftnumber            VARCHAR(6)  = 'UNK'
 , @resourcetypeonleg      CHAR(1)
 , @payto                  VARCHAR(12)
 , @mpp_teamleader         VARCHAR(6)
 , @profile_owner          VARCHAR(12)
 , @mpp_branch             VARCHAR(12)
 , @trc_branch             VARCHAR(12)
 , @trl_branch             VARCHAR(12)
 , @car_branch             VARCHAR(12)
) AS

/**
 *
 * NAME:
 * dbo.d_scroll_assignments_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for P*S datawindow d_scroll_assignments
 *
 * RETURNS:
 *
 * RESULT SETS:
 * 001 - lgh_number int not null,
 * 002 - asgn_type varchar(6) not null,
 * 003 - asgn_id varchar(13) not null,
 * 004 - asgn_date datetime null,
 * 005 - asgn_enddate datetime null,
 * 006 - cmp_id_start varchar(8) null,
 * 007 - cmp_id_end varchar(8) null,
 * 008 - mov_number int null,
 * 009 - asgn_number int null,
 * 010 - ord_hdrnumber int null,
 * 011 - lgh_startcity int null,
 * 012 - lgh_endcity int null,
 * 013 - ord_number varchar(12) null,
 * 014 - name varchar(64) null,
 * 015 - cmp_name_start varchar(30) null,
 * 016 - cmp_name_end varchar(30) null,
 * 017 - cty_nmstct_start varchar(25) null,
 * 018 - cty_nmstct_end varchar(25) null,
 * 019 - need_paperwork int null,
 * 020 - ivh_revtype1   varchar(6) null,
 * 021 - revtype1_name  varchar(8) null,
 * 022 - lgh_split_flag char(1) null,
 * 023 - trip_description varchar(255) null,
 * 024 - lgh_type1   varchar(6) null,
 * 025 - lgh_type_name  varchar(8) null,
 * 026 - ivh_billdate datetime Null,
 * 027 - ivh_invoicenumber varchar(12) Null,
 * 028 - lgh_booked_revtyep1 varchar(12)
 * 029 - ivh_billto
 * 030 - asgn_controlling
 * 031 - shiftdate datatime
 * 032 - lgh_shiftnumber
 *
 * PARAMETERS:
 * 001 - @drvyes varchar(3),
 * 002 - @trcyes varchar(3),
 * 003 - @caryes varchar(3),
 * 004 - @loenddate datetime,
 * 005 - @hienddate datetime,
 * 006 - @lostartdate datetime,
 * 007 - @histartdate datetime,
 * 008 - @company varchar(8),
 * 009 - @fleet varchar(8),
 * 010 - @division varchar(8),
 * 011 - @terminal varchar(8),
 * 012 - @drvtyp1 varchar(6),
 * 013 - @drvtyp2 varchar(6),
 * 014 - @drvtyp3 varchar(6),
 * 015 - @drvtyp4 varchar(6),
 * 016 - @trctyp1 varchar(6),
 * 017 - @trctyp2 varchar(6),
 * 018 - @trctyp3 varchar(6),
 * 019 - @trctyp4 varchar(6),
 * 020 - @driver varchar(8),
 * 021 - @tractor varchar(8),
 * 022 - @acct_typ char(1),
 * 023 - @carrier varchar(8),
 * 024 - @cartyp1 varchar(6),
 * 025 - @cartyp2 varchar(6),
 * 026 - @cartyp3 varchar(6),
 * 027 - @cartyp4 varchar(6),
 * 028 - @trlyes varchar(3),
 * 029 - @trailer varchar(13),
 * 030 - @trltyp1 varchar(6),
 * 031 - @trltyp2 varchar(6),
 * 032 - @trltyp3 varchar(6),
 * 033 - @trltyp4 varchar(6),
 * 034 - @lgh_type1 varchar(6),
 * 035 - @beg_invoice_bill_date datetime,
 * 036 - @end_invoice_bill_date datetime,
 * 037 - @lgh_booked_revtype1 varchar(12)
 * 038 - @sch_date1 datetime  sch earliest datetime from
 * 039 - @sch_date1 datetime  sch earliest datetime to
 * 040 - @tpryes varchar(3) ??
 * 041 - @tpr_id varchar(8) ??
 * 042 - @tpr_type varchar(12) ??
 * 043 - @revtype1
 * 044 - @revtype2
 * 045 - @revtype3
 * 046 - @revtype4
 * 047 - @inv_status
 * 048 - ?
 * 049 - ?
 * 050 - ?
 * 051 - ?
 * 052 - ?
 * 053 - ?
 * 054 - @p_ivh_revtype1
 * 055 - @p_ivh_billto
 * 056 - @G_USERID varchar(14)   -- PTS 41389 GAP 74
 * 057 - @shiftdate datetime
 * 058 - @shiftnumber varchar(6)
 * 059 - @resourcetypeonleg Char(1)  -- PTS 48237 - DJM - parameter to tell proc to use mpp_types and trc_types from the leg instead of profile.
 *
 * REVISION HISTORY:
 * Orginal: 10/15/97 wsc - to replace the 4 union select in the datawindow
 * pts 2722 MF 5/11/98 removed useless where clauses
 * DPETE PTS 16930 1/20/3 If gi setting invoicemustsettle set to N and asset was on trips tagged do not invoice, the trip come up twice
 * PTS 17873 - 4/14/03 - DJM - Modified parameters to include lgh_type1
 * PTS 16945 - 5/2/03 - BAL - Allow user to filter data by invoice billing date
 * PTS 29160 - 5/23/05 - DPH - Modified parameters to include lgh_booked_revtype1
 * 10/11/2005.01 – PTS29974 - Vince Herman – add ability to use accounting type
 *                 from assetassignment (set at time of move) rather than
 *                 manpowerprofile StlUseLegAcctType
 * LOR   PTS# 30053  added sch earliest dates
 * MRH 31225 3rd party
 * 02/23/2005.01 - PTS30395 - Vince Herman - add logic from 29974 to the tractor side
 * DMC  PTS 32781 - Added RevType and InvStatus restrictions.
 * EMK PTS 36869 - Added required for invoicing check to paperwork count
 * LOR   PTS# 37918  added asgn_controlling - flag for lead/co-drv
 * MDH  PTS# 40119  Fixed comments of parameters, added row level security.
 * JDS  PTS# 41389 GAP 74 - add branch (aka lgh_booked_revtype1 & ord_booked_revtype1)
 * SLM  PTS# 41600 - Allow split trips to be viewed even though no invoice exists and an invoice is required.
 *                   This allows for pay to be computed for completed orders on the trip segment.
 * JSwindell PTS# 43720 - fix 41600 ( run original select if new GI setting is NOT set ) 7-24-2008
 * vjh   pts# 41767  put order number in trip description if it is blank.
 * vjh   PTS# 33665  Added shift number and shift date
 * vjh   PTS# 45500  Added logic to handle paperwork cutoff date
 * vjh   PTS# 45381  Added logic for selection including shift
 * vjh   PTS# 45562 and 44306 Modify StlMustInv logic to handle Cross Docked/Split/Consolidated orders the same.
 *             If StlMustInv=Y then any leg that has a drop for an order must have an invoice for that order to settle the leg.
 *             If SplitMustInv=Y then all orders on a leg must be invoiced to settle the leg.
 *             StlXInvStat excludes invoices from consideration based on the invoice status.
 * 07/20/09.01 PTS47363 - vjh - Added LH functionality
 * SGB PTS# 48667 need to exclude 0 ord_hdrnumbers 08/26/09
 * pmill PTS# 49424 - performance enhancements requested by KAG
 * PTS 48237 - DJM - Added option to search by Driver/Tractor type on the Trip instead of on the Asset Master File.
 * PTS 53466: Rewriting the update statement for bettering the performance and also changing the != to <>
 * PTS 52192: Need to exclude from queue any Carriers that are not yet approved to be paid if GI setting is on.
 * PTS 53273 - SPN - added @acct_typ in three queries where the parameter was missing
 * PTS 52995 - SPN - updating the lgh_booked_revtype1 to UNK where it remained Lgh_Booked_Revtype1
 * 09/23/10.01 PTS52942 - vjh - add SLTMUSTORD to control restriction legs unless all orders on that led are complete.
 * 10/27/2010 PTS 54538 MTC Replaced population of trip description in temp table with a function rather than a loop to concatenate values -- to improve performance.
 * 04/29/2011 PTS 56345 vjh enahnce stlmustord and whole unification theory
 * 05/31/2011 PTS 57093 SPN - #tmp table, RowRestrictByUser Performance issue fixed
 * 07/08/2011 PTS 54402 vjh coowner paytos
 * PTS 59676 - SPN - changed 53273 fixes to check @acct_typ against manpowerprofile/#tmp table instead of assetassignment
 * 12/12/2011 PTS 60549 SPN - RowRestrictByAsgn Performance issue fixed
 * 03/19/2012 PTS 60184 SPN - Addded Restriction @mpp_teamleader
 * 04/03/2012 PTS 62353 SPN - Addded Restriction @profile_owner
 * 4/2012  PTS 60458 2 cols for multi-PH support
 * PTS 63716 SGB Add support for SplitMustInv = 'L' from PTS58060
 * 11/08/2012 PTS 65645 SPN - Added Restriction @mpp_branch, @trc_branch, @trl_branch, @car_branch
 * 10/05/2013 PTS 65394 NQIAO - get ivh_billto, ivh_billdate, etc properaly for consolidates orders 
 **/

SET NOCOUNT ON

DECLARE @first_invoice                       INT
DECLARE @stlmustinv                          CHAR(1)
DECLARE @stlmustord                          CHAR(1)
DECLARE @stlmustinvLH                        CHAR(60)
DECLARE @splitmustinv                        CHAR(1)
DECLARE @split_flag                          CHAR(1)
DECLARE @li_count                            INT
DECLARE @li_mov                              INT
DECLARE @ls_tripdesc                         VARCHAR(255)
DECLARE @ls_ordnumber                        VARCHAR(25)
DECLARE @ls_invstat1                         VARCHAR(60)
DECLARE @ls_invstat2                         VARCHAR(60)
DECLARE @ls_invstat3                         VARCHAR(60)
DECLARE @ls_invstat4                         VARCHAR(60)
DECLARE @paperworkchecklevel                 VARCHAR(6)
DECLARE @paperworkmode                       VARCHAR(3)
DECLARE @revtype4                            VARCHAR(6)
DECLARE @excludemppterminal                  VARCHAR(60)
DECLARE @excludempptype1formttrips           VARCHAR(60)
DECLARE @STLUseLegAcctType                   CHAR(1)
DECLARE @agent                               VARCHAR(3)
DECLARE @ComputeRevenueByTripSegment         CHAR(1)
DECLARE @paperwork_computed_cutoff_datetime  DATETIME
DECLARE @paperwork_GI_cutoff_datetime        DATETIME
DECLARE @paperwork_GI_cutoff_flag            CHAR(1)
DECLARE @paperwork_GI_cutoff_dayofweek       INT
DECLARE @ls_STL_TRS_Include_Shift            CHAR(1)
DECLARE @min_shift_id                        INT,
      @TPRIgnoreStlMustInv char(1)

--BEGIN PTS 57093 SPN
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
DECLARE @rowsecurity char(1)
--END PTS 57093 SPN

--BEGIN PTS 57093 SPN
DECLARE @tmp TABLE
( mpp_id          VARCHAR(8)  NULL
, mpp_lastfirst   VARCHAR(45) NULL
, mpp_type1       VARCHAR(6)  NULL
, mpp_type2       VARCHAR(6)  NULL
, mpp_type3       VARCHAR(6)  NULL
, mpp_type4       VARCHAR(6)  NULL
, mpp_actg_type   CHAR(1)     NULL  --PTS 59676 SPN
, asgn_branch     VARCHAR(12) NULL  --PTS 65645 SPN
)

DECLARE @tmp1 TABLE
( trc_number      VARCHAR(8)  NULL
, trc_owner       VARCHAR(12) NULL
, trc_type1       VARCHAR(6)  NULL
, trc_type2       VARCHAR(6)  NULL
, trc_type3       VARCHAR(6)  NULL
, trc_type4       VARCHAR(6)  NULL
, asgn_branch     VARCHAR(12) NULL  --PTS 65645 SPN
)

DECLARE @tmp2 TABLE
( car_id          VARCHAR(8)  NULL
, car_name        VARCHAR(64) NULL
, asgn_branch     VARCHAR(12) NULL  --PTS 65645 SPN
)

DECLARE @tmp3 TABLE
( trl_id          VARCHAR(13) NULL
, trl_owner       VARCHAR(12) NULL
, asgn_branch     VARCHAR(12) NULL  --PTS 65645 SPN
)

DECLARE @tmp4 TABLE
( tpr_id          VARCHAR(8)  NULL
, tpr_name        VARCHAR(30) NULL
)
--END PTS 57093 SPN

/* Create a temporary table for data return set */
CREATE TABLE #temp_rtn
( lgh_number            INT            NOT NULL
, asgn_type             VARCHAR(6)     NOT NULL
, asgn_id               VARCHAR(13)    NOT NULL
, asgn_date             DATETIME       NULL
, asgn_enddate          DATETIME       NULL
, cmp_id_start          VARCHAR(8)     NULL
, cmp_id_end            VARCHAR(8)     NULL
, mov_number            INT            NULL
, asgn_number           INT            NULL
, ord_hdrnumber         INT            NULL
, lgh_startcity         INT            NULL
, lgh_endcity           INT            NULL
, ord_number            VARCHAR(12)    NULL
, name                  VARCHAR(64)    NULL
, cmp_name_start        VARCHAR(100)   NULL
, cmp_name_end          VARCHAR(100)   NULL
, cty_nmstct_start      VARCHAR(25)    NULL
, cty_nmstct_end        VARCHAR(25)    NULL
, need_paperwork        INT            NULL
, ivh_revtype1          VARCHAR(6)     NULL
, revtype1_name         VARCHAR(8)     NULL
, lgh_split_flag        CHAR(1)        NULL
, trip_description      VARCHAR(255)   NULL
, lgh_type1             VARCHAR(6)     NULL
, lgh_type_name         VARCHAR(8)     NULL
, ivh_billdate          DATETIME       NULL
, ivh_invoicenumber     VARCHAR(12)    NULL
, lgh_booked_revtype1   VARCHAR(20)    NULL
, ivh_billto            VARCHAR(8)     NULL
, asgn_controlling      VARCHAR(1)     NULL
, lgh_shiftdate         DATETIME       NULL
, lgh_shiftnumber       VARCHAR(6)     NULL
, shift_ss_id           INT            NULL
, stp_schdtearliest     DATETIME       NULL
, ord_route             VARCHAR(18)    NULL
, Cost                  MONEY          NULL
, ord_revtype1          VARCHAR(6)     NULL
, ord_revtype1_name     VARCHAR(20)    NULL
, ord_revtype2          VARCHAR(6)     NULL
, ord_revtype2_name     VARCHAR(20)    NULL
, ord_revtype3          VARCHAR(6)     NULL
, ord_revtype3_name     VARCHAR(20)    NULL
, ord_revtype4          VARCHAR(6)     NULL
, ord_revtype4_name     VARCHAR(20)    NULL
, lgh_type2             VARCHAR(6)     NULL
, lgh_type3             VARCHAR(6)     NULL
, lgh_type4             VARCHAR(6)     NULL
)

CREATE TABLE #temp_rtn1
( lgh_number            INT            NOT NULL
, asgn_type             VARCHAR(6)     NOT NULL
, asgn_id               VARCHAR(13)    NOT NULL
, asgn_date             DATETIME       NULL
, asgn_enddate          DATETIME       NULL
, cmp_id_start          VARCHAR(8)     NULL
, cmp_id_end            VARCHAR(8)     NULL
, mov_number            INT            NULL
, asgn_number           INT            NULL
, ord_hdrnumber         INT            NULL
, lgh_startcity         INT            NULL
, lgh_endcity           INT            NULL
, ord_number            VARCHAR(12)    NULL
, name                  VARCHAR(64)    NULL
, cmp_name_start        VARCHAR(100)   NULL
, cmp_name_end          VARCHAR(100)   NULL
, cty_nmstct_start      VARCHAR(25)    NULL
, cty_nmstct_end        VARCHAR(25)    NULL
, need_paperwork        INT            NULL
, ivh_revtype1          VARCHAR(6)     NULL
, revtype1_name         VARCHAR(8)     NULL
, lgh_split_flag        CHAR(1)        NULL
, trip_description      VARCHAR(255)   NULL
, lgh_type1             VARCHAR(6)     NULL
, lgh_type_name         VARCHAR(8)     NULL
, ivh_billdate          DATETIME       NULL
, ivh_invoicenumber     VARCHAR(12)    NULL
, lgh_booked_revtyep1   VARCHAR(20)    NULL
, ivh_billto            VARCHAR(8)     NULL
, asgn_controlling      VARCHAR(1)     NULL
, lgh_shiftdate         DATETIME       NULL
, lgh_shiftnumber       VARCHAR(6)     NULL
, shift_ss_id           INT            NULL
, stp_schdtearliest     DATETIME       NULL
, ord_route             VARCHAR(18)    NULL
, Cost                  MONEY          NULL
, ord_revtype1          VARCHAR(6)     NULL
, ord_revtype1_name     VARCHAR(20)    NULL
, ord_revtype2          VARCHAR(6)     NULL
, ord_revtype2_name     VARCHAR(20)    NULL
, ord_revtype3          VARCHAR(6)     NULL
, ord_revtype3_name     VARCHAR(20)    NULL
, ord_revtype4          VARCHAR(6)     NULL
, ord_revtype4_name     VARCHAR(20)    NULL
, lgh_type2             VARCHAR(6)     NULL
, lgh_type3             VARCHAR(6)     NULL
, lgh_type4             VARCHAR(6)     NULL
)

CREATE TABLE #temp_pwk
( lgh_number            INT            NULL
, ord_hdrnumber         INT            NULL
, req_cnt               INT            NULL
, rec_cnt               INT            NULL
, ord_billto            VARCHAR(8)     NULL
)

--vjh PTS 45562
CREATE TABLE #temp_Orders
( lgh_number            INT            NULL
, ord_hdrnumber         INT            NULL
, Inv_OK_Flag           CHAR(1)        NULL
, Ord_OK_Flag           CHAR(1)        NULL
, split_flag         char(1)        NULL    -- PTS 63716 SGB Add support for SplitMustInv = 'L' from PTS58060

)

SELECT @rowsecurity = gi_string1
  FROM generalinfo
 WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y'
   INSERT INTO @tbl_restrictedbyuser
   SELECT rowsec_rsrv_id
     FROM RowRestrictValidAssignments_orderheader_fn()
ELSE
   INSERT @tbl_restrictedbyuser (rowsec_rsrv_id)
   SELECT 0

If @drvyes <> 'XXX'
   INSERT INTO @tmp
   SELECT DISTINCT
          mpp_id
        , mpp_lastfirst
        , mpp_type1
        , mpp_type2
        , mpp_type3
        , mpp_type4
        , mpp_actg_type
        , mpp_branch    --PTS 65645 SPN
     FROM manpowerprofile
     JOIN RowRestrictValidAssignments_manpowerprofile_fn() rsva ON manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                                OR rsva.rowsec_rsrv_id = 0
    WHERE (@driver   = mpp_id OR @driver   = 'UNKNOWN')
      AND (@company  = 'UNK'  OR @company  = mpp_company)
      AND (@fleet    = 'UNK'  OR @fleet    = mpp_fleet)
      AND (@division = 'UNK'  OR @division = mpp_division)
      AND (@terminal = 'UNK'  OR @terminal = mpp_terminal)
      AND (@mpp_teamleader = 'UNK' OR @mpp_teamleader = mpp_teamleader)
      AND (@profile_owner = 'UNK' OR @profile_owner = mpp_payto)

If @trcyes <> 'XXX'
   INSERT INTO @tmp1
   SELECT DISTINCT
          trc_number
        , trc_owner
        , trc_type1
        , trc_type2
        , trc_type3
        , trc_type4
        , trc_branch   --PTS 65645 SPN
     FROM tractorprofile
     JOIN RowRestrictValidAssignments_tractorprofile_fn() rsva ON tractorprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                               OR rsva.rowsec_rsrv_id = 0
    WHERE ( @tractor = trc_number
          OR (@tractor = 'UNKNOWN' and @payto = 'UNKNOWN')
          OR (@payto <> 'UNKNOWN'  and trc_number IN (SELECT trc_number
                                                        FROM tractorprofile
                                                       WHERE trc_owner = @payto or trc_owner2 = @payto
                                                      )
             )
          )
      AND ( (@acct_typ = 'X' AND trc_actg_type IN('A', 'P')) OR (@acct_typ = trc_actg_type) )
      AND (@company  = 'UNK' OR @company  = trc_company)
      AND (@fleet    = 'UNK' OR @fleet    = trc_fleet)
      AND (@division = 'UNK' OR @division = trc_division)
      AND (@terminal = 'UNK' OR @terminal = trc_terminal)
      AND (@profile_owner = 'UNK' OR @profile_owner = trc_owner)

If @caryes <> 'XXX'
   INSERT INTO @tmp2
   SELECT DISTINCT
          car_id
        , car_name
        , car_branch   --PTS 65645 SPN
     FROM carrier
     JOIN RowRestrictValidAssignments_carrier_fn() rsva ON carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                        OR rsva.rowsec_rsrv_id = 0
    WHERE (@carrier = car_id OR @carrier = 'UNKNOWN')
      AND ( (@acct_typ = 'X' AND car_actg_type IN('A', 'P')) OR (@acct_typ = car_actg_type) )
      AND (@cartyp1 = 'UNK'  OR @cartyp1 = car_type1)
      AND (@cartyp2 = 'UNK'  OR @cartyp2 = car_type2)
      AND (@cartyp3 = 'UNK'  OR @cartyp3 = car_type3)
      AND (@cartyp4 = 'UNK'  OR @cartyp4 = car_type4)
      AND (@profile_owner = 'UNK' OR @profile_owner = pto_id)

If @trlyes <> 'XXX'
   INSERT INTO @tmp3
   SELECT DISTINCT
          trl_id
        , trl_owner
        , trl_branch   --PTS 65645 SPN
     FROM trailerprofile
     JOIN RowRestrictValidAssignments_trailerprofile_fn() rsva ON trailerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                               OR rsva.rowsec_rsrv_id = 0
    WHERE (@trailer  = trl_id OR @trailer  = 'UNKNOWN')
      AND ( (@acct_typ = 'X' AND trl_actg_type IN('A', 'P')) OR (@acct_typ = trl_actg_type) )
      AND (@company  = 'UNK'  OR @company  = trl_company)
      AND (@fleet    = 'UNK'  OR @fleet    = trl_fleet)
      AND (@division = 'UNK'  OR @division = trl_division)
      AND (@terminal = 'UNK'  OR @terminal = trl_terminal)
      AND (@trltyp1  = 'UNK'  OR @trltyp1  = trl_type1)
      AND (@trltyp2  = 'UNK'  OR @trltyp2  = trl_type2)
      AND (@trltyp3  = 'UNK'  OR @trltyp3  = trl_type3)
      AND (@trltyp4  = 'UNK'  OR @trltyp4  = trl_type4)
      AND (@profile_owner = 'UNK' OR @profile_owner = trl_owner)

--vjh 45500 get pieces used for paperwork cutoff
select @paperwork_GI_cutoff_flag = upper(left(gi_string1,1))
     , @paperwork_GI_cutoff_dayofweek = gi_integer1
     , @paperwork_GI_cutoff_datetime = gi_date1
  from generalinfo
 where gi_name = 'PaperWorkCutOffDate'
if @paperwork_GI_cutoff_flag is null select @paperwork_GI_cutoff_flag = 'N'
if @paperwork_GI_cutoff_flag = 'N'
   begin
      select @paperwork_computed_cutoff_datetime = '2049-12-31 23:59'
   end
else
   begin
      -- compute the paperwork cutoff datetime
      -- datetime from GI, plus the number of days from then to now
      -- so @computed_cutoff_datetime holds today's date with the time from the GI
      select @paperwork_computed_cutoff_datetime = dateadd(day,datediff(day,@paperwork_GI_cutoff_datetime,getdate()),@paperwork_GI_cutoff_datetime)
      -- now subtract the dayofweek of today and then add the dayof week from GI
      select @paperwork_computed_cutoff_datetime = dateadd(day,@paperwork_GI_cutoff_dayofweek - datepart(dw,getdate()),@paperwork_computed_cutoff_datetime)
   end

--PTS 41600 SLM 6/2/2008
SELECT @ComputeRevenueByTripSegment = Upper(gi_string1) from generalinfo where Upper(gi_name) = 'COMPUTEREVENUEBYTRIPSEGMENT'
--vjh 45562
select @ls_invstat1 = gi_string1
     , @ls_invstat2 = gi_string2
     , @ls_invstat3 = gi_string3
     , @ls_invstat4 = gi_string4
  from generalinfo
 where gi_name = 'StlXInvStat'

select @ls_invstat1 = IsNull(@ls_invstat1,'')
select @ls_invstat2 = IsNull(@ls_invstat2,@ls_invstat1)
select @ls_invstat3 = IsNull(@ls_invstat3,@ls_invstat1)
select @ls_invstat4 = IsNull(@ls_invstat4,@ls_invstat1)

select @splitmustinv = substring(upper(gi_string1),1,1) from generalinfo where gi_name = 'SPLITMUSTINV'

select @stlmustinv =  substring(upper(gi_string1),1,1)
     , @stlmustinvLH =  upper(gi_string2)
  from generalinfo
 where gi_name = 'STLMUSTINV'

select @stlmustord =  substring(upper(gi_string1),1,1) from generalinfo where gi_name = 'STLMUSTORD'  --vjh 52942

-- LOR   PTS# 60638
select @TPRIgnoreStlMustInv = 'N'
select @TPRIgnoreStlMustInv = substring(upper(gi_string1),1,1) from generalinfo where gi_name = 'TPRIgnoreStlMustInv'
If @TPRIgnoreStlMustInv = 'Y' and @stlmustinv = 'Y' and @tpryes <> 'XXX' set @stlmustinv = 'N'
-- LOR

if @stlmustinvLH is null or @stlmustinvLH <> 'ALL' set @stlmustinvLH = 'LH'
--vjh 45381
SELECT @ls_STL_TRS_Include_Shift = upper(left(gi_string1,1)) FROM generalinfo WHERE gi_name = 'STL_TRS_Include_Shift'
if @ls_STL_TRS_Include_Shift is null select @ls_STL_TRS_Include_Shift = 'N'

---------------------------------------------------------------------------------------------------------------
-- PTS 41389 GAP 74 Start
IF @lgh_booked_revtype1 is NULL or @lgh_booked_revtype1 = '' or @lgh_booked_revtype1 = 'UNK'
   begin
      SELECT @lgh_booked_revtype1 = 'UNKNOWN'
   end

SELECT @lgh_booked_revtype1= ',' + LTRIM(RTRIM(ISNULL(@lgh_booked_revtype1, '')))  + ','
-- PTS 41389 GAP 74 end
---------------------------------------------------------------------------------------------------------------

If exists (select * from generalinfo where gi_name = 'TRSExcludeNonPayableTrips' and gi_string1 = 'Y')
   update assetassignment
      set pyd_status = 'PPD'
    where asgn_status = 'CMP'
      and pyd_status = 'NPD'
      and not exists (select *
                        from stops
                       where stops.lgh_number = assetassignment.lgh_number
                         and IsNull(stops.stp_paylegpt,'N') = 'Y'
                     )

-- vjh 30395 move here so that all resource types can use it
select @STLUseLegAcctType = 'N'
If exists (select * from generalinfo where gi_name = 'STLUseLegAcctType' and IsNull(gi_string1,'') <> '')
begin
   select @STLUseLegAcctType = upper(left(gi_string1,1)) from generalinfo where gi_name = 'STLUseLegAcctType'
end

-- PTS 3223781 - DJM
SELECT @inv_status = ',' + LTRIM(RTRIM(ISNULL(@inv_status, 'UNK'))) + ','


--BEGIN DRIVERS
IF @drvyes <> 'XXX'
BEGIN
   If @driver = 'UNKNOWN'
   BEGIN
      -- JD 28117 Exclude drivers that belong to the terminal specified by the gi setting TRSExcludeDrvTerminal
      If exists (select * from generalinfo where gi_name = 'TRSExcludeDrvTerminal' and IsNull(gi_string1,'') <> '')
      begin
         select @excludemppterminal = gi_string1 from generalinfo where gi_name = 'TRSExcludeDrvTerminal'
         select @excludemppterminal = ',' +@excludemppterminal + ','
         UPDATE assetassignment
            SET pyd_status = 'PPD'
           FROM manpowerprofile mpp
          WHERE asgn_type = 'DRV'
            AND mpp.mpp_id = asgn_id
            AND charindex (mpp.mpp_terminal,@excludemppterminal) > 0
            AND asgn_status = 'CMP'
            AND pyd_status = 'NPD'
            AND asgn_date BETWEEN @lostartdate AND @histartdate
            AND asgn_enddate BETWEEN @loenddate AND @hienddate

      end
      -- end 28117 JD

      -- JD 28169 Exclude drivers that belong to the mpp_type1 specified by string1 and that have fully MT trips (i.e no loaded stops on the trip seg)
      If exists (select * from generalinfo where gi_name = 'TRSExcludeDrvType1WithMTTrips' and IsNull(gi_string1,'') <> '')
      begin
         select @excludempptype1formttrips= gi_string1 from generalinfo where gi_name = 'TRSExcludeDrvType1WithMTTrips'
         select @excludempptype1formttrips= ',' +@excludempptype1formttrips + ','
         UPDATE assetassignment
            SET pyd_status = 'PPD'
           FROM manpowerprofile mpp
          WHERE asgn_type = 'DRV'
            AND mpp.mpp_id = asgn_id
            AND charindex (mpp.mpp_type1,@excludempptype1formttrips) > 0
            AND asgn_status = 'CMP'
            AND pyd_status = 'NPD'
            AND asgn_date BETWEEN @lostartdate AND @histartdate
            AND asgn_enddate BETWEEN @loenddate AND @hienddate
            AND NOT EXISTS (select *
                              from stops
                             where stops.lgh_number = assetassignment.lgh_number
                               and stops.stp_loadstatus = 'LD'
                           )
      end

      --  Exclude drivers that belong to the mpp_type1 specified by string1 and that have all intracity stops on the trip segment
      select @excludempptype1formttrips = null
      If exists (select * from generalinfo where gi_name = 'TRSExcludeDrvType1WithICTrips' and IsNull(gi_string1,'') <> '')
      begin
         select @excludempptype1formttrips= gi_string1 from generalinfo where gi_name = 'TRSExcludeDrvType1WithICTrips'
         select @excludempptype1formttrips= ',' +@excludempptype1formttrips + ','

         UPDATE assetassignment
            SET pyd_status = 'PPD'
           FROM manpowerprofile mpp
          WHERE asgn_type = 'DRV'
            AND mpp.mpp_id = asgn_id
            AND charindex (mpp.mpp_type1,@excludempptype1formttrips) > 0
            AND asgn_status = 'CMP'
            AND pyd_status = 'NPD'
            AND asgn_date BETWEEN @lostartdate AND @histartdate
            AND asgn_enddate BETWEEN @loenddate AND @hienddate
            AND lgh_number in (select c.lgh_number
                                 from stops c
                                where c.lgh_number = assetassignment.lgh_number
                                  and exists (select *
                                                from stops d
                                                   , stops e
                                               where d.lgh_number = c.lgh_number
                                                 and d.lgh_number = e.lgh_number
                                                 and d.stp_mfh_sequence = 1
                                                 and e.stp_mfh_sequence = 2
                                                 and e.stp_loadstatus = 'MT'
                                                 and d.stp_city = e.stp_city
                                             )
                               group by c.lgh_number
                               having count(*) = 2
                              )

      end
   END


   IF @STLUseLegAcctType = 'Y'
      BEGIN
         IF @ls_STL_TRS_Include_Shift = 'N'
            BEGIN
            --***(1a)
               INSERT INTO #temp_rtn
               SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                      a.mov_number, a.asgn_number, 0, 0, 0, '', mpp_lastfirst,
                      '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                      null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                      l.lgh_shiftdate,
                      l.lgh_shiftnumber,
                      l.shift_ss_id,
                      -- PTS 47740 added 11 new columns <<start>>
                      null, null, null, null, null, null, null, null, null, null, null
                      -- PTS 47740 <<end>>
                      , null, null, null -- PTS 52192
                 FROM assetassignment a
               INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                     AND a.asgn_type = 'DRV'
                    , @tmp #tmp
                WHERE a.asgn_type = 'DRV'
                  AND a.asgn_id = mpp_id
                  AND a.asgn_status = 'CMP'
                  AND pyd_status = 'NPD'
                  AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                  AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
                  AND ( (@acct_typ = 'X' AND a.actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
                  AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
                        then l.mpp_type1
                        else #tmp.mpp_type1
                        end))
                  AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
                        then l.mpp_type2
                        else #tmp.mpp_type2
                        end))
                  AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
                        then l.mpp_type3
                        else #tmp.mpp_type3
                        end))
                  AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
                        then l.mpp_type4
                        else #tmp.mpp_type4
                        end))
                  --BEGIN PTS 65645 SPN
                  AND ( @mpp_branch = 'UNKNOWN'
                     OR @mpp_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END)
                      )
                  --END PTS 65645 SPN
            END
         ELSE
            BEGIN
            --***(1b)
               --vjh 45381 new insert for join to shiftschedules table and restrictions based on that.
               INSERT INTO #temp_rtn
               SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                      a.mov_number, a.asgn_number, 0, 0, 0, '', mpp_lastfirst,
                      '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                      null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                      l.lgh_shiftdate,
                      l.lgh_shiftnumber,
                      l.shift_ss_id,
                      -- PTS 47740 added 11 new columns <<start>>
                      null, null, null, null, null, null, null, null, null, null, null
                      -- PTS 47740 <<end>>
                      , null, null, null -- PTS 52192
                 FROM assetassignment a
               INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                     AND a.asgn_type = 'DRV'
               LEFT JOIN shiftschedules s ON l.shift_sS_id = s.ss_id
                    , @tmp #tmp
                WHERE a.asgn_type = 'DRV'
                  AND a.asgn_id = #tmp.mpp_id
                  AND a.asgn_status = 'CMP'
                  AND pyd_status = 'NPD'
                  AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                  AND s.ss_starttime BETWEEN @loenddate AND @hienddate
                  AND ( (@acct_typ = 'X' AND a.actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
                  AND ( @drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y' then l.mpp_type1 else #tmp.mpp_type1 end) )
                  AND ( @drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y' then l.mpp_type2 else #tmp.mpp_type2 end) )
                  AND ( @drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y' then l.mpp_type3 else #tmp.mpp_type3 end) )
                  AND ( @drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y' then l.mpp_type4 else #tmp.mpp_type4 end) )
                  --BEGIN PTS 65645 SPN
                  AND ( @mpp_branch = 'UNKNOWN'
                     OR @mpp_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END)
                      )
                  --END PTS 65645 SPN

               --vjh 45381 walk through each shift and grab any trips that fell outside of the date range but have same shift
               SELECT @min_shift_id = min(shift_ss_id) FROM #temp_rtn WHERE shift_ss_id is not null and shift_ss_id > 0 and asgn_type = 'DRV'
               WHILE @min_shift_id is not null
               BEGIN
                  INSERT INTO #temp_rtn
                  SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                         a.mov_number, a.asgn_number, 0, 0, 0, '', mpp_lastfirst,
                         '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                         null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                         l.lgh_shiftdate,
                         l.lgh_shiftnumber,
                         l.shift_ss_id,
                         -- PTS 47740 added 11 new columns <<start>>
                         null, null, null, null, null, null, null, null, null, null, null
                         -- PTS 47740 <<end>>
                         , null, null, null -- PTS 52192
                    FROM assetassignment a
                  INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                        AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                        AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                        AND a.asgn_type = 'DRV'
                       , @tmp #tmp
                   WHERE a.asgn_type = 'DRV'
                     AND a.asgn_id = mpp_id
                     AND a.asgn_status = 'CMP'
                     AND pyd_status = 'NPD'
                     AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                     AND shift_ss_id = @min_shift_id
                     AND l.lgh_number not in (SELECT lgh_number FROM #temp_rtn WHERE shift_ss_id = @min_shift_id)
                     AND ( (@acct_typ = 'X' AND a.actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
                     AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y' then l.mpp_type1 else #tmp.mpp_type1 end) )
                     AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y' then l.mpp_type2 else #tmp.mpp_type2 end) )
                     AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y' then l.mpp_type3 else #tmp.mpp_type3 end) )
                     AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y' then l.mpp_type4 else #tmp.mpp_type4 end) )
                     --BEGIN PTS 65645 SPN
                     AND ( @mpp_branch = 'UNKNOWN'
                        OR @mpp_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END)
                         )
                     --END PTS 65645 SPN

                  SELECT @min_shift_id = min(shift_ss_id) FROM #temp_rtn WHERE shift_ss_id is not null and shift_ss_id > @min_shift_id and asgn_type = 'DRV'
               END --LOOP
            END
      END
   ELSE
      BEGIN
         IF @ls_STL_TRS_Include_Shift = 'N'
            BEGIN
            --***(2a)
               INSERT INTO #temp_rtn
               SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                      a.mov_number, a.asgn_number, 0, 0, 0, '', mpp_lastfirst,
                      '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                      null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                      l.lgh_shiftdate,
                      l.lgh_shiftnumber,
                      l.shift_ss_id,
                      -- PTS 47740 added 11 new columns <<start>>
                      null, null, null, null, null, null, null, null, null, null, null
                      -- PTS 47740 <<end>>
                      , null, null, null -- PTS 52192
                 FROM assetassignment a
               INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                     AND a.asgn_type = 'DRV'
                    , @tmp #tmp
                WHERE a.asgn_type = 'DRV'
                  AND a.asgn_id = mpp_id
                  AND a.asgn_status = 'CMP'
                  AND pyd_status = 'NPD'
                  AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                  AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
                  AND ( (@acct_typ = 'X' AND #tmp.mpp_actg_type IN('A', 'P')) OR (@acct_typ = #tmp.mpp_actg_type) )
                  AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y' then l.mpp_type1 else #tmp.mpp_type1 end) )
                  AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y' then l.mpp_type2 else #tmp.mpp_type2 end) )
                  AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y' then l.mpp_type3 else #tmp.mpp_type3 end) )
                  AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y' then l.mpp_type4 else #tmp.mpp_type4 end) )
                  --BEGIN PTS 65645 SPN
                  AND ( @mpp_branch = 'UNKNOWN'
                     OR @mpp_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END)
                      )
                  --END PTS 65645 SPN
            END
         ELSE
            BEGIN
            --***(2b)
               --vjh 45381 new insert for join to shiftschedules table and restrictions based on that.
               INSERT INTO #temp_rtn
               SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                      a.mov_number, a.asgn_number, 0, 0, 0, '', mpp_lastfirst,
                      '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                      null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                      l.lgh_shiftdate,
                      l.lgh_shiftnumber,
                      l.shift_ss_id,
                      -- PTS 47740 added 11 new columns <<start>>
                      null, null, null, null, null, null, null, null, null, null, null
                      -- PTS 47740 <<end>>
                      , null, null, null -- PTS 52192
                 FROM assetassignment a
               INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                     AND a.asgn_type = 'DRV'
               LEFT JOIN shiftschedules s ON l.shift_Ss_id = s.ss_id
                    , @tmp #tmp
                WHERE a.asgn_type = 'DRV'
                  AND a.asgn_id = #tmp.mpp_id
                  AND a.asgn_status = 'CMP'
                  AND pyd_status = 'NPD'
                  AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                  AND s.ss_starttime BETWEEN @loenddate AND @hienddate
                  AND ( (@acct_typ = 'X' AND #tmp.mpp_actg_type IN('A', 'P')) OR (@acct_typ = #tmp.mpp_actg_type) )
                  AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y' then l.mpp_type1 else #tmp.mpp_type1 end) )
                  AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y' then l.mpp_type2 else #tmp.mpp_type2 end) )
                  AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y' then l.mpp_type3 else #tmp.mpp_type3 end) )
                  AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y' then l.mpp_type4 else #tmp.mpp_type4 end) )
                  --BEGIN PTS 65645 SPN
                  AND ( @mpp_branch = 'UNKNOWN'
                     OR @mpp_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END)
                      )
                  --END PTS 65645 SPN

               --vjh 45381 walk through each shift and grab any trips that fell outside of the date range but have same shift
               SELECT @min_shift_id = min(shift_ss_id) FROM #temp_rtn WHERE shift_ss_id is not null and shift_ss_id > 0 and asgn_type = 'DRV'
               WHILE @min_shift_id is not null
               BEGIN
                  INSERT INTO #temp_rtn
                  SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                         a.mov_number, a.asgn_number, 0, 0, 0, '', mpp_lastfirst,
                         '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                         null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                         l.lgh_shiftdate,
                         l.lgh_shiftnumber,
                         l.shift_ss_id,
                         -- PTS 47740 added 11 new columns <<start>>
                         null, null, null, null, null, null, null, null, null, null, null
                         -- PTS 47740 <<end>>
                         , null, null, null -- PTS 52192
                    FROM assetassignment a
                  INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                        AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                        AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                        AND a.asgn_type = 'DRV'
                       , @tmp #tmp
                   WHERE a.asgn_type = 'DRV'
                     AND a.asgn_id = mpp_id
                     AND a.asgn_status = 'CMP'
                     AND pyd_status = 'NPD'
                     AND shift_ss_id = @min_shift_id
                     AND l.lgh_number not in (SELECT lgh_number FROM #temp_rtn WHERE shift_ss_id = @min_shift_id)
                     AND ( (@acct_typ = 'X' AND #tmp.mpp_actg_type IN('A', 'P')) OR (@acct_typ = #tmp.mpp_actg_type) )
                     AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y' then l.mpp_type1 else #tmp.mpp_type1 end) )
                     AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y' then l.mpp_type2 else #tmp.mpp_type2 end) )
                     AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y' then l.mpp_type3 else #tmp.mpp_type3 end) )
                     AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y' then l.mpp_type4 else #tmp.mpp_type4 end) )
                     --BEGIN PTS 65645 SPN
                     AND ( @mpp_branch = 'UNKNOWN'
                        OR @mpp_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END)
                         )
                     --END PTS 65645 SPN

                  SELECT @min_shift_id = min(shift_ss_id) FROM #temp_rtn WHERE shift_ss_id is not null and shift_ss_id > @min_shift_id and asgn_type = 'DRV'
               END  --LOOP
            END
      END
END
--END DRIVERS


--BEGIN TRACTORS
IF @trcyes <> 'XXX'
BEGIN
   -- vjh 30395 add logic for using asset asignment accounting type
   If @STLUseLegAcctType = 'Y'
      BEGIN
         IF @ls_STL_TRS_Include_Shift = 'N'
            BEGIN
            --***(1a)
               INSERT INTO #temp_rtn
               SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                      a.mov_number, a.asgn_number, 0, 0, 0, '', trc_owner,
                      '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                      null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                      l.lgh_shiftdate,
                      l.lgh_shiftnumber,
                      l.shift_ss_id,
                      -- PTS 47740 added 11 new columns <<start>>
                      null, null, null, null, null, null, null, null, null, null, null
                      -- PTS 47740 <<end>>
                      , null, null, null -- PTS 52192
                 FROM assetassignment a
               INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                     AND a.asgn_type = 'TRC'
                    , @tmp1 #tmp1
                WHERE a.asgn_type = 'TRC'
                  AND a.asgn_id = trc_number
                  AND a.asgn_status = 'CMP'
                  AND pyd_status = 'NPD'
                  AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                  AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
                  AND ( (@acct_typ = 'X' AND actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
                  AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y' then l.trc_type1 else #tmp1.trc_type1 end) )
                  AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y' then l.trc_type2 else #tmp1.trc_type2 end) )
                  AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y' then l.trc_type3 else #tmp1.trc_type3 end) )
                  AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y' then l.trc_type4 else #tmp1.trc_type4 end) )
                  --BEGIN PTS 65645 SPN
                  AND ( @trc_branch = 'UNKNOWN'
                     OR @trc_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END)
                      )
                  --END PTS 65645 SPN
            END
         ELSE
            BEGIN
            --***(1b)
               INSERT INTO #temp_rtn
               SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                      a.mov_number, a.asgn_number, 0, 0, 0, '', trc_owner,
                      '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                      null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                      l.lgh_shiftdate,
                      l.lgh_shiftnumber,
                      l.shift_ss_id,
                      -- PTS 47740 added 11 new columns <<start>>
                      null, null, null, null, null, null, null, null, null, null, null
                      -- PTS 47740 <<end>>
                      , null, null, null -- PTS 52192
                 FROM assetassignment a
               INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                     AND a.asgn_type = 'TRC'
               LEFT JOIN shiftschedules s ON l.shift_sS_id = s.ss_id
                    , @tmp1 #tmp1
                WHERE a.asgn_type = 'TRC'
                  AND a.asgn_id = #tmp1.trc_number
                  AND a.asgn_status = 'CMP'
                  AND pyd_status = 'NPD'
                  AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                  AND s.ss_starttime BETWEEN @loenddate AND @hienddate
                  AND ( (@acct_typ = 'X' AND actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
                  AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y' then l.trc_type1 else #tmp1.trc_type1 end) )
                  AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y' then l.trc_type2 else #tmp1.trc_type2 end) )
                  AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y' then l.trc_type3 else #tmp1.trc_type3 end) )
                  AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y' then l.trc_type4 else #tmp1.trc_type4 end) )
                  --BEGIN PTS 65645 SPN
                  AND ( @trc_branch = 'UNKNOWN'
                     OR @trc_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END)
                      )
                  --END PTS 65645 SPN

               SELECT @min_shift_id = min(shift_ss_id) FROM #temp_rtn WHERE shift_ss_id is not null and shift_ss_id > 0 and asgn_type = 'TRC'
               WHILE @min_shift_id is not null
               BEGIN
                  INSERT INTO #temp_rtn
                  SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                         a.mov_number, a.asgn_number, 0, 0, 0, '', trc_owner,
                         '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                         null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                         l.lgh_shiftdate,
                         l.lgh_shiftnumber,
                         l.shift_ss_id,
                         -- PTS 47740 added 11 new columns <<start>>
                         null, null, null, null, null, null, null, null, null, null, null
                         -- PTS 47740 <<end>>
                         , null, null, null -- PTS 52192
                    FROM assetassignment a
                  INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                        AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                        AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                        AND a.asgn_type = 'TRC'
                       , @tmp1 #tmp1
                   WHERE a.asgn_type = 'TRC'
                     AND a.asgn_id = trc_number
                     AND a.asgn_status = 'CMP'
                     AND pyd_status = 'NPD'
                     AND shift_ss_id = @min_shift_id
                     AND l.lgh_number not in (SELECT lgh_number FROM #temp_rtn WHERE shift_ss_id = @min_shift_id)
                     AND ( (@acct_typ = 'X' AND actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
                     AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y' then l.trc_type1 else #tmp1.trc_type1 end) )
                     AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y' then l.trc_type2 else #tmp1.trc_type2 end) )
                     AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y' then l.trc_type3 else #tmp1.trc_type3 end) )
                     AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y' then l.trc_type4 else #tmp1.trc_type4 end) )
                     --BEGIN PTS 65645 SPN
                     AND ( @trc_branch = 'UNKNOWN'
                        OR @trc_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END)
                         )
                     --END PTS 65645 SPN

                  SELECT @min_shift_id = min(shift_ss_id) FROM #temp_rtn WHERE shift_ss_id is not null and shift_ss_id > @min_shift_id and asgn_type = 'TRC'
               END --LOOP
            END
      END
   ELSE
      BEGIN
         IF @ls_STL_TRS_Include_Shift = 'N'
            BEGIN
            --***(2a)
               INSERT INTO #temp_rtn
               SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                      a.mov_number, a.asgn_number, 0, 0, 0, '', trc_owner,
                      '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                      null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                      l.lgh_shiftdate,
                      l.lgh_shiftnumber,
                      l.shift_ss_id,
                      -- PTS 47740 added 11 new columns <<start>>
                      null, null, null, null, null, null, null, null, null, null, null
                      -- PTS 47740 <<end>>
                      , null, null, null -- PTS 52192
                 FROM assetassignment a
               INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                     AND a.asgn_type = 'TRC'
                    , @tmp1 #tmp1
                WHERE a.asgn_type = 'TRC'
                  AND a.asgn_id = trc_number
                  AND a.asgn_status = 'CMP'
                  AND pyd_status = 'NPD'
                  AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                  AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
                  AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y' then l.trc_type1 else #tmp1.trc_type1 end) )
                  AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y' then l.trc_type2 else #tmp1.trc_type2 end) )
                  AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y' then l.trc_type3 else #tmp1.trc_type3 end) )
                  AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y' then l.trc_type4 else #tmp1.trc_type4 end) )
                  --BEGIN PTS 65645 SPN
                  AND ( @trc_branch = 'UNKNOWN'
                     OR @trc_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END)
                      )
                  --END PTS 65645 SPN
            END
         ELSE
            BEGIN
            --***(2b)
               INSERT INTO #temp_rtn
               SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                      a.mov_number, a.asgn_number, 0, 0, 0, '', trc_owner,
                      '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                      null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                      l.lgh_shiftdate,
                      l.lgh_shiftnumber,
                      l.shift_ss_id,
                      -- PTS 47740 added 11 new columns <<start>>
                      null, null, null, null, null, null, null, null, null, null, null
                      -- PTS 47740 <<end>>
                      , null, null, null -- PTS 52192
                 FROM assetassignment a
               INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                     AND a.asgn_type = 'TRC'
               LEFT JOIN shiftschedules s ON l.shift_sS_id = s.ss_id
                    , @tmp1 #tmp1
                WHERE a.asgn_type = 'TRC'
                  AND a.asgn_id = #tmp1.trc_number
                  AND a.asgn_status = 'CMP'
                  AND pyd_status = 'NPD'
                  AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                  AND s.ss_starttime BETWEEN @loenddate AND @hienddate
                  AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y' then l.trc_type1 else #tmp1.trc_type1 end) )
                  AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y' then l.trc_type2 else #tmp1.trc_type2 end) )
                  AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y' then l.trc_type3 else #tmp1.trc_type3 end) )
                  AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y' then l.trc_type4 else #tmp1.trc_type4 end) )
                  --BEGIN PTS 65645 SPN
                  AND ( @trc_branch = 'UNKNOWN'
                     OR @trc_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END)
                      )
                  --END PTS 65645 SPN

               SELECT @min_shift_id = min(shift_ss_id) FROM #temp_rtn WHERE shift_ss_id is not null and shift_ss_id > 0 and asgn_type = 'TRC'
               WHILE @min_shift_id is not null
               BEGIN
                  INSERT INTO #temp_rtn
                  SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
                         a.mov_number, a.asgn_number, 0, 0, 0, '', trc_owner,
                         '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
                         null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
                         l.lgh_shiftdate,
                         l.lgh_shiftnumber,
                         l.shift_ss_id,
                         -- PTS 47740 added 11 new columns <<start>>
                         null, null, null, null, null, null, null, null, null, null, null
                         -- PTS 47740 <<end>>
                         , null, null, null -- PTS 52192
                    FROM assetassignment a
                  INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                        AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                                        AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                                        AND a.asgn_type = 'TRC'
                       , @tmp1 #tmp1
                   WHERE a.asgn_type = 'TRC'
                     AND a.asgn_id = trc_number
                     AND a.asgn_status = 'CMP'
                     AND pyd_status = 'NPD'
                     AND shift_ss_id = @min_shift_id
                     AND l.lgh_number not in (SELECT lgh_number FROM #temp_rtn WHERE shift_ss_id = @min_shift_id)
                     AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y' then l.trc_type1 else #tmp1.trc_type1 end) )
                     AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y' then l.trc_type2 else #tmp1.trc_type2 end) )
                     AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y' then l.trc_type3 else #tmp1.trc_type3 end) )
                     AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y' then l.trc_type4 else #tmp1.trc_type4 end) )
                     --BEGIN PTS 65645 SPN
                     AND ( @trc_branch = 'UNKNOWN'
                        OR @trc_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END)
                         )
                     --END PTS 65645 SPN

                  SELECT @min_shift_id = min(shift_ss_id) FROM #temp_rtn WHERE shift_ss_id is not null and shift_ss_id > @min_shift_id and asgn_type = 'TRC'
               END --LOOP
            END
      END
END
--END TRACTORS


--BEGIN CARRIERS
IF @caryes <> 'XXX'
BEGIN
    INSERT INTO #temp_rtn
    SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
           a.mov_number, a.asgn_number, 0, 0, 0, '', car_name,
           '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
           null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
           l.lgh_shiftdate,
           l.lgh_shiftnumber,
           l.shift_ss_id,
           -- PTS 47740 added 11 new columns <<start>>
           null, null, null, null, null, null, null, null, null, null, null
           -- PTS 47740 <<end>>
           , null, null, null -- PTS 52192
      FROM assetassignment a
    INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                          AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                          AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                          AND a.asgn_type = 'CAR'
         , @tmp2 #tmp2
     WHERE a.asgn_type = 'CAR'
       AND a.asgn_id = car_id
       AND a.asgn_status = 'CMP'
       AND pyd_status = 'NPD'
       AND a.asgn_date BETWEEN @lostartdate AND @histartdate
       AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
       --BEGIN PTS 65645 SPN
       AND ( @car_branch = 'UNKNOWN'
          OR @car_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp2.asgn_branch,'UNKNOWN') END)
           )
       --END PTS 65645 SPN
END
--END CARRIERS


--BEGIN TRAILERS
IF @trlyes <> 'XXX'
BEGIN
   INSERT INTO #temp_rtn
   SELECT a.lgh_number, a.asgn_type, a.asgn_id, a.asgn_date, a.asgn_enddate, '', '',
          a.mov_number, a.asgn_number, 0, 0, 0, '', trl_owner,
          '', '', '', '', 0, '', 'RevType1','N','','UNK','LghType1',
          null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', a.asgn_controlling,
          l.lgh_shiftdate,
          l.lgh_shiftnumber,
          l.shift_ss_id,
          -- PTS 47740 added 11 new columns <<start>>
          null, null, null, null, null, null, null, null, null, null, null
          -- PTS 47740 <<end>>
          , null, null, null -- PTS 52192
     FROM assetassignment a
   INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                         AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
                         AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
                         AND a.asgn_type = 'TRL'
        , @tmp3 #tmp3
    WHERE a.asgn_type = 'TRL'
      AND a.asgn_id = trl_id
      AND a.asgn_status = 'CMP'
      AND pyd_status = 'NPD'
      AND a.asgn_date BETWEEN @lostartdate AND @histartdate
      AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
      --BEGIN PTS 65645 SPN
      AND ( @trl_branch = 'UNKNOWN'
       OR @trl_branch = (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp3.asgn_branch,'UNKNOWN') END)
        )
      --END PTS 65645 SPN
END
--END TRAILERS


--BEGIN THIRD-PARTIES
-- MRH 31225 Third party
-- Need TPR ID and not on hold....
IF @tpryes <> 'XXX'
BEGIN
   -- LOR   PTS# 31839
   select @agent = Upper(LTrim(RTrim(gi_string1))) from generalinfo where gi_name = 'AgentCommiss'
   If @agent = 'Y' or @agent = 'YES'
      BEGIN
         INSERT INTO @tmp4
         SELECT DISTINCT tpr_id, tpr_name
           FROM thirdpartyprofile
           JOIN RowRestrictValidAssignments_thirdpartyprofile_fn() rsva ON thirdpartyprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                                        OR rsva.rowsec_rsrv_id = 0
          WHERE @tpr_id IN ('UNKNOWN', tpr_id)
            AND (@tprtype1 in ('N', 'X') OR (@tprtype1 = 'Y' AND @tprtype1 = tpr_thirdpartytype1))
            AND (@tprtype2 in ('N', 'X') OR (@tprtype2 = 'Y' AND @tprtype2 = tpr_thirdpartytype2))
            AND (@tprtype3 in ('N', 'X') OR (@tprtype3 = 'Y' AND @tprtype3 = tpr_thirdpartytype3))
            AND (@tprtype4 in ('N', 'X') OR (@tprtype4 = 'Y' AND @tprtype4 = tpr_thirdpartytype4))
            AND (@tprtype5 in ('N', 'X') OR (@tprtype5 = 'Y' AND @tprtype5 = tpr_thirdpartytype5))
            AND (@tprtype6 in ('N', 'X') OR (@tprtype6 = 'Y' AND @tprtype6 = tpr_thirdpartytype6))
            AND @acct_typ IN ('X', tpr_actg_type)
            AND tpr_actg_type IN('A', 'P')
            AND (@profile_owner = 'UNK' OR @profile_owner = tpr_payto)

         INSERT INTO #temp_rtn
               (lgh_number, asgn_type, asgn_id, asgn_date, asgn_enddate,
                cmp_id_start, cmp_id_end, mov_number, asgn_number, ord_hdrnumber,
                lgh_startcity, lgh_endcity, ord_number, name,
                cmp_name_start, cmp_name_end, cty_nmstct_start, cty_nmstct_end,
                need_paperwork, ivh_revtype1, revtype1_name, lgh_split_flag,
                trip_description, lgh_type1, lgh_type_name, ivh_billdate,
                ivh_invoicenumber, lgh_booked_revtype1, ivh_billto, asgn_controlling)
         SELECT 0, 'TPR', orderheader.ord_thirdpartytype1, orderheader.ord_startdate,
               orderheader.ord_completiondate, '', '', orderheader.mov_number, 0,
               orderheader.ord_hdrnumber, 0, 0, orderheader.ord_number, tpr_name,
               '', '', '', '', 0, '', 'RevType1', 'N','',
               'UNK','LghType1', null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', 'Y'
           FROM orderheader
              , @tmp4 #tmp4
          WHERE orderheader.ord_thirdpartytype1 = tpr_id
            AND orderheader.ord_status = 'CMP'
            AND orderheader.ord_pyd_status_1 = 'NPD'
            AND orderheader.ord_startdate BETWEEN @lostartdate AND @histartdate
            AND orderheader.ord_completiondate BETWEEN @loenddate AND @hienddate
            AND ( (@rowsecurity <> 'Y')
                   OR EXISTS(SELECT 1
                               FROM @tbl_restrictedbyuser rsva
                              WHERE orderheader.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                 OR rsva.rowsec_rsrv_id = 0
                            )
                )

         INSERT INTO #temp_rtn
               (lgh_number, asgn_type, asgn_id, asgn_date, asgn_enddate,
                cmp_id_start, cmp_id_end, mov_number, asgn_number, ord_hdrnumber,
                lgh_startcity, lgh_endcity, ord_number, name,
                cmp_name_start, cmp_name_end, cty_nmstct_start, cty_nmstct_end,
                need_paperwork, ivh_revtype1, revtype1_name, lgh_split_flag,
                trip_description, lgh_type1, lgh_type_name, ivh_billdate,
                ivh_invoicenumber, lgh_booked_revtype1, ivh_billto, asgn_controlling)
         SELECT 0, 'TPR', orderheader.ord_thirdpartytype1, orderheader.ord_startdate,
                orderheader.ord_completiondate, '', '', orderheader.mov_number, 0,
                orderheader.ord_hdrnumber, 0, 0, orderheader.ord_number, tpr_name,
                '', '', '', '', 0, '', 'RevType1', 'N','',
                'UNK','LghType1', null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', 'Y'
           FROM orderheader
              , @tmp4 #tmp4
          WHERE orderheader.ord_thirdpartytype2 = tpr_id
            AND orderheader.ord_status = 'CMP'
            AND orderheader.ord_pyd_status_2 = 'NPD'
            AND orderheader.ord_startdate BETWEEN @lostartdate AND @histartdate
            AND orderheader.ord_completiondate BETWEEN @loenddate AND @hienddate
            AND ( (@rowsecurity <> 'Y')
                   OR EXISTS(SELECT 1
                               FROM @tbl_restrictedbyuser rsva
                              WHERE orderheader.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                 OR rsva.rowsec_rsrv_id = 0
                            )
                )

      END
   Else
-- LOR
      INSERT INTO #temp_rtn
            (lgh_number, asgn_type, asgn_id, asgn_date, asgn_enddate,
             cmp_id_start, cmp_id_end, mov_number, asgn_number, ord_hdrnumber,
             lgh_startcity, lgh_endcity, ord_number, name,
             cmp_name_start, cmp_name_end, cty_nmstct_start, cty_nmstct_end,
             need_paperwork, ivh_revtype1, revtype1_name, lgh_split_flag,
             trip_description, lgh_type1, lgh_type_name, ivh_billdate,
             ivh_invoicenumber, lgh_booked_revtype1, ivh_billto, asgn_controlling)
      SELECT lgh_number, 'TPR', tpr_id as asgn_id,
             (select lgh_startdate from legheader where lgh_number = tpa.lgh_number) as asgn_date,
             (select lgh_enddate from legheader where lgh_number = tpa.lgh_number) as asgn_enddate,
             '', '',
             0, 0, 0, 0, 0, '', '',
             '', '', '', '', 0, '', '','N','','UNK','',
             null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', 'Y'
        FROM thirdpartyassignment tpa
       WHERE isnull(pyd_status, 'NPD') = 'NPD'
         AND (@tpr_id = tpr_id OR @tpr_id = 'UNKNOWN')
         AND (@tpr_type = tpr_type OR @tpr_type = 'UNKNOWN')
         AND isnull(tpa_status, 'NPD') <> 'DEL'
         AND (select lgh_outstatus from legheader where lgh_number = tpa.lgh_number) = 'CMP'
         AND (select lgh_startdate from legheader where lgh_number = tpa.lgh_number) BETWEEN @lostartdate AND @histartdate
         AND (select lgh_enddate from legheader where lgh_number = tpa.lgh_number) BETWEEN @loenddate AND @hienddate
END
-- MRH
--END THIRD-PARTIES

--CREATE INDEXES NOW
CREATE INDEX temp_rtn_ord_hdrnumber ON #temp_rtn( lgh_number,ord_hdrnumber)
CREATE INDEX #dk_temp_idx_mov ON #temp_rtn (mov_number)

/* Get the mov number */
UPDATE #temp_rtn
   SET mov_number          = legheader.mov_number
     , ord_hdrnumber       = legheader.ord_hdrnumber
     , lgh_startcity       = legheader.lgh_startcity
     , cmp_id_start        = legheader.cmp_id_start
     , lgh_endcity         = legheader.lgh_endcity
     , cmp_id_end          = legheader.cmp_id_end
     , cty_nmstct_start    = lgh_startcty_nmstct
     , cty_nmstct_end      = lgh_endcty_nmstct
     , lgh_split_flag      = legheader.lgh_split_flag
     , lgh_type1           = isNull(legheader.lgh_type1,'UNK')
     , ivh_billdate        = NULL
     , ivh_invoicenumber   = NULL
     , lgh_booked_revtype1 = isNull(legheader.lgh_booked_revtype1, 'UNK')
     , lgh_type2           = isNull(legheader.lgh_type2,'UNK') -- PTS 52192
     , lgh_type3           = isNull(legheader.lgh_type3,'UNK') -- PTS 52192
     , lgh_type4           = isNull(legheader.lgh_type4,'UNK') -- PTS 52192
     , stp_schdtearliest   = legheader.lgh_schdtearliest
  FROM legheader
 WHERE legheader.lgh_number = #temp_rtn.lgh_number

--BEGIN PTS 52995 SPN
UPDATE #temp_rtn
   SET lgh_booked_revtype1 = 'UNK'
 WHERE lgh_booked_revtype1 = 'Lgh_Booked_Revtype1'
--END PTS 52995 SPN

-- 21110 JD exclude hourly orders from trips ready to settle
select @revtype4 = gi_string4 from generalinfo where gi_name = 'TripStlExcludeRevtypefromQ'
If @revtype4 is not null and exists (select * from labelfile where labeldefinition = 'Revtype4' and abbr = @revtype4)
begin
   delete #temp_rtn from orderheader
   where #temp_rtn.ord_hdrnumber = orderheader.ord_hdrnumber and
      orderheader.ord_revtype4 = @revtype4
end
-- end 21110 JD


/* PTS 17873 - DJM - 4/11/03 Remove legs that don't match the requrired lgh_type1   */
select @lgh_type1 = isnull(@lgh_type1, 'UNK')
if @lgh_type1 <> 'UNK' AND @lgh_type1 <> ''
   Delete from #temp_rtn
   where lgh_type1 <> @lgh_type1



update #temp_rtn set trip_description = dbo.tmwf_scroll_assignments_concat(mov_number)
update #temp_rtn set trip_description = substring(trip_description,2,datalength(trip_description))
where datalength(trip_description) > 0

--UPDATE #temp_rtn
--   SET ord_number = (SELECT orderheader.ord_number
--                       FROM orderheader
--                      WHERE orderheader.ord_hdrnumber = #temp_rtn.ord_hdrnumber)
--END PTS 54538 MTC
declare @revtype1userlabel varchar(20), @revtype2userlabel varchar(20), @revtype3userlabel varchar(20), @revtype4userlabel varchar(20)
select @revtype1userlabel = MIN(labelfile.userlabelname) from labelfile where labeldefinition = 'RevType1' and labelfile.userlabelname > ''
select @revtype2userlabel = MIN(labelfile.userlabelname) from labelfile where labeldefinition = 'RevType2' and labelfile.userlabelname > ''
select @revtype3userlabel = MIN(labelfile.userlabelname) from labelfile where labeldefinition = 'RevType3' and labelfile.userlabelname > ''
select @revtype4userlabel = MIN(labelfile.userlabelname) from labelfile where labeldefinition = 'RevType4' and labelfile.userlabelname > ''

update #temp_rtn
   set ord_revtype1_name = @revtype1userlabel
     , ord_revtype2_name = @revtype2userlabel
     , ord_revtype3_name = @revtype3userlabel
     , ord_revtype4_name = @revtype4userlabel

Update #temp_rtn
   set ord_number   = orderheader.ord_hdrnumber
     , ord_route    = orderheader.ord_route
     , ord_revtype1 = orderheader.ord_revtype1
     , ord_revtype2 = orderheader.ord_revtype2
     , ord_revtype3 = orderheader.ord_revtype3
     , ord_revtype4 = orderheader.ord_revtype4
  from #temp_rtn
inner join orderheader on #temp_rtn.ord_hdrnumber = orderheader.ord_hdrnumber
                      and #temp_rtn.ord_hdrnumber > 0

update #temp_rtn
   set cmp_name_start = company.cmp_name
  from #temp_rtn inner join company on #temp_rtn.cmp_id_start = company.cmp_id

update #temp_rtn
   set cmp_name_end = company.cmp_name
  from #temp_rtn
inner join company on #temp_rtn.cmp_id_end = company.cmp_id

update #temp_rtn
   set #temp_rtn.ivh_revtype1 = invoiceheader.ivh_revtype1
     , #temp_rtn.ivh_billto = invoiceheader.ivh_billto
  from #temp_rtn
inner join invoiceheader on #temp_rtn.ord_hdrnumber = invoiceheader.ord_hdrnumber
                        and #temp_rtn.ord_hdrnumber > 0
                        and invoiceheader.ivh_hdrnumber = (SELECT min(ivh_hdrnumber)
                                                             FROM invoiceheader i
                                                            WHERE #temp_rtn.ord_hdrnumber > 0 and i.ord_hdrnumber = #temp_rtn.ord_hdrnumber
                                                          )

update #temp_rtn
   set Cost = (SELECT sum(pyd_amount)
                 FROM paydetail
                WHERE paydetail.ord_hdrnumber > 0
                  and ord_hdrnumber = #temp_rtn.ord_hdrnumber
             )


--UPDATE #temp_rtn
--   SET ord_number =
--       (
--        CASE WHEN IsNull(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
--        ELSE
--             (SELECT orderheader.ord_number
--                FROM orderheader
--               WHERE orderheader.ord_hdrnumber = #temp_rtn.ord_hdrnumber
--             )
--        END
--       )
--     , ord_route =
--       (
--        CASE WHEN IsNull(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
--        ELSE
--             (SELECT orderheader.ord_route
--                FROM orderheader
--               WHERE orderheader.ord_hdrnumber = #temp_rtn.ord_hdrnumber
--             )
--        END
--       )
--     , stp_schdtearliest =
--       (
--        CASE WHEN IsNull(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
--        ELSE
--             (SELECT stp_schdtearliest
--                FROM stops
--               WHERE stp_number =
--                     (SELECT min(stp_number)
--                        FROM stops
--                       WHERE ord_hdrnumber = #temp_rtn.ord_hdrnumber
--                         AND stp_mfh_sequence =
--                             (SELECT min(stp_mfh_sequence)
--                                FROM stops
--                               WHERE ord_hdrnumber = #temp_rtn.ord_hdrnumber
--                             )
--                     )
--             )
--        END
--       )
--     , cost =
--       (
--        CASE WHEN IsNull(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
--        ELSE
--             (SELECT sum(pyd_amount)
--                FROM paydetail
--               WHERE ord_hdrnumber = #temp_rtn.ord_hdrnumber
--             )
--        END
--       )
--     , ord_revtype1 =
--       (
--        CASE WHEN IsNull(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
--        ELSE
--             (SELECT orderheader.ord_revtype1
--                FROM orderheader
--               WHERE orderheader.ord_hdrnumber = #temp_rtn.ord_hdrnumber
--             )
--        END
--       )
--     , ord_revtype1_name =
--       (SELECT min(labelfile.userlabelname)
--          FROM labelfile
--         WHERE labelfile.userlabelname > ''
--           AND labelfile.labeldefinition = 'REVTYPE1'
--       )
--     , ord_revtype2 =
--       (
--        CASE WHEN IsNull(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
--        ELSE
--             (SELECT orderheader.ord_revtype2
--                FROM orderheader
--               WHERE orderheader.ord_hdrnumber = #temp_rtn.ord_hdrnumber
--             )
--        END
--       )
--     , ord_revtype2_name =
--       (SELECT min(labelfile.userlabelname)
--          FROM labelfile
--         WHERE labelfile.userlabelname > ''
--           AND labelfile.labeldefinition = 'REVTYPE2'
--       )
--     , ord_revtype3 =
--       (
--        CASE WHEN IsNull(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
--        ELSE
--             (SELECT orderheader.ord_revtype3
--                FROM orderheader
--               WHERE orderheader.ord_hdrnumber = #temp_rtn.ord_hdrnumber
--             )
--        END
--       )
--     , ord_revtype3_name =
--       (SELECT min(labelfile.userlabelname)
--          FROM labelfile
--         WHERE labelfile.userlabelname > ''
--           AND labelfile.labeldefinition = 'REVTYPE3'
--       )
--     , ord_revtype4 =
--       (
--        CASE WHEN IsNull(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
--        ELSE
--             (SELECT orderheader.ord_revtype4
--                FROM orderheader
--               WHERE orderheader.ord_hdrnumber = #temp_rtn.ord_hdrnumber)
--        END
--       )
--     , ord_revtype4_name =
--       (SELECT min(labelfile.userlabelname)
--          FROM labelfile
--         WHERE labelfile.userlabelname > ''
--           AND labelfile.labeldefinition = 'REVTYPE4'
--       )
--     , cmp_name_start =
--       (SELECT co.cmp_name
--          FROM company co
--         WHERE #temp_rtn.cmp_id_start = co.cmp_id
--       )
--     , cmp_name_end =
--       (SELECT co.cmp_name
--          FROM company co
--         WHERE #temp_rtn.cmp_id_end = co.cmp_id
--       )
--     , ivh_revtype1 =
--       (
--        CASE WHEN IsNull(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
--        ELSE
--             (SELECT ivh_revtype1
--                FROM invoiceheader i
--               WHERE i.ord_hdrnumber = #temp_rtn.ord_hdrnumber
--                 AND i.ord_hdrnumber <> 0
--                 AND i.ivh_hdrnumber = (SELECT MIN(ivh_hdrnumber)
--                                          FROM invoiceheader ii
--                                         WHERE ii.ord_hdrnumber = i.ord_hdrnumber
--                                           AND ii.ord_hdrnumber=#temp_rtn.ord_hdrnumber
--                                       )
--             )
--        END
--       )
--     , ivh_billto =
--       (
--        CASE WHEN IsNull(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
--        ELSE
--             (SELECT ivh_billto
--                FROM invoiceheader i
--               WHERE i.ord_hdrnumber = #temp_rtn.ord_hdrnumber
--                 AND i.ord_hdrnumber <> 0
--                 AND i.ivh_hdrnumber = (SELECT MIN(ivh_hdrnumber)
--                                          FROM invoiceheader ii
--                                         WHERE ii.ord_hdrnumber = i.ord_hdrnumber
--                                           AND ii.ord_hdrnumber=#temp_rtn.ord_hdrnumber
--                                       )
--             )
--        END
--       )
--END PTS 53466 SPN

/* PTS 16034 - DJM - Modified to handle Paperwork requirements by Leg and/or by Bill To company.   */
select @paperworkmode = isNull(gi_string1,'A') from generalinfo where gi_name = 'PaperWorkMode'
select @paperworkchecklevel = IsNull(gi_string1,'ORDER') from generalinfo where gi_name = 'PaperWorkCheckLevel'

/* PTS 16982 - DJM - Modify the Proc to properly identify the Paperwork required each Order and/or Leg to be settled.   */
/* Insert a record into #temp_pwk for every Legheader/Orderheader combination.  Gets all the Orderheaders on
   a Leg so Paperwork can be tracked for every Order.    */
Insert into #temp_pwk
SELECT   #temp_rtn.lgh_number,
   stops.ord_hdrnumber,
   0 req_cnt,
   0 rec_cnt,
   'UNKNOWN'
   --(select isNull(ord_billto,'UNK') from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) ord_billto
FROM #temp_rtn, stops
WHERE stops.lgh_number = #temp_rtn.lgh_number
   and stops.ord_hdrnumber > 0  --isNull(stops.ord_hdrnumber,0) > 0  pmill 49424 performance enhancement

GROUP BY #temp_rtn.lgh_number, stops.ord_hdrnumber
Order by #temp_rtn.lgh_number

update   #temp_pwk
set #temp_pwk.ord_billto = orderheader.ord_billto
from #temp_pwk inner join orderheader on #temp_pwk.ord_hdrnumber = orderheader.ord_hdrnumber

/* Set the number of required paperwork fields for each order     */
--PTS 36869 EMK Added Invoice Required
if @paperworkchecklevel = 'LEG'
   Begin
      if @paperworkmode = 'B'
         update #temp_pwk
         set req_cnt = (select count(*)
                     from billdoctypes
                     where cmp_id = #temp_pwk.ord_billto
                           and IsNull(billdoctypes.bdt_inv_required, 'Y') = 'Y'
                           and (ISNULL(bdt_required_for_application, 'B') = 'B' or bdt_required_for_application = 'S') --PTS 40877
                           and ((exists(select *
                                    from stops stp
                                    where stp.lgh_number = #temp_pwk.lgh_number
                                       and stp_type = 'PUP')
                                 and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'PUP'or bdt_required_for_fgt_event = 'APUP'or bdt_required_for_fgt_event = 'ASTOP'))
                              or (exists(select *
                                    from stops stp
                                    where stp.lgh_number = #temp_pwk.lgh_number
                                       and stp_type = 'DRP')
                              and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'DRP'or bdt_required_for_fgt_event = 'ADRP'or bdt_required_for_fgt_event = 'ASTOP')))
                     ),
            rec_cnt = (select count(*)
                     from paperwork, billdoctypes
                     where #temp_pwk.ord_hdrnumber = paperwork.ord_hdrnumber
                           and paperwork.pw_received = 'Y'
                           and ( @paperwork_GI_cutoff_flag = 'N' or paperwork.pw_dt <= @paperwork_computed_cutoff_datetime ) --vjh 45500
                           and #temp_pwk.lgh_number = paperwork.lgh_number
                           and billdoctypes.cmp_id = #temp_pwk.ord_billto
                           and billdoctypes.bdt_doctype = paperwork.abbr
                           and IsNull(billdoctypes.bdt_inv_required, 'Y') = 'Y'
                           and (ISNULL(bdt_required_for_application, 'B') = 'B' or bdt_required_for_application = 'S') --PTS 40877
                           and ((exists(select *
                                    from stops stp
                                    where stp.lgh_number = #temp_pwk.lgh_number
                                       and stp_type = 'PUP')
                                 and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'PUP' or bdt_required_for_fgt_event = 'APUP'or bdt_required_for_fgt_event = 'ASTOP'))
                              or (exists(select *
                                    from stops stp
                                    where stp.lgh_number = #temp_pwk.lgh_number
                                       and stp_type = 'DRP')
                              and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'DRP' or bdt_required_for_fgt_event = 'ADRP'or bdt_required_for_fgt_event = 'ASTOP')))
                     )  --PTS 36869
      else
         Update #temp_pwk
         set req_cnt = (select count(*) from labelfile where labeldefinition = 'Paperwork'
            and (retired is NULL or retired = 'N')),
         rec_cnt = (select count(*)
               from paperwork
               where #temp_pwk.ord_hdrnumber = paperwork.ord_hdrnumber
                  and paperwork.pw_received = 'Y'
                  and ( @paperwork_GI_cutoff_flag = 'N' or paperwork.pw_dt <= @paperwork_computed_cutoff_datetime ) --vjh 45500
                  and #temp_pwk.lgh_number = paperwork.lgh_number)
   End
Else
   /* Paperwork is not tracked by Leg,  Only the total number for the Order is tracked    */
   Begin
      if @paperworkmode = 'B'
         update #temp_pwk
         set req_cnt = (select count(*)
                     from billdoctypes
                     where cmp_id = #temp_pwk.ord_billto
                           and IsNull(billdoctypes.bdt_inv_required, 'Y') = 'Y'
                           and (ISNULL(bdt_required_for_application, 'B') = 'B' or bdt_required_for_application = 'S') --PTS 40877
                     ),
            rec_cnt = (select count(*)
                     from paperwork, billdoctypes
                     where #temp_pwk.ord_hdrnumber = paperwork.ord_hdrnumber
                           and paperwork.pw_received = 'Y'
                           and ( @paperwork_GI_cutoff_flag = 'N' or paperwork.pw_dt <= @paperwork_computed_cutoff_datetime ) --vjh 45500
                           and billdoctypes.cmp_id = #temp_pwk.ord_billto
                           and billdoctypes.bdt_doctype = paperwork.abbr
                           and IsNull(billdoctypes.bdt_inv_required, 'Y') = 'Y'
                           and (ISNULL(bdt_required_for_application, 'B') = 'B' or bdt_required_for_application = 'S') --PTS 40877
                     )
      else
         Update #temp_pwk
         set req_cnt = (select count(*) from labelfile where labeldefinition = 'Paperwork'
            and (retired is NULL or retired = 'N')),
         rec_cnt = (select count(*)
               from paperwork
               where #temp_pwk.ord_hdrnumber = paperwork.ord_hdrnumber
                  and paperwork.pw_received = 'Y'
                  and ( @paperwork_GI_cutoff_flag = 'N' or paperwork.pw_dt <= @paperwork_computed_cutoff_datetime ) )--vjh 45500
   End

if @paperworkchecklevel = 'LEG'
   Begin
      /* Update where all paperwork is in       */
      UPDATE #temp_rtn
         SET need_paperwork = 1
        FROM #temp_rtn
       WHERE exists ( select * from #temp_pwk
         where #temp_pwk.lgh_number = #temp_rtn.lgh_number
            and rec_cnt >= req_cnt)

      /* Update where all paperwork is not in   */
      UPDATE #temp_rtn
         SET need_paperwork = -1
        FROM #temp_rtn
       WHERE exists ( select * from #temp_pwk
         where #temp_pwk.lgh_number = #temp_rtn.lgh_number
            and rec_cnt < req_cnt)
   End
else
   Begin
      /* Update where all paperwork is in       */
      UPDATE #temp_rtn
         SET need_paperwork = 1
        FROM #temp_rtn
       WHERE exists ( select * from #temp_pwk
         where #temp_pwk.ord_hdrnumber = #temp_rtn.ord_hdrnumber
            and rec_cnt >= req_cnt)

      /* Update where all paperwork is not in   */
      UPDATE #temp_rtn
         SET need_paperwork = -1
        FROM #temp_rtn
       WHERE exists ( select * from #temp_pwk
         where #temp_pwk.ord_hdrnumber = #temp_rtn.ord_hdrnumber
            and rec_cnt < req_cnt)
   End
-- End 16982

DROP TABLE #temp_pwk



if @stlmustinv = 'Y' or @StlMustOrd = 'Y' begin
   --get the orders we need to consider
   if @splitmustinv ='Y' or @StlMustOrd = 'Y' begin
      insert #temp_Orders
      select a.lgh_number, s.ord_hdrnumber, 'N', 'N', lgh_split_flag
      from #temp_rtn a
      join stops s on a.lgh_number = s.lgh_number
      and s.ord_hdrnumber <> 0 -- SGB PTS 48667 need to exclude 0 ord_hdrnumbers
   end else begin
      if @splitmustinv ='N' begin

         --@splitmustinv = 'N' so only need to check for orders on stops with drop events
      insert #temp_Orders
         select a.lgh_number, s.ord_hdrnumber, 'N', 'N', lgh_split_flag
      from #temp_rtn a
      join stops s on a.lgh_number = s.lgh_number
      join event e on e.stp_number = s.stp_number
      join eventcodetable ect on ect.abbr = e.evt_eventcode and fgt_event='DRP'
      end else begin
         -- --PTS 63716 Add support for SplitMustInv = 'L' from PTS58060
         --@splitmustinv = 'L' so only need to check for orders on stops on last leg
         insert #temp_Orders
         select a.lgh_number, s.ord_hdrnumber, 'N', 'N', lgh_split_flag
         from #temp_rtn a
         join stops s on a.lgh_number = s.lgh_number
         and s.ord_hdrnumber > 0
         --and a.lgh_split_flag = 'F' Needs to handle non split trips
         and a.lgh_split_flag in ( 'F','N')--  = 'F'
         join event e on e.stp_number = s.stp_number
      end

   end
end

if @splitmustinv = 'N' begin
   --vjh 56345  splits without drops do not require invoicesif @splitmustinv = 'N'
   update #temp_Orders set Inv_OK_Flag = 'Y'
   where not exists (
      select 1 from legheader l
      join stops s on l.lgh_number = s.lgh_number
      join event e on e.stp_number = s.stp_number
      join eventcodetable ect on ect.abbr = e.evt_eventcode and fgt_event='DRP'
      where s.lgh_number = #temp_Orders.lgh_number and s.ord_hdrnumber > 0
   )
end
--PTS 63716 Add support for SplitMustInv = 'L' from PTS58060
--@splitmustinv = 'L' so only need to check for orders on stops on last leg
if @splitmustinv = 'L' begin
   update #temp_Orders
   set Inv_OK_Flag = 'Y'
   where split_flag = 'S'
   and exists (select * from #temp_orders t2
            where t2.ord_hdrnumber = #temp_Orders.ord_hdrnumber
            and t2.split_flag = 'F')
end

if @StlMustOrd = 'Y' begin
   --@StlMustOrd = 'Y'
   update #temp_Orders set Ord_OK_Flag = 'Y'
   where exists (select *
               from orderheader o
               where o.ord_hdrnumber = #temp_Orders.ord_hdrnumber
               and o.ord_status = 'CMP')
end else begin
   --@StlMustOrd = 'N'
   update #temp_Orders set Ord_OK_Flag = 'Y'
end

--now look at the invoices.
if @ls_invstat1 <> '' begin
   if @stlmustinv = 'Y' begin
      --@ps_invstat1 and @stlmustinv = 'Y'
      --update if any invoice exists for the order and the invoice status is not in the exclude list
      update #temp_Orders set Inv_OK_Flag = 'Y'
      where exists (select *
                  from invoiceheader i
                  where i.ord_hdrnumber = #temp_Orders.ord_hdrnumber
                  and ivh_invoicestatus not in (@ls_invstat1,@ls_invstat2,@ls_invstat3,@ls_invstat4)
                  and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL') )
      or exists (select *
                  from invoiceheader i
                  join invoicemaster on ivm_invoiceordhdrnumber = i.ord_hdrnumber
                  where invoicemaster.ord_hdrnumber = #temp_Orders.ord_hdrnumber
                  and ivh_invoicestatus not in (@ls_invstat1,@ls_invstat2,@ls_invstat3,@ls_invstat4)
                  and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL') )
   end else begin
      --@ps_invstat1 and @stlmustinv = 'N'
      update #temp_Orders set Inv_OK_Flag = 'Y'
   end
end else begin --@ls_invstat1 = ''
   if @stlmustinv = 'Y' begin
      --update if any invoice exists for the order AND the order is on complete status
      update #temp_Orders set #temp_Orders.Inv_OK_Flag = 'Y'
      where (
         exists (select *
                  from invoiceheader i
                  where i.ord_hdrnumber = #temp_Orders.ord_hdrnumber
                  and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL') )
         or exists (select *
                  from invoiceheader i
                  join invoicemaster on ivm_invoiceordhdrnumber = i.ord_hdrnumber
                  where invoicemaster.ord_hdrnumber = #temp_Orders.ord_hdrnumber
                  and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL'))
      )
   end else begin
      --@ps_invstat1='' and @stlmustinv = 'N'
      update #temp_Orders set Inv_OK_Flag = 'Y'
   end
end


   update #temp_Orders set Inv_OK_Flag = 'Y'
   where exists(select * from orderheader o where o.ord_hdrnumber = #temp_Orders.ord_hdrnumber and ord_invoicestatus='XIN')
   and #temp_Orders.ord_hdrnumber > 0
--end

insert into #temp_rtn1
select a.*
from #temp_rtn a
where not exists (select * from #temp_Orders where (Inv_OK_Flag = 'N' or Ord_OK_Flag = 'N') and a.lgh_number = #temp_Orders.lgh_number)
or (a.lgh_split_flag = 'S' and @ComputeRevenueByTripSegment = 'Y')


-- PTS 31363 -- BL (start)
-- Update billdate and invoicenumber rather than set it during the insert
update   #temp_rtn1
set      ivh_invoicenumber = (select max(ivh_invoicenumber)
                     from  invoiceheader
                     where    #temp_rtn1.ord_hdrnumber > 0 and #temp_rtn1.ord_hdrnumber = invoiceheader.ord_hdrnumber )
where    #temp_rtn1.ord_hdrnumber > 0


-- For invoice by move cases
Update #temp_rtn1
   set ivh_invoicenumber = (select max(ivh_invoicenumber)
                     from  invoiceheader
                     where    #temp_rtn1.mov_number  = invoiceheader.mov_number )
   where #temp_rtn1.ivh_invoicenumber is null


Update #temp_rtn1
set ivh_billdate = invoiceheader.ivh_billdate,
   ivh_billto  = invoiceheader.ivh_billto,
   ivh_revtype1 = invoiceheader.ivh_revtype1
from #temp_rtn1 inner join invoiceheader on #temp_rtn1.ord_hdrnumber = invoiceheader.ord_hdrnumber
and #temp_rtn1.ivh_invoicenumber = invoiceheader.ivh_invoicenumber  and #temp_rtn1.ord_hdrnumber > 0


-- 65394 for consolidate orders 
Update #temp_rtn1  
set ivh_billdate = invoiceheader.ivh_billdate,  
   ivh_billto  = invoiceheader.ivh_billto,  
   ivh_revtype1 = invoiceheader.ivh_revtype1  
from #temp_rtn1 inner join invoiceheader on #temp_rtn1.ord_hdrnumber in (select ord_hdrnumber from orderheader
				where mov_number = (select mov_number from orderheader where ord_hdrnumber = invoiceheader.ord_hdrnumber ))
and #temp_rtn1.ivh_invoicenumber = invoiceheader.ivh_invoicenumber  and #temp_rtn1.ord_hdrnumber > 0  
and #temp_rtn1.ivh_billto = 'IvhBillT'

--update    #temp_rtn1
--set    ivh_billdate = (SELECT  max(ivh_billdate)
--                from  invoiceheader
--                where #temp_rtn1.ord_hdrnumber = invoiceheader.ord_hdrnumber)
--where  #temp_rtn1.ord_hdrnumber > 0

--update    #temp_rtn1
--set    ivh_invoicenumber = (select max(ivh_invoicenumber)
--                   from  invoiceheader
--                   where    ivh_billdate = #temp_rtn1.ivh_billdate)
--where  #temp_rtn1.ord_hdrnumber > 0
---- PTS 31363 -- BL (end)

----BEGIN 46308 SPN
----Get Consolidated Orders Invoice Info
--BEGIN
--   DECLARE upd_cursor_consord CURSOR FOR
--   SELECT mov_number
--     FROM #temp_rtn1
--    WHERE ivh_invoicenumber IS NULL

--   OPEN upd_cursor_consord
--   FETCH NEXT FROM upd_cursor_consord INTO @upd_cursor_consord_mov_number
--   WHILE @@FETCH_STATUS = 0
--      BEGIN
--         SELECT @upd_cursor_consord_ord_hdrnumber = MIN(ord_hdrnumber)
--           FROM orderheader
--          WHERE mov_number = @upd_cursor_consord_mov_number
--         SELECT @new_ivh_invoicenumber = ivh_invoicenumber
--              , @new_ivh_billdate = ivh_billdate
--           FROM invoiceheader
--          WHERE ord_hdrnumber = @upd_cursor_consord_ord_hdrnumber

--         UPDATE #temp_rtn1
--            SET ivh_invoicenumber = @new_ivh_invoicenumber
--              , ivh_billdate = @new_ivh_billdate
--          WHERE mov_number = @upd_cursor_consord_mov_number

--         FETCH NEXT FROM upd_cursor_consord INTO @upd_cursor_consord_mov_number
--      END
--   CLOSE upd_cursor_consord
--   DEALLOCATE upd_cursor_consord
--END
--END 46308 SPN

-- PTS 16945 -- BL (start)
-- See if user entered in an Invoice bill_date range
if @beg_invoice_bill_date > convert(datetime, '1950-01-01 00:00') OR
      @end_invoice_bill_date < convert(datetime, '2049-12-31 23:59')
Begin
   -- Remove paydetails that do NOT fit in given invoice bill_date range
   Delete from #temp_rtn1
   where ivh_billdate is NULL
   or ivh_billdate > @end_invoice_bill_date
   or ivh_billdate < @beg_invoice_bill_date
end
-- PTS 16945 -- BL (end)

-- PTS 32781 - DJM
-- Retrict based on RevType requirement
if @p_revtype1 <> 'UNK' OR @p_revtype2 <> 'UNK' OR @p_revtype3 <> 'UNK' OR @p_revtype4 <> 'UNK'
   Begin

      if @p_revtype1 <> 'UNK'
         delete from #temp_rtn1
         where not exists (select 1 from orderheader o
            where #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
            and isNull(o.ord_revtype1,'UNK') = @p_revtype1)

      if @p_revtype2 <> 'UNK'
         delete from #temp_rtn1
         where not exists (select 1 from orderheader o
            where #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
            and isNull(o.ord_revtype2,'UNK') = @p_revtype2)

      if @p_revtype3 <> 'UNK'
         delete from #temp_rtn1
         where not exists (select 1 from orderheader o
            where #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
            and isNull(o.ord_revtype3,'UNK') = @p_revtype3)

      if @p_revtype4 <> 'UNK'
         delete from #temp_rtn1
         where not exists (select 1 from orderheader o
            where #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
            and isNull(o.ord_revtype4,'UNK') = @p_revtype4)
   end
-- 01/21/2008 MDH PTS 40119: Added delete to clean up orders they should not see.
DELETE FROM #temp_rtn1
   WHERE ord_hdrnumber is not null and ord_hdrnumber <> 0
      and not exists (select 1 from orderheader
                  where #temp_rtn1.ord_hdrnumber = orderheader.ord_hdrnumber
                                   AND ( (@rowsecurity <> 'Y')
                                         OR EXISTS(SELECT 1
                                                     FROM @tbl_restrictedbyuser rsva
                                                    WHERE orderheader.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                       OR rsva.rowsec_rsrv_id = 0
                                                  )
                                       )
            )


-- Restrict based on Invoice status requirement.
if isNull(@inv_status,',UNK,') <> ',UNK,'
   delete from #temp_rtn1
   where not exists (select 1 from Invoiceheader i
      where #temp_rtn1.ord_hdrnumber = i.ord_hdrnumber
         and i.ord_hdrnumber > 0
         and (charindex(',' + isNull(i.ivh_invoicestatus,'UNK')+ ',',@inv_status) > 0
            OR charindex(',' + isNull(i.ivh_mbstatus,'NTP') + ',',@inv_status) > 0 ))

-- Restrict based on Invoice billto
select @p_ivh_billto = isnull(@p_ivh_billto,'UNKNOWN')
if isNull(@p_ivh_billto,'UNKNOWN') <> 'UNKNOWN'
   -- 65394 <start>
   /*
   delete from #temp_rtn1
   where not exists (select 1 from Invoiceheader i
      where #temp_rtn1.ord_hdrnumber = i.ord_hdrnumber
         and i.ord_hdrnumber > 0
         and isnull(i.ivh_billto,'UNKNOWN') = @p_ivh_billto
         and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL') )
   */
   delete from #temp_rtn1  
   where not exists (select 1 from Invoiceheader i  
      where i.ord_hdrnumber > 0 
		and(#temp_rtn1.ord_hdrnumber = i.ord_hdrnumber or 
			#temp_rtn1.ord_hdrnumber in (select ord_hdrnumber from orderheader
				where mov_number = (select mov_number from orderheader where ord_hdrnumber = i.ord_hdrnumber )))
         and isnull(i.ivh_billto,'UNKNOWN') = @p_ivh_billto  
         and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL') )
   --65394 <end>



-- Restrict based on Invoice revtype1
select @p_ivh_revtype1 = isnull(@p_ivh_revtype1,'UNK')
if isNull(@p_ivh_revtype1,'UNK') <> 'UNK'
   delete from #temp_rtn1
   where not exists (select 1 from Invoiceheader i
      where #temp_rtn1.ord_hdrnumber = i.ord_hdrnumber
         and i.ord_hdrnumber > 0
         and isnull(i.ivh_revtype1,'UNK') = @p_ivh_revtype1
         and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL') )

-- End 32781

----------------------------------------------------------------------------------------------------------
-- -- PTS 41389 GAP 74 (start)
If exists (select * from generalinfo where gi_name = 'TrackBranch' and gi_string1 = 'Y')
BEGIN
      -- IF SPECIFIC THEN PULL THAT - IF UNKNOWN THEN PULL THE ONES ALLOWED FOR THE USER.

      --IF  @brn_id  = ',UNKNOWN,'
      IF  @lgh_booked_revtype1  = ',UNKNOWN,'
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

               -------select * from #temp_user_branch    ----------  DEBUG ~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

               DELETE from #temp_rtn1 where lgh_booked_revtyep1 NOT IN (select brn_id from #temp_user_branch)
            END
         end
       ELSE
         begin
            Delete from #temp_rtn1
            where lgh_booked_revtyep1 in (select lgh_booked_revtyep1 from #temp_rtn1
                                 where CHARINDEX(',' + lgh_booked_revtyep1 + ',', @lgh_booked_revtype1 ) = 0 )
         end

END
-- -- PTS 41389 GAP 74 (end)
-- original code
----------------------------------------------------------------------------------------------------------
-- PTS 52192 <<start>> -- remove Carriers that are not yet approved.
declare @onetwothreefour as integer
declare @whichlghType as varchar(12)
declare @carapprovalCode as varchar(8)
declare @ls_segment_lghtype as varchar(12)

if exists (select 1 from generalinfo where gi_name = 'STLApprvdCarrierOnly' and gi_string1='Y')
begin
   set @whichlghType = ( Select gi_string2 from generalinfo where gi_name = 'STLApprvdCarrierOnly' and gi_string1='Y' )
   set @carapprovalCode = ( Select gi_string3 from generalinfo where gi_name = 'STLApprvdCarrierOnly' and gi_string1='Y' )
end

if ( @whichlghType is not NULL and @carapprovalCode is not NULL )
begin

      IF @whichlghType = 'lghtype1'    OR ( CHARINDEX('1', @whichlghType ) > 0 )
         BEGIN
            delete #temp_rtn1 where @carapprovalCode  <> lgh_type1 and asgn_type = 'CAR'
         END
      IF @whichlghType = 'lghtype2'  OR ( CHARINDEX('2', @whichlghType ) > 0 )
         BEGIN
            delete #temp_rtn1 where @carapprovalCode  <> lgh_type2 and asgn_type = 'CAR'
         END
      IF @whichlghType = 'lghtype3'  OR ( CHARINDEX('3', @whichlghType ) > 0 )
         BEGIN
            delete #temp_rtn1 where @carapprovalCode  <> lgh_type3 and asgn_type = 'CAR'
         END
      IF @whichlghType = 'lghtype4' OR ( CHARINDEX('4', @whichlghType ) > 0 )
         BEGIN
            delete #temp_rtn1 where @carapprovalCode  <> lgh_type4 and asgn_type = 'CAR'
         END
end


-- PTS 52192 <<end>>
----------------------------------------------------------------------------------------------------------


-- LOR   PTS#30053
if @sch_date1 > convert(datetime, '1950-01-01 00:00') OR
      @sch_date2 < convert(datetime, '2049-12-31 23:59')
-- LOR   PTS# 43728  changed stp_sequence to stp_mfh_sequence
   SELECT t.lgh_number,
         t.asgn_type,
         t.asgn_id,
         t.asgn_date,
         t.asgn_enddate,
         t.cmp_id_start,
         t.cmp_id_end,
         t.mov_number,
         t.asgn_number,
         t.ord_hdrnumber,
         t.lgh_startcity,
         t.lgh_endcity,
         t.ord_number,
         t.name,
         t.cmp_name_start,
         t.cmp_name_end,
         t.cty_nmstct_start,
         t.cty_nmstct_end,
         t.need_paperwork,
         t.ivh_revtype1,
         t.revtype1_name,
         t.lgh_split_flag,
         t.trip_description,
         t.lgh_type1,
         t.lgh_type_name,
         t.ivh_billdate,
         t.ivh_invoicenumber,
         t.lgh_booked_revtyep1,
         t.asgn_controlling,
         t.lgh_shiftdate,  --vjh 33665
         t.lgh_shiftnumber,   --vjh 33665
         t.stp_schdtearliest, -- PTS 47740
         t.ord_route,         -- PTS 47740
         t.cost,              -- PTS 47740
         t.ord_revtype1,         -- PTS 47740
         t.ord_revtype1_name, -- PTS 47740
         t.ord_revtype2,         -- PTS 47740
         t.ord_revtype2_name, -- PTS 47740
         t.ord_revtype3,         -- PTS 47740
         t.ord_revtype3_name, -- PTS 47740
         t.ord_revtype4,         -- PTS 47740
         t.ord_revtype4_name,     -- PTS 47740
          'N' as 'cc_selected',     -- PTS 60458 /needed for R_to_PH feature
         0  as 'cc_processed'    -- PTS 60458 /needed for R_to_PH feature
   FROM #temp_rtn1 t, stops
   where t.lgh_number = stops.lgh_number and
         stops.stp_mfh_sequence = 1 and
         stops.stp_schdtearliest between @sch_date1 and @sch_date2
   ORDER BY t.asgn_type, t.asgn_id, t.asgn_date, t.mov_number,t.lgh_number
Else
   SELECT t.lgh_number,
         t.asgn_type,
         t.asgn_id,
         t.asgn_date,
         t.asgn_enddate,
         t.cmp_id_start,
         t.cmp_id_end,
         t.mov_number,
         t.asgn_number,
         t.ord_hdrnumber,
         t.lgh_startcity,
         t.lgh_endcity,
         t.ord_number,
         t.name,
         t.cmp_name_start,
         t.cmp_name_end,
         t.cty_nmstct_start,
         t.cty_nmstct_end,
         t.need_paperwork,
         t.ivh_revtype1,
         t.revtype1_name,
         t.lgh_split_flag,
         t.trip_description,
         t.lgh_type1,
         t.lgh_type_name,
         t.ivh_billdate,
         t.ivh_invoicenumber,
         t.lgh_booked_revtyep1,
         t.ivh_billto,
         t.asgn_controlling,
         t.lgh_shiftdate,  --vjh 33665
         t.lgh_shiftnumber,   --vjh 33665
         t.stp_schdtearliest, -- PTS 47740
         t.ord_route,         -- PTS 47740
         t.cost,              -- PTS 47740
         t.ord_revtype1,         -- PTS 47740
         t.ord_revtype1_name, -- PTS 47740
         t.ord_revtype2,         -- PTS 47740
         t.ord_revtype2_name, -- PTS 47740
         t.ord_revtype3,         -- PTS 47740
         t.ord_revtype3_name, -- PTS 47740
         t.ord_revtype4,         -- PTS 47740
         t.ord_revtype4_name,     -- PTS 47740
          'N' as 'cc_selected',     -- PTS 60458 /needed for R_to_PH feature
         0  as 'cc_processed'    -- PTS 60458 /needed for R_to_PH feature
FROM #temp_rtn1 t
   ORDER BY asgn_type, asgn_id, asgn_date, mov_number,lgh_number

DROP TABLE #temp_rtn

GO
GRANT EXECUTE ON  [dbo].[d_scroll_assignments_sp] TO [public]
GO
