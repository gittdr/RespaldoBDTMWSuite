SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetStopLocOpenDays]      
 @p_cmpid varchar(8),@p_Stopdate datetime,  @p_openDate datetime output, @p_closeDate datetime output,  
                                            @p_openPriorDate datetime output, @p_closePriorDate datetime output,  
                                            @p_openNextDate datetime output, @p_closeNextDate datetime output  
  
AS      
/**      
 *       
 * NAME:      
 * dbo.GetStopLocOpenInfoDays  
 *      
 * TYPE:      
 * StoredProcedure      
 *      
 * DESCRIPTION:      
 * Pass an stop companyID and tstop date,It will return the open and close date times for this date and
 * for the prior and next days as well
 *      
 *            
 * RETURNS:      
 * no return code      
 *      
 * RESULT SETS:       
 *  NONE      
 *      
 * PARAMETERS:      
 * 001 -  @p_cmpid varchar(8)      
 * 002 - @p_Stopdate datetime      
 * 003 - @p_openDate datetime output, 
 * 004 - @p_closeDate datetime output,  
 * 005 - @p_openPriorDate datetime output
 * 006 - @p_closePriorDate datetime output,  
 * 007 - -@p_openNextDate datetime output
 * 008 -  @p_closeNextDate datetime output  
 *      
 * REFERENCES:      
 *       
 * REVISION HISTORY:      
 * 3/20/07 DPETE/JPISK PTS35732- Created stored proc for SR requireing all  trips to be adjusted for the time zone.      
      
 *      
 **/      
