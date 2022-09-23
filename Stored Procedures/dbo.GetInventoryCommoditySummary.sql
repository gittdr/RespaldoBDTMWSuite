SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[GetInventoryCommoditySummary] @cmp_id varchar(8), @startdate datetime, @enddate datetime
as
select stops.ord_hdrnumber, ord_number, isnull(commodity.cmd_class2,'UNK'), 
	coalesce( 
	(select min(company_tankdetail.cmd_code) from company_tankdetail where company_tankdetail.cmp_id = stops.cmp_id and company_tankdetail.ActiveCommodityCode  = freightdetail.cmd_code ),
	(select min(company_tankdetail.cmd_code) from company_tankdetail where company_tankdetail.cmp_id = stops.cmp_id and charindex(rtrim(',' + freightdetail.cmd_code) + ',', + ',' + Rtrim(ltrim(ValidCommodityList))  + ',') > 0),
	(select min(commodity_equivalent.cmd_code) from tankforecast join commodity_equivalent on Commodity_eqid = commodity_equivalent.Eqid
		join commodity_equivalentdetails on commodity_equivalent.Eqid = commodity_equivalentdetails.eqid
		where tankforecast.cmp_id = stops.cmp_id and commodity_equivalentdetails.cmd_code = freightdetail.cmd_code),
		freightdetail.cmd_code) as cmd_code, 
	stops.stp_arrivaldate, ord_status, fgt_volume, fgt_weight, fgt_count, stops.lgh_number,
	fgt_deliverytank1, fgt_deliverytank2,fgt_deliverytank3,fgt_deliverytank4,fgt_deliverytank5,fgt_deliverytank6,fgt_deliverytank7,fgt_deliverytank8,fgt_deliverytank9,fgt_deliverytank10,
	isnull((select min(lgh_driver1) from legheader 
			where orderheader.mov_number = legheader.mov_number and lgh_driver1 <> 'UNKNOWN'), 'UNKNOWN') lgh_driver1,
	stops.stp_schdtearliest as Earliest, stops.stp_schdtlatest as Latest
from stops join freightdetail on stops.stp_number = freightdetail.stp_number
			join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
			join commodity on freightdetail.cmd_code = commodity.cmd_code
			left outer join tankforecast on tankforecast.cmp_id = stops.cmp_id and commoditystring = freightdetail.cmd_code
where stops.cmp_id = @cmp_id and stops.stp_type = 'DRP' and stops.stp_arrivaldate between @startdate  and @enddate and stops.ord_hdrnumber > 0
		and ord_status in ('AVL','DSP','PLN','STD','CMP') and freightdetail.cmd_code <> 'UNKNOWN'
GO
GRANT EXECUTE ON  [dbo].[GetInventoryCommoditySummary] TO [public]
GO
