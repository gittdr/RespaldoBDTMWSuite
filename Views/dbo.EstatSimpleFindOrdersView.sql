SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [dbo].[EstatSimpleFindOrdersView]
as select 
  ord.ord_number,
 ord.ord_status 'DispStatus', 
 ord.ord_company 'OrderByID', 
   scity.cty_name 'PickupCity',
 scity.cty_state 'PickupState',
 --ccompany.cmp_id 'ConsigneeID',
 ccity.cty_name 'ConsigneeCity',
 ccity.cty_state 'ConsigneeState', 
 ord.ord_hdrnumber,
 ord.ord_startdate 'StartDate', 
 ord.ord_completiondate 'EndDate' 
from orderheader as ord
  join city as scity on ord.ord_origincity = scity.cty_code
  join company as scompany on ord.ord_originpoint = scompany.cmp_id
  join city as ccity on ord.ord_destcity = ccity.cty_code
  join company as ccompany on ord_destpoint = ccompany.cmp_id
GO
GRANT INSERT ON  [dbo].[EstatSimpleFindOrdersView] TO [public]
GO
GRANT SELECT ON  [dbo].[EstatSimpleFindOrdersView] TO [public]
GO
GRANT UPDATE ON  [dbo].[EstatSimpleFindOrdersView] TO [public]
GO
