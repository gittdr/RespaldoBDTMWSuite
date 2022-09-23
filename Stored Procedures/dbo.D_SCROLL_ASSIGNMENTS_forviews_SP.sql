SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[D_SCROLL_ASSIGNMENTS_forviews_SP] (
   @loenddate datetime,
   @hienddate datetime,
   @lostartdate datetime,
   @histartdate datetime,
   @beg_invoice_bill_date  datetime,
   @end_invoice_bill_date  datetime,
   @resourcetypeonleg char(1),
   @view_id          varchar(6)
   )

 AS
/**
 ** PTS 63716 SGB             Add support for SplitMustInv = 'L' from PTS58060
 ** PTS 60458     9/2012      2 cols for multi-PH support
 ** PTS 66553 SPN 04/03/2013  Performance fix etc.
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @drvyes varchar(3),
 @trcyes varchar(3),
 @caryes varchar(3),
 --@loenddate datetime,
 --@hienddate datetime,    --05
 --@lostartdate datetime,
 --@histartdate datetime,
 @company varchar(255),
 @fleet varchar(255),
 @division varchar(255), --10
 @terminal varchar(255),
 @drvtyp1 varchar(255),
 @drvtyp2 varchar(255),
 @drvtyp3 varchar(255),
 @drvtyp4 varchar(255),    --15
 @trctyp1 varchar(255),
 @trctyp2 varchar(255),
 @trctyp3 varchar(255),
 @trctyp4 varchar(255),
 @driver varchar(255),  --20
 @tractor varchar(255),
 @acct_typ char(1),
 @carrier varchar(255),
 @cartyp1 varchar(255),
 @cartyp2 varchar(255),    --25
 @cartyp3 varchar(255),
 @cartyp4 varchar(255),
 @trlyes varchar(3),
 @trailer varchar(255),
 @trltyp1 varchar(255), --30
 @trltyp2 varchar(255),
 @trltyp3 varchar(255),
 @trltyp4 varchar(255),
 @lgh_type1 varchar(255),
 --@beg_invoice_bill_date datetime, --35
 --@end_invoice_bill_date datetime,
 @lgh_booked_revtype1 varchar(255),
 --@sch_date1 datetime,
 --@sch_date2 datetime,
 @tpryes varchar(3),  --40
 @tpr_id varchar(255),
 @tpr_type varchar(255),
 @p_revtype1 varchar(255),
 @p_revtype2 varchar(255),
 @p_revtype3 varchar(255), --45
 @p_revtype4 varchar(255),
 @inv_status varchar(255),
 @p_tpr_type varchar(255),
 --   @tprtype1 char(1),
 --@tprtype2 char(1),
 --@tprtype3 char(1),  --50
 --@tprtype4 char(1),
 --@tprtype5 char(1),
 --@tprtype6 char(1),
 @p_ivh_revtype1 varchar(255),
 @p_ivh_billto varchar(255), --55
 --@G_USERID varchar(14),   -- PTS 41389 GAP 74
 @shiftdate datetime ,  --vjh 33665
 @shiftnumber varchar(6) ,  --vjh 33665
 --@resourcetypeonleg char(1),   -- DJM PTS 48237
 @payto  varchar(255),
 @paperwork_received int

--BEGIN PTS 63020 SPN - Unused restrictions
DECLARE @bov_ivh_rev_type1    VARCHAR(255)
--END PTS 63020 SPN

--BEGIN PTS 65645 SPN
DECLARE @mpp_branch    VARCHAR(255)
DECLARE @trc_branch    VARCHAR(255)
DECLARE @trl_branch    VARCHAR(255)
DECLARE @car_branch    VARCHAR(255)
--END PTS 65645 SPN

select @shiftdate = '1/1/1950'
select @shiftnumber = 'UNK'

--BEGIN PTS 63020 SPN
--select @p_ivh_billto = case isNull(rtrim(bov_billto), '')
--                        when '' then '%'
--                        when 'UNKNOWN' then '%'
--                        else (',' + bov_billto + ',')
--                     end,
--   @lgh_booked_revtype1 = case isNull(rtrim(bov_booked_revtype1), '')
--                        when '' then '%'
--                        when 'UNKNOWN' then '%'
--                        else (',' + bov_booked_revtype1 + ',')
--                     end,
--   @p_revtype1 = case isNull(rtrim(bov_rev_type1), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_rev_type1 + ',')
--                     end,
--   @p_revtype2 = case isNull(rtrim(bov_rev_type2), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_rev_type2 + ',')
--                     end,
--   @p_revtype3 = case isNull(rtrim(bov_rev_type3), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_rev_type3 + ',')
--                     end,
--   @p_revtype4 = case isNull(rtrim(bov_rev_type4), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_rev_type4 + ',')
--                     end,
--   @lgh_type1 = case isNull(rtrim(bov_lgh_type1), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_lgh_type1 + ',')
--                     end,
--   @paperwork_received = case isNull(rtrim(bov_paperwork_received), 'N/A')
--                        when 'Y' then 1
--                        when 'N' then -1
--                        else 0
--                     end,     -- Y/N/"N/A"
--   @company = case isNull(rtrim(bov_company), '')
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
--   @drvtyp1 = case isNull(rtrim(bov_mpp_type1), '')
--                        when '' then '%'
--                        else (',' + bov_mpp_type1 + ',')
--                     end ,
--   @drvtyp2 = case isNull(rtrim(bov_mpp_type2), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_mpp_type2 + ',')
--                     end ,
--   @drvtyp3 = case isNull(rtrim(bov_mpp_type3), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_mpp_type3 + ',')
--                     end ,
--   @drvtyp4 = case isNull(rtrim(bov_mpp_type4), '')
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
--   @trctyp1 = case isNull(rtrim(bov_trc_type1), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trc_type1 + ',')
--                     end ,
--   @trctyp2 = case isNull(rtrim(bov_trc_type2), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trc_type2 + ',')
--                     end ,
--   @trctyp3 = case isNull(rtrim(bov_trc_type3), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trc_type3 + ',')
--                     end ,
--   @trctyp4 = case isNull(rtrim(bov_trc_type4), '')
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
--   @trltyp1 = case isNull(rtrim(bov_trl_type1), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trl_type1 + ',')
--                     end ,
--   @trltyp2 = case isNull(rtrim(bov_trl_type2), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trl_type2 + ',')
--                     end ,
--   @trltyp3 = case isNull(rtrim(bov_trl_type3), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_trl_type3 + ',')
--                     end ,
--   @trltyp4 = case isNull(rtrim(bov_trl_type4), '')
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
--   @cartyp1 = case isNull(rtrim(bov_car_type1), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_car_type1 + ',')
--                     end ,
--   @cartyp2 = case isNull(rtrim(bov_car_type2), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_car_type2 + ',')
--                     end ,
--   @cartyp3 = case isNull(rtrim(bov_car_type3), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_car_type3 + ',')
--                     end ,
--   @cartyp4 = case isNull(rtrim(bov_car_type4), '')
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
--   @inv_status = case isNull(rtrim(bov_car_type4), '')
--                        when '' then '%'
--                        when 'UNK' then '%'
--                        else (',' + bov_car_type4 + ',')
--                     end,
--   @tpr_type = case isNull(rtrim(bov_tpr_type), '')
--                        when '' then '%'
--                        when 'UNKNOWN' then '%'
--                        else (',' + bov_tpr_type + ',')
--                     end
--   from backofficeview
--   where bov_id = @view_id and bov_type = 'TRS'

   --PTS 65645 SPN - added @mpp_branch, @trc_branch, @trl_branch and @car_branch
   EXEC dbo.backofficeview_get_sp
                         @bov_type               = 'TRS'
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
                       , @bov_mpp_type1          = @drvtyp1             OUTPUT
                       , @bov_mpp_type2          = @drvtyp2             OUTPUT
                       , @bov_mpp_type3          = @drvtyp3             OUTPUT
                       , @bov_mpp_type4          = @drvtyp4             OUTPUT
                       , @bov_mpp_branch         = @mpp_branch          OUTPUT
                       , @bov_tractor_incl       = @trcyes              OUTPUT
                       , @bov_tractor_id         = @tractor             OUTPUT
                       , @bov_trc_type1          = @trctyp1             OUTPUT
                       , @bov_trc_type2          = @trctyp2             OUTPUT
                       , @bov_trc_type3          = @trctyp3             OUTPUT
                       , @bov_trc_type4          = @trctyp4             OUTPUT
                       , @bov_trc_branch         = @trc_branch          OUTPUT
                       , @bov_trailer_incl       = @trlyes              OUTPUT
                       , @bov_trailer_id         = @trailer             OUTPUT
                       , @bov_trl_type1          = @trltyp1             OUTPUT
                       , @bov_trl_type2          = @trltyp2             OUTPUT
                       , @bov_trl_type3          = @trltyp3             OUTPUT
                       , @bov_trl_type4          = @trltyp4             OUTPUT
                       , @bov_trl_branch         = @trl_branch          OUTPUT
                       , @bov_carrier_incl       = @caryes              OUTPUT
                       , @bov_carrier_id         = @carrier             OUTPUT
                       , @bov_car_type1          = @cartyp1             OUTPUT
                       , @bov_car_type2          = @cartyp2             OUTPUT
                       , @bov_car_type3          = @cartyp3             OUTPUT
                       , @bov_car_type4          = @cartyp4             OUTPUT
                       , @bov_car_branch         = @car_branch          OUTPUT
                       , @bov_tpr_incl           = @tpryes              OUTPUT
                       , @bov_tpr_id             = @tpr_id              OUTPUT
                       , @bov_tpr_type           = @tpr_type            OUTPUT
                       , @bov_inv_status         = @inv_status          OUTPUT
                       , @bov_ivh_rev_type1      = @bov_ivh_rev_type1   OUTPUT
--END PTS 63020 SPN

select @payto = '%' , @inv_status = '%', @p_ivh_revtype1 = '%'

Declare @first_invoice int,
 @stlmustinv  char(1),
 @stlmustord  char(1),
 @stlmustinvLH char(60),
 @splitmustinv char(1),
 @split_flag  char(1),
 @li_count  int,
 @li_mov   int,
 @ls_tripdesc    varchar(255),
 @ls_ordnumber   varchar(25),
 @ls_invstat1    varchar(60),
 @ls_invstat2    varchar(60),
 @ls_invstat3    varchar(60),
 @ls_invstat4    varchar(60),
 @paperworkchecklevel varchar(6),
 @paperworkmode varchar(3),
 @revtype4  varchar(6),
 @excludemppterminal varchar(60),
 @excludempptype1formttrips varchar(60),
 @STLUseLegAcctType char(1),
 @agent   varchar(3),
 @ComputeRevenueByTripSegment  char(1),
 @paperwork_computed_cutoff_datetime datetime,
 @paperwork_GI_cutoff_datetime  datetime,
 @paperwork_GI_cutoff_flag   char(1),
 @paperwork_GI_cutoff_dayofweek  int,
 @ls_STL_TRS_Include_Shift   char(1),
   @min_shift_id  int,
   @TPRIgnoreStlMustInv char(1)

--BEGIN PTS 66553 SPN
----BEGIN 46308 SPN
--DECLARE  @upd_cursor_consord_mov_number int,
--         @upd_cursor_consord_ord_hdrnumber int,
--         @new_ivh_invoicenumber varchar(12),
--         @new_ivh_billdate datetime
----END 46308 SPN
--END PTS 66553 SPN

--BEGIN PTS 66553 SPN
----BEGIN PTS 57093 SPN
--DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--DECLARE @rowsecurity char(1)
----END PTS 57093 SPN
--END PTS 66553 SPN

--BEGIN PTS 57093 SPN
DECLARE @tmp TABLE
( mpp_id          VARCHAR(8) NULL
, mpp_lastfirst   VARCHAR(45) NULL
, mpp_type1       VARCHAR(6) NULL
, mpp_type2       VARCHAR(6) NULL
, mpp_type3       VARCHAR(6) NULL
, mpp_type4       VARCHAR(6) NULL
, asgn_branch     VARCHAR(12) NULL  --PTS 65645 SPN
)

DECLARE @tmp1 TABLE
( trc_number      VARCHAR(8) NULL
, trc_owner       VARCHAR(12) NULL
, trc_type1       VARCHAR(6) NULL
, trc_type2       VARCHAR(6) NULL
, trc_type3       VARCHAR(6) NULL
, trc_type4       VARCHAR(6) NULL
, asgn_branch     VARCHAR(12) NULL  --PTS 65645 SPN
)

DECLARE @tmp2 TABLE
( car_id          VARCHAR(8) NULL
, car_name        VARCHAR(64) NULL
, asgn_branch     VARCHAR(12) NULL  --PTS 65645 SPN
)

DECLARE @tmp3 TABLE
( trl_id          VARCHAR(13) NULL
, trl_owner       VARCHAR(12) NULL
, asgn_branch     VARCHAR(12) NULL  --PTS 65645 SPN
)

DECLARE @tmp4 TABLE
( tpr_id          VARCHAR(8) NULL
, tpr_name        VARCHAR(30) NULL
)
--END PTS 57093 SPN

/* Create a temporary table for data return set */
DECLARE  @temp_rtn TABLE
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
, cmp_name_start        VARCHAR(100)   NULL           -- gap 74 - increase size to match table.
, cmp_name_end          VARCHAR(100)   NULL           -- gap 74 - increase size to match table.
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
, lgh_shiftdate         DATETIME       NULL           --vjh 33665
, lgh_shiftnumber       VARCHAR(6)     NULL           --vjh 33665
, shift_ss_id           INT            NULL           --vjh 45381
, stp_schdtearliest     DATETIME       NULL           -- PTS 47740
, ord_route             VARCHAR(18)    NULL           -- PTS 47740
, Cost                  MONEY          NULL           -- PTS 47740
, ord_revtype1          VARCHAR(6)     NULL           -- PTS 47740
, ord_revtype1_name     VARCHAR(20)    NULL           -- PTS 47740
, ord_revtype2          VARCHAR(6)     NULL           -- PTS 47740
, ord_revtype2_name     VARCHAR(20)    NULL           -- PTS 47740
, ord_revtype3          VARCHAR(6)     NULL           -- PTS 47740
, ord_revtype3_name     VARCHAR(20)    NULL           -- PTS 47740
, ord_revtype4          VARCHAR(6)     NULL           -- PTS 47740
, ord_revtype4_name     VARCHAR(20)    NULL           -- PTS 47740
, lgh_type2             VARCHAR(6)     NULL           -- PTS 52192
, lgh_type3             VARCHAR(6)     NULL           -- PTS 52192
, lgh_type4             VARCHAR(6)     NULL           -- PTS 52192
)

