SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[EstatHistoricalOrdersVieworig] as 
select
 'TMWWF_ESTAT_HISTORICAL' as 'TMWWF_ESTAT_HISTORICAL',
 ord.ord_number,
 (select cmp_name from company where cmp_id = ord.ord_billto) 'BillTo', 
 ord.ord_billto 'BillToID',
    (select cmp_name from company where cmp_id = ord.ord_company) 'OrderBy',
    ord.ord_company 'OrderByID',  
 
 ord.ord_status 'DispStatus', 
 scompany.cmp_id 'PickupID',
 scompany.cmp_name 'PickupName',
 scity.cty_name 'PickupCity',
 scity.cty_state 'PickupState',
 ccompany.cmp_id 'ConsigneeID',
 ccompany.cmp_name 'ConsigneeName',
 ccity.cty_name 'ConsigneeCity',
 ccity.cty_state 'ConsigneeState',
 ord.ord_revtype1 'RevType1', ord.ord_revtype2 'RevType2', ord.ord_revtype3 'RevType3', ord.ord_revtype4 'RevType4',  
 ord.ord_hdrnumber,
 ord.ord_startdate 'StartDate', 
 ord.ord_completiondate 'EndDate'
from orderheader as ord
  join city as scity on ord.ord_origincity = scity.cty_code
  join company as scompany on ord.ord_originpoint = scompany.cmp_id
  join city as ccity on ord.ord_destcity = ccity.cty_code
  join company as ccompany on ord_destpoint = ccompany.cmp_id
GO
