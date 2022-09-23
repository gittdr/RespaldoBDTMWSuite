SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_stlmnt_queue_sp_new] (
	@report_type varchar(5),
	@drv_yes varchar(3),
	@trc_yes varchar(3),
	@trl_yes varchar(3),
	@car_yes varchar(3),
	@hldstatus varchar(3),
	@pndstatus varchar(3),
	@colstatus varchar(3),
	@relstatus varchar(3),
	@prnstatus varchar(3),
	@xfrstatus varchar(3),
	@lopaydate datetime,
	@hipaydate datetime,
	@company varchar(6),
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
	@trltype1 varchar(6),
	@trltype2 varchar(6),
	@trltype3 varchar(6),
	@trltype4 varchar(6),
	@cartype1 varchar(6),
	@cartype2 varchar(6),
	@cartype3 varchar(6),
	@cartype4 varchar(6),
	@drv_id varchar(8),
	@trc_id varchar(8),
	@trl_id varchar(13),
	@car_id varchar(8),
	@acct_type char(1),
	@workperiodstart datetime,
	@workperiodend datetime,
	@lgh_type1  varchar(6),
	@tpr_yes varchar(3),
	@tpr_id varchar(8),
	@tpr_type varchar(12),
	--BEGIN PTS 55217 SPN
	@ivh_billto     varchar(10),
	@ivh_revtype1   varchar(4000),
	@pto_yes	varchar(3),
	@pto_id	varchar(12)
)
AS
/*
* 
* NAME:
* dbo.d_stlmnt_queue_sp_new
*
* TYPE:
* [StoredProcedure]
*
* REVISION HISTORY:
* Date ?   PTS# -   AuthorName  Revision Description
* 1/16/2007   35187 SLM      Fix bug where Third Party settlement sheets release but not collected do not print
* 11/06/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
* 01/10/2008 MDH PTS 40119: Added calls to RowRestrictByUser.
* 02/25/2011 SPN PTS 55217: added ivh_billto and ivh_revtype1
*/

declare @use_trc_id varchar(8)

CREATE TABLE #temp_que (
	pyhnumber int null,
	type varchar(3) not null,
	asgn_id varchar(13) not null,
	status varchar(8) null,
	payperiod datetime null,
	totalcomp money null,
	totaldeduct money null,
	totalreimbrs money null,
	totalpay money null,
	payto varchar(12) null,
	terminal varchar(8) null,
	driver varchar(45) null,
	payto_lastfirst varchar(45) null,
	type1 varchar(6) null,
	type2 varchar(6) null,
	type3 varchar(6) null,
	type4 varchar(6) null,
	det_count smallint null, 
	socsecfedtax varchar(10) null)

--BEGIN PTS 55217 SPN
SELECT @ivh_billto = IsNull(@ivh_billto,'UNKNOWN')
SELECT @ivh_revtype1 = IsNull(@ivh_revtype1,'UNK')
--END PTS 55217 SPN

