SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[LoadProductBasePrice] 
as
	insert ProductBasePrice (Shipper, Supplier, CommodityCode, PriceDate, Price, CreatedBy, ModifiedBy)	
	select DTNPricing.Shipper, DTNPricing.Supplier, DTNPricing.CommodityCode, DTNPricing.PriceDate, DTNPricing.Price, 'IMPORT', 'IMPORT' from DTNPricing 
	where not exists(select * from ProductBasePrice where DTNPricing.Shipper = ProductBasePrice.Shipper and DTNPricing.Supplier = DTNPricing.Supplier 
						and ProductBasePrice.PriceDate = DTNPricing.PriceDate and ProductBasePrice.Price = DTNPricing.Price and ProductBasePrice.CommodityCode = DTNPricing.CommodityCode )
GO
GRANT EXECUTE ON  [dbo].[LoadProductBasePrice] TO [public]
GO
