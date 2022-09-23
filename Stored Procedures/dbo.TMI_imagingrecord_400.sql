SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*
Created for TMI on PTS 15477
Example call 
exec TMI_imagingrecord_400 @ivhhdrnumber =556

select ivh_hdrnumber from invoiceheader where ivh_mbnumber > 0

select ivh_hdrnumber from invoiceheader where ord_hdrnumber = 67340

These records are to be created when the invoice is created and every time any of the info on the record changes.


*/
Create Procedure [dbo].[TMI_imagingrecord_400]  @ivhhdrnumber int
As
--DTS when sql returns messages due to inserts
SET NOCOUNT ON

Declare @bol char(20), @po char(20),@trailer2 char(25),@commodity char(10),@ordhdrnumber int

Select @ordhdrnumber = ord_hdrnumber From invoiceheader where ivh_hdrnumber = @ivhhdrnumber
Select @bol = Min(ref_number) From referencenumber where ref_table = 'orderheader'  and ref_tablekey = @ordhdrnumber and
ref_type = 'BL#'  --,'BOL')
If @bol is null
  Select @bol = ref_number From referencenumber where ref_table = 'orderheader' and ref_tablekey = @ordhdrnumber and
	ref_type ='BOL' 
Select @bol = IsNull(@bol,replicate(' ',20))
Select @po = ref_number From referencenumber where ref_table = 'orderheader' and ref_tablekey = @ordhdrnumber and
ref_type in ('PO') 
Select @po = IsNull(@po,replicate(' ',20))
Select @trailer2 = evt_trailer2 From event Where stp_number = (Select stp_number From stops where ord_hdrnumber = @ordhdrnumber
  and stp_sequence = 1) and evt_sequence = 1
Select @trailer2 = IsNull(@trailer2,replicate(' ',25))

Select '40002'
+ @bol
+ Convert( char(10),ivh_billdate,101)+' '+Convert( char(8),ivh_billdate,108)
+ Convert(char(15),ivh_invoicenumber)
+ @po
+ Convert( char(10),ivh_shipdate,101)+' '+Convert( char(8),ivh_shipdate,108)
+ Convert(char(20),ord_number)
+ Case ivh_tractor When 'Unknown' Then replicate(' ',10) Else Convert(char(10),ivh_tractor) End
+ Case ivh_trailer When 'Unknown' Then replicate(' ',25) Else Convert(char(25),ivh_trailer) End
+ @trailer2
+ convert(char(10),IsNull(ivh_originpoint,'UNKNOWN'))
+ convert(char(10), IsNull(ivh_destpoint,'UNKNOWN'))
+ convert(char(10),ivh_billto)
+ Case IsNull(tar_number,0) When 0 Then replicate(' ',10) Else Convert(char(10),tar_number) End
+ Convert(char(22),IsNull(ivh_totalmiles,0))
+ Case IsNull(ivh_order_cmd_code,'UNKNOWN') When 'UNKNOWN' Then Replicate(' ',10) Else Convert(char(10),ivh_order_cmd_code) End
+ Convert(char(22),IsNull(ivh_totalcharge,0),1)
+ Replicate(' ',10)  -- Cust type not et implemented
+ Case IsNull(c.cmp_edi210,0) When 0 Then 'N         ' When 1 Then 'Y         ' When 2 Then 'Y         ' Else 'N         ' End
+ replicate(' ',10)  -- Subsiduary company not implemented.
+ Convert(char(30),Substring(Rtrim(IsNull(mpp_firstname,'')+' ')+IsNull(mpp_lastname,''),1,30))
+ Convert(char(22),ivh_hdrnumber)
+ Case IsNull(c.cmp_invoicetype,'INV') When 'NONE' then 'Y' Else 'N' End
+ Case IsNull(ivh_mbnumber,0) When 0 Then replicate(' ',15) else convert(char(15),ivh_mbnumber) End
From invoiceheader h, company c, manpowerprofile
Where h.ivh_hdrnumber = @ivhhdrnumber
And c.cmp_id = h.ivh_billto
And manpowerprofile.mpp_id = ivh_driver



GO
GRANT EXECUTE ON  [dbo].[TMI_imagingrecord_400] TO [public]
GO
