SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[CarrierHubWorkSheetView] as
WITH  PayStatus as (
 select l.lgh_number, max(case when ph.pyh_paystatus = 'XFR' then '90 - Paid' 
  when pd.pyd_status = 'AUD' then '80 - Approved'
  when pd.pyd_status = 'HLD' then '70 - Needs Pay Review'
  when a.pyd_status = 'NPD' then '60 - No Pay'
  else '80 - Released'
 end) PayStatus from 
   legheader as l 
   join assetassignment as a on a.asgn_id = l.lgh_carrier and a.asgn_type = 'CAR' and a.lgh_number = l.lgh_number 
   left join paydetail as pd on pd.lgh_number = l.lgh_number
   left join payheader as ph on ph.pyh_pyhnumber = pd.pyh_number
   group by l.lgh_number),
PaperWorkCount as (select count(*) as [Required] from labelfile as label where label.labeldefinition = 'PaperWork' and label.abbr <> 'UNK' and label.retired <> 'Y'),
PaperWorkStatus as (
	 select l.lgh_number, PaperWorkCount.[Required], sum(case when isnull(p.pw_received, 'N') = 'Y' then 1 else 0 end) as Recieved
	 from  PaperWorkCount, 
	  legheader as l 
	  left join paperwork as p on p.lgh_number = l.lgh_number 
	 group by l.lgh_number, PaperWorkCount.[Required])   
	select        l.lgh_carrier [Carrier],
	   case when l.lgh_outstatus = 'AVL' then '10 - Available' 
		when l.lgh_outstatus = 'STD' then '25 - Started'
		when l.lgh_outstatus = 'PLN' AND (l.lgh_204status = 'TND' OR l.lgh_204status is null) then '15 - Tendered'
		when l.lgh_outstatus = 'DSP' OR (l.lgh_outstatus = 'PLN' AND l.lgh_204status = 'TDA') then '20 - Accepted'
		when PaperWorkStatus.Required <> PaperWorkStatus.Recieved or r.fgt_number is null then '30 - Missing Data'
		else PayStatus.PayStatus end [CarrierStatus],
			l.lgh_number [LegNumber],
			o.ord_hdrnumber [OrderNumber],
            o.mov_number [MoveNumber],
            c.cmp_id [ShipperId],
            c.cmp_altid [ShipperAltId],
            parent.cmp_id [ParentId],
            parent.cmp_altid [ParentAltId],
            tank.cmp_tank_id [TankId],
            tank.TankTranslation [TankTranslation],
            o.ord_revtype1 [RevType1], 
            o.ord_revtype2 [RevType2], 
            o.ord_revtype3 [RevType3], 
            o.ord_revtype4 [RevType4], 
            o.ord_priority [Priority],
            l.lgh_enddate [EndDate],
			l.lgh_204status [Edi204Status],
			case when l.lgh_outstatus = 'PLN' AND (l.lgh_204status = 'TND' OR l.lgh_204status is null) then 'Y'
			else 'N'
			end [Tendered],
			l.lgh_204date [Edi204Date], 
            f.fgt_number [FreightNumber],
            f.cmd_code [Commodity],
            f.fgt_volume [Volume1],
            f.fgt_volumeunit [Volume1Unit],
            f.fgt_volume2 [Volume2],
            f.fgt_volume2unit [Volume2Unit],
            r.TicketType [TicketType],
            r.run_ticket [TicketNumber],
            r.inv_readingdate [ReadingDate]
              from legheader as l   
      join stops as s on s.lgh_number = l.lgh_number and s.stp_type = 'PUP'
      join orderheader as o on s.ord_hdrnumber = o.ord_hdrnumber 
                     join freightdetail as f on f.stp_number = s.stp_number
                     join company as c on c.cmp_id = s.cmp_id
                     join company as parent on parent.cmp_id = c.cmp_mastercompany
                     left outer join OilFieldReadings as r on r.fgt_number = f.fgt_number
                     left outer join freight_by_compartment as fbc on fbc.fgt_number = f.fgt_number
                     left outer join company_tankdetail as tank on tank.cmp_id = s.cmp_id and tank.forecast_bucket = fbc.fbc_tank_nbr
      join PayStatus on PayStatus.lgh_number = l.lgh_number
      join PaperWorkStatus on PaperWorkStatus.lgh_number = l.lgh_number

			where l.lgh_carrier <> 'UNKNOWN' --and lgh_enddate > dateadd(dd, -780, getdate())
GO
GRANT SELECT ON  [dbo].[CarrierHubWorkSheetView] TO [public]
GO
