SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_view_trips_by_paystatus_sp] (
	@status varchar(6),
	@types varchar(15),
	@lostartdate datetime,
	@histartdate datetime,
	@loenddate datetime,
	@hienddate datetime,
	@company varchar(8),
	@fleet varchar(6),
	@division varchar(6),
	@terminal varchar(6),
	@drvtype1 varchar(6),
	@drvtype2 varchar(6),
	@drvtype3 varchar(6),
	@drvtype4 varchar(6),
	@trctype1 varchar(6),
	@trctype2 varchar(6),
	@trctype3 varchar(6),
	@trctype4 varchar(6),
	@driver varchar(8),
	@tractor varchar(8),
	@acct_type char(1),
	@carrier varchar(8),
	@cartype1 varchar(6),
	@cartype2 varchar(6),
	@cartype3 varchar(6),
	@cartype4 varchar(6),
	@trailer varchar(13),
	@trltype1 varchar(6),
	@trltype2 varchar(6),
	@trltype3 varchar(6),
	@trltype4 varchar(6),
	@lghtype1 varchar(6),
	@beg_invoice_bill_date datetime,
	@end_invoice_bill_date datetime,
	@sch_date1 datetime,
	@sch_date2 datetime,
	@tpr_id varchar(8),
	@tpr_type varchar(12),
	@p_revtype1 varchar(6),
	@p_revtype2 varchar(6),
	@p_revtype3 varchar(6),
	@p_revtype4 varchar(6),
	@inv_status varchar(100),
	@tprtype1 char(1),
	@tprtype2 char(1),
	@tprtype3 char(1),
	@tprtype4 char(1),
	@tprtype5 char(1),
	@tprtype6 char(1),
	@brn_id varchar(256),     -- PTS 41389 GAP 74
	@G_USERID varchar(14),   -- PTS 41389 GAP 74
	@p_ivh_billto varchar(8),  -- PTS 46402
	@p_pyd_workcycle_status varchar(30), -- PTS 47021
	@resourcetypeonleg char(1),
	@mpp_branch             VARCHAR(12),
	@trc_branch             VARCHAR(12),
	@trl_branch             VARCHAR(12),
	@car_branch             VARCHAR(12)
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --9/14/2011 wkeckha: added while waiting for TMW to get permanent fix. proc was deadlocking.
/**
 *
 * NAME:
 * dbo.d_view_trips_by_paystatus_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Proc for dw d_view_trips_by_paystatus
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * .....
 * 035 - @sch_date1 datetime  sch earliest datetime from
 * 036 - @sch_date1 datetime  sch earliest datetime to
 *
 * REVISION HISTORY:
-- JET - 10/26/99 - PTS #6631, removed joins to the asset assignment table.
-- All the information that it is verified against the asset assignment table is stored
-- with the pay details.  The information on the pay details is more exact, so it should
-- be used.  The trips on hold queue is to release any pay details on hold that match
-- the entered criteria.  The only queue that needs to look at asset assignment records
-- is the trips ready to settle.  This queue is looking for trips that may not have
-- any pay details.  Any queue that is based on pay details that exist should not look
-- to the asset assignment table.
--
-- PTS 16945 - 5/2/03 - BAL - Allow user to filter data by invoice billing date
--
-- PTS 19738 - 2/2/05 - DJM - Expand the asgn_id column in the temp table to 13 characters to
--       allow for trl_id.  Changed use of trl_number in the Trailer section to
--       link paydetail and trailerprofile by trl_id.
 * LOR   PTS# 30053  added sch earliest dates
 * MRH 31225 2/10/06 3rd party pay.
 * PTS 32781 - DJM - Added revtypes and Invoice Status as parameters.
 * LOR   PTS# 31389  agent pay in queues
-- PTS 35646 - 1/31/07 - SLM - Create a General Info setting to use the Arrivaldate on the last
--                             stop of the trip segment instead of the pyd_transdate in the
--                             criteria used to display the pay details.
-- PTS 36869 6/4/07 EMK - Added required for invoice check to paperwork
-- PTS 41389 GAP 74  JSwindell 3/31/2008  Add parameter brn_id (branch id) aka lgh_booked_revtype1 & ord_booked_revtype1
* LOR PTS# 42881  added asgn_controlling - flag for lead/co-drv
-- PTS 46402 JSwindell 3-30-2009  Add ivh_billto as a parameter:  p_ivh_billto
-- PTS 47021  7-24-2009: Argument & result set:  pyd_workcycle_status varchar(30), pyd_prorap char(1)
-- PTS 48237 - DJM - Added option to restrict Driver and Tractor types against the Legheader values instead of the Profile values.
-- PTS 55221 CCI 2/16/11:  Rewrote paperwork to fix split trips when using 'LEG' level; also fixed retired paperwork label files when in 'A' mode.
-- PTS 59057 vjh 10/03/2011 add setting to help with locking per Mindy Curnutt
-- PTS 61669 JJF 20120920 - rework of criteria to eliminate many deletes from temp table after initial queries.  Moved directly to selects.  Performance request from Mindy C.
-- 11/08/2012 PTS 65645 SPN - Added Restriction @mpp_branch, @trc_branch, @trl_branch, @car_branch
-- PTS 63566 Add asgn_date to #trips so  @lostartdate/@histartdate parameters can be used.	)	
-- PTS 63566 Add identity col to #trips table.
-- PTS 63566  Carrier Name in core is x(64) &  drivername is varchar(45);  increase drivername to 80 but truncate it back to 45 for result set.
-- pts 85922 vjh add to be audited
**/

-- PTS 41389 GAP 74 Start
IF @brn_id IS NULL or @brn_id = '' or @brn_id  = 'UNK'
   begin
      SELECT @brn_id = 'UNKNOWN'
   end

SELECT @brn_id = ',' + LTRIM(RTRIM(ISNULL(@brn_id, '')))  + ','
-- PTS 41389 GAP 74 end


Declare @paperworkchecklevel varchar(6),
 @paperworkmode varchar(3),
 @agent varchar(3),
 @usearrivaldate char(1), -- PTS 35646
 @tobeaudited char(1)		--85922

if @status = 'TBA' begin
	set @status = 'HLD'
	set @tobeaudited = 'Y'
	--description of alternate handling for tobeaudited
	--this feature overloads the @status field.
	--passing in 'TBA' really selects 'HLD' pay details with additional requirements
	--the paytype must be marked as pyt_requireaudit='Y'
	--and the trip muls have other pay details released (it is in the spec)
end else begin
	set @tobeaudited = 'N'
end
 
 -- PTS 63566.start
CREATE TABLE #tmpAsgnNbrAsgnDate (	v_ident_count int null,
									asgn_number int null, 									
									lgh_number	int null,									
									asgn_date	datetime null,  
									asgn_type	varchar(6) null,		
									asgn_id		varchar(13) null )									
