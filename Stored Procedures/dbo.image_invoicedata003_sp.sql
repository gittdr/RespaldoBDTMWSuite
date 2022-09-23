SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[image_invoicedata003_sp] (@pegcontrol int)  
As
/*  MODIFICATION LOG

Created PTS 14952 DPETE
  8/22/02 Dave Lair decides to use Other type 2 field instead of new supporting docs table.  Set up so it can be overridden
         but cmp_othertype2 is the default

DPETE 15873 return mb number from pegasus_invoiclist table
 DPETE PTS 25769 order by the new idenetiy col so that records are returned
    in the sequence in which they appear on the document if gi ImageSupportDocSeq = MB
*/
Declare @docfieldname varchar(30),
 @docsequence varchar(50)

/* determine the sequence in which records are to be returned */

Select @docsequence = UPPER(gi_string1) From generalinfo Where gi_name = 'ImageSupportDocSeq'
Select @docsequence = IsNull(@docsequence,'INV') 


Select @docfieldname = IsNull(gi_string1,'cmp_orthertype2')
From generalinfo
Where gi_name = 'DocTypeField'

Select @docfieldname = IsNull(@docfieldname,'cmp_othertype2')

Select invoicenumber = ivh_invoicenumber,ordernumber = ord_number,mbnumber = isnull(c.mb_number,''),billto = ivh_billto,shipper = ivh_shipper,consignee = ivh_consignee,
billdate= ivh_billdate,driver = ivh_driver,tractor = ivh_tractor,deliverydate=ivh_deliverydate,refnumber = IsNull(ivh_ref_number,''),
Supportdocs = Case @docfieldname When 'cmp_othertype1' Then (Case cmp_othertype1 When 'UNK' then '' Else Isnull(cmp_othertype1,'') End) When 'cmp_othertype2' then (Case cmp_othertype2 When 'UNK' Then '' Else IsNull(cmp_othertype2,'') End )
When 'cmp_misc1' then IsNull(cmp_misc1,'') When 'cmp_misc2' Then IsNull(cmp_misc2,'') When 'cmp_misc3' Then IsNull(cmp_misc3,'') When 'cmp_misc4' then IsNull(cmp_misc4,'') Else (Case cmp_othertype2 When 'UNK' Then '' Else IsNull(cmp_othertype2,'') End) End
From pegasus_invoicelist c, invoiceheader i, company m
where c.Peg_controlnumber = @pegcontrol 
and i.ivh_hdrnumber = c.ivh_hdrnumber
and m.cmp_id = i.ivh_billto
Order by Case @DocSequence When 'MB' Then peg_identity else 1 End,ivh_invoicenumber


GO
GRANT EXECUTE ON  [dbo].[image_invoicedata003_sp] TO [public]
GO
