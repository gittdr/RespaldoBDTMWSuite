SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[getweekfordate_sp] @date DATETIME          
AS          
/* Used to provide a week number that is the same for all the days in a given week.  
  Returns the week number of the last day of the week that this date falls in  
  
  If the week is   SUN Dec 29, MON Dec 30, TUE Dec 31, WED Jan1,  THU Jan 2, FRI Jan 3, SAT Jan 4  
  and you pass any one of the dates in this week the proc will return a 1  

PTS50443 DPETE 1/6/10 return year with week number
  
*/  
declare @week int 
  
select @week = Datepart(ww,dateadd(d,7 - (select datepart(dw,@date)),@date))
select @week = @week + ( Datepart(yyyy,dateadd(d,7 - (select datepart(dw,@date)),@date)) * 100 )
  
Return @week 
GO
GRANT EXECUTE ON  [dbo].[getweekfordate_sp] TO [public]
GO
