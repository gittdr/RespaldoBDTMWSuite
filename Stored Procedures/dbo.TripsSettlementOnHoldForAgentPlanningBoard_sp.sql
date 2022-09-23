SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[TripsSettlementOnHoldForAgentPlanningBoard_sp] (
 @status varchar(6), ----> Must be 'HLD' ?
 @drvyes varchar(3),  
 @trcyes varchar(3), 
 @trlyes varchar(3), 
 @caryes varchar(3),
 @tpryes varchar(3), 
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
 -- PTS 16945 -- BL
 @beg_invoice_bill_date datetime,
 @end_invoice_bill_date datetime,
 @sch_date1 datetime,
 @sch_date2 datetime,
 @tpr_id varchar(8),
 @tpr_type varchar(12),
 @thirdpartytype1 varchar(6), ----> Must be 'AGENT' ?
 @thirdpartytype2 varchar(6),
 @thirdpartytype3 varchar(6),
 @thirdpartytype4 varchar(6),
 @p_revtype1 varchar(6),
 @p_revtype2 varchar(6),
 @p_revtype3 varchar(6),
 @p_revtype4 varchar(6),
 @inv_status	varchar(100),
 @tprtype1 char(1),
 @tprtype2 char(1),
 @tprtype3 char(1),
 @tprtype4 char(1),
 @tprtype5 char(1),
 @tprtype6 char(1),
 @brn_id varchar(256),     -- PTS 41389 GAP 74
 @G_USERID varchar(14),   -- PTS 41389 GAP 74
 @p_ivh_billto varchar(8),	-- PTS 46402
 @p_pyd_workcycle_status varchar(30), -- PTS 47021
 @resourcetypeonleg char(1),
 @ptoyes varchar(3),
 @pto_id varchar(12),
 @ptotype1 varchar(6),
 @ptotype2 varchar(6),
 @ptotype3 varchar(6),
 @ptotype4 varchar(6)
)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --9/14/2011 wkeckha: added while waiting for TMW to get permanent fix. proc was deadlocking.
/**
 *
 * NAME:
 * dbo.TripsSettlementOnHoldForAgentPlanningBoard_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Proc for dw TripsSettlementOnHoldForAgentPlanningBoard_sp
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * .....
 * 035 - @sch_date1 datetime	sch earliest datetime from
 * 036 - @sch_date1 datetime	sch earliest datetime to
 *
 * REVISION HISTORY:
-- JET - 10/26/99 - PTS #6631, removed joins to the asset assignment table.
--	All the information that it is verified against the asset assignment table is stored
--	with the pay details.  The information on the pay details is more exact, so it should
--	be used.  The trips on hold queue is to release any pay details on hold that match
--	the entered criteria.  The only queue that needs to look at asset assignment records
--	is the trips ready to settle.  This queue is looking for trips that may not have
--	any pay details.  Any queue that is based on pay details that exist should not look
--	to the asset assignment table.
--
-- PTS 16945 - 5/2/03 - BAL - Allow user to filter data by invoice billing date
--
-- PTS 19738 - 2/2/05 - DJM - Expand the asgn_id column in the temp table to 13 characters to
--			allow for trl_id.  Changed use of trl_number in the Trailer section to
--			link paydetail and trailerprofile by trl_id.
 * LOR	PTS# 30053	added sch earliest dates
 * MRH 31225 2/10/06 3rd party pay.
 *	PTS 32781 - DJM - Added revtypes and Invoice Status as parameters.
 *	LOR	PTS# 31389	agent pay in queues
-- PTS 35646 - 1/31/07 - SLM - Create a General Info setting to use the Arrivaldate on the last
--                             stop of the trip segment instead of the pyd_transdate in the
--                             criteria used to display the pay details.
-- PTS 36869 6/4/07 EMK - Added required for invoice check to paperwork
-- PTS 41389 GAP 74  JSwindell 3/31/2008  Add parameter brn_id (branch id) aka lgh_booked_revtype1 & ord_booked_revtype1 
* LOR	PTS# 42881	added asgn_controlling - flag for lead/co-drv
-- PTS 46402 JSwindell 3-30-2009  Add ivh_billto as a parameter:  p_ivh_billto
-- PTS 47021  7-24-2009: Argument & result set:  pyd_workcycle_status varchar(30), pyd_prorap char(1)
-- PTS 48237 - DJM - Added option to restrict Driver and Tractor types against the Legheader values instead of the Profile values.
-- PTS 55221 CCI 2/16/11:  Rewrote paperwork to fix split trips when using 'LEG' level; also fixed retired paperwork label files when in 'A' mode.
-- PTS 59057 vjh 10/03/2011 add setting to help with locking per Mindy Curnutt
-- PTS 75902 nloke this is modified copy of d_view_trips_by_paystatus for .net Back Office Scroll
-- PTS 80721 | 2014/07/24 | AVANE - Add support for new third party types (follow convention of other assets, which have xyzType1-4)
-- PTS 81134 | 2014/08/07 | AVANE - Add support for filtering trips by PayTo information
-- PTS 81134 | 2014/10/20 | AVANE - change PayTo filters to strictly filter to "settle by PayTo" functionality (pto_stlByPayTo)
-- PTS 93273 | 2015/9/1   | GulabT - Filter out trips from queue that are not related to Agent Pay
-- PTS 93273 | 2015/11/6   | GulabT - In case of Carriers, instead of overwriting Assignment ID with Pay to Id, update the AssignPayTo 
-- PTS 104851 | 2016/08/19 | AV - Provide filtering of Thirdpartyassignment ThirdPartyType1-4 values
-- PTS 105064 | 2016/08/30 | AV - DBA Standards Fixes
**/

-- PTS 41389 GAP 74 Start
IF @brn_id = NULL or @brn_id = '' or @brn_id  = 'UNK' 
	begin
		SELECT @brn_id = 'UNKNOWN'	
	end 

SELECT @brn_id = ',' + LTRIM(RTRIM(ISNULL(@brn_id, '')))  + ','
-- PTS 41389 GAP 74 end


Declare @paperworkchecklevel varchar(6),
 @paperworkmode varchar(3),
 @agent varchar(3),
 @usearrivaldate char(1) -- PTS 35646

