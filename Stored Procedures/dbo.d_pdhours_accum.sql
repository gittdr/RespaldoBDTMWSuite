SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 CREATE PROC [dbo].[d_pdhours_accum] (@asgn_id VARCHAR(13), @asgn_type VARCHAR(6), @payperiodstart DATETIME, @payperiodend DATETIME)  
AS  
  
CREATE TABLE #hours  
      (asgnid VARCHAR(13) NULL,  
       asgntype VARCHAR(6) NULL,   
       workperiod DATETIME NULL,   
       payperiod DATETIME NULL,   
       hoursworked DECIMAL(8, 2) NULL,  
       weekending DATETIME NULL,  
       othours DECIMAL(8,2) NULL,  
       eihours DECIMAL(8,2) NULL  
       )  
/*  
DPETE 28888 adjust the hours report to show time in the last week of the prior  
    payperiod that would be included in overtime in the current pay period - hours worked between   
    12 am sunday to the date at the beginnig of the work period. Also bring back OT and EI hours  
DPETE 28015 show hours up thru the sat urday of the period end date week
DPETE 29275 period start date is bad when a bonus was paid driver before this pay period
DPETE 40260 recode Pauls into Main SOurce 4/19/08
*/

/* fudged to compensate for bad pay period start */ 
select @payperiodstart = max(psd_date) from payschedulesdetail 
where psh_id = (select min(psh_id) from payschedulesheader) and psd_date <  CAST(FLOOR(CAST(@payperiodend AS FLOAT)) AS DATETIME)
  
-- Adjust pay period start to the sunday date in the week in which the payperiodstart falls  
select @payperiodstart =  Dateadd(d,-(datepart(dw,@payperiodstart) - 1),@payperiodstart)  
Select @payperiodend = Dateadd(d, 7 - datepart(dw,@payperiodend), @payperiodend)
 

  
INSERT INTO #hours (asgnid, asgntype, workperiod, payperiod, hoursworked, weekending,othours,eihours)  
     SELECT asgn_type, asgn_id, pyd_workperiod, pyh_payperiod, SUM(pdh_standardhours),    
            CONVERT(DATETIME, CONVERT(VARCHAR(10), pdh_date, 101)) + (7 - DATEPART(dw, pdh_date))  
            ,othours = SUM(IsNull(pdh_othours,0)), eihours = SUM(IsNull(pdh_eihours,0))  
       FROM paydetail, pdhours   
      WHERE pdhours.pyd_number = paydetail.pyd_number   
            AND pdh_date BETWEEN @payperiodstart AND @payperiodend   
            AND asgn_id = @asgn_id   
            AND asgn_type = @asgn_type  
            AND pyh_payperiod < '20491231'  
   GROUP BY asgn_type, asgn_id, pyd_workperiod, pyh_payperiod,   
            CONVERT(DATETIME, CONVERT(VARCHAR(10), pdh_date, 101)) + (7 - DATEPART(dw, pdh_date))  
  
-- code to update the week ending date  
SELECT workperiod, payperiod, weekending, hoursworked,othours,eihours   
  FROM #hours   
  
DROP TABLE #hours  

GO
GRANT EXECUTE ON  [dbo].[d_pdhours_accum] TO [public]
GO