-- PTS 63566.end 

-- PTS 63566 Add identity col to #trips table.
CREATE TABLE #trips (
	v_ident_count INT Identity,
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
	drivername varchar(80) null,	--PTS 63566  increase to 80 char from 45
	paperwork smallint null,
	lgh_type1 varchar(6) null,
	ivh_billdate datetime Null,
	ivh_invoicenumber varchar(12) Null,
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

Create index #idx_ord on #trips(ord_hdrnumber)


-- PTS 55221
CREATE TABLE #requiredpaperwork (
   ord_hdrnumber INT NULL ,
   lgh_number INT NULL ,
   abbr VARCHAR(6) NULL )
SELECT @paperworkchecklevel = ISNULL( ( SELECT gi_string1 FROM generalinfo WHERE upper(gi_name) = 'PAPERWORKCHECKLEVEL' ), 'ORD' )
SELECT @paperworkmode = ISNULL( ( SELECT gi_string1 FROM generalinfo WHERE upper(gi_name) = 'PAPERWORKMODE' ), 'A' )

-- PTS 3223781 - DJM
SELECT @inv_status = ',' + LTRIM(RTRIM(ISNULL(@inv_status, 'UNK'))) + ','

-- PTS 35646 - SLM 1/31/07
SELECT @usearrivaldate = gi_string1 from generalinfo where upper(gi_name) = 'USEARRIVALDATE'

