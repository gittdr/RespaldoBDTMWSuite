SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


--exec weekmiles_update_porsemana_JR

CREATE PROCEDURE [dbo].[weekmiles_update_porsemana_JR] AS

DECLARE @sunday datetime, @fecha7diasant datetime

create table #tempweekmiles (
	TWM_mpp_id varchar(8),
	TWM_miles smallint)

--select @sunday = DATEADD(day, -1 * (datepart(dw,getdate())-1), getdate())
--select @sunday = dateadd(dd,datediff(dd,'20040101', @sunday ),'20040101')

--Actualiza en cero los kilometrajes de los operadores...
update manpowerprofile
set mpp_mile_day7 = 0.00
where mpp_status <> 'OUT'



select @fecha7diasant =  dateadd(dd,datediff(dd,'20040101',  DATEADD(day, -7, getdate()) ),'20040101')

insert #tempweekmiles (TWM_mpp_id, TWM_miles)
(
select e.evt_driver1, case when  sum( isnull(stp_lgh_mileage,0)) > 32767 then 32766 else  sum( isnull(stp_lgh_mileage,0)) end
---EMOLVERA: se agrego validacion para no sobrepasar datos del smallint, ya que los viajes hechos con driver unknown superan el limite de kms del smallint que solo llega hasta 32767 25/jul/2016
from stops s (nolock), event e (nolock)
where s.stp_number = e.stp_number
and stp_status='DNE'
and stp_arrivaldate > @fecha7diasant
group by evt_driver1
)



update manpowerprofile
set mpp_mile_day7 = TWM_miles  
from #tempweekmiles
where mpp_id = TWM_mpp_id

drop table #tempweekmiles


/*select mpp_id, mpp_mile_day7 from manpowerprofile 
order by mpp_mile_day7 desc
*/
GO