--BEGIN PTS 66553 SPN
---- KMM for DMOOK, PTS 19944
--Create Index temp_rtn_ord_hdrnumber on  #temp_rtn( ord_hdrnumber)
---- END PTS 19944
---- KMM for DMOOK, PTS 19944
---- JD need a mov_number index and and ord_number index for the loops
---- 36763 start JD
--create index #dk_temp_idx_mov on #temp_rtn (mov_number)
--create index #dk_temp_idx_ord on #temp_rtn (ord_number)
--create index #dk_temp_idx_lgh on #temp_rtn (lgh_number)  --pmill 49424 additional index for performance improvements
--
---- 36763 end JD
--END PTS 66553 SPN

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
, cmp_name_start        VARCHAR(100)   NULL           -- gap 74 - increase size to match table.
, cmp_name_end          VARCHAR(100)   NULL           -- gap 74 - increase size to match table.
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
, lgh_shiftdate         DATETIME       NULL           -- vjh 33665
, lgh_shiftnumber       VARCHAR(6)     NULL           -- vjh 33665
, shift_ss_id           INT            NULL           -- vjh 45381
, stp_schdtearliest     DATETIME       NULL           -- PTS 47740
, ord_route             VARCHAR(18)    NULL           -- PTS 47740
, Cost                  MONEY          NULL           -- PTS 47740
, ord_revtype1          VARCHAR(6)     NULL           -- PTS 47740
, ord_revtype1_name     VARCHAR(20)    NULL           -- PTS 47740
, ord_revtype2          VARCHAR(6)     NULL           -- PTS 47740
, ord_revtype2_name     VARCHAR(20)    NULL           -- PTS 47740
, ord_revtype3          VARCHAR(6)     NULL           -- PTS 47740
, ord_revtype3_name     VARCHAR(20)    NULL           -- PTS 47740
, ord_revtype4          VARCHAR(6)     NULL           -- PTS 47740
, ord_revtype4_name     VARCHAR(20)    NULL           -- PTS 47740
, lgh_type2             VARCHAR(6)     NULL           -- PTS 52192
, lgh_type3             VARCHAR(6)     NULL           -- PTS 52192
, lgh_type4             VARCHAR(6)     NULL           -- PTS 52192
)

/* PTS 17873 - DJM - No change, just moved to beginning of Proc
 to try and limit recompiles while I'm in this proc anyway  */
create table #temp_pwk
( lgh_number            INT         NULL
, ord_hdrnumber         INT         NULL
, req_cnt               INT         NULL
, rec_cnt               INT         NULL
, ord_billto            VARCHAR(8)  NULL
)

--vjh PTS 45562
CREATE TABLE #temp_Orders
( lgh_number            INT      NULL
, ord_hdrnumber         INT      NULL
, Inv_OK_Flag           CHAR(1)  NULL
, Ord_OK_Flag           CHAR(1)  NULL
, split_flag            CHAR(1)  NULL                  -- PTS 63716 SGB Add support for SplitMustInv = 'L' from PTS58060
)


--BEGIN PTS 66553 SPN
----BEGIN PTS 57093 SPN
--SELECT @rowsecurity = gi_string1
--  FROM generalinfo
-- WHERE gi_name = 'RowSecurity'

--IF @rowsecurity = 'Y'
--   INSERT INTO @tbl_restrictedbyuser
--   SELECT rowsec_rsrv_id
--     FROM RowRestrictValidAssignments_orderheader_fn()
--ELSE
--   INSERT @tbl_restrictedbyuser (rowsec_rsrv_id)
--   SELECT 0
----END PTS 57093 SPN
--END PTS 66553 SPN

--BEGIN PTS 54163 SPN
--BEGIN PTS 57093 SPN
--BEGIN PTS 66553 SPN
IF @drvyes <> 'XXX'
BEGIN
--END PTS 66553 SPN
   INSERT INTO @tmp
   SELECT DISTINCT mpp_id, mpp_lastfirst, mpp_type1, mpp_type2, mpp_type3, mpp_type4
                 , mpp_branch    --PTS 65645 SPN
   --  INTO #tmp
   --END PTS 57093 SPN
     FROM manpowerprofile
   --BEGIN PTS 66553 SPN
     JOIN RowRestrictValidAssignments_manpowerprofile_fn() rsva ON manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                                OR rsva.rowsec_rsrv_id = 0
   --END PTS 66553 SPN
    --WHERE (@driver = mpp_id OR @driver = 'UNKNOWN')
    --AND ( (@acct_typ = 'X' AND mpp_actg_type IN('A', 'P')) OR (@acct_typ = mpp_actg_type) )
    --AND (@company = 'UNK' or @company = mpp_company)
    --AND (@fleet = 'UNK' or @fleet = mpp_fleet)
    --AND (@division = 'UNK' or @division = mpp_division)
    --AND (@terminal = 'UNK' or @terminal = mpp_terminal)
     WHERE (@driver = mpp_id OR @driver = 'UNKNOWN' or @driver = '%' or CHARINDEX( ',' + mpp_id + ',',@driver) > 0)
    AND ( (@acct_typ = 'X' AND mpp_actg_type IN('A', 'P')) OR (@acct_typ = mpp_actg_type) )
    AND (@company = 'UNK' or @company = mpp_company or @company = '%' or CHARINDEX( ',' + mpp_company + ',',@company) > 0)
    AND (@fleet = 'UNK' or @fleet = mpp_fleet or @fleet = '%' or CHARINDEX( ',' + mpp_fleet + ',',@fleet) > 0)
    AND (@division = 'UNK' or @division = mpp_division or @division = '%' or CHARINDEX( ',' + mpp_division + ',',@division) > 0)
    AND (@terminal = 'UNK' or @terminal = mpp_terminal or @terminal = '%' or CHARINDEX( ',' + mpp_terminal + ',',@terminal) > 0)

   --select 'Point 1 @tmp - ' + convert(varchar(20),count(*)) from @tmp
--BEGIN PTS 66553 SPN
END
--END PTS 66553 SPN

--BEGIN PTS 57093 SPN
--BEGIN PTS 66553 SPN
IF @trcyes <> 'XXX'
BEGIN
--END PTS 66553 SPN
   INSERT INTO @tmp1
   SELECT DISTINCT trc_number, trc_owner, trc_type1, trc_type2, trc_type3, trc_type4
                 , trc_branch    --PTS 65645 SPN
   --  INTO #tmp1
   --END PTS 57093 SPN
     FROM tractorprofile
   --BEGIN PTS 66553 SPN
     JOIN RowRestrictValidAssignments_tractorprofile_fn() rsva ON tractorprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                               OR rsva.rowsec_rsrv_id = 0
   --END PTS 66553 SPN
    --WHERE (@tractor = trc_number OR (@tractor = 'UNKNOWN' and @payto = 'UNKNOWN')
    --  OR (@payto <> 'UNKNOWN' and trc_number in (select trc_number from tractorprofile where trc_owner = @payto or trc_owner2 = @payto)))
    --AND ( (@acct_typ = 'X' AND trc_actg_type IN('A', 'P')) OR (@acct_typ = trc_actg_type) )
    --AND (@company = 'UNK' OR @company = trc_company)
    --AND (@fleet = 'UNK' OR @fleet = trc_fleet)
    --AND (@division = 'UNK' OR @division = trc_division)
    --AND (@terminal = 'UNK' OR @terminal = trc_terminal)
     WHERE (@tractor = trc_number OR @tractor = 'UNKNOWN' or @tractor = '%' or CHARINDEX( ',' + trc_number + ',',@tractor) > 0)
    AND ( (@acct_typ = 'X' AND trc_actg_type IN('A', 'P')) OR (@acct_typ = trc_actg_type) )
    AND (@company = 'UNK' or @company = trc_company or @company = '%' or CHARINDEX( ',' + trc_company + ',',@company) > 0)
    AND (@fleet = 'UNK' or @fleet = trc_fleet or @fleet = '%' or CHARINDEX( ',' + trc_fleet + ',',@fleet) > 0)
    AND (@division = 'UNK' or @division = trc_division or @division = '%' or CHARINDEX( ',' + trc_division + ',',@division) > 0)
    AND (@terminal = 'UNK' or @terminal = trc_terminal or @terminal = '%' or CHARINDEX( ',' + trc_terminal + ',',@terminal) > 0)

     --select 'Point 2 @tmp1 - ' + convert(varchar(20),count(*)) from @tmp1
--BEGIN PTS 66553 SPN
END
--END PTS 66553 SPN