CREATE TABLE #trips (mov_number int null,
 o_cty_nmstct varchar(25) null,
 d_cty_nmstct varchar(25) null,
 lgh_startdate datetime null,
 lgh_enddate datetime null,
 ord_originpoint varchar(8) null,
 ord_destpoint varchar(8) null,
 ord_startdate datetime null,
 ord_completiondate datetime null,
 asgn_id varchar(13) null,		--PTS 19738 - FJM
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
 drivername varchar(45) null,
 paperwork smallint null,
 lgh_type1 varchar(6) null,
 -- PTS 16945 -- BL
 ivh_billdate datetime Null,
 ivh_invoicenumber varchar(12) Null,
 --PTS 19038 RE
 pyt_itemcode varchar(6) Null,
 pyd_authcode varchar(30) Null,
 pyd_number		int			null, -- 28117 JD
 ord_revtype1	varchar(6)	null,
 ord_revtype2	varchar(6)	null,
 ord_revtype3	varchar(6)	null,
 ord_revtype4	varchar(6)	null,
 lgh_booked_revtype1 varchar(20) null,  -- PTS 41389  GAP 74
 asgn_controlling varchar(1) null,
 pyd_workcycle_status varchar(30) null,		-- PTS 47021
 pyd_prorap char(1)	null,					-- PTS 47021
 stp_schdtearliest datetime Null,	-- PTS 47740 - 50169
 ord_route varchar(18) Null,			-- PTS 47740 - 50169
 Cost money Null,					-- PTS 47740 - 50169
 ord_revtype1_name varchar(20) Null,	-- PTS 47740 - 50169
 ord_revtype2_name varchar(20) Null,	-- PTS 47740 - 50169
 ord_revtype3_name varchar(20) Null,	-- PTS 47740 - 50169
 ord_revtype4_name varchar(20) Null,	-- PTS 47740 - 50169
 asgn_payto varchar(12) null
)

Create index #idx_ord on #trips(ord_hdrnumber)


-- PTS 55221
CREATE TABLE #requiredpaperwork ( 
   ord_hdrnumber INT NULL , 
   lgh_number INT NULL , 
   abbr VARCHAR(6) NULL ) 
--CREATE TABLE #paperwork
--       (total_required INT NULL,
--        required_count INT NULL,
--        ord_hdrnumber INT NULL,
--	    ord_billto varchar(8) NULL)

-- PTS 21386 -- BL (start)
-- Get GENERALINFO 'PaperWork' settings
-- PTS 55221 - check for nulls in one place
SELECT @paperworkchecklevel = ISNULL( ( SELECT gi_string1 FROM generalinfo WHERE upper(gi_name) = 'PAPERWORKCHECKLEVEL' ), 'ORD' ) 
SELECT @paperworkmode = ISNULL( ( SELECT gi_string1 FROM generalinfo WHERE upper(gi_name) = 'PAPERWORKMODE' ), 'A' ) 
-- PTS 21386 -- BL (end)

-- PTS 3223781 - DJM
SELECT @inv_status = ',' + LTRIM(RTRIM(ISNULL(@inv_status, 'UNK'))) + ','

-- PTS 35646 - SLM 1/31/07
SELECT @usearrivaldate = gi_string1 from generalinfo where upper(gi_name) = 'USEARRIVALDATE'

DECLARE @tmp_pto TABLE
( pto_id          VARCHAR(12)  NULL
, pto_type1        VARCHAR(6) NULL
, pto_type2        VARCHAR(6) NULL
, pto_type3        VARCHAR(6) NULL
, pto_type4        VARCHAR(6) NULL
)

-- Grab all pay tos by search filters
INSERT INTO @tmp_pto
SELECT Distinct
        pto_id
        , pto_type1
        , pto_type2
        , pto_type3
        , pto_type4
FROM payto
JOIN RowRestrictValidAssignments_payto_fn() rsva ON payto.rowsec_rsrv_id = rsva.rowsec_rsrv_id OR rsva.rowsec_rsrv_id = 0
WHERE (@pto_id   = pto_id OR @pto_id   = 'UNKNOWN')
    AND (@ptotype1 = 'UNK'  OR @ptotype1 = pto_type1)
    AND (@ptotype2 = 'UNK'  OR @ptotype2 = pto_type2)
    AND (@ptotype3 = 'UNK'  OR @ptotype3 = pto_type3)
    AND (@ptotype4 = 'UNK'  OR @ptotype4 = pto_type4)
    AND (ISNULL(pto_stlByPayTo, 0) = 1)

-- GET DRIVER DATA IF NEEDED
--IF SUBSTRING(@types, 1, 3) = 'DRV'
If @drvyes <> 'XXX'
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
			lh.lgh_booked_revtype1,	-- PTS 41389 GAP 74  
			asgn_controlling = (select asgn_controlling from assetassignment aa where pd.asgn_number = aa.asgn_number),
			pd.pyd_workcycle_status,						-- PTS 47021
			pyd_prorap, 									    -- PTS 47021
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
				where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name,
            -- PTS 47740 <<end>>
            null --asgn_payto
  FROM paydetail pd
		Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
		Join legheader lh on pd.lgh_number = lh.lgh_number
  WHERE pd.asgn_type = 'DRV'
    AND pd.pyd_status = @status
    AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
    AND ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
    AND exists (select * from assetassignment aa where pd.asgn_number = aa.asgn_number AND aa.pyd_status = 'PPD')
   	--PTS 38816 JJF 20080312 add additional needed parms
    	--PTS 51570 JJF 20100510 
    --AND dbo.RowRestrictByUser (oh.ord_belongsto, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
    --PTS 56468 JJF 20110325 - handle empty moves (no order)
    --AND dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
    --AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null) 	-- 11/29/2007 MDH PTS 40119: Added
	--END PTS 56468 JJF 20110325 - handle empty moves (no order)

	IF @driver <> 'UNKNOWN'
		delete #trips  where asgn_type = 'DRV' and asgn_id <> @driver

	IF @company <> 'UNK'
		delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_company <> @company

	IF @fleet <> 'UNK'
		delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_fleet <> @fleet

	IF @division <> 'UNK'
		delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_division <> @division

	IF @terminal <> 'UNK'
		delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_terminal <> @terminal
