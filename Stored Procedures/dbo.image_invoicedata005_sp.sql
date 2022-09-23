SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[image_invoicedata005_sp] (@pegcontrol int)  
As

/*  MODIFICATION LOG

Created PTS 17484 BLEVON
  4/08/03 	NEW invoicedata proc for EBE - Electronic Business Equipment

PTS 21348 (1/14/04) PAPERWISE Imaging Stored Proc
	This is a new version, based on 004, with 2 new fields,
	cmp_edi210, ivh_revtype1 -- requested by EL Hollingsworth and Paperwise (Travis)
	This proc replaces image_invoicedata003_sp in the Paperwise kit.

*/

SELECT  move_number = mov_number,
   billto = ivh_billto,
   billto_name = (select cmp_name from company co where co.cmp_id = ivh_billto),
   shipper = ivh_shipper,
   shipper_name = (select cmp_name from company co where co.cmp_id = ivh_shipper),
   consignee = ivh_consignee,
   consignee_name = (select cmp_name from company co where co.cmp_id = ivh_consignee),
   bol_number = (select max(ref_number) from referencenumber rn where rn.ref_tablekey = i.ord_hdrnumber and rn.ref_table = 'orderheader' and rn.ref_type in ('BOL', 'BL#')),
   po_number = (select max(ref_number) from referencenumber rn where rn.ref_tablekey = i.ord_hdrnumber and rn.ref_table = 'orderheader' and rn.ref_type = 'PO'),
   tractor = ivh_tractor,
   trailer = ivh_trailer,
   drivername = (select case mpp_id when 'UNKNOWN' then 'UNKNOWN' else mpp_firstname + ' ' + isnull(mpp_middlename, '') + ' ' + mpp_lastname end from manpowerprofile mp where mp.mpp_id = ivh_driver),
   invoicedate = ivh_billdate,
   shipdate = ivh_shipdate,
   cmp_edi210 = (select cmp_edi210 from company co where co.cmp_id = ivh_billto),
   ivh_revtype1
	 --,
--   invoicenumber = ivh_invoicenumber,
--   ordernumber = ord_number,
--   mbnumber = isnull(c.mb_number,'')
FROM pegasus_invoicelist c, invoiceheader i, company m
WHERE c.Peg_controlnumber = @pegcontrol 
   and i.ivh_hdrnumber = c.ivh_hdrnumber
   and m.cmp_id = i.ivh_billto

GO
GRANT EXECUTE ON  [dbo].[image_invoicedata005_sp] TO [public]
GO
