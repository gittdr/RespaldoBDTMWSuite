SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[TMI_imagingrecord_300] @cmpid varchar(8),@transcode char(1)
As
/*  MODIFICATION LOG
Example call
exec TMI_imagingrecord_300 @cmpid='DET1',@transcode= 'A'

A trans code of 'L' returns all active companies

DPETE CREATED PTS 15477 Fro TMI Imaging company (allow for general info setting to map one of the cmp misc fields
   to the TMI CUSTTYPE (used as a super sort for invoice printing) and BILLREP (ref to clerk who normally performs
   billing for specific clients) 


*/
--DTS when sql returns messages due to inserts
SET NOCOUNT ON

Declare @TMIcusttypeField varchar(20),@TMIBillRepField varchar(20)

Select @TMICustTypeField = Upper(gi_string1) From Generalinfo Where gi_name = 'TMICustTypeField'
Select @TMICustTypeField = IsNull(@TMICustTypeField,'X')
Select @TMIBillRepField = Upper(gi_string1) From Generalinfo Where gi_name = 'TMIBillRepField'
Select @TMIBillRepField = IsNull(@TMIBillRepField,'X')

/* If company is UNKNOWN */
--If @cmpid <> 'UNKNOWN'
If @transcode = 'L'

  Select '30002' 
  + Convert(char(10),cmp_id)
  + Convert(char(50),Substring(IsNull(cmp_name,' '),1, 50))
  + Convert(char(40),Substring(IsNull(cmp_address1,' '),1,40))
  + Convert(char(40),Substring(IsNull(cmp_address2,' '),1,40))
--  + Case Charindex(',',IsNull(company.cty_nmstct,'')) When 0 Then replicate(' ',50) Else Convert(char(50),Substring(company.cty_nmstct,1,charindex(',',company.cty_nmstct) - 1)) End
--  + Case Charindex('/',IsNull(company.cty_nmstct,'')) When 0 Then Replicate(' ',25) Else Convert(char(25),Substring(company.cty_nmstct,charindex(',',company.cty_nmstct) + 1,charindex('/',company.cty_nmstct) - charindex(',',company.cty_nmstct) - 1))  End 
  + Convert(char(50),Substring(IsNull(cty_name,' '),1,50))
  + Convert(Char(25),IsNull(cty_state,' ')) 
  + Convert(char(15),IsNull(cmp_zip,' '))
  + IsNull(cmp_billto,'N')
  + IsNull(cmp_shipper,'N')
  + IsNull(cmp_consingee,'N')
--  + Case Datalength(Rtrim(IsNull(stc_country_c,''))) When 0 Then Replicate (' ',5) Else Convert(char(5),Substring(stc_country_c,1,5)) End
  + Convert(Char(5),IsNull(cty_country,' '))
  + Convert(char(10),Substring(Case @TMICustTypeField When 'MISC1' Then Isnull(cmp_misc1,' ') When 'MISC2' Then Isnull(cmp_misc2,' ') When 'MISC3' Then IsNull(cmp_misc3,' ') When 'MISC4' Then IsNull(cmp_misc4,' ') Else ' ' End,1,10))
  + Convert(char(10),Substring(Case @TMIBillRepField When 'MISC1' Then Isnull(cmp_misc1,' ') When 'MISC2' Then Isnull(cmp_misc2,' ') When 'MISC3' Then IsNull(cmp_misc3,' ') When 'MISC4' Then IsNull(cmp_misc4,' ') Else ' ' End,1,10))
  + replicate(' ',1)
  + @transcode
  From company,city  --city 
  Where cmp_active = 'Y'
  And cty_code =* cmp_city
  --And stc_state_c =* Case Charindex('/',IsNull(company.cty_nmstct,'')) When 0 Then'++' Else Substring(company.cty_nmstct,charindex(',',company.cty_nmstct) + 1,charindex('/',company.cty_nmstct) - charindex(',',company.cty_nmstct) - 1)  End 
  And cmp_id <> 'UNKNOWN'


Else

  Select '30002' 
  + Convert(char(10),cmp_id)
  + Convert(char(50),Substring(IsNull(cmp_name,' '),1, 50))
  + Convert(char(40),Substring(IsNull(cmp_address1,' '),1,40))
  + Convert(char(40),Substring(IsNull(cmp_address2,' '),1,40))
  + Case Charindex(',',IsNull(company.cty_nmstct,'')) When 0 Then replicate(' ',50) Else Convert(char(50),Substring(company.cty_nmstct,1,charindex(',',company.cty_nmstct) - 1)) End
  + Case Charindex('/',IsNull(company.cty_nmstct,'')) When 0 Then Replicate(' ',25) Else Convert(char(25),Substring(company.cty_nmstct,charindex(',',company.cty_nmstct) + 1,charindex('/',company.cty_nmstct) - charindex(',',company.cty_nmstct) - 1))  End 
  + Convert(char(15),IsNull(cmp_zip,' '))
  + IsNull(cmp_billto,'N')
  + IsNull(cmp_shipper,'N')
  + IsNull(cmp_consingee,'N')
  + Case Datalength(Rtrim(IsNull(stc_country_c,''))) When 0 Then Replicate (' ',5) Else Convert(char(5),Substring(stc_country_c,1,5)) End
  + Convert(char(10),Substring(Case @TMIBillRepField When 'MISC1' Then Isnull(cmp_misc1,' ') When 'MISC2' Then Isnull(cmp_misc2,' ') When 'MISC3' Then IsNull(cmp_misc3,' ') When 'MISC4' Then IsNull(cmp_misc4,' ') Else ' ' End,1,10))
  + Convert(char(10),Substring(Case @TMIBillRepField When 'MISC1' Then Isnull(cmp_misc1,' ') When 'MISC2' Then Isnull(cmp_misc2,' ') When 'MISC3' Then IsNull(cmp_misc3,' ') When 'MISC4' Then IsNull(cmp_misc4,' ') Else ' ' End,1,10))
  + replicate(' ',1)
  + @transcode
  From company,statecountry  
  Where cmp_id = @cmpid
  And stc_state_c =* Case Charindex('/',IsNull(company.cty_nmstct,'')) When 0 Then'++' Else Substring(company.cty_nmstct,charindex(',',company.cty_nmstct) + 1,charindex('/',company.cty_nmstct) - charindex(',',company.cty_nmstct) - 1)  End 
 
GO
GRANT EXECUTE ON  [dbo].[TMI_imagingrecord_300] TO [public]
GO