--BEGIN PTS 57093 SPN
--BEGIN PTS 66553 SPN
IF @caryes <> 'XXX'
BEGIN
--END PTS 66553 SPN
   INSERT INTO @tmp2
   SELECT DISTINCT car_id, car_name
                 , car_branch    --PTS 65645 SPN
   --  INTO #tmp2
   --END PTS 57093 SPN
     FROM carrier
   --BEGIN PTS 66553 SPN
     JOIN RowRestrictValidAssignments_carrier_fn() rsva ON carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                        OR rsva.rowsec_rsrv_id = 0
   --END PTS 66553 SPN
    --WHERE (@carrier = car_id OR @carrier = 'UNKNOWN')
    --AND ( (@acct_typ = 'X' AND car_actg_type IN('A', 'P')) OR (@acct_typ = car_actg_type) )
    --AND (@cartyp1 = 'UNK' or @cartyp1 = car_type1)
    --AND (@cartyp2 = 'UNK' or @cartyp2 = car_type2)
    --AND (@cartyp3 = 'UNK' or @cartyp3 = car_type3)
    --AND (@cartyp4 = 'UNK' or @cartyp4 = car_type4)
     WHERE (@carrier = car_id OR @carrier = 'UNKNOWN' or @carrier = '%' or CHARINDEX( ',' + car_id + ',',@carrier) > 0)
    AND ( (@acct_typ = 'X' AND car_actg_type IN('A', 'P')) OR (@acct_typ = car_actg_type) )
    AND (@cartyp1 = 'UNK' or @cartyp1 = car_type1 or @cartyp1 = '%' or CHARINDEX( ',' + car_type1 + ',',@cartyp1) > 0)
    AND (@cartyp2 = 'UNK' or @cartyp2 = car_type2 or @cartyp2 = '%' or CHARINDEX( ',' + car_type2 + ',',@cartyp2) > 0)
    AND (@cartyp3 = 'UNK' or @cartyp3 = car_type3 or @cartyp3 = '%' or CHARINDEX( ',' + car_type3 + ',',@cartyp3) > 0)
    AND (@cartyp4 = 'UNK' or @cartyp4 = car_type4 or @cartyp4 = '%' or CHARINDEX( ',' + car_type4 + ',',@cartyp4) > 0)

     --select 'Point 2 @tmp2 - ' + convert(varchar(20),count(*)) from @tmp2
--BEGIN PTS 66553 SPN
END
--END PTS 66553 SPN

--BEGIN PTS 57093 SPN
--BEGIN PTS 66553 SPN
IF @trlyes <> 'XXX'
BEGIN
--END PTS 66553 SPN
   INSERT INTO @tmp3
   SELECT DISTINCT trl_id, trl_owner
                 , trl_branch    --PTS 65645 SPN
   --  INTO #tmp3
   --END PTS 57093 SPN
     FROM trailerprofile
   --BEGIN PTS 66553 SPN
     JOIN RowRestrictValidAssignments_trailerprofile_fn() rsva ON trailerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id
                                                               OR rsva.rowsec_rsrv_id = 0
   --END PTS 66553 SPN
    --WHERE (@trailer = trl_id OR @trailer = 'UNKNOWN')
    --AND ( (@acct_typ = 'X' AND trl_actg_type IN('A', 'P')) OR (@acct_typ = trl_actg_type) )
    --AND (@company = 'UNK' OR @company = trl_company)
    --AND (@fleet = 'UNK' OR @fleet = trl_fleet)
    --AND (@division = 'UNK' OR @division = trl_division)
    --AND (@terminal = 'UNK' OR @terminal = trl_terminal)
    --AND (@trltyp1 = 'UNK' OR @trltyp1 = trl_type1)
    --AND (@trltyp2 = 'UNK' OR @trltyp2 = trl_type2)
    --AND (@trltyp3 = 'UNK' OR @trltyp3 = trl_type3)
    --AND (@trltyp4 = 'UNK' OR @trltyp4 = trl_type4)
     WHERE (@trailer = trl_id OR @trailer = 'UNKNOWN' or @trailer = '%' or CHARINDEX( ',' + trl_id + ',',@trailer) > 0)
    AND ( (@acct_typ = 'X' AND trl_actg_type IN('A', 'P')) OR (@acct_typ = trl_actg_type) )
    AND (@company = 'UNK' or @company = trl_company or @company = '%' or CHARINDEX( ',' + trl_company + ',',@company) > 0)
    AND (@fleet = 'UNK' or @fleet = trl_fleet or @fleet = '%' or CHARINDEX( ',' + trl_fleet + ',',@fleet) > 0)
    AND (@division = 'UNK' or @division = trl_division or @division = '%' or CHARINDEX( ',' + trl_division + ',',@division) > 0)
    AND (@terminal = 'UNK' or @terminal = trl_terminal or @terminal = '%' or CHARINDEX( ',' + trl_terminal + ',',@terminal) > 0)
    AND (@trltyp1 = 'UNK' or @trltyp1 = trl_type1 or @trltyp1 = '%' or CHARINDEX( ',' + trl_type1 + ',',@trltyp1) > 0)
    AND (@trltyp2 = 'UNK' or @trltyp2 = trl_type2 or @trltyp2 = '%' or CHARINDEX( ',' + trl_type2 + ',',@trltyp2) > 0)
    AND (@trltyp3 = 'UNK' or @trltyp3 = trl_type3 or @trltyp3 = '%' or CHARINDEX( ',' + trl_type3 + ',',@trltyp3) > 0)
    AND (@trltyp4 = 'UNK' or @trltyp4 = trl_type4 or @trltyp4 = '%' or CHARINDEX( ',' + trl_type4 + ',',@trltyp4) > 0)

      --select 'Point 3 @tmp3 - ' + convert(varchar(20),count(*)) from @tmp3
   --END PTS 54163 SPN
--BEGIN PTS 66553 SPN
END
--END PTS 66553 SPN

--vjh 45500 get pieces used for paperwork cutoff
select @paperwork_GI_cutoff_flag = upper(left(gi_string1,1)),
  @paperwork_GI_cutoff_dayofweek = gi_integer1,
  @paperwork_GI_cutoff_datetime = gi_date1
from generalinfo where gi_name = 'PaperWorkCutOffDate'
if @paperwork_GI_cutoff_flag is null select @paperwork_GI_cutoff_flag = 'N'
if @paperwork_GI_cutoff_flag = 'N' begin
 select @paperwork_computed_cutoff_datetime = '2049-12-31 23:59'
end else begin
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
select  @ls_invstat1 = gi_string1,
 @ls_invstat2 = gi_string2,
 @ls_invstat3 = gi_string3,
 @ls_invstat4 = gi_string4
from  generalinfo
where  gi_name = 'StlXInvStat'
select @ls_invstat1 = IsNull(@ls_invstat1,'')
select @ls_invstat2 = IsNull(@ls_invstat2,@ls_invstat1)
select @ls_invstat3 = IsNull(@ls_invstat3,@ls_invstat1)
select @ls_invstat4 = IsNull(@ls_invstat4,@ls_invstat1)

select @splitmustinv = substring(upper(gi_string1),1,1) from generalinfo where gi_name = 'SPLITMUSTINV'
select @stlmustinv =  substring(upper(gi_string1),1,1),
 @stlmustinvLH =  upper(gi_string2)
from generalinfo
where gi_name = 'STLMUSTINV'
select @stlmustord =  substring(upper(gi_string1),1,1) from generalinfo where gi_name = 'STLMUSTORD' --vjh 52942

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
---- PTS 41389 GAP 74 Start
--IF @lgh_booked_revtype1 is NULL or @lgh_booked_revtype1 = '' or @lgh_booked_revtype1 = 'UNK'
-- begin
--  SELECT @lgh_booked_revtype1 = 'UNKNOWN'
-- end
--SELECT @lgh_booked_revtype1= ',' + LTRIM(RTRIM(ISNULL(@lgh_booked_revtype1, '')))  + ','
---- PTS 41389 GAP 74 end
---------------------------------------------------------------------------------------------------------------

If exists (select * from generalinfo where gi_name = 'TRSExcludeNonPayableTrips' and gi_string1 = 'Y')
 update assetassignment set pyd_status = 'PPD'
  where asgn_status = 'CMP' and pyd_status = 'NPD'
  and not exists (select * from stops where stops.lgh_number = assetassignment.lgh_number  and IsNull(stops.stp_paylegpt,'N') = 'Y')

-- vjh 30395 move here so that all resource types can use it
select @STLUseLegAcctType = 'N'
If exists (select * from generalinfo where gi_name = 'STLUseLegAcctType' and IsNull(gi_string1,'') <> '')
begin
 select @STLUseLegAcctType = upper(left(gi_string1,1)) from generalinfo where gi_name = 'STLUseLegAcctType'
end

-- PTS 3223781 - DJM
--SELECT @inv_status = ',' + LTRIM(RTRIM(ISNULL(@inv_status, 'UNK'))) + ','

