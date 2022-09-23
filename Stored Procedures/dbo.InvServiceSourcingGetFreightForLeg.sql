SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[InvServiceSourcingGetFreightForLeg] @lgh_number int
as

DECLARE @OrderNumbers varchar(100)
SELECT @OrderNumbers = coalesce(@OrderNumbers + ',' , orderheader.ord_number) + orderheader.ord_number 
FROM legheader inner join 
	orderheader on orderheader.mov_number = legheader.mov_number
WHERE legheader.lgh_number = @lgh_number
 
select distinct
		RTRIM(LTRIM(ISNULL(@OrderNumbers, '0'))) as OrderNumbers, 
		ISNULL(legheader.mov_number,0) as MoveNumber,
		RTRIM(LTRIM(ISNULL(stops.cmp_id, 'UNKNOWN'))) as Consignee,
		RTRIM(LTRIM(ISNULL(freightdetail.fgt_shipper, 'UNKNOWN'))) as Shipper, 
		RTRIM(LTRIM(ISNULL(freightdetail.fgt_supplier, 'UNKNOWN'))) as Supplier,  
		RTRIM(LTRIM(ISNULL(freightdetail.cmd_code, 'UNKNOWN'))) as Commodity,
		ISNULL(stops.stp_arrivaldate, '1/1/1950') as Arrival,
		ISNULL(freightdetail.fgt_quantity, 0.0) as Volume
from legheader 
	inner join stops on legheader.lgh_number = stops.lgh_number 
	inner join freightdetail on freightdetail.stp_number = stops.stp_number 
	inner join orderheader on orderheader.mov_number = stops.mov_number 
where legheader.lgh_number = @lgh_number and stops.stp_event = 'LUL'
GO
GRANT EXECUTE ON  [dbo].[InvServiceSourcingGetFreightForLeg] TO [public]
GO
