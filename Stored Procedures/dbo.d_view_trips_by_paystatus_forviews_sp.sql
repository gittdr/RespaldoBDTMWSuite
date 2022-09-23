SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_view_trips_by_paystatus_forviews_sp] (
   @status varchar(6),
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

SET NOCOUNT ON

/**
-- PTS 63566 Add asgn_date to #trips so  @lostartdate/@histartdate parameters can be used.	)
-- PTS 63566 Add identity col to #trips table.
-- PTS 63566  Carrier Name in core is x(64) &  drivername is varchar(45);  increase drivername to 80 but truncate it back to 45 for result set.
-- PTS 63566: IF INI ShowStartDateRestriction=N  then 'trips ending' come in as @lostartdate/@histartdate
-- PTS 63566: IF INI ShowStartDateRestriction=Y  then 'trips ending' come in as @lostartdate/@histartdate and 
--													  'trips STARTING' come in as @loenddate / @hienddate  
**/

declare @drvyes varchar(3),
   @trcyes varchar(3),
   @caryes varchar(3),
   @trlyes varchar(3),
   @tpryes varchar(3),
--@types varchar(15),
 --@lostartdate datetime,
 --@histartdate datetime,
 --@loenddate datetime,
 --@hienddate datetime,
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
   @driver varchar(255),      --20
   @tractor varchar(255),
   @acct_typ char(1),
   @carrier varchar(255),
   @cartyp1 varchar(255),
   @cartyp2 varchar(255),    --25
   @cartyp3 varchar(255),
   @cartyp4 varchar(255),
 @trailer varchar(255),
   @trltyp1 varchar(255),  --30
   @trltyp2 varchar(255),
   @trltyp3 varchar(255),
   @trltyp4 varchar(255),
 @lgh_type1 varchar(255),
--@beg_invoice_bill_date datetime,
--@end_invoice_bill_date datetime,
--@sch_date1 datetime,
--@sch_date2 datetime,
@tpr_id varchar(255),
   @tpr_type varchar(255),
@p_revtype1 varchar(255),
   @p_revtype2 varchar(255),
   @p_revtype3 varchar(255), --45
   @p_revtype4 varchar(255),
   @inv_status varchar(255),
 --   @tprtype1 char(1),
   --@tprtype2 char(1),
   --@tprtype3 char(1),
   --@tprtype4 char(1),
   --@tprtype5 char(1),
   --@tprtype6 char(1),
--@brn_id varchar(256),     -- PTS 41389 GAP 74
--@G_USERID varchar(14),   -- PTS 41389 GAP 74
@p_ivh_billto varchar(255),   -- PTS 46402
--@p_pyd_workcycle_status varchar(30), -- PTS 47021
--@resourcetypeonleg char(1)
@view_type  varchar(6)

-- PTS 41389 GAP 74 Start
--IF @brn_id = NULL or @brn_id = '' or @brn_id  = 'UNK'
-- begin
--    SELECT @brn_id = 'UNKNOWN'
-- end

--SELECT @brn_id = ',' + LTRIM(RTRIM(ISNULL(@brn_id, '')))  + ','
-- PTS 41389 GAP 74 end


Declare @paperworkchecklevel varchar(6),
 @paperworkmode varchar(3),
 @agent varchar(3),
 @usearrivaldate char(1) -- PTS 35646

--BEGIN PTS 63020 SPN - Unused restrictions
DECLARE @lgh_booked_revtype1  VARCHAR(255)
DECLARE @paperwork_received   INT
DECLARE @bov_ivh_rev_type1    VARCHAR(255)
--END PTS 63020 SPN

--BEGIN PTS 65645 SPN
DECLARE @mpp_branch    VARCHAR(255)
DECLARE @trc_branch    VARCHAR(255)
DECLARE @trl_branch    VARCHAR(255)
DECLARE @car_branch    VARCHAR(255)
--END PTS 65645 SPN


 -- PTS 63566.start
CREATE TABLE #tmpAsgnNbrAsgnDate (	v_ident_count int null,
									asgn_number int null, 									
									lgh_number	int null,									
									asgn_date	datetime null,  
									asgn_type	varchar(6) null,		
									asgn_id		varchar(13) null )									
-- PTS 63566.end 

-- PTS 63566 Add identity col to #trips table.
CREATE TABLE #trips (v_ident_count INT Identity,
 mov_number int null,
 o_cty_nmstct varchar(25) null,
 d_cty_nmstct varchar(25) null,
 lgh_startdate datetime null,
 lgh_enddate datetime null,
 ord_originpoint varchar(8) null,
 ord_destpoint varchar(8) null,
 ord_startdate datetime null,
 ord_completiondate datetime null,
 asgn_id varchar(13) null,    --PTS 19738 - FJM
 asgn_type varchar(6) null,
 asgn_number int null,
 ord_hdrnumber int null,
 ord_number varchar(12) null,
 pyh_payperiod datetime null,
 pyd_workperiod datetime null,
 pyd_transferdate datetime null,
 psd_id int null,
 pyh_number int null,
 pyd_status varchar(6) null,
 pyd_transdate datetime null,
 lgh_number int null,
 --drivername varchar(45) null,
  drivername varchar(80) null,	--PTS 63566  increase to 80 char from 45
 paperwork smallint null,
 lgh_type1 varchar(6) null,
-- PTS 16945 -- BL
ivh_billdate datetime Null,
ivh_invoicenumber varchar(12) Null,
--PTS 19038 RE
pyt_itemcode varchar(6) Null,
pyd_authcode varchar(30) Null,
pyd_number     int         null, -- 28117 JD
ord_revtype1   varchar(6)  null,
ord_revtype2   varchar(6)  null,
ord_revtype3   varchar(6)  null,
ord_revtype4   varchar(6)  null,
lgh_booked_revtype1 varchar(20) null,  -- PTS 41389  GAP 74
asgn_controlling varchar(1) null,
pyd_workcycle_status varchar(30) null,    -- PTS 47021
pyd_prorap char(1)   null,             -- PTS 47021
stp_schdtearliest datetime Null, -- PTS 47740 - 50169
ord_route varchar(18) Null,         -- PTS 47740 - 50169
Cost money Null,              -- PTS 47740 - 50169
ord_revtype1_name varchar(20) Null, -- PTS 47740 - 50169
ord_revtype2_name varchar(20) Null, -- PTS 47740 - 50169
ord_revtype3_name varchar(20) Null, -- PTS 47740 - 50169
ord_revtype4_name varchar(20) Null  -- PTS 47740 - 50169
)

If @status = 'HLD'
   select @view_type = 'SOH'
Else
   If @status = 'AUD'
   select @view_type = 'SA'

--BEGIN PTS 63020 SPN
--select @p_ivh_billto = case isNull(rtrim(bov_billto), '')
--                      when '' then '%'
--                      when 'UNKNOWN' then '%'
--                      else (',' + bov_billto + ',')
--                   end,
-- --@lgh_booked_revtype1 = case isNull(rtrim(bov_booked_revtype1), '')
-- --                   when '' then '%'
-- --                   when 'UNKNOWN' then '%'
-- --                   else (',' + bov_booked_revtype1 + ',')
-- --                end,
-- @p_revtype1 = case isNull(rtrim(bov_rev_type1), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_rev_type1 + ',')
--                   end,
-- @p_revtype2 = case isNull(rtrim(bov_rev_type2), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_rev_type2 + ',')
--                   end,
-- @p_revtype3 = case isNull(rtrim(bov_rev_type3), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_rev_type3 + ',')
--                   end,
-- @p_revtype4 = case isNull(rtrim(bov_rev_type4), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_rev_type4 + ',')
--                   end,
-- @lgh_type1 = case isNull(rtrim(bov_lgh_type1), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_lgh_type1 + ',')
--                   end,
-- --[bov_paperwork_received] varchar(2) NULL,     -- Y/N/NA
-- @company = case isNull(rtrim(bov_company), '')
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
-- @drvtyp1 = case isNull(rtrim(bov_mpp_type1), '')
--                      when '' then '%'
--                      else (',' + bov_mpp_type1 + ',')
--                   end ,
-- @drvtyp2 = case isNull(rtrim(bov_mpp_type2), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_mpp_type2 + ',')
--                   end ,
-- @drvtyp3 = case isNull(rtrim(bov_mpp_type3), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_mpp_type3 + ',')
--                   end ,
-- @drvtyp4 = case isNull(rtrim(bov_mpp_type4), '')
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
-- @trctyp1 = case isNull(rtrim(bov_trc_type1), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trc_type1 + ',')
--                   end ,
-- @trctyp2 = case isNull(rtrim(bov_trc_type2), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trc_type2 + ',')
--                   end ,
-- @trctyp3 = case isNull(rtrim(bov_trc_type3), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trc_type3 + ',')
--                   end ,
-- @trctyp4 = case isNull(rtrim(bov_trc_type4), '')
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
-- @trltyp1 = case isNull(rtrim(bov_trl_type1), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trl_type1 + ',')
--                   end ,
-- @trltyp2 = case isNull(rtrim(bov_trl_type2), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trl_type2 + ',')
--                   end ,
-- @trltyp3 = case isNull(rtrim(bov_trl_type3), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_trl_type3 + ',')
--                   end ,
-- @trltyp4 = case isNull(rtrim(bov_trl_type4), '')
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
-- @cartyp1 = case isNull(rtrim(bov_car_type1), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_car_type1 + ',')
--                   end ,
-- @cartyp2 = case isNull(rtrim(bov_car_type2), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_car_type2 + ',')
--                   end ,
-- @cartyp3 = case isNull(rtrim(bov_car_type3), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_car_type3 + ',')
--                   end ,
-- @cartyp4 = case isNull(rtrim(bov_car_type4), '')
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
--                   end ,
-- @inv_status = case isNull(rtrim(bov_inv_status), '')
--                      when '' then '%'
--                      when 'UNK' then '%'
--                      else (',' + bov_inv_status + ',')
--                   end
-- from backofficeview
-- where bov_id = @view_id and bov_type = @view_type
   --PTS 65645 SPN - added @mpp_branch, @trc_branch, @trl_branch and @car_branch
   EXEC dbo.backofficeview_get_sp
                         @bov_type               = @view_type
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

