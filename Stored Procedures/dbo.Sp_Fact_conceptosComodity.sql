SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Sp_Fact_conceptosComodity] @ord_mb varchar(10)
AS
SET NOCOUNT ON

begin

select '/'+  ivd_description +' - '+ cast(count(*) as varchar) +
(select  ' - ' + cast(id.ord_hdrnumber as varchar) from invoicedetail id
inner join invoiceheader ih on ih.ord_hdrnumber = id.ord_hdrnumber and ih.ivh_mbnumber = @ord_mb and inv.ivd_description = id.ivd_description and id.cht_itemcode = 'DEL' FOR XML PATH(''))  

from invoicedetail inv
where ord_hdrnumber in (select ord_hdrnumber from invoiceheader
where ivh_mbnumber = @ord_mb) and cht_itemcode = 'DEL'
group by ivd_description
FOR XML PATH('')


end


--select * from invoicedetail
--where invoicenumber in ('A1191467','A1191468','A1191469','A1191470')


--select id.ord_hdrnumber,* from invoicedetail id
--inner join invoiceheader ih on ih.ord_hdrnumber = id.ord_hdrnumber
--where ivh_mbnumber = '910295'
GO
