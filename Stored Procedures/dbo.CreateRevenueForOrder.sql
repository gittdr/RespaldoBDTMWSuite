SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[CreateRevenueForOrder] (@p_ordhdrnumber INTEGER,@p_AddOrBackout varchar(10),@p_foruser varchar(255),@p_source varchar(50)
  ,@p_DeletingInvoice char(1) = 'N' )
AS


/* function to add records for all revenue for an order (charges on orderheader, freight and invoicedetails)
   Flag @p_addorBackout = ADD or BACKOUT dictates if the amounts will be as on the order (ADD) or reversed (BACKOUT)

optional argument is passed when delting an invoice,  do not backout invoice detail charges if deleting an invoice,
  the dt_invoiceheader deltes the records and the dt_invoicedetial creates the backouts needed

Created 6/4/10 DPETE PTS51844
6/28/10 DPETE 51844 modified for dot net order entry
9/9/10 DPETE add more info to comment up rev tracker
01/18/11 DPETE PTS55393 add mileage to revenue_tracker (for invoice only)
07/18/11 DPETE 57990 Occasionally getting error , Line 44 String or binary data would be truncated".
*/
declare @v_now datetime, @v_AddOrBackoutFactor int, @v_rateby char(1),@v_ordstatus varchar(6),@v_ordcurrency varchar(6)
declare @v_appid varchar(30) , @v_recordzerochanges char(1)
-- check to see if feature is on

If  exists (select 1 from generalinfo where gi_name = 'TrackRevenue' and gi_string1 = '100')
 BEGIN
 /* option to record adds and backouts of zero dollars - used for debug */
   Select @v_recordzerochanges = gi_string2 from generalinfo where gi_name = 'TrackRevenue'
   Select @v_recordzerochanges = isnull(@v_recordzerochanges,'N')
   
   Select @v_now = getdate()
   select @p_foruser = rtrim(substring(@p_foruser,1,50))
   select @v_appid = rtrim(left(app_name(),30))
   If left(@p_AddOrBackout,1) = 'A' 
      Select @v_AddOrBackoutFactor  = 1
   else
      Select @v_AddOrBackoutFactor  = -1
   Select @v_rateby = ord_rateby,@v_ordstatus = ord_status, @v_ordcurrency = ord_currency  from orderheader where ord_hdrnumber = @p_ordhdrnumber

   If @v_rateby = 'T' 
     BEGIN
     -- If Order is rate by total and has a charge create a record in the revenue_tracking table
       If exists (select 1 from orderheader where ord_hdrnumber = @p_ordhdrnumber and ord_rateby = 'T' and (ord_charge <> 0 or @v_recordzerochanges = 'Y'))

         BEGIN
           Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number,cur_code,rvt_isbackout,ord_status
             ,ivh_invoicestatus,rvt_updatedby,rvt_updatesource,rvt_appname,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles,rvt_billemptymiles)
           select @p_ordhdrnumber
           ,0
           ,'PRERATE'
           ,@v_now
           ,cht_itemcode
           ,(ord_charge * @v_AddOrBackoutFactor) 
           ,isnull(tar_number,0)
           ,@v_ordcurrency
           ,case @v_AddOrBackoutFactor when 1 then 'N' else 'Y' end
           ,'???'
           ,'???'
           ,@p_foruser
           ,substring(@p_source + '(call CRV from ord_charge)',1,100) 
           ,substring(@v_appid,1,100)
           ,ord_quantity
           ,0
           ,ord_rateby
           ,0.0
           ,0.0
           from orderheader 
           where ord_hdrnumber = @p_ordhdrnumber

         END
     END
   Else

     -- If rate by detail insert records for charges on the freight records that are not zero
     If exists (select 1 from stops s join freightdetail f on s.stp_number = f.stp_number where s.ord_hdrnumber = @p_ordhdrnumber 
        and stp_type = 'DRP' and (fgt_charge <> 0 or @v_recordzerochanges = 'Y') )
       BEGIN
         Select @v_rateby = ord_rateby from orderheader where ord_hdrnumber = @p_ordhdrnumber
         Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number,cur_code,rvt_isbackout,ord_status
         ,ivh_invoicestatus,rvt_updatedby,rvt_updatesource,rvt_appname,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles,rvt_billemptymiles)
           select @p_ordhdrnumber
           ,0
           ,'PRERATE'
           ,@v_now
           ,cht_itemcode
           ,(fgt_charge * @v_AddOrBackoutFactor) 
           ,isnull(tar_number,0)
           ,@v_ordcurrency
           ,case @v_AddOrBackoutFactor when 1 then 'N' else 'Y' end
           ,'???'
           ,'???'
           ,@p_foruser
           ,substring(@p_source + '(call CRV from fgt charge)' ,1,100)
           ,substring(@v_appid,1,100)
           ,fgt_quantity
           ,0
           ,@v_rateby 
           ,0.0
           ,0.0
           from stops s join freightdetail f on s.stp_number = f.stp_number
           where ord_hdrnumber = @p_ordhdrnumber
           and stp_type = 'DRP'
           and ( fgt_charge <> 0 or @v_recordzerochanges = 'Y')
       END

   -- finally add records for each of the invoice detail records 
   If exists (select 1 from invoicedetail where ord_hdrnumber = @p_ordhdrnumber and ivh_hdrnumber = 0) 
      and @p_deletinginvoice = 'N' 
     BEGIN
       Select @v_rateby = ord_rateby from orderheader where ord_hdrnumber = @p_ordhdrnumber  
       Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number,cur_code,rvt_isbackout,ord_status
       ,ivh_invoicestatus,rvt_updatedby,rvt_updatesource,rvt_appname,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles,rvt_billemptymiles)
       select @p_ordhdrnumber
       ,0
       ,'PRERATE'
       ,@v_now
       ,cht_itemcode
       ,(ivd_charge * @v_AddOrBackoutFactor)
       ,isnull(tar_number,0)   
       ,@v_ordcurrency
       ,case @v_AddOrBackoutFactor when 1 then 'N' else 'Y' end
       ,'???'
       ,'???'
       ,@p_foruser
       ,substring(@p_source + '(call CRV)',1,100)
       ,substring(@v_appid,1,100)
       ,ivd_quantity
       ,ivd_number
       ,@v_rateby
       ,0.0
       ,0.0  
       from invoicedetail
       where ord_hdrnumber = @p_ordhdrnumber
       and ivh_hdrnumber = 0
       and ivd_type <> 'SUB' -- dot net adds SUB in pre rate for rate by total
       and isnull(fgt_number,0) = 0  -- dot net may add details for fgt in prerate by detail 
    END
END
GO
GRANT EXECUTE ON  [dbo].[CreateRevenueForOrder] TO [public]
GO
