SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create VIEW [dbo].[TMSOrderFreightView]
AS
 select distinct tmsitem.LineItemId, 
  tmso.OrderId, 
  tmso.OrderNumber, 
  orderheader.ord_hdrnumber 'Order Header',   
  commodity.cmd_code 'Commodity Code', 
  commodity.cmd_name  'Commodity Name',   
  commodity.cmd_misc1,
  cmp.cmp_id DropID, 
     cmp.cmp_name DropName,   
  city.cty_name DropCity, 
  city.cty_state DropState,   
  pickupcmp.cmp_id PickupId,  
  pickupcmp.cmp_name PickupName,
  pickupcity.cty_name PickupCity, 
  pickupcity.cty_state PickupState, 
  tmsitem.QuanityToShip,
  tmsitem.QuanityToShipUnit, 
  ISNULL(dropfreight.fgt_count,tmsitem.Pallets) as [Pallet],
  ISNULL(dropfreight.fgt_volume,tmsitem.Cases) as Cases,
  ISNULL(dropfreight.fgt_weight,Quantity3) as [Weight],
  TSD.ShipId 'ShipID',
  'ModePlanner_OrderFreight' as 'ModePlanner_OrderFreight'  
  from TMSOrderLineItems as tmsitem join TMSOrder as tmso on tmso.OrderId = tmsitem.OrderId          
          join TMSShipmentStopDetail as TSD on tmso.OrderId = TSD.OrderId
    join freightdetail as dropfreight on tmsitem.fgt_number_drop = dropfreight.fgt_number
    join freightdetail as pickupfreight on tmsitem.fgt_number_pickup = pickupfreight.fgt_number
    join stops as dropstop on dropfreight.stp_number = dropstop.stp_number
    join stops as pickupstop on pickupfreight.stp_number = pickupstop.stp_number
    join event as pickupevent on pickupevent.stp_number = pickupstop.stp_number and pickupevent.evt_sequence = 1
    left join event as sapevent on sapevent.stp_number = pickupstop.stp_number and sapevent.evt_sequence = 2
    join orderheader on orderheader.ord_hdrnumber = dropstop.ord_hdrnumber
    join commodity on commodity.cmd_code = ISNULL(dropfreight.cmd_code,tmsitem.cmd_code)
    join company as cmp on cmp.cmp_id = dropstop.cmp_id
    join city on city.cty_code = cmp.cmp_city
    join company as pickupcmp on pickupcmp.cmp_id = pickupstop.cmp_id
    join city as pickupcity on pickupcity.cty_code = pickupcmp.cmp_city
GO
GRANT SELECT ON  [dbo].[TMSOrderFreightView] TO [public]
GO
