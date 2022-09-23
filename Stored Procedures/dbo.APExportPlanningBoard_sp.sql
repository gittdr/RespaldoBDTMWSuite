SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  Returns ap export planning board data
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  12/02/2014   BackOffice       PTS: 84569  Initial Release
  08/12/2016   BackOffice       PTS: 103177 Add join conditions
  09/19/2016   BackOffice       PTS: 105015 AP retransfer 
********************************************************************************************************************/

CREATE PROCEDURE [dbo].[APExportPlanningBoard_sp]    
(
	@PayScheduleList	varchar(4000),
	@DateList			varchar(4000),
    @PayStatusList      varchar(100)
)  
AS


/**
*
* NAME:
* dbo.APExportPlanningBoard_sp
*
* TYPE:
* Stored Procedure
*
* DESCRIPTION:
* Stored Procedure used as a data source for the accounts payable transfer queue.
*
* RESULT SETS:
* pyh_pyhnumber			int
* asgn_type				char(6)
* asgn_id				varchar(13)
* pyh_paystatus			varchar(6)
* pyh_payperiod			datetime
* pyh_taxableearnings	money
* pyh_taxabledeductions	money
* pyh_adjustments		money
* pyh_deductions		money
* pyh_payto				varchar(12)
* payScheduleId			int
*
* PARAMETERS:
* 001 -	@PayScheduleList	varchar(4000),
* 002 -	@DateList			varchar(4000)
*
* Sample Call:
* APExportPlanningBoard_sp '11', '2014/06/01'
*
* REVISION HISTORY:
* 12/02/14 | PTS 84569 | KW - created proc from collect queue proc
*/

CREATE TABLE #temp 
(
	pyh_pyhnumber			INT,
	asgn_type				VARCHAR(6),
	asgn_id					VARCHAR(13),
	pyh_paystatus			VARCHAR(6),
	pyh_payperiod			DATETIME,
	pyh_taxableearnings		DECIMAL(17,2),
	pyh_taxabledeductions	DECIMAL(17,2),
	pyh_adjustments			DECIMAL(17,2),
	pyh_deductions			DECIMAL(17,2),
	pyh_payto				VARCHAR(12),
	payScheduleId			INT
)

DECLARE @scheduletable TABLE
(
	st_id	INT	IDENTITY,
	sch_id	INT
)

DECLARE @datetable TABLE
(
	dt_id	INT	IDENTITY,
	paydate	DATETIME
)

DECLARE @payStatusTable TABLE
(
    id INT IDENTITY(1, 1),
    payStatus VARCHAR(6)
)

EXEC dbo.UpdateAssetSchedules_sp

INSERT @scheduletable (sch_id)
  SELECT [Value] FROM CSVStringsToTable_fn(@PayScheduleList)

INSERT @datetable (paydate)
  SELECT [Value] FROM CSVStringsToTable_fn(@DateList)

IF LTRIM(RTRIM(@PayStatusList)) = ''
BEGIN
  INSERT @payStatusTable(payStatus)
  VALUES('REL')
END
ELSE
BEGIN
  INSERT @payStatusTable(payStatus)
    SELECT [Value] FROM CSVStringsToTable_fn(@PayStatusList)
END

INSERT INTO #temp 
	SELECT DISTINCT 
		payheader.pyh_pyhnumber,
		payheader.asgn_type,
		payheader.asgn_id,
		payheader.pyh_paystatus,
		payheader.pyh_payperiod,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxableearnings,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxabledeductions,
		CAST (0 AS DECIMAL(17,2)) AS pyh_adjustments,
		CAST (0 AS DECIMAL(17,2)) AS pyh_deductions,
		payheader.pyh_payto,
		st.sch_id
	FROM @scheduletable st
		JOIN @datetable dt ON dt.dt_id = st.st_id
		JOIN manpowerprofile mp ON mp.PayScheduleId = st.sch_id AND mp.mpp_actg_type = 'A'
		JOIN payheader ON payheader.asgn_id = mp.mpp_id AND payheader.asgn_type = 'DRV' AND payheader.pyh_payperiod = dt.paydate
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('manpowerprofile', NULL) rsva ON (rsva.rowsec_rsrv_id = mp.rowsec_rsrv_id OR rsva.rowsec_rsrv_id = 0)
		LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id
	WHERE payheader.pyh_paystatus IN (SELECT payStatus FROM @payStatusTable)
			