-- LOR PTS# 6404 elliminate trial and final settlement sheets
-- Get all on hold items
IF @hldstatus = 'HLD' 
BEGIN
	IF @lgh_type1 = 'UNK' --PTS# 20161 05/02/05
	BEGIN
		IF @drv_yes != 'XXX'
			INSERT INTO #temp_que 
				SELECT 0, 
				'DRV', 
				mp.mpp_id, 
				-- LOR PTS# 6404
				'Hold',
				'20491231', 
				NULL,
				NULL,
				NULL,
				NULL,
				mp.mpp_payto, 
				mp.mpp_terminal, 
				mp.mpp_lastfirst, 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				mp.mpp_type1, 
				mp.mpp_type2, 
				mp.mpp_type3, 
				mp.mpp_type4, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.asgn_id = mp.mpp_id AND 
					pd.asgn_type = 'DRV' AND 
					pd.pyh_payperiod >= '20491231 23:59' AND 
					pd.pyh_number = 0 and 
					pd.pyd_status = 'HLD'
					and pyd_workperiod between @workperiodstart and @workperiodend
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM manpowerprofile mp LEFT OUTER JOIN payto pt ON mp.mpp_payto = pt.pto_id 
			WHERE @drv_id IN ('UNKNOWN', mp.mpp_id) AND 
				@drvtype1 IN ('UNK', mp.mpp_type1) AND 
				@drvtype2 IN ('UNK', mp.mpp_type2) AND 
				@drvtype3 IN ('UNK', mp.mpp_type3) AND 
				@drvtype4 IN ('UNK', mp.mpp_type4) AND 
				@company IN ('UNK', mp.mpp_company) AND 
				@fleet IN ('UNK', mp.mpp_fleet) AND 
				@division IN ('UNK', mp.mpp_division) AND 
				( (@acct_type = 'X' AND mp.mpp_actg_type IN ('A', 'P')) OR (@acct_type = mp.mpp_actg_type) ) AND
				@terminal IN ('UNK', mp.mpp_terminal) AND 
				(mp.mpp_terminationdt > dateadd(day, -45, getdate()) OR mp.mpp_status <> 'OUT')
				--PTS 38816 JJF 20080312 add additional needed parms
				--PTS 51570 JJF 20100510 
				--AND dbo.RowRestrictByUser (mp.mpp_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
				AND dbo.RowRestrictByUser ('manpowerprofile', mp.rowsec_rsrv_id, '', '', '') = 1

		IF @trc_yes != 'XXX' 
			INSERT INTO #temp_que 
				SELECT 0, 
				'TRC', 
				tp.trc_number, 
				-- LOR PTS# 6404
				'Hold',
				'20491231', 
				NULL,
				NULL,
				NULL,
				NULL,
				tp.trc_owner, 
				tp.trc_terminal, 
				'', 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				tp.trc_type1, 
				tp.trc_type2, 
				tp.trc_type3, 
				tp.trc_type4, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.asgn_id = tp.trc_number AND 
					pd.asgn_type = 'TRC' AND 
					pd.pyh_payperiod >= '20491231 23:59' AND 
					pd.pyh_number = 0 and 
					pd.pyd_status = 'HLD'
					and pyd_workperiod between @workperiodstart and @workperiodend
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM tractorprofile tp LEFT OUTER JOIN payto pt ON tp.trc_owner = pt.pto_id
			WHERE @trc_id IN ('UNKNOWN', tp.trc_number) AND 
				@trctype1 IN ('UNK', tp.trc_type1) AND 
				@trctype2 IN ('UNK', tp.trc_type2) AND 
				@trctype3 IN ('UNK', tp.trc_type3) AND 
				@trctype4 IN ('UNK', tp.trc_type4) AND 
				@company IN ('UNK', tp.trc_company) AND 
				@fleet IN ('UNK', tp.trc_fleet) AND 
				@division IN ('UNK', tp.trc_division) AND 
				( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
				@terminal IN ('UNK', tp.trc_terminal) AND 
				(tp.trc_retiredate > dateadd(day, -45, getdate()) OR 
				tp.trc_status <> 'OUT')
				--PTS 38816 JJF 20080312 add additional needed parms
				--PTS 51570 JJF 20100510 
				--AND dbo.RowRestrictByUser (tp.trc_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
				AND dbo.RowRestrictByUser ('tractorprofile', tp.rowsec_rsrv_id, '', '', '') = 1

		--vjh 54604 add payto	
		IF @pto_yes != 'XXX'
		BEGIN 
			if @pto_id = 'UNKNOWN' select @use_trc_id = 'UNKNOWN'
			else select @use_trc_id = trc_number from tractorprofile where trc_owner = @pto_id or trc_owner2 = @pto_id
			if @use_trc_id is null select @use_trc_id = '-1'
			--2 inserts, this first for trc_owner, and next for trc_owner2
			INSERT INTO #temp_que 
				SELECT 0, 
				'TRC', 
				tp.trc_number, 
				-- LOR PTS# 6404
				'Hold',
				'20491231', 
				NULL,
				NULL,
				NULL,
				NULL,
				tp.trc_owner, 
				tp.trc_terminal, 
				'', 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				tp.trc_type1, 
				tp.trc_type2, 
				tp.trc_type3, 
				tp.trc_type4, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.asgn_id = tp.trc_number AND 
					pd.asgn_type = 'TRC' AND 
					pd.pyh_payperiod >= '20491231 23:59' AND 
					pd.pyh_number = 0 and 
					pd.pyd_status = 'HLD'
					and pyd_workperiod between @workperiodstart and @workperiodend
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM tractorprofile tp LEFT OUTER JOIN payto pt ON tp.trc_owner = pt.pto_id
			WHERE @use_trc_id IN ('UNKNOWN', tp.trc_number) AND 
				@pto_id IN ('UNKNOWN', tp.trc_owner) AND 
				@trctype1 IN ('UNK', tp.trc_type1) AND 
				@trctype2 IN ('UNK', tp.trc_type2) AND 
				@trctype3 IN ('UNK', tp.trc_type3) AND 
				@trctype4 IN ('UNK', tp.trc_type4) AND 
				@company IN ('UNK', tp.trc_company) AND 
				@fleet IN ('UNK', tp.trc_fleet) AND 
				@division IN ('UNK', tp.trc_division) AND 
				( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
				@terminal IN ('UNK', tp.trc_terminal) AND 
				(tp.trc_retiredate > dateadd(day, -45, getdate()) OR 
				tp.trc_status <> 'OUT')
				--PTS 38816 JJF 20080312 add additional needed parms
				--PTS 51570 JJF 20100510 
				--AND dbo.RowRestrictByUser (tp.trc_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
				AND dbo.RowRestrictByUser ('tractorprofile', tp.rowsec_rsrv_id, '', '', '') = 1

			--vjh now trc_owner2
			INSERT INTO #temp_que 
				SELECT 0, 
				'TRC', 
				tp.trc_number, 
				-- LOR PTS# 6404
				'Hold',
				'20491231', 
				NULL,
				NULL,
				NULL,
				NULL,
				tp.trc_owner2, 
				tp.trc_terminal, 
				'', 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				tp.trc_type1, 
				tp.trc_type2, 
				tp.trc_type3, 
				tp.trc_type4, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.asgn_id = tp.trc_number AND 
					pd.asgn_type = 'TRC' AND 
					pd.pyh_payperiod >= '20491231 23:59' AND 
					pd.pyh_number = 0 and 
					pd.pyd_status = 'HLD'
					and pyd_workperiod between @workperiodstart and @workperiodend
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM tractorprofile tp LEFT OUTER JOIN payto pt ON tp.trc_owner = pt.pto_id
			WHERE @use_trc_id IN ('UNKNOWN', tp.trc_number) AND 
				@pto_id IN ('UNKNOWN', tp.trc_owner2) AND
				@trctype1 IN ('UNK', tp.trc_type1) AND 
				@trctype2 IN ('UNK', tp.trc_type2) AND 
				@trctype3 IN ('UNK', tp.trc_type3) AND 
				@trctype4 IN ('UNK', tp.trc_type4) AND 
				@company IN ('UNK', tp.trc_company) AND 
				@fleet IN ('UNK', tp.trc_fleet) AND 
				@division IN ('UNK', tp.trc_division) AND 
				( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
				@terminal IN ('UNK', tp.trc_terminal) AND 
				(tp.trc_retiredate > dateadd(day, -45, getdate()) OR 
				tp.trc_status <> 'OUT')
				--PTS 38816 JJF 20080312 add additional needed parms
				--PTS 51570 JJF 20100510 
				--AND dbo.RowRestrictByUser (tp.trc_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
				AND dbo.RowRestrictByUser ('tractorprofile', tp.rowsec_rsrv_id, '', '', '') = 1
		END

		IF @car_yes != 'XXX'
			INSERT INTO #temp_que 
				SELECT 0, 
				'CAR', 
				cr.car_id,
				-- LOR PTS# 6404
				'Hold',
				'20491231', 
				NULL,
				NULL,
				NULL,
				NULL,
				cr.pto_id, 
				'', 
				cr.car_name, 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end,
				cr.car_type1, 
				cr.car_type2, 
				cr.car_type3, 
				cr.car_type4, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.asgn_id = cr.car_id AND 
					pd.asgn_type = 'CAR' AND 
					pd.pyh_payperiod >= '20491231 23:59' AND 
					pd.pyh_number = 0 and 
					pd.pyd_status = 'HLD'
					and pyd_workperiod between @workperiodstart and @workperiodend
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM carrier cr LEFT OUTER JOIN payto pt ON cr.pto_id = pt.pto_id
			WHERE @car_id IN ('UNKNOWN', cr.car_id) AND 
				@cartype1 IN ('UNK', cr.car_type1) AND 
				@cartype2 IN ('UNK', cr.car_type2) AND 
				@cartype3 IN ('UNK', cr.car_type3) AND 
				@cartype4 IN ('UNK', cr.car_type4) AND 
				( (@acct_type = 'X' AND cr.car_actg_type IN ('A', 'P')) OR (@acct_type = cr.car_actg_type) ) AND
				cr.car_status <> 'OUT'

		--  LOR PTS# 5744  trailer settlements
		IF @trl_yes != 'XXX' 
			INSERT INTO #temp_que 
				SELECT 0, 
				'TRL', 
				tp.trl_number, 
				-- LOR PTS# 6404
				'Hold',
				'20491231', 
				NULL,
				NULL,
				NULL,
				NULL,
				tp.trl_owner, 
				tp.trl_terminal, 
				'', 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				tp.trl_type1, 
				tp.trl_type2, 
				tp.trl_type3, 
				tp.trl_type4, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.asgn_id = tp.trl_number AND 
					pd.asgn_type = 'TRL' AND 
					pd.pyh_payperiod >= '20491231 23:59' AND 
					pd.pyh_number = 0 and 
					pd.pyd_status = 'HLD'
					and pyd_workperiod between @workperiodstart and @workperiodend
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM trailerprofile tp LEFT OUTER JOIN payto pt ON tp.trl_owner = pt.pto_id
			WHERE @trl_id IN ('UNKNOWN', tp.trl_id) AND 
				@trltype1 IN ('UNK', tp.trl_type1) AND 
				@trltype2 IN ('UNK', tp.trl_type2) AND 
				@trltype3 IN ('UNK', tp.trl_type3) AND 
				@trltype4 IN ('UNK', tp.trl_type4) AND 
				@company IN ('UNK', tp.trl_company) AND 
				@fleet IN ('UNK', tp.trl_fleet) AND 
				@division IN ('UNK', tp.trl_division) AND 
				((@acct_type = 'X' AND tp.trl_actg_type IN ('A', 'P')) 
				OR (@acct_type = tp.trl_actg_type) ) AND
				@terminal IN ('UNK', tp.trl_terminal) AND 
				(tp.trl_retiredate > dateadd(day, -45, getdate()) OR 
				tp.trl_status <> 'OUT')
				--PTS 38816 JJF 20080312 add additional needed parms
				--PTS 51570 JJF 20100510 
				--AND dbo.RowRestrictByUser (tp.trl_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
				AND dbo.RowRestrictByUser ('trailerprofile', tp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
				--LOR

			--  MRH PTS# 31951  3rd party settlements
		IF @tpr_yes != 'XXX' 
			INSERT INTO #temp_que 
				SELECT 0, 
				'TPR', 
				tp.tpr_id, 
				-- LOR PTS# 6404
				'Hold',
				'20491231', 
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL, 
				tp.tpr_name, 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				NULL, 
				NULL, 
				NULL, 
				NULL, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.asgn_id = tp.tpr_id AND 
					pd.asgn_type = 'TPR' AND 
					pd.pyh_payperiod >= '20491231 23:59' AND 
					pd.pyh_number = 0 and 
					pd.pyd_status = 'HLD'
					and pyd_workperiod between @workperiodstart and @workperiodend
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM thirdpartyprofile tp LEFT OUTER JOIN payto pt ON tp.tpr_payto = pt.pto_id
			WHERE @tpr_id IN ('UNKNOWN', tp.tpr_id) AND 
				@tpr_type IN ('UNKNOWN', tp.tpr_type) AND 
				((@acct_type = 'X' AND tp.tpr_actg_type IN ('A', 'P')) 
				OR (@acct_type = tp.tpr_actg_type) )

	END -- End IF @lgh_type1 = 'UNK'
	ELSE
	BEGIN --PTS# 20161 05/02/05
		IF @drv_yes != 'XXX'
			INSERT INTO #temp_que 
				SELECT 0, 
				'DRV', 
				mp.mpp_id, 
				-- LOR PTS# 6404
				'Hold',
				'20491231', 
				NULL,
				NULL,
				NULL,
				NULL,
				mp.mpp_payto, 
				mp.mpp_terminal, 
				mp.mpp_lastfirst, 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				mp.mpp_type1, 
				mp.mpp_type2, 
				mp.mpp_type3, 
				mp.mpp_type4, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
					FROM paydetail pd
					--BEGIN PTS 55217 SPN
					--     , legheader lh
					-- WHERE pd.lgh_number = lh.lgh_number and
					JOIN legheader lh ON pd.lgh_number = lh.lgh_number
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE lh.lgh_type1 = @lgh_type1 and
					pd.asgn_id = mp.mpp_id AND 
					pd.asgn_type = 'DRV' AND 
					pd.pyh_payperiod >= '20491231 23:59' AND 
					pd.pyh_number = 0 and 
					pd.pyd_status = 'HLD'
					and pyd_workperiod between @workperiodstart and @workperiodend
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM manpowerprofile mp LEFT OUTER JOIN payto pt ON mp.mpp_payto = pt.pto_id
			WHERE @drv_id IN ('UNKNOWN', mp.mpp_id) AND 
				@drvtype1 IN ('UNK', mp.mpp_type1) AND 
				@drvtype2 IN ('UNK', mp.mpp_type2) AND 
				@drvtype3 IN ('UNK', mp.mpp_type3) AND 
				@drvtype4 IN ('UNK', mp.mpp_type4) AND 
				@company IN ('UNK', mp.mpp_company) AND 
				@fleet IN ('UNK', mp.mpp_fleet) AND 
				@division IN ('UNK', mp.mpp_division) AND 
				( (@acct_type = 'X' AND mp.mpp_actg_type IN ('A', 'P')) OR (@acct_type = mp.mpp_actg_type) ) AND
				@terminal IN ('UNK', mp.mpp_terminal) AND 
				(mp.mpp_terminationdt > dateadd(day, -45, getdate()) OR
				mp.mpp_status <> 'OUT')
				--PTS 38816 JJF 20080312 add additional needed parms
				--PTS 51570 JJF 20100510 
				--AND dbo.RowRestrictByUser (mp.mpp_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */  
				AND dbo.RowRestrictByUser('manpowerprofile', mp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */  
				
		IF @trc_yes != 'XXX' 
			INSERT INTO #temp_que 
				SELECT 0, 
					'TRC', 
					tp.trc_number, 
					-- LOR PTS# 6404
					'Hold',
					'20491231', 
					NULL,
					NULL,
					NULL,
					NULL,
					tp.trc_owner, 
					tp.trc_terminal, 
					'', 
					case 
						when len(pt.pto_companyname) > 0 then pt.pto_companyname
						else pt.pto_lastfirst
						end, 
					tp.trc_type1, 
					tp.trc_type2, 
					tp.trc_type3, 
					tp.trc_type4, 
					(SELECT COUNT (DISTINCT pd.pyd_number) 
						FROM paydetail pd
						--BEGIN PTS 55217 SPN
						--     , legheader lh
						-- WHERE pd.lgh_number = lh.lgh_number and
						JOIN legheader lh ON pd.lgh_number = lh.lgh_number
						LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
						--END PTS 55217 SPN
						WHERE lh.lgh_type1 = @lgh_type1 and
						pd.asgn_id = tp.trc_number AND 
						pd.asgn_type = 'TRC' AND 
						pd.pyh_payperiod >= '20491231 23:59' AND 
						pd.pyh_number = 0 and 
						pd.pyd_status = 'HLD'
						and pyd_workperiod between @workperiodstart and @workperiodend
						--BEGIN PTS 55217 SPN
						AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
						AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
						--END PTS 55217 SPN
						), 
					pt.pto_ssn 
				FROM tractorprofile tp LEFT OUTER JOIN payto pt ON tp.trc_owner = pt.pto_id
				WHERE @trc_id IN ('UNKNOWN', tp.trc_number) AND 
					@trctype1 IN ('UNK', tp.trc_type1) AND 
					@trctype2 IN ('UNK', tp.trc_type2) AND 
					@trctype3 IN ('UNK', tp.trc_type3) AND 
					@trctype4 IN ('UNK', tp.trc_type4) AND 
					@company IN ('UNK', tp.trc_company) AND 
					@fleet IN ('UNK', tp.trc_fleet) AND 
					@division IN ('UNK', tp.trc_division) AND 
					( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
					@terminal IN ('UNK', tp.trc_terminal) AND 
					(tp.trc_retiredate > dateadd(day, -45, getdate()) OR 
					tp.trc_status <> 'OUT')
					--PTS 38816 JJF 20080312 add additional needed parms
					--PTS 51570 JJF 20100510 
					--AND dbo.RowRestrictByUser(tp.trc_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */   
					AND dbo.RowRestrictByUser('tractorprofile', tp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */   

		--vjh 54604 add payto
		IF @pto_yes != 'XXX' 
		BEGIN
			if @pto_id = 'UNKNOWN' select @use_trc_id = 'UNKNOWN'
			else select @use_trc_id = trc_number from tractorprofile where trc_owner = @pto_id or trc_owner2 = @pto_id
			if @use_trc_id is null select @use_trc_id = '-1'
			--2 inserts, this first for trc_owner, and next for trc_owner2			
			INSERT INTO #temp_que 
				SELECT 0, 
					'TRC', 
					tp.trc_number, 
					-- LOR PTS# 6404
					'Hold',
					'20491231', 
					NULL,
					NULL,
					NULL,
					NULL,
					tp.trc_owner, 
					tp.trc_terminal, 
					'', 
					case 
						when len(pt.pto_companyname) > 0 then pt.pto_companyname
						else pt.pto_lastfirst
						end, 
					tp.trc_type1, 
					tp.trc_type2, 
					tp.trc_type3, 
					tp.trc_type4, 
					(SELECT COUNT (DISTINCT pd.pyd_number) 
						FROM paydetail pd
						--BEGIN PTS 55217 SPN
						--     , legheader lh
						-- WHERE pd.lgh_number = lh.lgh_number and
						JOIN legheader lh ON pd.lgh_number = lh.lgh_number
						LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
						--END PTS 55217 SPN
						WHERE lh.lgh_type1 = @lgh_type1 and
						pd.asgn_id = tp.trc_number AND 
						pd.asgn_type = 'TRC' AND 
						pd.pyh_payperiod >= '20491231 23:59' AND 
						pd.pyh_number = 0 and 
						pd.pyd_status = 'HLD'
						and pyd_workperiod between @workperiodstart and @workperiodend
						--BEGIN PTS 55217 SPN
						AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
						AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
						--END PTS 55217 SPN
						), 
					pt.pto_ssn 
				FROM tractorprofile tp LEFT OUTER JOIN payto pt ON tp.trc_owner = pt.pto_id
				WHERE @use_trc_id IN ('UNKNOWN', tp.trc_number) AND 
					@pto_id IN ('UNKNOWN', tp.trc_owner) AND
					@trctype1 IN ('UNK', tp.trc_type1) AND 
					@trctype2 IN ('UNK', tp.trc_type2) AND 
					@trctype3 IN ('UNK', tp.trc_type3) AND 
					@trctype4 IN ('UNK', tp.trc_type4) AND 
					@company IN ('UNK', tp.trc_company) AND 
					@fleet IN ('UNK', tp.trc_fleet) AND 
					@division IN ('UNK', tp.trc_division) AND 
					( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
					@terminal IN ('UNK', tp.trc_terminal) AND 
					(tp.trc_retiredate > dateadd(day, -45, getdate()) OR 
					tp.trc_status <> 'OUT')
					--PTS 38816 JJF 20080312 add additional needed parms
					--PTS 51570 JJF 20100510 
					--AND dbo.RowRestrictByUser(tp.trc_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */   
					AND dbo.RowRestrictByUser('tractorprofile', tp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */   

			--now for trc_owner2
			INSERT INTO #temp_que 
				SELECT 0, 
					'TRC', 
					tp.trc_number, 
					-- LOR PTS# 6404
					'Hold',
					'20491231', 
					NULL,
					NULL,
					NULL,
					NULL,
					tp.trc_owner2, 
					tp.trc_terminal, 
					'', 
					case 
						when len(pt.pto_companyname) > 0 then pt.pto_companyname
						else pt.pto_lastfirst
						end, 
					tp.trc_type1, 
					tp.trc_type2, 
					tp.trc_type3, 
					tp.trc_type4, 
					(SELECT COUNT (DISTINCT pd.pyd_number) 
						FROM paydetail pd
						--BEGIN PTS 55217 SPN
						--     , legheader lh
						-- WHERE pd.lgh_number = lh.lgh_number and
						JOIN legheader lh ON pd.lgh_number = lh.lgh_number
						LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
						--END PTS 55217 SPN
						WHERE lh.lgh_type1 = @lgh_type1 and
						pd.asgn_id = tp.trc_number AND 
						pd.asgn_type = 'TRC' AND 
						pd.pyh_payperiod >= '20491231 23:59' AND 
						pd.pyh_number = 0 and 
						pd.pyd_status = 'HLD'
						and pyd_workperiod between @workperiodstart and @workperiodend
						--BEGIN PTS 55217 SPN
						AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
						AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
						--END PTS 55217 SPN
						), 
					pt.pto_ssn 
				FROM tractorprofile tp LEFT OUTER JOIN payto pt ON tp.trc_owner = pt.pto_id
				WHERE @use_trc_id IN ('UNKNOWN', tp.trc_number) AND 
					@pto_id IN ('UNKNOWN', tp.trc_owner2) AND
					@trctype1 IN ('UNK', tp.trc_type1) AND 
					@trctype2 IN ('UNK', tp.trc_type2) AND 
					@trctype3 IN ('UNK', tp.trc_type3) AND 
					@trctype4 IN ('UNK', tp.trc_type4) AND 
					@company IN ('UNK', tp.trc_company) AND 
					@fleet IN ('UNK', tp.trc_fleet) AND 
					@division IN ('UNK', tp.trc_division) AND 
					( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
					@terminal IN ('UNK', tp.trc_terminal) AND 
					(tp.trc_retiredate > dateadd(day, -45, getdate()) OR 
					tp.trc_status <> 'OUT')
					--PTS 38816 JJF 20080312 add additional needed parms
					--PTS 51570 JJF 20100510 
					--AND dbo.RowRestrictByUser(tp.trc_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */   
					AND dbo.RowRestrictByUser('tractorprofile', tp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */   
		END

		IF @car_yes != 'XXX'
			INSERT INTO #temp_que 
				SELECT 0, 
				'CAR', 
				cr.car_id,
				-- LOR PTS# 6404
				'Hold',
				'20491231', 
				NULL,
				NULL,
				NULL,
				NULL,
				cr.pto_id, 
				'', 
				cr.car_name, 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end,
				cr.car_type1, 
				cr.car_type2, 
				cr.car_type3, 
				cr.car_type4, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
					FROM paydetail pd
					--BEGIN PTS 55217 SPN
					--     , legheader lh
					-- WHERE pd.lgh_number = lh.lgh_number and
					JOIN legheader lh ON pd.lgh_number = lh.lgh_number
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE lh.lgh_type1 = @lgh_type1 and
					pd.asgn_id = cr.car_id AND 
					pd.asgn_type = 'CAR' AND 
					pd.pyh_payperiod >= '20491231 23:59' AND 
					pd.pyh_number = 0 and 
					pd.pyd_status = 'HLD'
					and pyd_workperiod between @workperiodstart and @workperiodend
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM carrier cr LEFT OUTER JOIN payto pt ON cr.pto_id = pt.pto_id 
			WHERE @car_id IN ('UNKNOWN', cr.car_id) AND 
				@cartype1 IN ('UNK', cr.car_type1) AND 
				@cartype2 IN ('UNK', cr.car_type2) AND 
				@cartype3 IN ('UNK', cr.car_type3) AND 
				@cartype4 IN ('UNK', cr.car_type4) AND 
				( (@acct_type = 'X' AND cr.car_actg_type IN ('A', 'P')) OR (@acct_type = cr.car_actg_type) ) AND
				cr.car_status <> 'OUT'

		--  LOR PTS# 5744  trailer settlements
		IF @trl_yes != 'XXX' 
			INSERT INTO #temp_que 
				SELECT 0, 
				'TRL', 
				tp.trl_number, 
				-- LOR PTS# 6404
				'Hold',
				'20491231', 
				NULL,
				NULL,
				NULL,
				NULL,
				tp.trl_owner, 
				tp.trl_terminal, 
				'', 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				tp.trl_type1, 
				tp.trl_type2, 
				tp.trl_type3, 
				tp.trl_type4, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
					FROM paydetail pd
					--BEGIN PTS 55217 SPN
					--     , legheader lh
					-- WHERE pd.lgh_number = lh.lgh_number and
					JOIN legheader lh ON pd.lgh_number = lh.lgh_number
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE lh.lgh_type1 = @lgh_type1 and
					pd.asgn_id = tp.trl_number AND 
					pd.asgn_type = 'TRL' AND 
					pd.pyh_payperiod >= '20491231 23:59' AND 
					pd.pyh_number = 0 and 
					pd.pyd_status = 'HLD'
					and pyd_workperiod between @workperiodstart and @workperiodend
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM trailerprofile tp LEFT OUTER JOIN payto pt ON tp.trl_owner = pt.pto_id
			WHERE @trl_id IN ('UNKNOWN', tp.trl_id) AND 
				@trltype1 IN ('UNK', tp.trl_type1) AND 
				@trltype2 IN ('UNK', tp.trl_type2) AND 
				@trltype3 IN ('UNK', tp.trl_type3) AND 
				@trltype4 IN ('UNK', tp.trl_type4) AND 
				@company IN ('UNK', tp.trl_company) AND 
				@fleet IN ('UNK', tp.trl_fleet) AND 
				@division IN ('UNK', tp.trl_division) AND 
				((@acct_type = 'X' AND tp.trl_actg_type IN ('A', 'P')) 
				OR (@acct_type = tp.trl_actg_type) ) AND
				@terminal IN ('UNK', tp.trl_terminal) AND 
				(tp.trl_retiredate > dateadd(day, -45, getdate()) OR 
				tp.trl_status <> 'OUT')
				--PTS 38816 JJF 20080312 add additional needed parms
				--PTS 51570 JJF 20100510 
				--AND dbo.RowRestrictByUser (tp.trl_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
				AND dbo.RowRestrictByUser('trailerprofile', tp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
				--LOR

		--  MRH PTS# 31951  3rd party settlements
		IF @tpr_yes != 'XXX' 
			INSERT INTO #temp_que 
				SELECT 0, 
				'TPR', 
				tp.tpr_id, 
				-- LOR PTS# 6404
				'Hold',
				'20491231', 
				NULL,
				NULL,
				NULL,
				NULL,
				NULL, 
				NULL, 
				tp.tpr_name, 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				NULL, 
				NULL, 
				NULL, 
				NULL, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.asgn_id = tp.tpr_id AND 
					pd.asgn_type = 'TPR' AND 
					pd.pyh_payperiod >= '20491231 23:59' AND 
					pd.pyh_number = 0 and 
					pd.pyd_status = 'HLD'
					and pyd_workperiod between @workperiodstart and @workperiodend
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM thirdpartyprofile tp LEFT OUTER JOIN payto pt ON tp.tpr_payto = pt.pto_id
			WHERE @tpr_id IN ('UNKNOWN', tp.tpr_id) AND 
				@tpr_type IN ('UNKNOWN', tp.tpr_type) AND 
				((@acct_type = 'X' AND tp.tpr_actg_type IN ('A', 'P')) 
				OR (@acct_type = tp.tpr_actg_type) )

	END--PTS# 20161 05/02/05

END

-- Get all released but not collected items
IF @pndstatus  = 'PND' and @colstatus  = 'XXX'
--IF @report_type = 'TRIAL'
--LOR
BEGIN
	IF @drv_yes != 'XXX'
		INSERT INTO #temp_que 
			SELECT 0, 
			'DRV', 
			mp.mpp_id, 
			-- LOR PTS# 6404
			'Released',
			'20491231', 
			NULL,
			NULL,
			NULL,
			NULL,
			mp.mpp_payto, 
			mp.mpp_terminal, 
			mp.mpp_lastfirst, 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end,
			mp.mpp_type1, 
			mp.mpp_type2, 
			mp.mpp_type3, 
			mp.mpp_type4, 
			(SELECT COUNT (DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				--BEGIN PTS 55217 SPN
				LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
				--END PTS 55217 SPN
				WHERE pd.asgn_id = mp.mpp_id AND 
				pd.asgn_type = 'DRV' AND 
				pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				pd.pyh_number = 0 and 
				pd.pyd_status = 'PND'
				--BEGIN PTS 55217 SPN
				AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
				AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
				--END PTS 55217 SPN
				), 
			pt.pto_ssn 
		FROM manpowerprofile mp LEFT OUTER JOIN payto pt ON mp.mpp_payto = pt.pto_id
		WHERE @drv_id IN ('UNKNOWN', mp.mpp_id) AND 
			@drvtype1 IN ('UNK', mp.mpp_type1) AND 
			@drvtype2 IN ('UNK', mp.mpp_type2) AND 
			@drvtype3 IN ('UNK', mp.mpp_type3) AND 
			@drvtype4 IN ('UNK', mp.mpp_type4) AND 
			@company IN ('UNK', mp.mpp_company) AND 
			@fleet IN ('UNK', mp.mpp_fleet) AND 
			@division IN ('UNK', mp.mpp_division) AND 
			( (@acct_type = 'X' AND mp.mpp_actg_type IN ('A', 'P')) OR (@acct_type = mp.mpp_actg_type) ) AND
			@terminal IN ('UNK', mp.mpp_terminal) AND 
			(mp.mpp_terminationdt > dateadd(day, -45, getdate()) OR
			mp.mpp_status <> 'OUT')
			--PTS 38816 JJF 20080312 add additional needed parms
			--PTS 51570 JJF 20100510 
			--AND dbo.RowRestrictByUser (mp.mpp_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
			AND dbo.RowRestrictByUser('manpowerprofile', mp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */

	IF @trc_yes != 'XXX' 
		INSERT INTO #temp_que 
			SELECT 0, 
			'TRC', 
			tp.trc_number, 
			-- LOR PTS# 6404
			'Released',
			'20491231', 
			NULL,
			NULL,
			NULL,
			NULL,
			tp.trc_owner, 
			tp.trc_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			tp.trc_type1, 
			tp.trc_type2, 
			tp.trc_type3, 
			tp.trc_type4, 
			(SELECT COUNT (DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				--BEGIN PTS 55217 SPN
				LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
				--END PTS 55217 SPN
				WHERE pd.asgn_id = tp.trc_number AND 
				pd.asgn_type = 'TRC' AND 
				pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				pd.pyh_number = 0 and 
				pd.pyd_status = 'PND'
				--BEGIN PTS 55217 SPN
				AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
				AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
				--END PTS 55217 SPN
				), 
			pt.pto_ssn 
		FROM tractorprofile tp LEFT OUTER JOIN payto pt ON tp.trc_owner = pt.pto_id
		WHERE @trc_id IN ('UNKNOWN', tp.trc_number) AND 
			@trctype1 IN ('UNK', tp.trc_type1) AND 
			@trctype2 IN ('UNK', tp.trc_type2) AND 
			@trctype3 IN ('UNK', tp.trc_type3) AND 
			@trctype4 IN ('UNK', tp.trc_type4) AND 
			@company IN ('UNK', tp.trc_company) AND 
			@fleet IN ('UNK', tp.trc_fleet) AND 
			@division IN ('UNK', tp.trc_division) AND 
			( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
			@terminal IN ('UNK', tp.trc_terminal) AND 
			(tp.trc_retiredate > dateadd(day, -45, getdate()) OR 
			tp.trc_status <> 'OUT')
			--PTS 38816 JJF 20080312 add additional needed parms
			--PTS 51570 JJF 20100510 
			--AND dbo.RowRestrictByUser(tp.trc_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
			AND dbo.RowRestrictByUser('tractorprofile', tp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */

	--vjh 54604 add payto		
	IF @pto_yes != 'XXX' BEGIN
		if @pto_id = 'UNKNOWN' select @use_trc_id = 'UNKNOWN'
		else select @use_trc_id = trc_number from tractorprofile where trc_owner = @pto_id or trc_owner2 = @pto_id
		if @use_trc_id is null select @use_trc_id = '-1'
		--2 inserts, this first for trc_owner, and next for trc_owner2	
		INSERT INTO #temp_que 
			SELECT 0, 
			'TRC', 
			tp.trc_number, 
			-- LOR PTS# 6404
			'Released',
			'20491231', 
			NULL,
			NULL,
			NULL,
			NULL,
			tp.trc_owner, 
			tp.trc_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			tp.trc_type1, 
			tp.trc_type2, 
			tp.trc_type3, 
			tp.trc_type4, 
			(SELECT COUNT (DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				--BEGIN PTS 55217 SPN
				LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
				--END PTS 55217 SPN
				WHERE pd.asgn_id = tp.trc_number AND 
				pd.asgn_type = 'TRC' AND 
				pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				pd.pyh_number = 0 and 
				pd.pyd_status = 'PND'
				--BEGIN PTS 55217 SPN
				AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
				AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
				--END PTS 55217 SPN
				), 
			pt.pto_ssn 
		FROM tractorprofile tp LEFT OUTER JOIN payto pt ON tp.trc_owner = pt.pto_id
		WHERE @use_trc_id IN ('UNKNOWN', tp.trc_number) AND 
			@pto_id IN ('UNKNOWN', tp.trc_owner) AND  
			@trctype1 IN ('UNK', tp.trc_type1) AND 
			@trctype2 IN ('UNK', tp.trc_type2) AND 
			@trctype3 IN ('UNK', tp.trc_type3) AND 
			@trctype4 IN ('UNK', tp.trc_type4) AND 
			@company IN ('UNK', tp.trc_company) AND 
			@fleet IN ('UNK', tp.trc_fleet) AND 
			@division IN ('UNK', tp.trc_division) AND 
			( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
			@terminal IN ('UNK', tp.trc_terminal) AND 
			(tp.trc_retiredate > dateadd(day, -45, getdate()) OR 
			tp.trc_status <> 'OUT')
			--PTS 38816 JJF 20080312 add additional needed parms
			--PTS 51570 JJF 20100510 
			--AND dbo.RowRestrictByUser(tp.trc_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
			AND dbo.RowRestrictByUser('tractorprofile', tp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */

		--vjh now trc_owner2
		INSERT INTO #temp_que 
			SELECT 0, 
			'TRC', 
			tp.trc_number, 
			-- LOR PTS# 6404
			'Released',
			'20491231', 
			NULL,
			NULL,
			NULL,
			NULL,
			tp.trc_owner2, 
			tp.trc_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			tp.trc_type1, 
			tp.trc_type2, 
			tp.trc_type3, 
			tp.trc_type4, 
			(SELECT COUNT (DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				--BEGIN PTS 55217 SPN
				LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
				--END PTS 55217 SPN
				WHERE pd.asgn_id = tp.trc_number AND 
				pd.asgn_type = 'TRC' AND 
				pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				pd.pyh_number = 0 and 
				pd.pyd_status = 'PND'
				--BEGIN PTS 55217 SPN
				AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
				AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
				--END PTS 55217 SPN
				), 
			pt.pto_ssn 
		FROM tractorprofile tp LEFT OUTER JOIN payto pt ON tp.trc_owner2 = pt.pto_id
		WHERE @use_trc_id IN ('UNKNOWN', tp.trc_number) AND 
			@pto_id IN ('UNKNOWN', tp.trc_owner2) AND
			@trctype1 IN ('UNK', tp.trc_type1) AND 
			@trctype2 IN ('UNK', tp.trc_type2) AND 
			@trctype3 IN ('UNK', tp.trc_type3) AND 
			@trctype4 IN ('UNK', tp.trc_type4) AND 
			@company IN ('UNK', tp.trc_company) AND 
			@fleet IN ('UNK', tp.trc_fleet) AND 
			@division IN ('UNK', tp.trc_division) AND 
			( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
			@terminal IN ('UNK', tp.trc_terminal) AND 
			(tp.trc_retiredate > dateadd(day, -45, getdate()) OR 
			tp.trc_status <> 'OUT')
			--PTS 38816 JJF 20080312 add additional needed parms
			--PTS 51570 JJF 20100510 
			--AND dbo.RowRestrictByUser(tp.trc_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
			AND dbo.RowRestrictByUser('tractorprofile', tp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
	END

	IF @car_yes != 'XXX'
		INSERT INTO #temp_que 
			SELECT 0, 
			'CAR', 
			cr.car_id,
			-- LOR PTS# 6404
			'Released',
			'20491231', 
			NULL,
			NULL,
			NULL,
			NULL,
			cr.pto_id, 
			'', 
			cr.car_name, 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end,
			cr.car_type1, 
			cr.car_type2, 
			cr.car_type3, 
			cr.car_type4, 
				(SELECT COUNT (DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				--BEGIN PTS 55217 SPN
				LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
				--END PTS 55217 SPN
				WHERE pd.asgn_id = cr.car_id AND 
				pd.asgn_type = 'CAR' AND 
				pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				pd.pyh_number = 0 and 
				pd.pyd_status = 'PND'
				--BEGIN PTS 55217 SPN
				AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
				AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
				--END PTS 55217 SPN
				), 
			pt.pto_ssn 
		FROM carrier cr LEFT OUTER JOIN payto pt ON cr.pto_id = pt.pto_id
		WHERE @car_id IN ('UNKNOWN', cr.car_id) AND 
			@cartype1 IN ('UNK', cr.car_type1) AND 
			@cartype2 IN ('UNK', cr.car_type2) AND 
			@cartype3 IN ('UNK', cr.car_type3) AND 
			@cartype4 IN ('UNK', cr.car_type4) AND 
			( (@acct_type = 'X' AND cr.car_actg_type IN ('A', 'P')) OR (@acct_type = cr.car_actg_type) ) AND
			cr.car_status <> 'OUT'

	--  LOR PTS# 5744  trailer settlements
	IF @trl_yes != 'XXX' 
		INSERT INTO #temp_que 
			SELECT 0, 
			'TRL', 
			tp.trl_number, 
			-- LOR PTS# 6404
			'Released',
			'20491231', 
			NULL,
			NULL,
			NULL,
			NULL,
			tp.trl_owner, 
			tp.trl_terminal, 
			'', 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			tp.trl_type1, 
			tp.trl_type2, 
			tp.trl_type3, 
			tp.trl_type4, 
			(SELECT COUNT (DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				--BEGIN PTS 55217 SPN
				LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
				--END PTS 55217 SPN
				WHERE pd.asgn_id = tp.trl_number AND 
				pd.asgn_type = 'TRL' AND 
				pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				pd.pyh_number = 0 and 
				pd.pyd_status = 'PND'
				--BEGIN PTS 55217 SPN
				AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
				AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
				--END PTS 55217 SPN
				), 
			pt.pto_ssn 
		FROM trailerprofile tp LEFT OUTER JOIN payto pt ON tp.trl_owner = pt.pto_id
		WHERE @trl_id IN ('UNKNOWN', tp.trl_id) AND 
			@trltype1 IN ('UNK', tp.trl_type1) AND 
			@trltype2 IN ('UNK', tp.trl_type2) AND 
			@trltype3 IN ('UNK', tp.trl_type3) AND 
			@trltype4 IN ('UNK', tp.trl_type4) AND 
			@company IN ('UNK', tp.trl_company) AND 
			@fleet IN ('UNK', tp.trl_fleet) AND 
			@division IN ('UNK', tp.trl_division) AND 
			((@acct_type = 'X' AND tp.trl_actg_type IN ('A', 'P')) 
			OR (@acct_type = tp.trl_actg_type) ) AND
			@terminal IN ('UNK', tp.trl_terminal) AND 
			(tp.trl_retiredate > dateadd(day, -45, getdate()) OR 
			tp.trl_status <> 'OUT')
			--PTS 38816 JJF 20080312 add additional needed parms
			--PTS 51570 JJF 20100510 
			--AND dbo.RowRestrictByUser (tp.trl_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */                     
			AND dbo.RowRestrictByUser ('trailerprofile', tp.rowsec_rsrv_id, '', '', '') = 1
			--LOR

	--  MRH PTS# 31951  3rd party settlements
	IF @tpr_yes != 'XXX' 
		INSERT INTO #temp_que 
			SELECT 0, 
			'TPR', 
			tp.tpr_id, 
			-- LOR PTS# 6404
			'Released',
			'20491231', 
			NULL,
			NULL,
			NULL,
			NULL,
			NULL, 
			NULL, 
			tp.tpr_name, 
			case 
				when len(pt.pto_companyname) > 0 then pt.pto_companyname
				else pt.pto_lastfirst
				end, 
			NULL, 
			NULL, 
			NULL, 
			NULL, 
			(SELECT COUNT (DISTINCT pd.pyd_number) 
				FROM paydetail pd 
				--BEGIN PTS 55217 SPN
				LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
				--END PTS 55217 SPN
				WHERE pd.asgn_id = tp.tpr_id AND 
				pd.asgn_type = 'TPR' AND 
				--PTS 35187 Remove this restriction 2/2/2007
				--                            pd.pyh_payperiod >= '20491231 23:59' AND 
				pd.pyh_number = 0 and 
				pd.pyd_status = 'PND' and
				pd.pyh_payperiod BETWEEN @lopaydate AND @hipaydate
				--BEGIN PTS 55217 SPN
				AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
				AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
				--END PTS 55217 SPN
				), 
			pt.pto_ssn 
		FROM thirdpartyprofile tp LEFT OUTER JOIN payto pt ON tp.tpr_payto = pt.pto_id
		WHERE @tpr_id IN ('UNKNOWN', tp.tpr_id) AND 
			@tpr_type IN ('UNKNOWN', tp.tpr_type) AND 
			((@acct_type = 'X' AND tp.tpr_actg_type IN ('A', 'P')) 
			OR (@acct_type = tp.tpr_actg_type) )

END

-- LOR PTS# 6404 elliminate trial and final settlement sheets
-- Get all released and collected items
IF @pndstatus  = 'PND' and @colstatus  = 'COL' 
--IF @report_type = 'FINAL'
--LOR
BEGIN 
	select @hldstatus = 'HLD' --need all settlements with a header jd 04/12/00#7751
	IF @drv_yes != 'XXX' 
		INSERT INTO #temp_que 
			SELECT DISTINCT ph.pyh_pyhnumber, 
				ph.asgn_type, 
				ph.asgn_id, 
				ph.pyh_paystatus, 
				ph.pyh_payperiod, 
				ph.pyh_totalcomp, 
				ph.pyh_totaldeduct, 
				ph.pyh_totalreimbrs, 
				ph.pyh_totalcomp + ph.pyh_totaldeduct + ph.pyh_totalreimbrs, 
				ph.pyh_payto, 
				mp.mpp_terminal, 
				mp.mpp_lastfirst, 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				mp.mpp_type1, 
				mp.mpp_type2, 
				mp.mpp_type3, 
				mp.mpp_type4, 
				(SELECT COUNT(DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.pyh_number = ph.pyh_pyhnumber
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id, 
			manpowerprofile mp
			WHERE ph.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				ph.pyh_paystatus IN (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus) AND 
				ph.asgn_type = 'DRV' AND 
				@drv_id IN ('UNKNOWN', ph.asgn_id) AND 
				ph.asgn_id = mp.mpp_id AND 
				@drvtype1 IN ('UNK', mp.mpp_type1) AND 
				@drvtype2 IN ('UNK', mp.mpp_type2) AND 
				@drvtype3 IN ('UNK', mp.mpp_type3) AND 
				@drvtype4 IN ('UNK', mp.mpp_type4) AND 
				@company IN ('UNK', mp.mpp_company) AND 
				@fleet IN ('UNK', mp.mpp_fleet) AND 
				@division IN ('UNK', mp.mpp_division) AND 
				( (@acct_type = 'X' AND mp.mpp_actg_type IN ('A', 'P')) OR (@acct_type = mp.mpp_actg_type) ) AND
				@terminal IN ('UNK', mp.mpp_terminal)
				--PTS 38816 JJF 20080312 add additional needed parms
				--PTS 51570 JJF 20100510 
				--AND dbo.RowRestrictByUser (mp.mpp_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
				AND dbo.RowRestrictByUser('manpowerprofile', mp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
	
	IF @trc_yes != 'XXX' 
		INSERT INTO #temp_que 
			SELECT DISTINCT ph.pyh_pyhnumber, 
				ph.asgn_type, 
				ph.asgn_id, 
				ph.pyh_paystatus, 
				ph.pyh_payperiod, 
				ph.pyh_totalcomp, 
				ph.pyh_totaldeduct, 
				ph.pyh_totalreimbrs, 
				ph.pyh_totalcomp + ph.pyh_totaldeduct + ph.pyh_totalreimbrs, 
				ph.pyh_payto, 
				tp.trc_terminal, 
				'', 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				tp.trc_type1, 
				tp.trc_type2, 
				tp.trc_type3, 
				tp.trc_type4, 
				(SELECT COUNT(DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.pyh_number = ph.pyh_pyhnumber
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id, 
			tractorprofile tp
			WHERE ph.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				ph.pyh_paystatus IN (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus) AND 
				ph.asgn_type = 'TRC' AND 
				@trc_id IN ('UNKNOWN', ph.asgn_id) AND 
				ph.asgn_id = tp.trc_number AND 
				@trctype1 IN ('UNK', tp.trc_type1) AND 
				@trctype2 IN ('UNK', tp.trc_type2) AND 
				@trctype3 IN ('UNK', tp.trc_type3) AND 
				@trctype4 IN ('UNK', tp.trc_type4) AND 
				@company IN ('UNK', tp.trc_company) AND 
				@fleet IN ('UNK', tp.trc_fleet) AND 
				@division IN ('UNK', tp.trc_division) AND 
				( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
				@terminal IN ('UNK', tp.trc_terminal)
				--PTS 38816 JJF 20080312 add additional needed parms
				--PTS 51570 JJF 20100510 
				--AND dbo.RowRestrictByUser(tp.trc_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
				AND dbo.RowRestrictByUser('tractorprofile', tp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
	




	--vjh 54604 add payto		
	IF @pto_yes != 'XXX' BEGIN
		if @pto_id = 'UNKNOWN' select @use_trc_id = 'UNKNOWN'
		else select @use_trc_id = trc_number from tractorprofile where trc_owner = @pto_id or trc_owner2 = @pto_id
		if @use_trc_id is null select @use_trc_id = '-1'
		--only 1 insert this time, since it is payheaders we are looking at.
		INSERT INTO #temp_que 
			SELECT DISTINCT ph.pyh_pyhnumber, 
				ph.asgn_type, 
				ph.asgn_id, 
				ph.pyh_paystatus, 
				ph.pyh_payperiod, 
				ph.pyh_totalcomp, 
				ph.pyh_totaldeduct, 
				ph.pyh_totalreimbrs, 
				ph.pyh_totalcomp + ph.pyh_totaldeduct + ph.pyh_totalreimbrs, 
				ph.pyh_payto, 
				tp.trc_terminal, 
				'', 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				tp.trc_type1, 
				tp.trc_type2, 
				tp.trc_type3, 
				tp.trc_type4, 
				(SELECT COUNT(DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.pyh_number = ph.pyh_pyhnumber
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id, 
			tractorprofile tp
			WHERE ph.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				ph.pyh_paystatus IN (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus) AND 
				ph.asgn_type = 'TRC' AND 
				@trc_id IN ('UNKNOWN', ph.asgn_id) AND 
				@pto_id in ('UNKNOWN', ph.pyh_payto) AND
				ph.asgn_id = tp.trc_number AND 
				@trctype1 IN ('UNK', tp.trc_type1) AND 
				@trctype2 IN ('UNK', tp.trc_type2) AND 
				@trctype3 IN ('UNK', tp.trc_type3) AND 
				@trctype4 IN ('UNK', tp.trc_type4) AND 
				@company IN ('UNK', tp.trc_company) AND 
				@fleet IN ('UNK', tp.trc_fleet) AND 
				@division IN ('UNK', tp.trc_division) AND 
				( (@acct_type = 'X' AND tp.trc_actg_type IN ('A', 'P')) OR (@acct_type = tp.trc_actg_type) ) AND
				@terminal IN ('UNK', tp.trc_terminal)
				--PTS 38816 JJF 20080312 add additional needed parms
				--PTS 51570 JJF 20100510 
				--AND dbo.RowRestrictByUser(tp.trc_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
				AND dbo.RowRestrictByUser('tractorprofile', tp.rowsec_rsrv_id, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */
	END


































	IF @car_yes != 'XXX' 
		INSERT INTO #temp_que 
			SELECT DISTINCT ph.pyh_pyhnumber, 
				ph.asgn_type, 
				ph.asgn_id, 
				ph.pyh_paystatus, 
				ph.pyh_payperiod, 
				ph.pyh_totalcomp, 
				ph.pyh_totaldeduct, 
				ph.pyh_totalreimbrs, 
				ph.pyh_totalcomp + ph.pyh_totaldeduct + ph.pyh_totalreimbrs, 
				ph.pyh_payto, 
				'', 
				'', 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end, 
				cr.car_type1, 
				cr.car_type2, 
				cr.car_type3, 
				cr.car_type4, 
				(SELECT COUNT(DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.pyh_number = ph.pyh_pyhnumber
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id, 
			carrier cr
			WHERE ph.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				ph.pyh_paystatus IN (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus) AND 
				ph.asgn_type = 'CAR' AND 
				@car_id IN ('UNKNOWN', ph.asgn_id) AND 
				ph.asgn_id = cr.car_id AND 
				@cartype1 IN ('UNK', cr.car_type1) AND 
				@cartype2 IN ('UNK', cr.car_type2) AND 
				@cartype3 IN ('UNK', cr.car_type3) AND 
				@cartype4 IN ('UNK', cr.car_type4) AND 
				( (@acct_type = 'X' AND cr.car_actg_type IN ('A', 'P')) OR (@acct_type = cr.car_actg_type) )
				--  LOR PTS# 5744  trailer settlements
	
	IF @trl_yes != 'XXX' 
		INSERT INTO #temp_que 
			SELECT DISTINCT ph.pyh_pyhnumber, 
				ph.asgn_type, 
				ph.asgn_id, 
				ph.pyh_paystatus, 
				ph.pyh_payperiod, 
				ph.pyh_totalcomp, 
				ph.pyh_totaldeduct, 
				ph.pyh_totalreimbrs, 
				ph.pyh_totalcomp + ph.pyh_totaldeduct + ph.pyh_totalreimbrs, 
				ph.pyh_payto, 
				tp.trl_terminal, 
				'', 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end,
				tp.trl_type1, 
				tp.trl_type2, 
				tp.trl_type3, 
				tp.trl_type4, 
				(SELECT COUNT(DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.pyh_number = ph.pyh_pyhnumber
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id, 
			trailerprofile tp
			WHERE ph.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				ph.pyh_paystatus IN (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus) AND 
				ph.asgn_type = 'TRL' AND 
				@trl_id IN ('UNKNOWN', ph.asgn_id) AND 
				ph.asgn_id = tp.trl_number AND 
				@trltype1 IN ('UNK', tp.trl_type1) AND 
				@trltype2 IN ('UNK', tp.trl_type2) AND 
				@trltype3 IN ('UNK', tp.trl_type3) AND 
				@trltype4 IN ('UNK', tp.trl_type4) AND 
				@company IN ('UNK', tp.trl_company) AND 
				@fleet IN ('UNK', tp.trl_fleet) AND 
				@division IN ('UNK', tp.trl_division) AND 
				((@acct_type = 'X' AND tp.trl_actg_type IN ('A', 'P')) OR 
				(@acct_type = tp.trl_actg_type) ) AND
				@terminal IN ('UNK', tp.trl_terminal)
				--PTS 38816 JJF 20080312 add additional needed parms
				--PTS 51570 JJF 20100510 
				--AND dbo.RowRestrictByUser (tp.trl_terminal, '', '', '') = 1  /* 01/10/2008 MDH PTS 40878: Added */                    
				AND dbo.RowRestrictByUser('trailerprofile', tp.rowsec_rsrv_id, '', '', '') = 1
				--LOR
	
	--  MRH PTS# 31951 3rd party settlements.
	IF @tpr_yes != 'XXX' 
		INSERT INTO #temp_que 
			SELECT DISTINCT ph.pyh_pyhnumber, 
				ph.asgn_type, 
				ph.asgn_id, 
				ph.pyh_paystatus, 
				ph.pyh_payperiod, 
				ph.pyh_totalcomp, 
				ph.pyh_totaldeduct, 
				ph.pyh_totalreimbrs, 
				ph.pyh_totalcomp + ph.pyh_totaldeduct + ph.pyh_totalreimbrs, 
				ph.pyh_payto, 
				NULL, 
				tp.tpr_name, 
				case 
					when len(pt.pto_companyname) > 0 then pt.pto_companyname
					else pt.pto_lastfirst
					end,
				NULL, 
				NULL, 
				NULL, 
				NULL, 
				(SELECT COUNT(DISTINCT pd.pyd_number) 
					FROM paydetail pd 
					--BEGIN PTS 55217 SPN
					LEFT OUTER JOIN invoiceheader i ON pd.mov_number = i.mov_number
					--END PTS 55217 SPN
					WHERE pd.pyh_number = ph.pyh_pyhnumber
					--BEGIN PTS 55217 SPN
					AND (IsNull(i.ivh_billto,'UNKNOWN') = @ivh_billto OR @ivh_billto = 'UNKNOWN')
					AND (CharIndex(','+IsNull(i.ivh_revtype1,'UNK')+',',@ivh_revtype1) > 0 OR @ivh_revtype1 = 'UNK')
					--END PTS 55217 SPN
					), 
				pt.pto_ssn 
			FROM payheader ph LEFT OUTER JOIN payto pt ON ph.pyh_payto = pt.pto_id, 
			thirdpartyprofile tp
			WHERE ph.pyh_payperiod BETWEEN @lopaydate AND @hipaydate AND 
				ph.pyh_paystatus IN (@hldstatus, @pndstatus, @colstatus, @relstatus, @prnstatus, @xfrstatus) AND 
				ph.asgn_type = 'TPR' AND 
				@tpr_id IN ('UNKNOWN', ph.asgn_id) AND 
				ph.asgn_id = tp.tpr_id AND 
				@tpr_type IN ('UNKNOWN', tp.tpr_type) AND 
				((@acct_type = 'X' AND tp.tpr_actg_type IN ('A', 'P')) OR 
				(@acct_type = tp.tpr_actg_type) )
				--MRH
END

SELECT * 
FROM #temp_que 
WHERE det_count > 0

DROP TABLE #temp_que

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_queue_sp_new] TO [public]
GO
