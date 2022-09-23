SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PopulateFuelAllocationUsage] as
	declare @dt datetime, @dt2 datetime
	select @dt = getdate()

	select @dt = convert(datetime, convert(varchar(10), @dt, 101))
	select @dt2 = convert(datetime, convert(varchar(10), @dt, 101)+ ' 23:59:59')

	declare @i int
	select @i = 0
	while @i < 1 
	begin	
		delete FuelAllocationUsage
		where loaddate = @dt

		insert FuelAllocationUsage
		select @dt as LoadDate, (case when stp_status = 'OPN' then 'Y' else 'N' end) as Complete, ord_billto as BillTo, 
				stops.cmp_id as Shipper, 
				isnull(freightdetail.fgt_supplier,'UNKNOWN') AS Supplier, 
				isnull(fgt_accountof,'UNKNOWN') as AccountOf, 
				commodity.cmd_class CommodityClass, freightdetail.cmd_code as Commodity, sum(fgt_volume) as Volume
		from stops join freightdetail on stops.stp_number = freightdetail.stp_number
				join commodity on freightdetail.cmd_code = commodity.cmd_code
				join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber					
		where stp_arrivaldate between @dt and @dt2 and stp_type = 'PUP' 
		group by ord_billto, case when stp_status = 'OPN' then 'Y' else 'N' end, stops.cmp_id, freightdetail.fgt_supplier, fgt_accountof, commodity.cmd_class, freightdetail.cmd_code

		select @dt = dateadd(d, -1, @dt)
		select @dt2 = convert(datetime, convert(varchar(10), @dt, 101)+ ' 23:59:59')
		select @i = @i + 1
	end
GO
GRANT EXECUTE ON  [dbo].[PopulateFuelAllocationUsage] TO [public]
GO