/* Insert any drivers */
--BEGIN PTS 53466 SPN
--IF @drvyes != 'XXX'
IF @drvyes <> 'XXX'
--END PTS 53466 SPN
BEGIN
 If @driver = 'UNKNOWN'
 BEGIN
  -- JD 28117 Exclude drivers that belong to the terminal specified by the gi setting TRSExcludeDrvTerminal
  If exists (select * from generalinfo where gi_name = 'TRSExcludeDrvTerminal' and IsNull(gi_string1,'') <> '')
  begin
   select @excludemppterminal = gi_string1 from generalinfo where gi_name = 'TRSExcludeDrvTerminal'
   select @excludemppterminal = ',' +@excludemppterminal + ','
   update assetassignment
    set pyd_status = 'PPD'
    from manpowerprofile mpp
    where  asgn_type = 'DRV'
     and mpp.mpp_id = asgn_id
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
   update assetassignment
    set pyd_status = 'PPD'
    from manpowerprofile mpp
    where asgn_type = 'DRV'
     and mpp.mpp_id = asgn_id
     and charindex (mpp.mpp_type1,@excludempptype1formttrips) > 0
     AND asgn_status = 'CMP'
     AND pyd_status = 'NPD'
     AND asgn_date BETWEEN @lostartdate AND @histartdate
     AND asgn_enddate BETWEEN @loenddate AND @hienddate
     and not exists (select * from stops where stops.lgh_number = assetassignment.lgh_number and stops.stp_loadstatus = 'LD')
  end

  --  Exclude drivers that belong to the mpp_type1 specified by string1 and that have all intracity stops on the trip segment
  select @excludempptype1formttrips = null
  If exists (select * from generalinfo where gi_name = 'TRSExcludeDrvType1WithICTrips' and IsNull(gi_string1,'') <> '')
  begin
   select @excludempptype1formttrips= gi_string1 from generalinfo where gi_name = 'TRSExcludeDrvType1WithICTrips'
   select @excludempptype1formttrips= ',' +@excludempptype1formttrips + ','

   update  assetassignment
    set  pyd_status = 'PPD'
    from  manpowerprofile mpp
    where  asgn_type = 'DRV'
     and mpp.mpp_id = asgn_id
     and charindex (mpp.mpp_type1,@excludempptype1formttrips) > 0
     AND asgn_status = 'CMP'
     AND pyd_status = 'NPD'
     AND asgn_date BETWEEN @lostartdate AND @histartdate
     AND asgn_enddate BETWEEN @loenddate AND @hienddate
     AND lgh_number in
     (  select  c.lgh_number from stops c
        where  c.lgh_number = assetassignment.lgh_number
          and exists (select *
           from stops d, stops e
           where d.lgh_number = c.lgh_number and
           d.lgh_number = e.lgh_number and
           d.stp_mfh_sequence = 1 and e.stp_mfh_sequence = 2 and
           e.stp_loadstatus = 'MT'  and
           d.stp_city = e.stp_city )
      group by c.lgh_number
      having count(*) = 2)

  end
 end

 IF @STLUseLegAcctType = 'Y' BEGIN
  IF @ls_STL_TRS_Include_Shift = 'N'
  BEGIN
   INSERT INTO @temp_rtn
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
    INNER JOIN legheader l
     ON a.lgh_number = l.lgh_number
     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
     AND a.asgn_type = 'DRV',
    --BEGIN PTS 54163 SPN
    @tmp #tmp
   WHERE a.asgn_type = 'DRV'
    AND a.asgn_id = mpp_id
    AND a.asgn_status = 'CMP'
    AND pyd_status = 'NPD'
    AND a.asgn_date BETWEEN @lostartdate AND @histartdate
    AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
    AND ( (@acct_typ = 'X' AND a.actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
    --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
    --AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type1
    --  else #tmp.mpp_type1
    --  end))
    --AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type2
    --  else #tmp.mpp_type2
    --  end))
    --AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type3
    --  else #tmp.mpp_type3
    --  end))
    --AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type4
    --  else #tmp.mpp_type4
    --  end))
    AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type1
              else #tmp.mpp_type1
             end) or
        @drvtyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type1
                  else #tmp.mpp_type1 end) + ',',@drvtyp1) > 0)
    AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type2
              else #tmp.mpp_type2
             end) or
        @drvtyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type2
                  else #tmp.mpp_type2 end) + ',',@drvtyp2) > 0)
    AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type3
              else #tmp.mpp_type3
             end) or
        @drvtyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type3
                  else #tmp.mpp_type3 end) + ',',@drvtyp3) > 0)
    AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type4
              else #tmp.mpp_type4
             end) or
        @drvtyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type4
                  else #tmp.mpp_type4 end) + ',',@drvtyp4) > 0)
            --BEGIN PTS 65645 SPN
            AND ( @mpp_branch = '%'
               OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END) + ',', @mpp_branch) > 0
                )
            --END PTS 65645 SPN

                  --select 'Point 4 @temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn
  END
 ELSE
  BEGIN
   --vjh 45381 new insert for join to shiftschedules table and restrictions based on that.
   INSERT INTO @temp_rtn
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
    INNER JOIN legheader l
     ON a.lgh_number = l.lgh_number
     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
     AND a.asgn_type = 'DRV'
    LEFT JOIN shiftschedules s
     ON l.shift_sS_id = s.ss_id,
    --BEGIN PTS 54163 SPN
    @tmp #tmp
   WHERE a.asgn_type = 'DRV'
    AND a.asgn_id = #tmp.mpp_id
    AND a.asgn_status = 'CMP'
    AND pyd_status = 'NPD'
    AND a.asgn_date BETWEEN @lostartdate AND @histartdate
    --AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
    AND s.ss_starttime BETWEEN @loenddate AND @hienddate
    AND ( (@acct_typ = 'X' AND a.actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
    --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
    --AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type1
    --  else #tmp.mpp_type1
    --  end))
    --AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type2
    --  else #tmp.mpp_type2
    --  end))
    --AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type3
    --  else #tmp.mpp_type3
    --  end))
    --AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type4
    --  else #tmp.mpp_type4
    --  end))
    AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type1
              else #tmp.mpp_type1
             end) or
        @drvtyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type1
                  else #tmp.mpp_type1 end) + ',',@drvtyp1) > 0)
    AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type2
              else #tmp.mpp_type2
             end) or
        @drvtyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type2
                  else #tmp.mpp_type2 end) + ',',@drvtyp2) > 0)
    AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type3
              else #tmp.mpp_type3
             end) or
        @drvtyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type3
                  else #tmp.mpp_type3 end) + ',',@drvtyp3) > 0)
    AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type4
              else #tmp.mpp_type4
             end) or
        @drvtyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type4
                  else #tmp.mpp_type4 end) + ',',@drvtyp4) > 0)
            --BEGIN PTS 65645 SPN
            AND ( @mpp_branch = '%'
               OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END) + ',', @mpp_branch) > 0
                )
            --END PTS 65645 SPN

  --select 'Point 5 @temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn

   --vjh 45381 walk through each shift and grab any trips that fell outside of the date range but have same shift
   SELECT @min_shift_id = min(shift_ss_id) FROM @temp_rtn WHERE shift_ss_id is not null and shift_ss_id > 0 and asgn_type = 'DRV'
   WHILE @min_shift_id is not null BEGIN
    INSERT INTO @temp_rtn
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
      INNER JOIN legheader l
       ON a.lgh_number = l.lgh_number
       AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
       AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
       AND a.asgn_type = 'DRV',
     --BEGIN PTS 54163 SPN
      @tmp #tmp
     WHERE a.asgn_type = 'DRV'
      AND a.asgn_id = mpp_id
      AND a.asgn_status = 'CMP'
      AND pyd_status = 'NPD'
      AND a.asgn_date BETWEEN @lostartdate AND @histartdate
      --AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
      AND shift_ss_id = @min_shift_id
      AND l.lgh_number not in (SELECT lgh_number FROM @temp_rtn WHERE shift_ss_id = @min_shift_id)
      AND ( (@acct_typ = 'X' AND a.actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
      --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
      --AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
      --  then l.mpp_type1
      --  else #tmp.mpp_type1
      --  end))
      --AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
      --  then l.mpp_type2
      --  else #tmp.mpp_type2
      --  end))
      --AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
      --  then l.mpp_type3
      --  else #tmp.mpp_type3
      --  end))
      --AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
      --  then l.mpp_type4
      --  else #tmp.mpp_type4
      --  end))
      AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type1
              else #tmp.mpp_type1
             end) or
        @drvtyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type1
                  else #tmp.mpp_type1 end) + ',',@drvtyp1) > 0)
      AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
                then l.mpp_type2
                else #tmp.mpp_type2
               end) or
          @drvtyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                    then l.mpp_type2
                    else #tmp.mpp_type2 end) + ',',@drvtyp2) > 0)
      AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
                then l.mpp_type3
                else #tmp.mpp_type3
               end) or
          @drvtyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                    then l.mpp_type3
                    else #tmp.mpp_type3 end) + ',',@drvtyp3) > 0)
      AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
                then l.mpp_type4
                else #tmp.mpp_type4
               end) or
          @drvtyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                    then l.mpp_type4
                    else #tmp.mpp_type4 end) + ',',@drvtyp4) > 0)
                  --BEGIN PTS 65645 SPN
                  AND ( @mpp_branch = '%'
                     OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END) + ',', @mpp_branch) > 0
                      )
                  --END PTS 65645 SPN

         --select 'Point 6 @temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn

    SELECT @min_shift_id = min(shift_ss_id)
    FROM @temp_rtn
    WHERE shift_ss_id is not null and shift_ss_id > @min_shift_id and asgn_type = 'DRV'
   END
  END
 END ELSE BEGIN
  IF @ls_STL_TRS_Include_Shift = 'N' BEGIN
   INSERT INTO @temp_rtn
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
    INNER JOIN legheader l
     ON a.lgh_number = l.lgh_number
     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
     AND a.asgn_type = 'DRV',
     --BEGIN PTS 54163 SPN
     @tmp #tmp
   WHERE a.asgn_type = 'DRV'
    AND a.asgn_id = mpp_id
    AND a.asgn_status = 'CMP'
    AND pyd_status = 'NPD'
    AND a.asgn_date BETWEEN @lostartdate AND @histartdate
    AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
    --BEGIN PTS 53273 SPN
    AND ( (@acct_typ = 'X' AND a.actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
    --END PTS 53273 SPN
    --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
    --AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type1
    --  else #tmp.mpp_type1
    --  end))
    --AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type2
    --  else #tmp.mpp_type2
    --  end))
    --AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type3
    --  else #tmp.mpp_type3
    --  end))
    --AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type4
    --  else #tmp.mpp_type4
    --  end))
    AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
                                          then l.mpp_type1
                                          else #tmp.mpp_type1
             end) or
        @drvtyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type1
                  else #tmp.mpp_type1 end) + ',',@drvtyp1) > 0)
    AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type2
              else #tmp.mpp_type2
             end) or
        @drvtyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type2
                  else #tmp.mpp_type2 end) + ',',@drvtyp2) > 0)
    AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type3
              else #tmp.mpp_type3
             end) or
        @drvtyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type3
                  else #tmp.mpp_type3 end) + ',',@drvtyp3) > 0)
    AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type4
              else #tmp.mpp_type4
             end) or
        @drvtyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type4
                  else #tmp.mpp_type4 end) + ',',@drvtyp4) > 0)
            --BEGIN PTS 65645 SPN
            AND ( @mpp_branch = '%'
               OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END) + ',', @mpp_branch) > 0
                )
            --END PTS 65645 SPN

                  --select 'Point 7 @temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn
  END ELSE BEGIN
   --vjh 45381 new insert for join to shiftschedules table and restrictions based on that.
   INSERT INTO @temp_rtn
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
    INNER JOIN legheader l
     ON a.lgh_number = l.lgh_number
     AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
     AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
     AND a.asgn_type = 'DRV'
    LEFT JOIN shiftschedules s
     ON l.shift_Ss_id = s.ss_id,
    --BEGIN PTS 54163 SPN
    @tmp #tmp
   WHERE a.asgn_type = 'DRV'
    AND a.asgn_id = #tmp.mpp_id
    AND a.asgn_status = 'CMP'
    AND pyd_status = 'NPD'
    AND a.asgn_date BETWEEN @lostartdate AND @histartdate
    --AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
    AND s.ss_starttime BETWEEN @loenddate AND @hienddate
    --BEGIN PTS 53273 SPN
    AND ( (@acct_typ = 'X' AND a.actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
    --END PTS 53273 SPN
    --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
    --AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type1
    --  else #tmp.mpp_type1
    --  end))
    --AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type2
    --  else #tmp.mpp_type2
    --  end))
    --AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type3
    --  else #tmp.mpp_type3
    --  end))
    --AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
    --  then l.mpp_type4
    --  else #tmp.mpp_type4
    --  end))
    AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type1
              else #tmp.mpp_type1
             end) or
        @drvtyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type1
                  else #tmp.mpp_type1 end) + ',',@drvtyp1) > 0)
    AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type2
              else #tmp.mpp_type2
             end) or
        @drvtyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type2
                  else #tmp.mpp_type2 end) + ',',@drvtyp2) > 0)
    AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type3
              else #tmp.mpp_type3
             end) or
        @drvtyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type3
                  else #tmp.mpp_type3 end) + ',',@drvtyp3) > 0)
    AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type4
              else #tmp.mpp_type4
             end) or
        @drvtyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type4
                  else #tmp.mpp_type4 end) + ',',@drvtyp4) > 0)
            --BEGIN PTS 65645 SPN
            AND ( @mpp_branch = '%'
               OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END) + ',', @mpp_branch) > 0
                )
            --END PTS 65645 SPN

                  --select 'Point 8 @temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn

   --vjh 45381 walk through each shift and grab any trips that fell outside of the date range but have same shift
   SELECT @min_shift_id = min(shift_ss_id) FROM @temp_rtn WHERE shift_ss_id is not null and shift_ss_id > 0 and asgn_type = 'DRV'
   WHILE @min_shift_id is not null BEGIN
    INSERT INTO @temp_rtn
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
      INNER JOIN legheader l
       ON a.lgh_number = l.lgh_number
       AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
       AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
       AND a.asgn_type = 'DRV',
      --BEGIN PTS 54163 SPN
      @tmp #tmp
     WHERE a.asgn_type = 'DRV'
      AND a.asgn_id = mpp_id
      AND a.asgn_status = 'CMP'
      AND pyd_status = 'NPD'
      --AND a.asgn_date BETWEEN @lostartdate AND @histartdate
      --AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
      AND shift_ss_id = @min_shift_id
      AND l.lgh_number not in (SELECT lgh_number FROM @temp_rtn WHERE shift_ss_id = @min_shift_id)
      --BEGIN PTS 53273 SPN
      AND ( (@acct_typ = 'X' AND a.actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
      --END PTS 53273 SPN
      --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
      --AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
      --  then l.mpp_type1
      --  else #tmp.mpp_type1
      --  end))
      --AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
      --  then l.mpp_type2
      --  else #tmp.mpp_type2
      --  end))
      --AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
      --  then l.mpp_type3
      --  else #tmp.mpp_type3
      --  end))
      --AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
      --  then l.mpp_type4
      --  else #tmp.mpp_type4
      --  end))
      AND (@drvtyp1 = 'UNK' or @drvtyp1 =(case @resourcetypeonleg when 'Y'
              then l.mpp_type1
              else #tmp.mpp_type1
     end) or
        @drvtyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.mpp_type1
                  else #tmp.mpp_type1 end) + ',',@drvtyp1) > 0)
      AND (@drvtyp2 = 'UNK' or @drvtyp2 =(case @resourcetypeonleg when 'Y'
                then l.mpp_type2
                else #tmp.mpp_type2
               end) or
          @drvtyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                    then l.mpp_type2
                    else #tmp.mpp_type2 end) + ',',@drvtyp2) > 0)
      AND (@drvtyp3 = 'UNK' or @drvtyp3 =(case @resourcetypeonleg when 'Y'
                then l.mpp_type3
                else #tmp.mpp_type3
               end) or
          @drvtyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                    then l.mpp_type3
                    else #tmp.mpp_type3 end) + ',',@drvtyp3) > 0)
      AND (@drvtyp4 = 'UNK' or @drvtyp4 =(case @resourcetypeonleg when 'Y'
                then l.mpp_type4
                else #tmp.mpp_type4
               end) or
          @drvtyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                    then l.mpp_type4
                    else #tmp.mpp_type4 end) + ',',@drvtyp4) > 0)
                  --BEGIN PTS 65645 SPN
                  AND ( @mpp_branch = '%'
                     OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp.asgn_branch,'UNKNOWN') END) + ',', @mpp_branch) > 0
                      )
                  --END PTS 65645 SPN

                    --select 'Point 9 @temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn

     SELECT @min_shift_id = min(shift_ss_id)
     FROM @temp_rtn
     WHERE shift_ss_id is not null and shift_ss_id > @min_shift_id and asgn_type = 'DRV'
   END
  END
 END
END

/* Insert any tractors */
--BEGIN PTS 53466 SPN
--IF @trcyes != 'XXX'
IF @trcyes <> 'XXX'
--END PTS 53466 SPN
BEGIN
 -- vjh 30395 add logic for using asset asignment accounting type
 If @STLUseLegAcctType = 'Y' BEGIN
  IF @ls_STL_TRS_Include_Shift = 'N' BEGIN
   INSERT INTO @temp_rtn
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
     INNER JOIN legheader l
      ON a.lgh_number = l.lgh_number
      AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
      AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
      AND a.asgn_type = 'TRC',
     --BEGIN PTS 54163 SPN
     @tmp1 #tmp1
    WHERE a.asgn_type = 'TRC'
     AND a.asgn_id = trc_number
     AND a.asgn_status = 'CMP'
     AND pyd_status = 'NPD'
     AND a.asgn_date BETWEEN @lostartdate AND @histartdate
     AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
     AND ( (@acct_typ = 'X' AND actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
     --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
     --AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type1
     --  else #tmp1.trc_type1
     --  end))
     --AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type2
     --  else #tmp1.trc_type2
     --  end))
     --AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type3
     --  else #tmp1.trc_type3
     --  end))
     --AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type4
     --  else #tmp1.trc_type4
     --  end))
     AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
              then l.trc_type1
              else #tmp1.trc_type1
             end) or
        @trctyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type1
                  else #tmp1.trc_type1 end) + ',',@trctyp1) > 0)
     AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
              then l.trc_type2
              else #tmp1.trc_type2
             end) or
        @trctyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type2
                  else #tmp1.trc_type2 end) + ',',@trctyp2) > 0)
     AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
              then l.trc_type3
              else #tmp1.trc_type3
             end) or
        @trctyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type3
                  else #tmp1.trc_type3 end) + ',',@trctyp3) > 0)
     AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
              then l.trc_type4
              else #tmp1.trc_type4
             end) or
        @trctyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type4
                  else #tmp1.trc_type4 end) + ',',@trctyp4) > 0)
            --BEGIN PTS 65645 SPN
            AND ( @trc_branch = '%'
               OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END) + ',', @trc_branch) > 0
                )
            --END PTS 65645 SPN

                  --select 'Point 10 @temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn

  END ELSE BEGIN
   INSERT INTO @temp_rtn
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
     INNER JOIN legheader l
      ON a.lgh_number = l.lgh_number
      AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
      AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
      AND a.asgn_type = 'TRC'
     LEFT JOIN shiftschedules s
      ON l.shift_sS_id = s.ss_id,
     --BEGIN PTS 54163 SPN
     @tmp1 #tmp1
    WHERE a.asgn_type = 'TRC'
     AND a.asgn_id = #tmp1.trc_number
     AND a.asgn_status = 'CMP'
     AND pyd_status = 'NPD'
     AND a.asgn_date BETWEEN @lostartdate AND @histartdate
     --AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
     AND s.ss_starttime BETWEEN @loenddate AND @hienddate
     AND ( (@acct_typ = 'X' AND actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
     --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
     --AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type1
     --  else #tmp1.trc_type1
     --  end))
     --AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type2
     --  else #tmp1.trc_type2
     --  end))
     --AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type3
     --  else #tmp1.trc_type3
     --  end))
     --AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type4
     --  else #tmp1.trc_type4
     --  end))
     AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
              then l.trc_type1
              else #tmp1.trc_type1
             end) or
        @trctyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
            then l.trc_type1
                  else #tmp1.trc_type1 end) + ',',@trctyp1) > 0)
     AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
              then l.trc_type2
              else #tmp1.trc_type2
             end) or
        @trctyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type2
                  else #tmp1.trc_type2 end) + ',',@trctyp2) > 0)
     AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
              then l.trc_type3
              else #tmp1.trc_type3
             end) or
        @trctyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type3
                  else #tmp1.trc_type3 end) + ',',@trctyp3) > 0)
     AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
              then l.trc_type4
              else #tmp1.trc_type4
             end) or
        @trctyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type4
                  else #tmp1.trc_type4 end) + ',',@trctyp4) > 0)
               --BEGIN PTS 65645 SPN
               AND ( @trc_branch = '%'
                  OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END) + ',', @trc_branch) > 0
                   )
               --END PTS 65645 SPN

                  --select 'Point 11 @temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn

   SELECT @min_shift_id = min(shift_ss_id) FROM @temp_rtn WHERE shift_ss_id is not null and shift_ss_id > 0 and asgn_type = 'TRC'
   WHILE @min_shift_id is not null BEGIN
    INSERT INTO @temp_rtn
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
      INNER JOIN legheader l
       ON a.lgh_number = l.lgh_number
       AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
       AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
       AND a.asgn_type = 'TRC',
      --BEGIN PTS 54163 SPN
      @tmp1 #tmp1
     WHERE a.asgn_type = 'TRC'
      AND a.asgn_id = trc_number
      AND a.asgn_status = 'CMP'
      AND pyd_status = 'NPD'
      --AND a.asgn_date BETWEEN @lostartdate AND @histartdate
      --AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
      AND shift_ss_id = @min_shift_id
      AND l.lgh_number not in (SELECT lgh_number FROM @temp_rtn WHERE shift_ss_id = @min_shift_id)
      AND ( (@acct_typ = 'X' AND actg_type IN('A', 'P')) OR (@acct_typ = actg_type) )
      --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
      --AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
      --  then l.trc_type1
      --  else #tmp1.trc_type1
      --  end))
      --AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
      --  then l.trc_type2
      --  else #tmp1.trc_type2
      --  end))
      --AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
      --  then l.trc_type3
      --  else #tmp1.trc_type3
      --  end))
      --AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
      --  then l.trc_type4
      --  else #tmp1.trc_type4
      --  end))
      AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
              then l.trc_type1
              else #tmp1.trc_type1
             end) or
        @trctyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type1
                  else #tmp1.trc_type1 end) + ',',@trctyp1) > 0)
     AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
              then l.trc_type2
              else #tmp1.trc_type2
             end) or
        @trctyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type2
                  else #tmp1.trc_type2 end) + ',',@trctyp2) > 0)
     AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
              then l.trc_type3
              else #tmp1.trc_type3
             end) or
        @trctyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type3
                  else #tmp1.trc_type3 end) + ',',@trctyp3) > 0)
     AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
              then l.trc_type4
              else #tmp1.trc_type4
             end) or
        @trctyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type4
                  else #tmp1.trc_type4 end) + ',',@trctyp4) > 0)
               --BEGIN PTS 65645 SPN
               AND ( @trc_branch = '%'
                  OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END) + ',', @trc_branch) > 0
                   )
               --END PTS 65645 SPN

                  --select 'Point 12 @temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn

    SELECT @min_shift_id = min(shift_ss_id) FROM @temp_rtn WHERE shift_ss_id is not null and shift_ss_id > @min_shift_id and asgn_type = 'TRC'
   END
  END
 END ELSE BEGIN
  IF @ls_STL_TRS_Include_Shift = 'N' BEGIN
   INSERT INTO @temp_rtn
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
     INNER JOIN legheader l
      ON a.lgh_number = l.lgh_number
      AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
      AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
      AND a.asgn_type = 'TRC',
     --BEGIN PTS 54163 SPN
     @tmp1 #tmp1
    WHERE a.asgn_type = 'TRC'
     AND a.asgn_id = trc_number
     AND a.asgn_status = 'CMP'
     AND pyd_status = 'NPD'
     AND a.asgn_date BETWEEN @lostartdate AND @histartdate
     AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
     --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
     --AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type1
     --  else #tmp1.trc_type1
     --  end))
     --AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type2
     --  else #tmp1.trc_type2
     --  end))
     --AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type3
     --  else #tmp1.trc_type3
     --  end))
     --AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type4
     --  else #tmp1.trc_type4
     --  end))
     AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
              then l.trc_type1
              else #tmp1.trc_type1
             end) or
        @trctyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type1
                  else #tmp1.trc_type1 end) + ',',@trctyp1) > 0)
     AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
              then l.trc_type2
              else #tmp1.trc_type2
             end) or
        @trctyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type2
                  else #tmp1.trc_type2 end) + ',',@trctyp2) > 0)
     AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
              then l.trc_type3
              else #tmp1.trc_type3
             end) or
        @trctyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type3
                  else #tmp1.trc_type3 end) + ',',@trctyp3) > 0)
     AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
              then l.trc_type4
              else #tmp1.trc_type4
             end) or
        @trctyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type4
                  else #tmp1.trc_type4 end) + ',',@trctyp4) > 0)
               --BEGIN PTS 65645 SPN
               AND ( @trc_branch = '%'
                  OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END) + ',', @trc_branch) > 0
                   )
               --END PTS 65645 SPN

                  --select 'Point 13 @@temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn
  END ELSE BEGIN
   INSERT INTO @temp_rtn
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
     INNER JOIN legheader l
      ON a.lgh_number = l.lgh_number
      AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
      AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
      AND a.asgn_type = 'TRC'
     LEFT JOIN shiftschedules s
      ON l.shift_sS_id = s.ss_id,
     --BEGIN PTS 54163 SPN
     @tmp1 #tmp1
    WHERE a.asgn_type = 'TRC'
     AND a.asgn_id = #tmp1.trc_number
     AND a.asgn_status = 'CMP'
     AND pyd_status = 'NPD'
     AND a.asgn_date BETWEEN @lostartdate AND @histartdate
     --AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
     AND s.ss_starttime BETWEEN @loenddate AND @hienddate
     --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
     --AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type1
     --  else #tmp1.trc_type1
     --  end))
     --AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type2
     --  else #tmp1.trc_type2
     --  end))
     --AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type3
     --  else #tmp1.trc_type3
     --  end))
     --AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
     --  then l.trc_type4
     --  else #tmp1.trc_type4
     --  end))
     AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
              then l.trc_type1
              else #tmp1.trc_type1
             end) or
        @trctyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type1
                  else #tmp1.trc_type1 end) + ',',@trctyp1) > 0)
     AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
              then l.trc_type2
              else #tmp1.trc_type2
             end) or
        @trctyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type2
                  else #tmp1.trc_type2 end) + ',',@trctyp2) > 0)
     AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
              then l.trc_type3
              else #tmp1.trc_type3
             end) or
        @trctyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type3
                  else #tmp1.trc_type3 end) + ',',@trctyp3) > 0)
     AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
              then l.trc_type4
              else #tmp1.trc_type4
             end) or
        @trctyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type4
                  else #tmp1.trc_type4 end) + ',',@trctyp4) > 0)
            --BEGIN PTS 65645 SPN
            AND ( @trc_branch = '%'
               OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END) + ',', @trc_branch) > 0
                )
            --END PTS 65645 SPN

 --select 'Point 14 @@temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn

   SELECT @min_shift_id = min(shift_ss_id) FROM @temp_rtn WHERE shift_ss_id is not null and shift_ss_id > 0 and asgn_type = 'TRC'
   WHILE @min_shift_id is not null BEGIN
    INSERT INTO @temp_rtn
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
      INNER JOIN legheader l
       ON a.lgh_number = l.lgh_number
       AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
       AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
       AND a.asgn_type = 'TRC',
     --BEGIN PTS 54163 SPN
     @tmp1 #tmp1
     WHERE a.asgn_type = 'TRC'
      AND a.asgn_id = trc_number
      AND a.asgn_status = 'CMP'
      AND pyd_status = 'NPD'
      --AND a.asgn_date BETWEEN @lostartdate AND @histartdate
      --AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
      AND shift_ss_id = @min_shift_id
      AND l.lgh_number not in (SELECT lgh_number FROM @temp_rtn WHERE shift_ss_id = @min_shift_id)
      --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1 -- 01/24/2008 MDH PTS 40119: Added
      --AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
      --  then l.trc_type1
      --  else #tmp1.trc_type1
      --  end))
      --AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
      --  then l.trc_type2
      --  else #tmp1.trc_type2
      --  end))
      --AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
      --  then l.trc_type3
      --  else #tmp1.trc_type3
      --  end))
      --AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
      --  then l.trc_type4
      --  else #tmp1.trc_type4
      --  end))
      AND (@trctyp1 = 'UNK' or @trctyp1 =(case @resourcetypeonleg when 'Y'
              then l.trc_type1
              else #tmp1.trc_type1
             end) or
        @trctyp1 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                  then l.trc_type1
                  else #tmp1.trc_type1 end) + ',',@trctyp1) > 0)
      AND (@trctyp2 = 'UNK' or @trctyp2 =(case @resourcetypeonleg when 'Y'
               then l.trc_type2
               else #tmp1.trc_type2
              end) or
         @trctyp2 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                   then l.trc_type2
                   else #tmp1.trc_type2 end) + ',',@trctyp2) > 0)
      AND (@trctyp3 = 'UNK' or @trctyp3 =(case @resourcetypeonleg when 'Y'
               then l.trc_type3
               else #tmp1.trc_type3
              end) or
         @trctyp3 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                   then l.trc_type3
                   else #tmp1.trc_type3 end) + ',',@trctyp3) > 0)
      AND (@trctyp4 = 'UNK' or @trctyp4 =(case @resourcetypeonleg when 'Y'
               then l.trc_type4
               else #tmp1.trc_type4
              end) or
         @trctyp4 ='%' or CHARINDEX( ',' + (case @resourcetypeonleg when 'Y'
                   then l.trc_type4
                   else #tmp1.trc_type4 end) + ',',@trctyp4) > 0)
                  --BEGIN PTS 65645 SPN
                  AND ( @trc_branch = '%'
                     OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp1.asgn_branch,'UNKNOWN') END) + ',', @trc_branch) > 0
                      )
                  --END PTS 65645 SPN

                   --select 'Point 15 @@temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn

    SELECT @min_shift_id = min(shift_ss_id) FROM @temp_rtn WHERE shift_ss_id is not null and shift_ss_id > @min_shift_id and asgn_type = 'TRC'
   END
  END
 END
END

/* Insert any carriers */
--BEGIN PTS 53466 SPN
--IF @caryes != 'XXX'
IF @caryes <> 'XXX'
--END PTS 53466 SPN
BEGIN
    INSERT INTO @temp_rtn
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
    INNER JOIN legheader l
  ON a.lgh_number = l.lgh_number
  AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
  AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
  AND a.asgn_type = 'CAR',
 --BEGIN PTS 54163 SPN
 @tmp2 #tmp2
    WHERE a.asgn_type = 'CAR'
        AND a.asgn_id = car_id
        AND a.asgn_status = 'CMP'
        AND pyd_status = 'NPD'
        AND a.asgn_date BETWEEN @lostartdate AND @histartdate
        AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
        --BEGIN PTS 65645 SPN
        AND ( @car_branch = '%'
           OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp2.asgn_branch,'UNKNOWN') END) + ',', @car_branch) > 0
            )
        --END PTS 65645 SPN

        --select 'Point 16 @temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn

