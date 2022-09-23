SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetStopLocOpenInfo]        
 @p_cmpid varchar(8),@p_Stopdate datetime      
        
AS        
/**        
 *         
 * NAME:        
 * dbo.GetStopLocOpenInfo        
 *        
 * TYPE:        
 * StoredProcedure        
 *        
 * DESCRIPTION:        
 * Pass an stop companyID and the arrival date,It will return the work date, the work day (day of week where 1 = SUN), A flag Y or N if the        
 * location is normally open at this time , a flag Y or N to indicate a holiday is being observed at this time, and the labelfile code for the holiday        
 * an indication if the prioe work day was a holiday and, if so, which holiday, an indication that the next day is a holiday, and if so which one.        
 *        
 *         
 *        
 * if GI 'SchedulerHolidayOptions' and GI string 2 = 'WorkHrsHoliday'        
 * If GI setting 'SchedulerHolidayOptions' string 2 set to 'WorkHrsHoliday' A holiday is observed only during compan open hours. For example        
 * if the work hours are 8 AM to 5 PM and the stop time is at 6 PM, the holiday observance flag will never get set to Y even if the        
 * date is on an observed holiday date.  Also if Christmas falls on Tuesday, but the company profile open hours maintenance indicates        
 * Tuesday Holidays are observed on the prior day, than any stop time on Tuesday the 25th of December will not be flagged as a holiday        
 *        
 * gi string 2 not set to 'WorkHrsHoliday'        
 * If the string 2 value is not set to 'WorkHrsHoliday' the holiday is flagged as being observed for a 24 hour period.  If the         
 * company hours of operation are during the same day ( like 8 AM to 6 PM ) then the holiday runs from midnight to midnight on that day.        
 * If the stop date time is Dec 25 at 7 Am ( and the holiday is observed on the same day) the Holiday Observtion flag will be set Y        
 * and the IsOpen flag will be set to N.  If the stop time is 8 AM the holiday flag will be Y and the is open flag will by Y (normally        
 * open on this day of the week at this time of the day).          
 *        
 * If the hours of operation span two days  ( 10 PM on Monday to 9 AM on Tuesday), the Holiday         
 * observance will run from the start of business on the work day that matches the holiday date and run for 24 hours.  If the Tuesday hours        
 * run from 10 PM on Monday to 9 AM on Tuesday and Christmas falls on TUesday and is observed ont he same day then the holdiay flag        
 * will be set for stops falling between 10 PM on Monday thru to 9:59 PM on Tuesday.        
        
 * RETURNS:        
 * no return code        
 *        
 * RESULT SETS:         
 *  @v_Workdate as work_date  (or shift date if company open form 10 PM on Monday to 8 AM Tuesday and  
 *           flag is set that start time is in Monday, then 2 am on Tuesday is t=returned as a the  
 *           Monday or "work day" date.  
 *    ,@v_DayOfWeek as day_of_week      
 *    ,@v_IsOpen as is_open    
 *    ,@v_IsHolidayObs as is_holiday_obs    
 *    ,@v_holidaycode as holiday_code     
 *    ,@v_holidaygroup as holiday_group    
 *    ,@v_IsHolidayObsPriorDay as is_holiday_obs_prior_day    
 *    ,@v_holidaycodePriorDay as holiday_code_prior_day    
 *    ,@v_holidaygroupPriorDay  as holiday_group_prior_day     
 *   ,@v_IsHolidayObsNextDay as is_holiday_obs_next_day    
 *    ,@v_holidaycodeNextDay as holiday_code_next_day    
 *    ,@v_holidaygroupNextDay as holiday_group_next_day  
 *        
 * PARAMETERS:        
 * 001 -  @p_cmpid varchar(8)        
 * 002 - @p_Stopdate datetime         
 *        
 * REFERENCES:        
 *         
 * REVISION HISTORY:        
 * 3/20/07 DPETE/JPISK PTS35732- Created stored proc for SR requireing all  trips to be adjusted for the time zone.        
        
 *        
 **/        
