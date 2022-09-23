SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[image_invoicedata004_sp] (@pegcontrol int)  
As

/*  MODIFICATION LOG

Created PTS 17484 BLEVON
  4/08/03 	NEW invoicedata proc for EBE - Electronic Business Equipment

 DPETE PTS 25769 order by the new idenetiy col so that records are returned
    in the sequence in which they appear on the document if gi ImageSupportDocSeq = MB
*/

Declare @docsequence varchar(50)

/* determine the sequence in which records are to be returned */

Select @docsequence = UPPER(gi_string1) From generalinfo Where gi_name = 'ImageSupportDocSeq'
Select @docsequence = IsNull(@docsequence,'INV') 

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
   shipdate = ivh_shipdate --,
--   invoicenumber = ivh_invoicenumber,
--   ordernumber = ord_number,
--   mbnumber = isnull(c.mb_number,'')
FROM pegasus_invoicelist c, invoiceheader i, company m
WHERE c.Peg_controlnumber = @pegcontrol 
   and i.ivh_hdrnumber = c.ivh_hdrnumber
   and m.cmp_id = i.ivh_billto
Order by Case @DocSequence When 'MB' Then peg_identity else 1 End,ivh_invoicenumber

GO
GRANT EXECUTE ON  [dbo].[image_invoicedata004_sp] TO [public]
GO
