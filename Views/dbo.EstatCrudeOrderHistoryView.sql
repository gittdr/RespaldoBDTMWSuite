SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[EstatCrudeOrderHistoryView] as
select o.ord_bookdate as BookDate,
		o.ord_hdrnumber,
		o.ord_number,
		s.stp_arrivaldate,
		o.ord_revtype1 as RevType1,
		o.ord_revtype2 as RevType2,
		ship.cmp_id as ShipperId,
		ship.cmp_altid as ShipperAltId,
		shipTank.TankTranslation,
		e.evt_driver1 as Driver,
		f.fgt_volume as Volume,
		o.ord_consignee as ConsigneeId,
		cons.cmp_altid as ConsigneeAltId,
		o.ord_status as Status,
		shipReading.inv_readingdate as ReadingDate
from stops as s 
		join orderheader as o on o.ord_hdrnumber = s.ord_hdrnumber
		join freightdetail as f on f.stp_number = s.stp_number
		join event as e on e.stp_number = s.stp_number and evt_sequence = 1
		join freight_by_compartment as fbc on fbc.fgt_number = f.fgt_number and fgt_sequence = 1
		join company as ship on ship.cmp_id = s.cmp_id 
		join company as cons on cons.cmp_id = o.ord_consignee
		left outer join company_tankdetail as shipTank on shipTank.cmp_id = s.cmp_id and shipTank.forecast_bucket =  fbc.fbc_tank_nbr
		left outer join OilFieldReadings as shipReading on shipReading.cmp_id = s.cmp_id and shipReading.fgt_number = f.fgt_number and shipReading.inv_tankID = shipTank.cmp_tank_id
where s.stp_event in ('LLD', 'HPL') 
GO
GRANT SELECT ON  [dbo].[EstatCrudeOrderHistoryView] TO [public]
GO