/*
	IF @drvtype1 <> 'UNK'
		delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type1 <> @drvtype1

	IF @drvtype2 <> 'UNK'
		delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type2 <> @drvtype2

	IF @drvtype3 <> 'UNK'
		delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type3 <> @drvtype3

	IF @drvtype4 <> 'UNK'
		delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type4 <> @drvtype4
*/
--PTS 48237 - DJM
	if @resourcetypeonleg = 'Y'
		Begin
			IF @drvtype1 <> 'UNK'
				delete #trips from legheader l where asgn_type = 'DRV' and l.lgh_number = #trips.lgh_number and isNull(#trips.lgh_number,0) > 0 and l.mpp_type1 <> @drvtype1

			IF @drvtype2 <> 'UNK'
				delete #trips from legheader l where asgn_type = 'DRV' and l.lgh_number = #trips.lgh_number and isNull(#trips.lgh_number,0) > 0 and l.mpp_type2 <> @drvtype2

			IF @drvtype3 <> 'UNK'
				delete #trips from legheader l where asgn_type = 'DRV' and l.lgh_number = #trips.lgh_number and isNull(#trips.lgh_number,0) > 0 and l.mpp_type3 <> @drvtype3
			
			IF @drvtype4 <> 'UNK'
				delete #trips from legheader l where asgn_type = 'DRV' and l.lgh_number = #trips.lgh_number and isNull(#trips.lgh_number,0) > 0 and l.mpp_type4 <> @drvtype4
	
		End
	else
		Begin

			IF @drvtype1 <> 'UNK'
				delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type1 <> @drvtype1

			IF @drvtype2 <> 'UNK'
				delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type2 <> @drvtype2

			IF @drvtype3 <> 'UNK'
				delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type3 <> @drvtype3
			
			IF @drvtype4 <> 'UNK'
				delete #trips from manpowerprofile tp where asgn_type = 'DRV' and asgn_id = tp.mpp_id and mpp_type4 <> @drvtype4
		end
		
	Update #trips set drivername = mpp_lastfirst, asgn_payto = mpp_payto from manpowerprofile where asgn_type = 'DRV' and asgn_id = mpp_id	

END -- end driver

-- GET TRACTOR DATA IF NEEDED
--IF SUBSTRING(@types, 4, 3) = 'TRC'
If @trcyes <> 'XXX'
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
			  -- -1,
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
			 lh.lgh_booked_revtype1,	-- PTS 41389 GAP 74  
			 asgn_controlling = (select asgn_controlling from assetassignment aa where pd.asgn_number = aa.asgn_number),
			 pd.pyd_workcycle_status, 						-- PTS 47021
			 pyd_prorap, 									    -- PTS 47021
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
				where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name, 
			 -- PTS 47740 <<end>>
             null as asgn_payto
  FROM paydetail pd
		Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
		Join legheader lh on pd.lgh_number = lh.lgh_number
  WHERE pd.asgn_type = 'TRC'
    AND pd.pyd_status = @status
    AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate  -- JD 32041 make the tractor trans date restrictions match the other dates.
    AND ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
	AND exists (select * from assetassignment aa where pd.asgn_number = aa.asgn_number  AND aa.pyd_status = 'PPD')
	--PTS 38816 JJF 20080312 add additional needed parms
    	--PTS 51570 JJF 20100510 
    --AND dbo.RowRestrictByUser (oh.ord_belongsto, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
    --PTS 56468 JJF 20110325 - handle empty moves (no order)
    --AND dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
    --AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null)	-- 11/29/2007 MDH PTS 40119: Added
	--END PTS 56468 JJF 20110325 - handle empty moves (no order)

    IF @tractor <> 'UNKNOWN'
		delete #trips  where asgn_type = 'TRC' and asgn_id <> @tractor

	IF @company <> 'UNK'
		delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_company <> @company

	IF @fleet <> 'UNK'
		delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_fleet <> @fleet

	IF @division <> 'UNK'
		delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_division <> @division

	IF @terminal <> 'UNK'
		delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_terminal <> @terminal

	/*IF @trctype1 <> 'UNK'
		delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_type1 <> @trctype1

	IF @trctype2 <> 'UNK'
		delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_type2 <> @trctype2

	IF @trctype3 <> 'UNK'
		delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_type3 <> @trctype3

	IF @trctype4 <> 'UNK'
		delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_type4 <> @trctype4
	*/
	
--PTS 48237 - DJM
	if @resourcetypeonleg = 'Y'
		Begin
			IF @trctype1 <> 'UNK'
				delete #trips from legheader l where asgn_type = 'TRC' and l.lgh_number = #trips.lgh_number and isNull(#trips.lgh_number,0) > 0 and l.trc_type1 <> @trctype1

			IF @trctype2 <> 'UNK'
				delete #trips from legheader l where asgn_type = 'TRC' and l.lgh_number = #trips.lgh_number and isNull(#trips.lgh_number,0) > 0 and l.trc_type2 <> @trctype2

			IF @trctype3 <> 'UNK'
				delete #trips from legheader l where asgn_type = 'TRC' and l.lgh_number = #trips.lgh_number and isNull(#trips.lgh_number,0) > 0 and l.trc_type3 <> @trctype3
			
			IF @trctype4 <> 'UNK'
				delete #trips from legheader l where asgn_type = 'TRC' and l.lgh_number = #trips.lgh_number and isNull(#trips.lgh_number,0) > 0 and l.trc_type4 <> @trctype4

		end
	else
		Begin
			IF @trctype1 <> 'UNK'
				delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_type1 <> @trctype1

			IF @trctype2 <> 'UNK'
				delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_type2 <> @trctype2

			IF @trctype3 <> 'UNK'
				delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_type3 <> @trctype3

			IF @trctype4 <> 'UNK'
				delete #trips from tractorprofile tp where asgn_type = 'TRC' and asgn_id = tp.trc_number and trc_type4 <> @trctype4

		end

	update #trips set drivername = trc_make + ', ' + trc_model, asgn_payto = trc_owner from tractorprofile where asgn_type = 'TRC' and asgn_id = trc_number

END -- END TRC


