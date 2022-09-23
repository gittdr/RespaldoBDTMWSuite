SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TripsReadyToSettleForAgentPlanningBoard_sp](@drvyes                VARCHAR(3),
                                                            @trcyes                VARCHAR(3),
                                                            @caryes                VARCHAR(3),
                                                            @loenddate             DATETIME,
                                                            @hienddate             DATETIME,
                                                            @lostartdate           DATETIME,
                                                            @histartdate           DATETIME,
                                                            @company               VARCHAR(8),
                                                            @fleet                 VARCHAR(8),
                                                            @division              VARCHAR(8),
                                                            @terminal              VARCHAR(8),
                                                            @drvtyp1               VARCHAR(6),
                                                            @drvtyp2               VARCHAR(6),
                                                            @drvtyp3               VARCHAR(6),
                                                            @drvtyp4               VARCHAR(6),
                                                            @trctyp1               VARCHAR(6),
                                                            @trctyp2               VARCHAR(6),
                                                            @trctyp3               VARCHAR(6),
                                                            @trctyp4               VARCHAR(6),
                                                            @driver                VARCHAR(8),
                                                            @tractor               VARCHAR(8),
                                                            @acct_typ              CHAR(1),
                                                            @carrier               VARCHAR(8),
                                                            @cartyp1               VARCHAR(6),
                                                            @cartyp2               VARCHAR(6),
                                                            @cartyp3               VARCHAR(6),
                                                            @cartyp4               VARCHAR(6),
                                                            @trlyes                VARCHAR(3),
                                                            @trailer               VARCHAR(13),
                                                            @trltyp1               VARCHAR(6),
                                                            @trltyp2               VARCHAR(6),
                                                            @trltyp3               VARCHAR(6),
                                                            @trltyp4               VARCHAR(6),
                                                            @lgh_type1             VARCHAR(6),
                                                            @beg_invoice_bill_date DATETIME,
                                                            @end_invoice_bill_date DATETIME,
                                                            @lgh_booked_revtype1   VARCHAR(256),
                                                            @sch_date1             DATETIME,
                                                            @sch_date2             DATETIME,
                                                            @tpryes                VARCHAR(3),
                                                            @tpr_id                VARCHAR(8),
                                                            @tpr_type              VARCHAR(12),
                                                            @tprtyp1               VARCHAR(6), ----> Must be 'AGENT' ?
                                                            @tprtyp2               VARCHAR(6),
                                                            @tprtyp3               VARCHAR(6),
                                                            @tprtyp4               VARCHAR(6),
                                                            @p_revtype1            VARCHAR(6),
                                                            @p_revtype2            VARCHAR(6),
                                                            @p_revtype3            VARCHAR(6),
                                                            @p_revtype4            VARCHAR(6),
                                                            @inv_status            VARCHAR(100),
                                                            @tprtype1              CHAR(1),
                                                            @tprtype2              CHAR(1),
                                                            @tprtype3              CHAR(1),
                                                            @tprtype4              CHAR(1),
                                                            @tprtype5              CHAR(1),
                                                            @tprtype6              CHAR(1),
                                                            @p_ivh_revtype1        VARCHAR(6),
                                                            @p_ivh_billto          VARCHAR(8),
                                                            @G_USERID              VARCHAR(14),
                                                            @shiftdate             DATETIME, --= '1/1/1950'
                                                            @shiftnumber           VARCHAR(6), -- = 'UNK'
                                                            @resourcetypeonleg     CHAR(1),
                                                            @mpp_teamleader        VARCHAR(6),
                                                            @profile_owner         VARCHAR(12),
                                                            @pytyes                VARCHAR(3),
                                                            @payto_include_id      VARCHAR(12),
                                                            @pyttyp1               VARCHAR(6),
                                                            @pyttyp2               VARCHAR(6),
                                                            @pyttyp3               VARCHAR(6),
                                                            @pyttyp4               VARCHAR(6))
AS

