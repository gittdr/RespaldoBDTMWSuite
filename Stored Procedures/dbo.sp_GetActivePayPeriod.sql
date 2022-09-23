SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetActivePayPeriod]
		(				
			@asgn_type char(6),
			@asgn_id varchar(13)
		)

AS
BEGIN 

SELECT MAX(pyh_payperiod)
FROM payheader  (NOLOCK)
WHERE (asgn_type = @asgn_type) AND (asgn_id = @asgn_id) AND (pyh_paystatus IN ('XFR','REL', 'COL'))

END
GO
GRANT EXECUTE ON  [dbo].[sp_GetActivePayPeriod] TO [public]
GO