INSERT INTO #temp 
	SELECT DISTINCT 
		payheader.pyh_pyhnumber,
		payheader.asgn_type,
		payheader.asgn_id,
		payheader.pyh_paystatus,
		payheader.pyh_payperiod,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxableearnings,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxabledeductions,
		CAST (0 AS DECIMAL(17,2)) AS pyh_adjustments,
		CAST (0 AS DECIMAL(17,2)) AS pyh_deductions,
		payheader.pyh_payto,
		st.sch_id
	FROM @scheduletable st
		JOIN @datetable dt ON dt.dt_id = st.st_id
		JOIN tractorprofile tp ON tp.PayScheduleId = st.sch_id AND tp.trc_actg_type = 'A'
		JOIN payheader ON payheader.asgn_id = tp.trc_number AND payheader.asgn_type = 'TRC' AND payheader.pyh_payperiod = dt.paydate
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('tractorprofile', NULL) rsva ON (rsva.rowsec_rsrv_id = tp.rowsec_rsrv_id OR rsva.rowsec_rsrv_id = 0)
		LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id
	WHERE payheader.pyh_paystatus IN (SELECT payStatus FROM @payStatusTable)

INSERT INTO #temp 
	SELECT DISTINCT 
		payheader.pyh_pyhnumber,
		payheader.asgn_type,
		payheader.asgn_id,
		payheader.pyh_paystatus,
		payheader.pyh_payperiod,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxableearnings,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxabledeductions,
		CAST (0 AS DECIMAL(17,2)) AS pyh_adjustments,
		CAST (0 AS DECIMAL(17,2)) AS pyh_deductions,
		payheader.pyh_payto,
		st.sch_id
	FROM @scheduletable st
		JOIN @datetable dt ON dt.dt_id = st.st_id
		JOIN carrier cr ON cr.PayScheduleId = st.sch_id AND cr.car_actg_type = 'A'
		JOIN payheader  ON payheader.asgn_id = cr.car_id AND payheader.asgn_type = 'CAR' AND payheader.pyh_payperiod = dt.paydate
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('carrier', NULL) rsva ON (rsva.rowsec_rsrv_id = cr.rowsec_rsrv_id OR rsva.rowsec_rsrv_id = 0)
		LEFT OUTER JOIN payto on payheader.pyh_payto = payto.pto_id
	WHERE payheader.pyh_paystatus IN (SELECT payStatus FROM @payStatusTable)

INSERT INTO #temp
	SELECT DISTINCT 
		payheader.pyh_pyhnumber,
		payheader.asgn_type,
		payheader.asgn_id,
		payheader.pyh_paystatus,
		payheader.pyh_payperiod,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxableearnings,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxabledeductions,
		CAST (0 AS DECIMAL(17,2)) AS pyh_adjustments,
		CAST (0 AS DECIMAL(17,2)) AS pyh_deductions,
		payheader.pyh_payto,
		st.sch_id
	FROM @scheduletable st
		JOIN @datetable dt ON dt.dt_id = st.st_id
		JOIN thirdpartyprofile tpr ON tpr.PayScheduleId = st.sch_id AND tpr.tpr_actg_type = 'A'
		JOIN payheader ON payheader.asgn_id = tpr.tpr_id AND payheader.asgn_type = 'TPR' and payheader.pyh_payperiod = dt.paydate
		LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id
	WHERE payheader.pyh_paystatus IN (SELECT payStatus FROM @payStatusTable)

INSERT INTO #temp 
	SELECT DISTINCT 
		payheader.pyh_pyhnumber,
		payheader.asgn_type,
		payheader.asgn_id,
		payheader.pyh_paystatus,
		payheader.pyh_payperiod,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxableearnings,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxabledeductions,
		CAST (0 AS DECIMAL(17,2)) AS pyh_adjustments,
		CAST (0 AS DECIMAL(17,2)) AS pyh_deductions,
		payheader.pyh_payto,
		st.sch_id
	FROM @scheduletable st
		JOIN @datetable dt ON dt.dt_id = st.st_id
		JOIN trailerprofile tp ON tp.PayScheduleId = st.sch_id AND tp.trl_actg_type = 'A'
		JOIN payheader ON payheader.asgn_id = tp.trl_id AND payheader.asgn_type = 'TRL' AND payheader.pyh_payperiod = dt.paydate
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('trailerprofile', NULL) rsva ON (rsva.rowsec_rsrv_id = tp.rowsec_rsrv_id OR rsva.rowsec_rsrv_id = 0)
		LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id
	WHERE payheader.pyh_paystatus IN (SELECT payStatus FROM @payStatusTable)

