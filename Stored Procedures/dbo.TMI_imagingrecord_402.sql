SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*
Created for TMI on PTS 15477
Example call 
exec TMI_imagingrecord_402 @ivhhdrnumber =5401

These records are to be created when the invoice is printed and every time any of the info on the record changes.
select * from invoicedetail

*/
Create Procedure [dbo].[TMI_imagingrecord_402]  @ivhhdrnumber int
As
--DTS when sql returns messages due to inserts
SET NOCOUNT ON

Declare @invoicenumber char(15)
Select @invoicenumber=ivh_invoicenumber
From invoiceheader where ivh_Hdrnumber = @ivhhdrnumber

Select '40102'
+  @invoicenumber
+  Convert(char(22),IsNull(ivd_sequence,0))
+  Convert(char(10),IsNull(cmp_id,'UNKNOWN'))
+  Convert(Char(22),@ivhhdrnumber)
From invoicedetail d
Where d.ivh_hdrnumber = @ivhhdrnumber
And IsNull(stp_number,0) > 0
order by ivd_sequence



GO
GRANT EXECUTE ON  [dbo].[TMI_imagingrecord_402] TO [public]
GO