-- GET TRAILER DATA IF NEEDED
--IF SUBSTRING(@types, 7, 3) = 'TRL'
If @trlyes <> 'XXX'
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
			  lh.lgh_booked_revtype1,	-- PTS 41389 GAP 74  
			  asgn_controlling = (select asgn_controlling from assetassignment aa where pd.asgn_number = aa.asgn_number),
			  pd.pyd_workcycle_status, 						-- PTS 47021
			  pyd_prorap, 									    -- PTS 47021
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
				where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name, 
			  -- PTS 47740 <<end>>
             null as asgn_payto
  FROM paydetail pd
		Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
		Join legheader lh on pd.lgh_number = lh.lgh_number
  WHERE pd.asgn_type = 'TRL'
    AND pd.pyd_status = @status
    AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
    AND ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
	AND exists (select * from assetassignment aa where pd.asgn_number = aa.asgn_number  AND aa.pyd_status = 'PPD')
  	--PTS 38816 JJF 20080312 add additional needed parms
   	--PTS 51570 JJF 20100510 
    --AND dbo.RowRestrictByUser (oh.ord_belongsto, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
    --PTS 56468 JJF 20110325 - handle empty moves (no order)
    --AND dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
    --AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null)	-- 11/29/2007 MDH PTS 40119: Added
	--END PTS 56468 JJF 20110325 - handle empty moves (no order)

	IF @trailer <> 'UNKNOWN'
		delete #trips  where asgn_type = 'TRL' and asgn_id <> @trailer

	IF @company <> 'UNK'
		delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_company <> @company

	IF @fleet <> 'UNK'
		delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_fleet <> @fleet

	IF @division <> 'UNK'
		delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_division <> @division

	IF @terminal <> 'UNK'
		delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_terminal <> @terminal

	IF @trltype1 <> 'UNK'
		delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_type1 <> @trltype1

	IF @trltype2 <> 'UNK'
		delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_type2 <> @trltype2

	IF @trltype3 <> 'UNK'
		delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_type3 <> @trltype3

	IF @trltype4 <> 'UNK'
		delete #trips from trailerprofile tp where asgn_type = 'TRL' and asgn_id = tp.trl_id and trl_type4 <> @trltype4

	Update #trips set drivername = trl_make + ', ' + trl_model, asgn_payto = trl_owner from trailerprofile where asgn_type = 'TRL' and asgn_id = trl_id

END

-- GET CARRIER DATA IF NEEDED
--IF SUBSTRING(@types, 10, 3) = 'CAR'
If @caryes <> 'XXX'
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
				  lh.lgh_booked_revtype1,	-- PTS 41389 GAP 74  
				  asgn_controlling = (select asgn_controlling from assetassignment aa where pd.asgn_number = aa.asgn_number),
				  pd.pyd_workcycle_status, 						-- PTS 47021
				  pyd_prorap, 									    -- PTS 47021
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
						where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name,
				  -- PTS 47740 <<end>>
                  null as asgn_payto
		FROM paydetail pd
			Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
			Join legheader lh on pd.lgh_number = lh.lgh_number
            Join stops s on pd.lgh_number = s.lgh_number
        WHERE pd.asgn_type = 'CAR'
          AND pd.pyd_status = @status
          --PTS 35646 SLM 2/20/2007
          --		          AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
          AND s.stp_arrivaldate BETWEEN @loenddate AND @hienddate
          AND ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
          AND  exists (select * from assetassignment aa where pd.asgn_number = aa.asgn_number  AND aa.pyd_status = 'PPD')
    --PTS 38816 JJF 20080312 add additional needed parms
   	--PTS 51570 JJF 20100510 
    --AND dbo.RowRestrictByUser (oh.ord_belongsto, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
    --PTS 56468 JJF 20110325 - handle empty moves (no order)
    --AND dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
    --AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null)	-- 11/29/2007 MDH PTS 40119: Added
	--END PTS 56468 JJF 20110325 - handle empty moves (no order)

		IF @carrier <> 'UNKNOWN'
			delete #trips  where asgn_type = 'CAR' and asgn_id <> @carrier

		IF @cartype1 <> 'UNK'
			delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and car_type1 <> @cartype1

		IF @cartype2 <> 'UNK'
			delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and car_type2 <> @cartype2

		IF @cartype3 <> 'UNK'
			delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and car_type3 <> @cartype3

		IF @cartype4 <> 'UNK'
			delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and car_type4 <> @cartype4

	    Update #trips set drivername = car_name, asgn_payto = pto_id from carrier where asgn_type = 'CAR' and asgn_id = car_id
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
				  lh.lgh_booked_revtype1,	-- PTS 41389 GAP 74  
				  asgn_controlling = (select asgn_controlling from assetassignment aa where pd.asgn_number = aa.asgn_number),
				  pd.pyd_workcycle_status, 						-- PTS 47021
				  pyd_prorap, 									    -- PTS 47021
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
						where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name, 
					-- PTS 47740 <<end>>
                  null as asgn_payto
	  FROM paydetail pd
			Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
			Join legheader lh on pd.lgh_number = lh.lgh_number
	  WHERE pd.asgn_type = 'CAR'
	    AND pd.pyd_status = @status
		AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
	    AND ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
		AND  exists (select * from assetassignment aa where pd.asgn_number = aa.asgn_number  AND aa.pyd_status = 'PPD')
	   	--PTS 38816 JJF 20080312 add additional needed parms
   		--PTS 51570 JJF 20100510 
		--AND dbo.RowRestrictByUser (oh.ord_belongsto, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
		--PTS 56468 JJF 20110325 - handle empty moves (no order)
		--AND dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
		--AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null) 	-- 11/29/2007 MDH PTS 40119: Added
		--END PTS 56468 JJF 20110325 - handle empty moves (no order)

		IF @carrier <> 'UNKNOWN'
			delete #trips  where asgn_type = 'CAR' and asgn_id <> @carrier

		IF @cartype1 <> 'UNK'
			delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and car_type1 <> @cartype1

		IF @cartype2 <> 'UNK'
			delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and car_type2 <> @cartype2

		IF @cartype3 <> 'UNK'
			delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and car_type3 <> @cartype3

		IF @cartype4 <> 'UNK'
			delete #trips from carrier tp where asgn_type = 'CAR' and asgn_id = tp.car_id and car_type4 <> @cartype4

		Update #trips set drivername = car_name, asgn_payto = pto_id from carrier where asgn_type = 'CAR' and asgn_id = car_id
	END
