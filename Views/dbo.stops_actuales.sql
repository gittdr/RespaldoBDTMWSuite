SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO















CREATE VIEW [dbo].[stops_actuales]

 AS 
 
select (select lgh_driver1 from legheader where lgh_number = stops.lgh_number) as driver,stops.*,
event.evt_tractor,
(Select lgh.ord_hdrnumber from legheader lgh where stops.lgh_number = lgh.lgh_number ) as lgh_ord_hdrnumber,
(Select lgh.lgh_type1 from legheader lgh where stops.lgh_number = lgh.lgh_number ) as ConfViaje,
(Select ord_revtype2 from orderheader where ord_hdrnumber = (Select lgh.ord_hdrnumber from legheader lgh where stops.lgh_number = lgh.lgh_number )) as ord_revtype2,
(Select ord_totalcharge from orderheader where ord_hdrnumber = (Select lgh.ord_hdrnumber from legheader lgh where stops.lgh_number = lgh.lgh_number )) as ord_totalcharge,
legheader.lgh_tractor,
(select 
		isnull((select max(trc_axles) from tractorprofile where trc_number = evt_tractor),0) +
		isnull((select max(trl_axles) from trailerprofile where trl_number = evt_trailer1),0) +
		isnull((select max(trl_axles) from trailerprofile where trl_number =evt_trailer2),0)+
		ISnull((select max(trl_axles) from trailerprofile where trl_number =evt_dolly),1)
			from event e where e.stp_number = stops.stp_number ) as ejes
from 
  stops
   left join event on stops.stp_number = event.stp_number
   left join legheader on legheader.lgh_number = stops.lgh_number
	where evt_tractor <> 'UNKNOWN'
	 --and stops.lgh_number in (select lgh_number
		--	from legheader 
		--	where (lgh_enddate between '01/01/2019'  and getdate()) and lgh_outstatus = 'CMP') 
	 and (Select lgh.ord_hdrnumber from legheader lgh where stops.lgh_number = lgh.lgh_number ) in (select ord_hdrnumber from orderheader where ord_completiondate > '2021-01-01' and ord_billto <> 'SAE' and ord_status = 'CMP' and ord_completiondate < getdate() )
	 --and evt_tractor = ''
GO
