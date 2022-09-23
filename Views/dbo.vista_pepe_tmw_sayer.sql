SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
















CREATE view [dbo].[vista_pepe_tmw_sayer]
AS
select ivh.ord_hdrnumber as ORDEN, ivh.ivh_consignee as Consigne,
(select top 1 ref.ref_number from referencenumber ref where ivh.ord_hdrnumber = ref.ord_hdrnumber) as TRASNSPORTE,
(select sum(ivd_charge)  from invoicedetail ivdet where ivdet.ord_hdrnumber = ivh.ord_hdrnumber AND cht_itemcode NOT IN ('TOLL','GST','PST')) AS VIAJE,
(select sum(ivd_charge)  from invoicedetail ivdet where ivdet.ord_hdrnumber = ivh.ord_hdrnumber AND cht_itemcode = 'TOLL') AS CASETAS

from invoiceheader ivh  
where ivh_billto IN ( 'SAYFUL','SAYER')
AND IVH_INVOICESTATUS ='HLD' 
and ord_hdrnumber in (
'715193',
'715194',
'715195',
'715196',
'715197',
'715198',
'715199',
'715200',
'715201',
'715202',
'715203',
'715204',
'715205',
'715206',
'715207',
'715208',
'715209',
'715210',
'715211',
'715212',
'715213',
'715214',
'715215',
'715559',
'715568',
'715570',
'715575',
'715576',
'715577',
'715578',
'715600',
'715601',
'715602',
'715604',
'715605',
'715606',
'715608',
--'715609',
--'708411',
--'709066',
--'711398',
--'712167',
--'711394',
--'712642',
--'712644',
--'712645',
--'712646',
--'713609',
--'713610',
'713611',
'713612',
'713613',
'713615',
'713616',
'713617',
'713618',
'715619',
'715620',
'715622',
'715623',
'716798',
'716799')
GO