END -- end carrier

-- MRH 31225 Third party
--IF SUBSTRING(@types, 13, 3) = 'TPR'
If @tpryes <> 'XXX'
BEGIN
	--	LOR	PTS# 31839
	select @agent = Upper(LTrim(RTrim(gi_string1))) from generalinfo where gi_name = 'AgentCommiss'
	If @agent = 'Y' or @agent = 'YES'
    begin
        declare @tprTypeMode int
        select @tprTypeMode = ISNULL(gi_integer1, 2) from generalinfo where gi_name = 'ThirdPartyTypes'

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
					pd.pyd_workcycle_status,   						-- PTS 47021
					pd.pyd_prorap, 								-- PTS 47021
					asgn_payto)
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
					oh.ord_booked_revtype1,	-- PTS 41389 GAP 74
					'Y',
					pd.pyd_workcycle_status, 						-- PTS 47021
					pyd_prorap,									    -- PTS 47021
                    null as asgn_payto
		FROM paydetail pd
			Left Outer Join orderheader oh on pd.ord_hdrnumber = oh.ord_hdrnumber and
					((pd.asgn_id = oh.ord_thirdpartytype1 AND oh.ord_pyd_status_1 = 'PPD') or
					 (pd.asgn_id = oh.ord_thirdpartytype2 AND oh.ord_pyd_status_2 = 'PPD'))
			Join thirdpartyprofile tpr on pd.asgn_id = tpr.tpr_id
		WHERE pd.pyd_status = @status
		  AND pd.asgn_type = 'TPR'
		  AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
		  AND @tpr_id IN ('UNKNOWN', pd.asgn_id)
		  AND (@tprTypeMode <> 2 AND (@tprtype1 in ('N', 'X') OR (@tprtype1 = 'Y' AND @tprtype1 = tpr_thirdpartytype1)))
		  AND (@tprTypeMode <> 2 AND (@tprtype2 in ('N', 'X') OR (@tprtype2 = 'Y' AND @tprtype2 = tpr_thirdpartytype2)))
		  AND (@tprTypeMode <> 2 AND (@tprtype3 in ('N', 'X') OR (@tprtype3 = 'Y' AND @tprtype3 = tpr_thirdpartytype3)))
		  AND (@tprTypeMode <> 2 AND (@tprtype4 in ('N', 'X') OR (@tprtype4 = 'Y' AND @tprtype4 = tpr_thirdpartytype4)))
		  AND (@tprTypeMode <> 2 AND (@tprtype5 in ('N', 'X') OR (@tprtype5 = 'Y' AND @tprtype5 = tpr_thirdpartytype5)))
		  AND (@tprTypeMode <> 2 AND (@tprtype6 in ('N', 'X') OR (@tprtype6 = 'Y' AND @tprtype6 = tpr_thirdpartytype6)))
          AND (@tprTypeMode = 2 AND (@thirdpartytype1 = 'UNK' or @thirdpartytype1 = tpr.ThirdPartyType1))
          AND (@tprTypeMode = 2 AND (@thirdpartytype2 = 'UNK' or @thirdpartytype2 = tpr.ThirdPartyType2))
          AND (@tprTypeMode = 2 AND (@thirdpartytype3 = 'UNK' or @thirdpartytype3 = tpr.ThirdPartyType3))
          AND (@tprTypeMode = 2 AND (@thirdpartytype4 = 'UNK' or @thirdpartytype4 = tpr.ThirdPartyType4))
		  AND ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR (@acct_type = pd.pyd_prorap))
 	    --PTS 38816 JJF 20080312 add additional needed parms
		--PTS 51570 JJF 20100510 
		--AND dbo.RowRestrictByUser (oh.ord_belongsto, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
		--PTS 56468 JJF 20110325 - handle empty moves (no order)
		--AND dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
		--AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null)	-- 11/29/2007 MDH PTS 40119: Added
		--END PTS 56468 JJF 20110325 - handle empty moves (no order)
    end
	Else
	Begin