/**
 *
 * NAME:
 * dbo.TripsReadyToSettleForAgentPlanningBoard_sp
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
 * 033 - asgn_payto - The pay to associated to the asset
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
 * 042 - @tprtype1 varchar(6)
 * 043 - @tprtype2 varchar(6)
 * 044 - @tprtype3 varchar(6)
 * 045 - @tprtype4 varchar(6)
 * 046 - @tpr_type varchar(12) ??
 * 047 - @revtype1
 * 048 - @revtype2
 * 049 - @revtype3
 * 050 - @revtype4
 * 051 - @inv_status
 * 052 - @tprtyp1
 * 053 - @tprtyp2
 * 054 - @tprtyp3
 * 055 - @tprtyp4
 * 056 - @tprtyp5
 * 057 - @tprtyp6
 * 058 - @p_ivh_revtype1
 * 059 - @p_ivh_billto
 * 060 - @G_USERID varchar(14)   -- PTS 41389 GAP 74
 * 061 - @shiftdate datetime
 * 062 - @shiftnumber varchar(6)
 * 063 - @resourcetypeonleg Char(1)  -- PTS 48237 - DJM - parameter to tell proc to use mpp_types and trc_types from the leg instead of profile.
 * 064 - @mpp_teamleader         VARCHAR(6)
 * 065 - @profile_owner          VARCHAR(12)
 * 066 - @pytyes                 VARCHAR(3) - whether or not to search by pay to
 * 067 - @payto_include_id       VARCHAR(12) - specific pay to id to search for
 * 068 - @pyttyp1                VARCHAR(6) - pay to type 1 to restrict on
 * 069 - @pyttyp2                VARCHAR(6) - pay to type 2 to restrict on
 * 070 - @pyttyp3                VARCHAR(6) - pay to type 3 to restrict on
 * 071 - @pyttyp4                VARCHAR(6) - pay to type 4 to restrict on
 *
 * REVISION HISTORY:
 * Orginal: 10/15/97 wsc - to replace the 4 union select in the datawindow
 * pts 2722 MF 5/11/98 removed useless where clauses
 * DPETE PTS 16930 1/20/3 If gi setting invoicemustsettle set to N and asset was on trips tagged do not invoice, the trip come up twice
 * PTS 17873 - 4/14/03 - DJM - Modified parameters to include lgh_type1
 * PTS 16945 - 5/2/03 - BAL - Allow user to filter data by invoice billing date
 * PTS 29160 - 5/23/05 - DPH - Modified parameters to include lgh_booked_revtype1
 * 10/11/2005.01 ? PTS29974 - Vince Herman ? add ability to use accounting type
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
 * 2014/07/24 | PTS 80721 | AVANE - Add support for new third party types (follow convention of other assets, which have xyzType1-4)
 * 2014/08/06 | PTS 81134 | AVANE - Add support for filtering by pay to
 * 2014/10/20 | PTS 81134 | AVANE - fix use of accounting type, change PayTo filters to strictly filter to "settle by PayTo" functionality (pto_stlByPayTo)
 * 2017/02/14 | NSUITE-200028 | vjh - Use accounting type from assignment rather than profile
 *                                  - and some DBA guideline fixes
 **/

     SET NOCOUNT ON

     DECLARE @first_invoice INT
     DECLARE @stlmustinv CHAR(1)
     DECLARE @stlmustord CHAR(1)
     DECLARE @stlmustinvLH CHAR(60)
     DECLARE @splitmustinv CHAR(1)
     DECLARE @split_flag CHAR(1)
     DECLARE @li_count INT
     DECLARE @li_mov INT
     DECLARE @ls_tripdesc VARCHAR(255)
     DECLARE @ls_ordnumber VARCHAR(25)
     DECLARE @ls_invstat1 VARCHAR(60)
     DECLARE @ls_invstat2 VARCHAR(60)
     DECLARE @ls_invstat3 VARCHAR(60)
     DECLARE @ls_invstat4 VARCHAR(60)
     DECLARE @paperworkchecklevel VARCHAR(6)
     DECLARE @paperworkmode VARCHAR(3)
     DECLARE @revtype4 VARCHAR(6)
     DECLARE @excludemppterminal VARCHAR(60)
     DECLARE @excludempptype1formttrips VARCHAR(60)
     DECLARE @STLUseLegAcctType CHAR(1)
     DECLARE @agent VARCHAR(3)
     DECLARE @ComputeRevenueByTripSegment CHAR(1)
     DECLARE @paperwork_computed_cutoff_datetime DATETIME
     DECLARE @paperwork_GI_cutoff_datetime DATETIME
     DECLARE @paperwork_GI_cutoff_flag CHAR(1)
     DECLARE @paperwork_GI_cutoff_dayofweek INT
     DECLARE @ls_STL_TRS_Include_Shift CHAR(1)
     DECLARE @min_shift_id INT, @TPRIgnoreStlMustInv CHAR(1)

     --BEGIN PTS 57093 SPN
     DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id INT PRIMARY KEY)
     DECLARE @rowsecurity CHAR(1)
     --END PTS 57093 SPN

     DECLARE @temp_user_branch TABLE(brn_id VARCHAR(12) NULL)

     --BEGIN PTS 57093 SPN
     DECLARE @tmp TABLE
     (mpp_id        VARCHAR(8) NULL,
      mpp_lastfirst VARCHAR(45) NULL,
      mpp_type1     VARCHAR(6) NULL,
      mpp_type2     VARCHAR(6) NULL,
      mpp_type3     VARCHAR(6) NULL,
      mpp_type4     VARCHAR(6) NULL,
      mpp_actg_type CHAR(1) NULL, --PTS 59676 SPN
      mpp_payto     VARCHAR(12) NULL
     )

     DECLARE @tmp1 TABLE
     (trc_number VARCHAR(8) NULL,
      trc_owner  VARCHAR(12) NULL,
      trc_type1  VARCHAR(6) NULL,
      trc_type2  VARCHAR(6) NULL,
      trc_type3  VARCHAR(6) NULL,
      trc_type4  VARCHAR(6) NULL
     )

     DECLARE @tmp2 TABLE
     (car_id   VARCHAR(8) NULL,
      car_name VARCHAR(64) NULL,
      pto_id   VARCHAR(12) NULL
     )

     DECLARE @tmp3 TABLE
     (trl_id    VARCHAR(13) NULL,
      trl_owner VARCHAR(12) NULL
     )

     DECLARE @tmp4 TABLE
     (tpr_id    VARCHAR(8) NULL,
      tpr_name  VARCHAR(30) NULL,
      tpr_payto VARCHAR(12) NULL
     )

     DECLARE @tmp5 TABLE
     (pto_id    VARCHAR(12) NULL,
      pto_type1 VARCHAR(6) NULL,
      pto_type2 VARCHAR(6) NULL,
      pto_type3 VARCHAR(6) NULL,
      pto_type4 VARCHAR(6) NULL
     )

     --END PTS 57093 SPN

     /* Create a temporary table for data return set */

     CREATE TABLE #temp_rtn
     (lgh_number          INT NOT NULL,
      asgn_type           VARCHAR(6) NOT NULL,
      asgn_id             VARCHAR(13) NOT NULL,
      asgn_date           DATETIME NULL,
      asgn_enddate        DATETIME NULL,
      cmp_id_start        VARCHAR(8) NULL,
      cmp_id_end          VARCHAR(8) NULL,
      mov_number          INT NULL,
      asgn_number         INT NULL,
      ord_hdrnumber       INT NULL,
      lgh_startcity       INT NULL,
      lgh_endcity         INT NULL,
      ord_number          VARCHAR(12) NULL,
      name                VARCHAR(64) NULL,
      cmp_name_start      VARCHAR(100) NULL,
      cmp_name_end        VARCHAR(100) NULL,
      cty_nmstct_start    VARCHAR(25) NULL,
      cty_nmstct_end      VARCHAR(25) NULL,
      need_paperwork      INT NULL,
      ivh_revtype1        VARCHAR(6) NULL,
      revtype1_name       VARCHAR(8) NULL,
      lgh_split_flag      CHAR(1) NULL,
      trip_description    VARCHAR(255) NULL,
      lgh_type1           VARCHAR(6) NULL,
      lgh_type_name       VARCHAR(8) NULL,
      ivh_billdate        DATETIME NULL,
      ivh_invoicenumber   VARCHAR(12) NULL,
      lgh_booked_revtype1 VARCHAR(20) NULL,
      ivh_billto          VARCHAR(8) NULL,
      asgn_controlling    VARCHAR(1) NULL,
      lgh_shiftdate       DATETIME NULL,
      lgh_shiftnumber     VARCHAR(6) NULL,
      shift_ss_id         INT NULL,
      stp_schdtearliest   DATETIME NULL,
      ord_route           VARCHAR(18) NULL,
      Cost                MONEY NULL,
      ord_revtype1        VARCHAR(6) NULL,
      ord_revtype1_name   VARCHAR(20) NULL,
      ord_revtype2        VARCHAR(6) NULL,
      ord_revtype2_name   VARCHAR(20) NULL,
      ord_revtype3        VARCHAR(6) NULL,
      ord_revtype3_name   VARCHAR(20) NULL,
      ord_revtype4        VARCHAR(6) NULL,
      ord_revtype4_name   VARCHAR(20) NULL,
      lgh_type2           VARCHAR(6) NULL,
      lgh_type3           VARCHAR(6) NULL,
      lgh_type4           VARCHAR(6) NULL,
      asgn_payto          VARCHAR(12) NULL
     )

     CREATE TABLE #temp_rtn1
     (lgh_number          INT NOT NULL,
      asgn_type           VARCHAR(6) NOT NULL,
      asgn_id             VARCHAR(13) NOT NULL,
      asgn_date           DATETIME NULL,
      asgn_enddate        DATETIME NULL,
      cmp_id_start        VARCHAR(8) NULL,
      cmp_id_end          VARCHAR(8) NULL,
      mov_number          INT NULL,
      asgn_number         INT NULL,
      ord_hdrnumber       INT NULL,
      lgh_startcity       INT NULL,
      lgh_endcity         INT NULL,
      ord_number          VARCHAR(12) NULL,
      name                VARCHAR(64) NULL,
      cmp_name_start      VARCHAR(100) NULL,
      cmp_name_end        VARCHAR(100) NULL,
      cty_nmstct_start    VARCHAR(25) NULL,
      cty_nmstct_end      VARCHAR(25) NULL,
      need_paperwork      INT NULL,
      ivh_revtype1        VARCHAR(6) NULL,
      revtype1_name       VARCHAR(8) NULL,
      lgh_split_flag      CHAR(1) NULL,
      trip_description    VARCHAR(255) NULL,
      lgh_type1           VARCHAR(6) NULL,
      lgh_type_name       VARCHAR(8) NULL,
      ivh_billdate        DATETIME NULL,
      ivh_invoicenumber   VARCHAR(12) NULL,
      lgh_booked_revtyep1 VARCHAR(20) NULL,
      ivh_billto          VARCHAR(8) NULL,
      asgn_controlling    VARCHAR(1) NULL,
      lgh_shiftdate       DATETIME NULL,
      lgh_shiftnumber     VARCHAR(6) NULL,
      shift_ss_id         INT NULL,
      stp_schdtearliest   DATETIME NULL,
      ord_route           VARCHAR(18) NULL,
      Cost                MONEY NULL,
      ord_revtype1        VARCHAR(6) NULL,
      ord_revtype1_name   VARCHAR(20) NULL,
      ord_revtype2        VARCHAR(6) NULL,
      ord_revtype2_name   VARCHAR(20) NULL,
      ord_revtype3        VARCHAR(6) NULL,
      ord_revtype3_name   VARCHAR(20) NULL,
      ord_revtype4        VARCHAR(6) NULL,
      ord_revtype4_name   VARCHAR(20) NULL,
      lgh_type2           VARCHAR(6) NULL,
      lgh_type3           VARCHAR(6) NULL,
      lgh_type4           VARCHAR(6) NULL,
      asgn_payto          VARCHAR(12) NULL
     )

     CREATE TABLE #temp_pwk
     (lgh_number    INT NULL,
      ord_hdrnumber INT NULL,
      req_cnt       INT NULL,
      rec_cnt       INT NULL,
      ord_billto    VARCHAR(8) NULL
     )

     --vjh PTS 45562
     CREATE TABLE #temp_Orders
     (lgh_number    INT NULL,
      ord_hdrnumber INT NULL,
      Inv_OK_Flag   CHAR(1) NULL,
      Ord_OK_Flag   CHAR(1) NULL
     )

     --GENERAL INFO MASTER LOOKUP BEGIN

     DECLARE @GI_VALUES_TO_LOOKUP TABLE(gi_name VARCHAR(30) PRIMARY KEY);

     DECLARE @GIKEY TABLE
     (gi_name     VARCHAR(30) PRIMARY KEY,
      gi_string1  VARCHAR(60),
      gi_string2  VARCHAR(60),
      gi_string3  VARCHAR(60),
      gi_string4  VARCHAR(60),
      gi_integer1 INT,
      gi_integer2 INT,
      gi_integer3 INT,
      gi_integer4 INT,
      gi_date1    DATETIME
     );

     INSERT INTO @GI_VALUES_TO_LOOKUP
     VALUES
     --Replace these lookups with value(s) that match your needs.
     ('RowSecurity'), ('PaperWorkCutOffDate'), ('COMPUTEREVENUEBYTRIPSEGMENT'), ('StlXInvStat'), ('SPLITMUSTINV'), ('STLMUSTINV'), ('STLMUSTORD'), ('TPRIgnoreStlMustInv'), ('STL_TRS_Include_Shift'), ('TRSExcludeNonPayableTrips'), ('STLUseLegAcctType'), ('TRSExcludeDrvTerminal'), ('TRSExcludeDrvType1WithMTTrips'), ('TRSExcludeDrvType1WithICTrips'), ('AgentCommiss'), ('ThirdPartyTypes'), ('TripStlExcludeRevtypefromQ'), ('PaperWorkMode'), ('PaperWorkCheckLevel'), ('TrackBranch'), ('BRANCHUSERSECURITY'), ('STLApprvdCarrierOnly')
     --,('Add additional values here')
     ;

     INSERT INTO @GIKEY
     (gi_name
    , gi_string1
    , gi_string2
    , gi_string3
    , gi_string4
    , gi_integer1
    , gi_integer2
    , gi_integer3
    , gi_integer4
    , gi_date1
     )
            SELECT gi_name
                 , gi_string1
                 , gi_string2
                 , gi_string3
                 , gi_string4
                 , gi_integer1
                 , gi_integer2
                 , gi_integer3
                 , gi_integer4
                 , gi_date1
            FROM
            (
                SELECT gvtlu.gi_name
                     , g.gi_string1
                     , g.gi_string2
                     , g.gi_string3
                     , g.gi_string4
                     , gi_integer1
                     , gi_integer2
                     , gi_integer3
                     , gi_integer4
                     , gi_date1
                       --What we're doing here is checking the date of the generalInfo row in case there are multiples.
                       --This will order the rows in descending date order with the following exceptions.
                       --Future dates are dropped to last priority by moving to less than the apocalypse.
                       --Nulls are moved to second to last priority by using the apocalypse.
                       --Everything else is ordered descending.
                       --We then take the "newest".
                     , ROW_NUMBER() OVER(PARTITION BY gvtlu.gi_name ORDER BY CASE
                                                                                 WHEN g.gi_datein > GETDATE()
                                                                                 THEN '1/1/1949'
                                                                                 ELSE COALESCE(g.gi_datein, '1/1/1950')
                                                                             END DESC) RN
                FROM @GI_VALUES_TO_LOOKUP gvtlu
                     LEFT OUTER JOIN dbo.generalinfo g ON gvtlu.gi_name = g.gi_name
            ) subQuery
            WHERE RN = 1; --   <---This is how we take the top 1.

     --GENERAL INFO MASTER LOOKUP END

     SELECT @rowsecurity = gi_string1
     FROM @GIKEY
     WHERE gi_name = 'RowSecurity'

     IF @rowsecurity = 'Y'
         INSERT INTO @tbl_restrictedbyuser
                SELECT rowsec_rsrv_id
                FROM RowRestrictValidAssignments_orderheader_fn()
     ELSE
     INSERT INTO @tbl_restrictedbyuser(rowsec_rsrv_id)
            SELECT 0

     IF @drvyes <> 'XXX'
         INSERT INTO @tmp
                SELECT DISTINCT
                       mpp_id
                     , mpp_lastfirst
                     , mpp_type1
                     , mpp_type2
                     , mpp_type3
                     , mpp_type4
                     , mpp_actg_type
                     , mpp_payto
                FROM manpowerprofile
                     JOIN RowRestrictValidAssignments_manpowerprofile_fn() rsva ON manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                                                   OR rsva.rowsec_rsrv_id = 0
                WHERE(@driver = mpp_id
                      OR @driver = 'UNKNOWN')
                     AND ((@acct_typ = 'X'
                           AND mpp_actg_type IN('A', 'P'))
                OR (@acct_typ = mpp_actg_type))
                     AND (@company = 'UNK'
                          OR @company = mpp_company)
                     AND (@fleet = 'UNK'
                          OR @fleet = mpp_fleet)
                     AND (@division = 'UNK'
                          OR @division = mpp_division)
                     AND (@terminal = 'UNK'
                          OR @terminal = mpp_terminal)
                     AND (@drvtyp1 = 'UNK'
                          OR @drvtyp1 = mpp_type1)
                     AND (@drvtyp2 = 'UNK'
                          OR @drvtyp2 = mpp_type2)
                     AND (@drvtyp3 = 'UNK'
                          OR @drvtyp3 = mpp_type3)
                     AND (@drvtyp4 = 'UNK'
                          OR @drvtyp4 = mpp_type4)
                     AND (@mpp_teamleader = 'UNK'
                          OR @mpp_teamleader = mpp_teamleader)
                     AND (@profile_owner = 'UNKNOWN'
                          OR @profile_owner = mpp_payto)

     IF @trcyes <> 'XXX'
         INSERT INTO @tmp1
                SELECT DISTINCT
                       trc_number
                     , trc_owner
                     , trc_type1
                     , trc_type2
                     , trc_type3
                     , trc_type4
                FROM tractorprofile
                     JOIN RowRestrictValidAssignments_tractorprofile_fn() rsva ON tractorprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                                                  OR rsva.rowsec_rsrv_id = 0
                WHERE(@tractor = trc_number
                      OR @tractor = 'UNKNOWN')
                     AND ((@acct_typ = 'X'
                           AND trc_actg_type IN('A', 'P'))
                OR (@acct_typ = trc_actg_type))
                     AND (@company = 'UNK'
                          OR @company = trc_company)
                     AND (@fleet = 'UNK'
                          OR @fleet = trc_fleet)
                     AND (@division = 'UNK'
                          OR @division = trc_division)
                     AND (@terminal = 'UNK'
                          OR @terminal = trc_terminal)
                     AND (@trctyp1 = 'UNK'
                          OR @trctyp1 = trc_type1)
                     AND (@trctyp2 = 'UNK'
                          OR @trctyp2 = trc_type2)
                     AND (@trctyp3 = 'UNK'
                          OR @trctyp3 = trc_type3)
                     AND (@trctyp4 = 'UNK'
                          OR @trctyp4 = trc_type4)
                     AND (@profile_owner = 'UNKNOWN'
                          OR @profile_owner = trc_owner
                          OR @profile_owner = trc_owner2)

     IF @caryes <> 'XXX'
         INSERT INTO @tmp2
                SELECT DISTINCT
                       car_id
                     , car_name
                     , pto_id
                FROM carrier
                     JOIN RowRestrictValidAssignments_carrier_fn() rsva ON carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                                           OR rsva.rowsec_rsrv_id = 0
                WHERE(@carrier = car_id
                      OR @carrier = 'UNKNOWN')
                     AND ((@acct_typ = 'X'
                           AND car_actg_type IN('A', 'P'))
                OR (@acct_typ = car_actg_type))
                     AND (@cartyp1 = 'UNK'
                          OR @cartyp1 = car_type1)
                     AND (@cartyp2 = 'UNK'
                          OR @cartyp2 = car_type2)
                     AND (@cartyp3 = 'UNK'
                          OR @cartyp3 = car_type3)
                     AND (@cartyp4 = 'UNK'
                          OR @cartyp4 = car_type4)
                     AND (@profile_owner = 'UNKNOWN'
                          OR @profile_owner = pto_id)

     IF @trlyes <> 'XXX'
         INSERT INTO @tmp3
                SELECT DISTINCT
                       trl_id
                     , trl_owner
                FROM trailerprofile
                     JOIN RowRestrictValidAssignments_trailerprofile_fn() rsva ON trailerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                                                  OR rsva.rowsec_rsrv_id = 0
                WHERE(@trailer = trl_id
                      OR @trailer = 'UNKNOWN')
                     AND ((@acct_typ = 'X'
                           AND trl_actg_type IN('A', 'P'))
                OR (@acct_typ = trl_actg_type))
                     AND (@company = 'UNK'
                          OR @company = trl_company)
                     AND (@fleet = 'UNK'
                          OR @fleet = trl_fleet)
                     AND (@division = 'UNK'
                          OR @division = trl_division)
                     AND (@terminal = 'UNK'
                          OR @terminal = trl_terminal)
                     AND (@trltyp1 = 'UNK'
                          OR @trltyp1 = trl_type1)
                     AND (@trltyp2 = 'UNK'
                          OR @trltyp2 = trl_type2)
                     AND (@trltyp3 = 'UNK'
                          OR @trltyp3 = trl_type3)
                     AND (@trltyp4 = 'UNK'
                          OR @trltyp4 = trl_type4)
                     AND (@profile_owner = 'UNKNOWN'
                          OR @profile_owner = trl_owner)

     -- Grab all pay tos by search filters
     INSERT INTO @tmp5
            SELECT DISTINCT
                   pto_id
                 , pto_type1
                 , pto_type2
                 , pto_type3
                 , pto_type4
            FROM payto
                 JOIN RowRestrictValidAssignments_payto_fn() rsva ON payto.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                                     OR rsva.rowsec_rsrv_id = 0
            WHERE(@payto_include_id = pto_id
                  OR @payto_include_id = 'UNKNOWN')
                 AND (@pyttyp1 = 'UNK'
                      OR @pyttyp1 = pto_type1)
                 AND (@pyttyp2 = 'UNK'
                      OR @pyttyp2 = pto_type2)
                 AND (@pyttyp3 = 'UNK'
                      OR @pyttyp3 = pto_type3)
                 AND (@pyttyp4 = 'UNK'
                      OR @pyttyp4 = pto_type4)
                 AND (COALESCE(pto_stlByPayTo, 0) = 1)

     IF @pytyes <> 'XXX'
         BEGIN
             -- Remove assets matched by pay tos who do not settle by payto, from their respective work lists
             DELETE FROM @tmp
             WHERE mpp_payto IS NULL
                   OR NOT EXISTS
             (
                 SELECT *
                 FROM @tmp5
                 WHERE mpp_payto = pto_id
             )

             DELETE FROM @tmp1
             WHERE trc_owner IS NULL
                   OR NOT EXISTS
             (
                 SELECT *
                 FROM @tmp5
                 WHERE trc_owner = pto_id
             )

             DELETE car
             FROM @tmp2 car
             WHERE car.pto_id IS NULL
                   OR NOT EXISTS
             (
                 SELECT *
                 FROM @tmp5 pto
                 WHERE car.pto_id = pto.pto_id
             )

             DELETE FROM @tmp3
             WHERE trl_owner IS NULL
                   OR NOT EXISTS
             (
                 SELECT *
                 FROM @tmp5
                 WHERE trl_owner = pto_id
             )

             DELETE FROM @tmp4
             WHERE tpr_payto IS NULL
                   OR NOT EXISTS
             (
                 SELECT *
                 FROM @tmp5
                 WHERE tpr_payto = pto_id
             )
         END
     ELSE
         BEGIN
             -- Remove assets matched by pay tos who settle by payto, from their respective work lists
             DELETE FROM @tmp
             WHERE mpp_payto IS NOT NULL
                   AND EXISTS
             (
                 SELECT *
                 FROM @tmp5
                 WHERE mpp_payto = pto_id
             )

             DELETE FROM @tmp1
             WHERE trc_owner IS NOT NULL
                   AND EXISTS
             (
                 SELECT *
                 FROM @tmp5
                 WHERE trc_owner = pto_id
             )

             DELETE car
             FROM @tmp2 car
             WHERE car.pto_id IS NOT NULL
                   AND EXISTS
             (
                 SELECT *
                 FROM @tmp5 pto
                 WHERE car.pto_id = pto.pto_id
             )

             DELETE FROM @tmp3
             WHERE trl_owner IS NOT NULL
                   AND EXISTS
             (
                 SELECT *
                 FROM @tmp5
                 WHERE trl_owner = pto_id
             )

             DELETE FROM @tmp4
             WHERE tpr_payto IS NOT NULL
                   AND EXISTS
             (
                 SELECT *
                 FROM @tmp5
                 WHERE tpr_payto = pto_id
             )
         END

     --vjh 45500 get pieces used for paperwork cutoff
     SELECT @paperwork_GI_cutoff_flag = UPPER(LEFT(gi_string1, 1))
          , @paperwork_GI_cutoff_dayofweek = gi_integer1
          , @paperwork_GI_cutoff_datetime = gi_date1
     FROM @GIKEY
     WHERE gi_name = 'PaperWorkCutOffDate'
     IF @paperwork_GI_cutoff_flag IS NULL
         SELECT @paperwork_GI_cutoff_flag = 'N'
     IF @paperwork_GI_cutoff_flag = 'N'
         BEGIN
             SELECT @paperwork_computed_cutoff_datetime = '2049-12-31 23:59'
         END
     ELSE
         BEGIN
             -- compute the paperwork cutoff datetime
             -- datetime from GI, plus the number of days from then to now
             -- so @computed_cutoff_datetime holds today's date with the time from the GI
             SELECT @paperwork_computed_cutoff_datetime = DATEADD(day, DATEDIFF(day, @paperwork_GI_cutoff_datetime, GETDATE()), @paperwork_GI_cutoff_datetime)
             -- now subtract the dayofweek of today and then add the dayof week from GI
             SELECT @paperwork_computed_cutoff_datetime = DATEADD(day, @paperwork_GI_cutoff_dayofweek - DATEPART(dw, GETDATE()), @paperwork_computed_cutoff_datetime)
         END

     --PTS 41600 SLM 6/2/2008
     SELECT @ComputeRevenueByTripSegment = UPPER(gi_string1)
     FROM @GIKEY
     WHERE UPPER(gi_name) = 'COMPUTEREVENUEBYTRIPSEGMENT'
     --vjh 45562
     SELECT @ls_invstat1 = gi_string1
          , @ls_invstat2 = gi_string2
          , @ls_invstat3 = gi_string3
          , @ls_invstat4 = gi_string4
     FROM @GIKEY
     WHERE gi_name = 'StlXInvStat'

     SELECT @ls_invstat1 = COALESCE(@ls_invstat1, '')
     SELECT @ls_invstat2 = COALESCE(@ls_invstat2, @ls_invstat1)
     SELECT @ls_invstat3 = COALESCE(@ls_invstat3, @ls_invstat1)
     SELECT @ls_invstat4 = COALESCE(@ls_invstat4, @ls_invstat1)

     SELECT @splitmustinv = SUBSTRING(UPPER(gi_string1), 1, 1)
     FROM @GIKEY
     WHERE gi_name = 'SPLITMUSTINV'

     SELECT @stlmustinv = SUBSTRING(UPPER(gi_string1), 1, 1)
          , @stlmustinvLH = UPPER(gi_string2)
     FROM @GIKEY
     WHERE gi_name = 'STLMUSTINV'

     SELECT @stlmustord = SUBSTRING(UPPER(gi_string1), 1, 1)
     FROM @GIKEY
     WHERE gi_name = 'STLMUSTORD'  --vjh 52942

     --	LOR	PTS# 60638
     SELECT @TPRIgnoreStlMustInv = 'N'
     SELECT @TPRIgnoreStlMustInv = SUBSTRING(UPPER(gi_string1), 1, 1)
     FROM @GIKEY
     WHERE gi_name = 'TPRIgnoreStlMustInv'
     IF @TPRIgnoreStlMustInv = 'Y'
        AND @stlmustinv = 'Y'
        AND @tpryes <> 'XXX'
         SET @stlmustinv = 'N'
     --	LOR

     IF @stlmustinvLH IS NULL
        OR @stlmustinvLH <> 'ALL'
         SET @stlmustinvLH = 'LH'
     --vjh 45381
     SELECT @ls_STL_TRS_Include_Shift = UPPER(LEFT(gi_string1, 1))
     FROM @GIKEY
     WHERE gi_name = 'STL_TRS_Include_Shift'
     IF @ls_STL_TRS_Include_Shift IS NULL
         SELECT @ls_STL_TRS_Include_Shift = 'N'

     ---------------------------------------------------------------------------------------------------------------
     -- PTS 41389 GAP 74 Start
     IF @lgh_booked_revtype1 IS NULL
        OR @lgh_booked_revtype1 = ''
        OR @lgh_booked_revtype1 = 'UNK'
         BEGIN
             SELECT @lgh_booked_revtype1 = 'UNKNOWN'
         END

     SELECT @lgh_booked_revtype1 = ','+LTRIM(RTRIM(COALESCE(@lgh_booked_revtype1, '')))+','
     -- PTS 41389 GAP 74 end
     ---------------------------------------------------------------------------------------------------------------

     IF EXISTS
     (
         SELECT *
         FROM @GIKEY
         WHERE gi_name = 'TRSExcludeNonPayableTrips'
               AND gi_string1 = 'Y'
     )
         UPDATE assetassignment
           SET
               pyd_status = 'PPD'
         WHERE asgn_status = 'CMP'
               AND pyd_status = 'NPD'
               AND NOT EXISTS
         (
             SELECT *
             FROM stops
             WHERE stops.lgh_number = assetassignment.lgh_number
                   AND COALESCE(stops.stp_paylegpt, 'N') = 'Y'
         )

     -- vjh 30395 move here so that all resource types can use it
     SELECT @STLUseLegAcctType = 'N'
     IF EXISTS
     (
         SELECT *
         FROM @GIKEY
         WHERE gi_name = 'STLUseLegAcctType'
               AND COALESCE(gi_string1, '') <> ''
     )
         BEGIN
             SELECT @STLUseLegAcctType = UPPER(LEFT(gi_string1, 1))
             FROM @GIKEY
             WHERE gi_name = 'STLUseLegAcctType'
         END

     -- PTS 3223781 - DJM
     SELECT @inv_status = ','+LTRIM(RTRIM(COALESCE(@inv_status, 'UNK')))+','

     --BEGIN DRIVERS
     IF @drvyes <> 'XXX'
        OR EXISTS
     (
         SELECT *
         FROM @tmp
     )
         BEGIN
             IF @driver = 'UNKNOWN'
                 BEGIN
                     -- JD 28117 Exclude drivers that belong to the terminal specified by the gi setting TRSExcludeDrvTerminal
                     IF EXISTS
                     (
                         SELECT *
                         FROM @GIKEY
                         WHERE gi_name = 'TRSExcludeDrvTerminal'
                               AND COALESCE(gi_string1, '') <> ''
                     )
                         BEGIN
                             SELECT @excludemppterminal = gi_string1
                             FROM @GIKEY
                             WHERE gi_name = 'TRSExcludeDrvTerminal'
                             SELECT @excludemppterminal = ','+@excludemppterminal+','
                             UPDATE assetassignment
                               SET
                                   pyd_status = 'PPD'
                             FROM manpowerprofile mpp
                             WHERE asgn_type = 'DRV'
                                   AND mpp.mpp_id = asgn_id
                                   AND CHARINDEX(mpp.mpp_terminal, @excludemppterminal) > 0
                                   AND asgn_status = 'CMP'
                                   AND pyd_status = 'NPD'
                                   AND asgn_date BETWEEN @lostartdate AND @histartdate
                                   AND asgn_enddate BETWEEN @loenddate AND @hienddate

                         END
                     -- end 28117 JD

                     -- JD 28169 Exclude drivers that belong to the mpp_type1 specified by string1 and that have fully MT trips (i.e no loaded stops on the trip seg)
                     IF EXISTS
                     (
                         SELECT *
                         FROM @GIKEY
                         WHERE gi_name = 'TRSExcludeDrvType1WithMTTrips'
                               AND COALESCE(gi_string1, '') <> ''
                     )
                         BEGIN
                             SELECT @excludempptype1formttrips = gi_string1
                             FROM @GIKEY
                             WHERE gi_name = 'TRSExcludeDrvType1WithMTTrips'
                             SELECT @excludempptype1formttrips = ','+@excludempptype1formttrips+','
                             UPDATE assetassignment
                               SET
                                   pyd_status = 'PPD'
                             FROM manpowerprofile mpp
                             WHERE asgn_type = 'DRV'
                                   AND mpp.mpp_id = asgn_id
                                   AND CHARINDEX(mpp.mpp_type1, @excludempptype1formttrips) > 0
                                   AND asgn_status = 'CMP'
                                   AND pyd_status = 'NPD'
                                   AND asgn_date BETWEEN @lostartdate AND @histartdate
                                   AND asgn_enddate BETWEEN @loenddate AND @hienddate
                                   AND NOT EXISTS
                             (
                                 SELECT *
                                 FROM stops
                                 WHERE stops.lgh_number = assetassignment.lgh_number
                                       AND stops.stp_loadstatus = 'LD'
                             )
                         END

                     --  Exclude drivers that belong to the mpp_type1 specified by string1 and that have all intracity stops on the trip segment
                     SELECT @excludempptype1formttrips = NULL
                     IF EXISTS
                     (
                         SELECT *
                         FROM @GIKEY
                         WHERE gi_name = 'TRSExcludeDrvType1WithICTrips'
                               AND COALESCE(gi_string1, '') <> ''
                     )
                         BEGIN
                             SELECT @excludempptype1formttrips = gi_string1
                             FROM @GIKEY
                             WHERE gi_name = 'TRSExcludeDrvType1WithICTrips'
                             SELECT @excludempptype1formttrips = ','+@excludempptype1formttrips+','

                             UPDATE assetassignment
                               SET
                                   pyd_status = 'PPD'
                             FROM manpowerprofile mpp
                             WHERE asgn_type = 'DRV'
                                   AND mpp.mpp_id = asgn_id
                                   AND CHARINDEX(mpp.mpp_type1, @excludempptype1formttrips) > 0
                                   AND asgn_status = 'CMP'
                                   AND pyd_status = 'NPD'
                                   AND asgn_date BETWEEN @lostartdate AND @histartdate
                                   AND asgn_enddate BETWEEN @loenddate AND @hienddate
                                   AND lgh_number IN
                             (
                                 SELECT c.lgh_number
                                 FROM stops c
                                 WHERE c.lgh_number = assetassignment.lgh_number
                                       AND EXISTS
                                 (
                                     SELECT *
                                     FROM stops d
                                        , stops e
                                     WHERE d.lgh_number = c.lgh_number
                                           AND d.lgh_number = e.lgh_number
                                           AND d.stp_mfh_sequence = 1
                                           AND e.stp_mfh_sequence = 2
                                           AND e.stp_loadstatus = 'MT'
                                           AND d.stp_city = e.stp_city
                                 )
                                 GROUP BY c.lgh_number
                                 HAVING COUNT(*) = 2
                             )

                         END
                 END

             IF @STLUseLegAcctType = 'Y'
                 BEGIN
                     IF @ls_STL_TRS_Include_Shift = 'N'
                         BEGIN
                             --***(1a)
                             INSERT INTO #temp_rtn
                             (lgh_number
                            , asgn_type
                            , asgn_id
                            , asgn_date
                            , asgn_enddate
                            , cmp_id_start
                            , cmp_id_end
                            , mov_number
                            , asgn_number
                            , ord_hdrnumber
                            , lgh_startcity
                            , lgh_endcity
                            , ord_number
                            , name
                            , cmp_name_start
                            , cmp_name_end
                            , cty_nmstct_start
                            , cty_nmstct_end
                            , need_paperwork
                            , ivh_revtype1
                            , revtype1_name
                            , lgh_split_flag
                            , trip_description
                            , lgh_type1
                            , lgh_type_name
                            , ivh_billdate
                            , ivh_invoicenumber
                            , lgh_booked_revtype1
                            , ivh_billto
                            , asgn_controlling
                            , lgh_shiftdate
                            , lgh_shiftnumber
                            , shift_ss_id
                            , stp_schdtearliest
                            , ord_route
                            , Cost
                            , ord_revtype1
                            , ord_revtype1_name
                            , ord_revtype2
                            , ord_revtype2_name
                            , ord_revtype3
                            , ord_revtype3_name
                            , ord_revtype4
                            , ord_revtype4_name
                            , lgh_type2
                            , lgh_type3
                            , lgh_type4
                            , asgn_payto
                             )
                                    SELECT a.lgh_number
                                         , a.asgn_type
                                         , a.asgn_id
                                         , a.asgn_date
                                         , a.asgn_enddate
                                         , ''
                                         , ''
                                         , a.mov_number
                                         , a.asgn_number
                                         , 0
                                         , 0
                                         , 0
                                         , ''
                                         , mpp_lastfirst
                                         , ''
                                         , ''
                                         , ''
                                         , ''
                                         , 0
                                         , ''
                                         , 'RevType1'
                                         , 'N'
                                         , ''
                                         , 'UNK'
                                         , 'LghType1'
                                         , NULL
                                         , NULL
                                         , 'Lgh_Booked_Revtype1'
                                         , 'IvhBillT'
                                         , a.asgn_controlling
                                         , l.lgh_shiftdate
                                         , l.lgh_shiftnumber
                                         , l.shift_ss_id
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , #tmp.mpp_payto
                                    FROM assetassignment a
                                         INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                   AND (@shiftdate = '1950-01-01 00:00'
                                                                        OR @shiftdate = l.lgh_shiftdate)
                                                                   AND (@shiftnumber = 'UNK'
                                                                        OR @shiftnumber = l.lgh_shiftnumber)
                                                                   AND a.asgn_type = 'DRV'
                                       , @tmp #tmp
                                    WHERE a.asgn_type = 'DRV'
                                          AND a.asgn_id = mpp_id
                                          AND a.asgn_status = 'CMP'
                                          AND pyd_status = 'NPD'
                                          AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                                          AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
                                          AND ((@acct_typ = 'X'
                                                AND a.actg_type IN('A', 'P'))
                                    OR (@acct_typ = actg_type))
                                         AND (@drvtyp1 = 'UNK'
                                              OR @drvtyp1 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type1
                                                                 ELSE #tmp.mpp_type1
                                                             END))
                                         AND (@drvtyp2 = 'UNK'
                                              OR @drvtyp2 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type2
                                                                 ELSE #tmp.mpp_type2
                                                             END))
                                         AND (@drvtyp3 = 'UNK'
                                              OR @drvtyp3 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type3
                                                                 ELSE #tmp.mpp_type3
                                                             END))
                                         AND (@drvtyp4 = 'UNK'
                                              OR @drvtyp4 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type4
                                                                 ELSE #tmp.mpp_type4
                                                             END))
                         END
                     ELSE
                         BEGIN
                             --***(1b)
                             --vjh 45381 new insert for join to shiftschedules table and restrictions based on that.
                             INSERT INTO #temp_rtn
                             (lgh_number
                            , asgn_type
                            , asgn_id
                            , asgn_date
                            , asgn_enddate
                            , cmp_id_start
                            , cmp_id_end
                            , mov_number
                            , asgn_number
                            , ord_hdrnumber
                            , lgh_startcity
                            , lgh_endcity
                            , ord_number
                            , name
                            , cmp_name_start
                            , cmp_name_end
                            , cty_nmstct_start
                            , cty_nmstct_end
                            , need_paperwork
                            , ivh_revtype1
                            , revtype1_name
                            , lgh_split_flag
                            , trip_description
                            , lgh_type1
                            , lgh_type_name
                            , ivh_billdate
                            , ivh_invoicenumber
                            , lgh_booked_revtype1
                            , ivh_billto
                            , asgn_controlling
                            , lgh_shiftdate
                            , lgh_shiftnumber
                            , shift_ss_id
                            , stp_schdtearliest
                            , ord_route
                            , Cost
                            , ord_revtype1
                            , ord_revtype1_name
                            , ord_revtype2
                            , ord_revtype2_name
                            , ord_revtype3
                            , ord_revtype3_name
                            , ord_revtype4
                            , ord_revtype4_name
                            , lgh_type2
                            , lgh_type3
                            , lgh_type4
                            , asgn_payto
                             )
                                    SELECT a.lgh_number
                                         , a.asgn_type
                                         , a.asgn_id
                                         , a.asgn_date
                                         , a.asgn_enddate
                                         , ''
                                         , ''
                                         , a.mov_number
                                         , a.asgn_number
                                         , 0
                                         , 0
                                         , 0
                                         , ''
                                         , mpp_lastfirst
                                         , ''
                                         , ''
                                         , ''
                                         , ''
                                         , 0
                                         , ''
                                         , 'RevType1'
                                         , 'N'
                                         , ''
                                         , 'UNK'
                                         , 'LghType1'
                                         , NULL
                                         , NULL
                                         , 'Lgh_Booked_Revtype1'
                                         , 'IvhBillT'
                                         , a.asgn_controlling
                                         , l.lgh_shiftdate
                                         , l.lgh_shiftnumber
                                         , l.shift_ss_id
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , #tmp.mpp_payto
                                    FROM assetassignment a
                                         INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                   AND (@shiftdate = '1950-01-01 00:00'
                                                                        OR @shiftdate = l.lgh_shiftdate)
                                                                   AND (@shiftnumber = 'UNK'
                                                                        OR @shiftnumber = l.lgh_shiftnumber)
                                                                   AND a.asgn_type = 'DRV'
                                         LEFT JOIN shiftschedules s ON l.shift_sS_id = s.ss_id
                                       , @tmp #tmp
                                    WHERE a.asgn_type = 'DRV'
                                          AND a.asgn_id = #tmp.mpp_id
                                          AND a.asgn_status = 'CMP'
                                          AND pyd_status = 'NPD'
                                          AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                                          AND s.ss_starttime BETWEEN @loenddate AND @hienddate
                                          AND ((@acct_typ = 'X'
                                                AND a.actg_type IN('A', 'P'))
                                    OR (@acct_typ = actg_type))
                                         AND (@drvtyp1 = 'UNK'
                                              OR @drvtyp1 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type1
                                                                 ELSE #tmp.mpp_type1
                                                             END))
                                         AND (@drvtyp2 = 'UNK'
                                              OR @drvtyp2 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type2
                                                                 ELSE #tmp.mpp_type2
                                                             END))
                                         AND (@drvtyp3 = 'UNK'
                                              OR @drvtyp3 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type3
                                                                 ELSE #tmp.mpp_type3
                                                             END))
                                         AND (@drvtyp4 = 'UNK'
                                              OR @drvtyp4 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type4
                                                                 ELSE #tmp.mpp_type4
                                                             END))

                             --vjh 45381 walk through each shift and grab any trips that fell outside of the date range but have same shift
                             SELECT @min_shift_id = MIN(shift_ss_id)
                             FROM #temp_rtn
                             WHERE shift_ss_id IS NOT NULL
                                   AND shift_ss_id > 0
                                   AND asgn_type = 'DRV'
                             WHILE @min_shift_id IS NOT NULL
                                 BEGIN
                                     INSERT INTO #temp_rtn
                                     (lgh_number
                                    , asgn_type
                                    , asgn_id
                                    , asgn_date
                                    , asgn_enddate
                                    , cmp_id_start
                                    , cmp_id_end
                                    , mov_number
                                    , asgn_number
                                    , ord_hdrnumber
                                    , lgh_startcity
                                    , lgh_endcity
                                    , ord_number
                                    , name
                                    , cmp_name_start
                                    , cmp_name_end
                                    , cty_nmstct_start
                                    , cty_nmstct_end
                                    , need_paperwork
                                    , ivh_revtype1
                                    , revtype1_name
                                    , lgh_split_flag
                                    , trip_description
                                    , lgh_type1
                                    , lgh_type_name
                                    , ivh_billdate
                                    , ivh_invoicenumber
                                    , lgh_booked_revtype1
                                    , ivh_billto
                                    , asgn_controlling
                                    , lgh_shiftdate
                                    , lgh_shiftnumber
                                    , shift_ss_id
                                    , stp_schdtearliest
                                    , ord_route
                                    , Cost
                                    , ord_revtype1
                                    , ord_revtype1_name
                                    , ord_revtype2
                                    , ord_revtype2_name
                                    , ord_revtype3
                                    , ord_revtype3_name
                                    , ord_revtype4
                                    , ord_revtype4_name
                                    , lgh_type2
                                    , lgh_type3
                                    , lgh_type4
                                    , asgn_payto
                                     )
                                            SELECT a.lgh_number
                                                 , a.asgn_type
                                                 , a.asgn_id
                                                 , a.asgn_date
                                                 , a.asgn_enddate
                                                 , ''
                                                 , ''
                                                 , a.mov_number
                                                 , a.asgn_number
                                                 , 0
                                                 , 0
                                                 , 0
                                                 , ''
                                                 , mpp_lastfirst
                                                 , ''
                                                 , ''
                                                 , ''
                                                 , ''
                                                 , 0
                                                 , ''
                                                 , 'RevType1'
                                                 , 'N'
                                                 , ''
                                                 , 'UNK'
                                                 , 'LghType1'
                                                 , NULL
                                                 , NULL
                                                 , 'Lgh_Booked_Revtype1'
                                                 , 'IvhBillT'
                                                 , a.asgn_controlling
                                                 , l.lgh_shiftdate
                                                 , l.lgh_shiftnumber
                                                 , l.shift_ss_id
                                                   -- PTS 47740 added 11 new columns <<start>>
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                   -- PTS 47740 <<end>>
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , #tmp.mpp_payto -- PTS 52192
                                            FROM assetassignment a
                                                 INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                           AND (@shiftdate = '1950-01-01 00:00'
                                                                                OR @shiftdate = l.lgh_shiftdate)
                                                                           AND (@shiftnumber = 'UNK'
                                                                                OR @shiftnumber = l.lgh_shiftnumber)
                                                                           AND a.asgn_type = 'DRV'
                                               , @tmp #tmp
                                            WHERE a.asgn_type = 'DRV'
                                                  AND a.asgn_id = mpp_id
                                                  AND a.asgn_status = 'CMP'
                                                  AND pyd_status = 'NPD'
                                                  AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                                                  AND shift_ss_id = @min_shift_id
                                                  AND l.lgh_number NOT IN
                                            (
                                                SELECT lgh_number
                                                FROM #temp_rtn
                                                WHERE shift_ss_id = @min_shift_id
                                            )
                                                  AND ((@acct_typ = 'X'
                                                        AND a.actg_type IN('A', 'P'))
                                            OR (@acct_typ = actg_type))
                                                 AND (@drvtyp1 = 'UNK'
                                                      OR @drvtyp1 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.mpp_type1
                                                                         ELSE #tmp.mpp_type1
                                                                     END))
                                                 AND (@drvtyp2 = 'UNK'
                                                      OR @drvtyp2 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.mpp_type2
                                                                         ELSE #tmp.mpp_type2
                                                                     END))
                                                 AND (@drvtyp3 = 'UNK'
                                                      OR @drvtyp3 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.mpp_type3
                                                                         ELSE #tmp.mpp_type3
                                                                     END))
                                                 AND (@drvtyp4 = 'UNK'
                                                      OR @drvtyp4 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.mpp_type4
                                                                         ELSE #tmp.mpp_type4
                                                                     END))

                                     SELECT @min_shift_id = MIN(shift_ss_id)
                                     FROM #temp_rtn
                                     WHERE shift_ss_id IS NOT NULL
                                           AND shift_ss_id > @min_shift_id
                                           AND asgn_type = 'DRV'
                                 END --LOOP
                         END
                 END
             ELSE
                 BEGIN
                     IF @ls_STL_TRS_Include_Shift = 'N'
                         BEGIN
                             --***(2a)
                             INSERT INTO #temp_rtn
                             (lgh_number
                            , asgn_type
                            , asgn_id
                            , asgn_date
                            , asgn_enddate
                            , cmp_id_start
                            , cmp_id_end
                            , mov_number
                            , asgn_number
                            , ord_hdrnumber
                            , lgh_startcity
                            , lgh_endcity
                            , ord_number
                            , name
                            , cmp_name_start
                            , cmp_name_end
                            , cty_nmstct_start
                            , cty_nmstct_end
                            , need_paperwork
                            , ivh_revtype1
                            , revtype1_name
                            , lgh_split_flag
                            , trip_description
                            , lgh_type1
                            , lgh_type_name
                            , ivh_billdate
                            , ivh_invoicenumber
                            , lgh_booked_revtype1
                            , ivh_billto
                            , asgn_controlling
                            , lgh_shiftdate
                            , lgh_shiftnumber
                            , shift_ss_id
                            , stp_schdtearliest
                            , ord_route
                            , Cost
                            , ord_revtype1
                            , ord_revtype1_name
                            , ord_revtype2
                            , ord_revtype2_name
                            , ord_revtype3
                            , ord_revtype3_name
                            , ord_revtype4
                            , ord_revtype4_name
                            , lgh_type2
                            , lgh_type3
                            , lgh_type4
                            , asgn_payto
                             )
                                    SELECT a.lgh_number
                                         , a.asgn_type
                                         , a.asgn_id
                                         , a.asgn_date
                                         , a.asgn_enddate
                                         , ''
                                         , ''
                                         , a.mov_number
                                         , a.asgn_number
                                         , 0
                                         , 0
                                         , 0
                                         , ''
                                         , mpp_lastfirst
                                         , ''
                                         , ''
                                         , ''
                                         , ''
                                         , 0
                                         , ''
                                         , 'RevType1'
                                         , 'N'
                                         , ''
                                         , 'UNK'
                                         , 'LghType1'
                                         , NULL
                                         , NULL
                                         , 'Lgh_Booked_Revtype1'
                                         , 'IvhBillT'
                                         , a.asgn_controlling
                                         , l.lgh_shiftdate
                                         , l.lgh_shiftnumber
                                         , l.shift_ss_id
                                           -- PTS 47740 added 11 new columns <<start>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                           -- PTS 47740 <<end>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , #tmp.mpp_payto -- PTS 52192
                                    FROM assetassignment a
                                         INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                   AND (@shiftdate = '1950-01-01 00:00'
                                                                        OR @shiftdate = l.lgh_shiftdate)
                                                                   AND (@shiftnumber = 'UNK'
                                                                        OR @shiftnumber = l.lgh_shiftnumber)
                                                                   AND a.asgn_type = 'DRV'
                                       , @tmp #tmp
                                    WHERE a.asgn_type = 'DRV'
                                          AND a.asgn_id = mpp_id
                                          AND a.asgn_status = 'CMP'
                                          AND pyd_status = 'NPD'
                                          AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                                          AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
                                          AND ((@acct_typ = 'X'
                                                AND #tmp.mpp_actg_type IN('A', 'P'))
                                    OR (@acct_typ = #tmp.mpp_actg_type))
                                         AND (@drvtyp1 = 'UNK'
                                              OR @drvtyp1 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type1
                                                                 ELSE #tmp.mpp_type1
                                                             END))
                                         AND (@drvtyp2 = 'UNK'
                                              OR @drvtyp2 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type2
                                                                 ELSE #tmp.mpp_type2
                                                             END))
                                         AND (@drvtyp3 = 'UNK'
                                              OR @drvtyp3 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type3
                                                                 ELSE #tmp.mpp_type3
                                                             END))
                                         AND (@drvtyp4 = 'UNK'
                                              OR @drvtyp4 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type4
                                                                 ELSE #tmp.mpp_type4
                                                             END))
                         END
                     ELSE
                         BEGIN
                             --***(2b)
                             --vjh 45381 new insert for join to shiftschedules table and restrictions based on that.
                             INSERT INTO #temp_rtn
                             (lgh_number
                            , asgn_type
                            , asgn_id
                            , asgn_date
                            , asgn_enddate
                            , cmp_id_start
                            , cmp_id_end
                            , mov_number
                            , asgn_number
                            , ord_hdrnumber
                            , lgh_startcity
                            , lgh_endcity
                            , ord_number
                            , name
                            , cmp_name_start
                            , cmp_name_end
                            , cty_nmstct_start
                            , cty_nmstct_end
                            , need_paperwork
                            , ivh_revtype1
                            , revtype1_name
                            , lgh_split_flag
                            , trip_description
                            , lgh_type1
                            , lgh_type_name
                            , ivh_billdate
                            , ivh_invoicenumber
                            , lgh_booked_revtype1
                            , ivh_billto
                            , asgn_controlling
                            , lgh_shiftdate
                            , lgh_shiftnumber
                            , shift_ss_id
                            , stp_schdtearliest
                            , ord_route
                            , Cost
                            , ord_revtype1
                            , ord_revtype1_name
                            , ord_revtype2
                            , ord_revtype2_name
                            , ord_revtype3
                            , ord_revtype3_name
                            , ord_revtype4
                            , ord_revtype4_name
                            , lgh_type2
                            , lgh_type3
                            , lgh_type4
                            , asgn_payto
                             )
                                    SELECT a.lgh_number
                                         , a.asgn_type
                                         , a.asgn_id
                                         , a.asgn_date
                                         , a.asgn_enddate
                                         , ''
                                         , ''
                                         , a.mov_number
                                         , a.asgn_number
                                         , 0
                                         , 0
                                         , 0
                                         , ''
                                         , mpp_lastfirst
                                         , ''
                                         , ''
                                         , ''
                                         , ''
                                         , 0
                                         , ''
                                         , 'RevType1'
                                         , 'N'
                                         , ''
                                         , 'UNK'
                                         , 'LghType1'
                                         , NULL
                                         , NULL
                                         , 'Lgh_Booked_Revtype1'
                                         , 'IvhBillT'
                                         , a.asgn_controlling
                                         , l.lgh_shiftdate
                                         , l.lgh_shiftnumber
                                         , l.shift_ss_id
                                           -- PTS 47740 added 11 new columns <<start>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                           -- PTS 47740 <<end>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , #tmp.mpp_payto -- PTS 52192
                                    FROM assetassignment a
                                         INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                   AND (@shiftdate = '1950-01-01 00:00'
                                                                        OR @shiftdate = l.lgh_shiftdate)
                                                                   AND (@shiftnumber = 'UNK'
                                                                        OR @shiftnumber = l.lgh_shiftnumber)
                                                                   AND a.asgn_type = 'DRV'
                                         LEFT JOIN shiftschedules s ON l.shift_Ss_id = s.ss_id
                                       , @tmp #tmp
                                    WHERE a.asgn_type = 'DRV'
                                          AND a.asgn_id = #tmp.mpp_id
                                          AND a.asgn_status = 'CMP'
                                          AND pyd_status = 'NPD'
                                          AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                                          AND s.ss_starttime BETWEEN @loenddate AND @hienddate
                                          AND ((@acct_typ = 'X'
                                                AND #tmp.mpp_actg_type IN('A', 'P'))
                                    OR (@acct_typ = #tmp.mpp_actg_type))
                                         AND (@drvtyp1 = 'UNK'
                                              OR @drvtyp1 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type1
                                                                 ELSE #tmp.mpp_type1
                                                             END))
                                         AND (@drvtyp2 = 'UNK'
                                              OR @drvtyp2 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type2
                                                                 ELSE #tmp.mpp_type2
                                                             END))
                                         AND (@drvtyp3 = 'UNK'
                                              OR @drvtyp3 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type3
                                                                 ELSE #tmp.mpp_type3
                                                             END))
                                         AND (@drvtyp4 = 'UNK'
                                              OR @drvtyp4 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.mpp_type4
                                                                 ELSE #tmp.mpp_type4
                                                             END))

                             --vjh 45381 walk through each shift and grab any trips that fell outside of the date range but have same shift
                             SELECT @min_shift_id = MIN(shift_ss_id)
                             FROM #temp_rtn
                             WHERE shift_ss_id IS NOT NULL
                                   AND shift_ss_id > 0
                                   AND asgn_type = 'DRV'
                             WHILE @min_shift_id IS NOT NULL
                                 BEGIN
                                     INSERT INTO #temp_rtn
                                     (lgh_number
                                    , asgn_type
                                    , asgn_id
                                    , asgn_date
                                    , asgn_enddate
                                    , cmp_id_start
                                    , cmp_id_end
                                    , mov_number
                                    , asgn_number
                                    , ord_hdrnumber
                                    , lgh_startcity
                                    , lgh_endcity
                                    , ord_number
                                    , name
                                    , cmp_name_start
                                    , cmp_name_end
                                    , cty_nmstct_start
                                    , cty_nmstct_end
                                    , need_paperwork
                                    , ivh_revtype1
                                    , revtype1_name
                                    , lgh_split_flag
                                    , trip_description
                                    , lgh_type1
                                    , lgh_type_name
                                    , ivh_billdate
                                    , ivh_invoicenumber
                                    , lgh_booked_revtype1
                                    , ivh_billto
                                    , asgn_controlling
                                    , lgh_shiftdate
                                    , lgh_shiftnumber
                                    , shift_ss_id
                                    , stp_schdtearliest
                                    , ord_route
                                    , Cost
                                    , ord_revtype1
                                    , ord_revtype1_name
                                    , ord_revtype2
                                    , ord_revtype2_name
                                    , ord_revtype3
                                    , ord_revtype3_name
                                    , ord_revtype4
                                    , ord_revtype4_name
                                    , lgh_type2
                                    , lgh_type3
                                    , lgh_type4
                                    , asgn_payto
                                     )
                                            SELECT a.lgh_number
                                                 , a.asgn_type
                                                 , a.asgn_id
                                                 , a.asgn_date
                                                 , a.asgn_enddate
                                                 , ''
                                                 , ''
                                                 , a.mov_number
                                                 , a.asgn_number
                                                 , 0
                                                 , 0
                                                 , 0
                                                 , ''
                                                 , mpp_lastfirst
                                                 , ''
                                                 , ''
                                                 , ''
                                                 , ''
                                                 , 0
                                                 , ''
                                                 , 'RevType1'
                                                 , 'N'
                                                 , ''
                                                 , 'UNK'
                                                 , 'LghType1'
                                                 , NULL
                                                 , NULL
                                                 , 'Lgh_Booked_Revtype1'
                                                 , 'IvhBillT'
                                                 , a.asgn_controlling
                                                 , l.lgh_shiftdate
                                                 , l.lgh_shiftnumber
                                                 , l.shift_ss_id
                                                   -- PTS 47740 added 11 new columns <<start>>
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                   -- PTS 47740 <<end>>
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , #tmp.mpp_payto -- PTS 52192
                                            FROM assetassignment a
                                                 INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                           AND (@shiftdate = '1950-01-01 00:00'
                                                                                OR @shiftdate = l.lgh_shiftdate)
                                                                           AND (@shiftnumber = 'UNK'
                                                                                OR @shiftnumber = l.lgh_shiftnumber)
                                                                           AND a.asgn_type = 'DRV'
                                               , @tmp #tmp
                                            WHERE a.asgn_type = 'DRV'
                                                  AND a.asgn_id = mpp_id
                                                  AND a.asgn_status = 'CMP'
                                                  AND pyd_status = 'NPD'
                                                  AND shift_ss_id = @min_shift_id
                                                  AND l.lgh_number NOT IN
                                            (
                                                SELECT lgh_number
                                                FROM #temp_rtn
                                                WHERE shift_ss_id = @min_shift_id
                                            )
                                                  AND ((@acct_typ = 'X'
                                                        AND #tmp.mpp_actg_type IN('A', 'P'))
                                            OR (@acct_typ = #tmp.mpp_actg_type))
                                                 AND (@drvtyp1 = 'UNK'
                                                      OR @drvtyp1 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.mpp_type1
                                                                         ELSE #tmp.mpp_type1
                                                                     END))
                                                 AND (@drvtyp2 = 'UNK'
                                                      OR @drvtyp2 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.mpp_type2
                                                                         ELSE #tmp.mpp_type2
                                                                     END))
                                                 AND (@drvtyp3 = 'UNK'
                                                      OR @drvtyp3 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.mpp_type3
                                                                         ELSE #tmp.mpp_type3
                                                                     END))
                                                 AND (@drvtyp4 = 'UNK'
                                                      OR @drvtyp4 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.mpp_type4
                                                                         ELSE #tmp.mpp_type4
                                                                     END))

                                     SELECT @min_shift_id = MIN(shift_ss_id)
                                     FROM #temp_rtn
                                     WHERE shift_ss_id IS NOT NULL
                                           AND shift_ss_id > @min_shift_id
                                           AND asgn_type = 'DRV'
                                 END  --LOOP
                         END
                 END
         END
     --END DRIVERS

     --BEGIN TRACTORS
     IF @trcyes <> 'XXX'
        OR EXISTS
     (
         SELECT *
         FROM @tmp1
     )
         BEGIN
             -- vjh 30395 add logic for using asset asignment accounting type
             IF @STLUseLegAcctType = 'Y'
                 BEGIN
                     IF @ls_STL_TRS_Include_Shift = 'N'
                         BEGIN
                             --***(1a)
                             INSERT INTO #temp_rtn
                             (lgh_number
                            , asgn_type
                            , asgn_id
                            , asgn_date
                            , asgn_enddate
                            , cmp_id_start
                            , cmp_id_end
                            , mov_number
                            , asgn_number
                            , ord_hdrnumber
                            , lgh_startcity
                            , lgh_endcity
                            , ord_number
                            , name
                            , cmp_name_start
                            , cmp_name_end
                            , cty_nmstct_start
                            , cty_nmstct_end
                            , need_paperwork
                            , ivh_revtype1
                            , revtype1_name
                            , lgh_split_flag
                            , trip_description
                            , lgh_type1
                            , lgh_type_name
                            , ivh_billdate
                            , ivh_invoicenumber
                            , lgh_booked_revtype1
                            , ivh_billto
                            , asgn_controlling
                            , lgh_shiftdate
                            , lgh_shiftnumber
                            , shift_ss_id
                            , stp_schdtearliest
                            , ord_route
                            , Cost
                            , ord_revtype1
                            , ord_revtype1_name
                            , ord_revtype2
                            , ord_revtype2_name
                            , ord_revtype3
                            , ord_revtype3_name
                            , ord_revtype4
                            , ord_revtype4_name
                            , lgh_type2
                            , lgh_type3
                            , lgh_type4
                            , asgn_payto
                             )
                                    SELECT a.lgh_number
                                         , a.asgn_type
                                         , a.asgn_id
                                         , a.asgn_date
                                         , a.asgn_enddate
                                         , ''
                                         , ''
                                         , a.mov_number
                                         , a.asgn_number
                                         , 0
                                         , 0
                                         , 0
                                         , ''
                                         , trc_owner
                                         , ''
                                         , ''
                                         , ''
                                         , ''
                                         , 0
                                         , ''
                                         , 'RevType1'
                                         , 'N'
                                         , ''
                                         , 'UNK'
                                         , 'LghType1'
                                         , NULL
                                         , NULL
                                         , 'Lgh_Booked_Revtype1'
                                         , 'IvhBillT'
                                         , a.asgn_controlling
                                         , l.lgh_shiftdate
                                         , l.lgh_shiftnumber
                                         , l.shift_ss_id
                                           -- PTS 47740 added 11 new columns <<start>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                           -- PTS 47740 <<end>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , #tmp1.trc_owner -- PTS 52192
                                    FROM assetassignment a
                                         INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                   AND (@shiftdate = '1950-01-01 00:00'
                                                                        OR @shiftdate = l.lgh_shiftdate)
                                                                   AND (@shiftnumber = 'UNK'
                                                                        OR @shiftnumber = l.lgh_shiftnumber)
                                                                   AND a.asgn_type = 'TRC'
                                       , @tmp1 #tmp1
                                    WHERE a.asgn_type = 'TRC'
                                          AND a.asgn_id = trc_number
                                          AND a.asgn_status = 'CMP'
                                          AND pyd_status = 'NPD'
                                          AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                                          AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
                                          AND ((@acct_typ = 'X'
                                                AND actg_type IN('A', 'P'))
                                    OR (@acct_typ = actg_type))
                                         AND (@trctyp1 = 'UNK'
                                              OR @trctyp1 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.trc_type1
                                                                 ELSE #tmp1.trc_type1
                                                             END))
                                         AND (@trctyp2 = 'UNK'
                                              OR @trctyp2 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.trc_type2
                                                                 ELSE #tmp1.trc_type2
                                                             END))
                                         AND (@trctyp3 = 'UNK'
                                              OR @trctyp3 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.trc_type3
                                                                 ELSE #tmp1.trc_type3
                                                             END))
                                         AND (@trctyp4 = 'UNK'
                                              OR @trctyp4 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.trc_type4
                                                                 ELSE #tmp1.trc_type4
                                                             END))
                         END
                     ELSE
                         BEGIN
                             --***(1b)
                             INSERT INTO #temp_rtn
                             (lgh_number
                            , asgn_type
                            , asgn_id
                            , asgn_date
                            , asgn_enddate
                            , cmp_id_start
                            , cmp_id_end
                            , mov_number
                            , asgn_number
                            , ord_hdrnumber
                            , lgh_startcity
                            , lgh_endcity
                            , ord_number
                            , name
                            , cmp_name_start
                            , cmp_name_end
                            , cty_nmstct_start
                            , cty_nmstct_end
                            , need_paperwork
                            , ivh_revtype1
                            , revtype1_name
                            , lgh_split_flag
                            , trip_description
                            , lgh_type1
                            , lgh_type_name
                            , ivh_billdate
                            , ivh_invoicenumber
                            , lgh_booked_revtype1
                            , ivh_billto
                            , asgn_controlling
                            , lgh_shiftdate
                            , lgh_shiftnumber
                            , shift_ss_id
                            , stp_schdtearliest
                            , ord_route
                            , Cost
                            , ord_revtype1
                            , ord_revtype1_name
                            , ord_revtype2
                            , ord_revtype2_name
                            , ord_revtype3
                            , ord_revtype3_name
                            , ord_revtype4
                            , ord_revtype4_name
                            , lgh_type2
                            , lgh_type3
                            , lgh_type4
                            , asgn_payto
                             )
                                    SELECT a.lgh_number
                                         , a.asgn_type
                                         , a.asgn_id
                                         , a.asgn_date
                                         , a.asgn_enddate
                                         , ''
                                         , ''
                                         , a.mov_number
                                         , a.asgn_number
                                         , 0
                                         , 0
                                         , 0
                                         , ''
                                         , trc_owner
                                         , ''
                                         , ''
                                         , ''
                                         , ''
                                         , 0
                                         , ''
                                         , 'RevType1'
                                         , 'N'
                                         , ''
                                         , 'UNK'
                                         , 'LghType1'
                                         , NULL
                                         , NULL
                                         , 'Lgh_Booked_Revtype1'
                                         , 'IvhBillT'
                                         , a.asgn_controlling
                                         , l.lgh_shiftdate
                                         , l.lgh_shiftnumber
                                         , l.shift_ss_id
                                           -- PTS 47740 added 11 new columns <<start>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                           -- PTS 47740 <<end>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , #tmp1.trc_owner -- PTS 52192
                                    FROM assetassignment a
                                         INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                   AND (@shiftdate = '1950-01-01 00:00'
                                                                        OR @shiftdate = l.lgh_shiftdate)
                                                                   AND (@shiftnumber = 'UNK'
                                                                        OR @shiftnumber = l.lgh_shiftnumber)
                                                                   AND a.asgn_type = 'TRC'
                                         LEFT JOIN shiftschedules s ON l.shift_sS_id = s.ss_id
                                       , @tmp1 #tmp1
                                    WHERE a.asgn_type = 'TRC'
                                          AND a.asgn_id = #tmp1.trc_number
                                          AND a.asgn_status = 'CMP'
                                          AND pyd_status = 'NPD'
                                          AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                                          AND s.ss_starttime BETWEEN @loenddate AND @hienddate
                                          AND ((@acct_typ = 'X'
                                                AND actg_type IN('A', 'P'))
                                    OR (@acct_typ = actg_type))
                                         AND (@trctyp1 = 'UNK'
                                              OR @trctyp1 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.trc_type1
                                                                 ELSE #tmp1.trc_type1
                                                             END))
                                         AND (@trctyp2 = 'UNK'
                                              OR @trctyp2 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.trc_type2
                                                                 ELSE #tmp1.trc_type2
                                                             END))
                                         AND (@trctyp3 = 'UNK'
                                              OR @trctyp3 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.trc_type3
                                                                 ELSE #tmp1.trc_type3
                                                             END))
                                         AND (@trctyp4 = 'UNK'
                                              OR @trctyp4 = (CASE @resourcetypeonleg
                                                                 WHEN 'Y'
                                                                 THEN l.trc_type4
                                                                 ELSE #tmp1.trc_type4
                                                             END))

                             SELECT @min_shift_id = MIN(shift_ss_id)
                             FROM #temp_rtn
                             WHERE shift_ss_id IS NOT NULL
                                   AND shift_ss_id > 0
                                   AND asgn_type = 'TRC'
                             WHILE @min_shift_id IS NOT NULL
                                 BEGIN
                                     INSERT INTO #temp_rtn
                                     (lgh_number
                                    , asgn_type
                                    , asgn_id
                                    , asgn_date
                                    , asgn_enddate
                                    , cmp_id_start
                                    , cmp_id_end
                                    , mov_number
                                    , asgn_number
                                    , ord_hdrnumber
                                    , lgh_startcity
                                    , lgh_endcity
                                    , ord_number
                                    , name
                                    , cmp_name_start
                                    , cmp_name_end
                                    , cty_nmstct_start
                                    , cty_nmstct_end
                                    , need_paperwork
                                    , ivh_revtype1
                                    , revtype1_name
                                    , lgh_split_flag
                                    , trip_description
                                    , lgh_type1
                                    , lgh_type_name
                                    , ivh_billdate
                                    , ivh_invoicenumber
                                    , lgh_booked_revtype1
                                    , ivh_billto
                                    , asgn_controlling
                                    , lgh_shiftdate
                                    , lgh_shiftnumber
                                    , shift_ss_id
                                    , stp_schdtearliest
                                    , ord_route
                                    , Cost
                                    , ord_revtype1
                                    , ord_revtype1_name
                                    , ord_revtype2
                                    , ord_revtype2_name
                                    , ord_revtype3
                                    , ord_revtype3_name
                                    , ord_revtype4
                                    , ord_revtype4_name
                                    , lgh_type2
                                    , lgh_type3
                                    , lgh_type4
                                    , asgn_payto
                                     )
                                            SELECT a.lgh_number
                                                 , a.asgn_type
                                                 , a.asgn_id
                                                 , a.asgn_date
                                                 , a.asgn_enddate
                                                 , ''
                                                 , ''
                                                 , a.mov_number
                                                 , a.asgn_number
                                                 , 0
                                                 , 0
                                                 , 0
                                                 , ''
                                                 , trc_owner
                                                 , ''
                                                 , ''
                                                 , ''
                                                 , ''
                                                 , 0
                                                 , ''
                                                 , 'RevType1'
                                                 , 'N'
                                                 , ''
                                                 , 'UNK'
                                                 , 'LghType1'
                                                 , NULL
                                                 , NULL
                                                 , 'Lgh_Booked_Revtype1'
                                                 , 'IvhBillT'
                                                 , a.asgn_controlling
                                                 , l.lgh_shiftdate
                                                 , l.lgh_shiftnumber
                                                 , l.shift_ss_id
                                                   -- PTS 47740 added 11 new columns <<start>>
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                   -- PTS 47740 <<end>>
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , #tmp1.trc_owner -- PTS 52192
                                            FROM assetassignment a
                                                 INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                           AND (@shiftdate = '1950-01-01 00:00'
                                                                                OR @shiftdate = l.lgh_shiftdate)
                                                                           AND (@shiftnumber = 'UNK'
                                                                                OR @shiftnumber = l.lgh_shiftnumber)
                                                                           AND a.asgn_type = 'TRC'
                                               , @tmp1 #tmp1
                                            WHERE a.asgn_type = 'TRC'
                                                  AND a.asgn_id = trc_number
                                                  AND a.asgn_status = 'CMP'
                                                  AND pyd_status = 'NPD'
                                                  AND shift_ss_id = @min_shift_id
                                                  AND l.lgh_number NOT IN
                                            (
                                                SELECT lgh_number
                                                FROM #temp_rtn
                                                WHERE shift_ss_id = @min_shift_id
                                            )
                                                  AND ((@acct_typ = 'X'
                                                        AND actg_type IN('A', 'P'))
                                            OR (@acct_typ = actg_type))
                                                 AND (@trctyp1 = 'UNK'
                                                      OR @trctyp1 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.trc_type1
                                                                         ELSE #tmp1.trc_type1
                                                                     END))
                                                 AND (@trctyp2 = 'UNK'
                                                      OR @trctyp2 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.trc_type2
                                                                         ELSE #tmp1.trc_type2
                                                                     END))
                                                 AND (@trctyp3 = 'UNK'
                                                      OR @trctyp3 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.trc_type3
                                                                         ELSE #tmp1.trc_type3
                                                                     END))
                                                 AND (@trctyp4 = 'UNK'
                                                      OR @trctyp4 = (CASE @resourcetypeonleg
                                                                         WHEN 'Y'
                                                                         THEN l.trc_type4
                                                                         ELSE #tmp1.trc_type4
                                                                     END))
                                     SELECT @min_shift_id = MIN(shift_ss_id)
                                     FROM #temp_rtn
                                     WHERE shift_ss_id IS NOT NULL
                                           AND shift_ss_id > @min_shift_id
                                           AND asgn_type = 'TRC'
                                 END --LOOP
                         END
                 END
             ELSE
                 BEGIN
                     IF @ls_STL_TRS_Include_Shift = 'N'
                         BEGIN
                             --***(2a)
                             INSERT INTO #temp_rtn
                             (lgh_number
                            , asgn_type
                            , asgn_id
                            , asgn_date
                            , asgn_enddate
                            , cmp_id_start
                            , cmp_id_end
                            , mov_number
                            , asgn_number
                            , ord_hdrnumber
                            , lgh_startcity
                            , lgh_endcity
                            , ord_number
                            , name
                            , cmp_name_start
                            , cmp_name_end
                            , cty_nmstct_start
                            , cty_nmstct_end
                            , need_paperwork
                            , ivh_revtype1
                            , revtype1_name
                            , lgh_split_flag
                            , trip_description
                            , lgh_type1
                            , lgh_type_name
                            , ivh_billdate
                            , ivh_invoicenumber
                            , lgh_booked_revtype1
                            , ivh_billto
                            , asgn_controlling
                            , lgh_shiftdate
                            , lgh_shiftnumber
                            , shift_ss_id
                            , stp_schdtearliest
                            , ord_route
                            , Cost
                            , ord_revtype1
                            , ord_revtype1_name
                            , ord_revtype2
                            , ord_revtype2_name
                            , ord_revtype3
                            , ord_revtype3_name
                            , ord_revtype4
                            , ord_revtype4_name
                            , lgh_type2
                            , lgh_type3
                            , lgh_type4
                            , asgn_payto
                             )
                                    SELECT a.lgh_number
                                         , a.asgn_type
                                         , a.asgn_id
                                         , a.asgn_date
                                         , a.asgn_enddate
                                         , ''
                                         , ''
                                         , a.mov_number
                                         , a.asgn_number
                                         , 0
                                         , 0
                                         , 0
                                         , ''
                                         , trc_owner
                                         , ''
                                         , ''
                                         , ''
                                         , ''
                                         , 0
                                         , ''
                                         , 'RevType1'
                                         , 'N'
                                         , ''
                                         , 'UNK'
                                         , 'LghType1'
                                         , NULL
                                         , NULL
                                         , 'Lgh_Booked_Revtype1'
                                         , 'IvhBillT'
                                         , a.asgn_controlling
                                         , l.lgh_shiftdate
                                         , l.lgh_shiftnumber
                                         , l.shift_ss_id
                                           -- PTS 47740 added 11 new columns <<start>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                           -- PTS 47740 <<end>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , #tmp1.trc_owner -- PTS 52192
                                    FROM assetassignment a
                                         INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                   AND (@shiftdate = '1950-01-01 00:00'
                                                                        OR @shiftdate = l.lgh_shiftdate)
                                                                   AND (@shiftnumber = 'UNK'
                                                                        OR @shiftnumber = l.lgh_shiftnumber)
                                                                   AND a.asgn_type = 'TRC'
                                       , @tmp1 #tmp1
                                    WHERE a.asgn_type = 'TRC'
                                          AND a.asgn_id = trc_number
                                          AND a.asgn_status = 'CMP'
                                          AND pyd_status = 'NPD'
                                          AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                                          AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
                                          AND (@trctyp1 = 'UNK'
                                               OR @trctyp1 = (CASE @resourcetypeonleg
                                                                  WHEN 'Y'
                                                                  THEN l.trc_type1
                                                                  ELSE #tmp1.trc_type1
                                                              END))
                                          AND (@trctyp2 = 'UNK'
                                               OR @trctyp2 = (CASE @resourcetypeonleg
                                                                  WHEN 'Y'
                                                                  THEN l.trc_type2
                                                                  ELSE #tmp1.trc_type2
                                                              END))
                                          AND (@trctyp3 = 'UNK'
                                               OR @trctyp3 = (CASE @resourcetypeonleg
                                                                  WHEN 'Y'
                                                                  THEN l.trc_type3
                                                                  ELSE #tmp1.trc_type3
                                                              END))
                                          AND (@trctyp4 = 'UNK'
                                               OR @trctyp4 = (CASE @resourcetypeonleg
                                                                  WHEN 'Y'
                                                                  THEN l.trc_type4
                                                                  ELSE #tmp1.trc_type4
                                                              END))
                         END
                     ELSE
                         BEGIN
                             --***(2b)
                             INSERT INTO #temp_rtn
                             (lgh_number
                            , asgn_type
                            , asgn_id
                            , asgn_date
                            , asgn_enddate
                            , cmp_id_start
                            , cmp_id_end
                            , mov_number
                            , asgn_number
                            , ord_hdrnumber
                            , lgh_startcity
                            , lgh_endcity
                            , ord_number
                            , name
                            , cmp_name_start
                            , cmp_name_end
                            , cty_nmstct_start
                            , cty_nmstct_end
                            , need_paperwork
                            , ivh_revtype1
                            , revtype1_name
                            , lgh_split_flag
                            , trip_description
                            , lgh_type1
                            , lgh_type_name
                            , ivh_billdate
                            , ivh_invoicenumber
                            , lgh_booked_revtype1
                            , ivh_billto
                            , asgn_controlling
                            , lgh_shiftdate
                            , lgh_shiftnumber
                            , shift_ss_id
                            , stp_schdtearliest
                            , ord_route
                            , Cost
                            , ord_revtype1
                            , ord_revtype1_name
                            , ord_revtype2
                            , ord_revtype2_name
                            , ord_revtype3
                            , ord_revtype3_name
                            , ord_revtype4
                            , ord_revtype4_name
                            , lgh_type2
                            , lgh_type3
                            , lgh_type4
                            , asgn_payto
                             )
                                    SELECT a.lgh_number
                                         , a.asgn_type
                                         , a.asgn_id
                                         , a.asgn_date
                                         , a.asgn_enddate
                                         , ''
                                         , ''
                                         , a.mov_number
                                         , a.asgn_number
                                         , 0
                                         , 0
                                         , 0
                                         , ''
                                         , trc_owner
                                         , ''
                                         , ''
                                         , ''
                                         , ''
                                         , 0
                                         , ''
                                         , 'RevType1'
                                         , 'N'
                                         , ''
                                         , 'UNK'
                                         , 'LghType1'
                                         , NULL
                                         , NULL
                                         , 'Lgh_Booked_Revtype1'
                                         , 'IvhBillT'
                                         , a.asgn_controlling
                                         , l.lgh_shiftdate
                                         , l.lgh_shiftnumber
                                         , l.shift_ss_id
                                           -- PTS 47740 added 11 new columns <<start>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                         , NULL
                                           -- PTS 47740 <<end>>
                                         , NULL
                                         , NULL
                                         , NULL
                                         , #tmp1.trc_owner -- PTS 52192
                                    FROM assetassignment a
                                         INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                   AND (@shiftdate = '1950-01-01 00:00'
                                                                        OR @shiftdate = l.lgh_shiftdate)
                                                                   AND (@shiftnumber = 'UNK'
                                                                        OR @shiftnumber = l.lgh_shiftnumber)
                                                                   AND a.asgn_type = 'TRC'
                                         LEFT JOIN shiftschedules s ON l.shift_sS_id = s.ss_id
                                       , @tmp1 #tmp1
                                    WHERE a.asgn_type = 'TRC'
                                          AND a.asgn_id = #tmp1.trc_number
                                          AND a.asgn_status = 'CMP'
                                          AND pyd_status = 'NPD'
                                          AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                                          AND s.ss_starttime BETWEEN @loenddate AND @hienddate
                                          AND (@trctyp1 = 'UNK'
                                               OR @trctyp1 = (CASE @resourcetypeonleg
                                                                  WHEN 'Y'
                                                                  THEN l.trc_type1
                                                                  ELSE #tmp1.trc_type1
                                                              END))
                                          AND (@trctyp2 = 'UNK'
                                               OR @trctyp2 = (CASE @resourcetypeonleg
                                                                  WHEN 'Y'
                                                                  THEN l.trc_type2
                                                                  ELSE #tmp1.trc_type2
                                                              END))
                                          AND (@trctyp3 = 'UNK'
                                               OR @trctyp3 = (CASE @resourcetypeonleg
                                                                  WHEN 'Y'
                                                                  THEN l.trc_type3
                                                                  ELSE #tmp1.trc_type3
                                                              END))
                                          AND (@trctyp4 = 'UNK'
                                               OR @trctyp4 = (CASE @resourcetypeonleg
                                                                  WHEN 'Y'
                                                                  THEN l.trc_type4
                                                                  ELSE #tmp1.trc_type4
                                                              END))

                             SELECT @min_shift_id = MIN(shift_ss_id)
                             FROM #temp_rtn
                             WHERE shift_ss_id IS NOT NULL
                                   AND shift_ss_id > 0
                                   AND asgn_type = 'TRC'
                             WHILE @min_shift_id IS NOT NULL
                                 BEGIN
                                     INSERT INTO #temp_rtn
                                     (lgh_number
                                    , asgn_type
                                    , asgn_id
                                    , asgn_date
                                    , asgn_enddate
                                    , cmp_id_start
                                    , cmp_id_end
                                    , mov_number
                                    , asgn_number
                                    , ord_hdrnumber
                                    , lgh_startcity
                                    , lgh_endcity
                                    , ord_number
                                    , name
                                    , cmp_name_start
                                    , cmp_name_end
                                    , cty_nmstct_start
                                    , cty_nmstct_end
                                    , need_paperwork
                                    , ivh_revtype1
                                    , revtype1_name
                                    , lgh_split_flag
                                    , trip_description
                                    , lgh_type1
                                    , lgh_type_name
                                    , ivh_billdate
                                    , ivh_invoicenumber
                                    , lgh_booked_revtype1
                                    , ivh_billto
                                    , asgn_controlling
                                    , lgh_shiftdate
                                    , lgh_shiftnumber
                                    , shift_ss_id
                                    , stp_schdtearliest
                                    , ord_route
                                    , Cost
                                    , ord_revtype1
                                    , ord_revtype1_name
                                    , ord_revtype2
                                    , ord_revtype2_name
                                    , ord_revtype3
                                    , ord_revtype3_name
                                    , ord_revtype4
                                    , ord_revtype4_name
                                    , lgh_type2
                                    , lgh_type3
                                    , lgh_type4
                                    , asgn_payto
                                     )
                                            SELECT a.lgh_number
                                                 , a.asgn_type
                                                 , a.asgn_id
                                                 , a.asgn_date
                                                 , a.asgn_enddate
                                                 , ''
                                                 , ''
                                                 , a.mov_number
                                                 , a.asgn_number
                                                 , 0
                                                 , 0
                                                 , 0
                                                 , ''
                                                 , trc_owner
                                                 , ''
                                                 , ''
                                                 , ''
                                                 , ''
                                                 , 0
                                                 , ''
                                                 , 'RevType1'
                                                 , 'N'
                                                 , ''
                                                 , 'UNK'
                                                 , 'LghType1'
                                                 , NULL
                                                 , NULL
                                                 , 'Lgh_Booked_Revtype1'
                                                 , 'IvhBillT'
                                                 , a.asgn_controlling
                                                 , l.lgh_shiftdate
                                                 , l.lgh_shiftnumber
                                                 , l.shift_ss_id
                                                   -- PTS 47740 added 11 new columns <<start>>
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                   -- PTS 47740 <<end>>
                                                 , NULL
                                                 , NULL
                                                 , NULL
                                                 , #tmp1.trc_owner -- PTS 52192
                                            FROM assetassignment a
                                                 INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                                           AND (@shiftdate = '1950-01-01 00:00'
                                                                                OR @shiftdate = l.lgh_shiftdate)
                                                                           AND (@shiftnumber = 'UNK'
                                                                                OR @shiftnumber = l.lgh_shiftnumber)
                                                                           AND a.asgn_type = 'TRC'
                                               , @tmp1 #tmp1
                                            WHERE a.asgn_type = 'TRC'
                                                  AND a.asgn_id = trc_number
                                                  AND a.asgn_status = 'CMP'
                                                  AND pyd_status = 'NPD'
                                                  AND shift_ss_id = @min_shift_id
                                                  AND l.lgh_number NOT IN
                                            (
                                                SELECT lgh_number
                                                FROM #temp_rtn
                                                WHERE shift_ss_id = @min_shift_id
                                            )
                                                  AND (@trctyp1 = 'UNK'
                                                       OR @trctyp1 = (CASE @resourcetypeonleg
                                                                          WHEN 'Y'
                                                                          THEN l.trc_type1
                                                                          ELSE #tmp1.trc_type1
                                                                      END))
                                                  AND (@trctyp2 = 'UNK'
                                                       OR @trctyp2 = (CASE @resourcetypeonleg
                                                                          WHEN 'Y'
                                                                          THEN l.trc_type2
                                                                          ELSE #tmp1.trc_type2
                                                                      END))
                                                  AND (@trctyp3 = 'UNK'
                                                       OR @trctyp3 = (CASE @resourcetypeonleg
                                                                          WHEN 'Y'
                                                                          THEN l.trc_type3
                                                                          ELSE #tmp1.trc_type3
                                                                      END))
                                                  AND (@trctyp4 = 'UNK'
                                                       OR @trctyp4 = (CASE @resourcetypeonleg
                                                                          WHEN 'Y'
                                                                          THEN l.trc_type4
                                                                          ELSE #tmp1.trc_type4
                                                                      END))

                                     SELECT @min_shift_id = MIN(shift_ss_id)
                                     FROM #temp_rtn
                                     WHERE shift_ss_id IS NOT NULL
                                           AND shift_ss_id > @min_shift_id
                                           AND asgn_type = 'TRC'
                                 END --LOOP
                         END
                 END
         END
     --END TRACTORS

     --BEGIN CARRIERS
     IF @caryes <> 'XXX'
        OR EXISTS
     (
         SELECT *
         FROM @tmp2
     )
         BEGIN
             INSERT INTO #temp_rtn
             (lgh_number
            , asgn_type
            , asgn_id
            , asgn_date
            , asgn_enddate
            , cmp_id_start
            , cmp_id_end
            , mov_number
            , asgn_number
            , ord_hdrnumber
            , lgh_startcity
            , lgh_endcity
            , ord_number
            , name
            , cmp_name_start
            , cmp_name_end
            , cty_nmstct_start
            , cty_nmstct_end
            , need_paperwork
            , ivh_revtype1
            , revtype1_name
            , lgh_split_flag
            , trip_description
            , lgh_type1
            , lgh_type_name
            , ivh_billdate
            , ivh_invoicenumber
            , lgh_booked_revtype1
            , ivh_billto
            , asgn_controlling
            , lgh_shiftdate
            , lgh_shiftnumber
            , shift_ss_id
            , stp_schdtearliest
            , ord_route
            , Cost
            , ord_revtype1
            , ord_revtype1_name
            , ord_revtype2
            , ord_revtype2_name
            , ord_revtype3
            , ord_revtype3_name
            , ord_revtype4
            , ord_revtype4_name
            , lgh_type2
            , lgh_type3
            , lgh_type4
            , asgn_payto
             )
                    SELECT a.lgh_number
                         , a.asgn_type
                         , a.asgn_id
                         , a.asgn_date
                         , a.asgn_enddate
                         , ''
                         , ''
                         , a.mov_number
                         , a.asgn_number
                         , 0
                         , 0
                         , 0
                         , ''
                         , car_name
                         , ''
                         , ''
                         , ''
                         , ''
                         , 0
                         , ''
                         , 'RevType1'
                         , 'N'
                         , ''
                         , 'UNK'
                         , 'LghType1'
                         , NULL
                         , NULL
                         , 'Lgh_Booked_Revtype1'
                         , 'IvhBillT'
                         , a.asgn_controlling
                         , l.lgh_shiftdate
                         , l.lgh_shiftnumber
                         , l.shift_ss_id
                           -- PTS 47740 added 11 new columns <<start>>
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                           -- PTS 47740 <<end>>
                         , NULL
                         , NULL
                         , NULL
                         , #tmp2.pto_id -- PTS 52192
                    FROM assetassignment a
                         INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                   AND (@shiftdate = '1950-01-01 00:00'
                                                        OR @shiftdate = l.lgh_shiftdate)
                                                   AND (@shiftnumber = 'UNK'
                                                        OR @shiftnumber = l.lgh_shiftnumber)
                                                   AND a.asgn_type = 'CAR'
                       , @tmp2 #tmp2
                    WHERE a.asgn_type = 'CAR'
                          AND a.asgn_id = car_id
                          AND a.asgn_status = 'CMP'
                          AND pyd_status = 'NPD'
                          AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                          AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
         END
     --END CARRIERS

     --BEGIN TRAILERS
     IF @trlyes <> 'XXX'
        OR EXISTS
     (
         SELECT *
         FROM @tmp3
     )
         BEGIN
             INSERT INTO #temp_rtn
             (lgh_number
            , asgn_type
            , asgn_id
            , asgn_date
            , asgn_enddate
            , cmp_id_start
            , cmp_id_end
            , mov_number
            , asgn_number
            , ord_hdrnumber
            , lgh_startcity
            , lgh_endcity
            , ord_number
            , name
            , cmp_name_start
            , cmp_name_end
            , cty_nmstct_start
            , cty_nmstct_end
            , need_paperwork
            , ivh_revtype1
            , revtype1_name
            , lgh_split_flag
            , trip_description
            , lgh_type1
            , lgh_type_name
            , ivh_billdate
            , ivh_invoicenumber
            , lgh_booked_revtype1
            , ivh_billto
            , asgn_controlling
            , lgh_shiftdate
            , lgh_shiftnumber
            , shift_ss_id
            , stp_schdtearliest
            , ord_route
            , Cost
            , ord_revtype1
            , ord_revtype1_name
            , ord_revtype2
            , ord_revtype2_name
            , ord_revtype3
            , ord_revtype3_name
            , ord_revtype4
            , ord_revtype4_name
            , lgh_type2
            , lgh_type3
            , lgh_type4
            , asgn_payto
             )
                    SELECT a.lgh_number
                         , a.asgn_type
                         , a.asgn_id
                         , a.asgn_date
                         , a.asgn_enddate
                         , ''
                         , ''
                         , a.mov_number
                         , a.asgn_number
                         , 0
                         , 0
                         , 0
                         , ''
                         , trl_owner
                         , ''
                         , ''
                         , ''
                         , ''
                         , 0
                         , ''
                         , 'RevType1'
                         , 'N'
                         , ''
                         , 'UNK'
                         , 'LghType1'
                         , NULL
                         , NULL
                         , 'Lgh_Booked_Revtype1'
                         , 'IvhBillT'
                         , a.asgn_controlling
                         , l.lgh_shiftdate
                         , l.lgh_shiftnumber
                         , l.shift_ss_id
                           -- PTS 47740 added 11 new columns <<start>>
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                         , NULL
                           -- PTS 47740 <<end>>
                         , NULL
                         , NULL
                         , NULL
                         , #tmp3.trl_owner -- PTS 52192
                    FROM assetassignment a
                         INNER JOIN legheader l ON a.lgh_number = l.lgh_number
                                                   AND (@shiftdate = '1950-01-01 00:00'
                                                        OR @shiftdate = l.lgh_shiftdate)
                                                   AND (@shiftnumber = 'UNK'
                                                        OR @shiftnumber = l.lgh_shiftnumber)
                                                   AND a.asgn_type = 'TRL'
                       , @tmp3 #tmp3
                    WHERE a.asgn_type = 'TRL'
                          AND a.asgn_id = trl_id
                          AND a.asgn_status = 'CMP'
                          AND pyd_status = 'NPD'
                          AND a.asgn_date BETWEEN @lostartdate AND @histartdate
                          AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
         END
     --END TRAILERS

     --BEGIN THIRD-PARTIES
     -- MRH 31225 Third party
     -- Need TPR ID and not on hold....
     IF @tpryes <> 'XXX'
        OR EXISTS
     (
         SELECT *
         FROM @tmp4
     )
         BEGIN
             -- LOR   PTS# 31839
             SELECT @agent = UPPER(LTRIM(RTRIM(gi_string1)))
             FROM @GIKEY
             WHERE gi_name = 'AgentCommiss'
             IF @agent = 'Y'
                OR @agent = 'YES'
                 BEGIN
                     DECLARE @tprTypeMode INT
                     SELECT @tprTypeMode = COALESCE(gi_integer1, 2)
                     FROM @GIKEY
                     WHERE gi_name = 'ThirdPartyTypes'

                     IF(@tprTypeMode = 2)
                         BEGIN
                             INSERT INTO @tmp4
                                    SELECT DISTINCT
                                           tpr.tpr_id
                                         , tpr.tpr_name
                                         , tpr.tpr_payto
                                    FROM thirdpartyprofile tpr
                                         JOIN RowRestrictValidAssignments_thirdpartyprofile_fn() rsva ON tpr.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                                                                         OR rsva.rowsec_rsrv_id = 0
                                         JOIN @tmp4 #tmp4 ON #tmp4.tpr_id = tpr.tpr_id
                                    WHERE @tpr_id IN('UNKNOWN', tpr.tpr_id)
                                         AND (@tprtyp1 = 'UNK'
                                              OR @tprtyp1 = ThirdPartyType1)
                                         AND (@tprtyp2 = 'UNK'
                                              OR @tprtyp2 = ThirdPartyType2)
                                         AND (@tprtyp3 = 'UNK'
                                              OR @tprtyp3 = ThirdPartyType3)
                                         AND (@tprtyp4 = 'UNK'
                                              OR @tprtyp4 = ThirdPartyType4)
                                         AND @acct_typ IN('X', tpr_actg_type)
                                    AND tpr_actg_type IN('A', 'P')
                             AND (@profile_owner = 'UNKNOWN'
                                  OR @profile_owner = tpr.tpr_payto)
                             AND #tmp4.tpr_id IS NULL
                         END
                     ELSE
                         BEGIN
                             INSERT INTO @tmp4
                                    SELECT DISTINCT
                                           tpr.tpr_id
                                         , tpr.tpr_name
                                         , tpr.tpr_payto
                                    FROM thirdpartyprofile tpr
                                         JOIN RowRestrictValidAssignments_thirdpartyprofile_fn() rsva ON tpr.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                                                                         OR rsva.rowsec_rsrv_id = 0
                                         JOIN @tmp4 #tmp4 ON #tmp4.tpr_id = tpr.tpr_id
                                    WHERE @tpr_id IN('UNKNOWN', tpr.tpr_id)
                                         AND (@tprtype1 IN('N', 'X')
                                    OR (@tprtype1 = 'Y'
                                        AND @tprtype1 = tpr_thirdpartytype1))
                                    AND (@tprtype2 IN('N', 'X')
                                    OR (@tprtype2 = 'Y'
                                        AND @tprtype2 = tpr_thirdpartytype2))
                             AND (@tprtype3 IN('N', 'X')
                             OR (@tprtype3 = 'Y'
                                 AND @tprtype3 = tpr_thirdpartytype3))
                         AND (@tprtype4 IN('N', 'X')
                         OR (@tprtype4 = 'Y'
                             AND @tprtype4 = tpr_thirdpartytype4))
                     AND (@tprtype5 IN('N', 'X')
                     OR (@tprtype5 = 'Y'
                         AND @tprtype5 = tpr_thirdpartytype5))
                     AND (@tprtype6 IN('N', 'X')
                     OR (@tprtype6 = 'Y'
                         AND @tprtype6 = tpr_thirdpartytype6))
                 AND @acct_typ IN('X', tpr_actg_type)
             AND tpr_actg_type IN('A', 'P')
             AND (@profile_owner = 'UNKNOWN'
                  OR @profile_owner = tpr.tpr_payto)
             AND #tmp4.tpr_id IS NULL
                         END

                     INSERT INTO #temp_rtn
                     (lgh_number
                    , asgn_type
                    , asgn_id
                    , asgn_date
                    , asgn_enddate
                    , cmp_id_start
                    , cmp_id_end
                    , mov_number
                    , asgn_number
                    , ord_hdrnumber
                    , lgh_startcity
                    , lgh_endcity
                    , ord_number
                    , name
                    , cmp_name_start
                    , cmp_name_end
                    , cty_nmstct_start
                    , cty_nmstct_end
                    , need_paperwork
                    , ivh_revtype1
                    , revtype1_name
                    , lgh_split_flag
                    , trip_description
                    , lgh_type1
                    , lgh_type_name
                    , ivh_billdate
                    , ivh_invoicenumber
                    , lgh_booked_revtype1
                    , ivh_billto
                    , asgn_controlling
                    , asgn_payto
                     )
                            SELECT 0
                                 , 'TPR'
                                 , orderheader.ord_thirdpartytype1
                                 , orderheader.ord_startdate
                                 , orderheader.ord_completiondate
                                 , ''
                                 , ''
                                 , orderheader.mov_number
                                 , 0
                                 , orderheader.ord_hdrnumber
                                 , 0
                                 , 0
                                 , orderheader.ord_number
                                 , tpr_name
                                 , ''
                                 , ''
                                 , ''
                                 , ''
                                 , 0
                                 , ''
                                 , 'RevType1'
                                 , 'N'
                                 , ''
                                 , 'UNK'
                                 , 'LghType1'
                                 , NULL
                                 , NULL
                                 , 'Lgh_Booked_Revtype1'
                                 , 'IvhBillT'
                                 , 'Y'
                                 , #TMP4.tpr_payto
                            FROM orderheader
                               , @tmp4 #tmp4
                            WHERE orderheader.ord_thirdpartytype1 = tpr_id
                                  AND orderheader.ord_status = 'CMP'
                                  AND orderheader.ord_pyd_status_1 = 'NPD'
                                  AND orderheader.ord_startdate BETWEEN @lostartdate AND @histartdate
                                  AND orderheader.ord_completiondate BETWEEN @loenddate AND @hienddate
                                  AND ((@rowsecurity <> 'Y')
                                       OR EXISTS
                                      (
                                          SELECT 1
                                          FROM @tbl_restrictedbyuser rsva
                                          WHERE orderheader.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                OR rsva.rowsec_rsrv_id = 0
                                      ))

                     INSERT INTO #temp_rtn
                     (lgh_number
                    , asgn_type
                    , asgn_id
                    , asgn_date
                    , asgn_enddate
                    , cmp_id_start
                    , cmp_id_end
                    , mov_number
                    , asgn_number
                    , ord_hdrnumber
                    , lgh_startcity
                    , lgh_endcity
                    , ord_number
                    , name
                    , cmp_name_start
                    , cmp_name_end
                    , cty_nmstct_start
                    , cty_nmstct_end
                    , need_paperwork
                    , ivh_revtype1
                    , revtype1_name
                    , lgh_split_flag
                    , trip_description
                    , lgh_type1
                    , lgh_type_name
                    , ivh_billdate
                    , ivh_invoicenumber
                    , lgh_booked_revtype1
                    , ivh_billto
                    , asgn_controlling
                    , asgn_payto
                     )
                            SELECT 0
                                 , 'TPR'
                                 , orderheader.ord_thirdpartytype1
                                 , orderheader.ord_startdate
                                 , orderheader.ord_completiondate
                                 , ''
                                 , ''
                                 , orderheader.mov_number
                                 , 0
                                 , orderheader.ord_hdrnumber
                                 , 0
                                 , 0
                                 , orderheader.ord_number
                                 , tpr_name
                                 , ''
                                 , ''
                                 , ''
                                 , ''
                                 , 0
                                 , ''
                                 , 'RevType1'
                                 , 'N'
                                 , ''
                                 , 'UNK'
                                 , 'LghType1'
                                 , NULL
                                 , NULL
                                 , 'Lgh_Booked_Revtype1'
                                 , 'IvhBillT'
                                 , 'Y'
                                 , #tmp4.tpr_payto
                            FROM orderheader
                               , @tmp4 #tmp4
                            WHERE orderheader.ord_thirdpartytype2 = tpr_id
                                  AND orderheader.ord_status = 'CMP'
                                  AND orderheader.ord_pyd_status_2 = 'NPD'
                                  AND orderheader.ord_startdate BETWEEN @lostartdate AND @histartdate
                                  AND orderheader.ord_completiondate BETWEEN @loenddate AND @hienddate
                                  AND ((@rowsecurity <> 'Y')
                                       OR EXISTS
                                      (
                                          SELECT 1
                                          FROM @tbl_restrictedbyuser rsva
                                          WHERE orderheader.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                OR rsva.rowsec_rsrv_id = 0
                                      ))
                 END
             ELSE
             -- LOR
             INSERT INTO #temp_rtn
             (lgh_number
            , asgn_type
            , asgn_id
            , asgn_date
            , asgn_enddate
            , cmp_id_start
            , cmp_id_end
            , mov_number
            , asgn_number
            , ord_hdrnumber
            , lgh_startcity
            , lgh_endcity
            , ord_number
            , name
            , cmp_name_start
            , cmp_name_end
            , cty_nmstct_start
            , cty_nmstct_end
            , need_paperwork
            , ivh_revtype1
            , revtype1_name
            , lgh_split_flag
            , trip_description
            , lgh_type1
            , lgh_type_name
            , ivh_billdate
            , ivh_invoicenumber
            , lgh_booked_revtype1
            , ivh_billto
            , asgn_controlling
            , asgn_payto
             )
                    SELECT lgh_number
                         , 'TPR'
                         , tpa.tpr_id AS asgn_id
                         ,
                    (
                        SELECT lgh_startdate
                        FROM legheader
                        WHERE lgh_number = tpa.lgh_number
                    ) AS asgn_date
                         ,
                    (
                        SELECT lgh_enddate
                        FROM legheader
                        WHERE lgh_number = tpa.lgh_number
                    ) AS asgn_enddate
                         , ''
                         , ''
                         , 0
                         , 0
                         , 0
                         , 0
                         , 0
                         , ''
                         , ''
                         , ''
                         , ''
                         , ''
                         , ''
                         , 0
                         , ''
                         , ''
                         , 'N'
                         , ''
                         , 'UNK'
                         , ''
                         , NULL
                         , NULL
                         , 'Lgh_Booked_Revtype1'
                         , 'IvhBillT'
                         , 'Y'
                         , COALESCE(#tmp5.pto_id, 'UNKNOWN') AS asgn_payto
                    FROM thirdpartyassignment tpa
                         JOIN thirdpartyprofile tpp ON tpp.tpr_id = tpa.tpr_id
                         LEFT OUTER JOIN @tmp5 #tmp5 ON #tmp5.pto_id = tpp.tpr_payto
                    WHERE COALESCE(pyd_status, 'NPD') = 'NPD'
                          AND (@tpr_id = tpa.tpr_id
                               OR @tpr_id = 'UNKNOWN')
                          AND (@tpr_type = tpa.tpr_type
                               OR @tpr_type = 'UNK')
                          -----PTS #82285
                          AND (@tprtyp1 = 'UNK'
                               OR @tprtyp1 = tpa.ThirdPartyType1)
                          AND (@tprtyp2 = 'UNK'
                               OR @tprtyp2 = tpa.ThirdPartyType2)
                          AND (@tprtyp3 = 'UNK'
                               OR @tprtyp3 = tpa.ThirdPartyType3)
                          AND (@tprtyp4 = 'UNK'
                               OR @tprtyp4 = tpa.ThirdPartyType4)
                          -----The end of PTS #82285
                          AND COALESCE(tpa_status, 'NPD') <> 'DEL'
                          AND
                    (
                        SELECT lgh_outstatus
                        FROM legheader
                        WHERE lgh_number = tpa.lgh_number
                    ) = 'CMP'
                          AND
                    (
                        SELECT lgh_startdate
                        FROM legheader
                        WHERE lgh_number = tpa.lgh_number
                    ) BETWEEN @lostartdate AND @histartdate
                          AND
                    (
                        SELECT lgh_enddate
                        FROM legheader
                        WHERE lgh_number = tpa.lgh_number
                    ) BETWEEN @loenddate AND @hienddate
                          AND (@pytyes = 'XXX'
                               OR #tmp5.pto_id IS NOT NULL)
         END
     -- MRH
     --END THIRD-PARTIES

     --CREATE INDEXES NOW
     CREATE INDEX temp_rtn_ord_hdrnumber ON #temp_rtn
     (lgh_number, ord_hdrnumber
     )
     CREATE INDEX #dk_temp_idx_mov ON #temp_rtn(mov_number)

     /* Get the mov number */

     UPDATE #temp_rtn
       SET
           mov_number = legheader.mov_number,
           ord_hdrnumber = legheader.ord_hdrnumber,
           lgh_startcity = legheader.lgh_startcity,
           cmp_id_start = legheader.cmp_id_start,
           lgh_endcity = legheader.lgh_endcity,
           cmp_id_end = legheader.cmp_id_end,
           cty_nmstct_start = lgh_startcty_nmstct,
           cty_nmstct_end = lgh_endcty_nmstct,
           lgh_split_flag = legheader.lgh_split_flag,
           lgh_type1 = COALESCE(legheader.lgh_type1, 'UNK'),
           ivh_billdate = NULL,
           ivh_invoicenumber = NULL,
           lgh_booked_revtype1 = COALESCE(legheader.lgh_booked_revtype1, 'UNK'),
           lgh_type2 = COALESCE(legheader.lgh_type2, 'UNK'), -- PTS 52192
           lgh_type3 = COALESCE(legheader.lgh_type3, 'UNK'), -- PTS 52192
           lgh_type4 = COALESCE(legheader.lgh_type4, 'UNK'), -- PTS 52192
           stp_schdtearliest = legheader.lgh_schdtearliest
     FROM legheader
     WHERE legheader.lgh_number = #temp_rtn.lgh_number

     --BEGIN PTS 52995 SPN
     UPDATE #temp_rtn
       SET
           lgh_booked_revtype1 = 'UNK'
     WHERE lgh_booked_revtype1 = 'Lgh_Booked_Revtype1'
     --END PTS 52995 SPN

     -- 21110 JD exclude hourly orders from trips ready to settle
     SELECT @revtype4 = gi_string4
     FROM @GIKEY
     WHERE gi_name = 'TripStlExcludeRevtypefromQ'
     IF @revtype4 IS NOT NULL
        AND EXISTS
     (
         SELECT *
         FROM labelfile
         WHERE labeldefinition = 'Revtype4'
               AND abbr = @revtype4
     )
         BEGIN
             DELETE #temp_rtn
             FROM orderheader
             WHERE #temp_rtn.ord_hdrnumber = orderheader.ord_hdrnumber
                   AND orderheader.ord_revtype4 = @revtype4
         END
     -- end 21110 JD

     /* PTS 17873 - DJM - 4/11/03 Remove legs that don't match the requrired lgh_type1   */

     SELECT @lgh_type1 = COALESCE(@lgh_type1, 'UNK')
     IF @lgh_type1 <> 'UNK'
        AND @lgh_type1 <> ''
         DELETE FROM #temp_rtn
         WHERE lgh_type1 <> @lgh_type1

     UPDATE #temp_rtn
       SET
           trip_description = dbo.tmwf_scroll_assignments_concat(mov_number)
     UPDATE #temp_rtn
       SET
           trip_description = SUBSTRING(trip_description, 2, DATALENGTH(trip_description))
     WHERE DATALENGTH(trip_description) > 0

     --UPDATE #temp_rtn
     --   SET ord_number = (SELECT orderheader.ord_number
     --                       FROM orderheader
     --                      WHERE orderheader.ord_hdrnumber = #temp_rtn.ord_hdrnumber)
     --END PTS 54538 MTC
     DECLARE @revtype1userlabel VARCHAR(20), @revtype2userlabel VARCHAR(20), @revtype3userlabel VARCHAR(20), @revtype4userlabel VARCHAR(20)
     SELECT @revtype1userlabel = MIN(labelfile.userlabelname)
     FROM labelfile
     WHERE labeldefinition = 'RevType1'
           AND labelfile.userlabelname > ''
     SELECT @revtype2userlabel = MIN(labelfile.userlabelname)
     FROM labelfile
     WHERE labeldefinition = 'RevType2'
           AND labelfile.userlabelname > ''
     SELECT @revtype3userlabel = MIN(labelfile.userlabelname)
     FROM labelfile
     WHERE labeldefinition = 'RevType3'
           AND labelfile.userlabelname > ''
     SELECT @revtype4userlabel = MIN(labelfile.userlabelname)
     FROM labelfile
     WHERE labeldefinition = 'RevType4'
           AND labelfile.userlabelname > ''

     UPDATE #temp_rtn
       SET
           ord_revtype1_name = @revtype1userlabel,
           ord_revtype2_name = @revtype2userlabel,
           ord_revtype3_name = @revtype3userlabel,
           ord_revtype4_name = @revtype4userlabel

     UPDATE #temp_rtn
       SET
           ord_number = orderheader.ord_number,
           ord_route = orderheader.ord_route,
           ord_revtype1 = orderheader.ord_revtype1,
           ord_revtype2 = orderheader.ord_revtype2,
           ord_revtype3 = orderheader.ord_revtype3,
           ord_revtype4 = orderheader.ord_revtype4
     FROM #temp_rtn
          INNER JOIN orderheader ON #temp_rtn.ord_hdrnumber = orderheader.ord_hdrnumber
                                    AND #temp_rtn.ord_hdrnumber > 0

     UPDATE #temp_rtn
       SET
           cmp_name_start = company.cmp_name
     FROM #temp_rtn
          INNER JOIN company ON #temp_rtn.cmp_id_start = company.cmp_id

     UPDATE #temp_rtn
       SET
           cmp_name_end = company.cmp_name
     FROM #temp_rtn
          INNER JOIN company ON #temp_rtn.cmp_id_end = company.cmp_id

     UPDATE #temp_rtn
       SET
           #temp_rtn.ivh_revtype1 = invoiceheader.ivh_revtype1,
           #temp_rtn.ivh_billto = invoiceheader.ivh_billto
     FROM #temp_rtn
          INNER JOIN invoiceheader ON #temp_rtn.ord_hdrnumber = invoiceheader.ord_hdrnumber
                                      AND #temp_rtn.ord_hdrnumber > 0
                                      AND invoiceheader.ivh_hdrnumber =
     (
         SELECT MIN(ivh_hdrnumber)
         FROM invoiceheader i
         WHERE #temp_rtn.ord_hdrnumber > 0
               AND i.ord_hdrnumber = #temp_rtn.ord_hdrnumber
     )

     UPDATE #temp_rtn
       SET
           Cost =
     (
         SELECT SUM(pyd_amount)
         FROM paydetail
         WHERE paydetail.ord_hdrnumber > 0
               AND ord_hdrnumber = #temp_rtn.ord_hdrnumber
     )

     --UPDATE #temp_rtn
     --   SET ord_number =
     --       (
     --        CASE WHEN coalesce(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
     --        ELSE
     --             (SELECT orderheader.ord_number
     --                FROM orderheader
     --               WHERE orderheader.ord_hdrnumber = #temp_rtn.ord_hdrnumber
     --             )
     --        END
     --       )
     --     , ord_route =
     --       (
     --        CASE WHEN coalesce(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
     --        ELSE
     --             (SELECT orderheader.ord_route
     --                FROM orderheader
     --               WHERE orderheader.ord_hdrnumber = #temp_rtn.ord_hdrnumber
     --             )
     --        END
     --       )
     --     , stp_schdtearliest =
     --       (
     --        CASE WHEN coalesce(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
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
     --        CASE WHEN coalesce(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
     --        ELSE
     --             (SELECT sum(pyd_amount)
     --                FROM paydetail
     --               WHERE ord_hdrnumber = #temp_rtn.ord_hdrnumber
     --             )
     --        END
     --       )
     --     , ord_revtype1 =
     --       (
     --        CASE WHEN coalesce(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
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
     --        CASE WHEN coalesce(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
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
     --        CASE WHEN coalesce(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
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
     --        CASE WHEN coalesce(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
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
     --        CASE WHEN coalesce(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
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
     --        CASE WHEN coalesce(#temp_rtn.ord_hdrnumber,0) = 0 THEN NULL
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

     SELECT @paperworkmode = COALESCE(gi_string1, 'A')
     FROM @GIKEY
     WHERE gi_name = 'PaperWorkMode'
     SELECT @paperworkchecklevel = COALESCE(gi_string1, 'ORDER')
     FROM @GIKEY
     WHERE gi_name = 'PaperWorkCheckLevel'

     /* PTS 16982 - DJM - Modify the Proc to properly identify the Paperwork required each Order and/or Leg to be settled.   */

/* Insert a record into #temp_pwk for every Legheader/Orderheader combination.  Gets all the Orderheaders on
   a Leg so Paperwork can be tracked for every Order.    */

     INSERT INTO #temp_pwk
            SELECT #temp_rtn.lgh_number
                 , stops.ord_hdrnumber
                 , 0 req_cnt
                 , 0 rec_cnt
                 , 'UNKNOWN'
            --(select coalesce(ord_billto,'UNK') from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) ord_billto
            FROM #temp_rtn
               , stops
            WHERE stops.lgh_number = #temp_rtn.lgh_number
                  AND stops.ord_hdrnumber > 0  --coalesce(stops.ord_hdrnumber,0) > 0  pmill 49424 performance enhancement

            GROUP BY #temp_rtn.lgh_number
                   , stops.ord_hdrnumber
            ORDER BY #temp_rtn.lgh_number

     UPDATE #temp_pwk
       SET
           #temp_pwk.ord_billto = orderheader.ord_billto
     FROM #temp_pwk
          INNER JOIN orderheader ON #temp_pwk.ord_hdrnumber = orderheader.ord_hdrnumber

     /* Set the number of required paperwork fields for each order     */

     --PTS 36869 EMK Added Invoice Required
     IF @paperworkchecklevel = 'LEG'
         BEGIN
             IF @paperworkmode = 'B'
                 UPDATE #temp_pwk
                   SET
                       req_cnt =
                 (
                     SELECT COUNT(*)
                     FROM billdoctypes
                     WHERE cmp_id = #temp_pwk.ord_billto
                           AND COALESCE(billdoctypes.bdt_inv_required, 'Y') = 'Y'
                           AND (COALESCE(bdt_required_for_application, 'B') = 'B'
                                OR bdt_required_for_application = 'S') --PTS 40877
                           AND ((EXISTS
                                (
                                    SELECT *
                                    FROM stops stp
                                    WHERE stp.lgh_number = #temp_pwk.lgh_number
                                          AND stp_type = 'PUP'
                                )
                                 AND (COALESCE(bdt_required_for_fgt_event, 'B') = 'B'
                                      OR bdt_required_for_fgt_event = 'PUP'))
                                OR (EXISTS
                                   (
                                       SELECT *
                                       FROM stops stp
                                       WHERE stp.lgh_number = #temp_pwk.lgh_number
                                             AND stp_type = 'DRP'
                                   )
                                    AND (COALESCE(bdt_required_for_fgt_event, 'B') = 'B'
                                         OR bdt_required_for_fgt_event = 'DRP')))
                 ),
                       rec_cnt =
                 (
                     SELECT COUNT(*)
                     FROM paperwork
                        , billdoctypes
                     WHERE #temp_pwk.ord_hdrnumber = paperwork.ord_hdrnumber
                           AND paperwork.pw_received = 'Y'
                           AND (@paperwork_GI_cutoff_flag = 'N'
                                OR paperwork.pw_dt <= @paperwork_computed_cutoff_datetime) --vjh 45500
                           AND #temp_pwk.lgh_number = paperwork.lgh_number
                           AND billdoctypes.cmp_id = #temp_pwk.ord_billto
                           AND billdoctypes.bdt_doctype = paperwork.abbr
                           AND COALESCE(billdoctypes.bdt_inv_required, 'Y') = 'Y'
                           AND (COALESCE(bdt_required_for_application, 'B') = 'B'
                                OR bdt_required_for_application = 'S') --PTS 40877
                           AND ((EXISTS
                                (
                                    SELECT *
                                    FROM stops stp
                                    WHERE stp.lgh_number = #temp_pwk.lgh_number
                                          AND stp_type = 'PUP'
                                )
                                 AND (COALESCE(bdt_required_for_fgt_event, 'B') = 'B'
                                      OR bdt_required_for_fgt_event = 'PUP'))
                                OR (EXISTS
                                   (
                                       SELECT *
                                       FROM stops stp
                                       WHERE stp.lgh_number = #temp_pwk.lgh_number
                                             AND stp_type = 'DRP'
                                   )
                                    AND (COALESCE(bdt_required_for_fgt_event, 'B') = 'B'
                                         OR bdt_required_for_fgt_event = 'DRP')))
                 )  --PTS 36869
             ELSE
             UPDATE #temp_pwk
               SET
                   req_cnt =
             (
                 SELECT COUNT(*)
                 FROM labelfile
                 WHERE labeldefinition = 'Paperwork'
                       AND (retired IS NULL
                            OR retired = 'N')
             ),
                   rec_cnt =
             (
                 SELECT COUNT(*)
                 FROM paperwork
                 WHERE #temp_pwk.ord_hdrnumber = paperwork.ord_hdrnumber
                       AND paperwork.pw_received = 'Y'
                       AND (@paperwork_GI_cutoff_flag = 'N'
                            OR paperwork.pw_dt <= @paperwork_computed_cutoff_datetime) --vjh 45500
                       AND #temp_pwk.lgh_number = paperwork.lgh_number
             )
         END
     ELSE

     /* Paperwork is not tracked by Leg,  Only the total number for the Order is tracked    */

         BEGIN
             IF @paperworkmode = 'B'
                 UPDATE #temp_pwk
                   SET
                       req_cnt =
                 (
                     SELECT COUNT(*)
                     FROM billdoctypes
                     WHERE cmp_id = #temp_pwk.ord_billto
                           AND COALESCE(billdoctypes.bdt_inv_required, 'Y') = 'Y'
                           AND (COALESCE(bdt_required_for_application, 'B') = 'B'
                                OR bdt_required_for_application = 'S') --PTS 40877
                 ),
                       rec_cnt =
                 (
                     SELECT COUNT(*)
                     FROM paperwork
                        , billdoctypes
                     WHERE #temp_pwk.ord_hdrnumber = paperwork.ord_hdrnumber
                           AND paperwork.pw_received = 'Y'
                           AND (@paperwork_GI_cutoff_flag = 'N'
                                OR paperwork.pw_dt <= @paperwork_computed_cutoff_datetime) --vjh 45500
                           AND billdoctypes.cmp_id = #temp_pwk.ord_billto
                           AND billdoctypes.bdt_doctype = paperwork.abbr
                           AND COALESCE(billdoctypes.bdt_inv_required, 'Y') = 'Y'
                           AND (COALESCE(bdt_required_for_application, 'B') = 'B'
                                OR bdt_required_for_application = 'S') --PTS 40877
                 )
             ELSE
             UPDATE #temp_pwk
               SET
                   req_cnt =
             (
                 SELECT COUNT(*)
                 FROM labelfile
                 WHERE labeldefinition = 'Paperwork'
                       AND (retired IS NULL
                            OR retired = 'N')
             ),
                   rec_cnt =
             (
                 SELECT COUNT(*)
                 FROM paperwork
                 WHERE #temp_pwk.ord_hdrnumber = paperwork.ord_hdrnumber
                       AND paperwork.pw_received = 'Y'
                       AND (@paperwork_GI_cutoff_flag = 'N'
                            OR paperwork.pw_dt <= @paperwork_computed_cutoff_datetime)
             )--vjh 45500
         END

     IF @paperworkchecklevel = 'LEG'
         BEGIN

             /* Update where all paperwork is in       */

             UPDATE #temp_rtn
               SET
                   need_paperwork = 1
             FROM #temp_rtn
             WHERE EXISTS
             (
                 SELECT *
                 FROM #temp_pwk
                 WHERE #temp_pwk.lgh_number = #temp_rtn.lgh_number
                       AND rec_cnt >= req_cnt
             )

             /* Update where all paperwork is not in   */

             UPDATE #temp_rtn
               SET
                   need_paperwork = -1
             FROM #temp_rtn
             WHERE EXISTS
             (
                 SELECT *
                 FROM #temp_pwk
                 WHERE #temp_pwk.lgh_number = #temp_rtn.lgh_number
                       AND rec_cnt < req_cnt
             )
         END
     ELSE
         BEGIN

             /* Update where all paperwork is in       */

             UPDATE #temp_rtn
               SET
                   need_paperwork = 1
             FROM #temp_rtn
             WHERE EXISTS
             (
                 SELECT *
                 FROM #temp_pwk
                 WHERE #temp_pwk.ord_hdrnumber = #temp_rtn.ord_hdrnumber
                       AND rec_cnt >= req_cnt
             )

             /* Update where all paperwork is not in   */

             UPDATE #temp_rtn
               SET
                   need_paperwork = -1
             FROM #temp_rtn
             WHERE EXISTS
             (
                 SELECT *
                 FROM #temp_pwk
                 WHERE #temp_pwk.ord_hdrnumber = #temp_rtn.ord_hdrnumber
                       AND rec_cnt < req_cnt
             )
         END
     -- End 16982

     DROP TABLE #temp_pwk

     IF @stlmustinv = 'Y'
        OR @StlMustOrd = 'Y'
         BEGIN
             --get the orders we need to consider
             IF @splitmustinv = 'Y'
                OR @StlMustOrd = 'Y'
                 BEGIN
                     INSERT INTO #temp_Orders
                            SELECT a.lgh_number
                                 , s.ord_hdrnumber
                                 , 'N'
                                 , 'N'
                            FROM #temp_rtn a
                                 JOIN stops s ON a.lgh_number = s.lgh_number
                                                 AND s.ord_hdrnumber <> 0 -- SGB PTS 48667 need to exclude 0 ord_hdrnumbers
                 END
             ELSE
                 BEGIN --@splitmustinv = 'N' so only need to check for orders on stops with drop events
                     INSERT INTO #temp_Orders
                            SELECT a.lgh_number
                                 , s.ord_hdrnumber
                                 , 'N'
                                 , 'N'
                            FROM #temp_rtn a
                                 JOIN stops s ON a.lgh_number = s.lgh_number
                                 JOIN event e ON e.stp_number = s.stp_number
                                 JOIN eventcodetable ect ON ect.abbr = e.evt_eventcode
                                                            AND fgt_event = 'DRP'
                 END
         END

     IF @splitmustinv = 'N'
         BEGIN
             --vjh 56345  splits without drops do not require invoicesif @splitmustinv = 'N'
             UPDATE #temp_Orders
               SET
                   Inv_OK_Flag = 'Y'
             WHERE NOT EXISTS
             (
                 SELECT 1
                 FROM legheader l
                      JOIN stops s ON l.lgh_number = s.lgh_number
                      JOIN event e ON e.stp_number = s.stp_number
                      JOIN eventcodetable ect ON ect.abbr = e.evt_eventcode
                                                 AND fgt_event = 'DRP'
                 WHERE s.lgh_number = #temp_Orders.lgh_number
                       AND s.ord_hdrnumber > 0
             )
         END

     IF @StlMustOrd = 'Y'
         BEGIN
             --@StlMustOrd = 'Y'
             UPDATE #temp_Orders
               SET
                   Ord_OK_Flag = 'Y'
             WHERE EXISTS
             (
                 SELECT *
                 FROM orderheader o
                 WHERE o.ord_hdrnumber = #temp_Orders.ord_hdrnumber
                       AND o.ord_status = 'CMP'
             )
         END
     ELSE
         BEGIN
             --@StlMustOrd = 'N'
             UPDATE #temp_Orders
               SET
                   Ord_OK_Flag = 'Y'
         END

     --now look at the invoices.
     IF @ls_invstat1 <> ''
         BEGIN
             IF @stlmustinv = 'Y'
                 BEGIN
                     --@ps_invstat1 and @stlmustinv = 'Y'
                     --update if any invoice exists for the order and the invoice status is not in the exclude list
                     UPDATE #temp_Orders
                       SET
                           Inv_OK_Flag = 'Y'
                     WHERE EXISTS
                     (
                         SELECT *
                         FROM invoiceheader i
                         WHERE i.ord_hdrnumber = #temp_Orders.ord_hdrnumber
                               AND ivh_invoicestatus NOT IN(@ls_invstat1, @ls_invstat2, @ls_invstat3, @ls_invstat4)
                         AND (i.ivh_definition = 'LH'
                              OR @stlmustinvLH = 'ALL')
                     )
                     OR EXISTS
                     (
                         SELECT *
                         FROM invoiceheader i
                              JOIN invoicemaster ON ivm_invoiceordhdrnumber = i.ord_hdrnumber
                         WHERE invoicemaster.ord_hdrnumber = #temp_Orders.ord_hdrnumber
                               AND ivh_invoicestatus NOT IN(@ls_invstat1, @ls_invstat2, @ls_invstat3, @ls_invstat4)
                              AND (i.ivh_definition = 'LH'
                                   OR @stlmustinvLH = 'ALL')
                     )
                 END
             ELSE
                 BEGIN
                     --@ps_invstat1 and @stlmustinv = 'N'
                     UPDATE #temp_Orders
                       SET
                           Inv_OK_Flag = 'Y'
                 END
         END
     ELSE
         BEGIN --@ls_invstat1 = ''
             IF @stlmustinv = 'Y'
                 BEGIN
                     --update if any invoice exists for the order AND the order is on complete status
                     UPDATE #temp_Orders
                       SET
                           #temp_Orders.Inv_OK_Flag = 'Y'
                     WHERE(EXISTS
                          (
                              SELECT *
                              FROM invoiceheader i
                              WHERE i.ord_hdrnumber = #temp_Orders.ord_hdrnumber
                                    AND (i.ivh_definition = 'LH'
                                         OR @stlmustinvLH = 'ALL')
                          )
                           OR EXISTS
                          (
                              SELECT *
                              FROM invoiceheader i
                                   JOIN invoicemaster ON ivm_invoiceordhdrnumber = i.ord_hdrnumber
                              WHERE invoicemaster.ord_hdrnumber = #temp_Orders.ord_hdrnumber
                                    AND (i.ivh_definition = 'LH'
                                         OR @stlmustinvLH = 'ALL')
                          ))
                 END
             ELSE
                 BEGIN
                     --@ps_invstat1='' and @stlmustinv = 'N'
                     UPDATE #temp_Orders
                       SET
                           Inv_OK_Flag = 'Y'
                 END
         END

     UPDATE #temp_Orders
       SET
           Inv_OK_Flag = 'Y'
     WHERE EXISTS
     (
         SELECT *
         FROM orderheader o
         WHERE o.ord_hdrnumber = #temp_Orders.ord_hdrnumber
               AND ord_invoicestatus = 'XIN'
     )
           AND #temp_Orders.ord_hdrnumber > 0
     --end

     INSERT INTO #temp_rtn1
            SELECT a.*
            FROM #temp_rtn a
            WHERE NOT EXISTS
            (
                SELECT *
                FROM #temp_Orders
                WHERE(Inv_OK_Flag = 'N'
                      OR Ord_OK_Flag = 'N')
                     AND a.lgh_number = #temp_Orders.lgh_number
            )
                  OR (a.lgh_split_flag = 'S'
                      AND @ComputeRevenueByTripSegment = 'Y')

     -- PTS 31363 -- BL (start)
     -- Update billdate and invoicenumber rather than set it during the insert
     UPDATE #temp_rtn1
       SET
           ivh_invoicenumber =
     (
         SELECT MAX(ivh_invoicenumber)
         FROM invoiceheader
         WHERE #temp_rtn1.ord_hdrnumber > 0
               AND #temp_rtn1.ord_hdrnumber = invoiceheader.ord_hdrnumber
     )
     WHERE #temp_rtn1.ord_hdrnumber > 0

     -- For invoice by move cases
     UPDATE #temp_rtn1
       SET
           ivh_invoicenumber =
     (
         SELECT MAX(ivh_invoicenumber)
         FROM invoiceheader
         WHERE #temp_rtn1.mov_number = invoiceheader.mov_number
     )
     WHERE #temp_rtn1.ivh_invoicenumber IS NULL

     UPDATE #temp_rtn1
       SET
           ivh_billdate = invoiceheader.ivh_billdate,
           ivh_billto = invoiceheader.ivh_billto,
           ivh_revtype1 = invoiceheader.ivh_revtype1
     FROM #temp_rtn1
          INNER JOIN invoiceheader ON #temp_rtn1.ord_hdrnumber = invoiceheader.ord_hdrnumber
                                      AND #temp_rtn1.ivh_invoicenumber = invoiceheader.ivh_invoicenumber
                                      AND #temp_rtn1.ord_hdrnumber > 0

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
     IF @beg_invoice_bill_date > CONVERT(DATETIME, '1950-01-01 00:00')
        OR @end_invoice_bill_date < CONVERT(DATETIME, '2049-12-31 23:59')
         BEGIN
             -- Remove paydetails that do NOT fit in given invoice bill_date range
             DELETE FROM #temp_rtn1
             WHERE ivh_billdate IS NULL
                   OR ivh_billdate > @end_invoice_bill_date
                   OR ivh_billdate < @beg_invoice_bill_date
         END
     -- PTS 16945 -- BL (end)

     -- PTS 32781 - DJM
     -- Retrict based on RevType requirement
     IF @p_revtype1 <> 'UNK'
        OR @p_revtype2 <> 'UNK'
        OR @p_revtype3 <> 'UNK'
        OR @p_revtype4 <> 'UNK'
         BEGIN

             IF @p_revtype1 <> 'UNK'
                 DELETE FROM #temp_rtn1
                 WHERE NOT EXISTS
                 (
                     SELECT 1
                     FROM orderheader o
                     WHERE #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
                           AND COALESCE(o.ord_revtype1, 'UNK') = @p_revtype1
                 )

             IF @p_revtype2 <> 'UNK'
                 DELETE FROM #temp_rtn1
                 WHERE NOT EXISTS
                 (
                     SELECT 1
                     FROM orderheader o
                     WHERE #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
                           AND COALESCE(o.ord_revtype2, 'UNK') = @p_revtype2
                 )

             IF @p_revtype3 <> 'UNK'
                 DELETE FROM #temp_rtn1
                 WHERE NOT EXISTS
                 (
                     SELECT 1
                     FROM orderheader o
                     WHERE #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
                           AND COALESCE(o.ord_revtype3, 'UNK') = @p_revtype3
                 )

             IF @p_revtype4 <> 'UNK'
                 DELETE FROM #temp_rtn1
                 WHERE NOT EXISTS
                 (
                     SELECT 1
                     FROM orderheader o
                     WHERE #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
                           AND COALESCE(o.ord_revtype4, 'UNK') = @p_revtype4
                 )
         END
     -- 01/21/2008 MDH PTS 40119: Added delete to clean up orders they should not see.
     DELETE FROM #temp_rtn1
     WHERE ord_hdrnumber IS NOT NULL
           AND ord_hdrnumber <> 0
           AND NOT EXISTS
     (
         SELECT 1
         FROM orderheader
         WHERE #temp_rtn1.ord_hdrnumber = orderheader.ord_hdrnumber
               AND ((@rowsecurity <> 'Y')
                    OR EXISTS
                   (
                       SELECT 1
                       FROM @tbl_restrictedbyuser rsva
                       WHERE orderheader.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                             OR rsva.rowsec_rsrv_id = 0
                   ))
     )

     -- Restrict based on Invoice status requirement.
     IF COALESCE(@inv_status, ',UNK,') <> ',UNK,'
         DELETE FROM #temp_rtn1
         WHERE NOT EXISTS
         (
             SELECT 1
             FROM Invoiceheader i
             WHERE #temp_rtn1.ord_hdrnumber = i.ord_hdrnumber
                   AND i.ord_hdrnumber > 0
                   AND (CHARINDEX(','+COALESCE(i.ivh_invoicestatus, 'UNK')+',', @inv_status) > 0
                        OR CHARINDEX(','+COALESCE(i.ivh_mbstatus, 'NTP')+',', @inv_status) > 0)
         )

     -- Restrict based on Invoice billto
     SELECT @p_ivh_billto = COALESCE(@p_ivh_billto, 'UNKNOWN')
     IF COALESCE(@p_ivh_billto, 'UNKNOWN') <> 'UNKNOWN'
         DELETE FROM #temp_rtn1
         WHERE NOT EXISTS
         (
             SELECT 1
             FROM Invoiceheader i
             WHERE #temp_rtn1.ord_hdrnumber = i.ord_hdrnumber
                   AND i.ord_hdrnumber > 0
                   AND COALESCE(i.ivh_billto, 'UNKNOWN') = @p_ivh_billto
                   AND (i.ivh_definition = 'LH'
                        OR @stlmustinvLH = 'ALL')
         )

     -- Restrict based on Invoice revtype1
     SELECT @p_ivh_revtype1 = COALESCE(@p_ivh_revtype1, 'UNK')
     IF COALESCE(@p_ivh_revtype1, 'UNK') <> 'UNK'
         DELETE FROM #temp_rtn1
         WHERE NOT EXISTS
         (
             SELECT 1
             FROM Invoiceheader i
             WHERE #temp_rtn1.ord_hdrnumber = i.ord_hdrnumber
                   AND i.ord_hdrnumber > 0
                   AND COALESCE(i.ivh_revtype1, 'UNK') = @p_ivh_revtype1
                   AND (i.ivh_definition = 'LH'
                        OR @stlmustinvLH = 'ALL')
         )

     -- End 32781

     ----------------------------------------------------------------------------------------------------------
     -- -- PTS 41389 GAP 74 (start)
     IF EXISTS
     (
         SELECT *
         FROM @GIKEY
         WHERE gi_name = 'TrackBranch'
               AND gi_string1 = 'Y'
     )
         BEGIN
             -- IF SPECIFIC THEN PULL THAT - IF UNKNOWN THEN PULL THE ONES ALLOWED FOR THE USER.

             --IF  @brn_id  = ',UNKNOWN,'
             IF @lgh_booked_revtype1 = ',UNKNOWN,'
                 BEGIN
                     IF EXISTS
                     (
                         SELECT *
                         FROM @GIKEY
                         WHERE gi_name = 'BRANCHUSERSECURITY'
                               AND gi_string1 = 'Y'
                     )
                         BEGIN
                             -- if branch security is ON then get data, else, DO NOT DELETE.
                             INSERT INTO @temp_user_branch(brn_id)
                                    SELECT brn_id
                                    FROM branch_assignedtype
                                    WHERE bat_type = 'USERID'
                                          AND brn_id <> 'UNKNOWN'
                                          AND bat_value = @G_USERID

                             -------select * from #temp_user_branch    ----------  DEBUG ~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                             DELETE FROM #temp_rtn1
                             WHERE lgh_booked_revtyep1 NOT IN
                             (
                                 SELECT brn_id
                                 FROM @temp_user_branch
                             )
                         END
                 END
             ELSE
                 BEGIN
                     DELETE FROM #temp_rtn1
                     WHERE lgh_booked_revtyep1 IN
                     (
                         SELECT lgh_booked_revtyep1
                         FROM #temp_rtn1
                         WHERE CHARINDEX(','+lgh_booked_revtyep1+',', @lgh_booked_revtype1) = 0
                     )
                 END

         END
     -- -- PTS 41389 GAP 74 (end)
     -- original code
     ----------------------------------------------------------------------------------------------------------
     -- PTS 52192 <<start>> -- remove Carriers that are not yet approved.
     DECLARE @onetwothreefour AS INTEGER
     DECLARE @whichlghType AS VARCHAR(12)
     DECLARE @carapprovalCode AS VARCHAR(8)
     DECLARE @ls_segment_lghtype AS VARCHAR(12)

     IF EXISTS
     (
         SELECT 1
         FROM @GIKEY
         WHERE gi_name = 'STLApprvdCarrierOnly'
               AND gi_string1 = 'Y'
     )
         BEGIN
             SET @whichlghType =
             (
                 SELECT gi_string2
                 FROM @GIKEY
                 WHERE gi_name = 'STLApprvdCarrierOnly'
                       AND gi_string1 = 'Y'
             )
             SET @carapprovalCode =
             (
                 SELECT gi_string3
                 FROM @GIKEY
                 WHERE gi_name = 'STLApprvdCarrierOnly'
                       AND gi_string1 = 'Y'
             )
         END

     IF(@whichlghType IS NOT NULL
        AND @carapprovalCode IS NOT NULL)
         BEGIN

             IF @whichlghType = 'lghtype1'
                OR (CHARINDEX('1', @whichlghType) > 0)
                 BEGIN
                     DELETE #temp_rtn1
                     WHERE @carapprovalCode <> lgh_type1
                           AND asgn_type = 'CAR'
                 END
             IF @whichlghType = 'lghtype2'
                OR (CHARINDEX('2', @whichlghType) > 0)
                 BEGIN
                     DELETE #temp_rtn1
                     WHERE @carapprovalCode <> lgh_type2
                           AND asgn_type = 'CAR'
                 END
             IF @whichlghType = 'lghtype3'
                OR (CHARINDEX('3', @whichlghType) > 0)
                 BEGIN
                     DELETE #temp_rtn1
                     WHERE @carapprovalCode <> lgh_type3
                           AND asgn_type = 'CAR'
                 END
             IF @whichlghType = 'lghtype4'
                OR (CHARINDEX('4', @whichlghType) > 0)
                 BEGIN
                     DELETE #temp_rtn1
                     WHERE @carapprovalCode <> lgh_type4
                           AND asgn_type = 'CAR'
                 END
         END

     -- LOR   PTS#30053
     IF @sch_date1 > CONVERT(DATETIME, '1950-01-01 00:00')
        OR @sch_date2 < CONVERT(DATETIME, '2049-12-31 23:59')
         -- LOR   PTS# 43728  changed stp_sequence to stp_mfh_sequence
         SELECT t.lgh_number
              , t.asgn_type
              , t.asgn_id
              , t.asgn_date
              , t.asgn_enddate
              , t.cmp_id_start
              , t.cmp_id_end
              , t.mov_number
              , t.asgn_number
              , t.ord_hdrnumber
              , t.lgh_startcity
              , t.lgh_endcity
              , t.ord_number
              , t.name
              , t.cmp_name_start
              , t.cmp_name_end
              , t.cty_nmstct_start
              , t.cty_nmstct_end
              , t.need_paperwork
              , t.ivh_revtype1
              , t.revtype1_name
              , t.lgh_split_flag
              , t.trip_description
              , t.lgh_type1
              , t.lgh_type_name
              , t.ivh_billdate
              , t.ivh_invoicenumber
              , t.lgh_booked_revtyep1
              , t.asgn_controlling
              , t.lgh_shiftdate --vjh 33665
              , t.lgh_shiftnumber --vjh 33665
              , t.stp_schdtearliest -- PTS 47740
              , t.ord_route -- PTS 47740
              , t.cost -- PTS 47740
              , t.ord_revtype1 -- PTS 47740
              , t.ord_revtype1_name -- PTS 47740
              , t.ord_revtype2 -- PTS 47740
              , t.ord_revtype2_name -- PTS 47740
              , t.ord_revtype3 -- PTS 47740
              , t.ord_revtype3_name -- PTS 47740
              , t.ord_revtype4 -- PTS 47740
              , t.ord_revtype4_name -- PTS 47740
              , 'N' AS 'cc_selected' -- PTS 60458 /needed for R_to_PH feature
              , 0 AS 'cc_processed' -- PTS 60458 /needed for R_to_PH feature
              , t.asgn_payto AS asgn_payto
         FROM #temp_rtn1 t
            , stops
         WHERE t.lgh_number = stops.lgh_number
               AND stops.stp_mfh_sequence = 1
               AND stops.stp_schdtearliest BETWEEN @sch_date1 AND @sch_date2
         ORDER BY t.asgn_type
                , t.asgn_id
                , t.asgn_date
                , t.mov_number
                , t.lgh_number
     ELSE
     SELECT t.lgh_number
          , t.asgn_type
          , t.asgn_id
          , t.asgn_date
          , t.asgn_enddate
          , t.cmp_id_start
          , t.cmp_id_end
          , t.mov_number
          , t.asgn_number
          , t.ord_hdrnumber
          , t.lgh_startcity
          , t.lgh_endcity
          , t.ord_number
          , t.name
          , t.cmp_name_start
          , t.cmp_name_end
          , t.cty_nmstct_start
          , t.cty_nmstct_end
          , t.need_paperwork
          , t.ivh_revtype1
          , t.revtype1_name
          , t.lgh_split_flag
          , t.trip_description
          , t.lgh_type1
          , t.lgh_type_name
          , t.ivh_billdate
          , t.ivh_invoicenumber
          , t.lgh_booked_revtyep1
          , t.ivh_billto
          , t.asgn_controlling
          , t.lgh_shiftdate --vjh 33665
          , t.lgh_shiftnumber --vjh 33665
          , t.stp_schdtearliest -- PTS 47740
          , t.ord_route -- PTS 47740
          , t.cost -- PTS 47740
          , t.ord_revtype1 -- PTS 47740
          , t.ord_revtype1_name -- PTS 47740
          , t.ord_revtype2 -- PTS 47740
          , t.ord_revtype2_name -- PTS 47740
          , t.ord_revtype3 -- PTS 47740
          , t.ord_revtype3_name -- PTS 47740
          , t.ord_revtype4 -- PTS 47740
          , t.ord_revtype4_name -- PTS 47740
          , 'N' AS 'cc_selected' -- PTS 60458 /needed for R_to_PH feature
          , 0 AS 'cc_processed' -- PTS 60458 /needed for R_to_PH feature
          , t.asgn_payto AS asgn_payto
     FROM #temp_rtn1 t
     ORDER BY asgn_type
            , asgn_id
            , asgn_date
            , mov_number
            , lgh_number

     DROP TABLE #temp_rtn

GO
GRANT EXECUTE ON  [dbo].[TripsReadyToSettleForAgentPlanningBoard_sp] TO [public]
GO
