SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*
Created for TMI on PTS 15477
Example call 
exec TMI_imagingrecord_401 @ivhhdrnumber =5401

These records are to be created when the invoice is printed and every time any of the info on the record changes.
select * from invoicedetail

*/
Create Procedure [dbo].[TMI_imagingrecord_401]  @ivhhdrnumber int
As
--DTS when sql returns messages due to inserts
SET NOCOUNT ON

Declare @invoicenumber char(15)
Select @invoicenumber=ivh_invoicenumber
From invoiceheader where ivh_Hdrnumber = @ivhhdrnumber

Select '40102'
+  @invoicenumber
+ Convert(Char(22),IsNull(ivd_sequence,0))
+ Convert(Char(22),IsNull(ivd_count,0))
+ Case IsNull(ivd_description,'UNKNOWN') When 'UNKNOWN' Then Convert(Char(80),IsNull(cht_description,' ')) Else Convert(Char(80),IsNull(ivd_description,' ')) End
+ Convert( char(3),Substring(IsNull(ivd_unit,' '),1,3))
+ Convert(char(22),IsNull(ivd_Quantity,0))
+ Convert(Char(22),IsNull(ivd_rate,0.00))
+ Convert(Char(22),IsNull(ivd_Charge,0.00))
+ Convert(char(22),ivh_hdrnumber)
+ Case IsNull(tar_number,0) When 0 Then replicate (' ',10) Else Convert(Char(10),tar_number) End
From invoicedetail d, chargetype c
Where d.ivh_hdrnumber = @ivhhdrnumber
And c.cht_itemcode = d.cht_itemcode
--And ivd_charge <> 0
order by ivd_sequence



GO
GRANT EXECUTE ON  [dbo].[TMI_imagingrecord_401] TO [public]
GO