-- GET DRIVER DATA IF NEEDED
IF SUBSTRING(@types, 1, 3) = 'DRV'
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
		mpp_lastfirst,
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
		(  SELECT TOP 1 stpinner.stp_schdtearliest
			FROM  stops stpinner with (nolock)
			WHERE stpinner.mov_number = oh.mov_number
				AND stpinner.ord_hdrnumber = oh.ord_hdrnumber
			ORDER BY stpinner.stp_mfh_sequence asc
		) stp_schdtearliest,
		oh.ord_route,
		cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name
	FROM paydetail pd
		Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
		Join legheader lh on pd.lgh_number = lh.lgh_number
		INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = oh.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or oh.rowsec_rsrv_id is null)
		left outer join manpowerprofile mpp on  (pd.asgn_type = 'DRV' and pd.asgn_id = mpp.mpp_id)
		JOIN assetassignment aa ON pd.asgn_number = aa.asgn_number AND aa.pyd_status = 'PPD'
  WHERE pd.asgn_type = 'DRV'
		and pd.pyd_status = @status
		and pd.pyd_transdate BETWEEN @loenddate AND @hienddate
		and ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
		and (@driver = 'UNKNOWN' or pd.asgn_id = @driver)
		and (@company = 'UNK' or ISNULL(mpp.mpp_company, @company) = @company)
		and (@fleet = 'UNK' or ISNULL(mpp.mpp_fleet, @fleet) = @fleet)
		and (@division = 'UNK' or ISNULL(mpp.mpp_division, @division) = @division)
		and (@terminal = 'UNK' or ISNULL(mpp.mpp_terminal, @terminal) = @terminal)
		and (@resourcetypeonleg <> 'Y' or isnull(pd.lgh_number, 0) = 0 or @drvtype1 = 'UNK' or isnull(lh.mpp_type1, @drvtype1) = @drvtype1)
		and (@resourcetypeonleg <> 'Y' or isnull(pd.lgh_number, 0) = 0 or @drvtype2 = 'UNK' or isnull(lh.mpp_type2, @drvtype2) = @drvtype2)
		and (@resourcetypeonleg <> 'Y' or isnull(pd.lgh_number, 0) = 0 or @drvtype3 = 'UNK' or isnull(lh.mpp_type3, @drvtype3) = @drvtype3)
		and (@resourcetypeonleg <> 'Y' or isnull(pd.lgh_number, 0) = 0 or @drvtype4 = 'UNK' or isnull(lh.mpp_type4, @drvtype4) = @drvtype4)
		and (@resourcetypeonleg = 'Y' or @drvtype1 = 'UNK' or ISNULL(mpp.mpp_type1, @drvtype1) = @drvtype1)
		and (@resourcetypeonleg = 'Y' or @drvtype2 = 'UNK' or ISNULL(mpp.mpp_type2, @drvtype2) = @drvtype2)
		and (@resourcetypeonleg = 'Y' or @drvtype3 = 'UNK' or ISNULL(mpp.mpp_type3, @drvtype3) = @drvtype3)
		and (@resourcetypeonleg = 'Y' or @drvtype4 = 'UNK' or ISNULL(mpp.mpp_type4, @drvtype4) = @drvtype4)
		and (   @mpp_branch = 'UNKNOWN'
			OR ( @resourcetypeonleg = 'Y'  AND IsNull(aa.asgn_branch, 'UNKNOWN') = @mpp_branch)
			OR ( @resourcetypeonleg <> 'Y' AND IsNull(mpp.mpp_branch, 'UNKNOWN') = @mpp_branch)
		)
		and (ISNULL(@p_revtype1, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype1, 'UNK') = @p_revtype1)
		and (ISNULL(@p_revtype2, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype2, 'UNK') = @p_revtype2)
		and (ISNULL(@p_revtype3, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype3, 'UNK') = @p_revtype3)
		and (ISNULL(@p_revtype4, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype4, 'UNK') = @p_revtype4)
		and (ISNULL(@lghtype1, 'UNK') = 'UNK' or ISNULL(lh.lgh_type1, 'UNK') = @lghtype1)
		and (ISNULL(@p_pyd_workcycle_status, 'UNK') = 'UNK' or ISNULL(pd.pyd_workcycle_status, 'UNK') = @p_pyd_workcycle_status)
END -- end driver

