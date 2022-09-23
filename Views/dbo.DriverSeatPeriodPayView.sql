SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[DriverSeatPeriodPayView]
AS
     WITH PAYSTOPS
          AS (SELECT paylegs.pyh_pyhnumber,
                     paylegs.asgn_type,
                     paylegs.asgn_id,
                     SUM(CASE WHEN stp_loadstatus = 'LD' THEN stp_lgh_mileage ELSE 0 END) 'LoadedMiles',
                     SUM(CASE WHEN stp_loadstatus <> 'LD' THEN stp_lgh_mileage ELSE 0 END) 'EmptyMiles'
              FROM (
				SELECT DISTINCT 
                   ph.pyh_pyhnumber, 
                   ph.asgn_type, 
                   ph.asgn_id, 
                   pd.lgh_number 
				FROM 
                   payheader ph JOIN 
                   paydetail pd ON pd.pyh_number = ph.pyh_pyhnumber
				) as paylegs JOIN
					 stops s on s.lgh_number = paylegs.lgh_number
              GROUP BY paylegs.pyh_pyhnumber, paylegs.asgn_type, paylegs.asgn_id)

          SELECT 

          /*Required Columns*/

          ISNULL(pay.pyh_pyhnumber, 0) pyh_pyhnumber,
          pay.pyh_payperiod,
          pay.asgn_type,
          pay.asgn_id, 	   
	   
          /*End Required Columns*/

          /*Start Optional Columns*/

          pay.pyh_totalcomp TotalCompensation,
          pay.pyh_totaldeduct TotalDeductions,
          pay.pyh_totalreimbrs TotalReimbursement,
          pay.pyh_totalcomp + pay.pyh_totaldeduct + pay.pyh_totalreimbrs TotalPay,
	   
          /*END Optional Columns*/

          lbl.name [Status],
          pay.pyh_paystatus [Pay Status],
          pay.pyh_issuedate [Issue Date],
          --,pay.processed [Processed]	   

          PAYSTOPS.EmptyMiles,
          PAYSTOPS.LoadedMiles
          FROM payheader pay
               LEFT OUTER JOIN labelfile AS lbl ON pay.pyh_paystatus = lbl.abbr
                                                   AND lbl.labeldefinition = 'PayStatus'
               LEFT OUTER JOIN PAYSTOPS ON PAYSTOPS.pyh_pyhnumber = pay.pyh_pyhnumber
          WHERE pay.pyh_paystatus IN('REL', 'XFR');
GO
GRANT INSERT ON  [dbo].[DriverSeatPeriodPayView] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverSeatPeriodPayView] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverSeatPeriodPayView] TO [public]
GO
