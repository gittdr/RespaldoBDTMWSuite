SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[InvServiceGetBestPriceForConsignee] @consignee varchar(8), @effectiveDate datetime
as
	declare @startDate datetime
	select @startDate = DATEADD(d, -7, @effectiveDate )

	create table #tempCommodity (
		CommodityCode varchar(8),
		QuoteVolume int
		)
	
	-- populate temp table with list of commodity tanks and valid commodities for tanks
	insert into #tempCommodity
	select distinct cmd_code, QuoteVolume from company_tankdetail
	where cmp_id = @consignee and company_tankdetail.cmd_code <> 'UNKNOWN' and cmd_code is not null
	union
	select distinct commodity.cmd_code, QuoteVolume from commodity, company_tankdetail
	where cmp_id = @consignee and CHARINDEX(','+commodity.cmd_code+',', ' ,'+ValidCommodityList+',') > 1 and commodity.cmd_code is not null
	union
	select distinct ActiveCommodityCode, QuoteVolume from company_tankdetail
	where cmp_id = @consignee and company_tankdetail.cmd_code <> 'UNKNOWN' and ActiveCommodityCode is not null
	
	create table #tempShippers (
		Shipper varchar(8),
		Commodity varchar(8)
		)		
		
	-- populate temp table with list of shippers and commodities that they have picked up before
	insert into #tempShippers
	select distinct
		FuelRelations.Pickup 'Shipper', 
		#tempCommodity.CommodityCode
	from
		FuelRelations cross join #tempCommodity
	where	FuelRelations.RelType = 'CMDPIN' and 
			FuelRelations.Delivery = @consignee
			
	select distinct
		DTN1.Shipper,
		DTN1.Supplier,
		DTN1.AccountOf,
		ISNULL(DTN1.CommodityCode, 'UNKNOWN') as CommodityCode,
		ISNULL(DTN1.PriceDate, '1/1/1950') as PriceDate,
		ISNULL(DTN1.PriceSource, 'UNK') as PriceSource,
		ISNULL(DTN1.Price,0.0) as Price,
		ISNULL(#tempCommodity.QuoteVolume, 0) as QuoteVolume
	from DTNPricing as DTN1		
				inner join #tempCommodity on DTN1.CommodityCode = #tempCommodity.CommodityCode
				inner join #tempShippers on #tempShippers.Shipper = DTN1.Shipper and #tempShippers.Commodity = DTN1.CommodityCode and
					DTN1.PriceDate in	(	
											select	MAX(DTN2.PriceDate) 
											from	DTNPricing as DTN2 
											where	DTN1.Shipper = DTN2.Shipper and 
													DTN1.Supplier = DTN2.Supplier and 
													DTN1.AccountOf = DTN2.AccountOf and 
													DTN1.CommodityCode = DTN2.CommodityCode and
													DTN2.PriceDate between @startDate and @effectiveDate
										)				
	order by DTN1.Shipper,
			 DTN1.Supplier,
			 DTN1.AccountOf,
			 DTN1.CommodityCode ,
			 DTN1.PriceDate,
			 DTN1.Price	
			 
drop table #tempCommodity
drop table #tempShippers

GO
GRANT EXECUTE ON  [dbo].[InvServiceGetBestPriceForConsignee] TO [public]
GO
