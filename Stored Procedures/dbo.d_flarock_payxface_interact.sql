SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_flarock_payxface_interact]
@pyh_number		int
AS
/**
 * 
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @vchar12 varchar(12), @money money


SELECT @money = 0.00 
SELECT @vchar12 = '            '
 
CREATE TABLE #payview_interact
			( pyh_pyhnumber int,
			pyh_paystatus varchar(6),
			pyh_amount money,
			pyh_deductions money,
			pyh_reimbursments money,
			revtype1 int NULL,
			mpp_ssn varchar(9),
			psd_date datetime NULL,
			asgn_id varchar(8))


INSERT INTO #payview_interact
SELECT	ph.pyh_pyhnumber,
	IsNull(ph.pyh_paystatus, ''),
	Sum(IsNull(pd.pyd_amount, 0)),
	IsNull(ph.pyh_totaldeduct,0),
	IsNull(ph.pyh_totalreimbrs,0),
	IsNull(lf.code, 0),
	IsNull(mp.mpp_ssn, ''),
	ph.pyh_payperiod,
	IsNull(ph.asgn_id, '')
FROM  manpowerprofile mp  LEFT OUTER JOIN  labelfile lf  ON (mp.mpp_terminal = lf.abbr and lf.labeldefinition = 'RevType1'),
	 payheader ph,
	 paydetail pd 
WHERE	 (ph.asgn_type  = 'DRV')
 AND	(ph.asgn_id  = mp.mpp_id)
 AND	(ph.pyh_pyhnumber  = @pyh_number)
 AND	(ph.pyh_pyhnumber  = pd.pyh_number)
GROUP BY ph.pyh_pyhnumber,
	IsNull(ph.pyh_paystatus, ''),
	IsNull(ph.pyh_totaldeduct,0),
	IsNull(ph.pyh_totalreimbrs,0),
	IsNull(lf.code, 0),
	IsNull(mp.mpp_ssn, ''),
	ph.pyh_payperiod,
	IsNull(ph.asgn_id, '')


SELECT * from #payview_interact
GO
GRANT EXECUTE ON  [dbo].[d_flarock_payxface_interact] TO [public]
GO