-- GET TRACTOR DATA IF NEEDED
IF SUBSTRING(@types, 4, 3) = 'TRC'
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
		trc.trc_make + ', ' + trc.trc_model,
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
		(  SELECT TOP 1 stpinner.stp_schdtearliest
			FROM  stops stpinner with (nolock)
			WHERE stpinner.mov_number = oh.mov_number
				AND stpinner.ord_hdrnumber = oh.ord_hdrnumber
			ORDER BY stpinner.stp_mfh_sequence asc
		) stp_schdtearliest,
		oh.ord_route,
		cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name

	FROM paydetail pd
		Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
		Join legheader lh on pd.lgh_number = lh.lgh_number
		INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = oh.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or oh.rowsec_rsrv_id is null)
		LEFT OUTER JOIN tractorprofile trc on (pd.asgn_type = 'TRC' and pd.asgn_id = trc.trc_number)
		JOIN assetassignment aa ON pd.asgn_number = aa.asgn_number AND aa.pyd_status = 'PPD'
	WHERE pd.asgn_type = 'TRC'
		and pd.pyd_status = @status
		and pd.pyd_transdate BETWEEN @loenddate AND @hienddate  -- JD 32041 make the tractor trans date restrictions match the other dates.
		and ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
		and (@tractor = 'UNKNOWN' or pd.asgn_id = @tractor)
		and (@company = 'UNK' or ISNULL(trc.trc_company, @company) = @company)
		and (@fleet = 'UNK' or ISNULL(trc.trc_fleet, @fleet) = @fleet)
		and (@division = 'UNK' or ISNULL(trc.trc_division, @division) = @division)
		and (@terminal = 'UNK' or ISNULL(trc.trc_terminal, @terminal) = @terminal)
		and (@resourcetypeonleg <> 'Y' or isnull(pd.lgh_number, 0) = 0 or @trctype1 = 'UNK' or isnull(lh.trc_type1, @trctype1) = @trctype1)
		and (@resourcetypeonleg <> 'Y' or isnull(pd.lgh_number, 0) = 0 or @trctype2 = 'UNK' or isnull(lh.trc_type2, @trctype2) = @trctype2)
		and (@resourcetypeonleg <> 'Y' or isnull(pd.lgh_number, 0) = 0 or @trctype3 = 'UNK' or isnull(lh.trc_type3, @trctype3) = @trctype3)
		and (@resourcetypeonleg <> 'Y' or isnull(pd.lgh_number, 0) = 0 or @trctype4 = 'UNK' or isnull(lh.trc_type4, @trctype4) = @trctype4)
		and (@resourcetypeonleg = 'Y' or @trctype1 = 'UNK' or ISNULL(trc.trc_type1, @trctype1) = @trctype1)
		and (@resourcetypeonleg = 'Y' or @trctype2 = 'UNK' or ISNULL(trc.trc_type2, @trctype2) = @trctype2)
		and (@resourcetypeonleg = 'Y' or @trctype3 = 'UNK' or ISNULL(trc.trc_type3, @trctype3) = @trctype3)
		and (@resourcetypeonleg = 'Y' or @trctype4 = 'UNK' or ISNULL(trc.trc_type4, @trctype4) = @trctype4)
		and (   @trc_branch = 'UNKNOWN'
			OR ( @resourcetypeonleg = 'Y'  AND IsNull(aa.asgn_branch, 'UNKNOWN') = @trc_branch)
			OR ( @resourcetypeonleg <> 'Y' AND IsNull(trc.trc_branch, 'UNKNOWN') = @trc_branch)
		)
		and (ISNULL(@p_revtype1, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype1, 'UNK') = @p_revtype1)
		and (ISNULL(@p_revtype2, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype2, 'UNK') = @p_revtype2)
		and (ISNULL(@p_revtype3, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype3, 'UNK') = @p_revtype3)
		and (ISNULL(@p_revtype4, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype4, 'UNK') = @p_revtype4)
		and (ISNULL(@lghtype1, 'UNK') = 'UNK' or ISNULL(lh.lgh_type1, 'UNK') = @lghtype1)
		and (ISNULL(@p_pyd_workcycle_status, 'UNK') = 'UNK' or ISNULL(pd.pyd_workcycle_status, 'UNK') = @p_pyd_workcycle_status)
   END -- END TRC

-- GET TRAILER DATA IF NEEDED
IF SUBSTRING(@types, 7, 3) = 'TRL'
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
              trl_make + ', ' + trl_model,
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
      (  SELECT TOP 1 stpinner.stp_schdtearliest
         FROM  stops stpinner with (nolock)
         WHERE stpinner.mov_number = oh.mov_number
               AND stpinner.ord_hdrnumber = oh.ord_hdrnumber
         ORDER BY stpinner.stp_mfh_sequence asc
      ) stp_schdtearliest,
      oh.ord_route,
      cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
      (select min(labelfile.userlabelname) from labelfile
         where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name


	FROM paydetail pd
		Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
		Join legheader lh on pd.lgh_number = lh.lgh_number
		INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = oh.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or oh.rowsec_rsrv_id is null)
		LEFT OUTER JOIN trailerprofile trl on (pd.asgn_type = 'TRL' and pd.asgn_id = trl.trl_id)
		JOIN assetassignment aa ON pd.asgn_number = aa.asgn_number AND aa.pyd_status = 'PPD'
	WHERE pd.asgn_type = 'TRL'
		AND pd.pyd_status = @status
		AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
		AND ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
		and (@trailer = 'UNKNOWN' or pd.asgn_id = @trailer)
		and (@company = 'UNK' or ISNULL(trl.trl_company, @company) = @company)
		and (@fleet = 'UNK' or ISNULL(trl.trl_fleet, @fleet) = @fleet)
		and (@division = 'UNK' or ISNULL(trl.trl_division, @division) = @division)
		and (@terminal = 'UNK' or ISNULL(trl.trl_terminal, @terminal) = @terminal)
		and (@trltype1 = 'UNK' or ISNULL(trl.trl_type1, @trltype1) = @trltype1)
		and (@trltype2 = 'UNK' or ISNULL(trl.trl_type2, @trltype2) = @trltype2)
		and (@trltype3 = 'UNK' or ISNULL(trl.trl_type3, @trltype3) = @trltype3)
		and (@trltype4 = 'UNK' or ISNULL(trl.trl_type4, @trltype4) = @trltype4)
		AND (   @trl_branch = 'UNKNOWN'
			OR ( @resourcetypeonleg = 'Y'  AND IsNull(aa.asgn_branch, 'UNKNOWN') = @trl_branch)
			OR ( @resourcetypeonleg <> 'Y' AND IsNull(trl.trl_branch, 'UNKNOWN') = @trl_branch)
		)
		and (ISNULL(@p_revtype1, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype1, 'UNK') = @p_revtype1)
		and (ISNULL(@p_revtype2, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype2, 'UNK') = @p_revtype2)
		and (ISNULL(@p_revtype3, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype3, 'UNK') = @p_revtype3)
		and (ISNULL(@p_revtype4, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype4, 'UNK') = @p_revtype4)
		and (ISNULL(@lghtype1, 'UNK') = 'UNK' or ISNULL(lh.lgh_type1, 'UNK') = @lghtype1)
		and (ISNULL(@p_pyd_workcycle_status, 'UNK') = 'UNK' or ISNULL(pd.pyd_workcycle_status, 'UNK') = @p_pyd_workcycle_status)
