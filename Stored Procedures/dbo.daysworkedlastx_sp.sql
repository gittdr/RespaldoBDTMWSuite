SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

  
CREATE PROC [dbo].[daysworkedlastx_sp] (@driver varchar(8)  
, @holiday datetime)  
AS    
/* Determine the number of days a driver worked in the last X days (from GI) prior to  
  a passed holiday date  
  Simply counts elapsed days of assigments without regard to hours  
  Gives the driver credit for any holidays that occurred during the X days (unless they occurred  
  before or after his employment  
    
  PTS 67184 DPETE created and added field for debugging indicating if record came from assignment (lgh_number > 0)  or holiday (lgh = 0)  
  */  
 declare @returnset table (asgn_date datetime, asgn_enddate datetime, days int, lgh_number int)   
 declare @paidholidays table (holidaydate datetime,pyh_payperiod datetime )   
   
 declare @start datetime, @end datetime, @hire datetime, @termination datetime  
 declare @holidaystart datetime, @holidayend datetime  
 declare @daysback int,@STATPayCode varchar(10)  
   
 Select @STATPayCode = gi_string1 from generalinfo where gi_name = 'StatPayCode'  
 Select @STATPayCode = ISNULL(@STATPayCode,'STAT')  
   
   
 --select asgn_id,pyh_payperiod  from paydetail where pyt_itemcode = 'STAT' alvkur  
 /* for future provide a GI setting that can allow for variable days back Currently they are only using 30 */  
 select @daysback = gi_integer1  from generalinfo where gi_name = 'DaysWorkedBackDays'  
 select @daysback =  ISNULL(@daysback,30) * -1  
   
 select @hire = mpp_hiredate,@termination = mpp_terminationdt  
 from manpowerprofile where mpp_id = @driver  
   
 /* make sure this date has time = 00:00 */  
 select @holiday = CAST(FLOOR(CAST(@holiday AS FLOAT)) AS DATETIME)  
   
 /* range of dates withing which the drivers work assingments are counted ends 1 minute before the holiday */  
 select @start = DATEADD(dd,@daysback,@holiday)  
 select @end = DATEADD(MI,-1,@holiday)  
  
   
 /* if driver was hired after the start date move the staret date up to not count holidays prior to the hire date  
    if a driver quit before the holiday do not count holidays after the termination date      
 */  
 select @holidaystart = @start  
 If @hire > @start select @holidaystart = CAST(FLOOR(CAST(@hire AS FLOAT)) AS DATETIME)  
 select @holidayend = @end  
 IF @termination < @holiday select @holidayend = @termination  
  
/* get a list of recent paid holidays for this driver */   
  Insert into @paidholidays  
 Select pdh_date, pyh_payperiod  
 FROM paydetail  
 JOIN pdhours on paydetail.pyd_number = pdhours.pyd_number  
 WHERE paydetail.asgn_type = 'DRV'  
 AND asgn_id = @driver  
 AND pyt_itemcode = @STATPayCode
 and pyd_amount > 0  
 AND pyh_payperiod >= @start  
  
  
  
 Insert into @returnset  
 SELECT assetassignment.asgn_date     
         ,CASE WHEN assetassignment.asgn_enddate> @end then @end ELSE assetassignment.asgn_enddate END asgn_enddate  
         ,CASE WHEN assetassignment.asgn_enddate> @end then DateDiff(dd, asgn_date, @end) +1 ELSE DateDiff(dd, asgn_date, asgn_enddate) + 1 END days  
        ,lgh_number  
    FROM assetassignment     
WHERE  asgn_date between @start AND @end  
  AND  asgn_type = 'DRV'  
  AND  asgn_id = @driver  
  
INSERT INTO @returnset  
SELECT holiday,holiday,1,0  
FROM holidays   
Join @paidholidays paid on holidays.holiday = paid.holidaydate  
WHERE holiday between @holidaystart and @holidayend /*credit driver with any holidays in period while employed*/  
  
SELECT asgn_date,asgn_enddate,days,lgh_number FROM @returnset  
ORDER BY asgn_date,asgn_enddate  
  
GO
GRANT EXECUTE ON  [dbo].[daysworkedlastx_sp] TO [public]
GO