END

/* LOR PTS# 5744 add trailer settlements */
/* Insert any trailers */
--BEGIN PTS 53466 SPN
--IF @trlyes != 'XXX'
IF @trlyes <> 'XXX'
--END PTS 53466 SPN
BEGIN
 INSERT INTO @temp_rtn
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
    INNER JOIN legheader l
  ON a.lgh_number = l.lgh_number
  AND (@shiftdate = '1950-01-01 00:00' or @shiftdate = l.lgh_shiftdate)
  AND (@shiftnumber = 'UNK' OR @shiftnumber = l.lgh_shiftnumber)
  AND a.asgn_type = 'TRL',
 --BEGIN PTS 54163 SPN
 @tmp3 #tmp3
  WHERE a.asgn_type = 'TRL'
         AND a.asgn_id = trl_id
         AND a.asgn_status = 'CMP'
         AND pyd_status = 'NPD'
         AND a.asgn_date BETWEEN @lostartdate AND @histartdate
         AND a.asgn_enddate BETWEEN @loenddate AND @hienddate
       --AND dbo.RowRestrictByAsgn (a.asgn_type, a.asgn_id) = 1  -- 01/24/2008 MDH PTS 40119: Added
         --BEGIN PTS 65645 SPN
         AND ( @trl_branch = '%'
            OR CHARINDEX( ',' + (CASE @resourcetypeonleg WHEN 'Y' THEN IsNull(a.asgn_branch,'UNKNOWN') ELSE IsNull(#tmp3.asgn_branch,'UNKNOWN') END) + ',', @trl_branch) > 0
             )
         --END PTS 65645 SPN

         --select 'Point 17 @@temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn
END
/* LOR */

IF @tpryes <> 'XXX'
--BEGIN
-- -- LOR PTS# 31839
-- select @agent = Upper(LTrim(RTrim(gi_string1))) from generalinfo where gi_name = 'AgentCommiss'
-- If @agent = 'Y' or @agent = 'YES'
-- Begin
--  --BEGIN PTS 57093 SPN
--  INSERT INTO @tmp4
--  SELECT DISTINCT tpr_id, tpr_name
--  --INTO #tmp4
--      --END PTS 57093 SPN
--  FROM thirdpartyprofile
--  WHERE @tpr_id IN ('UNKNOWN', tpr_id)
--     AND (@tprtype1 in ('N', 'X') OR (@tprtype1 = 'Y' AND @tprtype1 = tpr_thirdpartytype1))
--     AND (@tprtype2 in ('N', 'X') OR (@tprtype2 = 'Y' AND @tprtype2 = tpr_thirdpartytype2))
--     AND (@tprtype3 in ('N', 'X') OR (@tprtype3 = 'Y' AND @tprtype3 = tpr_thirdpartytype3))
--     AND (@tprtype4 in ('N', 'X') OR (@tprtype4 = 'Y' AND @tprtype4 = tpr_thirdpartytype4))
--     AND (@tprtype5 in ('N', 'X') OR (@tprtype5 = 'Y' AND @tprtype5 = tpr_thirdpartytype5))
--     AND (@tprtype6 in ('N', 'X') OR (@tprtype6 = 'Y' AND @tprtype6 = tpr_thirdpartytype6))
--     AND @acct_typ IN ('X', tpr_actg_type)
--     AND tpr_actg_type IN('A', 'P')

--    INSERT INTO #temp_rtn
--               (lgh_number, asgn_type, asgn_id, asgn_date, asgn_enddate,
--                cmp_id_start, cmp_id_end, mov_number, asgn_number, ord_hdrnumber,
--    lgh_startcity, lgh_endcity, ord_number, name,
--    cmp_name_start, cmp_name_end, cty_nmstct_start, cty_nmstct_end,
--    need_paperwork, ivh_revtype1, revtype1_name, lgh_split_flag,
--    trip_description, lgh_type1, lgh_type_name, ivh_billdate,
--    ivh_invoicenumber, lgh_booked_revtype1, ivh_billto, asgn_controlling)
--   SELECT 0, 'TPR', orderheader.ord_thirdpartytype1, orderheader.ord_startdate,
--     orderheader.ord_completiondate, '', '', orderheader.mov_number, 0,
--     orderheader.ord_hdrnumber, 0, 0, orderheader.ord_number, tpr_name,
--     '', '', '', '', 0, '', 'RevType1', 'N','',
--     'UNK','LghType1', null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', 'Y'
--   FROM orderheader, @tmp4 #tmp4
--         WHERE orderheader.ord_thirdpartytype1 = tpr_id
--               AND orderheader.ord_status = 'CMP'
--               AND orderheader.ord_pyd_status_1 = 'NPD'
--               AND orderheader.ord_startdate BETWEEN @lostartdate AND @histartdate
--               AND orderheader.ord_completiondate BETWEEN @loenddate AND @hienddate
--               AND ( (@rowsecurity <> 'Y')
--                   OR EXISTS(SELECT 1
--                               FROM @tbl_restrictedbyuser rsva
--                              WHERE orderheader.rowsec_rsrv_id = rsva.rowsec_rsrv_id
--                                 OR rsva.rowsec_rsrv_id = 0
--                            )
--                   )
--               --END PTS 57093 SPN

--    INSERT INTO #temp_rtn
--               (lgh_number, asgn_type, asgn_id, asgn_date, asgn_enddate,
--                cmp_id_start, cmp_id_end, mov_number, asgn_number, ord_hdrnumber,
--    lgh_startcity, lgh_endcity, ord_number, name,
--    cmp_name_start, cmp_name_end, cty_nmstct_start, cty_nmstct_end,
--    need_paperwork, ivh_revtype1, revtype1_name, lgh_split_flag,
--    trip_description, lgh_type1, lgh_type_name, ivh_billdate,
--    ivh_invoicenumber, lgh_booked_revtype1, ivh_billto, asgn_controlling)
--         SELECT 0, 'TPR', orderheader.ord_thirdpartytype1, orderheader.ord_startdate,
--     orderheader.ord_completiondate, '', '', orderheader.mov_number, 0,
--     orderheader.ord_hdrnumber, 0, 0, orderheader.ord_number, tpr_name,
--     '', '', '', '', 0, '', 'RevType1', 'N','',
--     'UNK','LghType1', null, null, 'Lgh_Booked_Revtype1', 'IvhBillT', 'Y'
--         FROM orderheader, @tmp4 #tmp4
--         WHERE orderheader.ord_thirdpartytype2 = tpr_id
--               AND orderheader.ord_status = 'CMP'
--               AND orderheader.ord_pyd_status_2 = 'NPD'
--               AND orderheader.ord_startdate BETWEEN @lostartdate AND @histartdate
--               AND orderheader.ord_completiondate BETWEEN @loenddate AND @hienddate
--               AND ( (@rowsecurity <> 'Y')
--     OR EXISTS(SELECT 1
--                 FROM @tbl_restrictedbyuser rsva
--                WHERE orderheader.rowsec_rsrv_id = rsva.rowsec_rsrv_id
--                   OR rsva.rowsec_rsrv_id = 0
--              )
--                   )
-- End
-- Else
---- LOR
  INSERT INTO @temp_rtn
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
   from thirdpartyassignment tpa
   where isnull(pyd_status, 'NPD') = 'NPD'
   --AND (@tpr_id = tpr_id OR @tpr_id = 'UNKNOWN')
   --AND (@tpr_type = tpr_type OR @tpr_type = 'UNKNOWN')
   AND (@tpr_id = tpr_id OR @tpr_id = 'UNKNOWN' OR @tpr_id = '%' OR CHARINDEX( ',' + tpr_id + ',',@tpr_id) > 0)
         AND (@tpr_type = tpr_type OR @tpr_type = 'UNKNOWN' OR @tpr_type = '%' or CHARINDEX( ',' + tpr_type + ',',@tpr_type) > 0)
         AND isnull(tpa_status, 'NPD') <> 'DEL'
   AND (select lgh_outstatus from legheader where lgh_number = tpa.lgh_number) = 'CMP'
   AND (select lgh_startdate from legheader where lgh_number = tpa.lgh_number) BETWEEN @lostartdate AND @histartdate
   AND (select lgh_enddate from legheader where lgh_number = tpa.lgh_number) BETWEEN @loenddate AND @hienddate

   --select 'Point 18 @temp_rtn - ' + convert(varchar(20),count(*)) from @temp_rtn
--END
-- MRH

/* Get the mov number */
UPDATE @temp_rtn
   SET mov_number = legheader.mov_number,
 ord_hdrnumber = legheader.ord_hdrnumber,
 lgh_startcity = legheader.lgh_startcity,
 cmp_id_start = legheader.cmp_id_start,
 lgh_endcity = legheader.lgh_endcity,
 cmp_id_end = legheader.cmp_id_end,
 cty_nmstct_start = lgh_startcty_nmstct,
 cty_nmstct_end = lgh_endcty_nmstct,
 lgh_split_flag = legheader.lgh_split_flag,
 lgh_type1 = isNull(legheader.lgh_type1,'UNK'),
 ivh_billdate = NULL,
 ivh_invoicenumber = NULL,
 lgh_booked_revtype1 = isNull(legheader.lgh_booked_revtype1, 'UNK')
      , lgh_type2 = isNull(legheader.lgh_type2,'UNK') -- PTS 52192
      , lgh_type3 = isNull(legheader.lgh_type3,'UNK') -- PTS 52192
      , lgh_type4 = isNull(legheader.lgh_type4,'UNK') -- PTS 52192
   FROM legheader inner join @temp_rtn r
 on legheader.lgh_number = r.lgh_number

--BEGIN PTS 52995 SPN
UPDATE @temp_rtn
   SET lgh_booked_revtype1 = 'UNK'
 WHERE lgh_booked_revtype1 = 'Lgh_Booked_Revtype1'
--END PTS 52995 SPN

---- 21110 JD exclude hourly orders from trips ready to settle
--select @revtype4 = gi_string4 from generalinfo where gi_name = 'TripStlExcludeRevtypefromQ'
--If @revtype4 is not null and exists (select * from labelfile where labeldefinition = 'Revtype4' and abbr = @revtype4)
--begin
-- delete #temp_rtn from orderheader
-- where #temp_rtn.ord_hdrnumber = orderheader.ord_hdrnumber and
--   orderheader.ord_revtype4 = @revtype4
--end
---- end 21110 JD


/* PTS 17873 - DJM - 4/11/03 Remove legs that don't match the requrired lgh_type1 */
--select @lgh_type1 = isnull(@lgh_type1, 'UNK')
--if @lgh_type1 <> 'UNK' AND @lgh_type1 <> ''
-- Delete from #temp_rtn
-- where lgh_type1 <> @lgh_type1
if @lgh_type1 <> ',UNK,' AND @lgh_type1 <> '%'
 Delete from @temp_rtn
 where CHARINDEX( ',' + lgh_type1 + ',',@lgh_type1) <= 0

--BEGIN PTS 66553 SPN
--update @temp_rtn set trip_description = dbo.tmwf_scroll_assignments_concat(mov_number)
--update @temp_rtn set trip_description = substring(trip_description,2,datalength(trip_description))
--where datalength(trip_description) > 0
--END PTS 66553 SPN

--BEGIN PTS 66553 SPN
UPDATE @temp_rtn
   SET ord_number = orderheader.ord_number,
   ord_route = orderheader.ord_route ,
   ord_revtype1 = orderheader.ord_revtype1,
   ord_revtype2 = orderheader.ord_revtype2,
   ord_revtype3 = orderheader.ord_revtype3,
   ord_revtype4 = orderheader.ord_revtype4
                       FROM orderheader  inner join @temp_rtn r
                      on orderheader.ord_hdrnumber = r.ord_hdrnumber
--END PTS 66553 SPN

--BEGIN PTS 66553 SPN
UPDATE @temp_rtn
   SET
    stp_schdtearliest =
       (
        CASE WHEN IsNull(r.ord_hdrnumber,0) = 0 THEN NULL
        ELSE
             (SELECT stp_schdtearliest
                FROM stops
               WHERE stp_number =
                     (SELECT min(stp_number)
                        FROM stops
                       WHERE ord_hdrnumber = r.ord_hdrnumber
                         AND stp_mfh_sequence =
                             (SELECT min(stp_mfh_sequence)
                                FROM stops
                               WHERE ord_hdrnumber = r.ord_hdrnumber
                             )
                     )
             )
        END
       )
     , cost =
       (
        CASE WHEN IsNull(r.ord_hdrnumber,0) = 0 THEN NULL
        ELSE
             (SELECT sum(pyd_amount)
                FROM paydetail
               WHERE ord_hdrnumber = r.ord_hdrnumber
             )
        END
       )

     , ord_revtype1_name =
       (SELECT min(labelfile.userlabelname)
          FROM labelfile
         WHERE labelfile.userlabelname > ''
           AND labelfile.labeldefinition = 'REVTYPE1'
       )

     , ord_revtype2_name =
       (SELECT min(labelfile.userlabelname)
          FROM labelfile
         WHERE labelfile.userlabelname > ''
           AND labelfile.labeldefinition = 'REVTYPE2'
       )

     , ord_revtype3_name =
       (SELECT min(labelfile.userlabelname)
          FROM labelfile
         WHERE labelfile.userlabelname > ''
           AND labelfile.labeldefinition = 'REVTYPE3'
       )

     , ord_revtype4_name =
       (SELECT min(labelfile.userlabelname)
          FROM labelfile
         WHERE labelfile.userlabelname > ''
           AND labelfile.labeldefinition = 'REVTYPE4'
       )
     , cmp_name_start =
       (SELECT co.cmp_name
          FROM company co
         WHERE r.cmp_id_start = co.cmp_id
       )
     , cmp_name_end =
       (SELECT co.cmp_name
          FROM company co
         WHERE r.cmp_id_end = co.cmp_id
       )
     , ivh_revtype1 =
       (
        CASE WHEN IsNull(r.ord_hdrnumber,0) = 0 THEN NULL
        ELSE
             (SELECT ivh_revtype1
                FROM invoiceheader i
               WHERE i.ord_hdrnumber = r.ord_hdrnumber
                 AND i.ord_hdrnumber <> 0
                 AND i.ivh_hdrnumber = (SELECT MIN(ivh_hdrnumber)
                      FROM invoiceheader ii
                                         WHERE ii.ord_hdrnumber = i.ord_hdrnumber
                                           AND ii.ord_hdrnumber=r.ord_hdrnumber
                                       )
             )
        END
       )
     , ivh_billto =
       (
        CASE WHEN IsNull(r.ord_hdrnumber,0) = 0 THEN NULL
        ELSE
             (SELECT ivh_billto
                FROM invoiceheader i
               WHERE i.ord_hdrnumber = r.ord_hdrnumber
                 AND i.ord_hdrnumber <> 0
                 AND i.ivh_hdrnumber = (SELECT MIN(ivh_hdrnumber)
                                          FROM invoiceheader ii
                                         WHERE ii.ord_hdrnumber = i.ord_hdrnumber
                                           AND ii.ord_hdrnumber=r.ord_hdrnumber
                                       )
             )
        END
       )  --END PTS 53466 SPN
       from @temp_rtn r
--END PTS 66553 SPN

/* PTS 16034 - DJM - Modified to handle Paperwork requirements by Leg and/or by Bill To company. */
select @paperworkmode = isNull(gi_string1,'A') from generalinfo where gi_name = 'PaperWorkMode'
select @paperworkchecklevel = IsNull(gi_string1,'ORDER') from generalinfo where gi_name = 'PaperWorkCheckLevel'

/* PTS 16982 - DJM - Modify the Proc to properly identify the Paperwork required each Order and/or Leg to be settled. */
/* Insert a record into #temp_pwk for every Legheader/Orderheader combination.  Gets all the Orderheaders on
 a Leg so Paperwork can be tracked for every Order.  */
Insert into #temp_pwk
SELECT  r.lgh_number,
 stops.ord_hdrnumber,
 0 req_cnt,
 0 rec_cnt,
 (select isNull(ord_billto,'UNK') from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) ord_billto
FROM @temp_rtn r inner join stops  ON  stops.lgh_number = r.lgh_number
WHERE
  stops.ord_hdrnumber <> 0  --isNull(stops.ord_hdrnumber,0) > 0  pmill 49424 performance enhancement

GROUP BY r.lgh_number, stops.ord_hdrnumber
Order by r.lgh_number

/* Set the number of required paperwork fields for each order  */
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
           --and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'PUP'))
		   and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event in ('PUP','APUP','FPUP','ASTOP'))) -- LOR  PTS# 106665
          or (exists(select *
            from stops stp
            where stp.lgh_number = #temp_pwk.lgh_number
             and stp_type = 'DRP')
          --and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'DRP')))
		  and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event in ('DRP', 'ADRP', 'LDRP', 'ASTOP')))) -- LOR  PTS# 106665
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
           --and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'PUP'))
		   and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event in ('PUP','APUP','FPUP','ASTOP'))) -- LOR  PTS# 106665
          or (exists(select *
            from stops stp
            where stp.lgh_number = #temp_pwk.lgh_number
             and stp_type = 'DRP')
         -- and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'DRP')))
		  and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event in ('DRP', 'ADRP', 'LDRP', 'ASTOP')))) -- LOR  PTS# 106665
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
 /* Paperwork is not tracked by Leg,  Only the total number for the Order is tracked  */
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
  /* Update where all paperwork is in   */
  UPDATE @temp_rtn
     SET need_paperwork = 1
    FROM @temp_rtn r
   WHERE exists ( select * from #temp_pwk
   where #temp_pwk.lgh_number = r.lgh_number
    and rec_cnt >= req_cnt)

  /* Update where all paperwork is not in  */
  UPDATE @temp_rtn
     SET need_paperwork = -1
    FROM @temp_rtn r
   WHERE exists ( select * from #temp_pwk
   where #temp_pwk.lgh_number = r.lgh_number
    and rec_cnt < req_cnt)
 End
