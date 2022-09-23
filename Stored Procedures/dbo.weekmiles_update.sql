SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[weekmiles_update] AS

DECLARE @sunday datetime

create table #tempweekmiles (
	TWM_mpp_id varchar(8),
	TWM_miles int)

select @sunday = DATEADD(day, -1 * (datepart(dw,getdate())-1), getdate())
select @sunday = dateadd(dd,datediff(dd,'20040101', @sunday ),'20040101')

insert #tempweekmiles (TWM_mpp_id, TWM_miles)
(
select e.evt_driver1, sum( isnull(stp_lgh_mileage,0)) 
from stops s, event e 
where s.stp_number = e.stp_number
and stp_status='DNE'
and stp_arrivaldate > @sunday
group by evt_driver1
)

update manpowerprofile
set mpp_mile_day7 = TWM_miles
from #tempweekmiles
where mpp_id = TWM_mpp_id

drop table #tempweekmiles

GO
GRANT EXECUTE ON  [dbo].[weekmiles_update] TO [public]
GO