--	LOR
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
			  pd.pyd_workcycle_status, 						-- PTS 47021
			  pyd_prorap, 									    -- PTS 47021
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
					where ( labelfile.userlabelname > '' ) AND labelfile.labeldefinition  = 'REVTYPE4') ord_revtype4_name, 
				-- PTS 47740 <<end>>
              null as asgn_payto
         FROM 	paydetail pd
				Left Outer Join orderheader oh on pd.mov_number = oh.mov_number
				Join legheader lh on pd.lgh_number = lh.lgh_number
				----- PTS #82285
			    INNER JOIN thirdpartyassignment tpa ON (pd.asgn_number = tpa.tpr_number)
			    ----- The end of PTS #82285
         WHERE pd.asgn_type = 'TPR'
          AND pd.pyd_status = @status ----> Must be 'HLD' ?
	      AND pd.pyd_transdate BETWEEN @loenddate AND @hienddate
	      AND (@thirdpartytype1 = 'UNK' OR @thirdpartytype1 = tpa.ThirdPartyType1)
          AND (@thirdpartytype2 = 'UNK' OR @thirdpartytype2 = tpa.ThirdPartyType2)
          AND (@thirdpartytype3 = 'UNK' OR @thirdpartytype3 = tpa.ThirdPartyType3)
          AND (@thirdpartytype4 = 'UNK' OR @thirdpartytype4 = tpa.ThirdPartyType4)
		  AND ((@acct_type = 'X' AND pd.pyd_prorap IN('A', 'P')) OR
			   (@acct_type = pd.pyd_prorap))
          AND (@ptoyes = 'XXX' OR EXISTS(SELECT * FROM @tmp_pto WHERE pto_id = pd.pyd_payto))
       	--PTS 38816 JJF 20080312 add additional needed parms
			--PTS 51570 JJF 20100510 
			--AND dbo.RowRestrictByUser (oh.ord_belongsto, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
			--PTS 56468 JJF 20110325 - handle empty moves (no order)
			--AND dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1	-- 11/29/2007 MDH PTS 40119: Added
			--AND (dbo.RowRestrictByUser ('orderheader', oh.rowsec_rsrv_id, '', '', '') = 1 or oh.rowsec_rsrv_id is null)	-- 11/29/2007 MDH PTS 40119: Added
			--END PTS 56468 JJF 20110325 - handle empty moves (no order)

  IF @tpr_id <> 'UNKNOWN'
		delete #trips  where asgn_type = 'TPR' and asgn_id <> @tpr_id
	IF (@tpr_type <> 'UNKNOWN') AND (@tpr_type <> 'UNK')
		delete #trips from thirdpartyprofile tp where asgn_type = 'TPR' and asgn_id = tp.tpr_id and tpr_type <> @tpr_type

	-- Filter out trips that do not match ThirdPartyType1-4
	IF (@thirdpartytype1 <> 'UNK')
  BEGIN
		DELETE t
		FROM #trips t
		JOIN
		Thirdpartyassignment tpa ON
  		t.asgn_id = tpa.tpr_id AND t.lgh_number = tpa.lgh_number
		WHERE
  		t.asgn_type = 'TPR'
  		AND tpa.ThirdPartyType1 <> @thirdpartytype1
  END

	IF (@thirdpartytype2 <> 'UNK')
  BEGIN
		DELETE t
		FROM #trips t
		JOIN
		Thirdpartyassignment tpa ON
  		t.asgn_id = tpa.tpr_id AND t.lgh_number = tpa.lgh_number
		WHERE
  		t.asgn_type = 'TPR'
  		AND tpa.ThirdPartyType2 <> @thirdpartytype2
  END

	IF (@thirdpartytype3 <> 'UNK')
  BEGIN
		DELETE t
		FROM #trips t
		JOIN
		Thirdpartyassignment tpa ON
  		t.asgn_id = tpa.tpr_id AND t.lgh_number = tpa.lgh_number
		WHERE
  		t.asgn_type = 'TPR'
  		AND tpa.ThirdPartyType3 <> @thirdpartytype3
  END

	IF (@thirdpartytype4 <> 'UNK')
  BEGIN
		DELETE t
		FROM #trips t
		JOIN
		Thirdpartyassignment tpa ON
  		t.asgn_id = tpa.tpr_id AND t.lgh_number = tpa.lgh_number
		WHERE
  		t.asgn_type = 'TPR'
  		AND tpa.ThirdPartyType4 <> @thirdpartytype4
  END

	Update #trips set drivername = tpr_name, asgn_payto = tpr_payto from thirdpartyprofile where asgn_type = 'TPR' and asgn_id = tpr_id
	End
END -- TPR
-- End 31225

-- PTS 81134 - AVANE - Remove trips that don't qualify on settle by payto search filter
IF @ptoyes = 'XXX'
begin
    delete #trips  where #trips.asgn_payto IS NOT NULL AND EXISTS(SELECT * FROM @tmp_pto WHERE asgn_payto = pto_id)
end
else
begin
    delete #trips  where #trips.asgn_payto IS NULL OR NOT EXISTS(SELECT * FROM @tmp_pto WHERE asgn_payto = pto_id)
end

/* PTS 17873 - DJM - Remove rows that do not meet the lgh_type1 requiements  */
if @lghtype1 <> 'UNK'
 Delete from #trips where lgh_type1 <> @lghtype1


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
            ( bdt_required_for_fgt_event = 'PUP' AND 
              EXISTS( 
                 SELECT * 
                   FROM stops s 
                  WHERE s.ord_hdrnumber = t.ord_hdrnumber AND 
                        s.lgh_number = t.lgh_number AND 
                        s.stp_type = 'PUP' ) 
            ) 
            OR 
            ( bdt_required_for_fgt_event = 'DRP' AND 
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

---- JET - 5/19/99, did not make any better.  Originally this part of the query was topping out
----     at about 1 million in I/O.  It is no longer doing that.  I'll leave the change here
----     just incase this becomes ugly again.
----CREATE TABLE #paperwork
----       (total_required INT NULL,
----        required_count INT NULL,
----        ord_hdrnumber INT NULL)
----INSERT INTO #paperwork
----       SELECT COUNT(*), 0, ord_hdrnumber
----         FROM #trips
----       GROUP BY ord_hdrnumber
----UPDATE #paperwork
----   SET required_count = (SELECT COUNT(pw_received)
----                    FROM paperwork pw, labelfile lf
----                   WHERE pw.abbr = lf.abbr
----                         AND pw.ord_hdrnumber = #paperwork.ord_hdrnumber
----                         AND pw.pw_received = 'Y'
----                         AND lf.code < 100
----                         AND lf.labeldefinition = 'PaperWork')

---- COMPUTE PAPERWORK REQUIREMENTS
---- PTS 21386 -- BL (start)
----Insert into #paperwork
----SELECT COUNT(*) total_required,
---- 0 required_count,
---- #trips.ord_hdrnumber,
---- 'UNK      ' ord_billto
------INTO #paperwork
----FROM #trips, paperwork pw, labelfile lf
----WHERE pw.abbr =* lf.abbr
---- AND pw.ord_hdrnumber =* #trips.ord_hdrnumber
---- AND lf.labeldefinition = 'PaperWork'
---- AND lf.code < 100
----GROUP BY #trips.ord_hdrnumber

--Insert into #paperwork
--/*	LOR
--SELECT COUNT(*) total_required,
--		 0 required_count,
--		 newtrip.ord_hdrnumber,
--		 'UNK      ' ord_billto
----INTO #paperwork
--FROM (select distinct ord_hdrnumber from #trips) newtrip, paperwork pw, labelfile lf
--WHERE pw.abbr =* lf.abbr
-- AND pw.ord_hdrnumber =* newtrip.ord_hdrnumber
-- AND lf.labeldefinition = 'PaperWork'
-- AND lf.code < 100
--GROUP BY newtrip.ord_hdrnumber	*/
--SELECT total_required = (SELECT COUNT(*) from labelfile
--							WHERE labeldefinition = 'PaperWork' AND code < 100),
--		 0 required_count,
--		 newtrip.ord_hdrnumber,
--		 'UNK      ' ord_billto
--FROM (select distinct ord_hdrnumber from #trips) newtrip
--	Left Outer Join paperwork pw on newtrip.ord_hdrnumber = pw.ord_hdrnumber
--GROUP BY newtrip.ord_hdrnumber
----LOR
---- PTS 21386 -- BL (end)

--Update #paperwork
--set required_count = IsNull((Select COUNT(pw.pw_received) FROM  paperwork pw
-- WHERE pw.ord_hdrnumber = #paperwork.ord_hdrnumber
--     AND pw.pw_received = 'Y'
-- GROUP BY pw.ord_hdrnumber),0)

--Update #paperwork
--set #paperwork.ord_billto = Rtrim(isNull(orderheader.ord_billto,'UNK'))
--from orderheader
--where #paperwork.ord_hdrnumber = orderheader.ord_hdrnumber and
-- orderheader.ord_billto is not null

----PTS 40877 JJF 20080219
------ PTS 21386 -- BL (start)
------if @paperworkmode = 'A'
------ ONLY check paperwork that is required for the 'billto' on the Order
----if @paperworkmode = 'B'
------ PTS 21386 -- BL (end)
---- update #paperwork
---- set total_required = (select count(*) 
----						from billdoctypes 
----						where cmp_id = #paperwork.ord_billto 
----								and IsNull(billdoctypes.bdt_inv_required, 'Y') = 'Y' --PTS36869
----						), 
----   required_count = (select count(*)
----						from paperwork, billdoctypes
----						where #paperwork.ord_hdrnumber = paperwork.ord_hdrnumber
----								and paperwork.pw_received = 'Y'
----								and billdoctypes.cmp_id = #paperwork.ord_billto
----								and billdoctypes.bdt_doctype = paperwork.abbr
----								and IsNull(billdoctypes.bdt_inv_required, 'Y') = 'Y'--PTS 36869
----					) 
----
----if @paperworkchecklevel = 'LEG'
---- Update #paperwork
---- set required_count = required_count * (select count(distinct lgh_number) from stops where ord_hdrnumber = #paperwork.ord_hdrnumber)
--if @paperworkmode = 'B' BEGIN
--	IF @paperworkchecklevel = 'LEG' BEGIN
--		update #paperwork
--		set total_required = (select count(*) 
--								from billdoctypes 
--								where cmp_id = #paperwork.ord_billto 
--										and IsNull(billdoctypes.bdt_inv_required, 'Y') = 'Y' --PTS36869
--										and (ISNULL(bdt_required_for_application, 'B') = 'B' or bdt_required_for_application = 'I') 
--										and ((exists(select * 
--														from stops stp inner join #trips on #trips.lgh_number = stp.lgh_number
--														where #trips.ord_hdrnumber = #paperwork.ord_hdrnumber
--															and stp_type = 'PUP') 
--													and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'PUP'))
--												or (exists(select * 
--															from stops stp inner join #trips on #trips.lgh_number = stp.lgh_number
--															where #trips.ord_hdrnumber = #paperwork.ord_hdrnumber
--																and stp_type = 'DRP') 
--												and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'DRP')))
--							), 
--			required_count = (select count(*)
--								from paperwork, billdoctypes
--								where #paperwork.ord_hdrnumber = paperwork.ord_hdrnumber
--										and paperwork.pw_received = 'Y'
--										and billdoctypes.cmp_id = #paperwork.ord_billto
--										and billdoctypes.bdt_doctype = paperwork.abbr
--										and IsNull(billdoctypes.bdt_inv_required, 'Y') = 'Y'--PTS 36869
--										and (ISNULL(bdt_required_for_application, 'B') = 'B' or bdt_required_for_application = 'S') 
--										and ((exists(select * 
--														from stops stp inner join #trips on #trips.lgh_number = stp.lgh_number
--														where #trips.ord_hdrnumber = #paperwork.ord_hdrnumber
--															and stp_type = 'PUP') 
--													and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'PUP'))
--												or (exists(select * 
--														from stops stp inner join #trips on #trips.lgh_number = stp.lgh_number
--														where #trips.ord_hdrnumber = #paperwork.ord_hdrnumber
--															and stp_type = 'DRP') 
--												and (ISNULL(bdt_required_for_fgt_event, 'B') = 'B' or bdt_required_for_fgt_event = 'DRP')))
--					) 

--	END
--	ELSE BEGIN
--		 update #paperwork
--		 set total_required = (select count(*) 
--								from billdoctypes 
--								where cmp_id = #paperwork.ord_billto 
--										and IsNull(billdoctypes.bdt_inv_required, 'Y') = 'Y' --PTS36869
--										and (ISNULL(bdt_required_for_application, 'B') = 'B' or bdt_required_for_application = 'S') 
--								), 
--			required_count = (select count(*)
--								from paperwork, billdoctypes
--								where #paperwork.ord_hdrnumber = paperwork.ord_hdrnumber
--										and paperwork.pw_received = 'Y'
--										and billdoctypes.cmp_id = #paperwork.ord_billto
--										and billdoctypes.bdt_doctype = paperwork.abbr
--										and IsNull(billdoctypes.bdt_inv_required, 'Y') = 'Y'--PTS 36869
--										and (ISNULL(bdt_required_for_application, 'B') = 'B' or bdt_required_for_application = 'S') 
--							) 

--	END
--END

----END PTS 40877 JJF 20080219

--/* Update where all paperwork is in */
--UPDATE #trips
--   SET paperwork = 1
--  FROM #paperwork, #trips
-- WHERE #trips.ord_hdrnumber = #paperwork.ord_hdrnumber
--       AND #paperwork.total_required > 0
--       AND #paperwork.total_required <= #paperwork.required_count

--/* Update where all paperwork is not in */
---- PTS 21386 -- BL (start)
----UPDATE #trips
----   SET paperwork = 0
----  FROM #paperwork, #trips
---- WHERE #trips.ord_hdrnumber = #paperwork.ord_hdrnumber
----       AND #paperwork.total_required > 0
----       AND #paperwork.total_required > #paperwork.required_count
--UPDATE #trips
--   SET paperwork = -1
--  FROM #paperwork, #trips
-- WHERE #trips.ord_hdrnumber = #paperwork.ord_hdrnumber
--       AND #paperwork.total_required > 0
--       AND #paperwork.total_required > #paperwork.required_count
---- PTS 21386 -- BL (end)

--DROP TABLE #paperwork


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
	 from 	invoiceheader  where #trips.ord_hdrnumber > 0 and #trips.ord_hdrnumber = invoiceheader.ord_hdrnumber and
			invoiceheader.ivh_billdate = (select max(ivh_billdate) from invoiceheader b
												where #trips.ord_hdrnumber = b.ord_hdrnumber and invoiceheader.ivh_hdrnumber = b.ivh_hdrnumber)

	 Delete from #trips
	 where (ord_hdrnumber > 0 and ivh_billdate is NULL )
	 or (ord_hdrnumber > 0 and (ivh_billdate > @end_invoice_bill_date  or ivh_billdate < @beg_invoice_bill_date))


 -- Remove paydetails that do NOT fit in given invoice bill_date range
-- Delete from #trips
-- where ivh_billdate is NULL
-- or ivh_billdate > @end_invoice_bill_date
-- or ivh_billdate < @beg_invoice_bill_date
end
-- PTS 16945 -- BL (end)

--LOR	PTS# 30053
if @sch_date1 > convert(datetime, '1950-01-01 00:00') OR
      @sch_date2 < convert(datetime, '2049-12-31 23:59')

	Delete from #trips
	where #trips.ord_hdrnumber > 0 and
			#trips.ord_hdrnumber in (select ord_hdrnumber
									from stops
									where stp_sequence = 1 and
									(stp_schdtearliest > @sch_date2  or
										stp_schdtearliest < @sch_date1))
--	LOR

--PTS 32781 - DJM - If specifying a revtype, delete from #trips where the revtype is not what is specified
IF isNull(@p_revtype1,'UNK') <> 'UNK'
	DELETE FROM #trips WHERE isNull(#trips.ord_revtype1,'UNK') <> @p_revtype1
IF isNull(@p_revtype2,'UNK') <> 'UNK'
	DELETE FROM #trips WHERE isNull(#trips.ord_revtype2,'UNK') <> @p_revtype2
IF isNull(@p_revtype3,'UNK') <> 'UNK'
	DELETE FROM #trips WHERE isNull(#trips.ord_revtype3,'UNK') <> @p_revtype3
IF isNull(@p_revtype4,'UNK') <> 'UNK'
	DELETE FROM #trips WHERE isNull(#trips.ord_revtype4,'UNK') <> @p_revtype4
--PTS 32781

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

-- PTS 47021 <<start>>
Select @p_pyd_workcycle_status = ISNULL(@p_pyd_workcycle_status, 'UNK')
IF @p_pyd_workcycle_status <> 'UNK'
BEGIN
	delete from #trips where ISNULL(pyd_workcycle_status, 'UNK') <> @p_pyd_workcycle_status
END
-- PTS 47021 <<end>>

--PTS 93273 - remove trips from queue for orders not related to Agent Pay
delete from #trips 
where #trips.ord_hdrnumber not in (select tpa.ord_hdrnumber from Thirdpartyassignment tpa
				join thirdpartyprofile tpr  on  tpa.tpr_id = tpr.tpr_id
				where tpr.ThirdPartyType1 = 'AGENT')
