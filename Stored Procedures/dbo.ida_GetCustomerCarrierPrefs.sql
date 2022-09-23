SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ida_GetCustomerCarrierPrefs] (
	@lgh_number int
) as


select
	cpc.car_id
from companypreferredcarriers as cpc  (NOLOCK)
where
	cpc.cmp_id in (select cmp_id from stops where lgh_number = @lgh_number)

GO
GRANT EXECUTE ON  [dbo].[ida_GetCustomerCarrierPrefs] TO [public]
GO