--select @inv_status = '%'
---- PTS 3223781 - DJM
--SELECT @inv_status = ',' + LTRIM(RTRIM(ISNULL(@inv_status, 'UNK'))) + ','

Create index #idx_ord on #trips(ord_hdrnumber)

-- PTS 55221
CREATE TABLE #requiredpaperwork (
   ord_hdrnumber INT NULL ,
   lgh_number INT NULL ,
   abbr VARCHAR(6) NULL )

SELECT @paperworkchecklevel = ISNULL( ( SELECT gi_string1 FROM generalinfo WHERE upper(gi_name) = 'PAPERWORKCHECKLEVEL' ), 'ORD' )
SELECT @paperworkmode = ISNULL( ( SELECT gi_string1 FROM generalinfo WHERE upper(gi_name) = 'PAPERWORKMODE' ), 'A' )
-- PTS 21386 -- BL (end)

-- PTS 35646 - SLM 1/31/07
SELECT @usearrivaldate = gi_string1 from generalinfo where upper(gi_name) = 'USEARRIVALDATE'

-- GET DRIVER DATA IF NEEDED
--IF SUBSTRING(@types, 1, 3) = 'DRV'
IF @drvyes <> 'XXX'
BEGIN
       INSERT INTO #trips
       SELECT DISTINCT pd.mov_number,
         lh.lgh_startcty_nmstct,
         lh.lgh_endcty_nmstct,
         lh.lgh_startdate,
         lh.lgh_enddate,
         oh.ord_originpoint,
         oh.ord_destpoint,
         oh.ord_startdate,
         oh.ord_completiondate,
         pd.asgn_id,
         pd.asgn_type,
         pd.asgn_number,
         pd.ord_hdrnumber,
         oh.ord_number,
         pd.pyh_payperiod,
         pd.pyd_workperiod,
         pd.pyd_transferdate,
         pd.psd_id,
         pd.pyh_number,
         pd.pyd_status,
         pd.pyd_transdate,
         pd.lgh_number,
         null , -- mp.mpp_lastfirst,
         0,
         lh.lgh_type1,
         null,
         null,
         pd.pyt_itemcode,
         pd.pyd_authcode,
         pd.pyd_number ,
         oh.ord_revtype1,
         oh.ord_revtype2,
         oh.ord_revtype3,
         oh.ord_revtype4,
         lh.lgh_booked_revtype1, -- PTS 41389 GAP 74
         asgn_controlling = (select asgn_controlling from assetassignment aa where pd.asgn_number = aa.asgn_number),
         pd.pyd_workcycle_status,                  -- PTS 47021
         pyd_prorap,                                -- PTS 47021

         (SELECT stp_schdtearliest FROM stops WHERE stp_number =
            (SELECT min(stp_number) from stops where ord_hdrnumber = oh.ord_hdrnumber and stp_mfh_sequence =
            (select min(stp_mfh_sequence) from stops where ord_hdrnumber = oh.ord_hdrnumber))) stp_schdtearliest,
         (SELECT orderheader.ord_route FROM orderheader
                WHERE orderheader.ord_hdrnumber = oh.ord_hdrnumber) ord_route,
         cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name
         -- PTS 47740 <<end>>
  FROM paydetail pd
      Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
      Join legheader lh on pd.lgh_number = lh.lgh_number
      --BEGIN PTS 65645 SPN
      JOIN assetassignment aa ON pd.asgn_number = aa.asgn_number AND aa.pyd_status = 'PPD'
      LEFT OUTER JOIN manpowerprofile mpp ON pd.asgn_type = 'DRV' AND pd.asgn_id = mpp.mpp_id
      --END PTS 65645 SPN
  WHERE pd.asgn_type = 'DRV'
    AND pd.pyd_status = @status
    AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
    AND ((@acct_typ = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_typ = pd.pyd_prorap))
    --BEGIN PTS 65645 SPN
   --AND exists (select * from assetassignment aa where pd.asgn_number = aa.asgn_number  AND aa.pyd_status = 'PPD')
    --END PTS 65645 SPN
    AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null)   -- 11/29/2007 MDH PTS 40119: Added
    --BEGIN PTS 65645 SPN
    AND (   @mpp_branch = '%'
         OR ( @resourcetypeonleg = 'Y'  AND CHARINDEX( ',' + IsNull(aa.asgn_branch, 'UNKNOWN') + ',', @mpp_branch) > 0 )
         OR ( @resourcetypeonleg <> 'Y' AND CHARINDEX( ',' + IsNull(mpp.mpp_branch, 'UNKNOWN') + ',', @mpp_branch) > 0 )
        )
    --END PTS 65645 SPN

   --IF @driver <> ',UNKNOWN'
   IF @driver <> ',UNKNOWN,' and @driver <> '%'
      delete #trips  where asgn_type = 'DRV' and
                     --asgn_id <> @driver
                     CHARINDEX( ',' + asgn_id + ',', @driver) <= 0
   --IF @company <> 'UNK'
   IF @company <> ',UNK,' and @company <> '%'
      delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and
                                       --mpp_company <> @company
                                       CHARINDEX( ',' + mpp_company + ',', @company) <= 0
   --IF @fleet <> 'UNK'
   IF @fleet <> ',UNK,' and @fleet <> '%'
      delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and
                                       --mpp_fleet <> @fleet
                                       CHARINDEX( ',' + mpp_fleet + ',', @fleet) <= 0
   --IF @division <> 'UNK'
   IF @division <> ',UNK,' and @division <> '%'
      delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and
                                       --mpp_division <> @division
                                       CHARINDEX( ',' + mpp_division + ',', @division) <= 0
   --IF @terminal <> 'UNK'
   IF @terminal <> ',UNK,' and @terminal <> '%'
      delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and
                                       --mpp_terminal <> @terminal
                                       CHARINDEX( ',' + mpp_terminal + ',', @terminal) <= 0

