SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ida_GetAcceptPercent](
@Daysback int =365
)
as
begin

declare @dateval datetime
set @dateval = dateadd(d,-365, getdate())

select 
eo.car_id, 
count(eo.ord_number) AS offers,
count(distinct(d.ord_number)) as declines,
count(distinct(c.ord_number)) as counters
from edi_outbound204_order eo (nolock) 
left join (select ord_number from edi_inbound990_records (nolock) where [action] = 'D') d on eo.ord_number = d.ord_number 
left join (select ord_number from edi_inbound990_records (nolock) where [action] = 'C') c on eo.ord_number = c.ord_number 
where eo.created_dt >= @dateval   
group by eo.car_id

END 

GO
GRANT EXECUTE ON  [dbo].[ida_GetAcceptPercent] TO [public]
GO
