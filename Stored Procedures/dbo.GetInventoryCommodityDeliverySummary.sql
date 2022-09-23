SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[GetInventoryCommodityDeliverySummary] @cmp_id varchar(8), @StartDate datetime, @EndDate datetime
as
select convert(datetime, convert(varchar(10), stp_arrivaldate,1),1) inv_date, isnull(commodity.cmd_class2,'UNK') as cmd_class2, freightdetail.cmd_code, sum(fgt_volume) as fgt_volume 
from stops join freightdetail on stops.stp_number = freightdetail.stp_number
			join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
			join commodity on freightdetail.cmd_code = commodity.cmd_code
where stops.cmp_id = @cmp_id and stops.stp_type = 'DRP' and stops.stp_arrivaldate between @StartDate and @EndDate and stops.ord_hdrnumber > 0
		and ord_status in ('AVL','DSP','PLN','STD','CMP') and freightdetail.cmd_code <> 'UNKNOWN'
group by convert(datetime, convert(varchar(10), stp_arrivaldate,1),1), isnull(commodity.cmd_class2,'UNK'), freightdetail.cmd_code
GO
GRANT EXECUTE ON  [dbo].[GetInventoryCommodityDeliverySummary] TO [public]
GO
