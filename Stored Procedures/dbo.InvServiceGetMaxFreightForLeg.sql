SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[InvServiceGetMaxFreightForLeg] @lgh_number int
as

DECLARE @OrderNumbers varchar(100)
SELECT @OrderNumbers = coalesce(@OrderNumbers + ',' , orderheader.ord_number) + orderheader.ord_number 
FROM legheader inner join 
	orderheader on orderheader.mov_number = legheader.mov_number
WHERE legheader.lgh_number = @lgh_number
 
select top 1
		ISNULL(@OrderNumbers, '0') as OrderNumbers, 
		ISNULL(freightdetail.fgt_shipper, 'UNKNOWN') as Shipper, 
		ISNULL(freightdetail.fgt_supplier, 'UNKNOWN') as Supplier, 
		ISNULL(stops.cmp_id, 'UNKNOWN') as Consignee, 
		ISNULL(freightdetail.cmd_code, 'UNKNOWN') as LeadCommodity,
		ISNULL(freightdetail.fgt_quantity, 0.0) as Volume
from legheader 
	inner join stops on legheader.lgh_number = stops.lgh_number 
	inner join freightdetail on freightdetail.stp_number = stops.stp_number 
	inner join orderheader on orderheader.mov_number = stops.mov_number 
	inner join (
			select MAX(freightdetail.fgt_quantity) as MaxQuantity from legheader
			inner join stops on legheader.lgh_number = stops.lgh_number 
			inner join freightdetail on freightdetail.stp_number = stops.stp_number 
			inner join orderheader on orderheader.mov_number = stops.mov_number 
			where legheader.lgh_number = @lgh_number
		) as MaxQuantity on MaxQuantity = freightdetail.fgt_quantity	
where legheader.lgh_number = @lgh_number and stops.stp_event = 'LUL'
group by freightdetail.fgt_shipper, freightdetail.fgt_supplier,stops.cmp_id,freightdetail.cmd_code,freightdetail.fgt_quantity, MaxQuantity, orderheader.ord_number
having MAX(freightdetail.fgt_quantity) = MaxQuantity
GO
GRANT EXECUTE ON  [dbo].[InvServiceGetMaxFreightForLeg] TO [public]
GO