declare @v_DayOfWeek smallint    
declare @v_dateOnly DateTime;      
      
   set @v_dateOnly = dateadd(dd,0, datediff(dd,0,@p_StopDate))      
   set @v_DayOfWeek = datepart(dw,@p_StopDate)      
   /* ================ DETERMIN THE WORK DAY FROM AND TO TIMES IN DateTime FROM THE STOP DATE ====== */      
   /*  */      
   select @p_openDate = case @v_DayOfWeek      
      when 1 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) , @v_dateOnly + dateadd(mi,((isnull(cmp_opens_su,0)/ 100) * 60) + (isnull(cmp_opens_su,0) % 100),0))      
      when 2 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) , @v_dateOnly + dateadd(mi,((isnull(cmp_opens_mo,0)/ 100) * 60) + (isnull(cmp_opens_mo,0) % 100),0))      
      when 3 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) , @v_dateOnly + dateadd(mi,((isnull(cmp_opens_tu,0)/ 100) * 60) + (isnull(cmp_opens_tu,0) % 100),0))      
      when 4 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) , @v_dateOnly + dateadd(mi,((isnull(cmp_opens_we,0)/ 100) * 60) + (isnull(cmp_opens_we,0) % 100),0))      
      when 5 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) , @v_dateOnly + dateadd(mi,((isnull(cmp_opens_th,0)/ 100) * 60) + (isnull(cmp_opens_th,0) % 100),0))      
      when 6 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) , @v_dateOnly + dateadd(mi,((isnull(cmp_opens_fr,0)/ 100) * 60) + (isnull(cmp_opens_fr,0) % 100),0))      
      when 7 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) , @v_dateOnly + dateadd(mi,((isnull(cmp_opens_sa,0)/ 100) * 60) + (isnull(cmp_opens_sa,0) % 100),0))      
      else null end,      
      @p_closeDate = case @v_DayOfWeek      
      when 1 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_su > cmp_closes_su then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_su,0)/ 100) * 60) + (isnull(cmp_closes_su,0) % 100),0))      
      when 2 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_mo > cmp_closes_mo then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_mo,0)/ 100) * 60) + (isnull(cmp_closes_mo,0) % 100),0))      
      when 3 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_tu > cmp_closes_tu then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_tu,0)/ 100) * 60) + (isnull(cmp_closes_tu,0) % 100),0))      
      when 4 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_we > cmp_closes_we then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_we,0)/ 100) * 60) + (isnull(cmp_closes_we,0) % 100),0))      
      when 5 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_th > cmp_closes_th then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_th,0)/ 100) * 60) + (isnull(cmp_closes_th,0) % 100),0))      
      when 6 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_fr > cmp_closes_fr then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_fr,0)/ 100) * 60) + (isnull(cmp_closes_fr,0) % 100),0))      
      when 7 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_sa > cmp_closes_sa then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_sa,0)/ 100) * 60) + (isnull(cmp_closes_sa,0) % 100),0))      
      else null end,      
      @p_openPriorDate = case @v_DayOfWeek      
      when 2 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_su,0)/ 100) * 60) + (isnull(cmp_opens_su,0) % 100),0))      
      when 3 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_mo,0)/ 100) * 60) + (isnull(cmp_opens_mo,0) % 100),0))      
      when 4 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_tu,0)/ 100) * 60) + (isnull(cmp_opens_tu,0) % 100),0))      
      when 5 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_we,0)/ 100) * 60) + (isnull(cmp_opens_we,0) % 100),0))      
      when 6 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_th,0)/ 100) * 60) + (isnull(cmp_opens_th,0) % 100),0))      
      when 7 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_fr,0)/ 100) * 60) + (isnull(cmp_opens_fr,0) % 100),0))      
      when 1 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_sa,0)/ 100) * 60) + (isnull(cmp_opens_sa,0) % 100),0))      
      else null end,      
      @p_closePriorDate = case @v_DayOfWeek      
      when 2 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1 + case when cmp_opens_su > cmp_closes_su then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_su,0)/ 100) * 60) + (isnull(cmp_closes_su,0) % 100),0))      
      when 3 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1 + case when cmp_opens_mo > cmp_closes_mo then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_mo,0)/ 100) * 60) + (isnull(cmp_closes_mo,0) % 100),0))      
      when 4 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1 + case when cmp_opens_tu > cmp_closes_tu then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_tu,0)/ 100) * 60) + (isnull(cmp_closes_tu,0) % 100),0))      
      when 5 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1 + case when cmp_opens_we > cmp_closes_we then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_we,0)/ 100) * 60) + (isnull(cmp_closes_we,0) % 100),0))      
      when 6 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1 + case when cmp_opens_th > cmp_closes_th then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_th,0)/ 100) * 60) + (isnull(cmp_closes_th,0) % 100),0))      
      when 7 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1 + case when cmp_opens_fr > cmp_closes_fr then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_fr,0)/ 100) * 60) + (isnull(cmp_closes_fr,0) % 100),0))      
      when 1 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) - 1 + case when cmp_opens_sa > cmp_closes_sa then 1 else 0 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_sa,0)/ 100) * 60) + (isnull(cmp_closes_sa,0) % 100),0))      
      else null end,      
      @p_openNextDate = case @v_DayOfWeek      
      when 7 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_su,0)/ 100) * 60) + (isnull(cmp_opens_su,0) % 100),0))      
      when 1 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_mo,0)/ 100) * 60) + (isnull(cmp_opens_mo,0) % 100),0))      
      when 2 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_tu,0)/ 100) * 60) + (isnull(cmp_opens_tu,0) % 100),0))      
      when 3 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_we,0)/ 100) * 60) + (isnull(cmp_opens_we,0) % 100),0))      
      when 4 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_th,0)/ 100) * 60) + (isnull(cmp_opens_th,0) % 100),0))      
      when 5 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_fr,0)/ 100) * 60) + (isnull(cmp_opens_fr,0) % 100),0))      
      when 6 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + 1, @v_dateOnly + dateadd(mi,((isnull(cmp_opens_sa,0)/ 100) * 60) + (isnull(cmp_opens_sa,0) % 100),0))      
      else null end,      
      @p_closeNextDate = case @v_DayOfWeek      
      when 7 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_su > cmp_closes_su then 2 else 1 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_su,0)/ 100) * 60) + (isnull(cmp_closes_su,0) % 100),0))      
      when 1 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_mo > cmp_closes_mo then 2 else 1 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_mo,0)/ 100) * 60) + (isnull(cmp_closes_mo,0) % 100),0))      
      when 2 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_tu > cmp_closes_tu then 2 else 1 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_tu,0)/ 100) * 60) + (isnull(cmp_closes_tu,0) % 100),0))      
      when 3 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_we > cmp_closes_we then 2 else 1 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_we,0)/ 100) * 60) + (isnull(cmp_closes_we,0) % 100),0))      
      when 4 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_th > cmp_closes_th then 2 else 1 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_th,0)/ 100) * 60) + (isnull(cmp_closes_th,0) % 100),0))      
      when 5 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_fr > cmp_closes_fr then 2 else 1 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_fr,0)/ 100) * 60) + (isnull(cmp_closes_fr,0) % 100),0))      
      when 6 then dateadd(dd, isnull(cmp_FromHrDateAdj,0) + case when cmp_opens_sa > cmp_closes_sa then 2 else 1 end, @v_dateOnly + dateadd(mi,((isnull(cmp_closes_sa,0)/ 100) * 60) + (isnull(cmp_closes_sa,0) % 100),0))      
      else null end  
      from company where cmp_id = @p_cmpid  
         
GO
GRANT EXECUTE ON  [dbo].[GetStopLocOpenDays] TO [public]
GO
