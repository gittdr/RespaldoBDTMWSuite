SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[ida_GetCurrencies]
as

select distinct
	c.currency
from
	(
	select cex.cex_from_curr as currency
	from currency_exchange as cex (NOLOCK)
	union
	select cex.cex_to_curr as currency  
	from currency_exchange as cex (NOLOCK)
	) as c
order by c.currency

GO
GRANT EXECUTE ON  [dbo].[ida_GetCurrencies] TO [public]
GO