declare @v_Workdate datetime       
declare @v_DayOfWeek smallint      
declare @v_IsOpen char(1),@v_IsHolidayObs char(1)      
declare @v_holidaycode varchar(6),@v_holidaygroup varchar(6)      
declare @v_IsHolidayObsPriorDay char(1), @v_holidaycodePriorDay varchar(6) ,@v_holidaygrouppriorday varchar(6)     
declare @v_IsHolidayObsNextDay char(1), @v_holidaycodeNextDay varchar(6) , @v_holidaygroupNextDay varchar(6)     
declare @v_cmpOpens DateTime, @v_cmpCloses DateTime        
declare @v_cmpPriorDayOpens DateTime,@v_cmpPriorDayCloses DateTime        
declare @v_cmpNextDayOpens DateTime,@v_cmpNextDayCloses DateTime  
declare @v_cmpholidaygroup varchar(6),@v_GIDefaultholidaygroup varchar(6)  
  
   select @v_GIDefaultholidaygroup = rtrim(isnull(gi_string1,'UNK')) from generalinfo where gi_name = 'CmpDefaultHolidayGroup'  
   if @v_GIDefaultholidaygroup = '' select @v_GIDefaultholidaygroup = 'UNK'  
  
   select @v_cmpholidaygroup = isnull(holiday_group, @v_GIDefaultholidaygroup) from company where cmp_id = @p_cmpid  
    
   select @v_IsOpen = 'N',@v_IsHolidayObs = 'N',@v_Workdate = dateadd(dd,0, datediff(dd,0,@p_StopDate))  -- minutes at 11:59 PM plus one        
   set @v_DayOfWeek = datepart(dw,@p_StopDate)        
   /* ================ DETERMIN THE WORK DAY FROM AND TO TIMES IN DateTime FROM THE STOP DATE ====== */        
   /*  */        
   execute dbo.GetStopLocOpenDays @p_cmpid ,@p_Stopdate, @v_cmpOpens output, @v_cmpCloses output, @v_cmpPriorDayOpens output, @v_cmpPriorDayCloses output,    
                                  @v_cmpNextDayOpens output, @v_cmpNextDayCloses output;    
        
   if @v_cmpPriorDayOpens <= @p_stopDate and @p_stopDate <= @v_cmpPriorDayCloses        
   begin        
      set @v_IsOpen    = 'Y';        
      set @v_Workdate  = dateadd(dd,0, datediff(dd,0,@v_cmpPriorDayOpens))        
      set @v_DayOfWeek = datepart(dw,@v_Workdate)        
      execute dbo.GetStopLocOpenDays @p_cmpid , @v_Workdate , @v_cmpOpens output, @v_cmpCloses output, @v_cmpPriorDayOpens output, @v_cmpPriorDayCloses output,    
                                     @v_cmpNextDayOpens output, @v_cmpNextDayCloses output;    
   end        
   else if @v_cmpOpens <= @p_stopDate and @p_stopDate <= @v_cmpCloses         
   begin        
      set @v_IsOpen    = 'Y';        
      set @v_Workdate  = dateadd(dd,0, datediff(dd,0,@v_cmpOpens))        
      set @v_DayOfWeek = datepart(dw,@v_Workdate)        
   end        
   else if @v_cmpNextDayOpens <= @p_stopDate and @p_stopDate <= @v_cmpNextDayCloses        
   begin        
      set @v_IsOpen = 'Y';        
      set @v_Workdate = dateadd(dd,0, datediff(dd,0,@v_cmpNextDayOpens))        
      set @v_DayOfWeek = datepart(dw,@v_Workdate)    
      execute dbo.GetStopLocOpenDays @p_cmpid , @v_Workdate , @v_cmpOpens output, @v_cmpCloses output, @v_cmpPriorDayOpens output,    
                                     @v_cmpPriorDayCloses output, @v_cmpNextDayOpens output, @v_cmpNextDayCloses output;    
   end    
   -- We are closed find the correct work day.  
   -- test prior day same day hours (00:00 - 23:59)  
   else if(dateadd(dd,0, datediff(dd,0,@v_cmpPriorDayOpens)) = dateadd(dd,0, datediff(dd,0,@v_cmpPriorDayCloses)) and dateadd(dd,0, datediff(dd,0,@p_StopDate)) = dateadd(dd,0, datediff(dd,0,@v_cmpPriorDayOpens))) begin  
      set @v_Workdate  = dateadd(dd,0, datediff(dd,0,@v_cmpPriorDayOpens))        
      set @v_DayOfWeek = datepart(dw,@v_Workdate)        
      execute dbo.GetStopLocOpenDays @p_cmpid , @v_Workdate , @v_cmpOpens output, @v_cmpCloses output, @v_cmpPriorDayOpens output, @v_cmpPriorDayCloses output,    
                                     @v_cmpNextDayOpens output, @v_cmpNextDayCloses output;    
   end  
   -- test current day same day hours (00:00 - 23:59)  
   else if(dateadd(dd,0, datediff(dd,0,@v_cmpOpens)) = dateadd(dd,0, datediff(dd,0,@v_cmpOpens)) and dateadd(dd,0, datediff(dd,0,@p_StopDate)) = dateadd(dd,0, datediff(dd,0,@v_cmpOpens))) begin  
      set @v_Workdate  = dateadd(dd,0, datediff(dd,0,@v_cmpOpens))        
      set @v_DayOfWeek = datepart(dw,@v_Workdate)        
   end  
   -- test next day same day hours (00:00 - 23:59)  
   else if(dateadd(dd,0, datediff(dd,0,@v_cmpNextDayOpens)) = dateadd(dd,0, datediff(dd,0,@v_cmpNextDayCloses)) and dateadd(dd,0, datediff(dd,0,@p_StopDate)) = dateadd(dd,0, datediff(dd,0,@v_cmpNextDayOpens))) begin  
      set @v_Workdate  = dateadd(dd,0, datediff(dd,0,@v_cmpNextDayOpens))        
      set @v_DayOfWeek = datepart(dw,@v_Workdate)        
      execute dbo.GetStopLocOpenDays @p_cmpid , @v_Workdate , @v_cmpOpens output, @v_cmpCloses output, @v_cmpPriorDayOpens output, @v_cmpPriorDayCloses output,    
                                     @v_cmpNextDayOpens output, @v_cmpNextDayCloses output;    
   end  
   -- midnight rules  
   else if (@p_stopDate < @v_cmpPriorDayOpens) begin    
      set @v_Workdate  = dateadd(dd,0, datediff(dd,0,@v_cmpPriorDayOpens))        
      set @v_DayOfWeek = datepart(dw,@v_Workdate)        
      execute dbo.GetStopLocOpenDays @p_cmpid , @v_Workdate , @v_cmpOpens output, @v_cmpCloses output, @v_cmpPriorDayOpens output,    
                                     @v_cmpPriorDayCloses output, @v_cmpNextDayOpens output, @v_cmpNextDayCloses output;    
   end    
   else if (@p_stopDate < @v_cmpOpens) begin    
      set @v_Workdate  = dateadd(dd,0, datediff(dd,0,@v_cmpPriorDayOpens))        
      set @v_DayOfWeek = datepart(dw,@v_Workdate)        
      execute dbo.GetStopLocOpenDays @p_cmpid , @v_Workdate , @v_cmpOpens output, @v_cmpCloses output, @v_cmpPriorDayOpens output,    
                                     @v_cmpPriorDayCloses output, @v_cmpNextDayOpens output, @v_cmpNextDayCloses output;    
   end   
  
  -- select 'Trace: Stop Date: ' , cast(@p_stopDate as varchar)        
   --select 'Trace: Work Date: ' , cast(@v_Workdate as varchar)        
   --select 'Trace: Yesterday  ' , cast(@v_cmpPriorDayOpens as varchar) , ' ' + cast(@v_cmpPriorDayCloses as varchar)        
   --select 'Trace: Today      ' , cast(@v_cmpOpens as varchar) + ' ' , cast(@v_cmpCloses as varchar)        
   --select 'Trace: Next Day   ' , cast(@v_cmpNextDayOpens as varchar) + ' ' , cast(@v_cmpNextDayCloses as varchar)        
    
   /* is the adjusted date an observed holiday */        
  -- declare @v_IsHolidayObsPriorDay char(1), @v_holidaycodePriorDay varchar(6)      
  select @v_holidaycodePriorDay = coalesce(holiday_code, '') ,  @v_IsHolidayObsPriorDay = case when holiday_code is not null then 'Y' else '' end,    
         @v_holidaygroupPriorDay  = coalesce(holidays.holiday_group, '')    
  from Holidays, company    
  where  dateadd(dd,0, datediff(dd,0,@v_cmpPriorDayOpens)) = case datepart(dw,holiday)         
     when 1 then dateadd(dd,isnull(cmp_SunObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 2 then dateadd(dd,isnull(cmp_MonObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 3 then dateadd(dd,isnull(cmp_TueObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 4 then dateadd(dd,isnull(cmp_WedObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 5 then dateadd(dd,isnull(cmp_ThuObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 6 then dateadd(dd,isnull(cmp_FriObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 7 then dateadd(dd,isnull(cmp_SatObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
   end    
   and company.cmp_id = @p_cmpid   
   and isnull(holidays.holiday_group,'UNK') = @v_cmpholidaygroup   
      
   If @v_holidaycodePriorDay is null begin      
      select @v_holidaycodePriorDay = '',@v_holidaygroupPriorDay  ='', @v_IsHolidayObsPriorDay= 'N'      
   end      
      
  -- declare @v_IsHolidayObsNextDay char(1), @v_holidaycodeNextDay varchar(6)      
  select @v_holidaycodeNextDay = coalesce(holiday_code, '') ,  @v_IsHolidayObsNextDay = case when holiday_code is not null then 'Y' else '' end,    
         @v_holidaygroupnextDay = coalesce(holidays.holiday_group, '')    
  from Holidays, company    
  where  dateadd(dd,0, datediff(dd,0,@v_cmpNextDayOpens)) = case datepart(dw,holiday)         
     when 1 then dateadd(dd,isnull(cmp_SunObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 2 then dateadd(dd,isnull(cmp_MonObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 3 then dateadd(dd,isnull(cmp_TueObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 4 then dateadd(dd,isnull(cmp_WedObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 5 then dateadd(dd,isnull(cmp_ThuObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 6 then dateadd(dd,isnull(cmp_FriObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 7 then dateadd(dd,isnull(cmp_SatObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
   end       
   and company.cmp_id = @p_cmpid    
   and isnull(holidays.holiday_group,'UNK') = @v_cmpholidaygroup   
      
   If @v_holidaycodeNextDay is null begin      
      select @v_holidaycodeNextDay = '',@v_holidaygroupnextDay  = '', @v_IsHolidayObsNextDay= 'N'      
   end      
      
   /* is the adjusted date an observed holiday */        
  select @v_holidaycode = coalesce(holiday_code, '') ,  @v_IsHolidayObs = case when holiday_code is not null then 'Y' else '' end,    
         @v_holidaygroup  = coalesce(holidays.holiday_group, '')    
  from Holidays, company    
  where  dateadd(dd,0, datediff(dd,0,@v_cmpOpens)) = case datepart(dw,holiday)         
     when 1 then dateadd(dd,isnull(cmp_SunObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 2 then dateadd(dd,isnull(cmp_MonObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 3 then dateadd(dd,isnull(cmp_TueObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 4 then dateadd(dd,isnull(cmp_WedObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 5 then dateadd(dd,isnull(cmp_ThuObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 6 then dateadd(dd,isnull(cmp_FriObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
     when 7 then dateadd(dd,isnull(cmp_SatObsHolFlag,0) + coalesce(cmp_FromHrDateAdj,0),holiday)        
   end       
   and company.cmp_id = @p_cmpid   
    and isnull(holidays.holiday_group,'UNK') = @v_cmpholidaygroup   
      
   If @v_holidaycode is null begin      
      select @v_holidaycode = '',@v_holidaygroup  = ''      
   end      
      
   if exists (select 1 from generalinfo where gi_name = 'SchedulerHolidayOptions' and isnull(gi_string1,'') = 'RULES' and isnull(gi_string2,'') = 'WorkHrsHoliday')        
   BEGIN  -- Holiday observance runs over work hours only        
        -- company closed on this date the stop has not fallen on an observed holiday        
      if @v_IsOpen = 'N' and @v_IsHolidayObs = 'Y'    
      begin        
          set @v_IsHolidayObs = 'N';        
          set @v_holidaycode = ''        
      end        
   END  -- Holiday observance runs over work hours only    
      
select @v_Workdate as work_date    
      ,@v_DayOfWeek as day_of_week      
      ,@v_IsOpen as is_open    
      ,@v_IsHolidayObs as is_holiday_obs    
      ,@v_holidaycode as holiday_code     
      ,@v_holidaygroup as holiday_group    
      ,@v_IsHolidayObsPriorDay as is_holiday_obs_prior_day    
      ,@v_holidaycodePriorDay as holiday_code_prior_day    
      ,@v_holidaygroupPriorDay  as holiday_group_prior_day     
      ,@v_IsHolidayObsNextDay as is_holiday_obs_next_day    
      ,@v_holidaycodeNextDay as holiday_code_next_day    
      ,@v_holidaygroupNextDay as holiday_group_next_day  
GO
GRANT EXECUTE ON  [dbo].[GetStopLocOpenInfo] TO [public]
GO
