SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[TMSFreightDataView] 
as
 select tmsitem.LineItemId, 
  tmsitem.fgt_number_drop, 
  tmsitem.fgt_number_pickup,
  dropstop.stp_number, 
  tmso.OrderId, 
  tmso.OrderNumber,
  orderheader.ord_revtype4 as ONHOLD,
  orderheader.ord_hdrnumber, 
  dropstop.mov_number,
  commodity.cmd_code, 
  commodity.cmd_name, 
  commodity.cmd_cust_num,
  commodity.cmd_misc1,     
  cmp.cmp_id DropID, 
  cmp.cmp_altid DropAltID, 
  cmp.cmp_name DropName, 
  cmp.cmp_address1 DropAddress1,
  cmp.cmp_address2 DropAddress2, 
  cmp.cmp_address3 DropAddress3,   
  city.cty_name DropCity, 
  city.cty_state DropState, 
  cmp.cmp_zip DropZip, 
  cmp.cmp_primaryphone DropPhone,
  pickupcmp.cmp_id PickupId, 
  pickupcmp.cmp_altid PickupAltID, 
  pickupcmp.cmp_name PickupName, 
  pickupcmp.cmp_address1 PickupAddress1, 
  pickupcmp.cmp_address2 PickupAddress2, 
  pickupcmp.cmp_address3 PickupAddress3, 
  pickupcity.cty_name PickupCity, 
  pickupcity.cty_state PickupState, 
  pickupcmp.cmp_zip PickupZip, 
  pickupcmp.cmp_primaryphone PickupPhone,
  tmsitem.LineNumber,
  tmsitem.QuanityToShip,
  tmsitem.QuanityToShipUnit,
  tmsitem.LineItemType1,
  tmsitem.LineItemType2,
  tmsitem.LineItemType3,
  tmsitem.LineItemType4,
  tmsitem.LineItemType5,
  tmsitem.SKU,
  ISNULL(dropfreight.fgt_count,tmsitem.Pallets) as [Pallet],
  ISNULL(dropfreight.fgt_volume,tmsitem.Cases) as Cases,
  ISNULL(dropfreight.fgt_weight,Quantity3) as [Weight],
  isnull(sapevent.evt_earlydate, pickupstop.stp_schdtearliest) as PickupWindowDateEarliest,
  isnull(sapevent.evt_latedate, pickupstop.stp_schdtlatest) as PickupWindowDateLatest,
  isnull(sapevent.evt_earlydate, dropstop.stp_schdtearliest) as DropWindowDateEarliest,
  isnull(sapevent.evt_latedate, dropstop.stp_schdtlatest) as DropWindowDateLatest,
  dropstop.stp_arrivaldate as Arrival,
  dropstop.stp_status as Status,
  dropstop.stp_departuredate as Departure,
  sapevent.evt_contact, 
  sapevent.evt_reason,
  pickupevent.evt_carrier,
  pickupstop.stp_mfh_sequence as PickupSequence,
  dropstop.stp_mfh_sequence as DropSequence,
  (case when rtrim(isnull(ref.ref_number,'')) <> '' then 'Y' else 'N' end) as HasPUAppt,
  (case when rtrim(isnull(refdrop.ref_number,'')) <> '' then 'Y' else 'N' end) as HasDRPAppt,
  ref.ref_number as PickupApptNumber,
  refdrop.ref_number as DropApptNumber, 
  pickupstop.stp_arrivaldate as PickupArrival,
  dropcmp.cmp_othertype1 as Lumper,
  pickupstop.stp_schdtearliest as PickupAppointment,
  dropstop.stp_schdtearliest as DeliveryAppointment
  from TMSOrderLineItems as tmsitem join TMSOrder as tmso on tmso.OrderId = tmsitem.OrderId
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
    join company as dropcmp on dropcmp.cmp_id = dropstop.cmp_id
    join city as pickupcity on pickupcity.cty_code = pickupcmp.cmp_city
    left join referencenumber as ref on ref.ref_table ='stops' and ref.ref_tablekey = pickupstop.stp_number and ref.ref_type = 'APPT#'
    left join referencenumber as refdrop on refdrop.ref_table ='stops' and refdrop.ref_tablekey = dropstop.stp_number and refdrop.ref_type in ( 'APPT#', 'DRP#')
