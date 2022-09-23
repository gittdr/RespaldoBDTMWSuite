SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


--Exec sp_TTSTMWGetChargeCodeString GetChargeCodeString 'Select [Invoice Header Number] from vTTSTMW_Invoices' 
CREATE   Procedure [dbo].[sp_TTSTMWGetChargeCodeString] (@SQLToRun varchar(8000),@OutSideColumn varchar(255) = '[Invoice Header Number]')

As
Declare @SQL varchar(8000)
Declare @ChargeTypeDesc varchar(255)
Declare @ChargeCode varchar(255)

If charindex('[Invoice Header Number]',@SQLToRun) > 0
Begin

Create Table #Invoice ([Invoice Header Number] int)

SET QUOTED_IDENTIFIER OFF
Insert into #Invoice
Exec (@SQLToRun)
SET QUOTED_IDENTIFIER ON

Set @SQL = ''


Create Table #ChargeTypesOnInvoice(cht_itemcode varchar(200))


select invoicedetail.cht_itemcode,chargetype.cht_description
into   #ChargeTypesToProcess
From   invoicedetail (NOLOCK),chargetype (NOLOCK)
where  exists (select * from #Invoice where #Invoice.[Invoice Header Number] = invoicedetail.ivh_hdrnumber)
       and
       IsNull(ivd_charge,0) <> 0
	   and
       invoicedetail.cht_itemcode = chargetype.cht_itemcode
     


Select cht_itemcode,cht_description
into   #TempChargeType
From   chargetype (NOLOCK)
Where  IsNull(cht_retired,'N') = 'N'
       And
       exists (select * From #ChargeTypesToProcess where #ChargeTypesToProcess.cht_itemcode = chargetype.cht_itemcode)


Set @ChargeTypeDesc = (select min(cht_description) from #TempChargeType)
Set @ChargeCode = (select top 1 cht_itemcode from #TempChargeType where cht_description = @ChargeTypeDesc)

While @ChargeTypeDesc Is Not Null
Begin


Set @SQL = @SQL + '[' + @ChargeTypeDesc + ']' + ' = ' + 'IsNull((Select sum(IsNull(b.ivd_charge,0)) from invoicedetail b (NOLOCK) where b.cht_itemcode = ' + '''' + @ChargeCode + '''' + ' And b.ivh_hdrnumber = ' + @OutSideColumn + '),0)' + ','

Set @ChargeTypeDesc = (select min(cht_description) from #TempChargeType where cht_description > @ChargeTypeDesc)

Set @ChargeCode = (select top 1 cht_itemcode from #TempChargeType where cht_description = @ChargeTypeDesc)


End


If Len(@SQL) > 0 
Begin
	Select Left(@SQL,Len(@SQL)-1)
End



End


If charindex('[Order Header Number]',@SQLToRun) > 0
Begin

Create Table #Order ([Order Header Number] int)

SET QUOTED_IDENTIFIER OFF
Insert into #Order
Exec (@SQLToRun)
SET QUOTED_IDENTIFIER ON

Set @SQL = ''


Create Table #ChargeTypesOnOrder(cht_itemcode varchar(200))


select invoicedetail.cht_itemcode,chargetype.cht_description
into   #ChargeTypesToProcessOrder
From   invoicedetail (NOLOCK),chargetype (NOLOCK)
where  exists (select * from #Order where #Order.[Order Header Number] = invoicedetail.ord_hdrnumber)
       and
       IsNull(ivd_charge,0) <> 0
	   and
       invoicedetail.cht_itemcode = chargetype.cht_itemcode
     


Select cht_itemcode,cht_description
into   #TempChargeTypeForOrder
From   chargetype (NOLOCK)
Where  IsNull(cht_retired,'N') = 'N'
       And
       exists (select * From #ChargeTypesToProcessOrder where #ChargeTypesToProcessOrder.cht_itemcode = chargetype.cht_itemcode)


Set @ChargeTypeDesc = (select min(cht_description) from #TempChargeTypeForOrder)
Set @ChargeCode = (select top 1 cht_itemcode from #TempChargeTypeForOrder where cht_description = @ChargeTypeDesc)

While @ChargeTypeDesc Is Not Null
Begin


Set @SQL = @SQL + '[' + @ChargeTypeDesc + ']' + ' = ' + 'IsNull((Select sum(IsNull(b.ivd_charge,0)) from invoicedetail b (NOLOCK) where b.cht_itemcode = ' + '''' + @ChargeCode + '''' + ' And b.ord_hdrnumber = ' + @OutSideColumn + '),0)' + ','

Set @ChargeTypeDesc = (select min(cht_description) from #TempChargeTypeForOrder where cht_description > @ChargeTypeDesc)

Set @ChargeCode = (select top 1 cht_itemcode from #TempChargeTypeForOrder where cht_description = @ChargeTypeDesc)


End

If Len(@SQL) > 0 
Begin
	Select Left(@SQL,Len(@SQL)-1)
End



End

GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWGetChargeCodeString] TO [public]
GO