else
 Begin
  /* Update where all paperwork is in   */
  UPDATE @temp_rtn
     SET need_paperwork = 1
    FROM @temp_rtn  r
   WHERE exists ( select * from #temp_pwk
   where #temp_pwk.ord_hdrnumber = r.ord_hdrnumber
    and rec_cnt >= req_cnt)

  /* Update where all paperwork is not in  */
  UPDATE @temp_rtn
     SET need_paperwork = -1
    FROM @temp_rtn  r
   WHERE exists ( select * from #temp_pwk
   where #temp_pwk.ord_hdrnumber = r.ord_hdrnumber
    and rec_cnt < req_cnt)
 End
-- End 16982

DROP TABLE #temp_pwk

if @stlmustinv = 'Y' or @StlMustOrd = 'Y' begin
 --get the orders we need to consider
 if @splitmustinv ='Y' or @StlMustOrd = 'Y' begin
  insert #temp_Orders
  select a.lgh_number, s.ord_hdrnumber, 'N', 'N', lgh_split_flag
  from @temp_rtn a
  join stops s on a.lgh_number = s.lgh_number
  and s.ord_hdrnumber <> 0 -- SGB PTS 48667 need to exclude 0 ord_hdrnumbers
   end else begin
      if @splitmustinv ='N' begin

         --@splitmustinv = 'N' so only need to check for orders on stops with drop events
  insert #temp_Orders
  select a.lgh_number, s.ord_hdrnumber, 'N', 'N', lgh_split_flag
  from @temp_rtn a
  join stops s on a.lgh_number = s.lgh_number
  join event e on e.stp_number = s.stp_number
  join eventcodetable ect on ect.abbr = e.evt_eventcode and fgt_event='DRP'
      end else begin
         -- --PTS 63716 Add support for SplitMustInv = 'L' from PTS58060
         --@splitmustinv = 'L' so only need to check for orders on stops on last leg
         insert #temp_Orders
         select a.lgh_number, s.ord_hdrnumber, 'N', 'N', lgh_split_flag
         from @temp_rtn a
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