INSERT INTO #temp 
	SELECT DISTINCT 
		payheader.pyh_pyhnumber,
		payheader.asgn_type,
		payheader.asgn_id,
		payheader.pyh_paystatus,
		payheader.pyh_payperiod,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxableearnings,
		CAST (0 AS DECIMAL(17,2)) AS pyh_taxabledeductions,
		CAST (0 AS DECIMAL(17,2)) AS pyh_adjustments,
		CAST (0 AS DECIMAL(17,2)) AS pyh_deductions,
		payheader.pyh_payto,
		st.sch_id
	FROM @scheduletable st
		JOIN @datetable dt ON dt.dt_id = st.st_id
		JOIN payto pto ON pto.PayScheduleId = st.sch_id
		JOIN payheader ON payheader.pyh_payto = pto.pto_id AND payheader.asgn_type = 'PTO' AND payheader.pyh_payperiod = dt.paydate
	WHERE  payheader.pyh_paystatus IN (SELECT payStatus FROM @payStatusTable)

--update summary information using similar logic to the final settlements summary secion in back office
UPDATE a 
SET
	pyh_taxableearnings		= sum_pyh_taxableearnings,
	pyh_taxabledeductions	= sum_pyh_taxabledeductions,
	pyh_adjustments			= sum_pyh_adjustments,
	pyh_deductions			= sum_pyh_deductions
FROM #temp a
JOIN
(
	SELECT pyh_number, 
		SUM ( CASE WHEN (pyd_amount > 0 AND pyd_pretax = 'Y') THEN paydetail.pyd_amount ELSE 0 END) AS sum_pyh_taxableearnings, 
		SUM ( CASE WHEN (pyd_amount < 0 AND pyd_pretax = 'Y') THEN paydetail.pyd_amount ELSE 0 END) AS sum_pyh_taxabledeductions, 
		SUM ( CASE WHEN (pyd_amount > 0 AND pyd_pretax = 'N') THEN paydetail.pyd_amount ELSE 0 END) AS sum_pyh_adjustments, 
		SUM ( CASE WHEN (pyd_amount < 0 AND pyd_pretax = 'N') THEN paydetail.pyd_amount ELSE 0 END) AS sum_pyh_deductions
	FROM paydetail
	GROUP BY pyh_number
) s ON a.pyh_pyhnumber = s.pyh_number

SELECT 
	pyh_pyhnumber,
	CASE 
		WHEN asgn_type = 'DRV' THEN 'Driver'
		WHEN asgn_type = 'TRC' THEN 'Tractor'
		WHEN asgn_type = 'TRL' THEN 'Trailer'
		WHEN asgn_type = 'CAR' THEN 'Carrier'
		WHEN asgn_type = 'PTO' THEN 'PayTo' 
	END AS asgn_type, 
	asgn_id,
	CASE 
		WHEN pyh_paystatus = 'PND' THEN 'Released'
		WHEN pyh_paystatus = 'COL' THEN 'Collected'
		WHEN pyh_paystatus = 'REL' THEN 'Closed'
		WHEN pyh_paystatus = 'XFR' THEN 'Transferred'		
	END AS pyh_paystatus, 
	CONVERT(NVARCHAR(12), pyh_payperiod, 101) AS pyh_payperiod,
	ABS(ISNULL(pyh_taxableearnings, 0)) AS pyh_taxableearnings,
	ABS(ISNULL(pyh_taxabledeductions, 0)) AS pyh_taxabledeductions,
	ABS(ISNULL(pyh_adjustments, 0)) AS pyh_adjustments,
	ABS(ISNULL(pyh_deductions, 0)) AS pyh_deductions,
	pyh_payto,
	payScheduleId
FROM #temp
ORDER BY asgn_type, asgn_id

DROP TABLE #temp

GO
GRANT EXECUTE ON  [dbo].[APExportPlanningBoard_sp] TO [public]
GO