END

-- GET CARRIER DATA IF NEEDED
IF SUBSTRING(@types, 10, 3) = 'CAR'
BEGIN
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
		car.car_name,
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
		(  SELECT TOP 1 stpinner.stp_schdtearliest
			FROM  stops stpinner with (nolock)
			WHERE stpinner.mov_number = oh.mov_number
				AND stpinner.ord_hdrnumber = oh.ord_hdrnumber
			ORDER BY stpinner.stp_mfh_sequence asc
		) stp_schdtearliest,
		oh.ord_route,
		cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name
	FROM paydetail pd
		Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
		Join legheader lh on pd.lgh_number = lh.lgh_number
		INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = oh.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or oh.rowsec_rsrv_id is null)
		LEFT OUTER JOIN carrier car on (pd.asgn_type = 'CAR' and pd.asgn_id = car.car_id)
		Join stops s on pd.lgh_number = s.lgh_number
		JOIN assetassignment aa ON pd.asgn_number = aa.asgn_number AND aa.pyd_status = 'PPD'
	WHERE pd.asgn_type = 'CAR'
		and pd.pyd_status = @status
		and s.stp_arrivaldate BETWEEN @loenddate AND @hienddate
		and ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
		and (@carrier = 'UNKNOWN' or pd.asgn_id = @carrier)
		and (@cartype1 = 'UNK' or ISNULL(car.car_type1, @cartype1) = @cartype1)
		and (@cartype2 = 'UNK' or ISNULL(car.car_type2, @cartype2) = @cartype2)
		and (@cartype3 = 'UNK' or ISNULL(car.car_type3, @cartype3) = @cartype3)
		and (@cartype4 = 'UNK' or ISNULL(car.car_type4, @cartype4) = @cartype4)
		and (   @car_branch = 'UNKNOWN'
			OR ( @resourcetypeonleg = 'Y'  AND IsNull(aa.asgn_branch, 'UNKNOWN') = @car_branch)
			OR ( @resourcetypeonleg <> 'Y' AND IsNull(car.car_branch, 'UNKNOWN') = @car_branch)
		)
		and (ISNULL(@p_revtype1, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype1, 'UNK') = @p_revtype1)
		and (ISNULL(@p_revtype2, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype2, 'UNK') = @p_revtype2)
		and (ISNULL(@p_revtype3, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype3, 'UNK') = @p_revtype3)
		and (ISNULL(@p_revtype4, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype4, 'UNK') = @p_revtype4)
		and (ISNULL(@lghtype1, 'UNK') = 'UNK' or ISNULL(lh.lgh_type1, 'UNK') = @lghtype1)
		and (ISNULL(@p_pyd_workcycle_status, 'UNK') = 'UNK' or ISNULL(pd.pyd_workcycle_status, 'UNK') = @p_pyd_workcycle_status)
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
		car.car_name,
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
		(  SELECT TOP 1 stpinner.stp_schdtearliest
			FROM  stops stpinner with (nolock)
			WHERE stpinner.mov_number = oh.mov_number
				AND stpinner.ord_hdrnumber = oh.ord_hdrnumber
			ORDER BY stpinner.stp_mfh_sequence asc
		) stp_schdtearliest,
		oh.ord_route,
		cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name
	FROM paydetail pd
		Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
		Join legheader lh on pd.lgh_number = lh.lgh_number
		INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = oh.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or oh.rowsec_rsrv_id is null)
		LEFT OUTER JOIN carrier car on (pd.asgn_type = 'CAR' and pd.asgn_id = car.car_id)
		JOIN assetassignment aa ON pd.asgn_number = aa.asgn_number AND aa.pyd_status = 'PPD'
	WHERE pd.asgn_type = 'CAR'
		and pd.pyd_status = @status
		and pd.pyd_transdate BETWEEN @loenddate AND @hienddate
		and ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
		and (@carrier = 'UNKNOWN' or pd.asgn_id = @carrier)
		and (@cartype1 = 'UNK' or ISNULL(car.car_type1, @cartype1) = @cartype1)
		and (@cartype2 = 'UNK' or ISNULL(car.car_type2, @cartype2) = @cartype2)
		and (@cartype3 = 'UNK' or ISNULL(car.car_type3, @cartype3) = @cartype3)
		and (@cartype4 = 'UNK' or ISNULL(car.car_type4, @cartype4) = @cartype4)
		and (   @car_branch = 'UNKNOWN'
			OR ( @resourcetypeonleg = 'Y'  AND IsNull(aa.asgn_branch, 'UNKNOWN') = @car_branch)
			OR ( @resourcetypeonleg <> 'Y' AND IsNull(car.car_branch, 'UNKNOWN') = @car_branch)
		)
		and (ISNULL(@p_revtype1, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype1, 'UNK') = @p_revtype1)
		and (ISNULL(@p_revtype2, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype2, 'UNK') = @p_revtype2)
		and (ISNULL(@p_revtype3, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype3, 'UNK') = @p_revtype3)
		and (ISNULL(@p_revtype4, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype4, 'UNK') = @p_revtype4)
		and (ISNULL(@lghtype1, 'UNK') = 'UNK' or ISNULL(lh.lgh_type1, 'UNK') = @lghtype1)
		and (ISNULL(@p_pyd_workcycle_status, 'UNK') = 'UNK' or ISNULL(pd.pyd_workcycle_status, 'UNK') = @p_pyd_workcycle_status)
   END