insert into #temp_rtn1
select a.*
from @temp_rtn a
where not exists (select * from #temp_Orders where (Inv_OK_Flag = 'N' or Ord_OK_Flag = 'N') and a.lgh_number = #temp_Orders.lgh_number)
or (a.lgh_split_flag = 'S' and @ComputeRevenueByTripSegment = 'Y')


-- PTS 31363 -- BL (start)
-- Update billdate and invoicenumber rather than set it during the insert
update  #temp_rtn1
set  ivh_billdate = (SELECT  max(ivh_billdate)
      from  invoiceheader
      where #temp_rtn1.ord_hdrnumber = invoiceheader.ord_hdrnumber)
where #temp_rtn1.ord_hdrnumber > 0

update  #temp_rtn1
set  ivh_invoicenumber = (select max(ivh_invoicenumber)
       from  invoiceheader
       where  ivh_billdate = #temp_rtn1.ivh_billdate)
where  #temp_rtn1.ord_hdrnumber > 0
-- PTS 31363 -- BL (end)

--BEGIN PTS 66553 SPN
----BEGIN 46308 SPN
----Get Consolidated Orders Invoice Info
--BEGIN
--   DECLARE upd_cursor_consord CURSOR FOR
--   SELECT mov_number
--     FROM #temp_rtn1
--    WHERE ivh_invoicenumber IS NULL
--
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
--
--         FETCH NEXT FROM upd_cursor_consord INTO @upd_cursor_consord_mov_number
--      END
--   CLOSE upd_cursor_consord
--   DEALLOCATE upd_cursor_consord
--END
----END 46308 SPN
--END PTS 66553 SPN

--BEGIN PTS 66553 SPN
Update #temp_rtn1
set ivh_billdate = invoiceheader.ivh_billdate,
   ivh_billto  = invoiceheader.ivh_billto,
   ivh_revtype1 = invoiceheader.ivh_revtype1
from #temp_rtn1 inner join invoiceheader on #temp_rtn1.ord_hdrnumber = invoiceheader.ord_hdrnumber
and #temp_rtn1.ivh_invoicenumber = invoiceheader.ivh_invoicenumber  and #temp_rtn1.ord_hdrnumber > 0
--END PTS 66553 SPN

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
--if @p_revtype1 <> 'UNK' OR @p_revtype2 <> 'UNK' OR @p_revtype3 <> 'UNK' OR @p_revtype4 <> 'UNK'
if (@p_revtype1 <> 'UNK' and @p_revtype1 <> '%') OR (@p_revtype2 <> 'UNK' and @p_revtype2 <> '%')  OR
  (@p_revtype3 <> 'UNK' and @p_revtype3 <> '%')  OR (@p_revtype4 <> 'UNK'  and @p_revtype4 <> '%')
 Begin

  if @p_revtype1 <> 'UNK' and @p_revtype1 <> '%'
   delete from #temp_rtn1
   where not exists (select 1 from orderheader o
        where #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
         --and isNull(o.ord_revtype1,'UNK') = @p_revtype1)
         and CHARINDEX( ',' + isNull(o.ord_revtype1,'UNK') + ',', @p_revtype1) > 0)

  if @p_revtype2 <> 'UNK' and @p_revtype2 <> '%'
   delete from #temp_rtn1
   where not exists (select 1 from orderheader o
        where #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
         --and isNull(o.ord_revtype2,'UNK') = @p_revtype2)
         and CHARINDEX( ',' + isNull(o.ord_revtype2,'UNK') + ',', @p_revtype2) > 0)

  if @p_revtype3 <> 'UNK' and @p_revtype3 <> '%'
   delete from #temp_rtn1
   where not exists (select 1 from orderheader o
        where #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
         --and isNull(o.ord_revtype3,'UNK') = @p_revtype3)
         and CHARINDEX( ',' + isNull(o.ord_revtype3,'UNK') + ',', @p_revtype3) > 0)

  if @p_revtype4 <> 'UNK' and @p_revtype4 <> '%'
   delete from #temp_rtn1
   where not exists (select 1 from orderheader o
        where #temp_rtn1.ord_hdrnumber = o.ord_hdrnumber
         --and isNull(o.ord_revtype4,'UNK') = @p_revtype4)
         and CHARINDEX( ',' + isNull(o.ord_revtype4,'UNK') + ',', @p_revtype4) > 0)
 end

