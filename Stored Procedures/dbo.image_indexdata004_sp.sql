SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[image_indexdata004_sp] (@ordnumber varchar(12))    
As  

/*  MODIFICATION LOG (for Paperwise) used to provide index information given an order  
  
Created PTS 17484 BLEVON  
  04/08/03	NEW indexdata proc for EBE - Electronic Business Equipment
  
  
*/  
  
If exists(Select * from invoiceheader where ord_number = @ordnumber)  
   
 SELECT move_number = mov_number,
   billto = ivh_billto,
   billto_name = (select cmp_name from company co where co.cmp_id = ivh_billto),
   shipper = ivh_shipper,
   shipper_name = (select cmp_name from company co where co.cmp_id = ivh_shipper),
   consignee = ivh_consignee,
   consignee_name = (select cmp_name from company co where co.cmp_id = ivh_consignee),
   bol_number = (select max(ref_number) from referencenumber rn where rn.ref_tablekey = ih.ord_hdrnumber and rn.ref_table = 'orderheader' and rn.ref_type in ('BOL', 'BL#')),
   po_number = (select max(ref_number) from referencenumber rn where rn.ref_tablekey = ih.ord_hdrnumber and rn.ref_table = 'orderheader' and rn.ref_type = 'PO'),
   tractor = ivh_tractor,
   trailer = ivh_trailer,
   drivername = (select case mpp_id when 'UNKNOWN' then 'UNKNOWN' else mpp_firstname + ' ' + isnull(mpp_middlename, '') + ' ' + mpp_lastname end from manpowerprofile mp where mp.mpp_id = ivh_driver),
   invoicedate= ivh_billdate,
   shipdate= ivh_shipdate,
   invoicestatus = 'PPD' --,
--   invoicenumber = ivh_invoicenumber,
--   ordernumber = ord_number,
--   mbnumber = isnull(c.mb_number,'')
 FROM invoiceheader ih
 WHERE ivh_hdrnumber = ( Select MIN(ivh_hdrnumber) from invoiceheader WHERE ord_number = @ordnumber)   
   
Else  
  if exists(Select * from orderheader where ord_number = @ordnumber)

    SELECT move_number = mov_number,
      billto = ord_billto,
      billto_name = (select cmp_name from company co where co.cmp_id = ord_billto),
      shipper = ord_shipper,
      shipper_name = (select cmp_name from company co where co.cmp_id = ord_shipper),
      consignee = ord_consignee,
      consignee_name = (select cmp_name from company co where co.cmp_id = ord_consignee),
      bol_number = (select max(ref_number) from referencenumber rn where rn.ref_tablekey = oh.ord_hdrnumber and rn.ref_table = 'orderheader' and rn.ref_type in ('BOL', 'BL#')),
      po_number = (select max(ref_number) from referencenumber rn where rn.ref_tablekey = oh.ord_hdrnumber and rn.ref_table = 'orderheader' and rn.ref_type = 'PO'),
      tractor = ord_tractor,
      trailer = ord_trailer,
      drivername = (select case mpp_id when 'UNKNOWN' then 'UNKNOWN' else mpp_firstname + ' ' + isnull(mpp_middlename, '') + ' ' + mpp_lastname end from manpowerprofile mp where mp.mpp_id = ord_driver1),
      invoicedate = NULL,
      shipdate = ord_startdate,
      invoicestatus = ord_invoicestatus --,
   --??--   invoicenumber = ivh_invoicenumber,
   --   ordernumber = ord_number,
   --??--   mbnumber = isnull(c.mb_number,'')
    FROM orderheader oh  
    WHERE ord_number = @ordnumber 
 
  else

    -- Return a result of NULLs when a 'bad' @ordnumber is given
    SELECT NULL move_number,
      NULL billto,
      NULL billto_name,
      NULL shipper,
      NULL shipper_name,
      NULL consignee,
      NULL consignee_name,
      NULL bol_number,
      NULL po_number,
      NULL tractor,
      NULL trailer,
      NULL drivername,
      NULL invoicedate,
      NULL shipdate,
      NULL invoicestatus --,
   --??--   invoicenumber = ivh_invoicenumber,
   --   ordernumber = ord_number,
   --??--   mbnumber = isnull(c.mb_number,'')
    FROM orderheader   
    WHERE 0 = 1  

GO
GRANT EXECUTE ON  [dbo].[image_indexdata004_sp] TO [public]
GO