END -- end carrier

-- MRH 31225 Third party
IF SUBSTRING(@types, 13, 3) = 'TPR'
BEGIN
   -- LOR   PTS# 31839
   select @agent = Upper(LTrim(RTrim(gi_string1))) from generalinfo where gi_name = 'AgentCommiss'
   If @agent = 'Y' or @agent = 'YES'
      INSERT INTO #trips
              (mov_number, o_cty_nmstct, d_cty_nmstct, lgh_startdate, lgh_enddate,
               ord_originpoint, ord_destpoint, ord_startdate, ord_completiondate,
               asgn_id, asgn_type, asgn_number, ord_hdrnumber, ord_number,
                  pyh_payperiod, pyd_workperiod, pyd_transferdate, psd_id, pyh_number,
               pyd_status, pyd_transdate, lgh_number, drivername, paperwork,
               lgh_type1, ivh_billdate, ivh_invoicenumber, pyt_itemcode,
               pyd_authcode, pyd_number,
               ord_revtype1, ord_revtype2, ord_revtype3, oh.ord_revtype4,
               lgh_booked_revtype1,  -- PTS 41389 GAP 74
               asgn_controlling,
               pd.pyd_workcycle_status,                     -- PTS 47021
               pd.pyd_prorap )                        -- PTS 47021

      SELECT DISTINCT pd.mov_number,
               (SELECT cty_code FROM city WHERE cty_code = oh.ord_origincity),
               (SELECT cty_code FROM city WHERE cty_code = oh.ord_destcity),
               oh.ord_startdate,
               oh.ord_completiondate,
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
               tpr.tpr_name,
               0,
               '',
               null, --ivh_billdate,
               null, --ivh_invoicenumber,
               pd.pyt_itemcode,
               pd.pyd_authcode,
               pd.pyd_number,
               oh.ord_revtype1,
               oh.ord_revtype2,
               oh.ord_revtype3,
               oh.ord_revtype4,
               oh.ord_booked_revtype1, -- PTS 41389 GAP 74
               'Y',
               pd.pyd_workcycle_status,                  -- PTS 47021
               pyd_prorap                              -- PTS 47021
      FROM paydetail pd
         Left Outer Join orderheader oh on pd.ord_hdrnumber = oh.ord_hdrnumber and
               ((pd.asgn_id = oh.ord_thirdpartytype1 AND oh.ord_pyd_status_1 = 'PPD') or
                (pd.asgn_id = oh.ord_thirdpartytype2 AND oh.ord_pyd_status_2 = 'PPD'))
         Join thirdpartyprofile tpr on pd.asgn_id = tpr.tpr_id
         INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = oh.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or oh.rowsec_rsrv_id is null)
      WHERE pd.pyd_status = @status
        AND pd.asgn_type = 'TPR'
        AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
        AND @tpr_id IN ('UNKNOWN', pd.asgn_id)
        AND (@tprtype1 in ('N', 'X') OR (@tprtype1 = 'Y' AND @tprtype1 = tpr_thirdpartytype1))
        AND (@tprtype2 in ('N', 'X') OR (@tprtype2 = 'Y' AND @tprtype2 = tpr_thirdpartytype2))
        AND (@tprtype3 in ('N', 'X') OR (@tprtype3 = 'Y' AND @tprtype3 = tpr_thirdpartytype3))
        AND (@tprtype4 in ('N', 'X') OR (@tprtype4 = 'Y' AND @tprtype4 = tpr_thirdpartytype4))
        AND (@tprtype5 in ('N', 'X') OR (@tprtype5 = 'Y' AND @tprtype5 = tpr_thirdpartytype5))
        AND (@tprtype6 in ('N', 'X') OR (@tprtype6 = 'Y' AND @tprtype6 = tpr_thirdpartytype6))
        AND ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
       and (ISNULL(@p_revtype1, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype1, 'UNK') = @p_revtype1)
       and (ISNULL(@p_revtype2, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype2, 'UNK') = @p_revtype2)
       and (ISNULL(@p_revtype3, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype3, 'UNK') = @p_revtype3)
       and (ISNULL(@p_revtype4, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype4, 'UNK') = @p_revtype4)
       and (ISNULL(@p_pyd_workcycle_status, 'UNK') = 'UNK' or ISNULL(pd.pyd_workcycle_status, 'UNK') = @p_pyd_workcycle_status)
   Else
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
		tpr.tpr_name,
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
		'Y',
		pd.pyd_workcycle_status,                  -- PTS 47021
		pyd_prorap,                                -- PTS 47021
		(  SELECT TOP 1 stpinner.stp_schdtearliest
			FROM  stops stpinner with (nolock)
			WHERE stpinner.mov_number = oh.mov_number
				AND stpinner.ord_hdrnumber = oh.ord_hdrnumber
			ORDER BY stpinner.stp_mfh_sequence asc
		) stp_schdtearliest,
		oh.ord_route,
		cast((SELECT sum(pyd_amount) from paydetail where ord_hdrnumber = oh.ord_hdrnumber) as money) Cost,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE1') ord_revtype1_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE2') ord_revtype2_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE3') ord_revtype3_name,
		(select min(labelfile.userlabelname) from labelfile
			where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name
	FROM  paydetail pd
		Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
		Join legheader lh on pd.lgh_number = lh.lgh_number
		INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = oh.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or oh.rowsec_rsrv_id is null)
		LEFT OUTER JOIN thirdpartyprofile tpr on (pd.asgn_type = 'TPR' and pd.asgn_id = tpr.tpr_id)
	WHERE pd.asgn_type = 'TPR'
		and pd.pyd_status = @status
		and pd.pyd_transdate BETWEEN @loenddate AND @hienddate
		and ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR
			(@acct_type = pd.pyd_prorap))
		and (@tpr_id = 'UNKNOWN' or pd.asgn_id = @tpr_id)
		and (@tpr_type = 'UNKNOWN' or ISNULL(tpr.tpr_type, 'UNK') = @tpr_type)
		and (ISNULL(@p_revtype1, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype1, 'UNK') = @p_revtype1)
		and (ISNULL(@p_revtype2, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype2, 'UNK') = @p_revtype2)
		and (ISNULL(@p_revtype3, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype3, 'UNK') = @p_revtype3)
		and (ISNULL(@p_revtype4, 'UNK') = 'UNK' or ISNULL(oh.ord_revtype4, 'UNK') = @p_revtype4)
		and (ISNULL(@lghtype1, 'UNK') = 'UNK' or ISNULL(lh.lgh_type1, 'UNK') = @lghtype1)
		and (ISNULL(@p_pyd_workcycle_status, 'UNK') = 'UNK' or ISNULL(pd.pyd_workcycle_status, 'UNK') = @p_pyd_workcycle_status)
   End