--BEGIN PTS 66553 SPN
---- 01/21/2008 MDH PTS 40119: Added delete to clean up orders they should not see.
--DELETE FROM #temp_rtn1
--   WHERE ord_hdrnumber is not null and ord_hdrnumber <> 0
--      and not exists (select 1 from orderheader
--                  where #temp_rtn1.ord_hdrnumber = orderheader.ord_hdrnumber
--                  --PTS 38816 JJF 20080312 add additional needed parms
--                  --PTS 51570 JJF 20100510
--                  --and dbo.RowRestrictByUser(orderheader.ord_belongsto, '', '', '') = 1)
--                                  --BEGIN PTS 57093 SPN
--               -- AND dbo.RowRestrictByUser('orderheader', orderheader.rowsec_rsrv_id, '', '', '') = 1
--                                   AND ( (@rowsecurity <> 'Y')
--                                         OR EXISTS(SELECT 1
--                                                     FROM @tbl_restrictedbyuser rsva
--                                                    WHERE orderheader.rowsec_rsrv_id = rsva.rowsec_rsrv_id
--                                                       OR rsva.rowsec_rsrv_id = 0
--                                                  )
--                                       )
--                                  --END PTS 57093 SPN
--            )
--END PTS 66553 SPN

-- Restrict based on Invoice status requirement.
if isNull(@inv_status,',UNK,') <> ',UNK,' and @inv_status <> '%'
 delete from #temp_rtn1
 where not exists (select 1 from Invoiceheader i
  where #temp_rtn1.ord_hdrnumber = i.ord_hdrnumber
   and i.ord_hdrnumber > 0
   and (charindex(',' + isNull(i.ivh_invoicestatus,'UNK')+ ',',@inv_status) > 0
    OR charindex(',' + isNull(i.ivh_mbstatus,'NTP') + ',',@inv_status) > 0 ))

-- Restrict based on Invoice billto
--select @p_ivh_billto = isnull(@p_ivh_billto,'UNKNOWN')
--if isNull(@p_ivh_billto,'UNKNOWN') <> 'UNKNOWN'
if @p_ivh_billto <> ',UNKNOWN,' and @p_ivh_billto <> '%'
 delete from #temp_rtn1
 where not exists (select 1 from Invoiceheader i
      where #temp_rtn1.ord_hdrnumber = i.ord_hdrnumber
       and i.ord_hdrnumber > 0
       --and isnull(i.ivh_billto,'UNKNOWN') = @p_ivh_billto
       and CHARINDEX( ',' + isnull(i.ivh_billto,'UNKNOWN') + ',', @p_ivh_billto) > 0
       and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL') )

-- Restrict based on Invoice revtype1
--select @p_ivh_revtype1 = isnull(@p_ivh_revtype1,'UNK')
--if isNull(@p_ivh_revtype1,'UNK') <> 'UNK'
if @p_ivh_revtype1 <> ',UNK,' and @p_ivh_revtype1 <> '%'
 delete from #temp_rtn1
 where not exists (select 1 from Invoiceheader i
      where #temp_rtn1.ord_hdrnumber = i.ord_hdrnumber
       and i.ord_hdrnumber > 0
       --and isnull(i.ivh_revtype1,'UNK') = @p_ivh_revtype1
       and CHARINDEX( ',' + isnull(i.ivh_revtype1,'UNKNOWN') + ',', @p_ivh_revtype1) > 0
       and (i.ivh_definition='LH' or @stlmustinvLH = 'ALL') )

-- End 32781

----------------------------------------------------------------------------------------------------------
-- -- PTS 41389 GAP 74 (start)
--If exists (select * from generalinfo where gi_name = 'TrackBranch' and gi_string1 = 'Y')
--BEGIN
--  -- IF SPECIFIC THEN PULL THAT - IF UNKNOWN THEN PULL THE ONES ALLOWED FOR THE USER.

--  --IF @brn_id  = ',UNKNOWN,'
--  IF  @lgh_booked_revtype1  = ',UNKNOWN,'
--   begin
--    If exists (select * from generalinfo where gi_name = 'BRANCHUSERSECURITY' and gi_string1 = 'Y')
--    BEGIN
--     -- if branch security is ON then get data, else, DO NOT DELETE.
--     SELECT brn_id
--     INTO #temp_user_branch
--     FROM branch_assignedtype
--     WHERE bat_type = 'USERID'
--     and brn_id <> 'UNKNOWN'
--     AND bat_value  =  @G_USERID

--     -------select * from #temp_user_branch  ----------  DEBUG ~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

--     DELETE from #temp_rtn1 where lgh_booked_revtyep1 NOT IN (select brn_id from #temp_user_branch)
--    END
--   end
--   ELSE
--   begin
--    Delete from #temp_rtn1
--    where lgh_booked_revtyep1 in (select lgh_booked_revtyep1 from #temp_rtn1
--           where CHARINDEX(',' + lgh_booked_revtyep1 + ',', @lgh_booked_revtype1 ) = 0 )
--   end

--END
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

If @paperwork_received <> 0
 delete #temp_rtn1 where need_paperwork <> @paperwork_received

-- LOR PTS#30053
--if @sch_date1 > convert(datetime, '1950-01-01 00:00') OR
--      @sch_date2 < convert(datetime, '2049-12-31 23:59')
---- LOR PTS# 43728 changed stp_sequence to stp_mfh_sequence
-- SELECT t.lgh_number,
--   t.asgn_type,
--    t.asgn_id,
--    t.asgn_date,
--   t.asgn_enddate,
--   t.cmp_id_start,
--   t.cmp_id_end,
--   t.mov_number,
--    t.asgn_number,
--    t.ord_hdrnumber,
--    t.lgh_startcity,
--    t.lgh_endcity,
--   t.ord_number,
--   t.name,
--   t.cmp_name_start,
--   t.cmp_name_end,
--   t.cty_nmstct_start,
--   t.cty_nmstct_end,
--   t.need_paperwork,
--   t.ivh_revtype1,
--   t.revtype1_name,
--   t.lgh_split_flag,
--   t.trip_description,
--   t.lgh_type1,
--   t.lgh_type_name,
--   t.ivh_billdate,
--   t.ivh_invoicenumber,
--   t.lgh_booked_revtyep1,
--   t.asgn_controlling,
--   t.lgh_shiftdate, --vjh 33665
--   t.lgh_shiftnumber, --vjh 33665
--   t.stp_schdtearliest, -- PTS 47740
--   t.ord_route,   -- PTS 47740
--   t.cost,     -- PTS 47740
--   t.ord_revtype1,   -- PTS 47740
--   t.ord_revtype1_name, -- PTS 47740
--   t.ord_revtype2,   -- PTS 47740
--   t.ord_revtype2_name, -- PTS 47740
--   t.ord_revtype3,   -- PTS 47740
--   t.ord_revtype3_name, -- PTS 47740
--   t.ord_revtype4,   -- PTS 47740
--   t.ord_revtype4_name  -- PTS 47740
-- FROM #temp_rtn1 t, stops
-- where t.lgh_number = stops.lgh_number and
--   stops.stp_mfh_sequence = 1 and
--   stops.stp_schdtearliest between @sch_date1 and @sch_date2
-- ORDER BY t.asgn_type, t.asgn_id, t.asgn_date, t.mov_number,t.lgh_number
--Else
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
   --t.trip_description,
   dbo.tmwf_scroll_assignments_concat_new(mov_number),
   t.lgh_type1,
   t.lgh_type_name,
   t.ivh_billdate,
   t.ivh_invoicenumber,
   t.lgh_booked_revtyep1,
   t.ivh_billto,
   t.asgn_controlling,
   t.lgh_shiftdate, --vjh 33665
   t.lgh_shiftnumber, --vjh 33665
   t.stp_schdtearliest, -- PTS 47740
   t.ord_route,   -- PTS 47740
   t.cost,     -- PTS 47740
   t.ord_revtype1,   -- PTS 47740
   t.ord_revtype1_name, -- PTS 47740
   t.ord_revtype2,   -- PTS 47740
   t.ord_revtype2_name, -- PTS 47740
   t.ord_revtype3,   -- PTS 47740
   t.ord_revtype3_name, -- PTS 47740
   t.ord_revtype4,   -- PTS 47740
   t.ord_revtype4_name  -- PTS 47740
       , 'N' AS 'cc_selected'  -- PTS 60458 /needed for R_to_PH feature
       , 0   AS 'cc_processed' -- PTS 60458 /needed for R_to_PH feature
FROM #temp_rtn1 t
 ORDER BY asgn_type, asgn_id, asgn_date, mov_number,lgh_number

--DROP TABLE @temp_rtn

GO
GRANT EXECUTE ON  [dbo].[D_SCROLL_ASSIGNMENTS_forviews_SP] TO [public]
GO
