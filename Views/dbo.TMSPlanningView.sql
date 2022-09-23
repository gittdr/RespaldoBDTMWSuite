SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMSPlanningView]
AS
 select 
  'Order' As 'Type',
  o.OrderId As 'Id',
  OrderNumber,
  delv_city.cty_nmstct 'Delivery',
  s2.WindowDateEarliest DeliveryDateEarliest, 
  s2.WindowDateLatest DeliveryDateLatest,
  c.cmd_name 'Commodity',
  dbo.GetTMSTotalQuantity1Total(oh.mov_number) 'Pallet',
  dbo.GetTMSTotalQuantity2Total(oh.mov_number) 'Cube',
  dbo.GetTMSTotalQuantity3Total(oh.mov_number) 'Weight',
  pick_city.cty_nmstct 'Pickup',
  s1.WindowDateEarliest PickupDateEarliest, 
  s1.WindowDateLatest PickupDateLatest,
  oh.ord_status 'Status',
  o.Status1 'TMSStatus1',
        o.Status2 'TMSStatus2',
  (SELECT COUNT(*) FROM orderheader where mov_number=lh.mov_number) OrderCount
 from TMSOrder o
  left join TMSStops as s1 on s1.OrderId = o.OrderId and s1.StopType = 'PUP'
  left join TMSStops as s2 on s2.OrderId = o.OrderId and s2.StopType = 'DRP'
  left join company pick on pick.cmp_id = s1.LocationId
  left join city pick_city on pick_city.cty_code = s1.LocationCityCode
  left join company delv on delv.cmp_id = s2.LocationId 
  left join city delv_city on delv_city.cty_code = s2.LocationCityCode
  left join commodity c on c.cmd_code = o.Commodity
  left join orderheader oh on o.ord_hdrnumber = oh.ord_hdrnumber
  join legheader_active lh on lh.ord_hdrnumber= oh.ord_hdrnumber
    where ISNULL(oh.ord_status,o.Status1)  = 'AVL'  
      and ordercount > 0  
union
 select 
  'Line' As 'Type',
  LineItemId As 'Id',
  o.OrderNumber,
  delv_city.cty_nmstct 'Delivery',
  s2.WindowDateEarliest DeliveryDateEarliest, 
  s2.WindowDateLatest DeliveryDateLatest,
  c.cmd_name 'Commodity',
  li.Quantity1 'Pallet',
  li.Quantity2 'Cube',
  li.Quantity3 'Weight',
  pick_city.cty_nmstct 'Pickup',
  s1.WindowDateEarliest PickupDateEarliest, 
  s1.WindowDateLatest PickupDateLatest,
  oh.ord_status 'Status',
  o.Status1 'TMSStatus1',
        o.Status2 'TMSStatus2',
  (SELECT COUNT(*) FROM orderheader where mov_number=lh.mov_number) OrderCount
 from TMSOrderLineItems li
  inner join TMSOrder o on o.OrderId = li.OrderId
  left join TMSStops as s1 on s1.OrderId = o.OrderId and s1.StopType = 'PUP'
  left join TMSStops as s2 on s2.OrderId = o.OrderId and s2.StopType = 'DRP'
  left join company pick on pick.cmp_id = s1.LocationId
  left join city pick_city on pick_city.cty_code = s1.LocationCityCode
  left join company delv on delv.cmp_id = s2.LocationId 
  left join city delv_city on delv_city.cty_code = s2.LocationCityCode
  left join commodity c on c.cmd_code = li.cmd_code
  left join orderheader oh on o.ord_hdrnumber = oh.ord_hdrnumber
  join legheader_active lh on lh.ord_hdrnumber= oh.ord_hdrnumber
    where ISNULL(oh.ord_status,o.Status1)  = 'AVL'     
      and ordercount > 0
GO
GRANT SELECT ON  [dbo].[TMSPlanningView] TO [public]
GO
