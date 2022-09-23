SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  Returns payroll export planning board data
  Revision History:
  Date         Name             Label/Card     Description
  -----------  ---------------  -------------  ----------------------------------------
  05/11/2017   BackOffice       NSUITE-200525  Initial Release
********************************************************************************************************************/

CREATE PROCEDURE [dbo].[PRExportPlanningBoard_sp]    
(
	@PayScheduleList	VARCHAR(4000),
	@DateList			VARCHAR(4000),
    @PayStatusList      VARCHAR(100),
    @DriverId           VARCHAR(50)
)  
AS


/**
*
* NAME:
* dbo.PRExportPlanningBoard_sp
*
* TYPE:
* Stored Procedure
*
* DESCRIPTION:
* Stored Procedure used as a data source for the accounts payable transfer queue.
*
* RESULT SETS:
* pyh_pyhnumber			int
* asgn_id				varchar(13)
* pyh_paystatus			varchar(6)
* pyh_payperiod			datetime
* pyh_taxableearnings	money
* pyh_taxabledeductions	money
* pyh_adjustments		money
* pyh_deductions		money
* payScheduleId			int
*
* PARAMETERS:
* 001 -	@PayScheduleList	varchar(4000),
* 002 -	@DateList			varchar(4000)
*
* Sample Call:
* PRExportPlanningBoard_sp '11', '2014/06/01'
*
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
		JOIN manpowerprofile mp ON mp.PayScheduleId = st.sch_id AND mp.mpp_actg_type = 'P'
		JOIN payheader ON payheader.asgn_id = mp.mpp_id AND payheader.asgn_type = 'DRV' AND payheader.pyh_payperiod = dt.paydate
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('manpowerprofile', NULL) rsva ON (rsva.rowsec_rsrv_id = mp.rowsec_rsrv_id OR rsva.rowsec_rsrv_id = 0)
		LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id
	WHERE payheader.pyh_paystatus IN (SELECT payStatus FROM @payStatusTable)
      AND
      payheader.pyh_prorap = 'P'
	  AND
      mp.mpp_id LIKE @DriverId + '%'

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
	payScheduleId
FROM #temp
ORDER BY asgn_id

DROP TABLE #temp

GO
GRANT EXECUTE ON  [dbo].[PRExportPlanningBoard_sp] TO [public]
GO
