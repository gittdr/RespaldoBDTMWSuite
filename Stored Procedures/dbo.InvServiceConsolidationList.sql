SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[InvServiceConsolidationList] as

create table #ActiveList
(ord_hdrnumber int not null,
 ord_number varchar(12) not null,
 Volume decimal(9,4) not null,
 ArrivalDate datetime not null,
 cmp_id varchar(8) not null)

insert #ActiveList
select orderheader.ord_hdrnumber, ord_number, 
	isnull((select sum(fgt_quantity) from stops join freightdetail on stops.stp_number = freightdetail.stp_number 
	where stops.ord_hdrnumber = leg.ord_hdrnumber  and fgt_volumeunit = fgt_unit and stops.stp_type = 'DRP' and stops.ord_hdrnumber <> 0),0) as Volume,
	(select min(stp_arrivaldate) from stops where stops.ord_hdrnumber = leg.ord_hdrnumber and stops.stp_type = 'DRP') as ArrivalDate,
    l_cmpid as cmp_id
from legheader_active as leg join orderheader on leg.ord_hdrnumber = orderheader.ord_hdrnumber
where (case when isnull(ord_order_source,'XX') <> 'FRCST' then 
	'N'  --isnot a forecasted order 
	when (select count(distinct ord_hdrnumber) from stops where stops.lgh_number = leg.lgh_number and stops.ord_hdrnumber <> 0) > 1 then 
	'N' --has more than one order
	when (select count(distinct lgh_number) from stops where stops.ord_hdrnumber = leg.ord_hdrnumber and stops.ord_hdrnumber <> 0) > 1 	then 
	'N' --has more than one leg
	when (select count(*) from stops where stops.ord_hdrnumber = leg.ord_hdrnumber and stops.stp_type = 'DRP') > 1 	then 
	'N' --has more than one delivery
	when isnull((select sum(fgt_quantity) from stops join freightdetail on stops.stp_number = freightdetail.stp_number 
			where stops.ord_hdrnumber = leg.ord_hdrnumber  and fgt_volumeunit = fgt_unit and stops.stp_type = 'DRP'),0) < 2 then
	'N' --has no delivery gallons and is not a 1 gallon forecast orders
	else 'Y' end) = 'Y' and
	(select min(stp_arrivaldate) from stops where stops.ord_hdrnumber = leg.ord_hdrnumber and stops.stp_type = 'DRP') >= getdate()



select InvServicesDeliveryGroupAssign.DelGroup, CanShortLoad, ord_hdrnumber, ord_number, Volume, ArrivalDate, #ActiveList.cmp_id 
from #ActiveList join InvServicesDeliveryGroupAssign on #ActiveList.cmp_id = InvServicesDeliveryGroupAssign.cmp_id
		join InvServicesDeliveryGroup on InvServicesDeliveryGroup.DelGroup = InvServicesDeliveryGroupAssign.DelGroup
where ArrivalDate between getdate() and dateadd(hour, HoursOutForSearch * 1.2, getdate())
	and ord_hdrnumber in (select min(ord_hdrnumber) from #ActiveList as list1 where list1.cmp_id = #ActiveList.cmp_id
									and list1.ArrivalDate in (select min(ArrivalDate) from #ActiveList as list2 where list2.cmp_id = list1.cmp_id))
GO
GRANT EXECUTE ON  [dbo].[InvServiceConsolidationList] TO [public]
GO
