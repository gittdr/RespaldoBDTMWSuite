SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vista_kms_operadores]
as
select evt_driver1,
mpp_lastfirst as name,
case when cast(stp_schdtlatest as date)>getdate() then orderheader.ord_completiondate else cast(stp_schdtlatest as date) end as fechastop 
,sum(stp_lgh_mileage) as stp_lgh_mileage
from 
  stops
   left join event on stops.stp_number = event.stp_number
   inner join legheader lgh on stops.lgh_number = lgh.lgh_number 
   inner join  orderheader on orderheader.ord_hdrnumber = lgh.ord_hdrnumber
   inner join manpowerprofile on manpowerprofile.mpp_id = event.evt_driver1
	where evt_tractor <> 'UNKNOWN' and stp_lgh_mileage > 0 and stp_lgh_mileage is not null
	and ord_completiondate < getdate() and ord_status = 'CMP' and cast(stp_schdtlatest as date) > '2000-01-01'
	group by evt_driver1,mpp_lastfirst, orderheader.ord_completiondate,cast(stp_schdtlatest as date)
	
GO
