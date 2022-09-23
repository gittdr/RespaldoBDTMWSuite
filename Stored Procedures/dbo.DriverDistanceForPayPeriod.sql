SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE PROC [dbo].[DriverDistanceForPayPeriod] (@asgn_id VARCHAR(13), @asgn_type VARCHAR(6), @payperiodstart DATETIME, @payperiodend DATETIME)  
AS  
/*  
DPETE 26888 - get the total miles driven on trips settled for the give pay period  
DPETE 26888 (2/22/05) - per dsk compare start and end to workperiod, not pay period  
DPETE 27327 (3/15/05) sum stp_lgh_mileage instead of leg_miles 
DPETE 28015 when a delay pay item form period 1 was paid in period 2 the distance
    for that trip was included.  limit lgh_numbers to pay for distance
DPETE 40260 recode Pauls 4/19/08
*/  
Select SUM(stp_lgh_mileage) from stops,(Select distinct lgh_number From Paydetail   
        Where  pyd_workperiod BETWEEN @payperiodstart and @payperiodend
        AND asgn_id =  @asgn_id     
        AND asgn_type = @asgn_type    
        AND pyh_payperiod < '20491231'
        AND pyd_unit = 'KMS') LGH   
--Where  pyd_workperiod BETWEEN @payperiodstart and @payperiodend 
 Where stops.lgh_number = LGH.lgh_number  
 

GO
GRANT EXECUTE ON  [dbo].[DriverDistanceForPayPeriod] TO [public]
GO
