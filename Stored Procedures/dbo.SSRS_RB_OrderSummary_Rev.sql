SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec [SSRS_RB_OrderSummary_Rev] 10012
--exec [SSRS_RB_OrderSummary_Rev] 1278

create  Procedure [dbo].[SSRS_RB_OrderSummary_Rev]	@ord_hdrnumber int
 
AS

Declare @Invoicestatus varchar(10)	
Set @Invoicestatus = (SELECT  orderheader.ord_invoicestatus from orderheader (nolock) where ord_hdrnumber = @ord_hdrnumber)

Declare  @Invoicelist table (ivd_charge int,cht_description varchar(100))



If @Invoicestatus = 'PPD'
		Begin
		insert into @invoicelist(ivd_charge,cht_description)
		select
		 invoicedetail.ivd_charge 
		, chargetype.cht_description 
		FROM invoicedetail 
		join chargetype on chargetype.cht_itemcode = invoicedetail.cht_itemcode
		where invoicedetail.ord_hdrnumber = @ord_hdrnumber
		and ivd_charge > 0
		
		select * from @invoicelist
		
		END
If @Invoicestatus <> 'PPD'
		Begin
		insert into @invoicelist(ivd_charge,cht_description)
		select
		Orderheader.ord_charge as 'ivd_charge'
		, chargetype.cht_description 

		FROM orderheader
		join chargetype  on chargetype.cht_itemcode = orderheader.cht_itemcode
		where orderheader.ord_hdrnumber = @ord_hdrnumber
		and ord_charge > 0
		UNION
		--insert into @invoicelist(ivd_charge,cht_description)
		select
		 invoicedetail.ivd_charge as 'ivd_charge'
		, chargetype.cht_description 

		FROM invoicedetail 
		join chargetype on chargetype.cht_itemcode = invoicedetail.cht_itemcode
		where invoicedetail.ord_hdrnumber = @ord_hdrnumber
		
		select * from @invoicelist
	
		End
		


GO
