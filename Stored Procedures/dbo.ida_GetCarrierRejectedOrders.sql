SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create proc [dbo].[ida_GetCarrierRejectedOrders]
	@ord_number varchar(12)
as

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ordercarrierrates]') and OBJECTPROPERTY(id, N'IsTable') = 1)
select 
	ocr.car_id,
	ocr.ocr_response
from ordercarrierrates as ocr (NOLOCK)
where
	ocr.ord_number = @ord_number
	and
	(
		ocr.ocr_response = 1 -- Declined
		or
		ocr.ocr_response = 2 -- Timed out
	)
else
select 
	'' as car_id,
	0 as ocr_response
where 0=1





GO
GRANT EXECUTE ON  [dbo].[ida_GetCarrierRejectedOrders] TO [public]
GO
