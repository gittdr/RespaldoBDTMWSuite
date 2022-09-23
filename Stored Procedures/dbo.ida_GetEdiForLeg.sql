SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--ida_GetEdiForLeg 6912
create proc [dbo].[ida_GetEdiForLeg]
	@lgh_number int
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
where eoo.lgh_number = @lgh_number
union
select
	null as car_id,
	ei.SCAC as SCAC,
	null as edi_code,
	action,
	null as cch_reason_code
from edi_inbound990_records as ei  (NOLOCK)
where IsNull(ei.lgh_number, convert(int,ei.ord_number)) = @lgh_number


GO
GRANT EXECUTE ON  [dbo].[ida_GetEdiForLeg] TO [public]
GO
