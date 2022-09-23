SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create proc [dbo].[ida_GetEdiForOrder]
	@ord_number varchar(12)
as

select
	eoo.car_id,
	eoo.car_edi_scac as SCAC,
	eoo.edi_code,
	null as action,
	(select name from labelfile (nolock) 
	where labeldefinition = 'CarrierChangeCode' 
	and abbr = (select top 1 cch_reason_code 
				from carrierchangehistory cch (nolock) 
				where cch.ord_hdrnumber = eoo.ord_hdrnumber 
				and cch_orig_car_id = eoo.car_id)) as cch_reason_code
from edi_outbound204_order as eoo  (NOLOCK)
where eoo.ord_number = @ord_number
union
select
	null as car_id,
	ei.SCAC as SCAC,
	null as edi_code,
	action,
	null as cch_reason_code
from edi_inbound990_records as ei  (NOLOCK)
where ei.ord_number = @ord_number


GO
GRANT EXECUTE ON  [dbo].[ida_GetEdiForOrder] TO [public]
GO
