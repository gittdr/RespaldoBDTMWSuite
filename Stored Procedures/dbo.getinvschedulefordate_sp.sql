SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE  [dbo].[getinvschedulefordate_sp]  (@p_date datetime,@p_perioddate datetime OUTPUT, @p_periodyear int OUTPUT, @p_period int OUTPUT)
AS
 /*
   sample use
   
      declare @indate datetime,@outdate datetime,@outyear int, @outperiod int
      select @indate = '20110513 12:31',@outdate = '19500101 00:00',@outyear = 0, @outperiod = 0
      exec getinvschedulefordate_sp @indate,@outdate OUTPUT,@outyear OUTPUT, @outperiod OUTPUT
      select '##',@outdate,@outyear,@outperiod
  
  REVISION
  7/26/11 DPETE created for PTS 56953 Return the billing schedule close date, period and year
       associated with the date on the order passed as an argument
       
  */
 BEGIN
     
     
     select @p_perioddate = min(ish_end_date)
     from invscheduleheader
     where ish_end_date >= @p_date
     and ish_status = 'OPN'
     
     if @p_perioddate  is not null
        select @p_periodyear = ish_year
        ,@p_period = ish_period
        from invscheduleheader
        where ish_end_date = @p_perioddate
     
     select @p_perioddate =  coalesce(@p_perioddate,'20491231 23:59:59')
     Select @p_periodyear = coalesce(@p_periodyear,0)
     Select @p_period = coalesce(@p_period,0)
  end
GO
GRANT EXECUTE ON  [dbo].[getinvschedulefordate_sp] TO [public]
GO