--PTS 48237 - DJM
   if @resourcetypeonleg = 'Y'
      Begin
         --IF @drvtyp1 <> 'UNK'
         IF @drvtyp1 <> ',UNK,' and @drvtyp1 <> '%'
            delete #trips from legheader l where asgn_type = 'DRV' and l.lgh_number = #trips.lgh_number and
                                       isNull(#trips.lgh_number,0) > 0 and
                                       --l.mpp_type1 <> @drvtyp1
                                       CHARINDEX( ',' + l.mpp_type1 + ',', @drvtyp1) <= 0
         --IF @drvtyp2 <> 'UNK'
         IF @drvtyp2 <> ',UNK,' and @drvtyp2 <> '%'
            delete #trips from legheader l where asgn_type = 'DRV' and l.lgh_number = #trips.lgh_number and
                                       isNull(#trips.lgh_number,0) > 0 and
                                       --l.mpp_type2 <> @drvtyp2
                                       CHARINDEX( ',' + l.mpp_type2 + ',', @drvtyp2) <= 0
         --IF @drvtyp3 <> 'UNK'
         IF @drvtyp3 <> ',UNK,' and @drvtyp3 <> '%'
            delete #trips from legheader l where asgn_type = 'DRV' and l.lgh_number = #trips.lgh_number and
                                       isNull(#trips.lgh_number,0) > 0 and
                                       --l.mpp_type3 <> @drvtyp3
                                       CHARINDEX( ',' + l.mpp_type3 + ',', @drvtyp3) <= 0
         --IF @drvtyp4 <> 'UNK'
         IF @drvtyp4 <> ',UNK,' and @drvtyp4 <> '%'
            delete #trips from legheader l where asgn_type = 'DRV' and l.lgh_number = #trips.lgh_number and
                                       isNull(#trips.lgh_number,0) > 0 and
                                       --l.mpp_type4 <> @drvtyp4
                                       CHARINDEX( ',' + l.mpp_type4 + ',', @drvtyp4) <= 0
      End
   else
      Begin
         --IF @drvtyp1 <> 'UNK'
         IF @drvtyp1 <> ',UNK,' and @drvtyp1 <> '%'
            delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and
                                             --mpp_type1 <> @drvtyp1
                                             CHARINDEX( ',' + mpp_type1 + ',', @drvtyp1) <= 0
         --IF @drvtyp2 <> 'UNK'
         IF @drvtyp2 <> ',UNK,' and @drvtyp2 <> '%'
            delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and
                                             --mpp_type2 <> @drvtyp2
                                             CHARINDEX( ',' + mpp_type2 + ',', @drvtyp2) <= 0
         --IF @drvtyp3 <> 'UNK'
         IF @drvtyp3 <> ',UNK,' and @drvtyp3 <> '%'
            delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and
                                             --mpp_type3 <> @drvtyp3
                                             CHARINDEX( ',' + mpp_type3 + ',', @drvtyp3) <= 0
         --IF @drvtyp4 <> 'UNK'
         IF @drvtyp4 <> ',UNK,' and @drvtyp4 <> '%'
            delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and
                                             --mpp_type4 <> @drvtyp4
                                             CHARINDEX( ',' + mpp_type4 + ',', @drvtyp4) <= 0
      end

   Update #trips set drivername = mpp_lastfirst from manpowerprofile where asgn_type = 'DRV' and asgn_id = mpp_id

END -- end driver

-- GET TRACTOR DATA IF NEEDED
--IF SUBSTRING(@types, 4, 3) = 'TRC'
IF @trcyes <> 'XXX'
BEGIN
       INSERT INTO #trips
       SELECT DISTINCT pd.mov_number,
              lh.lgh_startcty_nmstct,
              lh.lgh_endcty_nmstct,
              lh.lgh_startdate,
              lh.lgh_enddate,
              oh.ord_originpoint,
              oh.ord_destpoint,
              oh.ord_startdate,
              oh.ord_completiondate,
              pd.asgn_id,
              pd.asgn_type,
              pd.asgn_number,
              pd.ord_hdrnumber,
              oh.ord_number,
              pd.pyh_payperiod,
              pd.pyd_workperiod,
              pd.pyd_transferdate,
              pd.psd_id,
              pd.pyh_number,
              pd.pyd_status,
              pd.pyd_transdate,
              pd.lgh_number,
           null,--        tp.trc_make + ', ' + tp.trc_model,
-- PTS 21386 -- BL (start)
--              -1,
      0,
-- PTS 21386 -- BL (end)
       lh.lgh_type1,
      null,
      null,
      pd.pyt_itemcode,
      pd.pyd_authcode,
      pd.pyd_number ,
         oh.ord_revtype1,
         oh.ord_revtype2,
         oh.ord_revtype3,
         oh.ord_revtype4,
         lh.lgh_booked_revtype1, -- PTS 41389 GAP 74
      asgn_controlling = (select asgn_controlling from assetassignment aa where pd.asgn_number = aa.asgn_number),
      pd.pyd_workcycle_status,                  -- PTS 47021
      pyd_prorap,                                -- PTS 47021

      (SELECT stp_schdtearliest FROM stops WHERE stp_number =
         (SELECT min(stp_number) from stops where ord_hdrnumber = oh.ord_hdrnumber and stp_mfh_sequence =
         (select min(stp_mfh_sequence) from stops where ord_hdrnumber = oh.ord_hdrnumber))) stp_schdtearliest,
      (SELECT orderheader.ord_route FROM orderheader
             WHERE orderheader.ord_hdrnumber = oh.ord_hdrnumber) ord_route,
      cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name
   -- PTS 47740 <<end>>

  FROM paydetail pd
      Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
      Join legheader lh on pd.lgh_number = lh.lgh_number
      --BEGIN PTS 65645 SPN
      JOIN assetassignment aa ON pd.asgn_number = aa.asgn_number AND aa.pyd_status = 'PPD'
      LEFT OUTER JOIN tractorprofile trc on pd.asgn_type = 'TRC' AND pd.asgn_id = trc.trc_number
      --END PTS 65645 SPN
  WHERE pd.asgn_type = 'TRC'
    AND pd.pyd_status = @status
    AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate  -- JD 32041 make the tractor trans date restrictions match the other dates.
    AND ((@acct_typ = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_typ = pd.pyd_prorap))
    --BEGIN PTS 65645 SPN
    --AND exists (select * from assetassignment aa where pd.asgn_number = aa.asgn_number  AND aa.pyd_status = 'PPD')
    --END PTS 65645 SPN
    AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null)   -- 11/29/2007 MDH PTS 40119: Added
    --BEGIN PTS 65645 SPN
    AND (   @trc_branch = '%'
         OR ( @resourcetypeonleg = 'Y'  AND CHARINDEX( ',' + IsNull(aa.asgn_branch, 'UNKNOWN') + ',', @trc_branch) > 0 )
         OR ( @resourcetypeonleg <> 'Y' AND CHARINDEX( ',' + IsNull(trc.trc_branch, 'UNKNOWN') + ',', @trc_branch) > 0 )
        )
    --END PTS 65645 SPN

   --IF @tractor <> 'UNKNOWN'
   IF @tractor <> ',UNKNOWN,' and @tractor <> '%'
      delete #trips  where asgn_type = 'TRC' and
                     --asgn_id <> @tractor
                     CHARINDEX( ',' + asgn_id + ',', @tractor) <= 0
   --IF @company <> 'UNK'
   IF @company <> ',UNK,' and @company <> '%'
      delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and
                                    --trc_company <> @company
                                    CHARINDEX( ',' + trc_company + ',', @company) <= 0
   --IF @fleet <> 'UNK'
   IF @fleet <> ',UNK,' and @fleet <> '%'
      delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and
                                    --trc_fleet <> @fleet
                                    CHARINDEX( ',' + trc_fleet + ',', @fleet) <= 0
   --IF @division <> 'UNK'
   IF @division <> ',UNK,' and @division <> '%'
      delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and
                                    --trc_division <> @division
                                    CHARINDEX( ',' + trc_division + ',', @division) <= 0
   --IF @terminal <> 'UNK'
   IF @terminal <> ',UNK,' and @terminal <> '%'
      delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and
                                    --trc_terminal <> @terminal
                                    CHARINDEX( ',' + trc_terminal + ',', @terminal) <= 0
--PTS 48237 - DJM
   if @resourcetypeonleg = 'Y'
      Begin
         --IF @trctyp1 <> 'UNK'
         IF @trctyp1 <> ',UNK,' and @trctyp1 <> '%'
            delete #trips from legheader l where asgn_type = 'TRC' and l.lgh_number = #trips.lgh_number and
                                       isNull(#trips.lgh_number,0) > 0 and
                                       --l.trc_type1 <> @trctyp1
                                       CHARINDEX( ',' + l.trc_type1 + ',', @trctyp1) <= 0
         --IF @trctyp2 <> 'UNK'
         IF @trctyp2 <> ',UNK,' and @trctyp2 <> '%'
            delete #trips from legheader l where asgn_type = 'TRC' and l.lgh_number = #trips.lgh_number and
                                       isNull(#trips.lgh_number,0) > 0 and
                                       --l.trc_type2 <> @trctyp2
                                       CHARINDEX( ',' + l.trc_type2 + ',', @trctyp2) <= 0
         --IF @trctyp3 <> 'UNK'
         IF @trctyp3 <> ',UNK,' and @trctyp3 <> '%'
            delete #trips from legheader l where asgn_type = 'TRC' and l.lgh_number = #trips.lgh_number and
                                       isNull(#trips.lgh_number,0) > 0 and
                                       --l.trc_type3 <> @trctyp3
                                       CHARINDEX( ',' + l.trc_type3 + ',', @trctyp3) <= 0
         --IF @trctyp4 <> 'UNK'
         IF @trctyp4 <> ',UNK,' and @trctyp4 <> '%'
            delete #trips from legheader l where asgn_type = 'TRC' and l.lgh_number = #trips.lgh_number and
                                       isNull(#trips.lgh_number,0) > 0 and
                                       --l.trc_type4 <> @trctyp4
                                       CHARINDEX( ',' + l.trc_type4 + ',', @trctyp4) <= 0
      end
   else
      Begin
         --IF @trctyp1 <> 'UNK'
         IF @trctyp1 <> ',UNK,' and @trctyp1 <> '%'
            delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and
                                             --trc_type1 <> @trctyp1
                                             CHARINDEX( ',' + trc_type1 + ',', @trctyp1) <= 0

         --IF @trctyp2 <> 'UNK'
         IF @trctyp2 <> ',UNK,' and @trctyp2 <> '%'
            delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and
                                             --trc_type2 <> @trctyp2
                                             CHARINDEX( ',' + trc_type2 + ',', @trctyp2) <= 0
         --IF @trctyp3 <> 'UNK'
         IF @trctyp3 <> ',UNK,' and @trctyp3 <> '%'
            delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and
                                             --trc_type3 <> @trctyp3
                                             CHARINDEX( ',' + trc_type3 + ',', @trctyp3) <= 0
         --IF @trctyp4 <> 'UNK'
         IF @trctyp4 <> ',UNK,' and @trctyp4 <> '%'
            delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and
                                             --trc_type4 <> @trctyp4
                                             CHARINDEX( ',' + trc_type4 + ',', @trctyp4) <= 0
      end

   update #trips set drivername = trc_make + ', ' + trc_model from tractorprofile where asgn_type = 'TRC' and asgn_id = trc_number

END -- END TRC


-- GET TRAILER DATA IF NEEDED
--IF SUBSTRING(@types, 7, 3) = 'TRL'
IF @trlyes <> 'XXX'
BEGIN
       INSERT INTO #trips
       SELECT DISTINCT pd.mov_number,
              lh.lgh_startcty_nmstct,
              lh.lgh_endcty_nmstct,
              lh.lgh_startdate,
              lh.lgh_enddate,
              oh.ord_originpoint,
              oh.ord_destpoint,
              oh.ord_startdate,
              oh.ord_completiondate,
              pd.asgn_id,
              pd.asgn_type,
              pd.asgn_number,
              pd.ord_hdrnumber,
              oh.ord_number,
              pd.pyh_payperiod,
              pd.pyd_workperiod,
              pd.pyd_transferdate,
              pd.psd_id,
              pd.pyh_number,
              pd.pyd_status,
              pd.pyd_transdate,
              pd.lgh_number,
              null, --tp.trl_make + ', ' + tp.trl_model,
-- PTS 21386 -- BL (start)
--              -1,
      0,
-- PTS 21386 -- BL (end)
       lh.lgh_type1,
      null,
      null,
      pd.pyt_itemcode,
      pd.pyd_authcode,
      pd.pyd_number ,
         oh.ord_revtype1,
         oh.ord_revtype2,
         oh.ord_revtype3,
         oh.ord_revtype4,
         lh.lgh_booked_revtype1, -- PTS 41389 GAP 74
      asgn_controlling = (select asgn_controlling from assetassignment aa where pd.asgn_number = aa.asgn_number),
      pd.pyd_workcycle_status,                  -- PTS 47021
      pyd_prorap,                                -- PTS 47021
      -- PTS 47740 - 50169 <<start>>
      -- MRH 35366
      (SELECT stp_schdtearliest FROM stops WHERE stp_number =
         (SELECT min(stp_number) from stops where ord_hdrnumber = oh.ord_hdrnumber and stp_mfh_sequence =
         (select min(stp_mfh_sequence) from stops where ord_hdrnumber = oh.ord_hdrnumber))) stp_schdtearliest,
      (SELECT orderheader.ord_route FROM orderheader
             WHERE orderheader.ord_hdrnumber = oh.ord_hdrnumber) ord_route,
      cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name
   -- PTS 47740 <<end>>

  FROM paydetail pd
      Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
      Join legheader lh on pd.lgh_number = lh.lgh_number
      --BEGIN PTS 65645 SPN
      JOIN assetassignment aa ON pd.asgn_number = aa.asgn_number AND aa.pyd_status = 'PPD'
      LEFT OUTER JOIN trailerprofile trl ON pd.asgn_type = 'TRL' AND pd.asgn_id = trl.trl_id
      --END PTS 65645 SPN
  WHERE pd.asgn_type = 'TRL'
    AND pd.pyd_status = @status
    AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
    AND ((@acct_typ = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_typ = pd.pyd_prorap))
    --BEGIN PTS 65645 SPN
    --AND exists (select * from assetassignment aa where pd.asgn_number = aa.asgn_number  AND aa.pyd_status = 'PPD')
    --END PTS 65645 SPN
    AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null)   -- 11/29/2007 MDH PTS 40119: Added
    --BEGIN PTS 65645 SPN
    AND (   @trl_branch = '%'
         OR ( @resourcetypeonleg = 'Y'  AND CHARINDEX( ',' + IsNull(aa.asgn_branch, 'UNKNOWN') + ',', @trl_branch) > 0 )
         OR ( @resourcetypeonleg <> 'Y' AND CHARINDEX( ',' + IsNull(trl.trl_branch, 'UNKNOWN') + ',', @trl_branch) > 0 )
        )
    --END PTS 65645 SPN

   --IF @trailer <> 'UNKNOWN'
   IF @trailer <> ',UNKNOWN,' and @trailer <> '%'
      delete #trips  where asgn_type = 'TRL' and
                     --asgn_id <> @trailer
                     CHARINDEX( ',' + asgn_id + ',', @trailer) <= 0
   --IF @company <> 'UNK'
   IF @company <> ',UNK,' and @company <> '%'
      delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and
                                       --trl_company <> @company
                                       CHARINDEX( ',' + trl_company + ',', @company) <= 0
   --IF @fleet <> 'UNK'
   IF @fleet <> ',UNK,' and @fleet <> '%'
      delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and
                                       --trl_fleet <> @fleet
                                       CHARINDEX( ',' + trl_fleet + ',', @fleet) <= 0
   --IF @division <> 'UNK'
   IF @division <> ',UNK,' and @division <> '%'
      delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and
                                       --trl_division <> @division
                                       CHARINDEX( ',' + trl_division + ',', @division) <= 0
   --IF @terminal <> 'UNK'
   IF @terminal <> ',UNK,' and @terminal <> '%'
      delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and
                                       --trl_terminal <> @terminal
                                       CHARINDEX( ',' + trl_terminal + ',', @terminal) <= 0
   --IF @trltyp1 <> 'UNK'
   IF @trltyp1 <> ',UNK,' and @trltyp1 <> '%'
      delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and
                                       --trl_type1 <> @trltyp1
                                       CHARINDEX( ',' + trl_type1 + ',', @trltyp1) <= 0
   --IF @trltyp2 <> 'UNK'
   IF @trltyp2 <> ',UNK,' and @trltyp2 <> '%'
      delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and
                                       --trl_type2 <> @trltyp2
                                       CHARINDEX( ',' + trl_type2 + ',', @trltyp2) <= 0
   --IF @trltyp3 <> 'UNK'
   IF @trltyp3 <> ',UNK,' and @trltyp3 <> '%'
      delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and
                                       --trl_type3 <> @trltyp3
                                       CHARINDEX( ',' + trl_type3 + ',', @trltyp3) <= 0
   --IF @trltyp4 <> 'UNK'
   IF @trltyp4 <> ',UNK,' and @trltyp4 <> '%'
      delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and
                                       --trl_type4 <> @trltyp4
                                       CHARINDEX( ',' + trl_type4 + ',', @trltyp4) <= 0

   Update #trips set drivername = trl_make + ', ' + trl_model from trailerprofile where asgn_type = 'TRL' and asgn_id = trl_id

END

-- GET CARRIER DATA IF NEEDED
--IF SUBSTRING(@types, 10, 3) = 'CAR'
IF @caryes <> 'XXX'
BEGIN
   --PTS 35646 SLM 2/20/2007
   IF upper(right(@usearrivaldate,1)) = 'Y'
   BEGIN

          INSERT INTO #trips
          SELECT DISTINCT pd.mov_number,
                 lh.lgh_startcty_nmstct,
                 lh.lgh_endcty_nmstct,
                 lh.lgh_startdate,
                 lh.lgh_enddate,
                 oh.ord_originpoint,
                 oh.ord_destpoint,
                 oh.ord_startdate,
                 oh.ord_completiondate,
                 pd.asgn_id,
                 pd.asgn_type,
                 pd.asgn_number,
                 pd.ord_hdrnumber,
                 oh.ord_number,
                 pd.pyh_payperiod,
                 pd.pyd_workperiod,
                 pd.pyd_transferdate,
                 pd.psd_id,
                 pd.pyh_number,
                 pd.pyd_status,
                 pd.pyd_transdate,
                 pd.lgh_number,
                 null, --cr.car_name,
   -- PTS 21386 -- BL (start)
   --              -1,
         0,
   -- PTS 21386 -- BL (end)
          lh.lgh_type1,
         null,
         null,
         pd.pyt_itemcode,
         pd.pyd_authcode,
         pd.pyd_number ,
            oh.ord_revtype1,
            oh.ord_revtype2,
            oh.ord_revtype3,
            oh.ord_revtype4,
            lh.lgh_booked_revtype1, -- PTS 41389 GAP 74
         asgn_controlling = (select asgn_controlling from assetassignment aa where pd.asgn_number = aa.asgn_number),
         pd.pyd_workcycle_status,                  -- PTS 47021
         pyd_prorap,                                -- PTS 47021
         -- PTS 47740 - 50169 <<start>>
         -- MRH 35366
         (SELECT stp_schdtearliest FROM stops WHERE stp_number =
            (SELECT min(stp_number) from stops where ord_hdrnumber = oh.ord_hdrnumber and stp_mfh_sequence =
            (select min(stp_mfh_sequence) from stops where ord_hdrnumber = oh.ord_hdrnumber))) stp_schdtearliest,
         (SELECT orderheader.ord_route FROM orderheader
                WHERE orderheader.ord_hdrnumber = oh.ord_hdrnumber) ord_route,
         cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name
      -- PTS 47740 <<end>>
      FROM paydetail pd
         Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
         Join legheader lh on pd.lgh_number = lh.lgh_number
                        Join stops s on pd.lgh_number = s.lgh_number
      --BEGIN PTS 65645 SPN
      JOIN assetassignment aa ON pd.asgn_number = aa.asgn_number AND aa.pyd_status = 'PPD'
      LEFT OUTER JOIN carrier car ON pd.asgn_type = 'CAR' AND pd.asgn_id = car.car_id
      --END PTS 65645 SPN
  WHERE pd.asgn_type = 'CAR'
   AND pd.pyd_status = @status
   AND s.stp_arrivaldate BETWEEN @loenddate AND @hienddate
   AND ((@acct_typ = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_typ = pd.pyd_prorap))
   --BEGIN PTS 65645 SPN
   --AND  exists (select * from assetassignment aa where pd.asgn_number = aa.asgn_number  AND aa.pyd_status = 'PPD')
   --END PTS 65645 SPN
     AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null)  -- 11/29/2007 MDH PTS 40119: Added
    --BEGIN PTS 65645 SPN
    AND (   @car_branch = '%'
         OR ( @resourcetypeonleg = 'Y'  AND CHARINDEX( ',' + IsNull(aa.asgn_branch, 'UNKNOWN') + ',', @car_branch) > 0 )
         OR ( @resourcetypeonleg <> 'Y' AND CHARINDEX( ',' + IsNull(car.car_branch, 'UNKNOWN') + ',', @car_branch) > 0 )
        )
    --END PTS 65645 SPN


      --IF @carrier <> 'UNKNOWN'
      IF @carrier <> ',UNKNOWN,' and @carrier <> '%'
         delete #trips  where asgn_type = 'CAR' and
                        --asgn_id <> @carrier
                        CHARINDEX( ',' + asgn_id + ',', @carrier) <= 0
      --IF @cartyp1 <> 'UNK'
      IF @cartyp1 <> ',UNK,' and @cartyp1 <> '%'
         delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and
                                    --car_type1 <> @cartyp1
                                    CHARINDEX( ',' + car_type1 + ',', @cartyp1) <= 0
      --IF @cartyp2 <> 'UNK'
      IF @cartyp2 <> ',UNK,' and @cartyp2 <> '%'
         delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and
                                    --car_type2 <> @cartyp2
                                    CHARINDEX( ',' + car_type2 + ',', @cartyp2) <= 0
      --IF @cartyp3 <> 'UNK'
      IF @cartyp3 <> ',UNK,' and @cartyp3 <> '%'
         delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and
                                    --car_type3 <> @cartyp3
                                    CHARINDEX( ',' + car_type3 + ',', @cartyp3) <= 0
      --IF @cartyp4 <> 'UNK'
      IF @cartyp4 <> ',UNK,' and @cartyp4 <> '%'
         delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and
                                    --car_type4 <> @cartyp4
                                    CHARINDEX( ',' + car_type4 + ',', @cartyp4) <= 0

      Update #trips set drivername = car_name from carrier where asgn_type = 'CAR' and asgn_id = car_id
   END -- end for Arrival Date Condition
ELSE
   -- Original way if not using gi setting for Arrival Date
   BEGIN
          INSERT INTO #trips
          SELECT DISTINCT pd.mov_number,
                 lh.lgh_startcty_nmstct,
                 lh.lgh_endcty_nmstct,
                 lh.lgh_startdate,
                 lh.lgh_enddate,
                 oh.ord_originpoint,
                 oh.ord_destpoint,
                 oh.ord_startdate,
                 oh.ord_completiondate,
                 pd.asgn_id,
                 pd.asgn_type,
                 pd.asgn_number,
                 pd.ord_hdrnumber,
                 oh.ord_number,
                 pd.pyh_payperiod,
                 pd.pyd_workperiod,
                 pd.pyd_transferdate,
                 pd.psd_id,
                 pd.pyh_number,
                 pd.pyd_status,
                 pd.pyd_transdate,
                 pd.lgh_number,
                 null, --cr.car_name,
   -- PTS 21386 -- BL (start)
   --              -1,
         0,
   -- PTS 21386 -- BL (end)
          lh.lgh_type1,
         null,
         null,
         pd.pyt_itemcode,
         pd.pyd_authcode,
         pd.pyd_number ,
            oh.ord_revtype1,
            oh.ord_revtype2,
            oh.ord_revtype3,
            oh.ord_revtype4,
            lh.lgh_booked_revtype1, -- PTS 41389 GAP 74
         asgn_controlling = (select asgn_controlling from assetassignment aa where pd.asgn_number = aa.asgn_number),
         pd.pyd_workcycle_status,                  -- PTS 47021
         pyd_prorap,                                -- PTS 47021
         -- PTS 47740 - 50169 <<start>>
         -- MRH 35366
         (SELECT stp_schdtearliest FROM stops WHERE stp_number =
            (SELECT min(stp_number) from stops where ord_hdrnumber = oh.ord_hdrnumber and stp_mfh_sequence =
            (select min(stp_mfh_sequence) from stops where ord_hdrnumber = oh.ord_hdrnumber))) stp_schdtearliest,
         (SELECT orderheader.ord_route FROM orderheader
                WHERE orderheader.ord_hdrnumber = oh.ord_hdrnumber) ord_route,
         cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
         (select min(labelfile.userlabelname) from labelfile
            where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name
         -- PTS 47740 <<end>>
     FROM paydetail pd
         Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
         Join legheader lh on pd.lgh_number = lh.lgh_number
      --BEGIN PTS 65645 SPN
      JOIN assetassignment aa ON pd.asgn_number = aa.asgn_number AND aa.pyd_status = 'PPD'
      LEFT OUTER JOIN carrier car ON pd.asgn_type = 'CAR' AND pd.asgn_id = car.car_id
      --END PTS 65645 SPN
     WHERE pd.asgn_type = 'CAR'
       AND pd.pyd_status = @status
      AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
       AND ((@acct_typ = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_typ = pd.pyd_prorap))
    --BEGIN PTS 65645 SPN
    --  AND  exists (select * from assetassignment aa where pd.asgn_number = aa.asgn_number  AND aa.pyd_status = 'PPD')
    --END PTS 65645 SPN
      AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null)    -- 11/29/2007 MDH PTS 40119: Added
    --BEGIN PTS 65645 SPN
    AND (   @car_branch = '%'
         OR ( @resourcetypeonleg = 'Y'  AND CHARINDEX( ',' + IsNull(aa.asgn_branch, 'UNKNOWN') + ',', @car_branch) > 0 )
         OR ( @resourcetypeonleg <> 'Y' AND CHARINDEX( ',' + IsNull(car.car_branch, 'UNKNOWN') + ',', @car_branch) > 0 )
        )
    --END PTS 65645 SPN


         --IF @carrier <> 'UNKNOWN'
      IF @carrier <> ',UNKNOWN,' and @carrier <> '%'
         delete #trips  where asgn_type = 'CAR' and
                        --asgn_id <> @carrier
                        CHARINDEX( ',' + asgn_id + ',', @carrier) <= 0
      --IF @cartyp1 <> 'UNK'
      IF @cartyp1 <> ',UNK,' and @cartyp1 <> '%'
         delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and
                                    --car_type1 <> @cartyp1
                                    CHARINDEX( ',' + car_type1 + ',', @cartyp1) <= 0
      --IF @cartyp2 <> 'UNK'
      IF @cartyp2 <> ',UNK,' and @cartyp2 <> '%'
         delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and
                                    --car_type2 <> @cartyp2
                                    CHARINDEX( ',' + car_type2 + ',', @cartyp2) <= 0
      --IF @cartyp3 <> 'UNK'
      IF @cartyp3 <> ',UNK,' and @cartyp3 <> '%'
         delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and
                                    --car_type3 <> @cartyp3
                                    CHARINDEX( ',' + car_type3 + ',', @cartyp3) <= 0
      --IF @cartyp4 <> 'UNK'
      IF @cartyp4 <> ',UNK,' and @cartyp4 <> '%'
         delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and
                                    --car_type4 <> @cartyp4
                                    CHARINDEX( ',' + car_type4 + ',', @cartyp4) <= 0

      Update #trips set drivername = car_name from carrier where asgn_type = 'CAR' and asgn_id = car_id
   END
END -- end carrier

-- MRH 31225 Third party
--IF SUBSTRING(@types, 13, 3) = 'TPR'
IF @tpryes <> 'XXX'
BEGIN
   -- LOR   PTS# 31839
   --select @agent = Upper(LTrim(RTrim(gi_string1))) from generalinfo where gi_name = 'AgentCommiss'
   --If @agent = 'Y' or @agent = 'YES'
   -- INSERT INTO #trips
   --         (mov_number, o_cty_nmstct, d_cty_nmstct, lgh_startdate, lgh_enddate,
   --          ord_originpoint, ord_destpoint, ord_startdate, ord_completiondate,
   --          asgn_id, asgn_type, asgn_number, ord_hdrnumber, ord_number,
 --                  pyh_payperiod, pyd_workperiod, pyd_transferdate, psd_id, pyh_number,
   --          pyd_status, pyd_transdate, lgh_number, drivername, paperwork,
   --          lgh_type1, ivh_billdate, ivh_invoicenumber, pyt_itemcode,
   --          pyd_authcode, pyd_number,
   --          ord_revtype1, ord_revtype2, ord_revtype3, oh.ord_revtype4,
   --          lgh_booked_revtype1,  -- PTS 41389 GAP 74
   --          asgn_controlling,
   --          pd.pyd_workcycle_status,                     -- PTS 47021
   --          pd.pyd_prorap )                        -- PTS 47021

   -- SELECT DISTINCT pd.mov_number,
   --          (SELECT cty_code FROM city WHERE cty_code = oh.ord_origincity),
   --          (SELECT cty_code FROM city WHERE cty_code = oh.ord_destcity),
   --          oh.ord_startdate,
   --          oh.ord_completiondate,
   --          oh.ord_originpoint,
   --          oh.ord_destpoint,
   --          oh.ord_startdate,
   --          oh.ord_completiondate,
   --          pd.asgn_id,
   --          pd.asgn_type,
   --          pd.asgn_number,
   --          pd.ord_hdrnumber,
   --          oh.ord_number,
   --          pd.pyh_payperiod,
   --          pd.pyd_workperiod,
   --          pd.pyd_transferdate,
   --          pd.psd_id,
   --          pd.pyh_number,
   --          pd.pyd_status,
   --          pd.pyd_transdate,
   --          pd.lgh_number,
   --          tpr.tpr_name,
   --          0,
   --          '',
   --          null, --ivh_billdate,
   --          null, --ivh_invoicenumber,
   --          pd.pyt_itemcode,
   --          pd.pyd_authcode,
   --          pd.pyd_number,
   --          oh.ord_revtype1,
   --          oh.ord_revtype2,
   --          oh.ord_revtype3,
   --          oh.ord_revtype4,
   --          oh.ord_booked_revtype1, -- PTS 41389 GAP 74
   --          'Y',
   --          pd.pyd_workcycle_status,                  -- PTS 47021
   --          pyd_prorap                              -- PTS 47021
   -- FROM paydetail pd
   --    Left Outer Join orderheader oh on pd.ord_hdrnumber = oh.ord_hdrnumber and
   --          ((pd.asgn_id = oh.ord_thirdpartytype1 AND oh.ord_pyd_status_1 = 'PPD') or
   --           (pd.asgn_id = oh.ord_thirdpartytype2 AND oh.ord_pyd_status_2 = 'PPD'))
   --    Join thirdpartyprofile tpr on pd.asgn_id = tpr.tpr_id
   -- WHERE pd.pyd_status = @status
   --   AND pd.asgn_type = 'TPR'
   --   AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
   --   AND @tpr_id IN ('UNKNOWN', pd.asgn_id)
   --   AND (@tprtype1 in ('N', 'X') OR (@tprtype1 = 'Y' AND @tprtype1 = tpr_thirdpartytype1))
   --   AND (@tprtype2 in ('N', 'X') OR (@tprtype2 = 'Y' AND @tprtype2 = tpr_thirdpartytype2))
   --   AND (@tprtype3 in ('N', 'X') OR (@tprtype3 = 'Y' AND @tprtype3 = tpr_thirdpartytype3))
   --   AND (@tprtype4 in ('N', 'X') OR (@tprtype4 = 'Y' AND @tprtype4 = tpr_thirdpartytype4))
   --   AND (@tprtype5 in ('N', 'X') OR (@tprtype5 = 'Y' AND @tprtype5 = tpr_thirdpartytype5))
   --   AND (@tprtype6 in ('N', 'X') OR (@tprtype6 = 'Y' AND @tprtype6 = tpr_thirdpartytype6))
   --   AND ((@acct_typ = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_typ = pd.pyd_prorap))
   -- AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null) -- 11/29/2007 MDH PTS 40119: Added

   --Else
   Begin
-- LOR
       INSERT INTO #trips
       SELECT DISTINCT pd.mov_number,
              lh.lgh_startcty_nmstct,
              lh.lgh_endcty_nmstct,
              lh.lgh_startdate,
              lh.lgh_enddate,
              oh.ord_originpoint,
              oh.ord_destpoint,
              oh.ord_startdate,
              oh.ord_completiondate,
              pd.asgn_id,
              pd.asgn_type,
              pd.asgn_number,
              pd.ord_hdrnumber,
              oh.ord_number,
              pd.pyh_payperiod,
              pd.pyd_workperiod,
              pd.pyd_transferdate,
              pd.psd_id,
              pd.pyh_number,
              pd.pyd_status,
              pd.pyd_transdate,
              pd.lgh_number,
              null, --cr.car_name,
-- PTS 21386 -- BL (start)
--              -1,
      0,
-- PTS 21386 -- BL (end)
            lh.lgh_type1,
      null,
      null,
      pd.pyt_itemcode,
      pd.pyd_authcode,
      pd.pyd_number ,
         oh.ord_revtype1,
         oh.ord_revtype2,
         oh.ord_revtype3,
         oh.ord_revtype4,
         lh.lgh_booked_revtype1, -- PTS 41389 GAP 74
      'Y',
      pd.pyd_workcycle_status,                  -- PTS 47021
      pyd_prorap,                                -- PTS 47021
      -- PTS 47740 <<start>>
      -- MRH 35366
      (SELECT stp_schdtearliest FROM stops WHERE stp_number =
         (SELECT min(stp_number) from stops where ord_hdrnumber = oh.ord_hdrnumber and stp_mfh_sequence =
         (select min(stp_mfh_sequence) from stops where ord_hdrnumber = oh.ord_hdrnumber))) stp_schdtearliest,
      (SELECT orderheader.ord_route FROM orderheader
             WHERE orderheader.ord_hdrnumber = oh.ord_hdrnumber) ord_route,
      cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name
      -- PTS 47740 <<end>>
         FROM  paydetail pd
            Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
            Join legheader lh on pd.lgh_number = lh.lgh_number
        WHERE pd.asgn_type = 'TPR'
          AND pd.pyd_status = @status
         AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
        AND ((@acct_typ = 'X' AND pd.pyd_prorap IN('A', 'P')) OR
            (@acct_typ = pd.pyd_prorap))
         AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null) -- 11/29/2007 MDH PTS 40119: Added

    --IF @tpr_id <> 'UNKNOWN'
    IF @tpr_id <> ',UNKNOWN,' and @tpr_id <> '%'
      delete #trips  where asgn_type = 'TPR' and
                     --asgn_id <> @tpr_id
                     CHARINDEX( ',' + asgn_id + ',', @tpr_id) <= 0
   --IF @tpr_type <> 'UNKNOWN'
   IF @tpr_type <> ',UNKNOWN,' and @tpr_type <> '%'
      delete #trips from thirdpartyprofile tp where asgn_type = 'TPR' and asgn_id = tp.tpr_id and
                                          --tpr_type <> @tpr_type
                                          CHARINDEX( ',' + tpr_type + ',', @tpr_type) <= 0

   Update #trips set drivername = tpr_name from thirdpartyprofile where asgn_type = 'TPR' and asgn_id = tpr_id
   End
END -- TPR
-- End 31225

/* PTS 17873 - DJM - Remove rows that do not meet the lgh_type1 requiements  */
--if @lghtype1 <> 'UNK'
-- Delete from #trips where lgh_type1 <> @lghtype1
 if @lgh_type1 <> ',UNK,' AND @lgh_type1 <> '%'
   Delete from #trips where CHARINDEX( ',' + lgh_type1 + ',',@lgh_type1) <= 0

/* Set paperwork required */
-- PTS 55221
IF @paperworkmode = 'B'
   INSERT #requiredpaperwork ( ord_hdrnumber, lgh_number, abbr )
   SELECT t.ord_hdrnumber, t.lgh_number, bdt_doctype
     FROM billdoctypes b
          JOIN orderheader o ON b.cmp_id = o.ord_billto
          JOIN #trips t ON o.ord_hdrnumber = t.ord_hdrnumber
    WHERE b.bdt_inv_required = 'Y' AND
          ( ISNULL( b.bdt_required_for_application, 'B' ) = 'B' OR bdt_required_for_application = 'S' ) AND
          ( ISNULL( bdt_required_for_fgt_event, 'B' ) = 'B'
            OR
           --( bdt_required_for_fgt_event = 'PUP' AND
		   ( bdt_required_for_fgt_event in ('PUP','APUP','FPUP','ASTOP') AND		--	LOR  PTS# 106665
              EXISTS(
                 SELECT *
                   FROM stops s
                  WHERE s.ord_hdrnumber = t.ord_hdrnumber AND
                        s.lgh_number = t.lgh_number AND
                        s.stp_type = 'PUP' )
            )
            OR
            -- ( bdt_required_for_fgt_event = 'DRP' AND
			( bdt_required_for_fgt_event in ('DRP', 'ADRP', 'LDRP', 'ASTOP') AND		--	LOR  PTS# 106665
              EXISTS(
                 SELECT *
                   FROM stops s
                  WHERE s.ord_hdrnumber = t.ord_hdrnumber AND
                        s.lgh_number = t.lgh_number AND
                        s.stp_type = 'DRP' )
            )
          )
ELSE -- @paperworkmode = 'A'
   INSERT #requiredpaperwork ( abbr )
   SELECT abbr
     FROM labelfile
    WHERE labeldefinition = 'PaperWork' AND
          code < 100 AND
          ISNULL( retired, 'N' ) <> 'Y'

UPDATE #trips
   SET paperwork = CASE WHEN required_cnt > 0 AND required_cnt <= received_cnt THEN 1
                        WHEN required_cnt > 0 AND required_cnt >  received_cnt THEN -1
                        ELSE 0 -- i.e., required_cnt = 0, appears as N/A for no paperwork required
                   END
  FROM #trips t1 JOIN
       (
         SELECT t.ord_hdrnumber ,
                t.lgh_number ,
                ( SELECT COUNT( DISTINCT rp.abbr )
                    FROM #requiredpaperwork rp
                   WHERE ( @paperworkmode<> 'B' OR rp.ord_hdrnumber = t.ord_hdrnumber ) AND
                         ( @paperworkchecklevel <> 'LEG' OR rp.lgh_number = t.lgh_number )
                ) required_cnt ,
                -- PW RECIEVED
                CASE WHEN @paperworkmode = 'B'
                THEN
                     ( SELECT COUNT( DISTINCT p.abbr )
                         FROM #requiredpaperwork rp
                              LEFT OUTER JOIN paperwork p
                              ON p.ord_hdrnumber = rp.ord_hdrnumber AND
                                 -- would like to make above ( @paperworkmode <> 'B' OR p.ord_hdrnumber = rp.ord_hdrnumber ) and
                                 -- get rid of separate @paperworkmode 'A'/'B' cases, but causes full index scan on k_ord_hdr_abb
                                 ( @paperworkchecklevel <> 'LEG' OR p.lgh_number = rp.lgh_number ) AND
                                 p.abbr = rp.abbr AND
                                 p.pw_received = 'Y'
                        WHERE t.ord_hdrnumber = p.ord_hdrnumber AND
                              ( @paperworkchecklevel <> 'LEG' OR t.lgh_number = p.lgh_number )
                     )
                ELSE -- @paperworkmode = 'A'
                     ( SELECT COUNT( DISTINCT p.abbr )
                         FROM #requiredpaperwork rp
                              LEFT OUTER JOIN paperwork p
                              ON p.abbr = rp.abbr AND
                                 p.pw_received = 'Y'
                        WHERE t.ord_hdrnumber = p.ord_hdrnumber AND
                              ( @paperworkchecklevel <> 'LEG' OR t.lgh_number = p.lgh_number )
                     )
                END received_cnt
           FROM #trips t
       ) pw_cnts
       ON t1.ord_hdrnumber = pw_cnts.ord_hdrnumber AND t1.lgh_number = pw_cnts.lgh_number

DROP TABLE #requiredpaperwork

-- 28117 JD remove uncashed express check paydetails from the queue
delete #trips from
paydetail pd , cdexpresscheck exc
where #trips.pyd_number = pd.pyd_number and pd.pyd_refnum = exc.ceh_customerid + ' ' + exc.ceh_sequencenumber and pd.pyd_status = 'HLD'
      and exc.ceh_registered = 'R'
-- end 28117 JD
-- PTS 16945 -- BL (start)
-- See if user entered in an Invoice bill_date range
if @beg_invoice_bill_date > convert(datetime, '1950-01-01 00:00') OR
      @end_invoice_bill_date < convert(datetime, '2049-12-31 23:59')
Begin
    Update #trips set ivh_billdate = invoiceheader.ivh_billdate , ivh_invoicenumber = invoiceheader.ivh_invoicenumber
    from    invoiceheader  where #trips.ord_hdrnumber > 0 and #trips.ord_hdrnumber = invoiceheader.ord_hdrnumber and
         invoiceheader.ivh_billdate = (select max(ivh_billdate) from invoiceheader b
                                    where #trips.ord_hdrnumber = b.ord_hdrnumber and invoiceheader.ivh_hdrnumber = b.ivh_hdrnumber)

    Delete from #trips
    where (ord_hdrnumber > 0 and ivh_billdate is NULL )
    or (ord_hdrnumber > 0 and (ivh_billdate > @end_invoice_bill_date  or ivh_billdate < @beg_invoice_bill_date))

end
-- PTS 16945 -- BL (end)

----LOR  PTS# 30053
--if @sch_date1 > convert(datetime, '1950-01-01 00:00') OR
--      @sch_date2 < convert(datetime, '2049-12-31 23:59')

-- Delete from #trips
-- where #trips.ord_hdrnumber > 0 and
--       #trips.ord_hdrnumber in (select ord_hdrnumber
--                         from stops
--                         where stp_sequence = 1 and
--                         (stp_schdtearliest > @sch_date2  or
--                            stp_schdtearliest < @sch_date1))
----  LOR

--PTS 32781 - DJM - If specifying a revtype, delete from #trips where the revtype is not what is specified
--IF isNull(@p_revtype1,'UNK') <> 'UNK'
   --DELETE FROM #trips WHERE isNull(#trips.ord_revtype1,'UNK') <> @p_revtype1
--IF isNull(@p_revtype2,'UNK') <> 'UNK'
-- DELETE FROM #trips WHERE isNull(#trips.ord_revtype2,'UNK') <> @p_revtype2
--IF isNull(@p_revtype3,'UNK') <> 'UNK'
-- DELETE FROM #trips WHERE isNull(#trips.ord_revtype3,'UNK') <> @p_revtype3
--IF isNull(@p_revtype4,'UNK') <> 'UNK'
-- DELETE FROM #trips WHERE isNull(#trips.ord_revtype4,'UNK') <> @p_revtype4
--PTS 32781

if @p_revtype2 <> ',UNK,' and @p_revtype2 <> '%'
   DELETE FROM #trips WHERE CHARINDEX( ',' + isnull(#trips.ord_revtype2,'UNK') + ',', @p_revtype2) <= 0
if @p_revtype1 <> ',UNK,' and @p_revtype1 <> '%'
   DELETE FROM #trips WHERE CHARINDEX( ',' + isnull(#trips.ord_revtype1,'UNK') + ',', @p_revtype1) <= 0
if @p_revtype3 <> ',UNK,' and @p_revtype3 <> '%'
   DELETE FROM #trips WHERE CHARINDEX( ',' + isnull(#trips.ord_revtype3,'UNK') + ',', @p_revtype3) <= 0
if @p_revtype4 <> ',UNK,' and @p_revtype4 <> '%'
   DELETE FROM #trips WHERE CHARINDEX( ',' + isnull(#trips.ord_revtype4,'UNK') + ',', @p_revtype4) <= 0

-- PTS 32781 - DJM - Remove records that don't meet the Invoice Status requirement.
if @inv_status <> ',UNK,' AND @inv_status <> '%'
   Delete from #trips
   where not exists (select 1 from Invoiceheader i
      where #trips.ord_hdrnumber = i.ord_hdrnumber
         and i.ord_hdrnumber > 0
         and (charindex(',' + isNull(i.ivh_invoicestatus,'UNK')+ ',',@inv_status) > 0
            OR charindex(',' + isNull(i.ivh_mbstatus,'NTP') + ',',@inv_status) > 0 ))

----**********  NOTE (gap 74): Original Proc did not acknowledge branch. so if trackbranch = N then IGNORE brn_id.

--If exists (select * from generalinfo where gi_name = 'TrackBranch' and gi_string1 = 'Y')
-- BEGIN
--    -- remove any null value records (If TrackBranch = 'Y' remove any null values if any.)
--    Delete from #trips where lgh_booked_revtype1 IS NULL -- remove any NULL value records.

--    IF @brn_id <> ',UNKNOWN,'
--       BEGIN
--          Delete from #trips
--          where lgh_booked_revtype1 in (select lgh_booked_revtype1 from #trips
--                                 where CHARINDEX(',' + lgh_booked_revtype1 + ',', @brn_id) = 0 )
--       END
--    ELSE
--       BEGIN
--          If exists (select * from generalinfo where gi_name = 'BRANCHUSERSECURITY' and gi_string1 = 'Y')
--          BEGIN
--             -- if branch security is ON then get data, else, do not delete.
--                   -- if branch id = 'unknown' bring back ALL branch IDs the user is ALLOWED to see.
--                   SELECT brn_id
--                   INTO #temp_user_branch
--                   FROM branch_assignedtype
--                   WHERE bat_type = 'USERID'
--                   and brn_id <> 'UNKNOWN'
--                   AND bat_value  =  @G_USERID

--                   Delete from #trips
--                   where lgh_booked_revtype1 NOT IN ( select brn_id from #temp_user_branch)
--          END
--       END
-- END
-- PTS 41389 GAP 74 (end)

-- PTS 46402 <<start>>
-- Restrict based on Invoice billto
--select @p_ivh_billto = isnull(@p_ivh_billto,'UNKNOWN')
--if isNull(@p_ivh_billto,'UNKNOWN') <> 'UNKNOWN'
-- delete from #trips
-- where not exists (select 1 from Invoiceheader i
--    where #trips.ord_hdrnumber = i.ord_hdrnumber
--       and i.ord_hdrnumber > 0
--       and isnull(i.ivh_billto,'UNKNOWN') = @p_ivh_billto)

if @p_ivh_billto <> ',UNKNOWN,' and @p_ivh_billto <> '%'
   delete from #trips
   where not exists (select 1 from Invoiceheader i
                  where #trips.ord_hdrnumber = i.ord_hdrnumber
                     and i.ord_hdrnumber > 0
                     and CHARINDEX( ',' + isnull(i.ivh_billto,'UNKNOWN') + ',', @p_ivh_billto) > 0)
-- PTS 46402 <<end>>

---- PTS 47021 <<start>>
--Select @p_pyd_workcycle_status = ISNULL(@p_pyd_workcycle_status, 'UNK')
--IF @p_pyd_workcycle_status <> 'UNK'
--BEGIN
-- delete from #trips where ISNULL(pyd_workcycle_status, 'UNK') <> @p_pyd_workcycle_status
--END
---- PTS 47021 <<end>>

--  pts 63566 -- window maps start dates to the @loenddate / @hienddate  parameters
-- PTS 63566.start  -- Apply dates if they do not = genesis / apocalypse
 If ( @loenddate is not null and 
		@hienddate is not null and 
			( @loenddate <> '1950-01-01 00:00:00.000' OR  @hienddate <> '2049-12-31 23:59:59.992' ) )
	BEGIN			
  
		 Insert Into #tmpAsgnNbrAsgnDate
		 Select v_ident_count, asgn_number, lgh_number,  NULL, asgn_type, asgn_id	 from #trips
		 where asgn_type <> 'TPR'
 
		Update #tmpAsgnNbrAsgnDate 
			set asgn_date = (select asgn_date  
							 from assetassignment aa 
							 where #tmpAsgnNbrAsgnDate.asgn_number = aa.asgn_number
							 and  asgn_type <> 'TPR')
		 where asgn_type <> 'TPR'					 	
							 
		Insert Into #tmpAsgnNbrAsgnDate
		Select v_ident_count,  asgn_number, lgh_number, lgh_startdate, asgn_type, asgn_id from #trips
		where asgn_type = 'TPR'	
		
		-- delete the ones we DO want to keep so we can delete the ones we do not want from #trips
		 delete from #tmpAsgnNbrAsgnDate where asgn_date between @loenddate and @hienddate 
		 
		  If ( select count(v_ident_count) from #tmpAsgnNbrAsgnDate )  > 0
		 Begin				 
			delete from #trips where  #trips.v_ident_count in (select v_ident_count from #tmpAsgnNbrAsgnDate )  
		 End
 
		IF OBJECT_ID(N'tempdb..##tmpAsgnNbrAsgnDate', N'U') IS NOT NULL 
		DROP TABLE #tmpAsgnNbrAsgnDate		
 
	END		
--PTS 63566.end	-- End of Apply dates 	


-- RETURN THE DATA
SELECT mov_number,
       o_cty_nmstct,
       d_cty_nmstct,
       lgh_startdate,
       lgh_enddate,
       ord_originpoint,
       ord_destpoint,
       ord_startdate,
       ord_completiondate,
       asgn_id,
       asgn_type,
       asgn_number,
       ord_hdrnumber,
       ord_number,
       pyh_payperiod,
       pyd_workperiod,
       pyd_transferdate,
       psd_id,
       pyh_number,
       pyd_status,
       pyd_transdate,
       lgh_number,
       --drivername,
        LEFT(drivername, 45) 'drivername',   --PTS 63566  bring back to 45 (from 80)
       paperwork,
       lgh_type1,
       'LghType1',
-- PTS 16945 -- BL (start)
ivh_billdate,
ivh_invoicenumber,
pyt_itemcode,
pyd_authcode,
lgh_booked_revtype1, -- PTS 41389 GAP 74
asgn_controlling,
pyd_workcycle_status,                  -- PTS 47021
ISNULL(pyd_prorap, 'N') 'pyd_prorap',      -- PTS 47021
   ord_revtype1,     -- PTS 47740
   ord_revtype2,     -- PTS 47740
   ord_revtype3,     -- PTS 47740
   ord_revtype4,     -- PTS 47740
   stp_schdtearliest,   -- PTS 47740
   ord_route,        -- PTS 47740
   Cost,          -- PTS 47740
   ord_revtype1_name,   -- PTS 47740
   ord_revtype2_name,   -- PTS 47740
   ord_revtype3_name,   -- PTS 47740
   ord_revtype4_name -- PTS 47740
  FROM #trips
ORDER BY mov_number, ord_number

DROP TABLE #trips
GO
GRANT EXECUTE ON  [dbo].[d_view_trips_by_paystatus_forviews_sp] TO [public]
GO