union
  select tmsitem.LineItemId, 
  tmsitem.fgt_number_drop, 
  tmsitem.fgt_number_pickup,
  null, 
  tmso.OrderId, 
  tmso.OrderNumber,
  null, 
  null, 
  null,
  commodity.cmd_code, 
  commodity.cmd_name, 
  commodity.cmd_cust_num,
  commodity.cmd_misc1,
  cmp.cmp_id DropID, 
  cmp.cmp_altid DropAltID, 
  cmp.cmp_name DropName, 
  cmp.cmp_address1 DropAddress1,
  cmp.cmp_address2 DropAddress2, 
  cmp.cmp_address3 DropAddress3, 
  city.cty_name DropCity, 
  city.cty_state DropState, 
  cmp.cmp_zip DropZip, 
  cmp.cmp_primaryphone DropPhone,
  pickupcmp.cmp_id PickupId, 
  pickupcmp.cmp_altid PickupAltID, 
  pickupcmp.cmp_name PickupName, 
  pickupcmp.cmp_address1 PickupAddress1, 
  pickupcmp.cmp_address2 PickupAddress2, 
  pickupcmp.cmp_address3 PickupAddress3, 
  pickupcity.cty_name PickupCity, 
  pickupcity.cty_state PickupState, 
  pickupcmp.cmp_zip PickupZip, 
  pickupcmp.cmp_primaryphone PickupPhone,
  tmsitem.LineNumber,
  tmsitem.QuanityToShip,
  tmsitem.QuanityToShipUnit,
  tmsitem.LineItemType1,
  tmsitem.LineItemType2,
  tmsitem.LineItemType3,
  tmsitem.LineItemType4,
  tmsitem.LineItemType5,
  tmsitem.SKU,
  tmsitem.Pallets as [Pallet],
  tmsitem.Cases as Cases,
  Quantity3 as [Weight],
  tmsp.WindowDateEarliest as TMWPickupWindowDateEarliest,
  tmsp.WindowDateLatest as TMWPickupWindowDateLatest,
  tmsd.WindowDateEarliest as TMWDropWindowDateEarliest,
  tmsd.WindowDateLatest as TMWDropWindowDateLatest,
  null as Arrival,
  null as Status,
  null as Departure,
  null, 
  null,
  null,
  null as PickupSequence,
  null as DropSequence,
  null as PUHasAppt,
  null as DRPHasAppt,
  null as PickupApptNumber,
  null as DropApptNumber,
  null as PickupArrival,
  null as Lumper,
  null as PickupAppointment,
  null as DeliveryAppointment
  from TMSOrderLineItems as tmsitem  join TMSOrder as tmso on tmso.OrderId = tmsitem.OrderId
   join TMSStops as tmsd on tmso.OrderId = tmsd.OrderId and tmsd.StopType = 'DRP'
   join TMSStops as tmsp on tmso.OrderId = tmsp.OrderId and tmsp.StopType = 'PUP'
   join commodity on commodity.cmd_code = tmsitem.cmd_code
   join company as cmp on cmp.cmp_id = tmsd.LocationId
   join city on city.cty_code = cmp.cmp_city
   join company as pickupcmp on pickupcmp.cmp_id = tmsitem.LineItemType4
   join city as pickupcity on pickupcity.cty_code = pickupcmp.cmp_city
  where tmsitem.fgt_number_drop is null
GO
GRANT SELECT ON  [dbo].[TMSFreightDataView] TO [public]
GO