--end 93273

-- RETURN THE DATA
SELECT mov_number 'mov_number',
       max(o_cty_nmstct) 'o_cty_nmstct',
       max(d_cty_nmstct) 'd_cty_nmstct',
       max(lgh_startdate)'lgh_startdate',
       max(lgh_enddate) 'lgh_enddate',
       max(ord_originpoint) 'ord_originpoint',
       max(ord_destpoint) 'ord_destpoint',
       max(ord_startdate) 'ord_startdate',
       max(ord_completiondate) 'ord_completiondate',
       asgn_id 'asgn_id',
       asgn_type 'asgn_type',
       max(asgn_number) 'asgn_number',
       ord_hdrnumber 'ord_hdrnumber',
       ord_number 'ord_number',
       pyh_payperiod 'pyh_payperiod',
       max(pyd_workperiod) 'pyd_workperiod',
       max(pyd_transferdate) 'pyd_transferdate',
       max(psd_id) 'psd_id',
       max(pyh_number) 'pyh_number',
       max(pyd_status) 'pyd_status',
       max(pyd_transdate) 'pyd_transdate',
       lgh_number 'lgh_number',
       max(drivername) 'drivername',
       max(paperwork) 'paperwork',
       max(lgh_type1) 'lgh_type1',
       'LghType1' as LghType1,
		-- PTS 16945 -- BL (start)
		max(ivh_billdate) 'ivh_billdate',
		max(ivh_invoicenumber) 'ivh_invoicenumber',
		max(pyt_itemcode) 'pyt_itemcode',
		max(pyd_authcode) 'pyd_authcode',
		max(lgh_booked_revtype1) 'lgh_booked_revtype1',	-- PTS 41389 GAP 74
