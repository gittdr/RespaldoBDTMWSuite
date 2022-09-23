SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetAssetsForInvoice]        
 @p_ordhdrnumber int ,@p_driver1 varchar(8) output,@p_driver2 varchaR(8) OUTPUT,@P_TRACTOR VARCHAR(8) OUTPUT,
 @p_trailer1 varchar(13) output,@p_trailer2 varchar(13) output,@p_carrier varchar(8) output 
    
AS   
/*   Proc to get the appropriate assets for an invoice based on GI settings  

**** see also proc GetAssetInforForInvoice when makign changes - does the same thing  with fewer arguments   ****
  
  REVISION HISTORY  
  
  called from d_inv_edit_hdr_sp
    
  12/31/09 PTS48966 DPETE developed for getting correct assets when retrieving an order for invoicing 
6/9/11 DPETE 57395 performance fix found by Mindy
    
  */  
    
Declare @v_billto varchar(8), @v_GI_InvoiceAssets varchar(30), @v_invoiceby varchar(6),@v_mov int,@v_consignee varchar(8)  
Declare @v_stpnumber int  
  
Declare @stops table (stp_number int null)  
declare @legmiles table (lgh_number int null,sumdist decimal(9,1) null,minstop int null )  
    
If exists (select 1 from invoiceheader where ord_hdrnumber = @p_ordhdrnumber)  
    select @v_billto = ivh_billto,@v_invoiceby = isnull(ivh_invoiceby,'ORD'), @v_mov = mov_number, @v_consignee = ivh_destpoint  
    from invoiceheader 
   where ord_hdrnumber =  @p_ordhdrnumber
    and ivh_hdrnumber = (select min ( ivh_hdrnumber) from invoiceheader where ord_hdrnumber = @p_ordhdrnumber )
else  
    select @v_billto = ord_billto,@v_invoiceby = isnull(cmp_invoiceby,'ORD'), @v_mov = mov_number,@v_consignee = ord_consignee  
    from orderheader join company on ord_billto = cmp_id  
    where ord_hdrnumber = @p_ordhdrnumber  
      
Select @v_GI_InvoiceAssets  = upper(gi_string1) from generalinfo where gi_name = 'InvoiceAssets'  
  
Select @v_GI_InvoiceAssets  =  isnull(@v_GI_InvoiceAssets,'DELIVERY')  
  
  
If @v_billto  is null RETURN  -- invalid order  
    
/* Handle special "invoiceby" options when selecting assets */  
If   @v_invoiceby = 'MOV'  
   Insert into @stops  
   Select stp_number  
   from orderheader  
   join stops on orderheader.ord_hdrnumber = stops.ord_hdrnumber  
   where orderheader.mov_number = @v_mov  
   and ord_billto = @v_billto  
if  @v_invoiceby = 'CON'  
   Insert into @stops  
   Select stp_number  
   from orderheader  
   join stops on orderheader.ord_hdrnumber = stops.ord_hdrnumber  
   where orderheader.mov_number = @v_mov  
   and ord_billto = @v_billto  
   and ord_consignee = @v_consignee  
If @v_invoiceby <> 'MOV' and @v_invoiceby <> 'CON'  
   Insert into @stops  
   Select stp_number  
   from stops   
   where ord_hdrnumber = @p_ordhdrnumber  
   and ord_hdrnumber > 0  
         
  
/* GI setting dicatates which leg to get the assets from */  
  
   If @v_GI_InvoiceAssets = 'DELIVERY'   
     BEGIN  -- get assets for delivery leg  
   
       select @v_stpnumber =  (select top 1 stops.stp_number  
          from @stops st  
          join stops on st.stp_number = stops.stp_number  
          where stops.stp_type = 'DRP'  
          order by stops.stp_sequence ,stops.stp_arrivaldate desc)  
     
       select
        @p_driver1 = evt_driver1,  
        @p_driver2 = evt_driver2,  
        @p_tractor = evt_tractor,  
        @p_trailer1 = evt_trailer1,  
        @p_trailer2 = evt_trailer2,  
        @p_carrier = evt_carrier
        from event  
        where event.stp_number = @v_stpnumber  
        and evt_sequence = 1  
              
      END   -- get assets for delivery leg  
        
    If @v_GI_InvoiceAssets = 'MOSTMILES'   
      BEGIN  -- get assets for leg with most miles (use trip miles to get total segment lenght) 
        insert into @legmiles (lgh_number,sumdist,minstop)  
        select lgh_number,sum(isnull(stp_lgh_mileage,0)),min(stops.stp_number)  
        from @stops st  
         join stops on st.stp_number = stops.stp_number  
        group by lgh_number  
        order by sum(isnull(stp_lgh_mileage,0)) desc  
                       
        select @v_stpnumber = (select top 1 minstop   
        from @legmiles)  
                              
        select 
        @p_driver1 = evt_driver1,  
        @p_driver2 = evt_driver2,  
        @p_tractor = evt_tractor,  
        @p_trailer1 = evt_trailer1,  
        @p_trailer2 = evt_trailer2,  
        @p_carrier = evt_carrier
        from event  
        where event.stp_number = @v_stpnumber  
        and evt_sequence = 1  
              
      END   -- get assets for most miles leg  
            
     /* **** DEFAULT - MAKE LAST *****   default is pickup leg */  
    If @v_GI_InvoiceAssets <> 'DELIVERY' and @v_GI_InvoiceAssets <> 'MOSTMILES'  
      BEGIN  -- get assets for pickup leg  
        select @v_stpnumber =  (select top 1 stops.stp_number  
             from @stops st  
             join stops on st.stp_number = stops.stp_number   
             where stp_type = 'PUP'  
             order by stp_mfh_sequence)  
                   
        select 
        @p_driver1 = evt_driver1,  
        @p_driver2 = evt_driver2,  
        @p_tractor = evt_tractor,  
        @p_trailer1 = evt_trailer1,  
        @p_trailer2 = evt_trailer2,  
        @p_carrier = evt_carrier
        from event  
        where event.stp_number = @v_stpnumber  
        and evt_sequence = 1  
              
      END   -- get assets for pickup leg  
  
GO
GRANT EXECUTE ON  [dbo].[GetAssetsForInvoice] TO [public]
GO
