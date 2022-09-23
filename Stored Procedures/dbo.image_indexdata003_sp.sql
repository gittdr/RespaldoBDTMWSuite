SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[image_indexdata003_sp] (@ordnumber varchar(12))    
As  
/*  MODIFICATION LOG (for Paperwise) used to provide index information given an order  
  
Created PTS 14952 DPETE  
  08/22/02 Per Dave Lair add ivh_ref_number  
  
  
*/  
  
If exists(Select * from invoiceheader where ord_number = @ordnumber)  
   
 Select ordernumber=ord_number,invoicestatus = 'PPD',billto = ivh_billto,shipper = ivh_shipper,consignee = ivh_consignee,  
   billdate = ivh_billdate, driver = ivh_driver,tractor = ivh_tractor,deliverydate = ivh_deliverydate, refnumber = IsNull(ivh_ref_number,'')  
 From invoiceheader where ivh_hdrnumber = ( Select MIN(ivh_hdrnumber) from invoiceheader   
   Where ord_number = @ordnumber)   
   
Else  
  
 Select ordernumber=ord_number,invoicestatus = ord_invoicestatus,billto = ord_billto,shipper = ord_shipper,consignee = ord_consignee,billdate = NULL,  
 driver = ord_driver1,tractor = ord_tractor,deliverydate = ord_completiondate, refnumber = IsNull(ord_refnum,'')  
 From orderheader   
 Where ord_number = @ordnumber  
  
  


GO
GRANT EXECUTE ON  [dbo].[image_indexdata003_sp] TO [public]
GO