max(asgn_controlling) 'asgn_controlling',
max(pyd_workcycle_status) 'pyd_workcycle_status', 						-- PTS 47021
ISNULL(max(pyd_prorap), 'N') 'pyd_prorap',	    -- PTS 47021
	max(ord_revtype1) 'ord_revtype1',		-- PTS 47740
	max(ord_revtype2) 'ord_revtype2',		-- PTS 47740
	max(ord_revtype3) 'ord_revtype3',		-- PTS 47740
	max(ord_revtype4) 'ord_revtype4',		-- PTS 47740
	max(stp_schdtearliest) 'stp_schdtearliest',	-- PTS 47740
	max(ord_route) 'ord_route',			-- PTS 47740
	max(Cost) 'Cost',				-- PTS 47740
	max(ord_revtype1_name) 'ord_revtype1_name',	-- PTS 47740
	max(ord_revtype2_name) 'ord_revtype2_name',	-- PTS 47740
	max(ord_revtype3_name) 'ord_revtype3_name',	-- PTS 47740
	max(ord_revtype4_name) 'ord_revtype4_name',	-- PTS 47740
    ISNULL(asgn_payto, 'UNKNOWN') 'asgn_payto'
  FROM #trips
  group by mov_number, ord_number, ord_hdrnumber, pyh_payperiod, lgh_number, asgn_type, asgn_id, asgn_payto
  ORDER BY mov_number, ord_number


DROP TABLE #trips
GO
GRANT EXECUTE ON  [dbo].[TripsSettlementOnHoldForAgentPlanningBoard_sp] TO [public]
GO
