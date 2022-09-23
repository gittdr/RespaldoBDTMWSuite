SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_flarock_payxface]
AS

DECLARE @vchar12 varchar(12), @money money


SELECT @money = 0.00 
SELECT @vchar12 = '            '
 
CREATE TABLE #payview ( pyh_pyhnumber int,
			pyh_paystatus varchar(6),
			pyh_amount money,
			revtype1 int NULL,
			mpp_ssn varchar(9),
			psd_date datetime NULL,
			asgn_id varchar(8))


INSERT INTO #payview
SELECT
		 ph.pyh_pyhnumber,
		 ISNULL(ph.pyh_paystatus, ''),
		 ISNULL(ph.pyh_totalcomp, 0),
		 ISNULL(lf.code, 0),
		 ISNULL(mp.mpp_ssn, ''),
		 ph.pyh_payperiod,
		 ISNULL(ph.asgn_id, '')
FROM  manpowerprofile mp  LEFT OUTER JOIN  labelfile lf  ON  (mp.mpp_terminal  = lf.abbr and lf.labeldefinition  = 'RevType1'),
	 payheader ph 
WHERE	 (ph.pyh_paystatus  = 'REL')
 AND	(ph.asgn_type  = 'DRV')
 AND	(ph.asgn_id  = mp.mpp_id)

SELECT * from #payview
GO
GRANT EXECUTE ON  [dbo].[d_flarock_payxface] TO [public]
GO
