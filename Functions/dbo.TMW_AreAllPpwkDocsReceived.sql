SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TMW_AreAllPpwkDocsReceived] 
  (@p_type varchar(3), @p_key int)  
RETURNS Char(1)  
AS  
  
/**  
 *   
 * NAME:  
 * dbo.AllPpwkDocsReceived_fn  
 *  
 * TYPE:  
 * function  
 *  
 * DESCRIPTION:  
 * Returns 'Y' if paperwork requiremetns are met, 'N' if there are outstanding requirements  
 *  
 * RETURNS:  
 * 'Y' or 'N'  
 *  
 * RESULT SETS:   
 * na  
 *  
 * PARAMETERS:  
 * 001 - @p_type pass 'INV' if we are to check by invoice (use in invoicing) or ORD to check for an order
 * 002 - @p_key ivh_hdrnumber or ord_hdrnumber depending on type 
   
 *  
 * REVISION HISTORY:  
 * 05/25/10 DPETE   
 *  
  
 */  
 BEGIN  
    
 declare @return char(1),@v_ivhhdrnumber int  
 Declare @v_ordhdrnumber int, @v_GIPaperWOrkCheckLevel varchar(10), @v_legFactor int, @v_billto varchar(8)  
 Declare @v_GIPaperworkMarkedYes varchar(10)  
 declare @legcountfactor int  
 declare @docsrequired table (docID varchar(6), neededcount int, rcvdcount int)  
 declare @docsreceived table (docID varchar(6), rcvdcount int)  

 If left(@p_type,3)  = 'INV' 
   BEGIN  
     select @v_ivhhdrnumber = @p_key 
     select @v_ordhdrnumber = ord_hdrnumber, @v_billto = ivh_billto  from invoiceheader where ivh_hdrnumber = @v_ivhhdrnumber  
   END
 else
   BEGIN 
     select @v_ordhdrnumber = @p_key
     select @v_ivhhdrnumber = min(ivh_hdrnumber) from invoiceheader where ord_hdrnumber = @v_ordhdrnumber
     if @v_ivhhdrnumber is not null
        select @v_billto = ivh_billto  from invoiceheader where ivh_hdrnumber = @v_ivhhdrnumber
     else
        select @v_billto = ord_billto from orderheader where ord_hdrnumber = @v_ordhdrnumber
  END  

 --##If @v_ordhdrnumber is null or @v_ordhdrnumber = 0 Return 'Y'  -- no doc requiremetns for a misc invoice  
  
 select @v_GIPaperWorkCheckLevel = dbo.TMW_GetGIStringSetting ('PaperworkCheckLevel','1')  
  
 select @v_GIPaperworkMarkedYes = dbo.TMW_GetGIStringSetting  ('PaperworkMarkedYes','1')  -- ALL or ONE  
   
   
 /* legfactor is 1 if no doing ppwk by leg and a number if doing paperwork by leg */  
 If @v_GIPaperWorkCheckLevel = 'LEG'  
 /* assumes we are interested only in legs with pup or DRP events at this time*/  
   select @legcountfactor = dbo.TMW_GetLegCountForOrder(@v_ordhdrnumber,'N') -- assume we are not interested in relay legs  
 else  
   select @legcountfactor = 1  
   /* get a table of doc types required, for non charge type paperwork the required count is always one, ignore legs  
      for bill to compnay required docs the required coutn might be extended by the leg count if GI CheckLevel = LEG */  
  /* docs associated with legs , the count is the factor for the leg count ot one depending on the GI PaperworkCheckLevel */      
  insert into @docsrequired --select * from v_paperwork_required where cmp_id = 'det1'  
  select doc_type, @legcountfactor,0  
  from v_paperwork_required  
  where cmp_id = @v_billto  
  and charge_code = '[ALL]'  
  and application_code in ('I','B')  
  
  /* docs associated with a charge type */  
  insert into @docsrequired  
  select distinct(doc_type),1,0  
  from v_paperwork_required  
  where cmp_id = @v_billto  
  and application_code in ('B','I')  
  and charindex(charge_code,'^' + dbo.TMW_InvoiceChargetypes(@v_ivhhdrnumber)) > 0  
  
 /* now I have a list of all the doc types required with a count of how many are required  
    next is to count how many I have of each type */  
      
  Insert into @docsreceived  
  select abbr,count(*)  
  from paperwork with (nolock)  
  where ord_hdrnumber = @v_ordhdrnumber  
  and pw_received = 'Y'  
  group by abbr  
--select '##z',* from   @docsreceived  
  /* match the required docs with the received */  
  update req  
  set rcvdcount = rcv.rcvdcount  
  from @docsrequired  req
  join @docsreceived rcv on req.docid = rcv.docid  
--select '##FINAL',* from   @docsrequired    
if @v_GIPaperworkMarkedYes  = 'ONE'  
   BEGIN  
     if exists(select 1 from @docsrequired where rcvdcount = 0)  
        select @return  = 'N'  
     else  
        select @return = 'Y'  
   END  
else  
   BEGIN  
     if exists(select 1 from @docsrequired where rcvdcount < neededcount)  
        select @return  = 'N'  
     else  
        select @return = 'Y'  
   END  
       
 
   
 return @return  
  
END  
GO
GRANT EXECUTE ON  [dbo].[TMW_AreAllPpwkDocsReceived] TO [public]
GO