END -- TPR

if @tobeaudited = 'Y'
begin
	--85922 remove pay details that do not need audited
	delete t
	from #trips t
	join paytype p on p.pyt_itemcode = t.pyt_itemcode
	where isnull(p.pyt_requireaudit,'N') = 'N'

	--85922 and remove trips that do not have released pay details
	--(it is in the spec)
	delete t
	from #trips t
	where not exists (select 1 from paydetail pd where pd.lgh_number = t.lgh_number and (pd.pyd_status in ('PND', 'REL', 'XFR')))
end

 If ( @lostartdate is not null and 
		@histartdate is not null and 
			( @lostartdate <> '1950-01-01 00:00:00.000' OR  @histartdate <> '2049-12-31 23:59:59.992' ) )
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
		 delete from #tmpAsgnNbrAsgnDate where asgn_date between @lostartdate and @histartdate 
		  If ( select count(v_ident_count) from #tmpAsgnNbrAsgnDate )  > 0
		 Begin				 
			delete from #trips where  #trips.v_ident_count in (select v_ident_count from #tmpAsgnNbrAsgnDate )  
		 End
 
		IF OBJECT_ID(N'tempdb..##tmpAsgnNbrAsgnDate', N'U') IS NOT NULL 
		DROP TABLE #tmpAsgnNbrAsgnDate		
 
	END		
 -- PTS 63566.end	-- End of Apply @lostartdate / @histartdate dates 		

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
			( bdt_required_for_fgt_event in ('PUP','APUP', 'FPUP', 'ASTOP') AND		-- LOR  PTS# 106665
              EXISTS(
                 SELECT *
                   FROM stops s
                  WHERE s.ord_hdrnumber = t.ord_hdrnumber AND
                        s.lgh_number = t.lgh_number AND
                        s.stp_type = 'PUP' )
            )
            OR
            --( bdt_required_for_fgt_event = 'DRP' AND
			( bdt_required_for_fgt_event in ('DRP', 'ADRP', 'LDRP', 'ASTOP') AND		-- LOR  PTS# 106665
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

--LOR PTS# 30053
if @sch_date1 > convert(datetime, '1950-01-01 00:00') OR
      @sch_date2 < convert(datetime, '2049-12-31 23:59')

   Delete from #trips
   where #trips.ord_hdrnumber > 0 and
         #trips.ord_hdrnumber in (select ord_hdrnumber
                           from stops
                           where stp_sequence = 1 and
                           (stp_schdtearliest > @sch_date2  or
                              stp_schdtearliest < @sch_date1))
-- LOR

-- PTS 32781 - DJM - Remove records that don't meet the Invoice Status requirement.
if @inv_status <> ',UNK,' AND @inv_status is not null
   Delete from #trips
   where not exists (select 1 from Invoiceheader i
      where #trips.ord_hdrnumber = i.ord_hdrnumber
         and i.ord_hdrnumber > 0
         and (charindex(',' + isNull(i.ivh_invoicestatus,'UNK')+ ',',@inv_status) > 0
            OR charindex(',' + isNull(i.ivh_mbstatus,'NTP') + ',',@inv_status) > 0 ))

----**********  NOTE (gap 74): Original Proc did not acknowledge branch. so if trackbranch = N then IGNORE brn_id.

If exists (select * from generalinfo where gi_name = 'TrackBranch' and gi_string1 = 'Y')
   BEGIN
      -- remove any null value records (If TrackBranch = 'Y' remove any null values if any.)
      Delete from #trips where lgh_booked_revtype1 IS NULL -- remove any NULL value records.

      IF @brn_id <> ',UNKNOWN,'
         BEGIN
            Delete from #trips
            where lgh_booked_revtype1 in (select lgh_booked_revtype1 from #trips
                                   where CHARINDEX(',' + lgh_booked_revtype1 + ',', @brn_id) = 0 )
         END
      ELSE
         BEGIN
            If exists (select * from generalinfo where gi_name = 'BRANCHUSERSECURITY' and gi_string1 = 'Y')
            BEGIN
               -- if branch security is ON then get data, else, do not delete.
                     -- if branch id = 'unknown' bring back ALL branch IDs the user is ALLOWED to see.
                     SELECT brn_id
                     INTO #temp_user_branch
                     FROM branch_assignedtype
                     WHERE bat_type = 'USERID'
                     and brn_id <> 'UNKNOWN'
                     AND bat_value  =  @G_USERID

                     Delete from #trips
                     where lgh_booked_revtype1 NOT IN ( select brn_id from #temp_user_branch)
            END
         END
   END
-- PTS 41389 GAP 74 (end)

-- PTS 46402 <<start>>
-- Restrict based on Invoice billto
select @p_ivh_billto = isnull(@p_ivh_billto,'UNKNOWN')
if isNull(@p_ivh_billto,'UNKNOWN') <> 'UNKNOWN'
   delete from #trips
   where not exists (select 1 from Invoiceheader i
      where #trips.ord_hdrnumber = i.ord_hdrnumber
         and i.ord_hdrnumber > 0
         and isnull(i.ivh_billto,'UNKNOWN') = @p_ivh_billto)
-- PTS 46402 <<end>>

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
		LEFT(drivername, 45) 'drivername',   --PTS 63566  bring back to 45 (from 80)
		paperwork,
		lgh_type1,
		'LghType1',
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
GRANT EXECUTE ON  [dbo].[d_view_trips_by_paystatus_sp] TO [public]
GO
