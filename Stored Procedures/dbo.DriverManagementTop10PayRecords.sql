SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[DriverManagementTop10PayRecords] (@asgn_ID VARCHAR(12))
												
AS

BEGIN

SELECT TOP 10  
 pyh_payperiod
, pyh_totalcomp
, (SELECT SUM(x.pyh_totalcomp) / COUNT(DISTINCT x.asgn_id) FROM dbo.payheader x WHERE x.asgn_type = payheader.asgn_type AND x.pyh_payperiod = payheader.pyh_payperiod) as AverageDriverPay
FROM 
 dbo.payheader
WHERE
 asgn_type = 'DRV'
 AND
 asgn_id = @asgn_id
ORDER BY 
  pyh_payperiod DESC;
END
GO
GRANT EXECUTE ON  [dbo].[DriverManagementTop10PayRecords] TO [public]
GO
